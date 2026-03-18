import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/constants/constants.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';

class ClassItemWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final imageUrl = homClass?.id != null
        ? '${Constants.assetsUrl}${homClass!.id}'
        : null;

    final fullPrice = homClass?.price;
    final trialPrice = homClass?.trialPrice;
    final trialEnabled = homClass?.trialEnabled ?? false;
    final showTrialSale = fullPrice != null &&
        trialPrice != null &&
        trialEnabled &&
        trialPrice.toDouble() < fullPrice.toDouble();

    final category = homClass?.category ?? '';
    final duration = homClass?.duration;
    final age = _formatAge(homClass?.minAge, homClass?.maxAge);

    return GestureDetector(
      onTap: () => context.router
          .push(ClassDetailRoute(classModel: homClass ?? const HomClass())),
      child: Container(
        width: width ?? 1.sw * 0.68,
        margin: EdgeInsets.only(left: 16.w),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: Colors.white.withOpacity(0.9)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3C539A).withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image with overlays
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: SizedBox(
                height: wrapBranch ? 140.h : 160.h,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (imageUrl != null)
                      CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade200,
                        ),
                        errorWidget: (context, error, stackTrace) =>
                            Assets.images.defaultImage.image(fit: BoxFit.cover),
                      )
                    else
                      Assets.images.defaultImage.image(fit: BoxFit.cover),

                    // Top-left chips (category + duration)
                    Positioned(
                      left: 8.w,
                      top: 8.h,
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
                              bgColor: const Color(0xFF21376D).withOpacity(0.65),
                              textColor: Colors.white,
                              borderColor: Colors.white.withOpacity(0.65),
                            ),
                        ],
                      ),
                    ),

                    // Price pill bottom-right
                    if (fullPrice != null)
                      Positioned(
                        right: 8.w,
                        bottom: 8.h,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
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
                                    // Old price (strikethrough)
                                    Text(
                                      '$fullPrice',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade600,
                                        decoration: TextDecoration.lineThrough,
                                        decorationThickness: 1.5,
                                      ),
                                    ),
                                    Assets.icons.coinLumi.image(width: 12.w, height: 12.h),
                                    8.kw,
                                    // Trial price
                                    Text(
                                      '$trialPrice',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF047857),
                                      ),
                                    ),
                                    Assets.icons.coinLumi.image(width: 16.w, height: 16.h),
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
                                    Assets.icons.coinLumi.image(width: 16.w, height: 16.h),
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
              homClass?.title ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2E3D5D),
              ),
            ),
            6.kh,

            // Branch badge + gender/age row
            Row(
              children: [
                if (showDescription && (homClass?.branch?.title ?? '').isNotEmpty)
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3FF).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: const Color(0xFFEDE9FE)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.apartment_rounded, size: 12.sp, color: const Color(0xFF6D28D9)),
                          4.kw,
                          Flexible(
                            child: Text(
                              homClass!.branch!.title!,
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
                  ),
                const Spacer(),
                if (age != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_outline, size: 12.sp, color: const Color(0xFF16A34A)),
                      2.kw,
                      Text(
                        age,
                        style: TextStyle(fontSize: 11.sp, color: const Color(0xFF16A34A)),
                      ),
                    ],
                  ),
              ],
            ),
            8.kh,

            // Address + distance row
            if (homClass?.branch?.address != null) ...[
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14.sp, color: const Color(0xFF312E81).withOpacity(0.9)),
                        4.kw,
                        Expanded(
                          child: Text(
                            homClass!.branch!.address!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF312E81).withOpacity(0.9),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (homClass?.branch?.distance != null || homClass?.distance != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.navigation_outlined, size: 12.sp, color: const Color(0xFF312E81).withOpacity(0.9)),
                        2.kw,
                        Text(
                          _formatDistance(homClass?.branch?.distance ?? homClass?.distance),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF312E81).withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ],
        ),
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

  String _formatDistance(double? distanceKm) {
    if (distanceKm == null) return '';
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).toInt()} m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }
}
