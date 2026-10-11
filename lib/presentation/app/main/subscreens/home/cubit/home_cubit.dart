import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:lumi_pass/common/utils/app_locale.dart';
import 'package:lumi_pass/common/utils/display_name_notifier.dart';
import 'package:lumi_pass/common/utils/catalog_revision.dart';
import 'package:lumi_pass/common/utils/user_location.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/api_model/order/day_booking.dart';
import 'package:lumi_pass/data/service/remote_config_service.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:lumi_pass/domain/repo/promo/promo_repository.dart';
import 'home_state.dart';

@injectable
class HomeCubit extends BaseCubit<HomeBuildable, HomeListenable> {
  HomeCubit(this._repo, this._storage, this._promo, this._orders)
      : super(const HomeBuildable());
  final HomeRepository _repo;
  final Storage _storage;
  final PromoRepository _promo;
  final OrdersApi _orders;

  String _lastLang = '';
  // Track premium/coupon state so we can detect changes on focus regain.
  bool _lastKnownHasPremium = false;
  int _lastKnownCouponPct = 0;

  // Where the "Near you" list is measured from. Held as instance fields so
  // every fetch below — first load, refresh, load-more — asks from the same
  // place; a page 2 measured from somewhere else would repeat and skip rows.
  double? _lat;
  double? _lng;

  /// The catalog revision this feed was built from. A course card is priced
  /// per viewer, so buying a trial changes what its card should say — see
  /// [catalogRevision].
  int _lastCatalogRevision = catalogRevision.value;

  /// Set once the location has been resolved, so a later `initWithLocation`
  /// (the page is re-entered on every tab switch) doesn't re-run the whole
  /// permission dance.
  bool _locationResolved = false;

  late final _location = UserLocationResolver(
    hasAsked: () async => _storage.locationAsked() == true,
    markAsked: () => _storage.locationAsked.set(true),
  );

  // Sync guards to prevent re-entrant load-more calls
  bool _newLoadLock = false;
  bool _nearLoadLock = false;

  static const int _pageLimit = 10;

  /// How many cards the "Входит в подписку" row deals. Ten, and ten only —
  /// the row is a sample of what a pack buys, not a catalogue, so it does not
  /// paginate. [loadMoreNewClasses] still tops it up while it is short, which
  /// is the one case where a deeper page is worth fetching for it.
  static const int subscriptionRowSize = 10;

  /// The row is shuffled from this FIXED seed, and from a FRESH [Random] each
  /// time, so the deal is a pure function of the feed: the same activities
  /// always come out in the same order.
  ///
  /// Both halves matter. A clock- or entropy-seeded shuffle would re-deal on
  /// every silent refresh, reordering the row under a parent who was
  /// mid-scroll and had changed nothing. A single long-lived [Random] would do
  /// the same more quietly — each deal would leave its state advanced, so the
  /// next refresh would shuffle the identical feed differently.
  static const int _shuffleSeed = 0x10C01;

  /// What [coursesAcrossCategories] buckets a course by: its FIRST category,
  /// lowercased.
  ///
  /// `HomClass.category` is a comma-separated LIST, not one name, and the card
  /// displays only the first of them (see `_ClassImage.firstCategory`) — so the
  /// first is what the user actually reads off the row, and spreading by
  /// anything else would spread by something invisible. Keying on the raw
  /// string instead would file "Dance, Fitness" and "Dance" as two different
  /// categories and happily deal them back to back.
  ///
  /// A course with no category at all gets a bucket to ITSELF, not a shared
  /// "uncategorised" one: pooled together they would take a single turn per
  /// round between them, so all but one would be pushed behind every named
  /// category.
  static String _categoryKey(HomClass course) {
    final first = (course.category ?? '')
        .split(',')
        .map((s) => s.trim())
        .firstWhere((s) => s.isNotEmpty, orElse: () => '');
    // Lowercased so a centre that typed "Shaxmat" and one that typed "shaxmat"
    // are one category rather than two.
    return first.isNotEmpty
        ? first.toLowerCase()
        : 'uncategorised:${course.id}';
  }

