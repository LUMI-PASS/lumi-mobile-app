import 'dart:async';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:lumi_pass/common/utils/coupon_discount.dart';
import 'package:lumi_pass/common/utils/course_period.dart';
import 'package:lumi_pass/common/widget/auth/gradient_button.dart';
import 'package:lumi_pass/common/widget/cashback_badge.dart';
import 'package:lumi_pass/common/widget/detail/detail_card.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';
import 'package:lumi_pass/common/widget/map_route_sheet.dart';
import 'package:lumi_pass/common/widget/stretchy_hero.dart';
import 'package:lumi_pass/data/api_model/class_full/class_full_model.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/api_model/wallet/cashback_preview.dart';
import 'package:lumi_pass/data/service/analytics_service.dart';
import 'package:lumi_pass/data/service/interest_reporter.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/courses/courses_api.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:lumi_pass/domain/repo/wallet/wallet_repository.dart';
import 'package:lumi_pass/presentation/app/cubit/app_cubit.dart';
import 'package:lumi_pass/presentation/app/cubit/app_state.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_icons.dart';
import 'package:share_plus/share_plus.dart';
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

class _ClassDetailPageState extends State<ClassDetailPage> {
  bool _isFavorite = false;
  List<String> _galleryImages = [];
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  int _currentImageIndex = 0;
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

  /// The trial lesson picked in the list above, on a course sold flat. Drives
  /// the sticky bottom CTA: nothing picked, nothing to book. Reset whenever the
  /// course reloads, since a purchase moves the ladder on.
  CourseLesson? _pickedTrial;

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

  /// The age brackets being enrolled, on a group priced by age.
  ///
  /// MULTI select — one bracket per child, so a parent signing up a 4-year-old
  /// and a 7-year-old picks both and pays the sum. Keyed by bracket rather than
  /// by index so a reload that reorders the tiers can't silently move the pick
  /// onto a different price. Never empty once tiers exist: the last one cannot
  /// be unticked, because a course bought for nobody has no price.
  Set<String> _selectedTierKeys = <String>{};

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

  /// The age brackets the picked group is sold at. Empty on a group with one
  /// price — there is then nothing to choose and no picker to show.
  List<CourseAgeTier> get _groupAgeTiers =>
      _selectedLevel?.ageTiers ?? const <CourseAgeTier>[];

  /// Identity of a bracket, for [_selectedTierKeys]. An open-ended tier has no
  /// upper bound, so its key ends empty rather than in a made-up age.
  static String _tierKey(CourseAgeTier t) => '${t.ageFrom}-${t.ageTo ?? ''}';

  /// The ticked brackets, in the order the server sent them.
  List<CourseAgeTier> get _selectedAgeTiers => _groupAgeTiers
      .where((t) => _selectedTierKeys.contains(_tierKey(t)))
      .toList();

  /// What the picked group costs as configured: the ticked brackets summed —
  /// one place per bracket — or the group's own single price when it isn't
  /// sold by age.
  num get _courseTotal {
    final picked = _selectedAgeTiers;
    if (picked.isEmpty) return _selectedLevel?.coursePrice ?? 0;
    return picked.fold<num>(0, (sum, t) => sum + t.price);
  }

  /// Tick the first bracket of [level], dropping any pick belonging to the
  /// group before it. A course priced by age has no meaningful "nothing
  /// picked" state — the price on screen has to be a price of something — so
  /// the cheapest bracket stands in until the parent says otherwise.
  void _seedAgeTiers(CourseLevel? level) {
    final tiers = level?.ageTiers ?? const <CourseAgeTier>[];
    _selectedTierKeys = tiers.isEmpty ? <String>{} : {_tierKey(tiers.first)};
  }

  /// A course is sold as a package, not per session. Known from the list model
  /// before the detail lands, so the CTA never flashes the ticket wording.
  bool get _isCourse => _full?.isCourse ?? widget.classModel.isCourse ?? false;

