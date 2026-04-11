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
import 'package:lumi_pass/common/widget/common_text_filed.dart';
import 'package:lumi_pass/presentation/auth/login/bloc/login_cubit.dart';
import 'package:lumi_pass/presentation/auth/login/bloc/login_state.dart';
import 'package:lumi_pass/presentation/auth/verify/verify_page.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

@RoutePage()
class LoginPage extends BasePage<LoginCubit, LoginBuildable, LoginListenable> {
  LoginPage({super.key});

  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  void listener(BuildContext context, LoginListenable state) {
    if (state.effect == LoginEffect.verify) {
      context.router.push(
        VerifyRoute(
            verifyStatus: VerifyStatus.LOGIN,
            phoneOrEmail: "+998${_phoneController.text}"),
      );
    } else {
      context.router.push(
          RegisterRoute(phoneOrMail: "+998${_phoneController.text}"));
    }
    super.listener(context, state);
  }

  @override
  Widget builder(context, state) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background SVG - top right
          Positioned(
            top: -60.h,
            right: -80.w,
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
              child: Assets.icons.background.phoneNumberMisc.svg(
                width: 380.w,
                height: 380.h,
              ),
            ),
          ),
          // Secondary background decoration - bottom left
          Positioned(
            bottom: -100.h,
            left: -80.w,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1600),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: (1 - value) * 0.3,
                  child: Opacity(
                    opacity: (value * 0.4).clamp(0.0, 0.4),
                    child: child,
                  ),
                );
              },
              child: Assets.icons.background.misc2.svg(
                width: 300.w,
                height: 300.h,
              ),
            ),
          ),
          // Floating decorative circles
          ..._buildFloatingCircles(),
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20.h),
                  // Illustration with bounce animation
                  Align(
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
                      child: _PulsingWidget(
                        child: Assets.images.congrats
                            .image(width: 130.w, height: 130.h),
                      ),
                    ),
                  ),
                  20.kh,
                  // Title with slide from left
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(-40 * (1 - value), 0),
                        child: Opacity(opacity: value, child: child),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        'login_title'.tr().s(28).w(700),
                        6.kh,
                        'login_subtitle'.tr()
                            .s(16)
                            .w(400)
                            .c(Colors.grey.shade600),
                      ],
                    ),
                  ),
                  32.kh,
                  // Phone input with slide up
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 30 * (1 - value)),
                        child: Opacity(opacity: value, child: child),
                      );
                    },
                    child: CommonTextField(
                      controller: _phoneController,
                      autofocus: true,
                      prefixIcon: "+998".s(12).w(400),
                      mask: "##-###-##-##",
                      keyboardType: const TextInputType.numberWithOptions(),
                      hint: "12-345-67-89",
                      onChanged: (text) => context
                          .read<LoginCubit>()
                          .changePhoneState(text.length == 9),
                    ),
                  ),
                  24.kh,
                  // Continue button with fade up
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Opacity(opacity: value, child: child),
                      );
                    },
                    child: CommonButton.elevated(
                      text: 'continue_button'.tr(),
                      backgroundColor: context.colors.primary,
                      loading: state.isLoading,
                      enabled: state.isSelected,
                      onPressed: () {
                        context
                            .read<LoginCubit>()
                            .login("+998${_phoneController.text}");
                      },
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

  List<Widget> _buildFloatingCircles() {
    return [
      _FloatingDot(
        top: 180.h,
        left: 30.w,
        size: 12.r,
        color: const Color(0xFFA652C7).withValues(alpha: 0.3),
        delay: 0,
      ),
      _FloatingDot(
        top: 300.h,
        right: 50.w,
        size: 8.r,
        color: const Color(0xFFA652C7).withValues(alpha: 0.2),
        delay: 500,
      ),
      _FloatingDot(
        top: 450.h,
        left: 60.w,
        size: 10.r,
        color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
        delay: 1000,
      ),
      _FloatingDot(
        bottom: 200.h,
        right: 40.w,
        size: 14.r,
        color: const Color(0xFFFFC107).withValues(alpha: 0.25),
        delay: 1500,
      ),
    ];
  }
}

class _SocialSignInButton extends StatelessWidget {
  const _SocialSignInButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDark = false,
  });

  final Widget icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark ? Colors.transparent : Colors.grey.shade300,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              SizedBox(width: 12.w),
              label
                  .s(16)
                  .w(500)
                  .c(isDark ? Colors.white : Colors.black87),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsingWidget extends StatefulWidget {
  const _PulsingWidget({required this.child});

  final Widget child;

  @override
  State<_PulsingWidget> createState() => _PulsingWidgetState();
}

class _PulsingWidgetState extends State<_PulsingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
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
        final scale = 1.0 + (_controller.value * 0.05);
        return Transform.scale(scale: scale, child: child);
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
  late final double _randomPhase;

  @override
  void initState() {
    super.initState();
    _randomPhase = Random().nextDouble() * 2 * pi;
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
          final offset = sin(_controller.value * pi + _randomPhase) * 8;
          return Transform.translate(
            offset: Offset(0, offset),
            child: Opacity(
              opacity: 0.5 + (_controller.value * 0.5),
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
