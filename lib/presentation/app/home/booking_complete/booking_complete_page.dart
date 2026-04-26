import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';

@RoutePage()
class BookingCompletePage extends StatefulWidget {
  const BookingCompletePage({super.key});

  @override
  State<BookingCompletePage> createState() => _BookingCompletePageState();
}

class _BookingCompletePageState extends State<BookingCompletePage>
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

  void _goToSchedule() {
    final tabs = context.router.root.innerRouterOf<TabsRouter>(MainRoute.name);
    tabs?.setActiveIndex(2);
    context.router.popUntil((r) => r.settings.name == MainRoute.name);
  }

  void _discoverMore() {
    final tabs = context.router.root.innerRouterOf<TabsRouter>(MainRoute.name);
    tabs?.setActiveIndex(0);
    context.router.popUntil((r) => r.settings.name == MainRoute.name);
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FC),
      body: Stack(
        children: [
          Positioned(
            top: -50,
            right: -60,
            child: Opacity(
              opacity: 0.1,
              child: Assets.icons.background.congratsMisc.svg(
                width: 260.w,
                height: 260.w,
                colorFilter: ColorFilter.mode(primary, BlendMode.srcIn),
              ),
            ),
          ),
          Positioned(
            bottom: -70,
            left: -60,
            child: Opacity(
              opacity: 0.08,
              child: Assets.icons.background.premiumMisc.svg(
                width: 280.w,
                height: 280.w,
                colorFilter:
                    ColorFilter.mode(const Color(0xFFFF7093), BlendMode.srcIn),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => context.router.maybePop(),
                      child: Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16.sp,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.6, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _ctrl,
                          curve: const Interval(0, 0.7,
                              curve: Curves.easeOutBack),
                        ),
                      ),
                      child: Container(
                        width: 140.w,
                        height: 140.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [primary, const Color(0xFFFF7093)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withOpacity(0.35),
                              blurRadius: 30,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 68.sp,
                        ),
                      ),
                    ),
                  ),
                  24.kh,
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _ctrl,
                      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Booking confirmed',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF2E3D5D),
                            height: 1.1,
                            letterSpacing: -0.4,
                          ),
                        ),
                        12.kh,
                        Text(
                          'Your seat is reserved. We can’t wait to\nsee you at the class.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            height: 1.45,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        22.kh,
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 14.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18.r),
                            border: Border.all(
                                color: Colors.grey.shade200, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40.w,
                                height: 40.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: primary.withOpacity(0.1),
                                ),
                                child: Icon(
                                  Icons.event_available_rounded,
                                  color: primary,
                                  size: 20.sp,
                                ),
                              ),
                              12.kw,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Check your schedule',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF1E293B),
                                      ),
                                    ),
                                    2.kh,
                                    Text(
                                      'Your booking has been added to the calendar.',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _goToSchedule,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18.r),
                        gradient: LinearGradient(
                          colors: [primary, const Color(0xFFFF7093)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Go to schedule',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  12.kh,
                  GestureDetector(
                    onTap: _discoverMore,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Center(
                        child: Text(
                          'Discover more classes',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF475569),
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
    );
  }
}
