import 'dart:async';
import 'package:lumi_pass/common/widget/sale_notice.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_shadows.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/utils/app_locale.dart';
import 'package:lumi_pass/common/utils/user_location.dart';
import 'package:lumi_pass/common/utils/coupon_discount.dart';
import 'package:lumi_pass/common/widget/auth/gradient_button.dart';
import 'package:lumi_pass/common/widget/cashback_badge.dart';
import 'package:lumi_pass/common/widget/coin_amount.dart';
import 'package:lumi_pass/common/widget/new_coin_price.dart';
import 'package:lumi_pass/data/api_model/new_coins/new_coin_models.dart';
import 'package:lumi_pass/common/widget/detail/detail_card.dart';
import 'package:lumi_pass/common/widget/detail/socials_card.dart';
import 'package:lumi_pass/common/widget/distance_label.dart';
import 'package:lumi_pass/common/widget/expandable_description.dart';
import 'package:lumi_pass/common/utils/promo_pass_coverage.dart';
import 'package:lumi_pass/common/widget/promo_included_label.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';
import 'package:lumi_pass/common/widget/location_preview_map.dart';
import 'package:lumi_pass/common/widget/map_route_sheet.dart';
import 'package:lumi_pass/common/widget/route_video_tile.dart';
import 'package:lumi_pass/common/widget/stretchy_hero.dart';
import 'package:lumi_pass/data/api_model/class_full/class_full_model.dart';
import 'package:lumi_pass/data/api_model/socials/centre_socials.dart';
import 'package:lumi_pass/data/service/listing_event_reporter.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/api_model/wallet/cashback_preview.dart';
import 'package:lumi_pass/data/service/analytics_service.dart';
import 'package:lumi_pass/data/service/interest_reporter.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/presentation/app/home/course_detail/intake_waitlist_sheet.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/widgets/rating_widgets.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/widgets/rating_sheet.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/widgets/reviews_sheet.dart';
import 'package:lumi_pass/common/widget/save_heart_icon.dart';
import 'package:lumi_pass/data/service/saved_activity_store.dart';
import 'package:lumi_pass/domain/repo/courses/courses_api.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:lumi_pass/domain/repo/wallet/wallet_repository.dart';
import 'package:lumi_pass/presentation/app/cubit/app_cubit.dart';
import 'package:lumi_pass/presentation/app/cubit/app_state.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';

@RoutePage()
class ClassDetailPage extends StatefulWidget {
  const ClassDetailPage({super.key, required this.classModel});

  final HomClass classModel;

  @override
  State<ClassDetailPage> createState() => _ClassDetailPageState();
}

/// Hero carousel height — also the distance the top scrim fades in over.
const double _kHeroHeight = 300;

/// The venue strip on the location card — the map, and the arrival clip beside
/// it. Same height as branch detail's, so the two pages read as one place.
const double _kVenueStripHeight = 140;

class _ClassDetailPageState extends State<ClassDetailPage> {
  /// The saved shelf ("Saqlanganlar"). The heart used to be a `bool` in this
  /// state and nothing else: it filled on tap, emptied on the way back in, and
  /// no screen in the app could tell you what you had hearted. It now writes
  /// through to [SavedActivityStore], which keeps the shelf on the server.
  final _saved = getIt<SavedActivityStore>();

  /// The shelf is the account's, so a guest is sent to sign in instead — the
  /// same hand-off buying a course makes. A failed save needs nothing here:
  /// the store has already put the heart back.
  Future<void> _toggleSaved() async {
    final outcome = await _saved.toggle(widget.classModel);
    if (!mounted) return;
    if (outcome == SaveOutcome.needsSignIn) {
      await context.router.push(LoginRoute());
    }
  }
  List<String> _galleryImages = [];
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();

  /// Anchors the venue card so a fresh buyer can be scrolled straight to the
  /// centre's phone numbers — see [_scrollToVenueCard].
  final GlobalKey _venueCardKey = GlobalKey();

  /// Kept out of page state because the carousel advances every five seconds,
  /// and rebuilding the whole detail page for one dot is wasteful.
  final ValueNotifier<int> _currentImageIndex = ValueNotifier<int>(0);
  ClassFullModel? _full;
  Timer? _slideTimer;

  /// This class's cashback rate, for the badge on the prices card.
  ///
  /// A rate, not an amount: this page shows several prices (per age tier, per
  /// level), so what it can honestly say is the percentage. The soum figure is
  /// the booking sheet's job, once there is one order to price.
  ///
  /// Starts at [CashbackPreview.none] and stays there if the fetch fails, so
  /// the badge is simply absent rather than wrong.
  CashbackPreview _cashback = CashbackPreview.none;

  /// Set only for a course: its dated lessons and package prices, fetched from
  /// `/api/courses/:id`. The lesson dates are expanded server-side from the
  /// course's own weekday pattern, so the screen never re-derives them.
  CourseDetail? _course;

  /// Which group the parent picked, on a course sold as several.
  ///
  /// Single select, and never empty: a course always runs as some group, so the
  /// page states one rather than asking. It is seeded from the server's own
  /// default (cheapest with seats) the moment the course lands, and a tap
  /// replaces it — tapping the picked group again leaves it picked, since
  /// clearing it would leave the page with a price and dates belonging to
  /// nothing. Re-seeded on reload, because a purchase can change which group is
  /// still buyable and a stale pick would carry a sold-out group to checkout.
  ///
  /// Null only in the window before the course detail arrives; [_selectedLevel]
  /// falls back to the first group so nothing downstream has to handle that.
  String? _selectedLevelId;

  /// The groups this course is sold as, always at least one.
  ///
  /// A course the centre entered without subcourses is still a course that runs
  /// on days at a price — it is simply one group. Presenting it as such keeps
  /// one shape on this screen instead of two, so the schedule and the price are
  /// on the page whether or not anyone bothered to split the course up.
  List<CourseLevel> get _courseGroups {
    final detail = _course;
    if (detail == null) return const <CourseLevel>[];
    return detail.hasLevels ? detail.levels : [detail.flat];
  }

  /// The picked group. Null only while the course detail hasn't landed and
  /// there are no groups yet.
  ///
  /// With a single group the pick is implicit — see [_courseGroups]. With
  /// several, a pick that no longer matches any group (the reload dropped it)
  /// falls back to the first rather than to nothing: the page always has a
  /// group to price, date and sell.
  CourseLevel? get _selectedLevel {
    final groups = _courseGroups;
    if (groups.isEmpty) return null;
    if (groups.length == 1) return groups.first;
    final id = _selectedLevelId;
    if (id != null) {
      for (final level in groups) {
        if (level.id == id) return level;
      }
    }
    return groups.first;
  }

  /// A course is sold as a package, not per session. Known from the list model
  /// before the detail lands, so the CTA never flashes the ticket wording.
  bool get _isCourse => _full?.isCourse ?? widget.classModel.isCourse ?? false;

  /// An INTAKE is a course that is still recruiting: no schedule, so nothing
  /// is on sale and the CTA offers a waitlist instead of a purchase.
  ///
  /// Decided by `type` alone. A course that merely has no dates is a
  /// misconfigured course, not an intake, and keeps its existing behaviour.
  /// Known only once the course detail lands — until then the page carries no
  /// bottom bar at all, which is what an ordinary course now shows anyway, so
  /// nothing flickers in or out as the detail arrives.
  bool get _isIntake => _course?.isIntake ?? false;

  /// Set once this user holds a place for the group on screen. Read only as a
  /// yes/no — the app cannot take a place back, so the id itself is never used
  /// for anything now.
  String? get _waitlistEntryId =>
      _course?.intake?.entryIdFor(_defaultBuyLevel()?.id);

  /// 0 → hero fully visible, 1 → content scrolled under the top controls and
  /// the frosted scrim is fully on.
  ///
  /// A notifier rather than a field, because it moves on every scroll frame:
  /// as page state it dragged the whole tree — hero and every card — through a
  /// rebuild per frame,
  /// which is what made the page stutter under the finger. Only the scrim
  /// listens now.
  final ValueNotifier<double> _topScrim = ValueNotifier<double>(0);

  /// Whether the scrim has taken over the background under the status bar,
  /// which is when its icons have to flip to dark on a light theme.
  ///
  /// A notifier rather than plain state: as `setState` this rebuilt the ENTIRE
  /// page — every card, and on the class screen the price rows and the
  /// HTML-cleaned description with them — in the middle of a drag, for a
  /// change that only two `Brightness` values care about. See [build].
  final ValueNotifier<bool> _scrimTookOver = ValueNotifier<bool>(false);

