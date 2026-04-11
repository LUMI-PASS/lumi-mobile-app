import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/presentation/auth/verify/cubit/verify_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'cubit/verify_state.dart';
import 'widget/common_pin_put.dart';

@RoutePage()
class VerifyPage
    extends BasePage<VerifyCubit, VerifyBuildable, VerifyListenable> {
  final VerifyStatus verifyStatus;
  final String phoneOrEmail;
  final int? code;
  final String? codeHash;

  VerifyPage(
      {super.key,
      required this.verifyStatus,
      required this.phoneOrEmail,
      this.codeHash,
      this.code});

  final storage = getIt<Storage>();

  String _formatTimer(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void listener(BuildContext context, VerifyListenable state) {
    if (state.effect == VerifyEffect.success) {
      context.router.replaceAll(const [MainRoute()]);
    }
    super.listener(context, state);
  }

  @override
  Widget builder(context, state) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background SVG - top left
          Positioned(
            top: -40.h,
            left: -50.w,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1400),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.6 + (0.4 * value),
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: Assets.icons.background.otpMisc.svg(
                width: 360.w,
                height: 360.h,
              ),
            ),
          ),
          // Secondary background - bottom right
          Positioned(
            bottom: -90.h,
            right: -70.w,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1600),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: (1 - value) * 0.25,
                  child: Opacity(
                    opacity: (value * 0.3).clamp(0.0, 0.3),
                    child: child,
                  ),
                );
              },
              child: Assets.icons.background.congratsMisc.svg(
                width: 300.w,
                height: 300.h,
              ),
            ),
          ),
          // Floating decorative dots
          ..._buildFloatingDots(),
          // Main content
          SizedBox(
            height: 1.sh,
            width: 1.sw,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                      height:
                          MediaQuery.of(context).viewPadding.top + 12.h),
                  // Back button
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Opacity(opacity: value, child: child);
                        },
                        child: GestureDetector(
                          onTap: () => context.router.maybePop(),
                          child: Container(
                            width: 42.r,
                            height: 42.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 18.r,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  8.kh,
                  // Illustration with bounce
                  Padding(
                    padding: EdgeInsets.only(right: 24.w),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: child,
                          );
                        },
                        child: _PulsingImage(
                          child: Assets.images.congrats
                              .image(width: 120.w, height: 120.h),
                        ),
                      ),
                    ),
                  ),
                  16.kh,
                  // OTP Card with slide-up + fade
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 60 * (1 - value)),
                        child: Opacity(opacity: value, child: child),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 28.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFA652C7)
                                  .withValues(alpha: 0.1),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                              spreadRadius: 5,
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0xFFA652C7)
                                .withValues(alpha: 0.1),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Lock icon with shimmer
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOutBack,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: child,
                                );
                              },
                              child: Container(
                                width: 60.r,
                                height: 60.r,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFFA652C7)
                                          .withValues(alpha: 0.2),
                                      const Color(0xFFA652C7)
                                          .withValues(alpha: 0.05),
                                    ],
                                  ),
                                ),
                                child: Icon(
                                  Icons.lock_outline_rounded,
                                  color: const Color(0xFFA652C7),
                                  size: 28.r,
                                ),
                              ),
                            ),
                            16.kh,
                            'verification_title'.tr()
                                .s(22)
                                .w(700),
                            10.kh,
                            'verification_subtitle'.tr()
                                .s(14)
                                .w(400)
                                .c(Colors.grey.shade600)
                                .a(TextAlign.center),
                            6.kh,
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFA652C7)
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: phoneOrEmail
                                  .s(13)
                                  .w(600)
                                  .c(const Color(0xFFA652C7)),
                            ),
                            24.kh,
                            // Pin input with scale animation
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.85, end: 1.0),
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOutBack,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Opacity(
                                    opacity:
                                        ((value - 0.85) / 0.15).clamp(0.0, 1.0),
                                    child: child,
                                  ),
                                );
                              },
                              child: CommonPinPut(
                                onChanged: (text) {
                                  if (text.length == 4) {
                                    context
                                        .read<VerifyCubit>()
                                        .changeCode(int.tryParse(text));
                                    // Auto-submit when all 4 digits are entered
                                    Future.microtask(() {
                                      context.read<VerifyCubit>().checkCode(
                                          phoneOrEmail,
                                          storage.codeHash.call() ?? "",
                                          verifyStatus ==
                                              VerifyStatus.REGISTER);
                                    });
                                  }
                                },
                              ),
                            ),
                            16.kh,
                            // Timer / Resend
                            InkWell(
                              onTap: () {
                                if (state.timer == 0) {
                                  context.read<VerifyCubit>().resendOtp(
                                      phoneOrEmail.replaceAll("-", ""));
                                }
                              },
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (child, anim) =>
                                    FadeTransition(
                                  opacity: anim,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.3),
                                      end: Offset.zero,
                                    ).animate(anim),
                                    child: child,
                                  ),
                                ),
                                child: state.timer != 0
                                    ? Row(
                                        key: const ValueKey('timer'),
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.timer_outlined,
                                            size: 16.r,
                                            color: Colors.grey.shade500,
                                          ),
                                          6.kw,
                                          _formatTimer(state.timer)
                                              .s(14)
                                              .w(600)
                                              .c(Colors.grey.shade600),
                                        ],
                                      )
                                    : Container(
                                        key: const ValueKey('resend'),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20.w,
                                          vertical: 8.h,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20.r),
                                          border: Border.all(
                                            color: context.colors.primary
                                                .withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: 'resend_code'.tr()
                                            .s(14)
                                            .w(600)
                                            .c(context.colors.primary),
                                      ),
                              ),
                            ),
                            if (state.error != null) ...[
                              12.kh,
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 300),
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                        sin(value * pi * 3) * 5 * (1 - value),
                                        0),
                                    child: Opacity(
                                        opacity: value, child: child),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: context.colors.primary2
                                        .withValues(alpha: 0.1),
                                    borderRadius:
                                        BorderRadius.circular(8.r),
                                  ),
                                  child: "${state.error}"
                                      .s(13)
                                      .w(500)
                                      .c(context.colors.primary2),
                                ),
                              ),
                            ],
                            20.kh,
                            CommonButton.elevated(
                              text: 'verify_button'.tr(),
                              backgroundColor: context.colors.primary,
                              loading: state.loading,
                              onPressed: () {
                                context.read<VerifyCubit>().checkCode(
                                    phoneOrEmail,
                                    storage.codeHash.call() ?? "",
                                    verifyStatus ==
                                        VerifyStatus.REGISTER);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  40.kh,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingDots() {
    return [
      _FloatingDot(
        top: 160.h,
        left: 30.w,
        size: 10.r,
        color: const Color(0xFFA652C7).withValues(alpha: 0.3),
        delay: 0,
      ),
      _FloatingDot(
        top: 280.h,
        right: 35.w,
        size: 7.r,
        color: const Color(0xFF4CAF50).withValues(alpha: 0.25),
        delay: 600,
      ),
      _FloatingDot(
        bottom: 250.h,
        left: 50.w,
        size: 12.r,
        color: const Color(0xFFFFC107).withValues(alpha: 0.2),
        delay: 1000,
      ),
      _FloatingDot(
        bottom: 150.h,
        right: 45.w,
        size: 9.r,
        color: const Color(0xFFA652C7).withValues(alpha: 0.15),
        delay: 1400,
      ),
    ];
  }
}

enum VerifyStatus { REGISTER, LOGIN, PASSWORDRESET }

// --- Shared animated widgets ---

class _PulsingImage extends StatefulWidget {
  const _PulsingImage({required this.child});

  final Widget child;

  @override
  State<_PulsingImage> createState() => _PulsingImageState();
}

class _PulsingImageState extends State<_PulsingImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1.0 + (_controller.value * 0.04);
        final dy = sin(_controller.value * pi) * 4;
        return Transform.translate(
          offset: Offset(0, dy),
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: widget.child,
    );
  }
}

class _FloatingDot extends StatefulWidget {
  const _FloatingDot({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    required this.color,
    this.delay = 0,
  });

  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double size;
  final Color color;
  final int delay;

  @override
  State<_FloatingDot> createState() => _FloatingDotState();
}

class _FloatingDotState extends State<_FloatingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final double _phase;

  @override
  void initState() {
    super.initState();
    _phase = Random().nextDouble() * 2 * pi;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top,
      bottom: widget.bottom,
      left: widget.left,
      right: widget.right,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final dy = sin(_controller.value * pi + _phase) * 8;
          return Transform.translate(
            offset: Offset(0, dy),
            child: Opacity(
              opacity: 0.4 + (_controller.value * 0.6),
              child: child,
            ),
          );
        },
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
          ),
        ),
      ),
    );
  }
}
