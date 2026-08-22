import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/styles/ios_text_styles.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/utils/coupon_discount.dart';
import 'package:lumi_pass/common/utils/image_url.dart';
import 'package:lumi_pass/common/widget/container_3d.dart';
import 'package:lumi_pass/data/api_model/class_full/class_full_model.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/presentation/app/cubit/app_cubit.dart';
import 'package:lumi_pass/presentation/app/cubit/app_state.dart';
import 'package:shimmer/shimmer.dart';

class ClassItemWidget extends StatefulWidget {
  const ClassItemWidget({
    super.key,
    required this.homClass,
    this.width,
    this.imageHeight,
    this.showDescription = true,
    this.wrapBranch = true,
    this.onViewAsReels,
  });

  final HomClass? homClass;
  final double? width;
  final double? imageHeight;
  final bool showDescription;
  final bool wrapBranch;
  final VoidCallback? onViewAsReels;

  @override
  State<ClassItemWidget> createState() => _ClassItemWidgetState();
}

class _ClassItemWidgetState extends State<ClassItemWidget> {
  String? _resolvedImageUrl;

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
    if (mounted) setState(() => _resolvedImageUrl = url);
  }

  @override
  Widget build(BuildContext context) {
    final hc = widget.homClass;
    final fullPrice = hc?.price;

    // Coupon (plan) discount state — used for badge and price display. Watches
    // AppCubit's Cubit state (not a one-off Storage read) so this rebuilds the
    // instant a purchase completes or a sync resolves.
    final app = context.watch<AppCubit>().state.buildable ?? const AppBuildable();
    // The coupon comes off Lumi's share of this class, so it is capped at that
    // share — the badge and the price must show what will actually be charged.
    final couponPct = effectiveCouponPercent(
      app.hasPremium ? app.planDiscountPercentage : 0,
      hc?.discountPercentage,
      isWholeCourse: hc?.showsWholeCoursePrice ?? false,
    );
    final showDiscountBadge = couponPct > 0;

    // Parse comma-separated categories into individual labels.
    final categories = (hc?.category ?? '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final duration = hc?.duration;
    final age = _formatAge(hc?.minAge, hc?.maxAge);

    // Clamp card width so layout stays sensible across phones and tablets:
    // narrow phones get a card that doesn't shrink below 240, tablets cap at 320.
    final double resolvedWidth =
        widget.width ?? (1.sw * 0.58).clamp(195.0, 255.0);

    return Container3d(
      onTap: () => context.router
          .push(ClassDetailRoute(classModel: hc ?? const HomClass())),
      width: resolvedWidth,
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
          // Image with overlays — aspect-ratio keeps it proportional to
          // the (clamped) card width on every screen size.
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: SizedBox(
              width: double.infinity,
              height: widget.imageHeight ?? 130.h,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Shimmer is always the base layer — shown while the
                  // network image loads and remains if the URL is null or
                  // the fetch fails (no static fallback image).
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade200,
                    highlightColor: Colors.grey.shade50,
                    child: Container(color: Colors.white),
                  ),
                  if (_resolvedImageUrl != null)
                    CachedNetworkImage(
                      imageUrl: _resolvedImageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      fadeInDuration: const Duration(milliseconds: 200),
                      // On error: SizedBox.shrink() lets the shimmer show through.
                      errorWidget: (_, __, ___) => const SizedBox.shrink(),
                    ),

                  // Top bar: categories (left, expands) + video button (right)
                  if (categories.isNotEmpty || widget.onViewAsReels != null)
                    Positioned(
                      left: 8.w,
                      right: 8.w,
                      top: 8.h,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (categories.isNotEmpty)
                            Flexible(
                              child: widget.wrapBranch
                                  // Horizontal carousel: first category only, capped width, truncated
                                  ? ConstrainedBox(
                                      constraints: BoxConstraints(maxWidth: 100.w),
                                      child: _buildChip(
                                        text: categories.first,
                                        bgColor: Colors.white.withOpacity(0.92),
                                        textColor: const Color(0xFF4A2FD4),
                                        borderColor: Colors.white.withOpacity(0.8),
                                        truncate: true,
                                      ),
                                    )
                                  // Vertical full-width list: all categories, full text
                                  : Wrap(
                                      spacing: 4.w,
                                      runSpacing: 4.h,
                                      children: categories.map((cat) => _buildChip(
                                        text: cat,
                                        bgColor: Colors.white.withOpacity(0.92),
                                        textColor: const Color(0xFF4A2FD4),
                                        borderColor: Colors.white.withOpacity(0.8),
                                      )).toList(),
                                    ),
                            ),
                          if (widget.onViewAsReels != null) ...[
                            if (categories.isNotEmpty) SizedBox(width: 6.w),
                            GestureDetector(
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
                                      color: const Color(0xFFA652C7).withOpacity(0.35),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.play_arrow_rounded,
                                        color: Colors.white, size: 16.sp),
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
                          ],
                        ],
                      ),
                    ),

                  // Discount badge — bottom-left of image. Shown when the user
                  // has a coupon and this class can carry it; the number is the
                  // coupon's effective percentage on THIS class.
                  if (showDiscountBadge)
                    Positioned(
                      left: 8.w,
                      bottom: 8.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B35), Color(0xFFFF3366)],
                          ),
                          borderRadius: BorderRadius.circular(10.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF3366).withOpacity(0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '−${formatCouponPercent(couponPct)}%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
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
            style: IOSText.headline(),
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
            final hasFreeAndPaid = snap != null && snap.priceMin == 0 && snap.priceMinPaid > 0;
            final effectivePrice = hasFreeAndPaid
                ? snap!.priceMinPaid
                : (snap != null && snap.priceMin > 0)
                    ? snap.priceMin
                    : (fullPrice ?? 0);
            if (effectivePrice <= 0) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                10.kh,
                Container(height: 1, color: const Color(0xFFE8E4F6)),
                10.kh,
                _buildInlinePrice(
                  fullPrice: fullPrice ?? 0,
                  snap: snap,
                  discountPct: hc?.discountPercentage ?? 0,
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
    required ClassPricingSnapshot? snap,
    required int discountPct,
  }) {
    // If the cheapest tier is free but paid tiers exist, show the lowest paid price.
    final hasFreeAndPaid = snap != null && snap.priceMin == 0 && snap.priceMinPaid > 0;
    final effectivePrice = hasFreeAndPaid
        ? snap!.priceMinPaid
        : (snap != null && snap.priceMin > 0)
            ? snap.priceMin
            : fullPrice;
    final showFrom = hasFreeAndPaid ||
        (snap != null && (snap.hasMultiplePrices || snap.rangeCount > 1));

    final priceStyle = TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w900,
      color: const Color(0xFF4A2FD4),
    );

    if (effectivePrice < 100) {
      return Text('price_free'.tr(), style: priceStyle);
    }
    if (showFrom) {
      return _applyPlanDiscount(
        originalWidget: Text(
          'price_from'.tr(args: [effectivePrice.toRawUzsPrice()]),
          style: priceStyle,
        ),
        originalPrice: effectivePrice,
        discountPct: discountPct,
        showFrom: true,
      );
    }
    return _applyPlanDiscount(
      originalWidget: Text(effectivePrice.toRawUzsPrice(), style: priceStyle),
      originalPrice: effectivePrice,
      discountPct: discountPct,
    );
  }

  Widget _applyPlanDiscount({
    required Widget originalWidget,
    required num originalPrice,
    required int discountPct,
    bool showFrom = false,
  }) {
    final app = context.watch<AppCubit>().state.buildable ?? const AppBuildable();
    // Capped at this class's partner share — see effectiveCouponPercent.
    final planPct = effectiveCouponPercent(
      app.hasPremium ? app.planDiscountPercentage : 0,
      widget.homClass?.discountPercentage,
      isWholeCourse: widget.homClass?.showsWholeCoursePrice ?? false,
    );
    if (planPct <= 0) {
      return originalWidget;
    }
    final discounted = originalPrice * (1 - planPct / 100);
    // Build the label strings, prefixing "from" when applicable.
    final originalLabel = showFrom
        ? 'price_from'.tr(args: [originalPrice.toRawUzsPrice()])
        : originalPrice.toRawUzsPrice();
    final discountedLabel = showFrom
        ? 'price_from'.tr(args: [discounted.toRawUzsPrice()])
        : discounted.toRawUzsPrice();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          originalLabel,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF9CA3AF),
            decoration: TextDecoration.lineThrough,
            decorationColor: const Color(0xFF9CA3AF),
          ),
        ),
        Text(
          discountedLabel,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF16A34A),
          ),
        ),
      ],
    );
  }

  Widget _buildChip({
    IconData? icon,
    required String text,
    required Color bgColor,
    required Color textColor,
    required Color borderColor,
    bool truncate = false,
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
          if (truncate)
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            )
          else
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
        text: 'boys'.tr(),
        bgColor: const Color(0xFF3B82F6).withOpacity(0.85),
        textColor: Colors.white,
        borderColor: Colors.white.withOpacity(0.65),
      );
    }
    if (g == 'FEMALE') {
      return _buildChip(
        icon: Icons.female_rounded,
        text: 'girls'.tr(),
        bgColor: const Color(0xFFEC4899).withOpacity(0.85),
        textColor: Colors.white,
        borderColor: Colors.white.withOpacity(0.65),
      );
    }
    // Both / All
    return _buildChip(
      icon: Icons.people_rounded,
      text: 'filter_both'.tr(),
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