  /// 0 → hero fully visible, 1 → content scrolled under the top controls and
  /// the frosted scrim is fully on.
  double _topScrim = 0;

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
    return _full?.isBookable ?? true;
  }

  // ─── Venue coordinates ────────────────────────────────────────────────────
  /// Where the class actually takes place, for the route sheet. The list model
  /// carries flat `latitude`/`longitude`; the detail's `branch_id` nests them
  /// under `location` — prefer whichever has arrived, list model first so the
  /// button is live before `/classes/:id` lands.
  double? get _venueLat =>
      widget.classModel.branch?.latitude ?? _full?.branch?.lat;

  double? get _venueLng =>
      widget.classModel.branch?.longitude ?? _full?.branch?.lng;

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

  // ─── Coupon discount helpers ──────────────────────────────────────────────
  /// The coupon's percentage on THIS class — the plan's percentage capped at
  /// Lumi's share of the class, which is what checkout will actually charge.
  ///
  /// Reads the plan's percentage from `AppCubit`'s Cubit state (watched, not
  /// a one-off `Storage` read) so this rebuilds the instant a purchase
  /// completes or a subscription is synced, instead of showing whatever was
  /// true the last time this page happened to build.
  num get _couponPct {
    final app =
        context.watch<AppCubit>().state.buildable ?? const AppBuildable();
    final plan = app.hasPremium ? app.planDiscountPercentage : 0;
    return effectiveCouponPercent(
      plan,
      _full?.discountPercentage ?? widget.classModel.discountPercentage,
      isCourse: _isCourse,
    );
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
    super.dispose();
  }

  /// Fade the top scrim in over the second half of the hero, so it is fully on
  /// by the time the first card slides under the back/share/heart controls.
  void _onScroll() {
    final start = _kHeroHeight.h * 0.45;
    final end = _kHeroHeight.h * 0.85;
    final t =
        ((_scrollController.offset - start) / (end - start)).clamp(0.0, 1.0);
    if ((t - _topScrim).abs() > 0.01 || t == 0 || t == 1) {
      if (t != _topScrim) setState(() => _topScrim = t);
    }
  }

  void _startAutoSlide() {
    _slideTimer?.cancel();
    _slideTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || _galleryImages.length <= 1) return;
      final next = (_currentImageIndex + 1) % _galleryImages.length;
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
    try {
      final full = await getIt<OrdersApi>().getClassFull(id);
      if (!mounted) return;
      setState(() {
        _full = full;
        _galleryImages = _resolveGallery(full);
      });
      if (full.isCourse) unawaited(_loadCourse(id));
    } catch (_) {
      // Keep whatever gallery/list image we already have.
    }
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
        // A reload usually follows a purchase, which moves the ladder on — the
        // old pick may now be bought or gone, so the CTA disarms rather than
        // pointing at a lesson that is no longer for sale. Same for the picked
        // subcourse: it may have just been enrolled in, or sold out.
        _pickedTrial = null;
        // Re-seeded rather than cleared: the page always names a group. The
        // server's default is the cheapest one with seats left, which is the
        // same group it would have charged for had nothing been picked.
        final groups = detail.hasLevels ? detail.levels : [detail.flat];
        final fallback = groups.isEmpty ? null : groups.first;
        _selectedLevelId = detail.defaultLevelId ?? fallback?.id;
        _seedAgeTiers(
          groups.where((l) => l.id == _selectedLevelId).firstOrNull ?? fallback,
        );
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

  void _openBooking() {
    final full = _full;
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
    context.router.push(BookingRoute(clazz: full));
  }

  /// What the sticky bottom CTA buys.
  ///
  /// On a course sold as subcourses that is whichever one the parent picked —
  /// the CTA is inert until then, so this is only null if the pick went stale
  /// under a reload, in which case the server's default (cheapest with seats)
  /// stands in rather than the tap doing nothing. A flat course has no choice
  /// to make and simply sells itself.
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

  /// Sticky bottom CTA — the one place a course is bought from this page.
  Future<void> _onBuyCourseTapped() async {
    final level = _defaultBuyLevel();
    if (level == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('cta_loading'.tr())),
      );
      return;
    }
    await _openCourseBooking(level);
  }

  /// Whether the sticky CTA should also sell a TRIAL lesson.
  ///
  /// True only for a ONE-group course that still has a rung left on its trial
  /// ladder. With several groups the trial is bought from the panel that names
  /// the group — a page-level trial button could not say which one it meant —
  /// and once the ladder is used up the whole course is the only thing left to
  /// sell, the same order the card pricing follows.
  bool get _sellsTrialLessons {
    if (!_isCourse || _courseGroups.length != 1) return false;
    final level = _courseGroups.first;
    return level.canBuyTrial &&
        level.trialLessons.any((lesson) => lesson.isAvailable);
  }

  /// Book the picked trial lesson of the one group this course runs as. The
  /// sticky CTA's half of [_openTrialBooking] — a multi-group course buys its
  /// trial from the panel that names the group instead.
  Future<void> _onBookTrialTapped() async {
    final level = _selectedLevel;
    if (level == null || _pickedTrial == null) return;
    await _openTrialBooking(level);
  }

  /// Buy ONE trial lesson of [level]: opens the same review-and-pay screen the
  /// whole course uses, so a trial is paid for exactly like anything else —
  /// with the calendar, the promocode field and the payment-method picker.
  ///
  /// Every trial purchase on this page goes through here, whichever group it
  /// belongs to. Going straight to checkout instead — as the group panels used
  /// to — skipped the promocode field, so a code that was valid on the course
  /// could not be spent on its trial.
  Future<void> _openTrialBooking(CourseLevel level) async {
    final id = _full?.id ?? widget.classModel.id;
    if (id == null) return;
    if (!level.canBuyTrial) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(level.trialBlockedReason == null
              ? 'course_blocked_unavailable'.tr()
              : _blockedMessage(level, level.trialBlockedReason!)),
        ),
      );
      return;
    }

    getIt<AnalyticsService>().logEvent(
      AnalyticsEvent.bookButtonTapped,
      params: {
        'class_id': id,
        if (widget.classModel.title != null)
          'class_title': widget.classModel.title!,
        'is_course': 'true',
        'course_option': 'trial',
      },
    );
    getIt<InterestReporter>().bookTapped(id);
    final full = _full;
    if (full == null) return;
    // The SAME booking page a class ticket goes through — calendar on top, the
    // course's own upcoming days in it, then slots, promocode, payment. A trial
    // is a session like any other; the only thing that differs is which
    // endpoint takes the money.
    final purchased = await context.router.push(
      BookingRoute(
        clazz: full,
        level: level,
        courseOption: CoursePurchaseOption.trial,
      ),
    );
    if (purchased == true && mounted) await _loadCourse(id);
  }

  /// Buy the whole course / a subcourse. A trial lesson goes through
  /// [_onBookTrialTapped] (flat course) or [_buyCourse] (a level's own panel).
  Future<void> _openCourseBooking(CourseLevel level) async {
    final id = _full?.id ?? widget.classModel.id;
    if (id == null) return;
    if (!level.canBuyFull) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(level.blockedReason == null
              ? 'course_blocked_unavailable'.tr()
              : _blockedMessage(level, level.blockedReason!)),
        ),
      );
      return;
    }
    getIt<AnalyticsService>().logEvent(
      AnalyticsEvent.bookButtonTapped,
      params: {
        'class_id': id,
        if (widget.classModel.title != null)
          'class_title': widget.classModel.title!,
        'is_course': 'true',
      },
    );
    getIt<InterestReporter>().bookTapped(id);
    final full = _full;
    if (full == null) return;
    // Same page as a class ticket — see [_onBookTrialTapped].
    //
    // No explicit <bool> on the push: BookingRoute is generated as
    // PageRouteInfo<BookingRouteArgs> (no return-type param), so the router
    // always wraps it as AutoRoutePage<dynamic> — pushing with an explicit
    // <bool> makes the internal cast to AutoRoutePage<bool> throw.
    final purchased = await context.router.push(
      BookingRoute(
        clazz: full,
        level: level,
        courseOption: CoursePurchaseOption.full,
        // The brackets ticked on this page ARE the order: one place per child,
        // priced per bracket. Carried over so the sheet's total is the figure
        // the page just showed, rather than the group's single price.
        ageTiers: level.id == _selectedLevel?.id
            ? _selectedAgeTiers
            : const <CourseAgeTier>[],
      ),
    );
    if (purchased == true && mounted) await _loadCourse(id);
  }

  /// Price tiers derived for display: one row per age tier (min price), or the
  /// price-summary ranges as a fallback.
  List<({String range, String subtitle, num price, SvgGenImage icon})>
      _priceRows() {
    final full = _full;
    final rows =
        <({String range, String subtitle, num price, SvgGenImage icon})>[];
    if (full == null) return rows;
    if (full.ageTiers.isNotEmpty) {
      for (final t in full.ageTiers) {
        final prices =
            t.durations.map((d) => d.price).where((p) => p > 0).toList();
        final min = prices.isEmpty ? 0 : prices.reduce((a, b) => a < b ? a : b);
        final adults = t.ageFrom >= 6 || t.ageTo == null;
        rows.add((
          range: t.rangeLabel,
          subtitle: adults ? 'price_tier_all'.tr() : 'price_tier_children'.tr(),
          price: min,
          icon: adults
              ? Assets.icons.home.profile2user
              : Assets.icons.home.babyGirl,
        ));
      }
    } else {
      for (final r in full.pricesSummary) {
        rows.add((
          range: r.rangeLabel,
          subtitle: 'price_tier_children'.tr(),
          price: r.price,
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
    final languages = full?.activityLanguages ?? const <String>[];
    // A course is bought from the ONE sticky CTA below, which sells whichever
    // group is picked — the panels are the choice, not the till. A group is
    // always picked (see [_selectedLevelId]), so the only thing the CTA still
    // waits on is the course detail itself arriving.
    final ctaEnabled = !_isCourse || _selectedLevel != null;
    final notes =
        full == null ? const <String>[] : _bullets(full.importantNotes);
    final requiredItems =
        full == null ? const <String>[] : _bullets(full.requiredItems);

    // Over the hero the status bar sits on a photo (light icons); once the
    // scrim takes over on a light background the icons have to flip to dark.
    final darkIcons = !c.isDark && _topScrim > 0.5;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: darkIcons ? Brightness.dark : Brightness.light,
        statusBarBrightness: darkIcons ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(child: _hero(c, safeTop)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 0),
                    child: Column(
                      children: [
                        _mainCard(c, title, description, branchTitle),
                        // Every course is shown as its groups — one card, one
                        // shape, whether the centre split it into several or
                        // entered it as a single group. Each panel carries the
                        // whole picture: which days it runs, what it costs,
                        // seats, and the dated trial lessons with their own
                        // prices. These are the facts a parent decides on, so
                        // they belong on the page rather than behind the buy
                        // button.
                        if (_courseGroups.isNotEmpty) ...[
                          6.verticalSpace,
                          _courseLevelsCard(c, _courseGroups),
                        ],
                        // Directly under the groups, because it prices the one
                        // that is picked — a group priced by a single figure
                        // has no brackets and shows nothing here.
                        if (_groupAgeTiers.isNotEmpty) ...[
                          6.verticalSpace,
                          _courseAgeTiersCard(c, _groupAgeTiers),
                        ],
                        // A course is priced per level/lesson, never by age
                        // tier — the underlying activity still carries a
                        // placeholder price-summary row, which would render a
                        // meaningless "0–99 years: free" card here.
                        if (!_isCourse && priceRows.isNotEmpty) ...[
                          6.verticalSpace,
                          _pricesCard(c, priceRows),
                        ],
                        if (description.isNotEmpty) ...[
                          6.verticalSpace,
                          _descriptionCard(c, title, description),
                        ],
                        if (notes.isNotEmpty) ...[
                          6.verticalSpace,
                          _bulletCard(
                            c,
                            icon: Assets.icons.detail.iconsaxQuestionMark,
                            iconGradient: AppGradients.brand,
                            title: 'detail_notes'.tr(),
                            items: notes,
                          ),
                        ],
                        if (requiredItems.isNotEmpty) ...[
                          6.verticalSpace,
                          _bulletCard(
                            c,
                            icon: Assets.icons.detail.iconsaxReceipt,
                            iconGradient: AppGradients.green,
                            title: 'detail_bring'.tr(),
                            items: requiredItems,
                          ),
                        ],
                        if (languages.isNotEmpty) ...[
                          6.verticalSpace,
                          _languageCard(c, languages),
                        ],
                      ],
                    ),
                  ),
                ),
                // Runway under the last card so the sticky CTA never covers it.
                // Every variant of this page now carries that bar, including a
                // course sold as subcourses, so the tall spacing is unconditional
                // — taller still while the trial variant stacks a second button
                // under the first.
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: (_sellsTrialLessons ? 146.h : 90.h) + safeBottom,
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
                child: Opacity(
                  opacity: _topScrim,
                  child: DetailTopScrim(
                    color: c.scaffoldBg,
                    height: safeTop + 56.h,
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
                  DetailControlButton(
                    child: HomeIcon(Assets.icons.home.heart,
                        size: 16,
                        color: _isFavorite ? AppColors.error : c.textSecondary),
                    onTap: () => setState(() => _isFavorite = !_isFavorite),
                  ),
                ],
              ),
            ),
            // Bottom CTA — the single place anything on this page is bought,
            // for a plain class, a flat course and a subcourse alike.
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
                // An inactive class — hidden by the centre, or not approved by
                // moderation — can still be reached by direct link, from an
                // existing booking, or from a feed page that loaded before it
                // was taken down, so the page opens but must not be bookable.
                // Inert "booking available soon" rather than a Book button
                // that would fail at checkout.
                // A course is bought as a package (trial lessons or the whole
                // course), never as a dated ticket — so it gets its own
                // wording and buys the default level directly instead of
                // opening the per-session booking flow.
                child: !_isBookable
                    ? _ComingSoonButton(c: c)
                    : _sellsTrialLessons
                        // A course still offering trial lessons sells one of
                        // those first — that is what the list above is for.
                        // Inert until a lesson is picked, so the button can
                        // never book an unnamed one. The whole course stays
                        // one tap away underneath.
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GradientButton(
                                text: 'course_book_trial_cta'.tr(),
                                onPressed: _pickedTrial == null
                                    ? null
                                    : _onBookTrialTapped,
                              ),
                              8.verticalSpace,
                              // Green, not a faint text link. Where the trial
                              // is free the trial button is the cheap-looking
                              // option and this is the one that earns — a
                              // greyed-out link next to it reads as an
                              // afterthought rather than the real offer.
                              _GreenButton(
                                text: 'course_buy_full'.tr(),
                                onPressed: _onBuyCourseTapped,
                              ),
                            ],
                          )
                        : GradientButton(
                            // A group is always picked, so the only thing
                            // left to wait on is the course detail landing —
                            // and the button says so rather than offering to
                            // buy something it can't name yet.
                            text: !_isCourse
                                ? 'buy_tickets'.tr()
                                : ctaEnabled
                                    ? 'course_buy_cta'.tr()
                                    : 'cta_loading'.tr(),
                            enabled: ctaEnabled,
                            onPressed:
                                _isCourse ? _onBuyCourseTapped : _openBooking,
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
              onPageChanged: (i) => setState(() => _currentImageIndex = i),
              itemBuilder: (_, i) => CachedNetworkImage(
                imageUrl: _galleryImages[i],
                fit: BoxFit.cover,
                placeholder: (_, __) => _imgShimmer(c),
                errorWidget: (_, __, ___) => _imgShimmer(c),
              ),
            )
          else
            _imgShimmer(c),
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
                child: FrostedCard(
                  hasBorder: false,
                  boxShadow: AppShadows.control,
                  borderRadius: BorderRadius.circular(32.r),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(_galleryImages.length, (i) {
                      final active = i == _currentImageIndex;
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
        ],
      ),
    );
  }

  Widget _imgShimmer(AppColorScheme c) => Shimmer.fromColors(
        baseColor: c.surface,
        highlightColor: c.isDark ? const Color(0xFF2E2E35) : Colors.white,
        child: Container(color: c.surface),
      );

  // ─── Main info card ────────────────────────────────────────────────────────
  Widget _mainCard(
      AppColorScheme c, String title, String description, String branchTitle) {
    return DetailCard(
      c: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.heading20.copyWith(color: c.textPrimary)),
          if (description.isNotEmpty) ...[
            6.verticalSpace,
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppText.regular14.copyWith(color: c.textPrimary),
            ),
          ],
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
                        Text('detail_location'.tr(),
                            style: AppText.regular12
                                .copyWith(color: c.textSecondary)),
                        4.verticalSpace,
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
          16.verticalSpace,
          _HappyParents(
            c: c,
            seed: (widget.classModel.id ?? widget.classModel.title ?? '')
                .hashCode,
          ),
        ],
      ),
    );
  }

  // ─── Prices card ────────────────────────────────────────────────────────────
  Widget _pricesCard(
      AppColorScheme c,
      List<({String range, String subtitle, num price, SvgGenImage icon})>
          rows) {
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
          if (_cashback.hasRate) ...[
            12.verticalSpace,
            Align(
              alignment: Alignment.centerLeft,
              child: CashbackChip(preview: _cashback),
            ),
          ],
          16.verticalSpace,
          ...List.generate(rows.length, (i) {
            final r = rows[i];
            return Padding(
              padding: EdgeInsets.only(bottom: i == rows.length - 1 ? 0 : 8.h),
              child: _PriceRow(c: c, row: r, couponPct: _couponPct),
            );
          }),
        ],
      ),
    );
  }

  // ─── Course lessons card ────────────────────────────────────────────────────

  /// The groups a course is sold as, each carrying its own two calendars.
  ///
  /// A course has no single schedule or price to show once it runs as more than
  /// one group — each has its own — so every group is a panel carrying the
  /// whole picture: the dated trial lessons with what each costs, the dated
  /// course lessons, the seats and the price. It is on the page, not in the
  /// purchase sheet: these are the facts a parent decides on, and a sheet that
  /// has to be opened to read them hides the decision behind the commitment.
  ///
  /// A course entered without subcourses renders here too, as a single group —
  /// see [_courseGroups]. With one group there is nothing to choose, so the
  /// panel drops its radio and reports the picked trial lesson up to the sticky
  /// CTA instead of carrying a buy button of its own.
  Widget _courseLevelsCard(AppColorScheme c, List<CourseLevel> groups) {
    final single = groups.length == 1;
    return DetailCard(
      c: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailCardHeader(
            c: c,
            icon: Assets.icons.detail.icCalendar,
            iconGradient: AppGradients.brand,
            title: 'course_levels_title'.tr(),
          ),
          14.verticalSpace,
          ...List.generate(groups.length, (i) {
            final level = groups[i];
            return Padding(
              padding: EdgeInsets.only(
                bottom: i == groups.length - 1 ? 0 : 10.h,
              ),
              child: _CourseLevelPanel(
                level: level,
                weekdays: _courseWeekdays(_courseCalendar(level)),
                // The lone group is always the one being bought, so it reads as
                // picked without a radio to tap.
                selectable: !single,
                selected: single ||
                    (level.id != null && level.id == _selectedLevelId),
                // Single select — picking one replaces the last. Tapping the
                // picked one again is a no-op rather than a clear: one group is
                // always the one being bought, and an empty pick would leave
                // the price, the dates and the age brackets below describing
                // nothing.
                onSelect: single
                    ? null
                    : () => setState(() {
                          if (level.id == _selectedLevelId) return;
                          _selectedLevelId = level.id;
                          // The brackets belong to the group, so a new group
                          // means a new set of prices — carrying the old ticks
                          // across would price the sale off the wrong one.
                          _seedAgeTiers(level);
                        }),
                // With several groups the trial is bought from the panel — it
                // is the only place that says WHICH group's trial. With one,
                // the sticky CTA below does it, so the section only reports the
                // choice up.
                onBuyTrial: single ? null : () => _openTrialBooking(level),
                onTrialSelectionChanged: single
                    ? (lesson) {
                        if (_pickedTrial?.date == lesson?.date) return;
                        setState(() => _pickedTrial = lesson);
                      }
                    : null,
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── Course age brackets ────────────────────────────────────────────────────

  /// "Choose age" — the brackets the picked group is sold at, MULTI select.
  ///
  /// One tick is one child: a parent enrolling two children of different ages
  /// ticks both brackets and the card sums them, which is the figure the sticky
  /// CTA and the purchase sheet then carry. That is why these are checkboxes
  /// and the group above is a radio — the group is which product, this is how
  /// many of it and at which prices.
  ///
  /// On the page rather than in the purchase sheet, for the same reason the
  /// group panels are: the price a parent decides on is the one their children
  /// actually add up to, and a sheet that has to be opened to see it hides the
  /// decision behind the commitment.
  Widget _courseAgeTiersCard(AppColorScheme c, List<CourseAgeTier> tiers) {
    final picked = _selectedAgeTiers;
    return DetailCard(
      c: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailCardHeader(
            c: c,
            icon: Assets.icons.home.profile2user,
            iconGradient: AppGradients.brand,
            title: 'course_choose_age_title'.tr(),
          ),
          8.verticalSpace,
          Text(
            'course_choose_age_sub'.tr(),
            style: AppText.regular12.copyWith(color: c.textSecondary),
          ),
          14.verticalSpace,
          ...List.generate(tiers.length, (i) {
            final tier = tiers[i];
            final key = _tierKey(tier);
            final selected = _selectedTierKeys.contains(key);
            return Padding(
              padding:
                  EdgeInsets.only(bottom: i == tiers.length - 1 ? 0 : 8.h),
              child: _AgeTierRow(
                tier: tier,
                selected: selected,
                couponPct: _couponPct,
                // Unticking the last bracket is refused rather than hidden:
                // the row stays tappable so the tap has an obvious effect
                // everywhere else, and the one case that would leave the sale
                // priced at nothing simply doesn't take.
                onTap: () => setState(() {
                  if (!selected) {
                    _selectedTierKeys = {..._selectedTierKeys, key};
                  } else if (_selectedTierKeys.length > 1) {
                    _selectedTierKeys = {..._selectedTierKeys}..remove(key);
                  }
                }),
              ),
            );
          }),
          // Only worth a line once there is arithmetic to show. With one
          // bracket ticked the total is the row's own price, and repeating it
          // underneath reads as a second charge.
          if (picked.length > 1) ...[
            12.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: Text(
                    'course_age_total'
                        .tr(namedArgs: {'count': '${picked.length}'}),
                    style:
                        AppText.semibold14.copyWith(color: c.textPrimary),
                  ),
                ),
                Text(
                  _courseTotal.toRawUzsPrice(),
                  style: AppText.bold16
                      .copyWith(color: AppColors.brandPurple),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─── Description card ───────────────────────────────────────────────────────
  Widget _descriptionCard(AppColorScheme c, String title, String description) {
    return DetailCard(
      c: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.semibold16.copyWith(color: c.textPrimary)),
          6.verticalSpace,
          Text(description,
              style: AppText.regular14.copyWith(color: c.textPrimary)),
        ],
      ),
    );
  }

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

/// "Довольные родители" — decorative avatar group (Figma 60:3421). No real
/// data source; renders overlapping brand-gradient avatars + a "+N" chip.
class _HappyParents extends StatelessWidget {
  const _HappyParents({required this.c, required this.seed});
  final AppColorScheme c;

  /// Stable per-class seed (from the class id/title) so each class shows a
  /// different trio of parent photos and a different "+N" — not a fixed +12.
  final int seed;

  @override
  Widget build(BuildContext context) {
    final s = seed.abs();
    // Three distinct real-photo avatars, varied per class (pravatar has 1–70).
    final photoIds = <int>[
      s % 70 + 1,
      (s ~/ 11) % 70 + 1,
      (s ~/ 23) % 70 + 1,
    ];
    // "+N" overflow count varies per class (~8–48) instead of always +12.
    final extra = 8 + s % 41;

    Widget avatar(int id) => Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: c.surface, width: 2),
          ),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: 'https://i.pravatar.cc/120?img=$id',
              width: 40.w,
              height: 40.w,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: c.control),
              errorWidget: (_, __, ___) => Container(
                color: c.control,
                alignment: Alignment.center,
                child: Icon(CupertinoIcons.person_fill,
                    size: 20.sp, color: c.textSecondary),
              ),
            ),
          ),
        );

    return Row(
      children: [
        SizedBox(
          width: 40.w * 3 - 24.w + 40.w,
          height: 40.w,
          child: Stack(
            children: [
              Positioned(left: 0, child: avatar(photoIds[0])),
              Positioned(left: 28.w, child: avatar(photoIds[1])),
              Positioned(left: 56.w, child: avatar(photoIds[2])),
              Positioned(
                left: 84.w,
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.control,
                    border: Border.all(color: c.surface, width: 2),
                  ),
                  child: Text('+$extra',
                      style:
                          AppText.semibold12.copyWith(color: c.textSecondary)),
                ),
              ),
            ],
          ),
        ),
        10.horizontalSpace,
        Text('detail_happy_parents'.tr(),
            style: AppText.regular12.copyWith(color: c.textPrimary)),
      ],
    );
  }
}

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