  /// Whether this class is on sale right now.
  ///
  /// Read from both payloads, and pessimistically: the list model's
  /// `is_active` (the feed's word for "approved") answers on the very first
  /// frame and still answers if `/classes/:id` soft-failed, while the detail's
  /// own visibility + moderation state is the authoritative one once it lands.
  /// Either saying no is enough — checkout would reject the booking anyway.
  bool get _isBookable {
    final listed = widget.classModel;
    if (listed.isActive == false || listed.isVisible == false) return false;
    if (_isCatalog) return false;
    return _full?.isBookable ?? true;
  }

  /// Whether this is a CATALOGUE listing — a venue Lumi listed itself from a
  /// public directory, with no contract behind it and nothing on it to sell.
  ///
  /// Read from the card first so the answer is right on the FIRST frame: the
  /// bottom bar is not drawn at all for one of these, and a Book button that
  /// appears for the half-second before `/classes/:id` lands and then vanishes
  /// is worse than either outcome. Either payload saying yes is enough.
  bool get _isCatalog =>
      widget.classModel.isCatalog == true || _full?.isCatalog == true;

  /// The centre's own accounts, which stand in for the Book button on a
  /// catalogue row. Only `/classes/:id` carries them, so this is empty until
  /// it lands — and empty for a real partner, always.
  CentreSocials get _socials => _full?.socials ?? CentreSocials.empty;

  /// A courses-plan centre's accounts on its course — see
  /// [ClassFullModel.contactSocials]. Never on a catalogue row, which has
  /// [_socials] instead.
  CentreSocials get _contactSocials => _isCatalog
      ? CentreSocials.empty
      : (_full?.contactSocials ?? CentreSocials.empty);

  /// Counts a tap that leaves the app on this class, for the centre's
  /// statistics. Fire-and-forget — see [ListingEventReporter].
  void _reportTap(ListingAction action, {SocialNetwork? network}) =>
      getIt<ListingEventReporter>()
          .report(widget.classModel.id ?? _full?.id, action, network: network);

  // ─── Venue coordinates ────────────────────────────────────────────────────
  /// Where the class actually takes place, for the route sheet. The list model
  /// carries flat `latitude`/`longitude`; the detail's `branch_id` nests them
  /// under `location` — prefer whichever has arrived, list model first so the
  /// button is live before `/classes/:id` lands.
  ///
  /// Both are read through [isUsableCoords]: a branch row whose location was
  /// never filled in comes back as `0, 0` rather than as nothing, and a map
  /// centred on the Gulf of Guinea is a worse answer than no map card at all.
  double? get _venueLat => _venue?.$1;

  double? get _venueLng => _venue?.$2;

  (double, double)? get _venue {
    final listLat = widget.classModel.branch?.latitude;
    final listLng = widget.classModel.branch?.longitude;
    if (isUsableCoords(listLat, listLng)) return (listLat!, listLng!);
    final fullLat = _full?.branch?.lat;
    final fullLng = _full?.branch?.lng;
    if (isUsableCoords(fullLat, fullLng)) return (fullLat!, fullLng!);
    return null;
  }

  /// Street address for the sheet's subject line, if the payload carries one.
  /// The list model has it already localized; the detail's is a per-language
  /// map, so fall through the same chain the API models use.
  String? get _venueAddress {
    final listAddress = widget.classModel.branch?.address?.trim();
    if (listAddress != null && listAddress.isNotEmpty) return listAddress;
    final map = _full?.branch?.address;
    if (map == null) return null;
    for (final key in [currentLang, 'ru', 'en', 'uz']) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  // ─── Venue contact ────────────────────────────────────────────────────────
  /// The centre's "how to get here" clip, from the branch.
  ///
  /// Shown to everyone, not only to buyers: the clip answers "can I actually
  /// get there" — which door off the courtyard, which floor — and that is a
  /// question a parent asks BEFORE paying, not after.
  String? get _venueVideoUrl => _full?.branch?.videoUrl;

  bool get _hasVenueVideo => RouteVideoTile.canPlay(_venueVideoUrl);

  /// The centre's own phone numbers — the branch administrators a parent
  /// calls to ask about their booking. Already trimmed of blanks by
  /// [BranchSummary.fromJson].
  ///
  /// Buyers only, unlike the clip above: these are for questions about a
  /// booking that exists. Published on a browse page they would route every
  /// pre-sales question past Lumi, to a centre with no record of the caller.
  List<String> get _venuePhones => _full?.viewerPurchased == true
      ? (_full?.branch?.supportPhones ?? const <String>[])
      : const <String>[];

  /// The rating as last answered by `PUT /classes/:id/rating`, once this viewer
  /// has rated on this page — newer than what [_full] was loaded with.
  RatingSummary? _ratedSummary;

  RatingSummary get _rating =>
      _ratedSummary ?? _full?.rating ?? const RatingSummary();

  /// Only a buyer may rate — the backend refuses anyone else, so they are not
  /// offered the button.
  bool get _canRate => _full?.viewerPurchased == true;

  /// [star] is the one tapped in the [RatePrompt] — the sheet opens with it
  /// already picked.
  Future<void> _openRating(int star) async {
    final id = widget.classModel.id;
    final full = _full;
    if (id == null || full == null) return;
    final summary = await RatingSheet.show(
      context,
      activityId: id,
      initialRating: star,
      initialComment: _rating.viewerComment,
      title: _localized(full.name, fallback: widget.classModel.title ?? ''),
    );
    if (summary == null || !mounted) return;
    setState(() => _ratedSummary = summary);
    // Their comment is public the moment it is saved — show it to them too.
    unawaited(_loadReviews());
  }

  /// How many reviews the detail page's horizontal strip loads.
  static const _reviewsPreview = 8;

  /// The newest public reviews, and how many there are in all.
  ActivityReviewPage _reviews = const ActivityReviewPage();

  /// Non-fatal: the page is complete without its reviews card.
  Future<void> _loadReviews() async {
    final id = widget.classModel.id;
    if (id == null) return;
    try {
      final page = await getIt<OrdersApi>()
          .getClassReviews(id, limit: _reviewsPreview);
      if (!mounted) return;
      setState(() => _reviews = page);
    } catch (_) {
      // Keep whatever was already shown.
    }
  }

  /// Dials a number. `tel:` wants it unpunctuated — the console stores it the
  /// way a human reads it, so the digits are pulled back out here.
  ///
  /// Silent on failure by design: a device with no dialler (a tablet) is not
  /// an error worth a snackbar over a row that simply does nothing.
  Future<void> _callVenue(String phone) async {
    final digits = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.isEmpty) return;
    _reportTap(ListingAction.callClick);
    await launchUrl(Uri.parse('tel:$digits'));
  }

  // ─── Coupon discount helpers ──────────────────────────────────────────────
  /// The coupon's percentage on THIS class — the plan's percentage capped at
  /// Lumi's share of the class, which is what checkout will actually charge.
  ///
  /// Reads the plan's percentage from `AppCubit`'s Cubit state (watched, not
  /// a one-off `Storage` read) so this rebuilds the instant a purchase
  /// completes or a subscription is synced, instead of showing whatever was
  /// true the last time this page happened to build.
  num _couponPercent({required bool isWholeCourse}) {
    final app =
        context.watch<AppCubit>().state.buildable ?? const AppBuildable();
    final plan = app.hasPremium ? app.planDiscountPercentage : 0;
    return effectiveCouponPercent(
      plan,
      _full?.discountPercentage ?? widget.classModel.discountPercentage,
      isWholeCourse: isWholeCourse,
    );
  }

  /// The coupon on the price this page's ACTIVITY rows show. Zero on a course:
  /// what a course page prices there is the enrolment, and a coupon never
  /// discounts that.
  num get _couponPct => _couponPercent(isWholeCourse: _isCourse);

  /// The "Lumi Start" packet covering THIS activity, or null.
  ///
  /// Resolved here — the one place that knows which activity the screen is —
  /// and threaded down the same channel `couponPct` already travels, so the
  /// price rows need no idea the packet exists beyond rendering its label.
  ///
  /// `price: 0` deliberately: a screen shows several tiers at once and the
  /// ceiling applies per booking, so it is tested per ROW rather than here. The
  /// rows re-ask with their own figure.
  PromoPassCoverage? _promoPassFor({required bool isWholeCourse}) {
    final pass = watchPromoPass(context);
    if (pass == null) return null;
    return pass.covers(
      activityId: widget.classModel.id,
      price: 0,
      isWholeCourse: isWholeCourse,
    )
        ? pass
        : null;
  }

  @override
  void initState() {
    super.initState();
    _loadImages();
    _loadFull();
    _loadCashbackRate();
    _startAutoSlide();
    _scrollController.addListener(_onScroll);
    final cm = widget.classModel;
    getIt<AnalyticsService>().logEvent(
      AnalyticsEvent.classDetailViewed,
      params: {
        if (cm.id != null) 'class_id': cm.id!,
        if (cm.title != null) 'class_title': cm.title!,
        if (cm.category != null) 'category': cm.category!,
        if (cm.branch?.title != null) 'branch': cm.branch!.title!,
        if (cm.price != null) 'price': cm.price!,
        if (cm.discountPercentage != null)
          'discount_percentage': cm.discountPercentage!,
      },
    );
  }

