import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/home/home_api.dart';

/// Shown after a successful plan purchase that includes a coupon discount.
/// Fetches the count of eligible activities and presents it alongside
/// an animated celebration so the user knows exactly what they unlocked.
class CouponSuccessPage extends StatefulWidget {
  const CouponSuccessPage({
    super.key,
    required this.discountPercentage,
  });

  /// The discount percentage tied to the purchased plan (e.g. 20 for 20%).
  final int discountPercentage;

  @override
  State<CouponSuccessPage> createState() => _CouponSuccessPageState();
}

class _CouponSuccessPageState extends State<CouponSuccessPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  int? _eligibleCount;
  bool _loadingCount = true;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fetchEligibleCount();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _fetchEligibleCount() async {
    try {
      final resp = await getIt<HomeApi>().getEligibleCount(widget.discountPercentage);
      final data = resp.data;
      if (data is Map && data['count'] is int) {
        if (mounted) setState(() => _eligibleCount = data['count'] as int);
      } else if (data is Map && data['count'] is num) {
        if (mounted) setState(() => _eligibleCount = (data['count'] as num).toInt());
      }
    } catch (_) {
      // Non-fatal — just leave count null; the UI handles it gracefully.
    } finally {
      if (mounted) setState(() => _loadingCount = false);
    }
  }

  void _finish() {
    final router = context.router;
    router.popUntil((route) => route.settings.name == MainRoute.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFF1E293B), const Color(0xFF0F172A)],
          ),
        ),
        child: Stack(
          children: [
            // Background decorative elements
            Positioned(
              top: -60,
              left: -80,
              child: Opacity(
                opacity: 0.08,
                child: Assets.icons.background.congratsMisc.svg(
                  width: 300.w,
                  height: 300.w,
                  colorFilter: const ColorFilter.mode(
                      Colors.white, BlendMode.srcIn),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              right: -80,
              child: Opacity(
                opacity: 0.07,
                child: Assets.icons.background.premiumMisc.svg(
                  width: 320.w,
                  height: 320.w,
                  colorFilter: const ColorFilter.mode(
                      Colors.white, BlendMode.srcIn),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
                child: Column(
                  children: [
                    const Spacer(),

                    // Lottie + discount badge
                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _ctrl,
                        curve: const Interval(0, 0.6, curve: Curves.easeOut),
                      ),
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.85, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _ctrl,
                            curve: const Interval(0, 0.7,
                                curve: Curves.easeOutBack),
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 200.w,
                              height: 200.w,
                              child: Lottie.asset(
                                Assets.lotties.premium,
                                repeat: true,
                                fit: BoxFit.contain,
                              ),
                            ),
                            // Discount pill on top of animation
                            Positioned(
                              bottom: 8.h,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 18.w, vertical: 8.h),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFF6B35), Color(0xFFFF3366)],
                                  ),
                                  borderRadius: BorderRadius.circular(30.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF3366).withOpacity(0.4),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '−${widget.discountPercentage}%',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    24.kh,

                    // Text content
                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _ctrl,
                        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
                      ),
                      child: Column(
                        children: [
                          // Badge
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 14.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF6B35), Color(0xFFFF3366)],
                              ),
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.local_offer_rounded,
                                    color: Colors.white, size: 13.sp),
                                6.kw,
                                Text(
                                  'coupon_activated_badge'.tr(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          20.kh,

                          // Title
                          Text(
                            'coupon_activated_title'.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30.sp,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                              letterSpacing: -0.6,
                            ),
                          ),

                          12.kh,

                          // Subtitle
                          Text(
                            'coupon_activated_subtitle'.tr(
                              namedArgs: {'percent': '${widget.discountPercentage}'},
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.78),
                              fontSize: 14.sp,
                              height: 1.5,
                            ),
                          ),

                          28.kh,

                          // Eligible activities card
                          _EligibleCountCard(
                            loading: _loadingCount,
                            count: _eligibleCount,
                            discountPercentage: widget.discountPercentage,
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // CTA
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: _finish,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 15.h),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B35), Color(0xFFFF3366)],
                            ),
                            borderRadius: BorderRadius.circular(18.r),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF3366).withOpacity(0.35),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'coupon_start_exploring'.tr(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EligibleCountCard extends StatelessWidget {
  const _EligibleCountCard({
    required this.loading,
    required this.count,
    required this.discountPercentage,
  });

  final bool loading;
  final int? count;
  final int discountPercentage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFF3366)],
              ),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.confirmation_number_rounded,
              color: Colors.white,
              size: 22.sp,
            ),
          ),
          16.kw,
          Expanded(
            child: loading
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'coupon_eligible_loading'.tr(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      8.kh,
                      SizedBox(
                        height: 3.h,
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFFF6B35)),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        count != null
                            ? 'coupon_eligible_count'
                                .tr(namedArgs: {'count': '$count'})
                            : 'coupon_discount_label'.tr(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      if (count != null) ...[
                        4.kh,
                        Text(
                          '−$discountPercentage% ${'coupon_discount_label'.tr()}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