class _PriceRow extends StatelessWidget {
  const _PriceRow(
      {required this.c, required this.row, required this.couponPct});
  final AppColorScheme c;
  final ({String range, String subtitle, num price, SvgGenImage icon}) row;
  final num couponPct;

  @override
  Widget build(BuildContext context) {
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
                Text(row.subtitle,
                    style: AppText.regular12.copyWith(color: c.textPrimary)),
              ],
            ),
          ),
          _priceChip(),
        ],
      ),
    );
  }

  Widget _priceChip() {
    Container chip(Widget child) => Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: detailChipFill(c),
            borderRadius: BorderRadius.circular(40.r),
          ),
          child: child,
        );
    if (couponPct <= 0 || row.price <= 0) {
      return chip(Text(
        row.price <= 0 ? 'price_free'.tr() : row.price.toRawUzsPrice(),
        style: AppText.semibold12.copyWith(color: c.textPrimary),
      ));
    }
    final discounted = (row.price * (100 - couponPct) / 100).round();
    return chip(Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          row.price.toRawUzsPrice(),
          style: AppText.regular12.copyWith(
            color: c.textMuted,
            decoration: TextDecoration.lineThrough,
          ),
        ),
        Text(discounted.toRawUzsPrice(),
            style: AppText.semibold12.copyWith(color: AppColors.green)),
      ],
    ));
  }
}