  /// An activity a Lumi Coin pack can pay for. The coin price is the whole
  /// test: the server sends it only on what coins are accepted for, and never
  /// on a course — courses are money-only, so they can never be in this row.
  static bool _paidWithCoins(HomClass c) => (c.newCoinPrice ?? 0) > 0;

  /// The row, dealt from everything the feed sent: the featured activities and
  /// the nearby ones, deduplicated, narrowed to what coins buy, shuffled, cut
  /// to [subscriptionRowSize].
  List<HomClass> _dealSubscriptionRow(
    List<HomClass> newClasses,
    List<HomClass> nearClasses,
  ) {
    final seen = <String>{};
    final pool = <HomClass>[];
    for (final c in [...newClasses, ...nearClasses]) {
      if (!_paidWithCoins(c)) continue;
      // A nearby activity is very often a featured one as well; without this
      // the row can deal the same card twice.
      final id = c.id;
      if (id != null && !seen.add(id)) continue;
      pool.add(c);
    }
    pool.shuffle(Random(_shuffleSeed));
    return pool.take(subscriptionRowSize).toList();
  }

  /// What the "Qiziqishlarga asosan" row shows.
  ///
  /// The server's `for_children` when it sent one: what suits this parent's
  /// children, from the topics picked for each. That list is used AS SENT —
  /// the server already dealt it across topics and across children, and
  /// re-spreading it by category here would undo exactly that.
  ///
  /// Otherwise the generic [courses], spread across categories: a parent with
  /// no children, none with topics picked, or a server that predates them.
  static List<HomClass> _interestsRow(HomData? data, List<HomClass> courses) {
    final forChildren = data?.forChildren?.data ?? const <HomClass>[];
    return forChildren.isNotEmpty
        ? forChildren
        : coursesAcrossCategories(courses);
  }

  /// [courses] reordered to walk ACROSS categories: one from each in turn,
  /// then the seconds, then the thirds. A feed that happened to send four
  /// dance courses in a row would otherwise fill the whole visible part of the
  /// "Qiziqishlarga asosan" row with dance.
  ///
  /// This is the row's FALLBACK ordering, not a recommendation — the stand-in
  /// for a parent the server has no picked topics for. See [_interestsRow].
  ///
  /// Stable: no shuffle, and the buckets keep the order the feed introduced
  /// them in, so the category it led with still leads the row.
  static List<HomClass> coursesAcrossCategories(List<HomClass> courses) {
    final byCategory = <String, List<HomClass>>{};
    for (final course in courses) {
      final key = _categoryKey(course);
      byCategory.putIfAbsent(key, () => []).add(course);
    }
    final buckets = byCategory.values.toList();
    final ordered = <HomClass>[];
    for (var round = 0; ordered.length < courses.length; round++) {
      for (final bucket in buckets) {
        if (round < bucket.length) ordered.add(bucket[round]);
      }
    }
    return ordered;
  }

  /// [row] with any newly-arrived coin activities appended, up to
  /// [subscriptionRowSize]. APPENDS rather than re-deals: the cards already on
  /// screen keep their places while a later page fills the row out behind
  /// them.
  static List<HomClass> growSubscriptionRow(
    List<HomClass> row,
    List<HomClass> incoming,
  ) {
    if (row.length >= subscriptionRowSize) return row;
    final have = row.map((c) => c.id).toSet();
    final fresh = incoming
        .where((c) => _paidWithCoins(c) && !have.contains(c.id))
        .toList()
      ..shuffle(Random(_shuffleSeed));
    if (fresh.isEmpty) return row;
    return [...row, ...fresh].take(subscriptionRowSize).toList();
  }

