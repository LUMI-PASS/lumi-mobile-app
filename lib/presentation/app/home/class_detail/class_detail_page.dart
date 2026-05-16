import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/ios_text_styles.dart';
import 'package:lumi_pass/common/utils/app_locale.dart';
import 'package:lumi_pass/data/api_model/class_full/class_full_model.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/service/remote_config_service.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/widgets/booking_bottomsheet.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/shorts/shorts_feed.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────
const _brand = Color(0xFF6C4EF2);
const _brandDark = Color(0xFF4A2FD4);
const _brandLight = Color(0xFFEDE8FF);
const _cream = Color(0xFFFDFAF5);
const _border = Color(0xFFE8E4F6);
const _navy = Color(0xFF0E0C2B);
const _muted = Color(0xFF6B6899);
const _success = Color(0xFF16A34A);

BoxShadow get _cardShadow => const BoxShadow(
      color: Color(0x1A6C4EF2),
      blurRadius: 24,
      offset: Offset(0, 4),
    );

@RoutePage()
class ClassDetailPage extends StatefulWidget {
  const ClassDetailPage({super.key, required this.classModel});

  final HomClass classModel;

  @override
  State<ClassDetailPage> createState() => _ClassDetailPageState();
}

class _ClassDetailPageState extends State<ClassDetailPage> {
  bool _isFavorite = false;
  List<String> _galleryImages = [];
  bool _isLoadingImages = true;
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  ClassFullModel? _full;
  Timer? _slideTimer;

  @override
  void initState() {
    super.initState();
    _loadImages();
    _loadFull();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _slideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
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
        _isLoadingImages = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoadingImages = false);
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
      setState(() {
        _galleryImages = [initial];
        _isLoadingImages = false;
      });
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