/// One line of an important-notes / what-to-bring list.
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

// ─── Course level sections ───────────────────────────────────────────────────

/// The course's own calendar, in date order — every lesson expanded from its
/// start date across its weekdays, through to the end date.
///
/// Deliberately NOT merged with the trial lessons. A course has two independent
/// calendars: the trials come from the activity's schedule and commonly run
/// weeks before the course itself starts, so listing them together would
/// misstate which days the course runs.
///
/// Top-level rather than a method: the page needs it for a level's weekday
/// summary, and the purchase sheet needs it for the same summary above the
/// dated list.
List<CourseLesson> _courseCalendar(CourseLevel level) {
  final lessons = level.courseLessons.where((l) => l.date.isNotEmpty).toList()
    ..sort((a, b) {
      final byDate = a.date.compareTo(b.date);
      return byDate != 0
          ? byDate
          : (a.startTime ?? '').compareTo(b.startTime ?? '');
    });
  return lessons;
}

/// "Tue, Thu, Sat" — which days the course runs, above the dated list.
/// Weekdays are read off the lessons themselves so the summary can never
/// disagree with the rows below it.
///
/// Days only: the lesson count used to be tacked on here, but the dated list
/// underneath already is the count, and the caller has the trial count to
/// state — three numbers on one line said less than one.
String _courseWeekdays(List<CourseLesson> lessons) {
  if (lessons.isEmpty) return '';
  // In WEEK order, not the order the dates happen to arrive in. The lessons are
  // sorted by date, so a course whose first lesson falls on a Wednesday read
  // "Wed, Fri, Mon" — a timetable nobody holds in their head that way.
  // DateTime.weekday is Mon=1…Sun=7, so sorting the numbers is the week order.
  final weekdayNums = lessons
      .map((l) => DateTime.tryParse(l.date)?.weekday)
      .whereType<int>()
      .toSet()
      .toList()
    ..sort();
  return weekdayNums.map((w) => 'weekday_short_$w'.tr()).join(', ');
}