  Future<void> initWithLocation() async {
    // Held up front and not by getHome alone: resolving the location below is
    // an await of its own, and home treats an empty un-fetched state as a
    // connection failure. Without this the offline view sits on screen for as
    // long as the platform takes to answer.
    build((b) => b.copyWith(isLoading: true));
    _lastLang = currentLang;
    _lastKnownHasPremium = _storage.hasPremium() == true;
    _lastKnownCouponPct = _storage.planDiscountPercentage() ?? 0;

    // Already-granted permission costs one silent platform call, so the first
    // paint can be ordered from the real position. Anything else (never asked,
    // or refused) resolves to Tashkent centre without a dialog, and the prompt
    // happens after the feed is on screen — see below.
    await _applyLocation(prompt: false);

    // Load home feed, the full category list and the packet concurrently.
    await Future.wait([getHome(), _loadAllCategories(), _loadPacket()]);
    // After the location is known, and off the first paint: the shelf sits
    // well below the fold.
    unawaited(_loadCentres());

    // Now that home has rendered, ask for the permission — once, ever. Nothing
    // is awaited by the caller: whether the user grants, refuses or ignores the
    // sheet, the feed they are already looking at stands.
    unawaited(_promptForLocation());
  }

  /// Asks for the location permission and, if that moved us off the fallback,
  /// re-sorts the feed around where the user actually is.
  Future<void> _promptForLocation() async {
    if (_locationResolved) return;
    final before = (_lat, _lng);
    await _applyLocation(prompt: true);
    if ((_lat, _lng) == before) return;
    await refreshSilently();
  }

  /// Picks up a location permission granted outside the app, without ever
  /// prompting. Returns whether that actually moved us off the fallback — the
  /// caller only reloads the feed when it did.
  Future<bool> _adoptLocationGrantedElsewhere() async {
    if (_locationResolved) return false;
    if (!await _location.isGranted) return false;
    final before = (_lat, _lng);
    await _applyLocation(prompt: false);
    return (_lat, _lng) != before;
  }

  /// Resolves the location into [_lat]/[_lng]. Falls back to the centre of
  /// Tashkent, so these are never null once home has loaded and the feed is
  /// always ordered by distance from *something*.
  Future<void> _applyLocation({required bool prompt}) async {
    if (_locationResolved) return;
    if (!prompt && !await _location.isGranted) {
      _lat ??= kTashkentCentre.lat;
      _lng ??= kTashkentCentre.lng;
      currentUserLocation.value ??= kTashkentCentre;
      return;
    }
    final here = await _location.resolve(prompt: prompt);
    _lat = here.lat;
    _lng = here.lng;
    // Home is the only screen that resolves the location, but it is not the
    // only one that needs it: every activity card in the app measures its
    // distance line from here. Published rather than passed down, because the
    // cards are rendered from four different screens and three different
    // cubits — see [currentUserLocation].
    currentUserLocation.value = here;
    // A precise fix is the end of it. A fallback isn't: the user may still be
    // sitting on an unanswered permission sheet.
    if (here.isPrecise) _locationResolved = true;
  }

  /// Fetches the complete category list from the unlimited /categories endpoint
  /// and stores it in state. Called concurrently with [getHome] so categories
  /// are not limited to the 10-item page that the home feed returns.
  Future<void> _loadAllCategories() async {
    try {
      final cats = await _repo.getAllCategories();
      if (cats.isNotEmpty) build((b) => b.copyWith(categories: cats));
    } catch (_) {}
  }

  /// Fetches the packet campaign on its own small public GET.
  ///
  /// Never folded into [getHome]: the home feed does not carry promo campaigns,
  /// and a failure here has to cost the feed nothing — the slots that advertise
  /// the packet just don't render. Keeps the last good campaign on failure
  /// rather than pulling a card off the screen the user is looking at.
  Future<void> _loadPacket() async {
    try {
      final all = await _promo.getCampaigns();
      // The list is ordered best-offer-first, so the first row is the one to
      // advertise.
      build((b) => b.copyWith(packet: all.isEmpty ? null : all.first));
    } catch (_) {}
  }

