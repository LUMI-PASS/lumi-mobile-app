import 'dart:async';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:lumi_pass/common/widget/auth/gradient_button.dart';
import 'package:lumi_pass/common/widget/detail/detail_card.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';
import 'package:lumi_pass/common/widget/stretchy_hero.dart';
import 'package:lumi_pass/data/api_model/class_full/class_full_model.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/service/analytics_service.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/courses/courses_api.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:lumi_pass/presentation/app/home/course_detail/course_purchase.dart';
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

  /// Set only for a course: its dated lessons and package prices, fetched from
  /// `/api/courses/:id`. The lesson dates are expanded server-side from the
  /// course's own weekday pattern, so the screen never re-derives them.
  CourseDetail? _course;
  bool _buyingCourse = false;

  /// A course is sold as a package, not per session. Known from the list model
  /// before the detail lands, so the CTA never flashes the ticket wording.
  bool get _isCourse =>
      _full?.isCourse ?? widget.classModel.isCourse ?? false;

  /// 0 → hero fully visible, 1 → content scrolled under the top controls and
  /// the frosted scrim is fully on.
  double _topScrim = 0;

  // ─── Coupon discount helpers ──────────────────────────────────────────────
  /// The coupon's percentage on THIS class — the plan's percentage capped at
  /// Lumi's share of the class, which is what checkout will actually charge.
  num get _couponPct {
    final s = getIt<Storage>();
    final plan = s.hasPremium() == true ? (s.planDiscountPercentage() ?? 0) : 0;
    return effectiveCouponPercent(
      plan,
      _full?.discountPercentage ?? widget.classModel.discountPercentage,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadImages();
    _loadFull();
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
    final t = ((_scrollController.offset - start) / (end - start))
        .clamp(0.0, 1.0);
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
      setState(() => _course = detail);
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
        final from = tiers.map((t) => t.ageFrom).reduce((a, b) => a < b ? a : b);
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
    context.router.push(BookingRoute(clazz: full));
  }

  /// Course CTA. Opens the package picker — trial lessons vs the whole course.
  ///
  /// [level] is passed when the parent came from a level panel that already
  /// shows that level's dates and prices: the sheet then skips straight to the
  /// package step instead of asking them to pick the level a second time.
  Future<void> _openCoursePurchase({CourseLevel? level}) async {
    final detail = _course;
    if (detail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('cta_loading'.tr())),
      );
      return;
    }
    getIt<AnalyticsService>().logEvent(
      AnalyticsEvent.bookButtonTapped,
      params: {
        if (_full?.id != null) 'class_id': _full!.id!,
        if (widget.classModel.title != null)
          'class_title': widget.classModel.title!,
        'is_course': 'true',
      },
    );
    final choice = await showModalBottomSheet<CoursePurchaseChoice>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _CoursePurchaseSheet(detail: detail, initialLevel: level),
    );
    if (choice != null && mounted) await _buyCourse(choice);
  }

  /// Charges the chosen package and hands off to the shared checkout screen —
  /// the same one the per-session booking flow ends on.
  Future<void> _buyCourse(CoursePurchaseChoice choice) async {
    final id = _full?.id ?? widget.classModel.id;
    if (id == null || _buyingCourse) return;
    setState(() => _buyingCourse = true);

    // Shared with nothing else on this screen, but deliberately not inlined:
    // it carries the sign-in check and the course error-code mapping, which
    // both matter more here than the few lines they save.
    final result = await runCoursePurchase(
      context,
      activityId: id,
      option: choice.option,
      subcourseId: choice.levelId,
      trialDates: choice.trialDates,
    );

    if (!mounted) return;
    setState(() => _buyingCourse = false);

    if (result.needsReload) {
      // The enrolment may have changed — refresh so the sheet reflects it.
      await _loadCourse(id);
      return;
    }
    final message = result.message;
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: context.colors.error,
        ),
      );
    }
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
        final prices = t.durations
            .map((d) => d.price)
            .where((p) => p > 0)
            .toList();
        final min = prices.isEmpty
            ? 0
            : prices.reduce((a, b) => a < b ? a : b);
        final adults = t.ageFrom >= 6 || t.ageTo == null;
        rows.add((
          range: t.rangeLabel,
          subtitle:
              adults ? 'price_tier_all'.tr() : 'price_tier_children'.tr(),
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
        statusBarIconBrightness:
            darkIcons ? Brightness.dark : Brightness.light,
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
                        // Which days the course actually runs, what the trial
                        // lessons cost and when they are — the things a parent
                        // decides on, so they belong on the page rather than
                        // behind the buy button. A course sold as LEVELS has no
                        // single calendar (Beginner and Advanced run at
                        // different times), so each level carries its own.
                        if (_course?.hasLevels == true) ...[
                          6.verticalSpace,
                          _courseLevelsCard(c, _course!),
                        ] else if (_course != null) ...[
                          if (_course!.flat.trialLessons.isNotEmpty) ...[
                            6.verticalSpace,
                            _courseTrialCard(c, _course!.flat),
                          ],
                          if (_courseCalendar(_course!.flat).isNotEmpty) ...[
                            6.verticalSpace,
                            _courseLessonsCard(c, _course!.flat),
                          ],
                        ],
                        if (priceRows.isNotEmpty) ...[
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
                SliverToBoxAdapter(
                  child: SizedBox(height: 90.h + safeBottom),
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
                        size: 16, color: AppColors.ink),
                    onTap: () => context.router.pop(),
                  ),
                  const Spacer(),
                  DetailControlButton(
                    onTap: _shareClass,
                    child: HomeIcon(Assets.icons.home.share,
                        size: 16, color: AppColors.inkMuted),
                  ),
                  8.horizontalSpace,
                  DetailControlButton(
                    child: HomeIcon(Assets.icons.home.heart,
                        size: 16,
                        color:
                            _isFavorite ? AppColors.error : AppColors.inkMuted),
                    onTap: () => setState(() => _isFavorite = !_isFavorite),
                  ),
                ],
              ),
            ),
            // Bottom CTA.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: c.scaffoldBg,
                  boxShadow: AppShadows.bottomBar,
                ),
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h + safeBottom),
                // A class the centre has hidden can still be reached by direct
                // link or from an existing booking, so the page opens — but it
                // must not be bookable. Inert "coming soon" rather than a Book
                // button that would fail at checkout.
                // A course is bought as a package (trial lessons or the whole
                // course), never as a dated ticket — so it gets its own
                // wording and opens the course purchase sheet instead of the
                // per-session booking flow.
                child: _full?.isVisible == false
                    ? _ComingSoonButton(c: c)
                    : GradientButton(
                        text: _isCourse
                            ? 'course_buy_cta'.tr()
                            : 'buy_tickets'.tr(),
                        onPressed: _isCourse
                            ? () => _openCoursePurchase()
                            : _openBooking,
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
                          color: active
                              ? AppColors.ink
                              : const Color(0xFFCECDD6),
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
                          style: AppText.semibold14
                              .copyWith(color: c.textPrimary),
                        ),
                      ],
                    ),
                  ),
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
                        child: Text('view_all'.tr(),
                            style: AppText.regular12
                                .copyWith(color: c.textPrimary)),
                      ),
                    ),
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

  /// Every dated lesson of the course, not a weekly pattern.
  ///
  /// A parent buying a course is committing to a fixed set of days, so the
  /// screen shows exactly which ones rather than "Tue/Thu/Sat" and leaving them
  /// to work out the dates.
  /// The levels a course is sold as, each opening onto its own two calendars.
  ///
  /// A levelled course has no single schedule or price to show — each level has
  /// its own — so every level is a panel carrying the whole picture: the dated
  /// trial lessons with what each costs, the dated course lessons, the seats
  /// and the price. It is on the page, not in the purchase sheet: these are the
  /// facts a parent decides on, and a sheet that has to be opened to read them
  /// hides the decision behind the commitment.
  Widget _courseLevelsCard(AppColorScheme c, CourseDetail detail) {
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
          8.verticalSpace,
          Text(
            'course_levels_subtitle'.tr(),
            style: AppText.regular13.copyWith(color: c.textSecondary),
          ),
          14.verticalSpace,
          ...List.generate(detail.levels.length, (i) {
            final level = detail.levels[i];
            return Padding(
              padding: EdgeInsets.only(
                bottom: i == detail.levels.length - 1 ? 0 : 10.h,
              ),
              child: _CourseLevelPanel(
                // The first level opens with the page. Dates and trial prices
                // are what the parent came to check, so at least one full set
                // is readable without a tap.
                initiallyExpanded: i == 0,
                level: level,
                weekdays: _courseWeekdays(_courseCalendar(level)),
                onBuy: () => _openCoursePurchase(level: level),
                onBuyTrial: (dates) => _buyCourse(
                  CoursePurchaseChoice(
                    option: CoursePurchaseOption.trial,
                    levelId: level.id,
                    trialDates: dates,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// The trial lessons of a course that isn't sold as levels: which dates, and
  /// what each one costs. Priced per lesson, so the per-lesson figures are
  /// shown alongside the total rather than only the sum.
  Widget _courseTrialCard(AppColorScheme c, CourseLevel level) {
    return DetailCard(
      c: c,
      child: _CourseTrialSection(
        level: level,
        showTitle: true,
        onBuy: (dates) => _buyCourse(
          CoursePurchaseChoice(
            option: CoursePurchaseOption.trial,
            levelId: level.id,
            trialDates: dates,
          ),
        ),
      ),
    );
  }

  Widget _courseLessonsCard(AppColorScheme c, CourseLevel level) {
    final lessons = _courseCalendar(level);
    final pattern = _courseWeekdays(lessons);
    return DetailCard(
      c: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailCardHeader(
            c: c,
            icon: Assets.icons.detail.icCalendar,
            iconGradient: AppGradients.brand,
            title: 'course_schedule_title'.tr(),
          ),
          if (pattern.isNotEmpty) ...[
            8.verticalSpace,
            Text(
              pattern,
              style: AppText.regular13.copyWith(color: c.textSecondary),
            ),
          ],
          16.verticalSpace,
          ...List.generate(lessons.length, (i) {
            final l = lessons[i];
            return Padding(
              padding:
                  EdgeInsets.only(bottom: i == lessons.length - 1 ? 0 : 8.h),
              child: _CourseLessonRow(c: c, lesson: l, index: i + 1),
            );
          }),
        ],
      ),
    );
  }

  /// The course's own calendar, in date order — every lesson expanded from its
  /// start date across its weekdays, through to the end date.
  ///
  /// Deliberately NOT merged with the trial lessons. A course has two
  /// independent calendars: the trials come from the activity's schedule and
  /// commonly run weeks before the course itself starts, so listing them here
  /// would misstate which days the course runs. The trials are priced and
  /// counted in the purchase sheet instead.
  List<CourseLesson> _courseCalendar(CourseLevel level) {
    final lessons =
        level.courseLessons.where((l) => l.date.isNotEmpty).toList()
          ..sort((a, b) {
            final byDate = a.date.compareTo(b.date);
            return byDate != 0
                ? byDate
                : (a.startTime ?? '').compareTo(b.startTime ?? '');
          });
    return lessons;
  }

  /// "Tue, Thu, Sat · 12 lessons" — the shape of the commitment, above the
  /// dated list. Weekdays are read off the lessons themselves so the summary
  /// can never disagree with the rows below it.
  String _courseWeekdays(List<CourseLesson> lessons) {
    if (lessons.isEmpty) return '';
    final seen = <int>{};
    final days = <String>[];
    for (final l in lessons) {
      final d = DateTime.tryParse(l.date);
      if (d == null || !seen.add(d.weekday)) continue;
      days.add('weekday_short_${d.weekday}'.tr());
    }
    final count =
        'course_lessons_count'.tr(namedArgs: {'count': '${lessons.length}'});
    return days.isEmpty ? count : '${days.join(', ')} · $count';
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
            children: languages.map((lang) => _LangChip(c: c, lang: lang)).toList(),
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
                      style: AppText.semibold12.copyWith(color: c.textSecondary)),
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
          Text(label,
              style: AppText.regular12.copyWith(color: c.textPrimary)),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.c, required this.row, required this.couponPct});
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
    if (l.contains('uz') || l.contains('ўз') || l.contains('o‘z') || l.contains("o'z")) {
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


// ─── Course lesson row ───────────────────────────────────────────────────────

/// One dated lesson: its position, the date, the time window and — for a trial
/// lesson, which is priced on its own — what it costs.
///
/// The price forces a second line: "12 Aug, Tue · 10:00 – 11:00 · 30 000 сум"
/// on one row overflows on a small phone, and none of the three may be the one
/// that gets clipped.
class _CourseLessonRow extends StatelessWidget {
  const _CourseLessonRow({
    required this.c,
    required this.lesson,
    required this.index,
  });

  final AppColorScheme c;
  final CourseLesson lesson;
  final int index;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(lesson.date);
    final label = date == null
        ? lesson.date
        : '${date.day} ${'month_short_${date.month}'.tr()}, '
            '${'weekday_short_${date.weekday}'.tr()}';
    final time = [lesson.startTime, lesson.endTime]
        .whereType<String>()
        .where((t) => t.isNotEmpty)
        .join(' – ');
    final price = lesson.price;
    // A lesson that has already run is still listed — the set of dates is what
    // the parent is reading — but it is visibly not part of what is on sale.
    final passed = lesson.hasPassed;

    return Opacity(
      opacity: passed ? 0.45 : 1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: c.control, shape: BoxShape.circle),
            child: Text(
              '$index',
              style: AppText.semibold12.copyWith(color: c.textSecondary),
            ),
          ),
          10.horizontalSpace,
          Expanded(
            child: price == null
                ? Text(
                    label,
                    style: AppText.semibold14.copyWith(color: c.textPrimary),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style:
                            AppText.semibold14.copyWith(color: c.textPrimary),
                      ),
                      if (time.isNotEmpty)
                        Text(
                          time,
                          style: AppText.regular12
                              .copyWith(color: c.textSecondary),
                        ),
                    ],
                  ),
          ),
          if (price == null && time.isNotEmpty) ...[
            6.horizontalSpace,
            Text(time,
                style: AppText.regular13.copyWith(color: c.textSecondary)),
          ],
          if (price != null) ...[
            8.horizontalSpace,
            Text(
              price.toRawUzsPrice(),
              style: AppText.semibold14.copyWith(color: c.textPrimary),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Course level sections ───────────────────────────────────────────────────

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
  return reason.messageKey.tr();
}

/// The trial block: every trial date, what each one costs, and the total.
///
/// A trial is not a discount on the course — each lesson is sold at its own
/// price and the fee is not credited toward enrolling — so the per-lesson
/// figures are shown, not just the sum a parent would otherwise have to accept
/// on trust.
class _CourseTrialSection extends StatefulWidget {
  const _CourseTrialSection({
    required this.level,
    required this.onBuy,
    this.showTitle = false,
  });

  final CourseLevel level;

  /// Buy the picked sessions, as YYYY-MM-DD dates.
  final void Function(List<String> dates) onBuy;

  /// True when this section is the whole card and needs the gradient header.
  final bool showTitle;

  @override
  State<_CourseTrialSection> createState() => _CourseTrialSectionState();
}

class _CourseTrialSectionState extends State<_CourseTrialSection> {
  /// Picked sessions, by date. Keyed on the date because the offered set rolls
  /// forward — an index would silently point at a different day tomorrow.
  late Set<String> _picked = _initialPick();

  /// What to tick on arrival: the mandatory lessons if there are any, else the
  /// next single lesson.
  ///
  /// Never the whole set — that would quote four lessons to someone who came to
  /// try one. But a mandatory lesson is not optional, so leaving it unticked
  /// would let a parent buy a lesson that gets them no closer to enrolling.
  Set<String> _initialPick() {
    final available = widget.level.availableTrialLessons;
    final mandatory =
        available.where((l) => l.isMandatory).map((l) => l.date).toSet();
    if (mandatory.isNotEmpty) return mandatory;
    final first = available.firstOrNull;
    return first == null ? <String>{} : {first.date};
  }

  @override
  void didUpdateWidget(_CourseTrialSection old) {
    super.didUpdateWidget(old);
    // After a purchase the lessons come back with `purchased` set; a stale pick
    // would keep a bought lesson ticked.
    if (widget.level.trialLessons.length != old.level.trialLessons.length ||
        widget.level.availableTrialLessons.length !=
            old.level.availableTrialLessons.length) {
      _picked = _initialPick();
    }
  }

  num get _total => widget.level.trialLessons
      .where((l) => _picked.contains(l.date))
      .fold<num>(0, (sum, l) => sum + (l.price ?? 0));

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final level = widget.level;
    final lessons = level.trialLessons;
    final blocked = !level.canBuyTrial ? level.trialBlockedReason : null;
    final anyAvailable = level.availableTrialLessons.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showTitle)
          DetailCardHeader(
            c: c,
            icon: Assets.icons.detail.icDiscount,
            iconGradient: AppGradients.green,
            title: 'course_trial_title'
                .tr(namedArgs: {'count': '${lessons.length}'}),
          )
        else
          Text(
            'course_trial_title'.tr(namedArgs: {'count': '${lessons.length}'}),
            style: AppText.semibold14.copyWith(color: c.textPrimary),
          ),
        6.verticalSpace,
        Text(
          'course_trial_pick_hint'.tr(),
          style: AppText.regular12.copyWith(color: c.textMuted),
        ),
        // Said here, before the price of the course itself: where a lesson is
        // mandatory the parent's first purchase is not the one they came for,
        // and finding that out at checkout is finding it out too late. Which
        // lessons is shown on the rows themselves.
        if (level.hasMandatoryTrial) ...[
          8.verticalSpace,
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: c.control,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: c.controlBorder),
            ),
            child: Text(
              'course_trial_required_note'.tr(namedArgs: {
                'count': '${level.mandatoryTrialLessons.length}',
              }),
              style: AppText.regular12.copyWith(color: c.textPrimary),
            ),
          ),
        ],
        12.verticalSpace,
        ...List.generate(lessons.length, (i) {
          final l = lessons[i];
          return Padding(
            padding: EdgeInsets.only(bottom: i == lessons.length - 1 ? 0 : 8.h),
            child: _TrialLessonRow(
              c: c,
              lesson: l,
              index: i + 1,
              picked: _picked.contains(l.date),
              onToggle: !l.isAvailable
                  ? null
                  : () => setState(() {
                        if (!_picked.remove(l.date)) _picked.add(l.date);
                      }),
            ),
          );
        }),
        if (anyAvailable) ...[
          12.verticalSpace,
          Divider(height: 1, color: c.border),
          10.verticalSpace,
          Row(
            children: [
              Expanded(
                child: Text(
                  'course_trial_selected'
                      .tr(namedArgs: {'count': '${_picked.length}'}),
                  style: AppText.semibold14.copyWith(color: c.textPrimary),
                ),
              ),
              Text(
                _total.toRawUzsPrice(),
                style: AppText.bold16.copyWith(color: c.primary),
              ),
            ],
          ),
          10.verticalSpace,
          _buyButton(c, enabled: _picked.isNotEmpty && level.canBuyTrial),
        ],
        if (blocked != null) ...[
          8.verticalSpace,
          Text(
            _blockedMessage(level, blocked),
            style: AppText.regular12.copyWith(color: c.textMuted),
          ),
        ],
      ],
    );
  }

  Widget _buyButton(AppColorScheme c, {required bool enabled}) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: enabled
            ? () => widget.onBuy(_picked.toList()..sort())
            : null,
        behavior: HitTestBehavior.opaque,
        child: Opacity(
          opacity: enabled ? 1 : 0.5,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppGradients.green,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              'course_buy_trial'.tr(),
              style: AppText.semibold14.copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

/// One trial lesson, with the tick that puts it in the basket.
///
/// Three states, and they must not be confused: available (tickable), already
/// bought (stated, not tickable — buying it twice is refused server-side), and
/// past (dimmed, gone).
class _TrialLessonRow extends StatelessWidget {
  const _TrialLessonRow({
    required this.c,
    required this.lesson,
    required this.index,
    required this.picked,
    required this.onToggle,
  });

  final AppColorScheme c;
  final CourseLesson lesson;
  final int index;
  final bool picked;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(lesson.date);
    final label = date == null
        ? lesson.date
        : '${date.day} ${'month_short_${date.month}'.tr()}, '
            '${'weekday_short_${date.weekday}'.tr()}';
    final time = [lesson.startTime, lesson.endTime]
        .whereType<String>()
        .where((t) => t.isNotEmpty)
        .join(' – ');
    final selectable = onToggle != null;

    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: selectable ? 1 : 0.5,
        child: Row(
          children: [
            Container(
              width: 22.w,
              height: 22.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: picked ? c.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: picked ? c.primary : c.border,
                  width: 1.5,
                ),
              ),
              child: picked || lesson.purchased
                  ? Icon(Icons.check_rounded,
                      size: 14.sp,
                      color: lesson.purchased && !picked
                          ? c.success
                          : Colors.white)
                  : null,
            ),
            10.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '$index. $label',
                          style:
                              AppText.semibold14.copyWith(color: c.textPrimary),
                        ),
                      ),
                      // Which lesson is required, on the lesson itself — a note
                      // at the top of the list cannot say "this one".
                      if (lesson.isMandatory) ...[
                        6.horizontalSpace,
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: c.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'course_trial_mandatory'.tr(),
                            style: AppText.semibold12.copyWith(color: c.primary),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (time.isNotEmpty || lesson.purchased)
                    Text(
                      lesson.purchased
                          ? [time, 'course_trial_bought_one'.tr()]
                              .where((t) => t.isNotEmpty)
                              .join(' · ')
                          : time,
                      style: AppText.regular12.copyWith(
                        color: lesson.purchased ? c.success : c.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            8.horizontalSpace,
            Text(
              (lesson.price ?? 0).toRawUzsPrice(),
              style: AppText.semibold14.copyWith(color: c.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

/// The course's own dated calendar for one level, under the level panel.
///
/// Long courses are capped: twenty rows would bury everything below them, so
/// the first [_visible] are shown with a tap to reveal the rest.
class _CourseScheduleSection extends StatefulWidget {
  const _CourseScheduleSection({required this.level, required this.weekdays});

  final CourseLevel level;

  /// "Tue, Thu · 12 lessons", computed by the page off the same lesson list.
  final String weekdays;

  @override
  State<_CourseScheduleSection> createState() => _CourseScheduleSectionState();
}

class _CourseScheduleSectionState extends State<_CourseScheduleSection> {
  static const int _visible = 5;

  bool _all = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final lessons = widget.level.courseLessons
        .where((l) => l.date.isNotEmpty)
        .toList()
      ..sort((a, b) {
        final byDate = a.date.compareTo(b.date);
        return byDate != 0
            ? byDate
            : (a.startTime ?? '').compareTo(b.startTime ?? '');
      });
    final shown = _all ? lessons : lessons.take(_visible).toList();
    final hidden = lessons.length - shown.length;
    final blocked = !widget.level.canBuyFull ? widget.level.blockedReason : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'course_schedule_title'.tr(),
                style: AppText.semibold14.copyWith(color: c.textPrimary),
              ),
            ),
            8.horizontalSpace,
            Text(
              widget.level.coursePrice.toRawUzsPrice(),
              style: AppText.semibold14.copyWith(color: c.primary),
            ),
          ],
        ),
        if (widget.weekdays.isNotEmpty) ...[
          6.verticalSpace,
          Text(
            widget.weekdays,
            style: AppText.regular12.copyWith(color: c.textMuted),
          ),
        ],
        12.verticalSpace,
        ...List.generate(shown.length, (i) {
          return Padding(
            padding: EdgeInsets.only(bottom: i == shown.length - 1 ? 0 : 8.h),
            child: _CourseLessonRow(c: c, lesson: shown[i], index: i + 1),
          );
        }),
        if (hidden > 0 || _all) ...[
          8.verticalSpace,
          GestureDetector(
            onTap: () => setState(() => _all = !_all),
            behavior: HitTestBehavior.opaque,
            child: Text(
              _all
                  ? 'course_show_less'.tr()
                  : 'course_more_lessons'.tr(namedArgs: {'count': '$hidden'}),
              style: AppText.semibold14.copyWith(color: c.primary),
            ),
          ),
        ],
        if (blocked != null) ...[
          8.verticalSpace,
          Text(
            _blockedMessage(widget.level, blocked),
            style: AppText.regular12.copyWith(color: c.textMuted),
          ),
        ],
      ],
    );
  }
}