/// When a course runs: its first lesson, and one calendar month later.
///
/// The end is a MONTH from the start, not the last lesson's date — a course is
/// sold as a month of lessons, so 11 Jan reads as "to 11 Feb" whether the
/// timetable's last entry falls on the 8th or the 14th. See [courseMonthEnd],
/// which the purchase sheet words its own month from.
///
/// Null when the group has no dated lessons — there is then no start to count
/// from, and the panel simply doesn't show a range.
({DateTime start, DateTime end})? _courseRun(CourseLevel level) {
  final lessons = _courseCalendar(level);
  if (lessons.isEmpty) return null;
  final start = DateTime.tryParse(lessons.first.date);
  if (start == null) return null;
  return (start: start, end: courseMonthEnd(start));
}

/// "11 yan" — a date as the rest of this page words them.
String _shortDate(DateTime d) => '${d.day} ${'month_short_${d.month}'.tr()}';

/// Why a purchase is refused, in words for the parent.
///
/// Mostly the reason's own message, but "wait for your first trial lesson" is
/// useless without the date — the parent's question is *when*, and they hold a
/// booking that answers it.
String _blockedMessage(CourseLevel level, CourseBlockedReason reason) {
  if (reason == CourseBlockedReason.trialPending) {
    final raw = level.enrollment?.trialFirstDate;
    final date = raw == null ? null : DateTime.tryParse(raw);
    if (date != null) {
      return 'course_blocked_trial_pending_date'.tr(namedArgs: {
        'date': '${date.day} ${'month_short_${date.month}'.tr()}',
      });
    }
  }
  if (reason == CourseBlockedReason.trialInProgress) {
    final raw = level.enrollment?.trialLastDate;
    final date = raw == null ? null : DateTime.tryParse(raw);
    if (date != null) {
      return 'course_blocked_trial_in_progress_date'.tr(namedArgs: {
        'date': '${date.day} ${'month_short_${date.month}'.tr()}',
      });
    }
  }
  return reason.messageKey.tr();
}

/// The trial block: a horizontal date strip to pick ONE upcoming session —
/// same shape as the ticket-booking flow's own date picker (`_DateStrip` in
/// booking_page.dart) — plus its price and the buy button.
///
/// Trials are sold ONE AT A TIME: a parent picks a single date to try, and
/// cannot pick the next one until that lesson has come round. The server is
/// authoritative on that gate (`canBuyTrial` / `trialBlockedReason`); this
/// widget just can't offer a purchase the server would reject.
/// The trial lessons of a course, as the ladder they actually are: lesson 1,
/// lesson 2, lesson 3 — each with its own date and its own price.
///
/// Listing them by NUMBER rather than offering a date picker is the point. The
/// centre prices each rung separately (a cheap or free first lesson, dearer
/// ones after), so "which lesson am I buying" is the choice a parent is
/// actually making, and a strip of dates hid it — every date looked alike and
/// the price sat somewhere else on the screen.
///
/// Lessons already bought, and lessons whose date has passed, stay in the list
/// but cannot be picked: the ladder reads as a whole, and a gap in it would
/// look like a missing lesson rather than a used one.
///
/// Selection is reported up via [onSelectionChanged] so the page's sticky
/// bottom CTA can enable itself — the one-group case, where that CTA is
/// unambiguous. Where it is not — a course running as several groups, whose
/// sticky CTA could not say whose trial it meant — [onBuy] renders an inline
/// button on the panel instead.
class _CourseTrialSection extends StatefulWidget {
  const _CourseTrialSection({
    required this.level,
    this.onBuy,
    this.onSelectionChanged,
    this.onFrosted = false,
  });