  void _onGallerySwipe(DragEndDetails details) {
    if (_galleryImages.length <= 1) return;
    final v = details.primaryVelocity ?? 0;
    if (v < -150) {
      final next = (_currentImageIndex + 1) % _galleryImages.length;
      _pageController.animateToPage(next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut);
    } else if (v > 150) {
      final prev =
          (_currentImageIndex - 1 + _galleryImages.length) % _galleryImages.length;
      _pageController.animateToPage(prev,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut);
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

  Color _getGenderColor() {
    switch ((_full?.gender ?? widget.classModel.gender)?.toUpperCase()) {
      case 'MALE':
        return const Color(0xFF3B82F6);
      case 'FEMALE':
        return const Color(0xFF7C3AED);
      default:
        return _brand;
    }
  }

  IconData _getGenderIcon() {
    switch ((_full?.gender ?? widget.classModel.gender)?.toUpperCase()) {
      case 'MALE':
        return Icons.male_rounded;
      case 'FEMALE':
        return Icons.female_rounded;
      default:
        return Icons.people_rounded;
    }
  }

  String _formatDuration(_Duration? d) {
    if (d == null) return '—';
    if (d.unbounded) return 'duration_unbounded'.tr();
    final minutes = d.minutes;
    if (minutes == null || minutes == 0) return '—';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h} soat';
    return '$m min';
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

  String _formatDistance(double? distanceMeters) {
    if (distanceMeters == null || distanceMeters <= 0) return '';
    if (distanceMeters < 1000) {
      return '${distanceMeters.round()} m';
    }
    final km = distanceMeters / 1000;
    return '${km.toStringAsFixed(1)} km';
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

  void _shareClass() {
    final title = widget.classModel.title ?? '';
    final branch = widget.classModel.branch?.title ?? '';
    final text = branch.isNotEmpty ? '$title — $branch' : title;
    Share.share(text);
  }

  void _openBookingSheet() {
    final full = _full;
    if (full == null ||
        (full.pricesSummary.isEmpty && full.ageTiers.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('cta_loading'.tr())),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: false,
      builder: (_) => BookingBottomsheet(clazz: full),
    );
  }

  String _getCategoryName() {
    final full = _full;
    if (full?.category != null) {
      final v = _localized(full!.category!.name);
      if (v.isNotEmpty) return v;
    }
    final cat = widget.classModel.category;
    if (cat != null && cat.isNotEmpty) return cat;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final classModel = widget.classModel;
    final full = _full;
    final safeBottom = MediaQuery.of(context).viewPadding.bottom;

    final categoryName = _getCategoryName();
    final branchTitle = full?.branch?.title ?? classModel.branch?.title;
    final distanceStr =
        _formatDistance(classModel.branch?.distance ?? classModel.distance);

    return Scaffold(
      backgroundColor: _cream,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ─── [1] Hero SliverAppBar ─────────────────────────────────────
              SliverAppBar(
                expandedHeight: 310.h,
                pinned: true,
                stretch: true,
                backgroundColor: _cream,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                automaticallyImplyLeading: false,
                leadingWidth: 72.w,
                toolbarHeight: 60.h,
                leading: Padding(
                  padding: EdgeInsets.only(left: 16.w, top: 6.h, bottom: 6.h),
                  child: _FrostedCircleButton(
                    onTap: () => context.router.pop(),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: _navy,
                      size: 18,
                    ),
                  ),
                ),
                actions: [
                  _FrostedCircleButton(
                    onTap: _shareClass,
                    child: const Icon(Icons.share_rounded, color: _navy, size: 18),
                  ),
                  8.kw,
                  _FrostedCircleButton(
                    onTap: () => setState(() => _isFavorite = !_isFavorite),
                    child: Icon(
                      _isFavorite
                          ? CupertinoIcons.heart_fill
                          : CupertinoIcons.heart,
                      color: _isFavorite ? const Color(0xFFEF4444) : _navy,
                      size: 18,
                    ),
                  ),
                  16.kw,
                ],
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  stretchModes: const [StretchMode.zoomBackground],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Gallery images — GestureDetector handles horizontal
                      // swipes because PageView inside SliverAppBar's
                      // FlexibleSpaceBar doesn't receive them reliably.
                      _galleryImages.isNotEmpty
                          ? GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onHorizontalDragEnd: _onGallerySwipe,
                              child: PageView.builder(
                              controller: _pageController,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _galleryImages.length,
                              onPageChanged: (i) =>
                                  setState(() => _currentImageIndex = i),
                              itemBuilder: (_, i) => CachedNetworkImage(
                                imageUrl: _galleryImages[i],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                placeholder: (_, __) => Shimmer.fromColors(
                                  baseColor: Colors.grey.shade200,
                                  highlightColor: Colors.grey.shade50,
                                  child: Container(color: Colors.white),
                                ),
                                errorWidget: (_, __, ___) =>
                                    Assets.images.defaultImage.image(
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ),
                          )
                          : _isLoadingImages
                              ? Shimmer.fromColors(
                                  baseColor: Colors.grey.shade200,
                                  highlightColor: Colors.grey.shade50,
                                  child: Container(color: Colors.white),
                                )
                              : Assets.images.defaultImage.image(
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),

                      // Top vignette — keeps nav buttons legible over any image
                      const Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0x880E0C2B), Colors.transparent],
                              stops: [0.0, 0.38],
                            ),
                          ),
                        ),
                      ),

