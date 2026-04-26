import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/utils/image_url.dart';
import 'package:lumi_pass/common/widget/container_3d.dart';
import 'package:lumi_pass/data/api_model/class_full/class_full_model.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:shimmer/shimmer.dart';

class ClassItemWidget extends StatefulWidget {
  const ClassItemWidget({
    super.key,
    required this.homClass,
    this.width,
    this.showDescription = true,
    this.wrapBranch = true,
    this.onViewAsReels,
  });

  final HomClass? homClass;
  final double? width;
  final bool showDescription;
  final bool wrapBranch;
  final VoidCallback? onViewAsReels;

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
    final url = sanitizeImageUrl(widget.homClass?.image);
    setState(() {
      _resolvedImageUrl = url;
      _isLoadingImage = false;
    });
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
      borderColor: const Color(0xFFE8E4F6),
      borderRadius: BorderRadius.circular(20.r),
      depth: 3,
      boxShadow: const [
        BoxShadow(
          color: Color(0x1A6C4EF2),
          blurRadius: 24,
          offset: Offset(0, 4),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image with overlays
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: AspectRatio(
              aspectRatio: 4 / 3,
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

                  // Top-left chips (category + gender) — no right constraint so video button doesn't overlap
                  Positioned(
                    left: 8.w,
                    top: 8.h,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (category.isNotEmpty)
                          _buildChip(
                            text: category,
                            bgColor: Colors.white.withOpacity(0.92),
                            textColor: const Color(0xFF4A2FD4),
                            borderColor: Colors.white.withOpacity(0.8),
                          ),
                        if (hc?.gender != null) ...[
                          4.kw,
                          _buildGenderChip(hc!.gender!),
                        ],
                      ],
                    ),
                  ),

                  // Video button (top-right) — taps open Shorts tab
                  if (widget.onViewAsReels != null)
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: widget.onViewAsReels,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFA652C7), Color(0xFFFF7093)],
                            ),
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFFA652C7).withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 16.sp,
                              ),
                              2.kw,
                              Text(
                                'Video',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Duration chip bottom-left with blur effect
                  if (duration != null)
                    Positioned(
                      left: 8.w,
                      bottom: 8.h,
                      child: _buildChip(
                        icon: Icons.access_time_rounded,
                        text: _formatDuration(duration),
                        bgColor: const Color(0x990E0C2B),
                        textColor: Colors.white,
                        borderColor: Colors.white.withOpacity(0.3),
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
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1535),
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

          // Price divider + row
          Builder(builder: (context) {
            final snap = ClassPricingCache.get(hc?.id);
            final effectivePrice = (snap != null && snap.priceMin > 0)
                ? snap.priceMin
                : (fullPrice ?? 0);
            if (effectivePrice <= 0) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                10.kh,
                Container(height: 1, color: const Color(0xFFE8E4F6)),
                10.kh,
                Row(
                  children: [
                    Expanded(
                      child: _buildInlinePrice(
                        fullPrice: fullPrice ?? 0,
                        trialPrice: trialPrice,
                        showTrialSale: showTrialSale,
                        snap: snap,
                      ),
                    ),
                    if (snap?.scheduleCount != null && snap!.scheduleCount! > 0)
                      _buildChip(
                        icon: Icons.event_repeat_rounded,
                        text: '${snap.scheduleCount} slots',
                        bgColor: const Color(0xFFEDE8FF),
                        textColor: const Color(0xFF6C4EF2),
                        borderColor: const Color(0xFFD6CDFF),
                      )
                    else
                      Text(
                        '1 ticket',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B6899),
                        ),
                      ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInlinePrice({
    required num fullPrice,
    required num? trialPrice,
    required bool showTrialSale,
    required ClassPricingSnapshot? snap,
  }) {
    // Always prefer snapshot price when available
    final effectivePrice =
        (snap != null && snap.priceMin > 0) ? snap.priceMin : fullPrice;
    final showFrom = snap != null &&
        (snap.hasMultiplePrices || snap.rangeCount > 1);

    if (showFrom) {
      return Text(
        'from ${effectivePrice.toRawUzsPrice()}',
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF4A2FD4),
        ),
      );
    }
    if (showTrialSale && trialPrice != null && trialPrice > 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            effectivePrice.toUzsPrice(),
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B6899),
              decoration: TextDecoration.lineThrough,
              decorationThickness: 1.5,
            ),
          ),
          6.kw,
          Text(
            trialPrice.toUzsPrice(),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF4A2FD4),
            ),
          ),
        ],
      );
    }
    return Text(
      effectivePrice.toRawUzsPrice(),
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w900,
        color: const Color(0xFF4A2FD4),
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
