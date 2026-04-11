import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/service/photo_service.dart';
import 'package:lumi_pass/data/service/remote_config_service.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/widgets/choose_child_bottomsheet.dart';
import 'package:shimmer/shimmer.dart';

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

  @override
  void initState() {
    super.initState();
    _loadImages();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadImages() async {
    final classId = widget.classModel.id;
    if (classId == null) {
      setState(() => _isLoadingImages = false);
      return;
    }

    // Set fallback immediately
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
    switch (widget.classModel.gender?.toUpperCase()) {
      case 'MALE':
        return 'Boys only';
      case 'FEMALE':
        return 'Girls only';
      default:
        return 'Everyone';
    }
  }

  Color _getGenderColor() {
    switch (widget.classModel.gender?.toUpperCase()) {
      case 'MALE':
        return const Color(0xFF3B82F6);
      case 'FEMALE':
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFFA652C7);
    }
  }

  IconData _getGenderIcon() {
    switch (widget.classModel.gender?.toUpperCase()) {
      case 'MALE':
        return Icons.male_rounded;
      case 'FEMALE':
        return Icons.female_rounded;
      default:
        return Icons.people_rounded;
    }
  }

  String _formatDuration(int? minutes) {
    if (minutes == null || minutes == 0) return '0 min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h} hour${h > 1 ? 's' : ''}';
    return '$m min';
  }

  String _formatDistance(double? distanceMeters) {
    if (distanceMeters == null || distanceMeters <= 0) return '';
    if (distanceMeters < 1000) {
      return '${distanceMeters.round()} m';
    }
    final km = distanceMeters / 1000;
    return '${km.toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final classModel = widget.classModel;
    final primary = context.colors.primary;

    return Scaffold(
      backgroundColor: context.colors.window,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ─── Hero Image Section ───
              SliverToBoxAdapter(
                child: SizedBox(
                  width: 1.sw,
                  height: 300.h,
                  child: Stack(
                    children: [
                      // Image carousel
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
                                  itemBuilder: (_, i) => SizedBox.expand(
                                    child: CachedNetworkImage(
                                      imageUrl: _galleryImages[i],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      placeholder: (_, __) =>
                                          Shimmer.fromColors(
                                        baseColor: Colors.grey.shade200,
                                        highlightColor: Colors.grey.shade50,
                                        child: Container(color: Colors.white),
                                      ),
                                      errorWidget: (_, __, ___) => Assets
                                          .images.defaultImage
                                          .image(
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
                                  : Assets.images.defaultImage
                                      .image(
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
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

                      // Favorite button
                      Positioned(
                        top: MediaQuery.of(context).viewPadding.top + 10.h,
                        right: 16.w,
                        child: _CircleButton(
                          onTap: () =>
                              setState(() => _isFavorite = !_isFavorite),
                          child: Icon(
                            _isFavorite
                                ? CupertinoIcons.heart_fill
                                : CupertinoIcons.heart,
                            color: _isFavorite
                                ? const Color(0xFFEF4444)
                                : primary,
                            size: 20.w,
                          ),
                        ),
                      ),

                      // Category badge
                      if (classModel.category != null &&
                          classModel.category!.isNotEmpty)
                        Positioned(
                          top: MediaQuery.of(context).viewPadding.top + 14.h,
                          left: 68.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 14.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: (classModel.category ?? "")
                                .s(12)
                                .w(600)
                                .c(primary),
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
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 3),
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
                          child: (classModel.title ?? "")
                              .s(20)
                              .w(700)
                              .c(Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Body Content ───
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    16.kh,

                    // Quick info chips
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        _QuickChip(
                          icon: Icons.child_care_rounded,
                          label:
                              "${classModel.minAge ?? 0}-${classModel.maxAge ?? 0} y.o",
                          bgColor: const Color(0xFFF0FDF4),
                          iconColor: const Color(0xFF16A34A),
                          textColor: const Color(0xFF15803D),
                        ),
                        _QuickChip(
                          icon: Icons.access_time_rounded,
                          label: _formatDuration(classModel.duration),
                          bgColor: const Color(0xFFF8FAFC),
                          iconColor: const Color(0xFF475569),
                          textColor: const Color(0xFF475569),
                        ),
                        _QuickChip(
                          icon: _getGenderIcon(),
                          label: _getGenderText(),
                          bgColor: _getGenderColor().withOpacity(0.08),
                          iconColor: _getGenderColor(),
                          textColor: _getGenderColor(),
                        ),
                      ],
                    ),

                    20.kh,

                    // Location card
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
                              child: Assets.icons.locationPrimary.svg(
                                width: 22.w,
                                height: 22.h,
                              ),
                            ),
                          ),
                          12.kw,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                (classModel.branch?.title ?? "")
                                    .s(14)
                                    .w(600)
                                    .c(const Color(0xFF1E293B)),
                                4.kh,
                                (classModel.branch?.address ?? "")
                                    .s(12)
                                    .w(400)
                                    .c(const Color(0xFF64748B)),
                              ],
                            ),
                          ),
                          if (_formatDistance(classModel.branch?.distance ??
                              classModel.distance).isNotEmpty) ...[
                            8.kw,
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                _formatDistance(classModel.branch?.distance ??
                                    classModel.distance),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF312E81),
                                ),
                              ),
                            ),
                          ] else
                            Icon(
                              CupertinoIcons.chevron_right,
                              size: 16.w,
                              color: const Color(0xFF94A3B8),
                            ),
                        ],
                      ),
                    ),

                    20.kh,

                    // // Duration & Gender detail cards
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: _DetailCard(
                    //         icon: Assets.icons.time.svg(
                    //             width: 20.w, height: 20.h),
                    //         iconBg: const Color(0xFF3B82F6).withOpacity(0.1),
                    //         label: "Duration",
                    //         labelColor: const Color(0xFF64748B),
                    //         value: _formatDuration(classModel.duration),
                    //         valueColor: const Color(0xFF1E293B),
                    //       ),
                    //     ),
                    //     12.kw,
                    //     Expanded(
                    //       child: _DetailCard(
                    //         icon: Assets.icons.availablitiy.svg(
                    //             width: 20.w, height: 20.h),
                    //         iconBg: _getGenderColor().withOpacity(0.1),
                    //         label: "Gender & Age",
                    //         labelColor: const Color(0xFF64748B),
                    //         value: _getGenderText(),
                    //         valueColor: const Color(0xFF1E293B),
                    //         subtitle:
                    //             "${classModel.minAge ?? 0}-${classModel.maxAge ?? 0} years old",
                    //         subtitleColor: _getGenderColor(),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    //
                    // 24.kh,

                    // About section
                    if ((classModel.description ?? "").isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(18.r),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(0xFF3C539A).withOpacity(0.08),
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
                                    child: Icon(
                                      Icons.info_outline_rounded,
                                      color: primary,
                                      size: 18.w,
                                    ),
                                  ),
                                ),
                                10.kw,
                                "About this class"
                                    .s(16)
                                    .w(700)
                                    .c(const Color(0xFF1E293B)),
                              ],
                            ),
                            14.kh,
                            Text(
                              classModel.description ?? "",
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

                    // Bottom spacing for CTA
                    120.kh,
                  ]),
                ),
              ),
            ],
          ),

          // ─── Sticky CTA Button ───
          if (!RemoteConfigService.instance.isInReview)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  left: 16.w,
                  right: 16.w,
                  bottom: MediaQuery.of(context).viewPadding.bottom + 16.h,
                  top: 20.h,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      context.colors.window.withOpacity(0),
                      context.colors.window.withOpacity(0.95),
                      context.colors.window,
                    ],
                    stops: const [0.0, 0.35, 0.6],
                  ),
                ),
                child: Material(
                  color: primary,
                  borderRadius: BorderRadius.circular(18.r),
                  elevation: 0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18.r),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (context) {
                          return ChooseChildBottomsheet(
                            classId: classModel.id,
                          );
                        },
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18.r),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.34),
                            blurRadius: 26,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          "Book for ${classModel.price ?? 0}"
                              .s(16)
                              .w(700)
                              .c(Colors.white),
                          8.kw,
                          Assets.icons.coinLumi
                              .image(width: 22.w, height: 22.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Circle Button (back/fav) ───

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

// ─── Quick Info Chip ───

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.iconColor,
    required this.textColor,
  });

  final IconData icon;
  final String label;
  final Color bgColor;
  final Color iconColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.w, color: iconColor),
          6.kw,
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Detail Card ───

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.icon,
    required this.iconBg,
    required this.label,
    required this.labelColor,
    required this.value,
    required this.valueColor,
    this.subtitle,
    this.subtitleColor,
  });

  final Widget icon;
  final Color iconBg;
  final String label;
  final Color labelColor;
  final String value;
  final Color valueColor;
  final String? subtitle;
  final Color? subtitleColor;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(child: icon),
          ),
          10.kh,
          label.s(11).w(500).c(labelColor),
          4.kh,
          value.s(14).w(700).c(valueColor),
          if (subtitle != null) ...[
            2.kh,
            subtitle!.s(12).w(500).c(subtitleColor ?? labelColor),
          ],
        ],
      ),
    );
  }
}