                      // Bottom vignette
                      const Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Color(0xBB0E0C2B),
                              ],
                              stops: [0.5, 1.0],
                            ),
                          ),
                        ),
                      ),

                      // Page indicators
                      if (_galleryImages.length > 1)
                        Positioned(
                          bottom: 14.h,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _galleryImages.length,
                              (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                width: _currentImageIndex == i ? 16 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: _currentImageIndex == i
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Category chip
                      if (categoryName.isNotEmpty)
                        Positioned(
                          bottom: 14.h,
                          left: 16.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 5.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.4)),
                            ),
                            child: Text(
                              categoryName,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ─── [2] Info card ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [_cardShadow],
                    ),
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          classModel.title ?? '',
                          style: IOSText.largeTitle(),
                        ),
                        14.kh,

                        if (branchTitle != null &&
                            branchTitle.isNotEmpty &&
                            classModel.branch != null)
                          _BranchNavCard(
                            title: branchTitle,
                            distance: distanceStr,
                            onTap: () => context.router.push(
                              BranchDetailRoute(branch: classModel.branch!),
                            ),
                          ),

                        16.kh,
                        Divider(color: _border, height: 1),
                        16.kh,

                        // Stats as tinted chip cards
                        Builder(builder: (_) {
                          final ageRange = _effectiveAgeRange(full);
                          final ageLabel = ageRange == null
                              ? null
                              : (ageRange.from == ageRange.to
                                  ? '${ageRange.from} yosh'
                                  : '${ageRange.from}–${ageRange.to} yosh');

                          final stats = <(IconData, Color, String, String)>[
                            (
                              Icons.access_time_rounded,
                              _brand,
                              _formatDuration(_effectiveDuration(full)),
                              'detail_duration_label'.tr(),
                            ),
                            if (ageLabel != null)
                              (
                                Icons.child_care_rounded,
                                _success,
                                ageLabel,
                                'age'.tr(),
                              ),
                            (
                              _getGenderIcon(),
                              _getGenderColor(),
                              _getGenderText(),
                              'gender'.tr(),
                            ),
                          ];

                          return Row(
                            children: stats.asMap().entries.map((e) {
                              final idx = e.key;
                              final s = e.value;
                              return Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(
                                      right: idx < stats.length - 1
                                          ? 8.w
                                          : 0),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12.h, horizontal: 6.w),
                                  decoration: BoxDecoration(
                                    color: s.$2.withOpacity(0.07),
                                    borderRadius:
                                        BorderRadius.circular(14.r),
                                    border: Border.all(
                                        color: s.$2.withOpacity(0.14)),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(s.$1,
                                          size: 20.sp, color: s.$2),
                                      6.kh,
                                      Text(
                                        s.$3,
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w700,
                                          color: _navy,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      2.kh,
                                      Text(
                                        s.$4,
                                        style: TextStyle(
                                            fontSize: 10.sp,
                                            color: _muted),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── [3] Content sections ──────────────────────────────────────
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (full == null) _DetailShimmer(),

                    if (full != null &&
                        (full.hasAgeTierPricing ||
                            full.pricesSummary.isNotEmpty)) ...[
                      _DetailSection(
                        title: full.hasAgePricing
                            ? 'detail_prices_by_age'.tr()
                            : 'detail_prices'.tr(),
                        icon: Icons.sell_rounded,
                        iconColor: _brand,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (full.hasAgeTierPricing)
                              ...List.generate(full.ageTiers.length, (i) {
                                final tier = full.ageTiers[i];
                                final isLastTier =
                                    i == full.ageTiers.length - 1;
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8.h),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10.w,
                                                vertical: 5.h),
                                            decoration: BoxDecoration(
                                              color: _brandLight,
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                            ),
                                            child: Text(
                                              tier.rangeLabel,
                                              style: TextStyle(
                                                fontSize: 11.sp,
                                                fontWeight: FontWeight.w800,
                                                color: _brandDark,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ...List.generate(
                                        tier.durations.length, (j) {
                                      final dur = tier.durations[j];
                                      final isLastDur =
                                          j == tier.durations.length - 1;
                                      return Column(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                12.w, 6.h, 0, 6.h),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.timelapse_rounded,
                                                  size: 14.sp,
                                                  color: _muted,
                                                ),
                                                6.kw,
                                                Expanded(
                                                  child: Text(
                                                    dur.durationLabel,
                                                    style: IOSText.body(),
                                                  ),
                                                ),
                                                Text(
                                                  dur.price.toRawUzsPrice(),
                                                  style:
                                                      IOSText.bodyEmphasized(
                                                          color: _brandDark),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (!isLastDur)
                                            Divider(
                                                height: 1,
                                                color: _border,
                                                thickness: 1),
                                        ],
                                      );
                                    }),
                                    if (!isLastTier)
                                      Divider(
                                          height: 1,
                                          color: _border,
                                          thickness: 1),
                                  ],
                                );
                              })
                            else
                              ...List.generate(full.pricesSummary.length,
                                  (i) {
                                final r = full.pricesSummary[i];
                                final isLast =
                                    i == full.pricesSummary.length - 1;
                                return Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8.h),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40.w,
                                            height: 36.h,
                                            decoration: BoxDecoration(
                                              color: _brandLight,
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${r.ageFrom}–${r.ageTo}',
                                                style: TextStyle(
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.w800,
                                                  color: _brandDark,
                                                ),
                                              ),
                                            ),
                                          ),
                                          10.kw,
                                          Expanded(
                                            child: Text(
                                              r.rangeLabel,
                                              style: IOSText.body(),
                                            ),
                                          ),
                                          Text(
                                            r.price.toRawUzsPrice(),
                                            style: IOSText.bodyEmphasized(
                                                color: _brandDark),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!isLast)
                                      Divider(
                                          height: 1,
                                          color: _border,
                                          thickness: 1),
                                  ],
                                );
                              }),
                          ],
                        ),
                      ),
                      16.kh,
                    ],

                    if (full != null &&
                        _cleanHtml(_localized(full.description))
                            .isNotEmpty) ...[
                      _DetailSection(
                        title: 'detail_about'.tr(),
                        icon: Icons.info_outline_rounded,
                        iconColor: _brand,
                        child: Text(
                          _cleanHtml(_localized(full.description)),
                          style: IOSText.body(color: IOSText.secondary),
                        ),
                      ),
                      16.kh,
                    ] else if (full == null &&
                        (classModel.description ?? '').isNotEmpty) ...[
                      _DetailSection(
                        title: 'detail_about'.tr(),
                        icon: Icons.info_outline_rounded,
                        iconColor: _brand,
                        child: Text(
                          _cleanHtml(classModel.description!),
                          style: IOSText.body(color: IOSText.secondary),
                        ),
                      ),
                      16.kh,
                    ],

                    if (full != null &&
                        _cleanHtml(_localized(full.importantNotes))
                            .isNotEmpty) ...[
                      _DetailSection(
                        title: 'detail_notes'.tr(),
                        icon: Icons.priority_high_rounded,
                        iconColor: const Color(0xFFD97706),
                        child: Text(
                          _cleanHtml(_localized(full.importantNotes)),
                          style: IOSText.body(color: IOSText.secondary),
                        ),
                      ),
                      16.kh,
                    ],

                    if (full != null &&
                        _cleanHtml(_localized(full.requiredItems))
                            .isNotEmpty) ...[
                      _DetailSection(
                        title: 'detail_bring'.tr(),
                        icon: Icons.checklist_rounded,
                        iconColor: const Color(0xFF0E7490),
                        child: Text(
                          _cleanHtml(_localized(full.requiredItems)),
                          style: IOSText.body(color: IOSText.secondary),
                        ),
                      ),
                      16.kh,
                    ],

                    if (full != null &&
                        full.activityLanguages.isNotEmpty) ...[
                      _DetailSection(
                        title: 'detail_language'.tr(),
                        icon: Icons.translate_rounded,
                        iconColor: _muted,
                        child: Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: full.activityLanguages
                              .map(
                                (lang) => Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: _brandLight,
                                    borderRadius:
                                        BorderRadius.circular(10.r),
                                  ),
                                  child: Text(
                                    lang,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: _brandDark,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      16.kh,
                    ],

                    if (full != null && full.workHours.isNotEmpty) ...[
                      _DetailSection(
                        title: 'detail_hours'.tr(),
                        icon: Icons.schedule_rounded,
                        iconColor: const Color(0xFF059669),
                        child: Column(
                          children: full.workHours
                              .map(
                                (s) => Padding(
                                  padding: EdgeInsets.only(bottom: 8.h),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8.w,
                                        height: 8.h,
                                        decoration: BoxDecoration(
                                          color: _brand,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      8.kw,
                                      Expanded(
                                        child: Text(
                                          s.day,
                                          style: IOSText.bodyEmphasized(),
                                        ),
                                      ),
                                      Text(
                                        '${s.startTime} – ${s.endTime}',
                                        style: IOSText.body(
                                            color: IOSText.secondary),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      16.kh,
                    ],

                    if (full?.effectiveVideoUrl != null) ...[
                      _VideoCard(onTap: () {
                        ShortsFeed.set([widget.classModel], 0);
                        context.tabsRouter.setActiveIndex(1);
                      }),
                      16.kh,
                    ],

                    120.kh,
                  ]),
                ),
              ),
            ],
          ),

          // ─── CTA bar at bottom ─────────────────────────────────────────────
          if (!RemoteConfigService.instance.isInReview)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x00FDFAF5),
                      Color(0xF2FDFAF5),
                      _cream,
                    ],
                    stops: [0.0, 0.35, 0.65],
                  ),
                ),
                padding: EdgeInsets.fromLTRB(
                    16.w, 20.h, 16.w, safeBottom + 16.h),
                child: full == null
                    ? Shimmer.fromColors(
                        baseColor: Colors.grey.shade200,
                        highlightColor: Colors.grey.shade50,
                        child: Container(
                          height: 54.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                      )
                    : full.pricesSummary.isEmpty && full.ageTiers.isEmpty
                        ? _CtaButton(
                            label: 'cta_loading'.tr(),
                            enabled: false,
                            onTap: null,
                          )
                        : _CtaGradientButton(
                            label: 'cta_buy_ticket'.tr(),
                            onTap: _openBookingSheet,
                          ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Frosted circle button ─────────────────────────────────────────────────────

class _FrostedCircleButton extends StatelessWidget {
  const _FrostedCircleButton({required this.onTap, required this.child});
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42.w,
      height: 42.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: onTap,
          child: Center(child: child),
        ),
      ),
    );
  }
}