  /// Fetches the centres shelf — see [HomeBuildable.centres]. Asked from the
  /// same place the near list is measured from, so the two agree on what
  /// "near" means. Keeps the last good list on failure.
  Future<void> _loadCentres() async {
    try {
      final page = await _repo.getDiscoveryBranches(
        page: 1,
        limit: _pageLimit,
        lat: _lat,
        lng: _lng,
      );
      build((b) => b.copyWith(centres: page.branches));
    } catch (_) {}
  }

  /// Fetches the rows of open-source centres — see
  /// [HomeBuildable.unclaimedShelves]. Same origin as the near list, and the
  /// last good rows are kept on failure.
  Future<void> _loadUnclaimedShelves() async {
    try {
      final shelves = await _repo.getUnclaimedShelves(lat: _lat, lng: _lng);
      build((b) => b.copyWith(unclaimedShelves: shelves));
    } catch (_) {}
  }

  /// Whether there is an account behind this session. The feed's banners for
  /// things only an account has — a referral code, a saved list — are left
  /// out without one, rather than opening a screen that answers 401 and
  /// throws the visitor at the login page.
  bool get isSignedIn => _canReadOrders;

  /// Whether this device may ask the orders endpoint for anything.
  ///
  /// Guarded rather than attempted: [AuthInterceptor] logs the user out and
  /// throws them at the login screen on ANY 401, so a speculative call for a
  /// signed-out browser would not merely come back empty — it would end their
  /// session. The review build is allowed through because the interceptor
  /// supplies it a token of its own.
  bool get _canReadOrders =>
      _storage.tokens.call()?.access != null ||
      RemoteConfigService.instance.isInReview;

  /// Fetches what has to be attended today, for the shelf above the banners.
  ///
  /// Its own request, like the packet's, and for the same reason: the home
  /// feed does not carry the user's bookings, and a failure here must cost the
  /// feed nothing — the shelf simply isn't there. Keeps the last good list on
  /// failure rather than pulling a card out from under someone mid-scroll.
  Future<void> _loadTodayBookings() async {
    if (!_canReadOrders) {
      if (buildable.todayBookings.isNotEmpty) {
        build((b) => b.copyWith(todayBookings: const []));
      }
      return;
    }
    try {
      final orders = await _orders.getOrders();
      build((b) => b.copyWith(todayBookings: DayBooking.dueToday(orders)));
    } catch (_) {}
  }

  /// Reloads the greeting name from the server on every home fetch.
  ///
  /// Both directions matter. Writing the name when the server sends one was
  /// already here; *clearing* it when the server says the account has none was
  /// not — so a freshly registered user, who has no name yet, kept being greeted
  /// by whatever name the previous account on this device had left behind.
  ///
  /// Guarded on [user] being present: an absent `for_user` means the response
  /// didn't carry the user at all, which is not the same as "this user has no
  /// name", and must not wipe a good one.
  void _syncDisplayName(HomForUser? user) {
    if (user == null) return;
    final firstName = user.firstName?.trim() ?? '';
    if (firstName.isNotEmpty) {
      _storage.parentName.set(firstName);
      displayNameNotifier.value = firstName;
    } else {
      _storage.parentName.set(null);
      displayNameNotifier.value = null;
    }
  }

  Future<void> refreshIfLanguageChanged() async {
    final lang = currentLang;
    if (_lastLang == lang) return;
    _lastLang = lang;
    await refreshSilently();
  }