/// One level of a levelled course, expanded in place on the detail page.
///
/// Collapsed it states the commitment — name, price, lesson count, seats.
/// Opened it carries everything the purchase sheet used to hold back: the
/// description, the dated trial lessons with their individual prices, and the
/// course calendar. The sheet is then only the act of buying.
class _CourseLevelPanel extends StatefulWidget {
  const _CourseLevelPanel({
    required this.level,
    required this.weekdays,
    required this.onBuy,
    required this.onBuyTrial,
    this.initiallyExpanded = false,
  });

  final CourseLevel level;
  final String weekdays;

  /// Buy the whole level — opens the purchase sheet.
  final VoidCallback onBuy;

  /// Buy the picked trial sessions of this level, as YYYY-MM-DD dates.
  final void Function(List<String> dates) onBuyTrial;
  final bool initiallyExpanded;

  @override
  State<_CourseLevelPanel> createState() => _CourseLevelPanelState();
}

class _CourseLevelPanelState extends State<_CourseLevelPanel> {
  late bool _open = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final level = widget.level;
    final enrolled = level.enrollment?.isEnrolled == true;
    final hasTrial = level.enrollment?.hasTrial == true;
    final canBuy = level.canBuyFull || level.canBuyTrial;

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _open = !_open),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          level.name ?? '',
                          style: AppText.semibold16
                              .copyWith(color: c.textPrimary),
                        ),
                        4.verticalSpace,
                        Text(
                          _summary(level),
                          style: AppText.regular12
                              .copyWith(color: c.textSecondary),
                        ),
                        if (enrolled || hasTrial || level.seatsLeft != null) ...[
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
                                  ? c.success
                                  : level.isFull
                                      ? c.error
                                      : c.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  8.horizontalSpace,
                  Text(
                    level.coursePrice.toRawUzsPrice(),
                    style: AppText.bold16.copyWith(color: c.primary),
                  ),
                  2.horizontalSpace,
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20.sp,
                      color: c.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_open)
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((level.description ?? '').trim().isNotEmpty) ...[
                    Text(
                      level.description!.trim(),
                      style:
                          AppText.regular13.copyWith(color: c.textSecondary),
                    ),
                    12.verticalSpace,
                  ],
                  if (level.trialLessons.isNotEmpty) ...[
                    Divider(height: 1, color: c.border),
                    12.verticalSpace,
                    _CourseTrialSection(
                      level: level,
                      onBuy: widget.onBuyTrial,
                    ),
                    12.verticalSpace,
                  ],
                  if (level.courseLessons.isNotEmpty) ...[
                    Divider(height: 1, color: c.border),
                    12.verticalSpace,
                    _CourseScheduleSection(
                      level: level,
                      weekdays: widget.weekdays,
                    ),
                    12.verticalSpace,
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: canBuy ? widget.onBuy : null,
                      behavior: HitTestBehavior.opaque,
                      child: Opacity(
                        opacity: canBuy ? 1 : 0.5,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: c.control,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: c.controlBorder),
                          ),
                          child: Text(
                            canBuy
                                ? 'course_buy_level'.tr()
                                : 'course_blocked_unavailable'.tr(),
                            style: AppText.semibold14
                                .copyWith(color: c.textPrimary),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// "12 lessons · 3 trial" — the shape of the commitment in one line.
  String _summary(CourseLevel level) {
    final parts = <String>[
      'course_lessons_count'
          .tr(namedArgs: {'count': '${level.courseLessons.length}'}),
      if (level.trialLessons.isNotEmpty)
        'course_trial_count'
            .tr(namedArgs: {'count': '${level.trialLessons.length}'}),
    ];
    return parts.join(' · ');
  }
}