  final CourseLevel level;

  /// Open the booking screen for the picked lesson. Null when the sticky bottom
  /// CTA drives it instead.
  ///
  /// Takes no date: the booking screen offers the group's own trial dates and
  /// the purchase is written against the day picked THERE, so handing one over
  /// here would only be overwritten.
  final VoidCallback? onBuy;

  /// Reports the picked lesson (or null) so a bottom CTA can follow it.
  final ValueChanged<CourseLesson?>? onSelectionChanged;

  /// True when the section is nested in a [FrostedCard]. This only selects the
  /// branded header treatment; content colours remain theme-aware.
  final bool onFrosted;

  @override
  State<_CourseTrialSection> createState() => _CourseTrialSectionState();
}

class _CourseTrialSectionState extends State<_CourseTrialSection> {
  /// The picked lesson's DATE, not its index: the offered set rolls forward as
  /// dates pass, so an index would silently point at a different day tomorrow.
  ///
  /// Starts unset — nothing is preselected, because the bottom CTA reads as
  /// "book the trial lesson" and must not be armed before a parent has said
  /// which one.
  String? _pickedDate;

  CourseLesson? get _picked {
    for (final lesson in widget.level.trialLessons) {
      if (lesson.date == _pickedDate) return lesson;
    }
    return null;
  }

  /// The one rung that may be climbed right now: the FIRST lesson still on sale.
  ///
  /// A trial is taken in order — you cannot sit the third lesson of a course
  /// before the first. So exactly one row is ever selectable, and the rest show
  /// as locked rather than as choices that would be refused later. This mirrors
  /// the server, which prices the card off `configured[used]` — the same rung —
  /// so the screen and the charge can never name different lessons.
  ///
  /// Null once nothing is left to take.
  String? get _nextRungDate {
    for (final lesson in widget.level.trialLessons) {
      if (lesson.isAvailable) return lesson.date;
    }
    return null;
  }

  @override
  void didUpdateWidget(_CourseTrialSection old) {
    super.didUpdateWidget(old);
    // After a purchase the lesson just bought stops being available; a stale
    // pick would arm the CTA for something no longer on sale.
    if (_pickedDate != null && _picked?.isAvailable != true) {
      _pickedDate = null;
      _notify(null);
    }
  }