  /// The cashback rate for this class.
  ///
  /// `purchase` is left unset here even for a course: the page shows both the
  /// trial and the full-enrolment prices, and the two can be configured at
  /// different rates — so the badge reports the full-course rate, and the
  /// booking sheet asks again for whichever half is actually being bought.
  Future<void> _loadCashbackRate() async {
    final id = widget.classModel.id;
    if (id == null) return;
    final preview = await getIt<WalletRepository>().getCashbackPreview(
      activityId: id,
      purchase: _isCourse ? 'full' : null,
    );
    if (!mounted) return;
    setState(() => _cashback = preview);
  }

  @override
  void dispose() {
    _slideTimer?.cancel();
    _pageController.dispose();
    _scrollController.dispose();
    _currentImageIndex.dispose();
    _topScrim.dispose();
    _scrimTookOver.dispose();
    super.dispose();
  }

  /// Fade the top scrim in over the second half of the hero, so it is fully on
  /// by the time the first card slides under the back/share/heart controls.
  void _onScroll() {
    final start = _kHeroHeight.h * 0.45;
    final end = _kHeroHeight.h * 0.85;
    final t =
        ((_scrollController.offset - start) / (end - start)).clamp(0.0, 1.0);
    _topScrim.value = t;

    _scrimTookOver.value = t > 0.5;
  }