// ─── Course purchase sheet ───────────────────────────────────────────────────

/// What the purchase sheet returns: which level (null when the course has none)
/// and which of the two packages.
class CoursePurchaseChoice {
  const CoursePurchaseChoice({
    required this.option,
    this.levelId,
    this.trialDates,
  });

  final CoursePurchaseOption option;
  final String? levelId;

  /// Which trial sessions, as YYYY-MM-DD. Trials are sold one at a time and
  /// picked by date because the offered set rolls forward; null on a
  /// whole-course purchase.
  final List<String>? trialDates;
}

/// The two things a course sells. Kept as a picker rather than two CTAs on the
/// page: the choice only matters once the parent has decided to buy, and the
/// trial's "you still pay full price for the course afterwards" caveat needs
/// room to be stated rather than hidden.
///
/// A course sold as LEVELS adds a step in front: pick Beginner / Elementary /
/// … first, then the package for that level. The second step is identical
/// either way, because a level and a level-less course expose the same fields.
class _CoursePurchaseSheet extends StatefulWidget {
  const _CoursePurchaseSheet({required this.detail, this.initialLevel});

  final CourseDetail detail;

  /// Set when the parent opened the sheet from a level panel that already
  /// shows that level's dates and prices — the level step is then skipped.
  final CourseLevel? initialLevel;

