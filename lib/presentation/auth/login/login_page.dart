import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:lumi_pass/presentation/auth/login/bloc/login_cubit.dart';
import 'package:lumi_pass/presentation/auth/login/bloc/login_state.dart';
import 'package:lumi_pass/presentation/auth/verify/verify_page.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

@RoutePage()
class LoginPage extends BasePage<LoginCubit, LoginBuildable, LoginListenable> {
  LoginPage({super.key});

  final _phoneController = TextEditingController();
  final _agreedToTerms = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _phoneController.dispose();
    _agreedToTerms.dispose();
    super.dispose();
  }

  @override
  void listener(BuildContext context, LoginListenable state) {
    if (state.effect == LoginEffect.verify) {
      context.router.push(
        VerifyRoute(
          verifyStatus: VerifyStatus.LOGIN,
          phoneOrEmail: "+998${_phoneController.text}",
          code: state.code,
        ),
      );
    }
    super.listener(context, state);
  }

  @override
  Widget builder(BuildContext context, LoginBuildable state) {
    final primary = context.colors.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F0FB),
      body: Column(
        children: [
          _Header(primary: primary),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  28.kh,
                  _TitleSection(),
                  28.kh,
                  _PhoneInput(controller: _phoneController),
                  16.kh,
                  _OfertaRow(
                    agreedNotifier: _agreedToTerms,
                    primary: primary,
                  ),
                  24.kh,
                  ValueListenableBuilder<bool>(
                    valueListenable: _agreedToTerms,
                    builder: (context, agreed, _) {
                      return _FadeSlideIn(
                        delay: const Duration(milliseconds: 200),
                        child: CommonButton.elevated(
                          text: 'continue_button'.tr(),
                          backgroundColor: primary,
                          loading: state.isLoading,
                          enabled: state.isSelected && agreed,
                          onPressed: () => context
                              .read<LoginCubit>()
                              .login("+998${_phoneController.text}"),
                        ),
                      );
                    },
                  ),
                  48.kh,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.primary});
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF7B1FA2),
            primary,
            const Color(0xFFCE93D8),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36.r),
          bottomRight: Radius.circular(36.r),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20.h,
            right: -30.w,
            child: Assets.icons.background.phoneNumberMisc.svg(
              width: 200.w,
              height: 200.h,
              colorFilter: ColorFilter.mode(
                Colors.white.withValues(alpha: 0.1),
                BlendMode.srcIn,
              ),
            ),
          ),
          Positioned(
            bottom: -10.h,
            left: -20.w,
            child: Assets.icons.background.misc2.svg(
              width: 130.w,
              height: 130.h,
              colorFilter: ColorFilter.mode(
                Colors.white.withValues(alpha: 0.07),
                BlendMode.srcIn,
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 750),
                curve: Curves.elasticOut,
                builder: (_, value, child) => Transform.scale(
                  scale: value.clamp(0.0, 1.15),
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: child,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 76.r,
                      height: 76.r,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(22.r),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      padding: EdgeInsets.all(12.r),
                      child: ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(12),
                          child: Assets.icons.lumiLogo.image(fit: BoxFit.contain)),
                    ),
            
                   
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Title section ─────────────────────────────────────────────────────────────

class _TitleSection extends StatelessWidget {
  const _TitleSection();

  @override
  Widget build(BuildContext context) {
    return _FadeSlideIn(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          'login_title'.tr().s(26).w(700),
          6.kh,
          'login_subtitle'.tr().s(14).w(400).c(Colors.grey.shade600),
        ],
      ),
    );
  }
}

// ── Phone input ───────────────────────────────────────────────────────────────

class _PhoneInput extends StatefulWidget {
  const _PhoneInput({required this.controller});
  final TextEditingController controller;

  @override
  State<_PhoneInput> createState() => _PhoneInputState();
}