  /// Called when the home tab regains focus. Silently refreshes when language
  /// OR coupon/premium status has changed since the last load, so discount
  /// badges and prices update immediately after a plan purchase.
  Future<void> refreshOnFocusGained() async {
    // Ahead of the change checks below, and deliberately not gated by them:
    // buying the packet turns its card from an offer into "2 visits left", and
    // none of the signals those checks watch move when that happens.
    unawaited(_loadPacket());
    // Same reasoning, and one more: a booking made minutes ago on another tab
    // is due today, and nothing those checks watch moves when it is made. The
    // clock alone is also a change — a lesson finishes while the app sits on
    // another tab — so the shelf is re-read every time home comes back.
    unawaited(_loadTodayBookings());

    final lang = currentLang;
    final hasPremium = _storage.hasPremium() == true;
    final couponPct = _storage.planDiscountPercentage() ?? 0;

    final langChanged = _lastLang != lang;
    final couponChanged =
        _lastKnownHasPremium != hasPremium || _lastKnownCouponPct != couponPct;
    // Someone who refused the prompt and then turned the permission on in
    // Settings comes back to a feed that would otherwise stay ordered from the
    // city centre for the rest of the session. Nothing else notices that
    // change, so this is the place to catch it.
    final locationChanged = await _adoptLocationGrantedElsewhere();
    // A purchase completed elsewhere in the app re-prices every course card:
    // the trial just bought is no longer the one on offer.
    final catalogChanged = _lastCatalogRevision != catalogRevision.value;

    if (!langChanged &&
        !couponChanged &&
        !locationChanged &&
        !catalogChanged) {
      return;
    }
    _lastCatalogRevision = catalogRevision.value;

    _lastLang = lang;
    _lastKnownHasPremium = hasPremium;
    _lastKnownCouponPct = couponPct;

    await refreshSilently();
  }

  Future<void> getHome() async {
    // Alongside the feed, not inside it: a different endpoint, and the shelf
    // must not hold up the first paint of the page. This covers both the first
    // load and pull-to-refresh, which is the gesture someone makes when they
    // have just paid for something.
    unawaited(_loadTodayBookings());
    // Here rather than at start-up only, so a pull-to-refresh picks up a
    // centre that was published a minute ago.
    unawaited(_loadUnclaimedShelves());
    return callable(
      future: _repo.getHome(
        newClassesPage: 1,
        newClassesLimit: _pageLimit,
        categoryPage: 1,
        categoryLimit: _pageLimit,
        nearClassPage: 1,
        nearClassLimit: _pageLimit,
        lat: _lat,
        lng: _lng,
      ),
      buildOnStart: () => buildable.copyWith(isLoading: true),
      buildOnData: (data) {
        final newClasses = data.data?.newClasses?.data ?? [];
        final nearClasses = data.data?.nearClasses?.data ?? [];
        final courses = data.data?.courses?.data ?? [];
        _syncDisplayName(data.data?.forUser);
        return buildable.copyWith(
          homeModel: data,
          newClassesList: newClasses,
          nearClassesList: nearClasses,
          coursesList: _interestsRow(data.data, courses),
          subscriptionList: _dealSubscriptionRow(newClasses, nearClasses),
          newClassesPage: 2,
          nearClassesPage: 2,
          hasMoreNewClasses: newClasses.length >= _pageLimit,
          hasMoreNearClasses: nearClasses.length >= _pageLimit,
        );
      },
      onErrorData: (error) {
        if (error is DioException) {
          if (error.response?.statusCode == 500 ||
              error.response?.statusCode == 502) {
            display.error(Strings.serverErrorTryLater);
          } else if (error.type == DioExceptionType.connectionError ||
              error.type == DioExceptionType.connectionTimeout) {
            display.error(Strings.connectionError);
          }
        }
        display.error(error);
      },
      buildOnDone: () => buildable.copyWith(isLoading: false),
    );
  }

