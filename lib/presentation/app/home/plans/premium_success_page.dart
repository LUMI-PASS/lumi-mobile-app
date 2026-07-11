import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';

class PremiumSuccessPage extends StatefulWidget {
  const PremiumSuccessPage({super.key});

  @override
  State<PremiumSuccessPage> createState() => _PremiumSuccessPageState();
}

class _PremiumSuccessPageState extends State<PremiumSuccessPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _finish() {
    final router = context.router;
    router.popUntil((route) => route.settings.name == MainRoute.name);
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primary, const Color(0xFFFF7093)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -60,
              left: -80,
              child: Opacity(
                opacity: 0.15,
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
                opacity: 0.12,
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
                        child: SizedBox(
                          width: 200.w,
                          height: 200.w,
                          child: Lottie.asset(
                            Assets.lotties.premium,
                            repeat: true,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    16.kh,
                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _ctrl,
                        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 14.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(30.r),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.workspace_premium_rounded,
                                    color: Colors.white, size: 14.sp),
                                6.kw,
                                Text(
                                  'premium_badge'.tr().toUpperCase(),
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
                          Text(
                            'You are Premium!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32.sp,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                              letterSpacing: -0.6,
                            ),
                          ),
                          14.kh,
                          Text(
                            'Thank you for upgrading. Unlimited classes,\npriority booking and exclusive perks are now\nyours to enjoy.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.92),
                              fontSize: 14.sp,
                              height: 1.5,
                            ),
                          ),
                          24.kh,
                          _PerkRow(icon: Icons.all_inclusive_rounded, text: 'Unlimited class access'),
                          10.kh,
                          _PerkRow(icon: Icons.bolt_rounded, text: 'Priority bookings'),
                          10.kh,
                          _PerkRow(
                              icon: Icons.auto_awesome_rounded,
                              text: 'Exclusive member perks'),
                        ],
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: _finish,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 15.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Start exploring',
                              style: TextStyle(
                                color: primary,
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

class _PerkRow extends StatelessWidget {
  const _PerkRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              size: 16.sp,
              color: const Color(0xFFFF7093),
            ),
          ),
          12.kw,
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