class _PhoneInputState extends State<_PhoneInput> {
  late final MaskTextInputFormatter _mask;
  final _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _mask = MaskTextInputFormatter(
      mask: '##-###-##-##',
      filter: {'#': RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
    );
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grey = context.colors.grey;
    final primary = context.colors.primary;

    return _FadeSlideIn(
      delay: const Duration(milliseconds: 80),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 56.h,
        decoration: BoxDecoration(
          color: grey.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: _focused ? primary : grey,
            width: _focused ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Flag + code ─────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _UzFlag(),
                  SizedBox(width: 7.w),
                  Text(
                    '+998',
                    style: GoogleFonts.onest(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            // ── Divider ──────────────────────────────────────────────────────
            Container(width: 1, height: 28.h, color: grey),
            // ── Number field ─────────────────────────────────────────────────
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focus,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(),
                inputFormatters: [_mask],
                cursorColor: primary,
                textAlignVertical: TextAlignVertical.center,
                style: GoogleFonts.onest(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                  color: context.colors.label,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '12-345-67-89',
                  hintStyle: GoogleFonts.onest(
                    fontSize: 15.sp,
                    color: const Color(0xFF717680),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 0),
                  isDense: true,
                ),
                onChanged: (text) {
                  final digits = _mask.unmaskText(text);
                  context
                      .read<LoginCubit>()
                      .changePhoneState(digits.length == 9);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Oferta row ────────────────────────────────────────────────────────────────

class _OfertaRow extends StatelessWidget {
  const _OfertaRow({
    required this.agreedNotifier,
    required this.primary,
  });

  final ValueNotifier<bool> agreedNotifier;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return _FadeSlideIn(
      delay: const Duration(milliseconds: 160),
      child: ValueListenableBuilder<bool>(
        valueListenable: agreedNotifier,
        builder: (context, agreed, _) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => agreedNotifier.value = !agreed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: agreed
                    ? primary.withValues(alpha: 0.07)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: agreed
                      ? primary.withValues(alpha: 0.4)
                      : Colors.grey.shade200,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _AnimatedCheckbox(checked: agreed, primary: primary),
                  12.kw,
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.onest(
                          fontSize: 13.sp,
                          color: Colors.black87,
                          height: 1.45,
                        ),
                        children: [
                          TextSpan(text: 'oferta_agree_prefix'.tr()),
                          TextSpan(
                            text: 'oferta_link_text'.tr(),
                            style: GoogleFonts.onest(
                              fontSize: 13.sp,
                              color: primary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: primary,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => launchUrl(
                                    Uri.parse(
                                        'https://lumipass.uz/public-offer'),
                                    mode: LaunchMode.externalApplication,
                                  ),
                          ),
                          TextSpan(text: 'oferta_agree_suffix'.tr()),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AnimatedCheckbox extends StatelessWidget {
  const _AnimatedCheckbox({required this.checked, required this.primary});

  final bool checked;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: 22.r,
      height: 22.r,
      decoration: BoxDecoration(
        color: checked ? primary : Colors.transparent,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: checked ? primary : Colors.grey.shade400,
          width: 1.5,
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: checked
            ? Icon(
                Icons.check_rounded,
                key: const ValueKey('checked'),
                size: 14.sp,
                color: Colors.white,
              )
            : const SizedBox.shrink(key: ValueKey('unchecked')),
      ),
    );
  }
}

// ── Uzbekistan flag ───────────────────────────────────────────────────────────

class _UzFlag extends StatelessWidget {
  const _UzFlag();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3.r),
      child: SizedBox(
        width: 24.w,
        height: 12.h,
        child: Column(
          children: [
            Expanded(
              flex: 10,
              child: Container(color: const Color(0xFF1BAEEE)),
            ),
            Container(height: 1.2.h, color: const Color(0xFFCE1126)),
            Expanded(
              flex: 10,
              child: Container(color: Colors.white),
            ),
            Container(height: 1.2.h, color: const Color(0xFFCE1126)),
            Expanded(
              flex: 10,
              child: Container(color: const Color(0xFF1EAA4F)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared fade-slide-in animation ───────────────────────────────────────────

class _FadeSlideIn extends StatelessWidget {
  const _FadeSlideIn({required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay.inMilliseconds),
      curve: Curves.easeOutCubic,
      builder: (_, value, child) => Opacity(
        opacity: value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, 18 * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