// ─── Branch navigation card ────────────────────────────────────────────────────

class _BranchNavCard extends StatelessWidget {
  const _BranchNavCard({
    required this.title,
    required this.distance,
    required this.onTap,
  });

  final String title;
  final String distance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: _brandLight.withOpacity(0.4),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: _brandLight,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.apartment_rounded, color: _brand, size: 18.sp),
            ),
            10.kw,
            Expanded(
              child: Text(
                title,
                style: IOSText.headline(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (distance.isNotEmpty) ...[
              6.kw,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _brandLight,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  distance,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: _brandDark,
                  ),
                ),
              ),
            ],
            6.kw,
            Icon(Icons.arrow_forward_ios_rounded, size: 14.sp, color: _muted),
          ],
        ),
      ),
    );
  }
}

// ─── Detail section ────────────────────────────────────────────────────────────

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [_cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Icon(icon, color: iconColor, size: 18.sp),
                ),
              ),
              10.kw,
              Expanded(
                child: Text(title, style: IOSText.headline()),
              ),
            ],
          ),
          12.kh,
          child,
        ],
      ),
    );
  }
}

// ─── Video card ────────────────────────────────────────────────────────────────

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_brand, _brandDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: _brand.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
                border: Border.all(color: Colors.white.withOpacity(0.35)),
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 26.sp,
              ),
            ),
            12.kw,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'video_watch'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  2.kh,
                  Text(
                    'video_shorts_cta'.tr(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── CTA button (disabled state) ──────────────────────────────────────────────

class _CtaButton extends StatelessWidget {
  const _CtaButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });
  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? _brandDark : const Color(0xFFCBD5E1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ─── CTA gradient button ───────────────────────────────────────────────────────

class _CtaGradientButton extends StatelessWidget {
  const _CtaGradientButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_brandDark, _brand],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: _brand.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Detail shimmer skeleton ───────────────────────────────────────────────────

class _DetailShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          16.kh,
          _shimmerBox(height: 20.h, width: 120.w, radius: 6.r),
          12.kh,
          _shimmerBox(height: 80.h, width: double.infinity, radius: 14.r),
          16.kh,
          _shimmerBox(height: 20.h, width: 160.w, radius: 6.r),
          12.kh,
          _shimmerBox(height: 120.h, width: double.infinity, radius: 14.r),
          16.kh,
          _shimmerBox(height: 20.h, width: 100.w, radius: 6.r),
          12.kh,
          _shimmerBox(height: 80.h, width: double.infinity, radius: 14.r),
          20.kh,
        ],
      ),
    );
  }

  Widget _shimmerBox(
      {required double height,
      required double width,
      required double radius}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ─── Effective duration value ──────────────────────────────────────────────────

class _Duration {
  const _Duration._({required this.unbounded, this.minutes});

  final bool unbounded;
  final int? minutes;

  factory _Duration.finite(int minutes) =>
      _Duration._(unbounded: false, minutes: minutes);

  factory _Duration.unbounded(int? longestFinite) =>
      _Duration._(unbounded: true, minutes: longestFinite);
}
