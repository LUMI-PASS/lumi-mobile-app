import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:lumi_pass/data/service/photo_service.dart';
import 'package:lumi_pass/data/service/remote_config_service.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/widgets/booking_bottomsheet.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────
const _brand = Color(0xFF6C4EF2);
const _brandDark = Color(0xFF4A2FD4);
const _brandLight = Color(0xFFEDE8FF);
const _cream = Color(0xFFFDFAF5);
const _border = Color(0xFFE8E4F6);
const _navy = Color(0xFF0E0C2B);
const _textColor = Color(0xFF1A1535);
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

  @override
  void initState() {
    super.initState();
    _loadImages();
    _loadFull();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadFull() async {
    final id = widget.classModel.id;
    if (id == null) return;
    try {
      final full = await getIt<OrdersApi>().getClassFull(id);
      if (!mounted) return;
      setState(() => _full = full);
    } catch (_) {
      // Soft-fail: keep base HomClass info visible.
    }
  }

  Future<void> _loadImages() async {
    final classId = widget.classModel.id;
    if (classId == null) {
      setState(() => _isLoadingImages = false);
      return;
    }

    if (widget.classModel.hasPhoto == true) {
      setState(() {
        _galleryImages = [PhotoService.getImageUrl(classId)];
      });
    }

    try {
      final photos =
          await PhotoService.instance.getClassPhotos(classId, limit: 5);
      if (mounted && photos.isNotEmpty) {
        setState(() {
          _galleryImages = photos;
          _isLoadingImages = false;
        });
        return;
      }
    } catch (_) {}

    if (mounted) setState(() => _isLoadingImages = false);
  }

  void _startAutoSlide() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted || _galleryImages.length <= 1) return;
      final next = (_currentImageIndex + 1) % _galleryImages.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
      _startAutoSlide();
    });
  }

  String _getGenderText() {
    switch ((_full?.gender ?? widget.classModel.gender)?.toUpperCase()) {
      case 'MALE':
        return 'Faqat o\'g\'il bolalar';
      case 'FEMALE':
        return 'Faqat qizlar';
      default:
        return 'Hamma uchun';
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

  String _formatDuration(int? minutes) {
    if (minutes == null || minutes == 0) return '—';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h} soat';
    return '$m min';
  }

  /// Effective duration: prefer list-level field, then derive max from ageTiers.
  int? _effectiveDuration(ClassFullModel? full) {
    final listMin = widget.classModel.duration;
    if (listMin != null && listMin > 0) return listMin;
    if (full == null) return listMin;
    final finite = full.ageTiers
        .expand((t) => t.durations)
        .where((d) => d.duration != null && d.duration! > 0)
        .map((d) => d.duration!)
        .toList();
    if (finite.isNotEmpty) return finite.reduce((a, b) => a > b ? a : b);
    return listMin;
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

  void _openBookingSheet() {
    final full = _full;
    if (full == null ||
        (full.pricesSummary.isEmpty && full.ageTiers.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Narxlar yuklanmoqda, iltimos kuting')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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
    final statusBarH = MediaQuery.of(context).viewPadding.top;
    final safeBottom = MediaQuery.of(context).viewPadding.bottom;

    final categoryName = _getCategoryName();
    final branchTitle = full?.branch?.title ?? classModel.branch?.title;
    final branchAddress =
        (full?.branch?.address.isNotEmpty == true)
            ? _localized(full!.branch!.address)
            : classModel.branch?.address;
    final branchLandmark = full?.branch?.landmark;
    final distanceStr =
        _formatDistance(classModel.branch?.distance ?? classModel.distance);
    final languages = (full?.activityLanguages ?? []);
    final hasMap =
        full?.branch?.lat != null && full?.branch?.lng != null;

    return Scaffold(
      backgroundColor: _cream,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ─── [1] Hero image section ───────────────────────────────────
              // Status bar spacer for floating buttons
              SliverToBoxAdapter(
                child: SizedBox(height: statusBarH + 64.h),
              ),

              // Hero image card with rounded borders
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Stack(
                        children: [
                          // Gallery images
                          Positioned.fill(
                            child: _galleryImages.isNotEmpty
                                ? PageView.builder(
                                    controller: _pageController,
                                    itemCount: _galleryImages.length,
                                    onPageChanged: (i) => setState(
                                        () => _currentImageIndex = i),
                                    itemBuilder: (_, i) =>
                                        CachedNetworkImage(
                                      imageUrl: _galleryImages[i],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      placeholder: (_, __) =>
                                          Shimmer.fromColors(
                                        baseColor: Colors.grey.shade200,
                                        highlightColor:
                                            Colors.grey.shade50,
                                        child:
                                            Container(color: Colors.white),
                                      ),
                                      errorWidget: (_, __, ___) =>
                                          Assets.images.defaultImage
                                              .image(
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                                  )
                                : _isLoadingImages
                                    ? Shimmer.fromColors(
                                        baseColor: Colors.grey.shade200,
                                        highlightColor:
                                            Colors.grey.shade50,
                                        child: Container(
                                            color: Colors.white),
                                      )
                                    : Assets.images.defaultImage.image(
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                          ),

                          // Bottom vignette
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    const Color(0xAA0E0C2B),
                                  ],
                                  stops: const [0.5, 1.0],
                                ),
                              ),
                            ),
                          ),

                          // Page indicators (bottom-center)
                          if (_galleryImages.length > 1)
                            Positioned(
                              bottom: 10.h,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: List.generate(
                                  _galleryImages.length,
                                  (i) => AnimatedContainer(
                                    duration: const Duration(
                                        milliseconds: 300),
                                    margin:
                                        const EdgeInsets.symmetric(
                                            horizontal: 3),
                                    width:
                                        _currentImageIndex == i ? 16 : 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: _currentImageIndex == i
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.5),
                                      borderRadius:
                                          BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // Category chip (bottom-left)
                          if (categoryName.isNotEmpty)
                            Positioned(
                              bottom: 10.h,
                              left: 10.w,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 5.h),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white.withOpacity(0.2),
                                  borderRadius:
                                      BorderRadius.circular(20.r),
                                  border: Border.all(
                                      color: Colors.white
                                          .withOpacity(0.4)),
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
                ),
              ),

              // ─── [2] Info card (overlaps hero by -24px) ──────────────────
              // Info card – no overlap, standard margin below hero
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [_cardShadow],
                    ),
                    padding: EdgeInsets.all(18.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category chip
                        if (categoryName.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: Wrap(
                              spacing: 8.w,
                              runSpacing: 6.h,
                              children: [
                                _PillChip(
                                  label: categoryName,
                                  bgColor: _brandLight,
                                  textColor: _brandDark,
                                ),
                              ],
                            ),
                          ),

                        // Title
                        Text(
                          classModel.title ?? '',
                          style: IOSText.largeTitle(),
                        ),

                        12.kh,

                        // Branch / location section
                        if (branchTitle != null && branchTitle.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 30.w,
                                    height: 30.h,
                                    decoration: BoxDecoration(
                                      color: _brandLight,
                                      borderRadius:
                                          BorderRadius.circular(8.r),
                                    ),
                                    child: Icon(Icons.apartment_rounded,
                                        color: _brand, size: 16.sp),
                                  ),
                                  8.kw,
                                  Expanded(
                                    child: Text(
                                      branchTitle,
                                      style: IOSText.headline(),
                                    ),
                                  ),
                                  if (distanceStr.isNotEmpty) ...[
                                    6.kw,
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8.w, vertical: 4.h),
                                      decoration: BoxDecoration(
                                        color: _brandLight,
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                      ),
                                      child: Text(
                                        distanceStr,
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w700,
                                          color: _brandDark,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (branchAddress != null &&
                                  branchAddress.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 4.h, left: 38.w),
                                  child: Row(
                                    children: [
                                      Icon(Icons.location_on_outlined,
                                          size: 13.sp, color: _muted),
                                      4.kw,
                                      Expanded(
                                        child: Text(
                                          branchAddress,
                                          style: IOSText.subhead(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (branchLandmark != null &&
                                  branchLandmark.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 2.h, left: 38.w),
                                  child: Row(
                                    children: [
                                      Icon(Icons.near_me_outlined,
                                          size: 13.sp, color: _muted),
                                      4.kw,
                                      Expanded(
                                        child: Text(
                                          branchLandmark,
                                          style: IOSText.subhead().copyWith(
                                            fontStyle: FontStyle.italic,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (hasMap)
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 8.h, left: 38.w),
                                  child: GestureDetector(
                                    onTap: () async {
                                      final f = full!;
                                      final lat = f.branch!.lat!;
                                      final lng = f.branch!.lng!;
                                      final uri = Uri.parse(
                                          'https://maps.google.com/?q=$lat,$lng');
                                      await launchUrl(uri,
                                          mode: LaunchMode
                                              .externalApplication);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12.w, vertical: 7.h),
                                      decoration: BoxDecoration(
                                        color: _brandLight,
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.map_rounded,
                                              size: 13.sp,
                                              color: _brandDark),
                                          5.kw,
                                          Text(
                                            "Xaritada ko'rish",
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w600,
                                              color: _brandDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),

                        14.kh,
                        Divider(color: _border, height: 1),
                        14.kh,

                        // Stats row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _StatItem(
                              icon: Icons.access_time_rounded,
                              iconColor: _brand,
                              value: _formatDuration(_effectiveDuration(full)),
                              label: 'Davomiylik',
                            ),
                            _StatItem(
                              icon: Icons.child_care_rounded,
                              iconColor: _success,
                              value:
                                  '${classModel.minAge ?? full?.ageFrom ?? 0}–${classModel.maxAge ?? full?.ageTo ?? 0} yosh',
                              label: 'Yosh',
                            ),
                            _StatItem(
                              icon: _getGenderIcon(),
                              iconColor: _getGenderColor(),
                              value: _getGenderText(),
                              label: 'Jinsi',
                            ),
                            if (languages.isNotEmpty)
                              _StatItem(
                                icon: Icons.translate_rounded,
                                iconColor: _muted,
                                value: languages.join('/'),
                                label: 'Til',
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── [3] Content sections ─────────────────────────────────────
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Loading indicator
                    if (full == null)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.h),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: _brand,
                            strokeWidth: 2.5,
                          ),
                        ),
                      ),

                    // Prices section
                    if (full != null &&
                        (full.hasAgeTierPricing ||
                            full.pricesSummary.isNotEmpty)) ...[
                      _DetailSection(
                        title: full.hasAgePricing
                            ? 'Yoshga qarab narxlar'
                            : 'Narxlar',
                        icon: Icons.sell_rounded,
                        iconColor: _brand,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (full.hasMultiplePrices)
                              Padding(
                                padding: EdgeInsets.only(bottom: 10.h),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline_rounded,
                                        size: 13.sp, color: _muted),
                                    5.kw,
                                    Expanded(
                                      child: Text(
                                        'Narx bolaning yoshiga qarab farqlanadi',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: _muted,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // ── New nested age-tier format ──
                            if (full.hasAgeTierPricing)
                              ...List.generate(full.ageTiers.length, (i) {
                                final tier = full.ageTiers[i];
                                final isLastTier =
                                    i == full.ageTiers.length - 1;
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    // Age tier header
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
                                    // Duration rows for this tier
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
                                                  style: IOSText.bodyEmphasized(
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
                              // ── Legacy flat format ──
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

                    // About section
                    if (full != null &&
                        _cleanHtml(_localized(full.description))
                            .isNotEmpty) ...[
                      _DetailSection(
                        title: 'Tadbir haqida',
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
                        title: 'Tadbir haqida',
                        icon: Icons.info_outline_rounded,
                        iconColor: _brand,
                        child: Text(
                          _cleanHtml(classModel.description!),
                          style: IOSText.body(color: IOSText.secondary),
                        ),
                      ),
                      16.kh,
                    ],

                    // Important notes
                    if (full != null &&
                        _cleanHtml(_localized(full.importantNotes))
                            .isNotEmpty) ...[
                      _DetailSection(
                        title: 'Muhim eslatmalar',
                        icon: Icons.priority_high_rounded,
                        iconColor: const Color(0xFFD97706),
                        child: Text(
                          _cleanHtml(_localized(full.importantNotes)),
                          style: IOSText.body(color: IOSText.secondary),
                        ),
                      ),
                      16.kh,
                    ],

                    // What to bring
                    if (full != null &&
                        _cleanHtml(_localized(full.requiredItems))
                            .isNotEmpty) ...[
                      _DetailSection(
                        title: 'Nima olib kelish kerak',
                        icon: Icons.checklist_rounded,
                        iconColor: const Color(0xFF0E7490),
                        child: Text(
                          _cleanHtml(_localized(full.requiredItems)),
                          style: IOSText.body(color: IOSText.secondary),
                        ),
                      ),
                      16.kh,
                    ],

                    // Languages
                    if (full != null && full.activityLanguages.isNotEmpty) ...[
                      _DetailSection(
                        title: 'Ta\'lim tili',
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
                                    borderRadius: BorderRadius.circular(10.r),
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

                    // Schedule
                    if (full != null && full.schedule.isNotEmpty) ...[
                      _DetailSection(
                        title: 'Dars jadvali',
                        icon: Icons.calendar_today_rounded,
                        iconColor: const Color(0xFF0EA5E9),
                        child: Column(
                          children: full.schedule
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

                    // Working hours
                    if (full != null && full.workHours.isNotEmpty) ...[
                      _DetailSection(
                        title: 'Ish vaqti',
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

                    // Video card
                    if (full?.effectiveVideoUrl != null) ...[
                      _VideoCard(onTap: () async {
                        final url =
                            Uri.parse(full!.effectiveVideoUrl!);
                        await launchUrl(url,
                            mode: LaunchMode.externalApplication);
                      }),
                      16.kh,
                    ],

                    120.kh,
                  ]),
                ),
              ),
            ],
          ),

          // ─── Fixed top action buttons ─────────────────────────────────────
          Positioned(
            top: statusBarH + 8.h,
            left: 16.w,
            right: 16.w,
            child: Row(
              children: [
                _FrostedCircleButton(
                  onTap: () => context.router.pop(),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: _navy,
                    size: 18,
                  ),
                ),
                const Spacer(),
                _FrostedCircleButton(
                  onTap: () {},
                  child: const Icon(
                    Icons.share_rounded,
                    color: _navy,
                    size: 18,
                  ),
                ),
                8.kw,
                _FrostedCircleButton(
                  onTap: () => setState(() => _isFavorite = !_isFavorite),
                  child: Icon(
                    _isFavorite
                        ? CupertinoIcons.heart_fill
                        : CupertinoIcons.heart,
                    color:
                        _isFavorite ? const Color(0xFFEF4444) : _navy,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),

          // ─── Positioned CTA bar at bottom ─────────────────────────────────
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
                    // Loading shimmer for CTA
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
                            label: 'Yuklanmoqda...',
                            enabled: false,
                            onTap: null,
                          )
                        : Row(
                            children: [
                              // Price column
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    full.priceMin.toRawUzsPrice(),
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w900,
                                      color: _brandDark,
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                              16.kw,
                              // CTA button
                              Expanded(
                                child: _CtaGradientButton(
                                  label: 'Chipta sotib olish',
                                  onTap: _openBookingSheet,
                                ),
                              ),
                            ],
                          ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Frosted circle button (hero top buttons) ──────────────────────────────

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
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: onTap,
          child: Center(child: child),
        ),
      ),
    );
  }
}

// ─── Pill chip ─────────────────────────────────────────────────────────────

class _PillChip extends StatelessWidget {
  const _PillChip({
    required this.label,
    required this.bgColor,
    required this.textColor,
  });
  final String label;
  final Color bgColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}

// ─── Stat item ─────────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18.sp, color: iconColor),
        4.kh,
        Text(
          value,
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
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: _muted,
          ),
        ),
      ],
    );
  }
}

// ─── Detail section ────────────────────────────────────────────────────────

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
        borderRadius: BorderRadius.circular(18.r),
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

// ─── Video card ────────────────────────────────────────────────────────────

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
          borderRadius: BorderRadius.circular(18.r),
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
                border:
                    Border.all(color: Colors.white.withOpacity(0.35)),
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
                    'Video ko\'rish',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  2.kh,
                  Text(
                    'Shorts sifatida tomosha qiling',
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

// ─── CTA button (disabled state) ──────────────────────────────────────────

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
          backgroundColor:
              enabled ? _brandDark : const Color(0xFFCBD5E1),
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

// ─── CTA gradient button ──────────────────────────────────────────────────

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
