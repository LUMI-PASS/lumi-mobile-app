import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';

/// Shows the one-time premium "get coupon" reward popup.
///
/// [onGetCoupon] is invoked after the dialog has been dismissed when the user
/// taps the CTA — the caller is responsible for navigation.
Future<void> showCouponPromoDialog(
  BuildContext context, {
  required VoidCallback onGetCoupon,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    transitionDuration: const Duration(milliseconds: 440),
    pageBuilder: (ctx, _, __) => _CouponPromoDialog(
      onGetCoupon: () {
        Navigator.of(ctx).pop();
        onGetCoupon();
      },
    ),
    transitionBuilder: (ctx, anim, _, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
      return Opacity(
        opacity: anim.value.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: 0.8 + 0.2 * curved.value,
          child: child,
        ),
      );
    },
  );
}

class _CouponPromoDialog extends StatelessWidget {
  const _CouponPromoDialog({required this.onGetCoupon});

  final VoidCallback onGetCoupon;

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 330.w,
          margin: EdgeInsets.symmetric(horizontal: 24.w),
          padding: EdgeInsets.fromLTRB(24.w, 14.h, 24.w, 24.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28.r),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.28),
                blurRadius: 44,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close_rounded,
                        size: 16.sp, color: const Color(0xFF64748B)),
                  ),
                ),
              ),
              // Premium Lottie with a soft radial glow behind it.
              SizedBox(
                height: 150.w,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 150.w,
                      height: 150.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            primary.withValues(alpha: 0.18),
                            primary.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                    Lottie.asset(
                      Assets.lotties.premium,
                      width: 150.w,
                      height: 150.w,
                      repeat: true,
                    ),
                  ],
                ),
              ),
              10.kh,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, const Color(0xFFFF7093)],
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.gift_fill,
                        size: 12.sp, color: Colors.white),
                    5.kw,
                    Text(
                      'coupon_plans_title'.tr().toUpperCase(),
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              12.kh,
              Text(
                'coupon_plans_subtitle'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2E3D5D),
                  height: 1.35,
                ),
              ),
              22.kh,
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onGetCoupon,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 15.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primary, const Color(0xFFFF7093)],
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'get_coupon'.tr(),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      6.kw,
                      Icon(Icons.arrow_forward_rounded,
                          size: 18.sp, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
