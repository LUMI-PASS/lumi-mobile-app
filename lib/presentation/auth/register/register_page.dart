import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/constants/constants.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/utils/input_validators.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:lumi_pass/common/widget/common_text_filed.dart';
import 'package:lumi_pass/data/api_model/profile_model/profile_model.dart';
import 'package:lumi_pass/presentation/auth/register/cubit/register_cubit.dart';
import 'package:lumi_pass/presentation/auth/register/cubit/register_state.dart';
import 'package:lumi_pass/presentation/auth/verify/verify_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

@RoutePage()
class RegisterPage
    extends BasePage<RegisterCubit, RegisterBuildable, RegisterListenable> {
  RegisterPage({super.key, required this.phoneOrMail});

  final String phoneOrMail;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final FocusNode _firstNameFocusNode = FocusNode();
  final FocusNode _lastNameFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    super.dispose();
  }

  @override
  void listener(BuildContext context, RegisterListenable state) {
    if (state.effect == RegisterEffect.main) {
      context.router.push(
        VerifyRoute(
            verifyStatus: VerifyStatus.REGISTER, phoneOrEmail: phoneOrMail),
      );
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
            top: -50.h,
            left: -60.w,
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
              child: Assets.icons.background.registrationMisc.svg(
                width: 360.w,
                height: 360.h,
              ),
            ),
          ),
          // Secondary background - bottom right
          Positioned(
            bottom: -80.h,
            right: -60.w,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1600),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: (1 - value) * -0.2,
                  child: Opacity(
                    opacity: (value * 0.35).clamp(0.0, 0.35),
                    child: child,
                  ),
                );
              },
              child: Assets.icons.background.misc3.svg(
                width: 280.w,
                height: 280.h,
              ),
            ),
          ),
          // Floating dots
          ..._buildFloatingDots(),
          // Main content
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: MediaQuery.of(context).viewPadding.top),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    8.kh,
                    // Back button
                    Align(
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
                    8.kh,
                    // Illustration with bounce
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
                        child: _PulsingImage(
                          child: Assets.images.mascot.mascotHello.image(
                            width: 120.w,
                            height: 120.h,
                            excludeFromSemantics: true,
                          ),
                        ),
                      ),
                    ),
                    // Title slide from left
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
                          8.kh,
                          'registration_title'.tr().s(28).w(700),
                          'register'.tr().s(28).w(700).c(context.colors.primary),
                          6.kh,
                          'registration_subtitle'.tr()
                              .s(14)
                              .w(400)
                              .c(Colors.grey.shade600),
                        ],
                      ),
                    ),
                    24.kh,
                    // Form fields with staggered animation
                    _StaggeredField(
                      delay: 200,
                      child: CommonTextField(
                        autofocus: true,
                        focusNode: _firstNameFocusNode,
                        controller: _firstNameController,
                        hint: 'first_name'.tr(),
                        validator: (value) =>
                            InputValidators.required(value, 'first_name'.tr()),
                        isNext: true,
                        needToCapitalize: true,
                        nextFocusNode: _lastNameFocusNode,
                      ),
                    ),
                    12.kh,
                    _StaggeredField(
                      delay: 300,
                      child: CommonTextField(
                        controller: _lastNameController,
                        hint: 'last_name'.tr(),
                        focusNode: _lastNameFocusNode,
                        validator: (value) =>
                            InputValidators.required(value, 'last_name'.tr()),
                        needToCapitalize: true,
                      ),
                    ),
                    12.kh,
                    _StaggeredField(
                      delay: 400,
                      child: CommonTextField(
                        hint: 'phone_number_label'.tr(),
                        enabled: false,
                        initialValue: phoneOrMail,
                      ),
                    ),
                    20.kh,
                    // Gender selection with animation
                    _StaggeredField(
                      delay: 500,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          'gender'.tr().s(16).w(600),
                          10.kh,
                          Row(
                            children: [
                              Expanded(
                                child: _GenderOption(
                                  label: 'male'.tr(),
                                  icon: Icons.male_rounded,
                                  isSelected: state.isSelected == false,
                                  onTap: () => context
                                      .read<RegisterCubit>()
                                      .changeState(false),
                                ),
                              ),
                              12.kw,
                              Expanded(
                                child: _GenderOption(
                                  label: 'female'.tr(),
                                  icon: Icons.female_rounded,
                                  isSelected: state.isSelected == true,
                                  onTap: () => context
                                      .read<RegisterCubit>()
                                      .changeState(true),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    20.kh,
                    // Register button
                    _StaggeredField(
                      delay: 700,
                      child: CommonButton.elevated(
                        text: 'register'.tr(),
                        backgroundColor: context.colors.primary,
                        loading: state.isLoading,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context
                                .read<RegisterCubit>()
                                .register(ProfileModel(
                                  firstName: _firstNameController.text,
                                  lastName: _lastNameController.text,
                                  phoneNumber: phoneOrMail.startsWith("+")
                                      ? phoneOrMail.replaceAll("-", "")
                                      : null,
                                  gender:
                                      state.isSelected ? "FEMALE" : "MALE",
                                  city: "Tashkent",
                                  country: "Uzbekistan",
                                ));
                          }
                        },
                      ),
                    ),
                    32.kh,
                  ],
                ),
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
        top: 200.h,
        right: 25.w,
        size: 10.r,
        color: const Color(0xFFA652C7).withValues(alpha: 0.25),
        delay: 200,
      ),
      _FloatingDot(
        top: 400.h,
        left: 40.w,
        size: 8.r,
        color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
        delay: 800,
      ),
      _FloatingDot(
        bottom: 180.h,
        right: 60.w,
        size: 12.r,
        color: const Color(0xFFFFC107).withValues(alpha: 0.2),
        delay: 1200,
      ),
    ];
  }
}

class _StaggeredField extends StatefulWidget {
  const _StaggeredField({required this.child, this.delay = 0});

  final Widget child;
  final int delay;

  @override
  State<_StaggeredField> createState() => _StaggeredFieldState();
}

class _StaggeredFieldState extends State<_StaggeredField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  const _GenderOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? context.colors.primary
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1.5,
          ),
          borderRadius: BorderRadius.circular(14.r),
          color: isSelected
              ? context.colors.primary.withValues(alpha: 0.08)
              : Colors.grey.shade50,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: context.colors.primary.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                icon,
                key: ValueKey('$label-$isSelected'),
                color: isSelected ? context.colors.primary : Colors.grey,
                size: 22.r,
              ),
            ),
            SizedBox(width: 8.w),
            Text(label).s(15).w(isSelected ? 600 : 400),
          ],
        ),
      ),
    );
  }
}

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
        final scale = 1.0 + (_controller.value * 0.04);
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