  /// Reported after the frame, never during build — the parent rebuilds its
  /// bottom CTA in response, and setState during build throws.
  void _notify(CourseLesson? lesson) {
    final report = widget.onSelectionChanged;
    if (report == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) report(lesson);
    });
  }

  void _pick(CourseLesson lesson) {
    setState(() {
      // Tapping the picked row clears it, so a parent can back out of the
      // choice without leaving the screen.
      _pickedDate = _pickedDate == lesson.date ? null : lesson.date;
    });
    _notify(_picked);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final level = widget.level;
    final blocked = !level.canBuyTrial ? level.trialBlockedReason : null;
    final lessons = level.trialLessons;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'course_trial_title'.tr(namedArgs: {'count': '${lessons.length}'}),
          style: AppText.semibold14.copyWith(color: c.textPrimary),
        ),
        6.verticalSpace,
        Text(
          blocked == null
              ? 'course_trial_pick_lesson_hint'.tr()
              : _blockedMessage(level, blocked),
          style: AppText.regular12.copyWith(color: c.textMuted),
        ),
        12.verticalSpace,
        for (var i = 0; i < lessons.length; i++) ...[
          if (i > 0) 8.verticalSpace,
          _TrialLessonRow(
            lesson: lessons[i],
            selected: lessons[i].date == _pickedDate,
            onFrosted: widget.onFrosted,
            // Locked until the rungs below it are done — see [_nextRungDate].
            locked: lessons[i].isAvailable && lessons[i].date != _nextRungDate,
            // A blocked section is still worth READING — it says which lessons
            // exist and what they cost — so the rows render, just inert.
            onTap: blocked == null && lessons[i].date == _nextRungDate
                ? () => _pick(lessons[i])
                : null,
          ),
        ],
        if (widget.onBuy != null && blocked == null && _picked != null) ...[
          12.verticalSpace,
          _buyButton(),
        ],
      ],
    );
  }

  Widget _buyButton() {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: widget.onBuy,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: AppGradients.green,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            'course_book_trial_cta'.tr(),
            style: AppText.semibold14.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// One rung of the trial ladder: "Trial lesson 2", its date, and its price.
///
/// A lesson that cannot be bought — already bought, or already run — keeps its
/// place in the list and says which of the two it is, rather than vanishing and
/// leaving the numbering with a hole in it.
class _TrialLessonRow extends StatelessWidget {
  const _TrialLessonRow({
    required this.lesson,
    required this.selected,
    required this.onTap,
    required this.onFrosted,
    this.locked = false,
  });

  final CourseLesson lesson;
  final bool selected;

  /// Null when this lesson cannot be picked right now.
  final VoidCallback? onTap;
  final bool onFrosted;

  /// Still for sale, but not yet: an earlier lesson has to be taken first.
  /// Says so with a padlock, because a row that were merely greyed would read
  /// as sold out or expired — and the parent would have no idea it unlocks.
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final accent = onFrosted ? AppColors.brandPurple : c.primary;
    final enabled = onTap != null;
    final free = (lesson.price ?? 0) <= 0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: selected ? accent.withValues(alpha: 0.08) : c.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: selected ? accent : c.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              locked
                  ? Icon(Icons.lock_outline_rounded,
                      size: 20.w, color: c.textMuted)
                  : _RadioDot(
                      selected: selected, accent: accent, border: c.border),
              10.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'course_trial_lesson_no'
                                .tr(namedArgs: {'n': '${lesson.lessonNo}'}),
                            style: AppText.semibold14
                                .copyWith(color: c.textPrimary),
                          ),
                        ),
                        if (lesson.isMandatory) ...[
                          6.horizontalSpace,
                          _TrialTag(
                            label: 'course_trial_mandatory'.tr(),
                            color: accent,
                          ),
                        ],
                      ],
                    ),
                    // Only a STATE line — no date. The day is picked on the
                    // booking page, off that course's own calendar; printing a
                    // date here promised a specific session this row does not
                    // actually sell, and the two disagreed the moment the
                    // buyer chose a different day.
                    //
                    // A row with nothing to say drops the line rather than
                    // leaving an empty one under the title.
                    if (lesson.purchased || lesson.hasPassed || locked) ...[
                      4.verticalSpace,
                      Text(
                        // Why it can't be picked matters: "already yours" and
                        // "too late" call for different next steps.
                        lesson.purchased
                            ? 'course_trial_bought_one'.tr()
                            : lesson.hasPassed
                                ? 'course_trial_passed'.tr()
                                : 'course_trial_locked'.tr(),
                        style:
                            AppText.regular12.copyWith(color: c.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              8.horizontalSpace,
              Text(
                free ? 'price_free'.tr() : (lesson.price ?? 0).toRawUzsPrice(),
                style: AppText.bold16
                    .copyWith(color: free ? AppColors.green : c.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One age bracket of a course, ticked or not: "3-5 years" and what a place at
/// that bracket costs.
///
/// A square box rather than [_RadioDot]'s circle — the group above is a
/// one-of-many radio and this is a many-of-many checkbox, and the shape is what
/// says so before anything is tapped.
class _AgeTierRow extends StatelessWidget {
  const _AgeTierRow({
    required this.tier,
    required this.selected,
    required this.couponPct,
    required this.onTap,
  });

  final CourseAgeTier tier;
  final bool selected;

  /// The plan discount already capped to this class — the same figure the
  /// price rows use, so a coupon holder reads one set of numbers on the page.
  final num couponPct;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    const accent = AppColors.brandPurple;
    final discounted = couponPct > 0 && tier.price > 0
        ? (tier.price * (100 - couponPct) / 100).round()
        : null;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.08) : c.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected ? accent : c.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            _CheckBox(selected: selected, accent: accent, border: c.border),
            10.horizontalSpace,
            Expanded(
              child: Text(
                '${tier.rangeLabel} ${'age_years_suffix'.tr()}',
                style: AppText.semibold14.copyWith(color: c.textPrimary),
              ),
            ),
            8.horizontalSpace,
            if (discounted == null)
              Text(
                tier.price.toRawUzsPrice(),
                style: AppText.semibold14.copyWith(color: c.textPrimary),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tier.price.toRawUzsPrice(),
                    style: AppText.regular12.copyWith(
                      color: c.textMuted,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  Text(
                    discounted.toRawUzsPrice(),
                    style:
                        AppText.semibold14.copyWith(color: AppColors.green),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Square tick box — the multi-select counterpart of [_RadioDot].
class _CheckBox extends StatelessWidget {
  const _CheckBox({
    required this.selected,
    required this.accent,
    required this.border,
  });

  final bool selected;
  final Color accent;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.w,
      height: 20.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: selected ? accent : border, width: 2),
        color: selected ? accent : Colors.transparent,
      ),
      child:
          selected ? Icon(Icons.check, size: 13.sp, color: Colors.white) : null,
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({
    required this.selected,
    required this.accent,
    required this.border,
  });

  final bool selected;
  final Color accent;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.w,
      height: 20.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: selected ? accent : border, width: 2),
        color: selected ? accent : Colors.transparent,
      ),
      child:
          selected ? Icon(Icons.check, size: 13.sp, color: Colors.white) : null,
    );
  }
}

/// Full-width green action button — the whole-course buy next to a trial CTA.
///
/// Green rather than the brand gradient so the two buttons in the bottom bar
/// are told apart at a glance: the gradient one takes the next trial lesson,
/// this one commits to the course.
class _GreenButton extends StatelessWidget {
  const _GreenButton({required this.text, required this.onPressed});

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: Opacity(
          opacity: onPressed == null ? 0.5 : 1,
          child: Container(
            // Same 44 as [GradientButton], the trial CTA directly above it:
            // both radii exceed half the button's height, so each renders as a
            // full pill and the two read as one pair rather than two styles.
            padding: EdgeInsets.symmetric(vertical: 14.h),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppGradients.green,
              borderRadius: BorderRadius.circular(44.r),
            ),
            child: Text(
              text,
              style: AppText.semibold14.copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class _TrialTag extends StatelessWidget {
  const _TrialTag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: AppText.semibold12.copyWith(color: color),
      ),
    );
  }
}

/// Horizontal day picker for trial lessons — the trial equivalent of
/// `_DateStrip` in booking_page.dart, so trying a class feels like booking
/// one. Auto-centres on the selected day when it changes.
class _TrialDateStrip extends StatefulWidget {
  const _TrialDateStrip({
    required this.dates,
    required this.selected,
    required this.onPick,
  });

  final List<String> dates;
  final String? selected;

  /// Null while the whole section is blocked (or nothing is buyable).
  final ValueChanged<String>? onPick;

  @override
  State<_TrialDateStrip> createState() => _TrialDateStripState();
}

class _TrialDateStripState extends State<_TrialDateStrip> {
  final ScrollController _scrollCtrl = ScrollController();

  /// Chip width + separator. Kept in sync with [_TrialDateChip] so the
  /// auto-scroll lands on the right day.
  static const double _chipExtent = _TrialDateChip.width + 4;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void didUpdateWidget(_TrialDateStrip old) {
    super.didUpdateWidget(old);
    if (old.selected != widget.selected) _scrollToSelected();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToSelected() {
    if (!_scrollCtrl.hasClients) return;
    final idx = widget.dates.indexOf(widget.selected ?? '');
    if (idx <= 0) return;
    final extent = _chipExtent.w;
    final target =
        idx * extent - (_scrollCtrl.position.viewportDimension - extent) / 2;
    _scrollCtrl.animateTo(
      target.clamp(0.0, _scrollCtrl.position.maxScrollExtent),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollCtrl,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < widget.dates.length; i++) ...[
            if (i > 0) 4.horizontalSpace,
            _TrialDateChip(
              date: widget.dates[i],
              isSelected: widget.selected == widget.dates[i],
              onTap: widget.onPick != null
                  ? () => widget.onPick!(widget.dates[i])
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}

/// One candidate date for the next trial lesson. Dates come from
/// [CourseLevel.trialNextDates], so each chip represents the same ladder slot
/// and differs only by when the parent wants to attend it.
class _TrialDateChip extends StatelessWidget {
  const _TrialDateChip({
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  /// Fixed so every chip is the same width whether or not it is selected —
  /// otherwise the strip would jitter as the frosted pill moves between days.
  static const double width = 48;

  final String date;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final d = DateTime.tryParse(date);
    final tappable = onTap != null;

    final dayColor = c.textPrimary;
    final mutedColor = c.textSecondary;

    final content = d == null
        ? Text(date, style: AppText.regular12.copyWith(color: mutedColor))
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('weekday_short_${d.weekday}'.tr(),
                  style: AppText.regular12.copyWith(color: mutedColor)),
              4.verticalSpace,
              Text('${d.day}',
                  style: AppText.bold18.copyWith(color: dayColor, height: 1.0)),
              4.verticalSpace,
              Text('month_short_${d.month}'.tr(),
                  style: AppText.regular12.copyWith(color: mutedColor)),
            ],
          );

    final padding = EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w);

    return Opacity(
      opacity: tappable ? 1 : 0.4,
      child: SizedBox(
        width: width.w,
        child: isSelected
            ? FrostedCard(
                onTap: onTap,
                padding: padding,
                borderRadius: BorderRadius.circular(56.r),
                child: content,
              )
            : GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap,
                child: Padding(padding: padding, child: content),
              ),
      ),
    );
  }
}

/// One group of a course — name, price, weekday summary, lesson count, seats
/// and description, plus the dated trial lessons with their individual prices.
///
/// The trial ladder is the one part that opens on selection rather than sitting
/// there: it is many rows long, and several groups' worth at once buries the
/// choice itself under it. Closed, the summary line carries the trial count so
/// nothing about the offer goes missing — only its detail.
///
/// With several groups the panel is a CHOICE: tapping it picks it, and the
/// page's single sticky CTA at the bottom buys whatever is picked. Giving every
/// panel its own whole-course button turned a list of options into a row of
/// competing calls to action, and there is only ever one thing being bought.
///
/// A course that runs as ONE group has nothing to choose, so [selectable] is
/// false there: no radio, and the trial ladder reports its pick up to the
/// sticky CTA rather than carrying a button of its own.
///
/// Sits on a theme-aware [FrostedCard], so its content uses theme roles too.
class _CourseLevelPanel extends StatelessWidget {
  const _CourseLevelPanel({
    required this.level,
    required this.weekdays,
    required this.selected,
    required this.onSelect,
    required this.onBuyTrial,
    this.onTrialSelectionChanged,
    this.selectable = true,
  });

  final CourseLevel level;
  final String weekdays;

  /// Whether this is the picked group. Single select across the list; always
  /// true when this is the only group.
  final bool selected;

  /// Whether the parent has a choice to make. False for a lone group, which
  /// drops the radio dot and the tap target with it.
  final bool selectable;

  /// Pick this group (or unpick it, if it is already the picked one). Null when
  /// there is nothing to choose.
  final VoidCallback? onSelect;

  /// Buy a trial lesson of this group, on the shared booking screen. Null when
  /// the page's sticky CTA drives it instead — see [onTrialSelectionChanged].
  final VoidCallback? onBuyTrial;

  /// Reports the picked trial lesson up so the sticky CTA can follow it. Set
  /// only when this is the lone group.
  final ValueChanged<CourseLesson?>? onTrialSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enrolled = level.enrollment?.isEnrolled == true;
    final hasTrial = level.enrollment?.hasTrial == true;
    // A course entered without subcourses has one unnamed group, so it gets a
    // generic heading. Not the course's own title: that is already at the top
    // of the page, and repeating it here would read as the panel being the
    // course rather than a group of it — which is exactly the distinction this
    // card exists to draw.
    final name = (level.name ?? '').trim().isNotEmpty
        ? level.name!.trim()
        : 'course_group_default_name'.tr();
    final summary = _summary(level, weekdays);
    final run = _courseRun(level);
    // The panel stays pickable even when the group can't be bought right
    // now: the reason is surfaced when the CTA is tapped, which reads better
    // than an inert row a parent has to guess about. Sold out is still worth
    // reading — the dates and the price are the point of the panel.
    const accent = AppColors.brandPurple;

    return GestureDetector(
      onTap: onSelect,
      behavior: HitTestBehavior.opaque,
      child: FrostedCard(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            // Only a real choice is highlighted. A lone group is "selected" so
            // the CTA can sell it, but painting it picked would imply the
            // parent chose it over something else.
            color: selectable && selected ? accent.withValues(alpha: 0.08) : null,
            border: Border.all(
              color: selectable && selected ? accent : Colors.transparent,
              width: 1.5,
            ),
          ),
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectable) ...[
                    _RadioDot(
                      selected: selected,
                      accent: accent,
                      border: colors.border,
                    ),
                    10.horizontalSpace,
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppText.semibold16
                              .copyWith(color: colors.textPrimary),
                        ),
                        // Empty when the group has neither dated lessons nor
                        // trials — with the lesson count gone there is no
                        // longer anything that always fills this line, so it
                        // has to be able to disappear rather than render as a
                        // blank gap under the name.
                        if (summary.isNotEmpty) ...[
                          4.verticalSpace,
                          Text(
                            summary,
                            style: AppText.regular12
                                .copyWith(color: colors.textSecondary),
                          ),
                        ],
                        // When the course actually runs. Stated on every
                        // panel, not just the picked one: it is one of the two
                        // facts a parent picks a group ON, so hiding it until
                        // after the pick would be asking them to choose blind.
                        if (run != null) ...[
                          4.verticalSpace,
                          Text(
                            'course_run_dates'.tr(namedArgs: {
                              'from': _shortDate(run.start),
                              'to': _shortDate(run.end),
                            }),
                            style: AppText.regular12
                                .copyWith(color: colors.textSecondary),
                          ),
                        ],
                        if (enrolled ||
                            hasTrial ||
                            level.seatsLeft != null) ...[
                          4.verticalSpace,
                          Text(
                            enrolled
                                ? 'course_level_enrolled'.tr()
                                : hasTrial
                                    ? 'course_level_trial'.tr()
                                    : level.isFull
                                        ? 'course_full_no_seats'.tr()
                                        : 'course_seats_left'.tr(namedArgs: {
                                            'count': '${level.seatsLeft}',
                                          }),
                            style: AppText.regular12.copyWith(
                              color: enrolled || hasTrial
                                  ? AppColors.green
                                  : level.isFull
                                      ? AppColors.error
                                      : colors.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  8.horizontalSpace,
                  Text(
                    // A group priced by age has no single price — this is the
                    // cheapest bracket, and saying so keeps it from reading as
                    // the figure every child costs. The brackets themselves,
                    // and what they add up to, are in the card below.
                    level.hasMultiplePriceTiers
                        ? 'price_from'
                            .tr(args: [level.coursePrice.toRawUzsPrice()])
                        : level.coursePrice.toRawUzsPrice(),
                    style:
                        AppText.bold16.copyWith(color: AppColors.brandPurple),
                  ),
                ],
              ),
              if ((level.description ?? '').trim().isNotEmpty) ...[
                10.verticalSpace,
                Text(
                  level.description!.trim(),
                  style:
                      AppText.regular13.copyWith(color: colors.textSecondary),
                ),
              ],
              // Only the picked group opens its trial ladder. Every group
              // showing every dated lesson at once turned a list of three or
              // four choices into a screen of scrolling, and the parent has to
              // pick one before any of it matters anyway. A lone group counts
              // as picked, so it opens straight away.
              if (selected && level.trialLessons.isNotEmpty) ...[
                12.verticalSpace,
                _CourseTrialSection(
                  level: level,
                  onBuy: onBuyTrial,
                  onSelectionChanged: onTrialSelectionChanged,
                  onFrosted: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// "Mon, Wed, Fri · 3 trial" — which days it runs, and that it can be tried
  /// first. The two facts a parent picks a group on.
  ///
  /// No lesson count: the dated list below already is the count, and a line
  /// carrying days AND lessons AND trials read as a spec sheet rather than a
  /// summary.
  ///
  /// Stated whether the group is open or closed. It duplicates the trial
  /// section's own title by a couple of lines when open, which is cheaper than
  /// a summary that rewrites itself every time the panel is tapped.
  String _summary(CourseLevel level, String weekdays) {
    final trials = level.trialLessons.isEmpty
        ? ''
        : 'course_trial_count'
            .tr(namedArgs: {'count': '${level.trialLessons.length}'});
    return [weekdays, trials].where((s) => s.isNotEmpty).join(' · ');
  }
}

/// Inert CTA shown in place of "Buy tickets" when a class is hidden from the
/// catalogue. Deliberately not a disabled [GradientButton]: a greyed-out
/// gradient reads as "temporarily broken", where this reads as "not yet".
class _ComingSoonButton extends StatelessWidget {
  const _ComingSoonButton({required this.c});

  final AppColorScheme c;

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
        'booking_available_soon'.tr(),
        textAlign: TextAlign.center,
        style: AppText.semibold16.copyWith(color: c.textSecondary),
      ),
    );
  }
}