  @override
  State<_CoursePurchaseSheet> createState() => _CoursePurchaseSheetState();
}

class _CoursePurchaseSheetState extends State<_CoursePurchaseSheet> {
  late CourseLevel? _selected = widget.initialLevel;

  bool get _needsLevel => widget.detail.hasLevels && _selected == null;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: c.scaffoldBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: c.border,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            16.verticalSpace,
            if (_needsLevel) ..._levelStep(c) else ..._packageStep(c),
          ],
        ),
      ),
    );
  }

  // ── Step 1: which level ────────────────────────────────────────────────────
  List<Widget> _levelStep(AppColorScheme c) {
    return [
      Text(
        'course_levels_title'.tr(),
        style: AppText.semibold18.copyWith(color: c.textPrimary),
      ),
      6.verticalSpace,
      Text(
        'course_levels_subtitle'.tr(),
        style: AppText.regular13.copyWith(color: c.textSecondary),
      ),
      16.verticalSpace,
      // Scrollable: a language school can easily run six levels, and the sheet
      // must not push its own content off the screen.
      ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 0.5.sh),
        child: SingleChildScrollView(
          child: Column(
            children: [
              for (final level in widget.detail.levels) ...[
                _levelRow(c, level),
                10.verticalSpace,
              ],
            ],
          ),
        ),
      ),
    ];
  }

  Widget _levelRow(AppColorScheme c, CourseLevel level) {
    final enrolled = level.enrollment?.isEnrolled == true;
    // Nothing left to sell here — still listed, so a parent can see the level
    // exists, but it must not look tappable-into-a-purchase.
    final unavailable = !level.canBuyFull && !level.canBuyTrial && !enrolled;

    return GestureDetector(
      onTap: () => setState(() => _selected = level),
      child: Opacity(
        opacity: unavailable ? 0.5 : 1,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: c.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      level.name ?? '',
                      style: AppText.semibold16.copyWith(color: c.textPrimary),
                    ),
                  ),
                  8.horizontalSpace,
                  Text(
                    level.coursePrice.toRawUzsPrice(),
                    style: AppText.bold16.copyWith(color: c.primary),
                  ),
                ],
              ),
              4.verticalSpace,
              Text(
                'course_lessons_count'
                    .tr(namedArgs: {'count': '${level.courseLessons.length}'}),
                style: AppText.regular13.copyWith(color: c.textSecondary),
              ),
              if (enrolled) ...[
                6.verticalSpace,
                Text(
                  'course_level_enrolled'.tr(),
                  style: AppText.regular12.copyWith(color: c.success),
                ),
              ] else if (level.seatsLeft != null) ...[
                6.verticalSpace,
                Text(
                  level.isFull
                      ? 'course_full_no_seats'.tr()
                      : 'course_seats_left'
                          .tr(namedArgs: {'count': '${level.seatsLeft}'}),
                  style: AppText.regular12.copyWith(
                    color: level.isFull ? c.error : c.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Step 2: which package ──────────────────────────────────────────────────
  List<Widget> _packageStep(AppColorScheme c) {
    // For a level-less course this is the whole sheet, and `flat` IS the course.
    final level = _selected ?? widget.detail.flat;
    final enrolled = level.enrollment?.isEnrolled == true;
    final hasTrial = level.enrollment?.hasTrial == true;

    return [
      Row(
        children: [
          if (widget.detail.hasLevels)
            GestureDetector(
              onTap: () => setState(() => _selected = null),
              child: Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: Icon(Icons.arrow_back_ios_new,
                    size: 16.sp, color: c.textPrimary),
              ),
            ),
          Expanded(
            child: Text(
              level.name ?? 'course_buy_cta'.tr(),
              style: AppText.semibold18.copyWith(color: c.textPrimary),
            ),
          ),
        ],
      ),
      if (enrolled) ...[
        12.verticalSpace,
        Text(
          'course_already_enrolled'.tr(),
          style: AppText.regular14.copyWith(color: c.textSecondary),
        ),
      ],
      16.verticalSpace,
      // Only the whole course is sold here. Trial lessons go one at a time and
      // the parent picks the dates, so they are bought from the trial section
      // on the page — a sheet that quoted the whole set as one price would be
      // selling something that no longer exists.
      _option(
        c,
        level: level,
        option: CoursePurchaseOption.full,
        title: 'course_full_title'.tr(),
        subtitle: level.lessonsLeft > 0 &&
                level.lessonsLeft < level.courseLessons.length
            // Joining mid-course buys only what is still ahead — at full price.
            ? 'course_lessons_remaining'.tr(namedArgs: {
                'left': '${level.lessonsLeft}',
                'total': '${level.courseLessons.length}',
              })
            : 'course_lessons_count'
                .tr(namedArgs: {'count': '${level.courseLessons.length}'}),
        price: level.coursePrice,
        enabled: level.canBuyFull,
        disabledLabel: level.blockedReason == null
            ? null
            : _blockedMessage(level, level.blockedReason!),
        // Stated, not hidden: the trial fee is not credited toward this.
        note: hasTrial ? 'course_upsell_body_short'.tr() : null,
      ),
    ];
  }

  Widget _option(
    AppColorScheme c, {
    required CourseLevel level,
    required CoursePurchaseOption option,
    required String title,
    required String subtitle,
    required num price,
    required bool enabled,
    String? disabledLabel,
    String? note,
  }) {
    return GestureDetector(
      onTap: enabled
          ? () => Navigator.of(context).pop(
                CoursePurchaseChoice(option: option, levelId: level.id),
              )
          : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: c.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(title,
                        style:
                            AppText.semibold16.copyWith(color: c.textPrimary)),
                  ),
                  8.horizontalSpace,
                  Text(
                    price.toRawUzsPrice(),
                    style: AppText.bold16.copyWith(color: c.primary),
                  ),
                ],
              ),
              4.verticalSpace,
              Text(subtitle,
                  style: AppText.regular13.copyWith(color: c.textSecondary)),
              if (note != null) ...[
                6.verticalSpace,
                Text(note,
                    style: AppText.regular12.copyWith(color: c.textMuted)),
              ],
              if (!enabled && disabledLabel != null) ...[
                6.verticalSpace,
                Text(disabledLabel,
                    style: AppText.regular12.copyWith(color: c.textMuted)),
              ],
            ],
          ),
        ),
      ),
    );
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
      padding: EdgeInsets.symmetric(vertical: 16.h),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.control,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: c.controlBorder),
      ),
      child: Text(
        'coming_soon'.tr(),
        style: AppText.semibold16.copyWith(color: c.textSecondary),
      ),
    );
  }
}
