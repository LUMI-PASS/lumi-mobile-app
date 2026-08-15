import 'dart:async';

import 'package:dio/dio.dart';
import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:lumi_pass/common/utils/app_locale.dart';
import 'package:lumi_pass/common/utils/display_name_notifier.dart';
import 'package:lumi_pass/common/utils/catalog_revision.dart';
import 'package:lumi_pass/common/utils/user_location.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';
import 'home_state.dart';

@injectable
class HomeCubit extends BaseCubit<HomeBuildable, HomeListenable> {
  HomeCubit(this._repo, this._storage) : super(const HomeBuildable());
  final HomeRepository _repo;
  final Storage _storage;

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

    // Load home feed and the full category list concurrently.
    await Future.wait([getHome(), _loadAllCategories()]);

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
      return;
    }
    final here = await _location.resolve(prompt: prompt);
    _lat = here.lat;
    _lng = here.lng;
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
          coursesList: courses,
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
    // Reload categories in parallel so they stay up-to-date on language change.
    unawaited(_loadAllCategories());
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
            coursesList: courses,
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
