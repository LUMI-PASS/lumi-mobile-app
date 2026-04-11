import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/widget/container_3d.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/service/photo_service.dart';
import 'package:shimmer/shimmer.dart';

class ClassItemWidget extends StatefulWidget {
  const ClassItemWidget({
    super.key,
    required this.homClass,
    this.width,
    this.showDescription = true,
    this.wrapBranch = true,
  });

  final HomClass? homClass;
  final double? width;
  final bool showDescription;
  final bool wrapBranch;

  @override
  State<ClassItemWidget> createState() => _ClassItemWidgetState();
}

class _ClassItemWidgetState extends State<ClassItemWidget> {
  String? _resolvedImageUrl;
  bool _isLoadingImage = true;

  @override
  void initState() {
    super.initState();
    _resolveImage();
  }

  @override
  void didUpdateWidget(ClassItemWidget old) {
    super.didUpdateWidget(old);
    if (old.homClass?.id != widget.homClass?.id) {
      _resolveImage();
    }
  }

  Future<void> _resolveImage() async {
    final classId = widget.homClass?.id;
    final hasPhoto = widget.homClass?.hasPhoto == true;

    // Set initial fallback
    final fallback =
        (hasPhoto && classId != null) ? PhotoService.getImageUrl(classId) : null;

    setState(() {
      _resolvedImageUrl = fallback;
      _isLoadingImage = true;
    });

    // Try to resolve optimized photo via API (like webapp)
    if (classId != null) {
      try {
        final photos =
            await PhotoService.instance.getClassPhotos(classId, limit: 1);
        if (mounted && photos.isNotEmpty) {
          setState(() {
            _resolvedImageUrl = photos.first;
            _isLoadingImage = false;
          });
          return;
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() => _isLoadingImage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hc = widget.homClass;
    final fullPrice = hc?.price;
    final trialPrice = hc?.trialPrice;
    final trialEnabled = hc?.trialEnabled ?? false;
    final showTrialSale = fullPrice != null &&
        trialPrice != null &&
        trialEnabled &&
        trialPrice.toDouble() < fullPrice.toDouble();

    final category = hc?.category ?? '';
    final duration = hc?.duration;
    final age = _formatAge(hc?.minAge, hc?.maxAge);

    return Container3d(
      onTap: () => context.router
          .push(ClassDetailRoute(classModel: hc ?? const HomClass())),
      width: widget.width ?? 1.sw * 0.68,
      margin: EdgeInsets.only(left: 16.w),
      padding: EdgeInsets.all(8.w),
      alignment: Alignment.topLeft,
      backgroundColor: Colors.white,
      borderColor: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(22.r),
      depth: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image with overlays
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: SizedBox(
              height: widget.wrapBranch ? 140.h : 160.h,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Shimmer placeholder shown while loading
                  if (_isLoadingImage && _resolvedImageUrl == null)
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade200,
                      highlightColor: Colors.grey.shade50,
                      child: Container(color: Colors.white),
                    ),
                  if (_resolvedImageUrl != null)
                    SizedBox.expand(
                      child: CachedNetworkImage(
                        imageUrl: _resolvedImageUrl!,
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
                    )
                  else if (!_isLoadingImage)
                    Assets.images.defaultImage.image(
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),

                  // Top-left chips (category + duration + gender)
                  Positioned(
                    left: 8.w,
                    top: 8.h,
                    right: 8.w,
                    child: Row(
                      children: [
                        if (category.isNotEmpty)
                          _buildChip(
                            text: category,
                            bgColor: Colors.white.withOpacity(0.75),
                            textColor: const Color(0xFFA652C7),
                            borderColor: Colors.white.withOpacity(0.8),
                          ),
                        if (category.isNotEmpty && duration != null) 4.kw,
                        if (duration != null)
                          _buildChip(
                            icon: Icons.access_time_rounded,
                            text: _formatDuration(duration),
                            bgColor:
                                const Color(0xFF21376D).withOpacity(0.65),
                            textColor: Colors.white,
                            borderColor: Colors.white.withOpacity(0.65),
                          ),
                        if (hc?.gender != null) ...[
                          4.kw,
                          _buildGenderChip(hc!.gender!),
                        ],
                      ],
                    ),
                  ),

                  // Price pill bottom-right
                  if (fullPrice != null)
                    Positioned(
                      right: 8.w,
                      bottom: 8.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border:
                              Border.all(color: const Color(0xFFA7F3D0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: showTrialSale
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$fullPrice',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600,
                                      decoration:
                                          TextDecoration.lineThrough,
                                      decorationThickness: 1.5,
                                    ),
                                  ),
                                  Assets.icons.coinLumi.image(
                                      width: 12.w, height: 12.h),
                                  8.kw,
                                  Text(
                                    '$trialPrice',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF047857),
                                    ),
                                  ),
                                  Assets.icons.coinLumi.image(
                                      width: 16.w, height: 16.h),
                                ],
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$fullPrice',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF2E3D5D),
                                    ),
                                  ),
                                  2.kw,
                                  Assets.icons.coinLumi.image(
                                      width: 16.w, height: 16.h),
                                ],
                              ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          8.kh,

          // Title
          Text(
            hc?.title ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2E3D5D),
            ),
          ),
          6.kh,

          // Branch badge + age row
          Row(
            children: [
              if (widget.showDescription &&
                  (hc?.branch?.title ?? '').isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 6.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F3FF).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8.r),
                    border:
                        Border.all(color: const Color(0xFFEDE9FE)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.apartment_rounded,
                          size: 12.sp,
                          color: const Color(0xFF6D28D9)),
                      4.kw,
                      Flexible(
                        child: Text(
                          hc!.branch!.title!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF6D28D9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (age != null) ...[
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 6.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_outline,
                          size: 12.sp,
                          color: const Color(0xFF16A34A)),
                      2.kw,
                      Text(
                        age,
                        style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF16A34A)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          8.kh,

          // Address + distance row
          if (hc?.branch?.address != null) ...[
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 14.sp,
                          color: const Color(0xFF312E81)
                              .withOpacity(0.9)),
                      4.kw,
                      Expanded(
                        child: Text(
                          hc!.branch!.address!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF312E81)
                                .withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_formatDistance(hc?.branch?.distance ?? hc?.distance).isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.navigation_outlined,
                          size: 12.sp,
                          color: const Color(0xFF312E81)
                              .withOpacity(0.9)),
                      2.kw,
                      Text(
                        _formatDistance(
                            hc?.branch?.distance ?? hc?.distance),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF312E81)
                              .withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChip({
    IconData? icon,
    required String text,
    required Color bgColor,
    required Color textColor,
    required Color borderColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12.sp, color: textColor),
            SizedBox(width: 4.w),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderChip(String gender) {
    final g = gender.toUpperCase();
    if (g == 'MALE') {
      return _buildChip(
        icon: Icons.male_rounded,
        text: 'Boys',
        bgColor: const Color(0xFF3B82F6).withOpacity(0.85),
        textColor: Colors.white,
        borderColor: Colors.white.withOpacity(0.65),
      );
    }
    if (g == 'FEMALE') {
      return _buildChip(
        icon: Icons.female_rounded,
        text: 'Girls',
        bgColor: const Color(0xFFEC4899).withOpacity(0.85),
        textColor: Colors.white,
        borderColor: Colors.white.withOpacity(0.65),
      );
    }
    // Both / All
    return _buildChip(
      icon: Icons.people_rounded,
      text: 'Both',
      bgColor: const Color(0xFF8B5CF6).withOpacity(0.85),
      textColor: Colors.white,
      borderColor: Colors.white.withOpacity(0.65),
    );
  }

  String? _formatAge(int? min, int? max) {
    if (min == null && max == null) return null;
    if (min != null && max != null) return '$min-$max y.o';
    if (min != null) return '$min+ y.o';
    return '≤$max y.o';
  }

  String _formatDuration(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }

  String _formatDistance(double? distanceMeters) {
    if (distanceMeters == null || distanceMeters <= 0) return '';
    if (distanceMeters < 1000) {
      return '${distanceMeters.round()} m';
    }
    final km = distanceMeters / 1000;
    return '${km.round()} km';
  }
}