  /// Silent refresh (used on tab focus) — no shimmer.
  Future<void> refreshSilently() async {
    // Reload categories and the packet in parallel so they stay up-to-date on
    // language change.
    unawaited(_loadAllCategories());
    unawaited(_loadPacket());
    unawaited(_loadTodayBookings());
    unawaited(_loadCentres());
    unawaited(_loadUnclaimedShelves());
    try {
      final data = await _repo.getHome(
        newClassesPage: 1,
        newClassesLimit: _pageLimit,
        categoryPage: 1,
        categoryLimit: _pageLimit,
        nearClassPage: 1,
        nearClassLimit: _pageLimit,
        lat: _lat,
        lng: _lng,
      );
      final newClasses = data.data?.newClasses?.data ?? [];
      final nearClasses = data.data?.nearClasses?.data ?? [];
      final courses = data.data?.courses?.data ?? [];
      _syncDisplayName(data.data?.forUser);
      build((b) => b.copyWith(
            homeModel: data,
            newClassesList: newClasses,
            nearClassesList: nearClasses,
            coursesList: _interestsRow(data.data, courses),
            subscriptionList: _dealSubscriptionRow(newClasses, nearClasses),
            newClassesPage: 2,
            nearClassesPage: 2,
            hasMoreNewClasses: newClasses.length >= _pageLimit,
            hasMoreNearClasses: nearClasses.length >= _pageLimit,
          ));
    } catch (_) {}
  }

  Future<void> loadMoreNewClasses() async {
    if (_newLoadLock || buildable.isLoadingNewClasses || !buildable.hasMoreNewClasses) return;
    _newLoadLock = true;
    build((b) => b.copyWith(isLoadingNewClasses: true));

    try {
      final data = await _repo.getHome(
        newClassesPage: buildable.newClassesPage,
        newClassesLimit: _pageLimit,
        lat: _lat,
        lng: _lng,
      );
      final incoming = data.data?.newClasses?.data ?? [];
      final existingIds = buildable.newClassesList.map((c) => c.id).toSet();
      final unique =
          incoming.where((c) => !existingIds.contains(c.id)).toList();

      build((b) => b.copyWith(
            newClassesList: [...b.newClassesList, ...unique],
            subscriptionList: growSubscriptionRow(b.subscriptionList, unique),
            newClassesPage: b.newClassesPage + 1,
            isLoadingNewClasses: false,
            hasMoreNewClasses: incoming.length >= _pageLimit,
          ));
    } catch (_) {
      build((b) => b.copyWith(isLoadingNewClasses: false));
    } finally {
      _newLoadLock = false;
    }
  }

  Future<void> loadMoreNearClasses() async {
    if (_nearLoadLock || buildable.isLoadingNearClasses || !buildable.hasMoreNearClasses) return;
    _nearLoadLock = true;
    build((b) => b.copyWith(isLoadingNearClasses: true));

    try {
      final data = await _repo.getHome(
        nearClassPage: buildable.nearClassesPage,
        nearClassLimit: _pageLimit,
        lat: _lat,
        lng: _lng,
      );
      final incoming = data.data?.nearClasses?.data ?? [];
      final existingIds = buildable.nearClassesList.map((c) => c.id).toSet();
      final unique =
          incoming.where((c) => !existingIds.contains(c.id)).toList();

      build((b) => b.copyWith(
            nearClassesList: [...b.nearClassesList, ...unique],
            nearClassesPage: b.nearClassesPage + 1,
            isLoadingNearClasses: false,
            hasMoreNearClasses: incoming.length >= _pageLimit,
          ));
    } catch (_) {
      build((b) => b.copyWith(isLoadingNearClasses: false));
    } finally {
      _nearLoadLock = false;
    }
  }

  Future<void> getCategories() async {
    return callable(
      future: _repo.getAllCategories(),
      buildOnStart: () => buildable.copyWith(isLoading: true),
      buildOnData: (data) {
        return buildable.copyWith(categories: data);
      },
      onErrorData: (error) {
        if (error is DioException) {
          if (error.response?.statusCode == 500 ||
              error.response?.statusCode == 502) {
            display.error(Strings.serverErrorTryLater);
          } else if (error.type == DioExceptionType.connectionError ||
              error.type == DioExceptionType.connectionTimeout) {
            display.error(Strings.connectionError);
          }
        }
        display.error(error);
      },
      buildOnDone: () => buildable.copyWith(isLoading: false),
    );
  }

  void changePhoneState(bool isMatched) {
    build((buildable) => buildable.copyWith(isSelected: isMatched));
  }
}
