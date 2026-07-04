import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/utils/image_url.dart';
import 'package:lumi_pass/common/utils/strip_html.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/service/analytics_service.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/class_item_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class BranchDetailPage extends StatefulWidget {
  const BranchDetailPage({super.key, required this.branch});

  final HomBranch branch;

  @override
  State<BranchDetailPage> createState() => _BranchDetailPageState();
}

class _BranchDetailPageState extends State<BranchDetailPage> {
  List<String> _galleryImages = [];
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  List<HomClass> _classes = [];
  bool _isLoadingClasses = true;
  String? _classesError;
  int _classesPage = 1;
  int _classesTotalPages = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _galleryImages = _resolveImagesFromBranch(widget.branch);
    _loadClasses();
    _startAutoSlide();
    final b = widget.branch;
    getIt<AnalyticsService>().logEvent(
      AnalyticsEvent.branchDetailViewed,
      params: {
        if (b.id != null) 'branch_id': b.id!,
        if (b.title != null) 'branch_title': b.title!,
        if (b.address != null) 'address': b.address!,
        if (b.distance != null) 'distance': b.distance!,
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<String> _resolveImagesFromBranch(HomBranch? branch) {
    final out = <String>[];
    if (branch == null) return out;
    for (final s in branch.images ?? const []) {
      final url = sanitizeImageUrl(s);
      if (url != null && url.isNotEmpty && !out.contains(url)) out.add(url);
    }
    final cover = sanitizeImageUrl(branch.image);
    if (cover != null && cover.isNotEmpty && !out.contains(cover)) {
      out.insert(0, cover);
    }
    return out;
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

  Future<void> _loadClasses({int page = 1, bool append = false}) async {
    final branchId = widget.branch.id;
    if (branchId == null) return;

    if (!append) {
      setState(() => _isLoadingClasses = true);
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      final repo = getIt<HomeRepository>();
      final result = await repo.getBranchClasses(
        branchId,
        page: page,
        limit: 10,
      );
      if (mounted) {
        setState(() {
          if (append) {
            _classes.addAll(result.classes);
          } else {
            _classes = result.classes;
          }
          _classesPage = page;
          _classesTotalPages = result.classesPages;
          _classesError = null;
          _isLoadingClasses = false;
          _isLoadingMore = false;

          // If the navigation-passed branch had no images, backfill from the
          // first class's branch — the classes endpoint returns full branch
          // data including image/images on each class object.
          if (!append && _galleryImages.isEmpty && _classes.isNotEmpty) {
            final enriched = _resolveImagesFromBranch(_classes.first.branch);
            if (enriched.isNotEmpty) _galleryImages = enriched;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _classesError = 'branch_failed_classes'.tr();
          _isLoadingClasses = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  String _formatDistance(double? meters) {
    if (meters == null || meters <= 0) return '';
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).round()} km';
  }

  Future<void> _openGoogleMaps() async {
    final lat = widget.branch.latitude;
    final lng = widget.branch.longitude;
    if (lat == null || lng == null) return;

    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final branch = widget.branch;
    final primary = context.colors.primary;
    final distance = _formatDistance(branch.distance);

    return Scaffold(
      backgroundColor: context.colors.window,
      body: CustomScrollView(
        slivers: [
          // Hero Image
          SliverToBoxAdapter(
            child: SizedBox(
              width: 1.sw,
              height: 300.h,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(28.r),
                        bottomRight: Radius.circular(28.r),
                      ),
                      child: _galleryImages.isNotEmpty
                          ? PageView.builder(
                              controller: _pageController,
                              itemCount: _galleryImages.length,
                              onPageChanged: (i) =>
                                  setState(() => _currentImageIndex = i),
                              itemBuilder: (_, i) => CachedNetworkImage(
                                imageUrl: _galleryImages[i],
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Shimmer.fromColors(
                                  baseColor: Colors.grey.shade200,
                                  highlightColor: Colors.grey.shade50,
                                  child: Container(color: Colors.white),
                                ),
                                errorWidget: (_, __, ___) => Shimmer.fromColors(
                                  baseColor: Colors.grey.shade200,
                                  highlightColor: Colors.grey.shade50,
                                  child: Container(color: Colors.white),
                                ),
                              ),
                            )
                          : Shimmer.fromColors(
                              baseColor: Colors.grey.shade200,
                              highlightColor: Colors.grey.shade50,
                              child: Container(color: Colors.white),
                            ),
                    ),
                  ),

                  // Gradient overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(28.r),
                          bottomRight: Radius.circular(28.r),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.15),
                            Colors.black.withOpacity(0.15),
                            Colors.black.withOpacity(0.55),
                          ],
                          stops: const [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Back button
                  Positioned(
                    top: MediaQuery.of(context).viewPadding.top + 10.h,
                    left: 16.w,
                    child: _CircleButton(
                      onTap: () => context.router.pop(),
                      child: Icon(Icons.arrow_back_ios_new,
                          color: primary, size: 18.w),
                    ),
                  ),

                  // Image indicators
                  if (_galleryImages.length > 1)
                    Positioned(
                      bottom: 60.h,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _galleryImages.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _currentImageIndex == i ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _currentImageIndex == i
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.45),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Title overlay
                  Positioned(
                    bottom: 16.h,
                    left: 20.w,
                    right: 20.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.28),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: (branch.title ?? "")
                          .s(20)
                          .w(700)
                          .c(Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Body Content
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                20.kh,

                // Address card
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(18.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3C539A).withOpacity(0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48.w,
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Center(
                          child: Icon(Icons.location_on_rounded,
                              color: primary, size: 24.w),
                        ),
                      ),
                      12.kw,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            'branch_address'
                                .tr()
                                .s(12)
                                .w(600)
                                .c(const Color(0xFF6B7280)),
                            4.kh,
                            (branch.address ?? 'branch_no_address'.tr())
                                .s(14)
                                .w(500)
                                .c(primary),
                            if ((branch.landmark ?? '').isNotEmpty) ...[
                              4.kh,
                              Row(
                                children: [
                                  Icon(Icons.place_outlined,
                                      size: 13.w,
                                      color: const Color(0xFF6B7280)),
                                  4.kw,
                                  Expanded(
                                    child: Text(
                                      branch.landmark!,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: const Color(0xFF6B7280),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Distance & Maps card
                if (branch.latitude != null && branch.longitude != null) ...[
                  12.kh,
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(18.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3C539A).withOpacity(0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48.w,
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Center(
                            child: Icon(Icons.map_rounded,
                                color: const Color(0xFF6366F1), size: 24.w),
                          ),
                        ),
                        12.kw,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              'branch_view_on_maps'
                                  .tr()
                                  .s(12)
                                  .w(600)
                                  .c(const Color(0xFF6B7280)),
                              8.kh,
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: _openGoogleMaps,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12.w, vertical: 6.h),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEEF2FF),
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                        border: Border.all(
                                            color: const Color(0xFFE0E7FF)),
                                      ),
                                      child: 'branch_build_route'
                                          .tr()
                                          .s(12)
                                          .w(600)
                                          .c(const Color(0xFF4F46E5)),
                                    ),
                                  ),
                                  if (distance.isNotEmpty) ...[
                                    8.kw,
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8.w, vertical: 6.h),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                        border: Border.all(
                                            color: Colors.grey.shade200),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.navigation_outlined,
                                              size: 12.sp,
                                              color: const Color(0xFF374151)),
                                          4.kw,
                                          Text(
                                            distance,
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF374151),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                20.kh,

                // About section
                if (stripHtml(branch.description).isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(18.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3C539A).withOpacity(0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
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
                                color: primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Center(
                                child: Icon(Icons.info_outline_rounded,
                                    color: primary, size: 18.w),
                              ),
                            ),
                            10.kw,
                            'branch_about'
                                .tr()
                                .s(16)
                                .w(700)
                                .c(const Color(0xFF1E293B)),
                          ],
                        ),
                        14.kh,
                        Text(
                          stripHtml(branch.description),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF4B5563),
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                if (stripHtml(branch.description).isNotEmpty) 20.kh,

                // Classes section header
                'branch_classes'.tr().s(18).w(700).c(const Color(0xFF1E293B)),
                12.kh,
              ]),
            ),
          ),

          // Classes list
          if (_isLoadingClasses)
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, __) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey.shade200,
                      highlightColor: Colors.grey.shade50,
                      child: Container(
                        height: 120.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                      ),
                    ),
                  ),
                  childCount: 3,
                ),
              ),
            )
          else if (_classesError != null)
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              sliver: SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Column(
                    children: [
                      Text(_classesError!,
                          style: TextStyle(
                              fontSize: 14.sp, color: const Color(0xFFDC2626))),
                      12.kh,
                      GestureDetector(
                        onTap: () => _loadClasses(),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                                color: primary.withOpacity(0.2)),
                          ),
                          child: 'booking_retry'.tr().s(14).w(600).c(primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (_classes.isEmpty)
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              sliver: SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3C539A).withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: 'branch_no_classes'
                      .tr()
                      .s(14)
                      .w(500)
                      .c(const Color(0xFF6B7280)),
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 0.w),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: ClassItemWidget(
                        homClass: _classes[index],
                        width: 1.sw - 32.w,
                        imageHeight: 190.h,
                        wrapBranch: false,
                        showDescription: false,
                      ),
                    );
                  },
                  childCount: _classes.length,
                ),
              ),
            ),

          // Load more button
          if (!_isLoadingClasses &&
              _classesError == null &&
              _classesPage < _classesTotalPages)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: GestureDetector(
                  onTap: _isLoadingMore
                      ? null
                      : () =>
                          _loadClasses(page: _classesPage + 1, append: true),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(14.r),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isLoadingMore
                          ? SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : 'branch_load_more_classes'
                              .tr()
                              .s(14)
                              .w(600)
                              .c(Colors.white),
                    ),
                  ),
                ),
              ),
            ),

          // Bottom spacing
          SliverToBoxAdapter(child: SizedBox(height: 32.h)),
        ],
      ),
    );
  }
}

// Circle button (reused pattern from ClassDetailPage)
class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.onTap, required this.child});
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.85),
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: onTap,
        child: Container(
          width: 42.w,
          height: 42.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