  void _startAutoSlide() {
    _slideTimer?.cancel();
    _slideTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || _galleryImages.length <= 1) return;
      final next = (_currentImageIndex.value + 1) % _galleryImages.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _loadFull() async {
    final id = widget.classModel.id;
    if (id == null) return;
    // Two calls, because they answer two different questions: `/classes/:id` is
    // the content (gallery, description, branch), `/courses/:id` is the
    // commerce (dated lessons, what this user may buy and at what price).
    // Neither payload carries the other's.
    //
    // Fired TOGETHER when the feed already told us this is a course, rather
    // than chaining the second behind the first — they don't depend on each
    // other, and chaining them made the page wait out both round-trips end to
    // end. A course opened from somewhere that didn't say so falls back to
    // the chained call below, once `/classes/:id` has answered.
    final knownCourse = widget.classModel.isCourse == true;
    unawaited(_loadReviews());
    if (knownCourse) {
      // One frame late, not synchronously: this runs from initState, and
      // `_loadCourse` reads `context.locale` — an inherited lookup that is
      // illegal there. The frame costs nothing next to the round-trip, and
      // `/classes/:id` below is already in flight by then, which is the point.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_loadCourse(id));
      });
    }
    try {
      final full = await getIt<OrdersApi>().getClassFull(id);
      if (!mounted) return;
      setState(() {
        _full = full;
        _galleryImages = _resolveGallery(full);
      });
      if (full.isCourse && !knownCourse) unawaited(_loadCourse(id));
    } catch (_) {
      // Keep whatever gallery/list image we already have.
    }
  }

  /// Re-reads `/classes/:id` after a purchase completes on this page.
  ///
  /// `viewer_purchased` gates the centre's phone numbers, and it was answered
  /// before this parent bought — so without this, the numbers the purchase
  /// just earned them stay hidden until they leave the page and come back.
  /// Deliberately narrower than [_loadFull]: the course payload is reloaded by
  /// its own caller, and firing it twice would re-seed the picked group
  /// underneath them.
  Future<void> _refreshAfterPurchase() async {
    final id = widget.classModel.id;
    if (id == null) return;
    try {
      final full = await getIt<OrdersApi>().getClassFull(id);
      if (!mounted) return;
      setState(() {
        _full = full;
        _galleryImages = _resolveGallery(full);
      });
    } catch (_) {
      // Non-fatal — the numbers stay hidden until the page is reopened.
    }
    if (mounted && _venuePhones.isNotEmpty) _scrollToVenueCard();
  }

  /// Bring the venue card into view after a purchase, so the numbers the order
  /// just unlocked are the first thing seen on returning from the success
  /// screen — rather than something to be hunted for further down the page.
  ///
  /// Runs while the success screen is still on top: this page stays laid out
  /// underneath, so by the time it is popped back to, it is already in
  /// position. That is also why there is no animation — animating a scroll
  /// nobody can see only risks being interrupted.
  ///
  /// Best-effort. The content is a lazy [SliverList], so the card may not be
  /// built yet; `ensureVisible` needs a laid-out context and there is no
  /// reliable offset to fall back to. Doing nothing simply leaves the parent
  /// to scroll down themselves, which is where they were anyway.
  void _scrollToVenueCard() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final target = _venueCardKey.currentContext;
      if (target == null) return;
      Scrollable.ensureVisible(
        target,
        duration: Duration.zero,
        // A little off the top edge, so the card reads as a section that was
        // scrolled to rather than one jammed under the app bar.
        alignment: 0.1,
      );
    });
  }

  /// Course lessons + package prices. Failure is non-fatal: the page still
  /// renders, it just can't show the lesson list or open the purchase sheet.
  Future<void> _loadCourse(String id) async {
    try {
      final detail = await getIt<CoursesApi>()
          .detail(id, lang: context.locale.languageCode);
      if (!mounted) return;
      setState(() {
        _course = detail;
        // Re-seeded rather than cleared: the page always names a group. The
        // server's default is the cheapest one with seats left, which is the
        // same group it would have charged for had nothing been picked.
        final groups = detail.hasLevels ? detail.levels : [detail.flat];
        final fallback = groups.isEmpty ? null : groups.first;
        _selectedLevelId = detail.defaultLevelId ?? fallback?.id;
      });
    } catch (_) {
      // Leave _course null — the CTA reports "not ready yet" if tapped.
    }
  }

  List<String> _resolveGallery(ClassFullModel full) {
    final out = <String>[];
    final cover = full.imageUrl;
    if (cover != null && cover.isNotEmpty) out.add(cover);
    for (final s in full.images) {
      if (s.isNotEmpty && !out.contains(s)) out.add(s);
    }
    if (out.isEmpty) {
      final listImage = widget.classModel.image;
      if (listImage != null && listImage.isNotEmpty) out.add(listImage);
    }
    return out;
  }

  void _loadImages() {
    final initial = widget.classModel.image;
    if (initial != null && initial.isNotEmpty) {
      _galleryImages = [initial];
    }
  }

  String _getGenderText() {
    switch ((_full?.gender ?? widget.classModel.gender)?.toUpperCase()) {
      case 'MALE':
        return 'gender_male_only'.tr();
      case 'FEMALE':
        return 'gender_female_only'.tr();
      default:
        return 'gender_all'.tr();
    }
  }

  String _formatDuration(_Duration? d) {
    if (d == null) return '—';
    if (d.unbounded) return 'duration_unbounded'.tr();
    final minutes = d.minutes;
    if (minutes == null || minutes == 0) return '—';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    final hUnit = 'duration_h_unit'.tr();
    final mUnit = 'duration_min_unit'.tr();
    if (h > 0 && m > 0) return '$h$hUnit $m$mUnit';
    if (h > 0) return '$h $hUnit';
    return '$m $mUnit';
  }

  _Duration? _effectiveDuration(ClassFullModel? full) {
    final tierDurs = full?.ageTiers.expand((t) => t.durations).toList() ?? [];
    final hasUnbounded = tierDurs.any((d) => d.duration == null);
    final finite = tierDurs
        .where((d) => d.duration != null && d.duration! > 0)
        .map((d) => d.duration!)
        .toList();
    final listMin = widget.classModel.duration;
    final maxFinite = finite.isNotEmpty
        ? finite.reduce((a, b) => a > b ? a : b)
        : (listMin != null && listMin > 0 ? listMin : null);
    if (hasUnbounded) return _Duration.unbounded(maxFinite);
    if (maxFinite == null) return null;
    return _Duration.finite(maxFinite);
  }

  ({int from, int to})? _effectiveAgeRange(ClassFullModel? full) {
    final cm = widget.classModel;
    final listFrom = cm.minAge ?? 0;
    final listTo = cm.maxAge ?? 0;
    if (listFrom > 0 || listTo > 0) {
      return (from: listFrom, to: listTo == 0 ? listFrom : listTo);
    }
    if (full != null) {
      if (full.ageFrom > 0 || full.ageTo > 0) {
        return (
          from: full.ageFrom,
          to: full.ageTo == 0 ? full.ageFrom : full.ageTo,
        );
      }
      if (full.ageTiers.isNotEmpty) {
        final tiers = full.ageTiers;
        final from =
            tiers.map((t) => t.ageFrom).reduce((a, b) => a < b ? a : b);
        final tos = tiers.map((t) => t.ageTo ?? 99).toList();
        final to = tos.reduce((a, b) => a > b ? a : b);
        return (from: from, to: to);
      }
    }
    return null;
  }

  String _ageLabel() {
    final r = _effectiveAgeRange(_full);
    if (r == null) return '—';
    if (r.to <= 0 || r.to == r.from) {
      return '${r.from}+ ${'filter_years_label'.tr()}';
    }
    return '${r.from}-${r.to} ${'filter_years_label'.tr()}';
  }

  String _localized(Map<String, dynamic> map, {String fallback = ''}) {
    final lang = currentLang;
    final v = map[lang] ?? map['ru'] ?? map['en'] ?? map['uz'];
    if (v is String && v.isNotEmpty) return v;
    return fallback;
  }

  String _cleanHtml(String html) {
    return html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p\s*>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '• ')
        .replaceAll(RegExp(r'</li\s*>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]+>', caseSensitive: false), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  /// Bullet lines out of a localized rich-text map (`important_notes`,
  /// `required_items`). The partner console stores these as HTML, so flatten it
  /// and treat every non-empty line as one bullet — `_cleanHtml` already turns
  /// `<li>`/`<br>`/`</p>` into "• " + newlines, we just strip the marker so the
  /// row can draw its own dot.
  List<String> _bullets(Map<String, dynamic> map) {
    final text = _cleanHtml(_localized(map));
    if (text.isEmpty) return const [];
    return text
        .split('\n')
        .map((l) => l.replaceFirst(RegExp(r'^\s*[•·\-–—*]\s*'), '').trim())
        .where((l) => l.isNotEmpty)
        .toList();
  }

  Future<void> _shareClass() async {
    try {
      final id = widget.classModel.id;
      final title = widget.classModel.title ?? '';
      final branch =
          widget.classModel.branch?.title ?? _full?.branch?.title ?? '';
      final label = branch.isNotEmpty ? '$title — $branch' : title;

      final String text;
      if (id != null && id.isNotEmpty) {
        final url = 'https://mobile-api.lumipass.uz/share/class/$id';
        text = label.isNotEmpty ? '$label\n$url' : url;
      } else if (label.isNotEmpty) {
        text = label;
      } else {
        return;
      }

      final box = context.findRenderObject() as RenderBox?;
      final origin =
          box == null ? null : box.localToGlobal(Offset.zero) & box.size;
      _reportTap(ListingAction.shareClick);
      await Share.share(
        text,
        subject: title.isNotEmpty ? title : 'Lumi',
        sharePositionOrigin: origin,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share error: $e')),
        );
      }
    }
  }

  Future<void> _openBooking() async {
    final full = _full;
    // Unreachable while the bar is drawn from [_isBookable] — belt and braces
    // for a class that turns out to be a catalogue listing, which has no
    // contract and no price behind it and would fail at checkout.
    if (_isCatalog) return;
    if (full == null || (full.pricesSummary.isEmpty && full.ageTiers.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('cta_loading'.tr())),
      );
      return;
    }
    getIt<AnalyticsService>().logEvent(
      AnalyticsEvent.bookButtonTapped,
      params: {
        if (full.id != null) 'class_id': full.id!,
        if (widget.classModel.title != null)
          'class_title': widget.classModel.title!,
      },
    );
    // The one interest signal the backend cannot see for itself: if they walk
    // away from here, no request is ever made and nothing records that they
    // nearly booked. Queued and sent in the background — see [InterestReporter].
    if (full.id != null) getIt<InterestReporter>().bookTapped(full.id!);
    final purchased = await context.router.push(BookingRoute(clazz: full));
    if (purchased == true && mounted) await _refreshAfterPurchase();
  }

  /// Which group an INTAKE's waitlist button puts the child down for.
  ///
  /// Whichever one the parent picked; the server's default (cheapest with
  /// seats) stands in if the pick went stale under a reload, rather than the
  /// tap doing nothing. A course entered as one group has no choice to make.
  ///
  /// Nothing else reads this any more — a course is not sold from this page,
  /// so there is no purchase left for it to name.
  CourseLevel? _defaultBuyLevel() {
    final detail = _course;
    if (detail == null) return null;
    final picked = _selectedLevel;
    if (picked != null) return picked;
    final id = detail.defaultLevelId;
    for (final l in detail.levels) {
      if (l.id == id) return l;
    }
    return detail.levels.isNotEmpty ? detail.levels.first : detail.flat;
  }

  /// Put a child down for an INTAKE. Not a purchase — no order, no money, no
  /// seat — so it deliberately does not go anywhere near the booking flow.
  Future<void> _onJoinWaitlistTapped() async {
    final id = _full?.id ?? widget.classModel.id;
    if (id == null) return;
    final level = _defaultBuyLevel();
    final joined = await IntakeWaitlistSheet.show(
      context,
      activityId: id,
      subcourseId: level?.id,
      groupName: level?.name,
      courseTitle: widget.classModel.title,
    );
    // Reload rather than patching state by hand: the joined flag lives on the
    // course detail, per group, and that is the one thing the CTA reads.
    if (joined && mounted) await _loadCourse(id);
  }

  // A course used to be bought from this page in two ways: the sticky CTA
  // below sold the whole enrolment, and each group panel's trial ladder sold
  // one trial lesson. Neither is offered any more — see `hasBottomBar` — so
  // the two handlers that opened the course booking flow are gone with them,
  // and the group panels and the ladder itself have gone too: a course is no
  // longer presented as the groups it splits into, and trial lessons are not
  // shown anywhere in the app.
  //
  // The purchase flow itself is UNTOUCHED, deliberately: `BookingPage` still
  // takes `CoursePurchaseOption.trial` / `.full`, and a course order already
  // paid for still renders everywhere it did. Nothing breaks for a parent
  // mid-trial, and showing trials again is a matter of restoring the UI.

  /// What a course costs, or null when there is nothing honest to quote.
  ///
  /// ONE figure, because the page no longer says which group it belongs to:
  /// the CHEAPEST price on offer across every group, which is the only figure
  /// that cannot be contradicted by a group the reader can no longer see.
  /// [_CoursePrice.isFrom] then says whether more than one price sits behind
  /// it — several groups priced differently, or a group priced per age
  /// bracket — so it can read "from X" rather than as a flat price another
  /// group charges more than.
  _CoursePrice? get _coursePrice {
    final groups = _courseGroups;
    if (groups.isEmpty) return null;
    num? cheapest;
    var varies = false;
    for (final level in groups) {
      final price = level.coursePrice;
      if (price <= 0) continue;
      // A group priced per age bracket is already several prices on its own.
      if (level.hasMultiplePriceTiers) varies = true;
      if (cheapest == null) {
        cheapest = price;
      } else if (price != cheapest) {
        varies = true;
        if (price < cheapest) cheapest = price;
      }
    }
    if (cheapest == null) return null;
    return (amount: cheapest, isFrom: varies);
  }

  /// Price rows for display: ONE PER (age tier x duration), which is the same
  /// list the booking sheet sells from.
  ///
  /// A bracket priced by how long the child stays is several prices, not one.
  /// Quoting the cheapest of them and calling it the bracket's price put a
  /// figure on this card that checkout then charged more than — so each
  /// duration gets its own row, named by [_PriceRowData.duration] so two rows
  /// under the same age read as the two things they are.
  ///
  /// The flat price-summary ranges are the fallback, and carry no duration.
  List<_PriceRowData> _priceRows() {
    final full = _full;
    final rows = <_PriceRowData>[];
    if (full == null) return rows;
    if (full.ageTiers.isNotEmpty) {
      for (final t in full.ageTiers) {
        final adults = t.ageFrom >= 6 || t.ageTo == null;
        final subtitle =
            adults ? 'price_tier_all'.tr() : 'price_tier_children'.tr();
        final icon = adults
            ? Assets.icons.home.profile2user
            : Assets.icons.home.babyGirl;
        // A tier with no durations still names a bracket the class admits —
        // it just has no price to quote, same as before.
        if (t.durations.isEmpty) {
          rows.add((
            range: t.rangeLabel,
            subtitle: subtitle,
            duration: null,
            price: 0,
            newCoinPrice: null,
            icon: icon,
          ));
          continue;
        }
        for (final d in t.durations) {
          rows.add((
            range: t.rangeLabel,
            subtitle: subtitle,
            duration: d.durationLabel,
            price: d.price,
            newCoinPrice:
                d.newCoinPrice ?? newCoinPriceFor(d.price, full.newCoinRate),
            icon: icon,
          ));
        }
      }
    } else {
      for (final r in full.pricesSummary) {
        rows.add((
          range: r.rangeLabel,
          subtitle: 'price_tier_children'.tr(),
          duration: null,
          price: r.price,
          newCoinPrice:
              r.newCoinPrice ?? newCoinPriceFor(r.price, full.newCoinRate),
          icon: Assets.icons.home.babyGirl,
        ));
      }
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final classModel = widget.classModel;
    final full = _full;
    final safeTop = MediaQuery.of(context).viewPadding.top;
    final safeBottom = MediaQuery.of(context).viewPadding.bottom;

    final title = full == null
        ? (classModel.title ?? '')
        : _localized(full.name, fallback: classModel.title ?? '');
    final branchTitle = full?.branch?.title ?? classModel.branch?.title ?? '';
    final description =
        full == null ? '' : _cleanHtml(_localized(full.description));
    final priceRows = _priceRows();
    // Null until the course detail lands, and on a course the centre never
    // priced — the card is then simply absent rather than showing a zero.
    final coursePrice = _isCourse ? _coursePrice : null;
    final languages = full?.activityLanguages ?? const <String>[];
    // Nothing on a course is sold from this page any more — not the enrolment
    // and not its trial lessons — so a course carries no bottom bar. An INTAKE
    // keeps one: its button joins a waiting list, which costs nothing and is
    // the only thing there is to do on a group that is still filling up.
    // A CATALOGUE listing gets none either, and for a different reason: there
    // is nothing to sell. Not even the inert "booking available soon" bar —
    // that promises a sale that is never coming. The centre's own accounts
    // take its place in the cards below.
    final hasBottomBar = (!_isCourse || _isIntake) && !_isCatalog;
    final notes =
        full == null ? const <String>[] : _bullets(full.importantNotes);
    final requiredItems =
        full == null ? const <String>[] : _bullets(full.requiredItems);

    // Stable keys matter while the two detail requests are landing. A course
    // card or description can be inserted above the location card; without a
    // child-index callback SliverList would recycle the element at that index
    // and rebuild the wrong card into it.
    final contentChildren = <Widget>[
      KeyedSubtree(
        key: const ValueKey<String>('class-detail-main'),
        child: _mainCard(c, title, branchTitle),
      ),
      // The centre's own accounts — Instagram, Telegram, website. A catalogue
      // row has no bottom bar, so this card is the only thing on the page a
      // parent can act on; it goes directly under the title rather than at the
      // bottom with the small print.
      if (_socials.openable.isNotEmpty)
        _detailSection(
          'class-detail-socials',
          CentreSocialsCard(
            c: c,
            socials: _socials,
            hint: 'detail_socials_hint'.tr(),
            onOpen: (link) =>
                _reportTap(ListingAction.socialClick, network: link.network),
          ),
        )
      // A courses-plan centre's own accounts, on its course. No hint: unlike a
      // catalogue venue, this centre is a real partner, and nothing here needs
      // explaining.
      else if (_contactSocials.openable.isNotEmpty)
        _detailSection(
          'class-detail-contact-socials',
          CentreSocialsCard(
            c: c,
            socials: _contactSocials,
            onOpen: (link) =>
                _reportTap(ListingAction.socialClick, network: link.network),
          ),
        ),
      // The "Guruhlar" card is gone: a course is no longer presented as the
      // groups it is split into. It used to carry four things at once — the
      // group picker, the timetable, the price and the trial ladder — so what
      // replaces it is the one of those that still belongs on the page, the
      // price, in a card of its own.
      if (_isCourse && coursePrice != null)
        _detailSection(
          'class-detail-course-price',
          _coursePriceCard(c, coursePrice),
        )
      else if (!_isCourse && priceRows.isNotEmpty)
        _detailSection(
          'class-detail-prices',
          _pricesCard(c, priceRows),
        ),
      if (description.isNotEmpty)
        _detailSection(
          'class-detail-description',
          _descriptionCard(c, title, description),
        ),
      // The card carries the map, and — after a purchase — the centre's own
      // arrival clip and phone numbers. A venue with no usable coordinates
      // still gets the card once it has those to show.
      if (_venue != null || _hasVenueVideo || _venuePhones.isNotEmpty)
        _detailSection(
          'class-detail-location',
          KeyedSubtree(key: _venueCardKey, child: _locationCard(c, branchTitle)),
        ),
      // The home of everything about ratings: the score, the stars a buyer
      // taps to give theirs, and what others wrote. Shown as soon as there is
      // any of the three.
      if (_rating.hasRatings || _reviews.reviews.isNotEmpty || _canRate)
        _detailSection(
          'class-detail-reviews',
          _reviewsCard(c),
        ),
      if (notes.isNotEmpty)
        _detailSection(
          'class-detail-notes',
          _bulletCard(
            c,
            icon: Assets.icons.detail.iconsaxQuestionMark,
            iconGradient: AppGradients.brand,
            title: 'detail_notes'.tr(),
            items: notes,
          ),
        ),
      if (requiredItems.isNotEmpty)
        _detailSection(
          'class-detail-required-items',
          _bulletCard(
            c,
            icon: Assets.icons.detail.iconsaxReceipt,
            iconGradient: AppGradients.green,
            title: 'detail_bring'.tr(),
            items: requiredItems,
          ),
        ),
      if (languages.isNotEmpty)
        _detailSection(
          'class-detail-languages',
          _languageCard(c, languages),
        ),
    ];

    // Over the hero the status bar sits on a photo (light icons); once the
    // scrim takes over on a light background the icons have to flip to dark.
    // The page itself is handed through as `child`, so crossing that threshold
    // rebuilds the overlay style and nothing else — see [_scrimTookOver].
    return ValueListenableBuilder<bool>(
      valueListenable: _scrimTookOver,
      builder: (_, tookOver, child) {
        final darkIcons = !c.isDark && tookOver;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                darkIcons ? Brightness.dark : Brightness.light,
            statusBarBrightness:
                darkIcons ? Brightness.light : Brightness.dark,
          ),
          child: child!,
        );
      },
      child: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(child: _hero(c, safeTop)),
                // These used to be one large Column in a SliverToBoxAdapter.
                // That eagerly mounted every child, including everything well
                // below the fold, while the opening network calls and hero
                // transition were competing for the same frame budget. A
                // sliver delegate mounts cards only as they approach the
                // viewport.
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, index) => contentChildren[index],
                      childCount: contentChildren.length,
                      findChildIndexCallback: (key) {
                        final index = contentChildren.indexWhere(
                          (child) => child.key == key,
                        );
                        return index < 0 ? null : index;
                      },
                    ),
                  ),
                ),
                // Runway under the last card so the sticky CTA never covers
                // it — one button tall where there is a button. A course has
                // no bar, so it gets ordinary bottom air instead of a gap the
                // height of a control that isn't there.
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: (hasBottomBar ? 90.h : 24.h) + safeBottom,
                  ),
                ),
              ],
            ),
            // Frosted scrim under the top controls — content blurs and fades
            // out as it scrolls beneath them (Figma "Детали / scrolled").
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                // No `Opacity` here: the scrim fades itself, because a
                // BackdropFilter inside an opacity layer blurs that layer
                // instead of the screen — and pays for a saveLayer every
                // frame to do it. See [DetailTopScrim].
                child: ValueListenableBuilder<double>(
                  valueListenable: _topScrim,
                  builder: (_, t, __) => DetailTopScrim(
                    color: c.scaffoldBg,
                    height: safeTop + 56.h,
                    t: t,
                  ),
                ),
              ),
            ),
            // Top controls over the hero.
            Positioned(
              top: safeTop + 8.h,
              left: 16.w,
              right: 16.w,
              child: Row(
                children: [
                  DetailControlButton(
                    child: HomeIcon(Assets.icons.home.arrow,
                        size: 16, color: c.textPrimary),
                    onTap: () => context.router.pop(),
                  ),
                  const Spacer(),
                  DetailControlButton(
                    onTap: _shareClass,
                    child: HomeIcon(Assets.icons.home.share,
                        size: 16, color: c.textSecondary),
                  ),
                  8.horizontalSpace,
                  // Reads the store rather than a local flag, so the heart is
                  // already filled when the page opens on something saved, and
                  // the shelf's count moves the moment it is tapped.
                  ValueListenableBuilder<Set<String>>(
                    valueListenable: _saved.savedIds,
                    builder: (_, __, ___) {
                      final isSaved = _saved.contains(widget.classModel.id);
                      return DetailControlButton(
                        onTap: _toggleSaved,
                        child: SaveHeartIcon(
                          saved: isSaved,
                          offColor: c.textSecondary,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Bottom CTA — a plain class, which is bought here, and an
            // intake course, whose button joins a waiting list rather than
            // selling anything.
            //
            // A COURSE carries no bar at all. Neither the whole-course button
            // that used to sit here nor the trial button under each group's
            // ladder is offered any more, so a course page says what the course
            // is, what its groups cost and when they run, and leaves the buying
            // to the centre. See [hasBottomBar].
            if (hasBottomBar)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: c.scaffoldBg,
                    boxShadow: AppShadows.bottomBar,
                  ),
                  padding:
                      EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h + safeBottom),
                  // An inactive class — hidden by the centre, or not approved
                  // by moderation — can still be reached by direct link, from
                  // an existing booking, or from a feed page that loaded before
                  // it was taken down, so the page opens but must not be
                  // bookable. Inert "booking available soon" rather than a Book
                  // button that would fail at checkout.
                  child: _isIntake
                      // A recruiting course: one button, and no price anywhere
                      // near it. Once they are on the list it becomes a plain
                      // statement — there is no way off it from here, by
                      // design. A parent who changed their mind says so when
                      // the centre rings, which it will.
                      ? (_waitlistEntryId != null
                          ? _ComingSoonButton(c: c, label: 'intake_joined'.tr())
                          : GradientButton(
                              text: 'intake_join_cta'.tr(),
                              onPressed: _onJoinWaitlistTapped,
                            ))
                      : !_isBookable
                          ? _ComingSoonButton(c: c)
                          : GradientButton(
                              text: 'buy_tickets'.tr(),
                              onPressed: _openBooking,
                            ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Hero image carousel ────────────────────────────────────────────────────
  Widget _hero(AppColorScheme c, double safeTop) {
    return StretchyHero(
      controller: _scrollController,
      height: _kHeroHeight.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_galleryImages.isNotEmpty)
            PageView.builder(
              controller: _pageController,
              itemCount: _galleryImages.length,
              onPageChanged: (i) => _currentImageIndex.value = i,
              itemBuilder: (_, i) => CachedNetworkImage(
                imageUrl: _galleryImages[i],
                fit: BoxFit.cover,
                placeholder: (_, __) => _imgShimmer(c),
                // A URL that will not load is not "still loading" — shimmering
                // at it forever both lies and costs a frame every vsync.
                errorWidget: (_, __, ___) => _heroBlank(c),
              ),
            )
          // Shimmer ONLY while `/classes/:id` is still in flight. A class the
          // centre never gave an image to has nothing left to wait for, and a
          // shimmer there never stops: it drives an animation frame every
          // vsync for as long as the page is open, and every one of those
          // frames re-rasters the blurred top scrim over it. That is what made
          // this screen stutter with nothing happening on it.
          else if (_full == null)
            _imgShimmer(c)
          else
            _heroBlank(c),
          // Top scrim — a soft dark fade so the light controls stay legible
          // over bright / near-white hero images.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: safeTop + 72.h,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.28),
                      Colors.black.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Dots indicator — frosted light pill over the hero (Figma 60:5620).
          if (_galleryImages.length > 1)
            Positioned(
              bottom: 12.h,
              left: 0,
              right: 0,
              child: Center(
                child: ValueListenableBuilder<int>(
                  valueListenable: _currentImageIndex,
                  builder: (_, currentImageIndex, __) => FrostedCard(
                    hasBorder: false,
                    boxShadow: AppShadows.control,
                    borderRadius: BorderRadius.circular(32.r),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(_galleryImages.length, (i) {
                        final active = i == currentImageIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: EdgeInsets.symmetric(horizontal: 3.w),
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: active ? c.textPrimary : c.textSecondary,
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Still, silent stand-in for a hero image that is never coming — see the
  /// shimmer's call site in [_hero].
  Widget _heroBlank(AppColorScheme c) => ColoredBox(color: c.control);

  Widget _imgShimmer(AppColorScheme c) => Shimmer.fromColors(
        baseColor: c.surface,
        highlightColor: c.isDark ? const Color(0xFF2E2E35) : Colors.white,
        child: Container(color: c.surface),
      );

  // ─── Main info card ────────────────────────────────────────────────────────
  Widget _mainCard(AppColorScheme c, String title, String branchTitle) {
    return DetailCard(
      c: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.heading20.copyWith(color: c.textPrimary)),
          // What other parents think, stated where a listing states it — right
          // under the name. Rating it yourself happens in the reviews card.
          if (_rating.hasRatings) ...[
            6.verticalSpace,
            RatingInline(
              rating: _rating,
              onTap: _reviews.reviews.isEmpty || widget.classModel.id == null
                  ? null
                  : () => ReviewsSheet.show(
                        context,
                        activityId: widget.classModel.id!,
                      ),
            ),
          ],
          // Says why there are no dates and no buy button, at the top of the
          // page rather than only down at the CTA.
          if (_isIntake) ...[
            6.verticalSpace,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.brandPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(40.r),
              ),
              child: Text(
                'intake_badge'.tr(),
                style: AppText.semibold12
                    .copyWith(color: AppColors.brandPurple),
              ),
            ),
          ],
          // No description here. It used to be repeated in this card as two
          // ellipsised lines and again in full in the card below; it is now
          // stated once, in [_descriptionCard], as a dropdown.
          20.verticalSpace,
          // Location row.
          if (branchTitle.isNotEmpty)
            Container(
              padding: EdgeInsets.fromLTRB(8.w, 8.h, 16.w, 8.h),
              decoration: BoxDecoration(
                color: c.control,
                borderRadius: BorderRadius.circular(40.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: c.surface,
                      shape: BoxShape.circle,
                    ),
                    child: HomeIcon(Assets.icons.detail.icLocation,
                        size: 16, color: c.textPrimary),
                  ),
                  8.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // How far away it is — and nothing else. The grey
                        // "Location" label that used to head this line told a
                        // parent what the pin icon and the centre's name
                        // underneath already say; the distance is the one fact
                        // here they can't get anywhere else on the card.
                        //
                        // Measured off [_venueLat]/[_venueLng], so it works
                        // from the list payload's flat coordinates before
                        // `/classes/:id` has landed and from the detail's
                        // nested ones after. No distance is no line at all —
                        // the name then sits alone, rather than under a gap.
                        ValueListenableBuilder<UserLocation?>(
                          valueListenable: currentUserLocation,
                          builder: (context, _, __) {
                            if (DistanceLabel.labelFor(_venueLat, _venueLng) ==
                                null) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: EdgeInsets.only(bottom: 4.h),
                              child: DistanceLabel(
                                latitude: _venueLat,
                                longitude: _venueLng,
                              ),
                            );
                          },
                        ),
                        Text(
                          branchTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              AppText.semibold14.copyWith(color: c.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  // "View all" chip first, route icon on the outside edge.
                  if (widget.classModel.branch != null)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => context.router.push(
                        BranchDetailRoute(branch: widget.classModel.branch!),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: detailChipFill(c),
                          borderRadius: BorderRadius.circular(40.r),
                        ),
                        // This chip opens the CENTRE, not a longer list —
                        // "View all" promised more of the same thing and
                        // delivered somewhere else. Its own key, so the generic
                        // "View all" on home and the schedule stays put.
                        child: Text('see_centre'.tr(),
                            style: AppText.regular12
                                .copyWith(color: c.textPrimary)),
                      ),
                    ),
                  if (_venueLat != null && _venueLng != null) ...[
                    8.horizontalSpace,
                    RouteIconButton(
                      lat: _venueLat!,
                      lng: _venueLng!,
                      title: branchTitle,
                      subtitle: _venueAddress,
                      onOpen: () => _reportTap(ListingAction.routeClick),
                    ),
                  ],
                ],
              ),
            ),
          12.verticalSpace,
          // Info tiles.
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  c: c,
                  icon: Assets.icons.detail.iconsaxTicketDiscount,
                  value: _formatDuration(_effectiveDuration(_full)),
                  label: 'detail_duration'.tr(),
                ),
              ),
              4.horizontalSpace,
              Expanded(
                child: _InfoTile(
                  c: c,
                  icon: Assets.icons.detail.iconsaxBaby,
                  value: _ageLabel(),
                  label: 'detail_age'.tr(),
                ),
              ),
              4.horizontalSpace,
              Expanded(
                child: _InfoTile(
                  c: c,
                  icon: Assets.icons.detail.iconsaxAiUsers,
                  value: _getGenderText(),
                  label: 'detail_gender'.tr(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Course price card ──────────────────────────────────────────────────────
  /// A course's price, standing in for the per-group panels that used to carry
  /// it. One figure and nothing else: the page does not sell a course, so this
  /// is here to be read, not acted on.
  Widget _coursePriceCard(AppColorScheme c, _CoursePrice price) {
    return DetailCard(
      c: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailCardHeader(
            c: c,
            icon: Assets.icons.home.money,
            iconGradient: const LinearGradient(
              colors: [AppColors.brandPink, AppColors.brandPink],
            ),
            title: 'course_full_title'.tr(),
          ),
          14.verticalSpace,
          Text(
            price.isFrom
                ? 'price_from'.tr(args: [price.amount.toRawUzsPrice()])
                : price.amount.toRawUzsPrice(),
            style: AppText.bold18.copyWith(color: AppColors.brandPurple),
          ),
        ],
      ),
    );
  }

  // ─── Prices card ────────────────────────────────────────────────────────────
  Widget _pricesCard(AppColorScheme c, List<_PriceRowData> rows) {
    // The tickets in Lumi Coin, instead of the so'm price. Only while packs
    // are on sale (or this user still holds coins), only when the server sent
    // coin prices for this activity, and never on a course — a course is
    // money-only.
    final showCoins = watchNewCoins(context).isVisible &&
        !_isCourse &&
        (_full?.hasNewCoinPrices ?? false);
    return DetailCard(
      c: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailCardHeader(
            c: c,
            icon: Assets.icons.home.money,
            iconGradient: const LinearGradient(
              colors: [AppColors.brandPink, AppColors.brandPink],
            ),
            title: 'detail_prices'.tr(),
          ),
          // One badge for the card, not one per row: the rate is the same
          // whichever age tier is bought, and repeating it down the list would
          // read as a per-row offer.
          //
          // Cashback is hidden from the activity flow (product decision), and
          // this card renders for activities only — so the chip is gated to
          // courses, which today means it is never shown here. The fetch and
          // the widget stay, so bringing it back is deleting this condition.
          if (_isCourse && _cashback.hasRate) ...[
            12.verticalSpace,
            Align(
              alignment: Alignment.centerLeft,
              child: CashbackChip(preview: _cashback),
            ),
          ],
          // The centre's own sale, above the prices it applies to. The rows
          // below stay at the list price: which lessons are cheaper depends on
          // the day and the hour, and that is priced where they are picked —
          // on the booking sheet.
          if (_full?.sale != null) ...[
            12.verticalSpace,
            SaleNotice(sale: _full!.sale!),
          ],
          16.verticalSpace,
          ...List.generate(rows.length, (i) {
            final r = rows[i];
            return Padding(
              padding: EdgeInsets.only(bottom: i == rows.length - 1 ? 0 : 8.h),
              child: _PriceRow(
                c: c,
                row: r,
                couponPct: _couponPct,
                promoPass: _promoPassFor(isWholeCourse: _isCourse),
                showNewCoinPrice: showCoins,
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── Description card ───────────────────────────────────────────────────────
  Widget _descriptionCard(AppColorScheme c, String title, String description) {
    return DetailCard(
      c: c,
      child: ExpandableDescription(
        title: title,
        text: description,
      ),
    );
  }

  // ─── Location card ──────────────────────────────────────────────────────────
  /// The venue on a map, plotted from whichever pair of coordinates has
  /// arrived — the list payload's flat ones, then the ones `/classes/:id`
  /// nests under `branch_id`. The address line under it is the one the route
  /// sheet would open, spelled out for a parent reading rather than tapping.
  Widget _locationCard(AppColorScheme c, String branchTitle) {
    final address = _venueAddress;
    final venue = _venue;
    final hasVideo = _hasVenueVideo;
    final phones = _venuePhones;

    return DetailCard(
      c: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailCardHeader(
            c: c,
            icon: Assets.icons.detail.icLocation,
            iconGradient: AppGradients.brand,
            title: 'detail_location'.tr(),
          ),
          // The map, and beside it the centre's arrival clip — the map gets a
          // parent to the building, the clip gets them in (which door off the
          // courtyard, which floor). Both in the same glance, because someone
          // standing outside needs the second one and will not scroll for it.
          if (venue != null || hasVideo) ...[
            12.verticalSpace,
            SizedBox(
              height: _kVenueStripHeight.h,
              child: Row(
                children: [
                  if (venue != null)
                    Expanded(
                      child: LocationPreviewMap(
                        lat: venue.$1,
                        lng: venue.$2,
                        title: branchTitle,
                        subtitle: address,
                        height: _kVenueStripHeight.h,
                        onOpen: () => _reportTap(ListingAction.routeClick),
                      ),
                    ),
                  if (venue != null && hasVideo) 8.horizontalSpace,
                  if (hasVideo)
                    // Expanded when it stands alone: with no map beside it, a
                    // 104px tile in an empty row reads as a broken image.
                    // (A tight width from Expanded overrides the tile's own
                    // default; an infinite one inside a Row would assert.)
                    if (venue == null)
                      Expanded(
                        child: RouteVideoTile(
                          url: _venueVideoUrl,
                          height: _kVenueStripHeight.h,
                        ),
                      )
                    else
                      RouteVideoTile(
                        url: _venueVideoUrl,
                        height: _kVenueStripHeight.h,
                      ),
                ],
              ),
            ),
          ],
          if (address != null && address.trim().isNotEmpty) ...[
            10.verticalSpace,
            Text(
              address.trim(),
              style: AppText.regular13.copyWith(color: c.textSecondary),
            ),
          ],
          // The centre's own lines, under the address they belong to — only
          // once this parent has bought; see [_venuePhones].
          if (phones.isNotEmpty) ...[
            14.verticalSpace,
            Text(
              'detail_venue_contact'.tr(),
              style: AppText.medium13.copyWith(color: c.textSecondary),
            ),
            8.verticalSpace,
            ...List.generate(phones.length, (i) {
              return Padding(
                padding:
                    EdgeInsets.only(bottom: i == phones.length - 1 ? 0 : 8.h),
                child: _VenuePhoneRow(
                  c: c,
                  phone: phones[i],
                  onTap: () => _callVenue(phones[i]),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _detailSection(String key, Widget child) => Padding(
        key: ValueKey<String>(key),
        padding: EdgeInsets.only(top: 6.h),
        child: child,
      );

  // ─── Bulleted section card (important notes / what to bring) ────────────────
  Widget _bulletCard(
    AppColorScheme c, {
    required SvgGenImage icon,
    required Gradient iconGradient,
    required String title,
    required List<String> items,
  }) {
    return DetailCard(
      c: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailCardHeader(
            c: c,
            icon: icon,
            iconGradient: iconGradient,
            title: title,
          ),
          16.verticalSpace,
          ...List.generate(items.length, (i) {
            return Padding(
              padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : 8.h),
              child: _BulletRow(c: c, text: items[i]),
            );
          }),
        ],
      ),
    );
  }

  // ─── Language card ──────────────────────────────────────────────────────────
  // ─── Reviews card ───────────────────────────────────────────────────────────
  /// Laid out like a store listing's "Ratings & Reviews": the score, a strip
  /// of review cards to swipe through, then the stars to tap.
  Widget _reviewsCard(AppColorScheme c) {
    final id = widget.classModel.id;
    final openAll = id == null || _reviews.reviews.isEmpty
        ? null
        : () => ReviewsSheet.show(context, activityId: id);
    return DetailCard(
      c: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The header is the way to every review — a chevron, not a button
          // under the list.
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: openAll,
            child: Row(
              children: [
                Expanded(
                  child: DetailCardHeader(
                    c: c,
                    icon: Assets.icons.detail.heart,
                    iconGradient: AppGradients.brand,
                    title: 'reviews_title'.tr(),
                  ),
                ),
                if (openAll != null)
                  Icon(Icons.chevron_right_rounded,
                      size: 24.sp, color: c.textSecondary),
              ],
            ),
          ),
          // The score: the number on the left, the stars and how many rated
          // on the right.
          if (_rating.hasRatings) ...[
            8.verticalSpace,
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _rating.average.toStringAsFixed(1),
                  style: AppText.heading20.copyWith(
                    color: c.textPrimary,
                    fontSize: 44.sp,
                    height: 1.1,
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RatingStars(filled: _rating.average.round(), size: 16),
                    4.verticalSpace,
                    Text(
                      'rating_count'.tr(args: ['${_rating.count}']),
                      style:
                          AppText.regular13.copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ],
          if (_reviews.reviews.isNotEmpty) ...[
            12.verticalSpace,
            SizedBox(
              height: ReviewCard.height,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                // Bleeds to the card's edges, so the next review peeks in and
                // the strip reads as something to swipe.
                clipBehavior: Clip.none,
                itemCount: _reviews.reviews.length,
                separatorBuilder: (_, __) => 8.horizontalSpace,
                itemBuilder: (_, index) => ReviewCard(
                  review: _reviews.reviews[index],
                  onTap: openAll,
                ),
              ),
            ),
          ] else if (!_canRate) ...[
            12.verticalSpace,
            Text(
              'reviews_empty'.tr(),
              style: AppText.regular13.copyWith(color: c.textSecondary),
            ),
          ],
          // For someone who bought it: the stars themselves, to tap.
          if (_canRate) ...[
            16.verticalSpace,
            Center(child: RatePrompt(rating: _rating, onRate: _openRating)),
          ],
        ],
      ),
    );
  }

  Widget _languageCard(AppColorScheme c, List<String> languages) {
    return DetailCard(
      c: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailCardHeader(
            c: c,
            icon: Assets.icons.detail.iconsaxLanguageCircle,
            iconGradient: AppGradients.indigo,
            title: 'detail_language'.tr(),
          ),
          16.verticalSpace,
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children:
                languages.map((lang) => _LangChip(c: c, lang: lang)).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Reusable pieces ──────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.c,
    required this.icon,
    required this.value,
    required this.label,
  });
  final AppColorScheme c;
  final SvgGenImage icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: c.control,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Multicolour detail glyphs — render their own colours (no tint).
          HomeIcon(icon, size: 24),
          4.verticalSpace,
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppText.semibold16.copyWith(color: c.textPrimary),
          ),
          4.verticalSpace,
          Text(label, style: AppText.regular12.copyWith(color: c.textPrimary)),
        ],
      ),
    );
  }
}

/// One line of the prices card: an age bracket at one of its durations.
/// A course's headline price, and whether more than one price sits behind it.
///
/// [isFrom] is NOT cosmetic: with the per-group panels gone the reader cannot
/// see that a cheaper or dearer group exists, so a varying price has to say so
/// in the one figure that is left.
typedef _CoursePrice = ({num amount, bool isFrom});

typedef _PriceRowData = ({
  String range,
  String subtitle,

  /// e.g. "1 soat" — only age-tier pricing carries a duration; the flat
  /// price-summary fallback has none.
  String? duration,
  num price,

  /// The same ticket in Lumi Coin, or null when the server gave no way to
  /// quote one.
  int? newCoinPrice,
  SvgGenImage icon,
});

class _PriceRow extends StatelessWidget {
  const _PriceRow(
      {required this.c,
      required this.row,
      required this.couponPct,
      this.promoPass,
      this.showNewCoinPrice = false});
  final AppColorScheme c;
  final _PriceRowData row;
  final num couponPct;

  /// Non-null while a packet pays for this activity — the price is then
  /// replaced by the included badge rather than quoted or discounted.
  final PromoPassCoverage? promoPass;

  /// Whether to quote [_PriceRowData.newCoinPrice] in place of the so'm price.
  final bool showNewCoinPrice;

  /// The packet is paying for this row — see [_priceText].
  bool get _coveredByPass {
    final pass = promoPass;
    final ceiling = pass?.maxActivityPrice;
    return pass != null &&
        row.price > 0 &&
        (ceiling == null || row.price <= ceiling);
  }

  @override
  Widget build(BuildContext context) {
    final coins = row.newCoinPrice;
    return Container(
      padding: EdgeInsets.fromLTRB(8.w, 8.h, 16.w, 8.h),
      decoration: BoxDecoration(
        color: c.control,
        borderRadius: BorderRadius.circular(40.r),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: c.surface, shape: BoxShape.circle),
            child: HomeIcon(row.icon, size: 20, color: c.textPrimary),
          ),
          8.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(row.range,
                    style: AppText.semibold14.copyWith(color: c.textPrimary)),
                4.verticalSpace,
                // Duration first: it is what separates two rows sharing an age
                // bracket, so it has to be the part the eye lands on. Same
                // "duration ·" lead-in the booking sheet's rows use.
                Text(
                  row.duration == null
                      ? row.subtitle
                      : '${row.duration} · ${row.subtitle}',
                  style: AppText.regular12.copyWith(color: c.textPrimary),
                ),
              ],
            ),
          ),
          // A visit the packet already covers has no second price to offer.
          if (showNewCoinPrice && coins != null && coins > 0 && !_coveredByPass)
            // In place of the so'm price, not under it: an activity is paid in
            // coins, so that is the only figure the row owes the buyer.
            CoinAmount(
              amount: coins,
              style: AppText.semibold14,
              color: c.textPrimary,
            )
          else
            _priceText(),
        ],
      ),
    );
  }

  /// The price, as plain text.
  ///
  /// Deliberately NOT a filled chip. The white pill it used to sit in was a
  /// second surface stacked on the row's own fill — on a light theme, white on
  /// grey inside a white card — which framed the price as a separate object
  /// rather than the end of the line it belongs to. Nothing needs a container
  /// to be findable at the right edge of its own row.
  Widget _priceText() {
    // Outranks the coupon: there is nothing left to discount once the visit is
    // paid for.
    //
    // `_promoPassFor` already settled everything that is true of the ACTIVITY —
    // scope, distinctness, courses. The per-visit ceiling is the one rule that
    // belongs to a single booking, and a class lists several tiers at once, so
    // it is applied here against this row's own figure.
    final pass = promoPass;
    final ceiling = pass?.maxActivityPrice;
    if (pass != null &&
        row.price > 0 &&
        (ceiling == null || row.price <= ceiling)) {
      return PromoIncludedLabel(pass: pass, compact: false);
    }
    if (couponPct <= 0 || row.price <= 0) {
      return Text(
        row.price <= 0 ? 'price_free'.tr() : row.price.toRawUzsPrice(),
        style: AppText.semibold14.copyWith(color: c.textPrimary),
      );
    }
    final discounted = (row.price * (100 - couponPct) / 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          row.price.toRawUzsPrice(),
          style: AppText.regular12.copyWith(
            color: c.textMuted,
            decoration: TextDecoration.lineThrough,
            decorationColor: c.textMuted,
          ),
        ),
        Text(discounted.toRawUzsPrice(),
            style: AppText.semibold14.copyWith(color: AppColors.green)),
      ],
    );
  }
}

/// One line of an important-notes / what-to-bring list.
/// One of the centre's own phone numbers, as a tappable row.
///
/// The number is drawn exactly as the console stored it, punctuation included:
/// that is the form a parent recognises and can read back aloud. Only the
/// `tel:` handoff strips it.
class _VenuePhoneRow extends StatelessWidget {
  const _VenuePhoneRow({
    required this.c,
    required this.phone,
    required this.onTap,
  });

  final AppColorScheme c;
  final String phone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: c.control,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(Icons.call_rounded, size: 18.w, color: AppColors.brandPurple),
            10.horizontalSpace,
            Expanded(
              child: Text(
                phone,
                style: AppText.medium14.copyWith(color: c.textPrimary),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20.w,
              color: c.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  const _BulletRow({required this.c, required this.text});
  final AppColorScheme c;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: c.control,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                color: c.textSecondary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          10.horizontalSpace,
          Expanded(
            child: Text(
              text,
              style: AppText.regular14.copyWith(color: c.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip({required this.c, required this.lang});
  final AppColorScheme c;
  final String lang;

  String get _flag {
    final l = lang.toLowerCase();
    if (l.contains('eng') || l.contains('англ')) return '🇬🇧';
    if (l.contains('rus') || l.contains('рус')) return '🇷🇺';
    if (l.contains('uz') ||
        l.contains('ўз') ||
        l.contains('o‘z') ||
        l.contains("o'z")) {
      return '🇺🇿';
    }
    return '🌐';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 4.h, 12.w, 4.h),
      decoration: BoxDecoration(
        color: detailChipFill(c),
        borderRadius: BorderRadius.circular(40.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            alignment: Alignment.center,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Text(_flag, style: TextStyle(fontSize: 16.sp)),
          ),
          6.horizontalSpace,
          Text(lang, style: AppText.medium16.copyWith(color: c.textPrimary)),
        ],
      ),
    );
  }
}

// ─── Duration helper ──────────────────────────────────────────────────────────

class _Duration {
  const _Duration._(this.minutes, this.unbounded);
  factory _Duration.finite(int minutes) => _Duration._(minutes, false);
  factory _Duration.unbounded(int? minutes) => _Duration._(minutes, true);
  final int? minutes;
  final bool unbounded;
}

/// Inert CTA shown in place of "Buy tickets" when a class is hidden from the
/// catalogue. Deliberately not a disabled [GradientButton]: a greyed-out
/// gradient reads as "temporarily broken", where this reads as "not yet".
class _ComingSoonButton extends StatelessWidget {
  const _ComingSoonButton({required this.c, this.label});

  final AppColorScheme c;

  /// Overrides the default "booking opens soon" wording. Used by the intake
  /// CTA, which is the same inert shape saying something different.
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // Horizontal room too: this label is a sentence, not a word, and has to
      // wrap rather than touch the border on a narrow phone.
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.control,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: c.controlBorder),
      ),
      child: Text(
        // Says what is unavailable, not just "soon" — the buyer is standing on
        // a class page with a price on it and needs to know booking is what's
        // off, and that it's temporary.
        label ?? 'booking_available_soon'.tr(),
        textAlign: TextAlign.center,
        style: AppText.semibold16.copyWith(color: c.textSecondary),
      ),
    );
  }
}
