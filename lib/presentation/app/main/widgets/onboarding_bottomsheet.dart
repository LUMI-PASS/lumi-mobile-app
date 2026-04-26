import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/auth/auth_repository.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';

const _primary = Color(0xFFA652C7);

Future<void> showOnboardingBottomsheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isDismissible: true,
    enableDrag: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _OnboardingSheet(),
  );
}

class _OnboardingSheet extends StatefulWidget {
  const _OnboardingSheet();

  @override
  State<_OnboardingSheet> createState() => _OnboardingSheetState();
}

class _OnboardingSheetState extends State<_OnboardingSheet> {
  final _parentName = TextEditingController();
  final _childName = TextEditingController();
  final _childAge = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _storage = getIt<Storage>();
  final _repo = getIt<AuthRepository>();
  bool _loading = false;
  String? _error;

  Future<void> _skip() async {
    await _storage.needsOnboarding.set(false);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _parentName.dispose();
    _childName.dispose();
    _childAge.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final phone = _storage.pendingPhone.call() ?? '';
      final parent = _parentName.text.trim();
      final parts = parent.split(RegExp(r'\s+'));
      final firstName = parts.first;
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      await _repo.register(
        phone: phone,
        firstName: firstName,
        lastName: lastName,
      );
      await _storage.parentName.set(parent);
      final childName = _childName.text.trim();
      final childAge = int.tryParse(_childAge.text.trim()) ?? 0;
      await _storage.childName.set(childName);
      await _storage.childAge.set(childAge);
      if (childName.isNotEmpty && childAge > 0) {
        await getIt<OrdersApi>().createChild(name: childName, age: childAge);
      }
      await _storage.needsOnboarding.set(false);
      await _storage.pendingPhone.set(null);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          boxShadow: [
            BoxShadow(
              color: _primary.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          child: Stack(
            children: [
              Positioned(
                top: -60.h,
                right: -40.w,
                child: Opacity(
                  opacity: 0.25,
                  child: Assets.icons.background.congratsMisc.svg(
                    width: 220.w,
                    height: 220.h,
                  ),
                ),
              ),
              Positioned(
                bottom: -40.h,
                left: -30.w,
                child: Opacity(
                  opacity: 0.15,
                  child: Assets.icons.background.otpMisc.svg(
                    width: 180.w,
                    height: 180.h,
                  ),
                ),
              ),
              SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 20.w,
                  right: 20.w,
                  top: 14.h,
                  bottom: 24.h + bottom,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Spacer(),
                          Center(
                            child: Container(
                              width: 44.w,
                              height: 4.h,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: _skip,
                                behavior: HitTestBehavior.opaque,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 4.w, vertical: 4.h),
                                  child: Text(
                                    'skip'.tr(),
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      16.kh,
                      Center(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.elasticOut,
                          builder: (context, v, child) =>
                              Transform.scale(scale: v, child: child),
                          child: _PulsingImage(
                            child: Assets.images.congrats
                                .image(width: 100.w, height: 100.h),
                          ),
                        ),
                      ),
                      12.kh,
                      Center(
                        child: 'onboarding_title'.tr().s(22).w(700),
                      ),
                      6.kh,
                      Center(
                        child: 'onboarding_subtitle'
                            .tr()
                            .s(14)
                            .w(400)
                            .c(Colors.grey.shade600)
                            .a(TextAlign.center),
                      ),
                      24.kh,
                      _FancyField(
                        controller: _parentName,
                        label: 'onboarding_parent_name'.tr(),
                        icon: Icons.person_outline_rounded,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'required'.tr()
                            : null,
                      ),
                      14.kh,
                      _FancyField(
                        controller: _childName,
                        label: 'onboarding_child_name'.tr(),
                        icon: Icons.child_care_rounded,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'required'.tr()
                            : null,
                      ),
                      14.kh,
                      _FancyField(
                        controller: _childAge,
                        label: 'onboarding_child_age'.tr(),
                        icon: Icons.cake_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        validator: (v) {
                          final n = int.tryParse(v?.trim() ?? '');
                          if (n == null || n <= 0 || n > 18) {
                            return 'required'.tr();
                          }
                          return null;
                        },
                      ),
                      if (_error != null) ...[
                        12.kh,
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: context.colors.primary2
                                .withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline_rounded,
                                  size: 18.r, color: context.colors.primary2),
                              8.kw,
                              Expanded(
                                child: _error!
                                    .s(12)
                                    .w(500)
                                    .c(context.colors.primary2),
                              ),
                            ],
                          ),
                        ),
                      ],
                      22.kh,
                      CommonButton.elevated(
                        text: 'continue'.tr(),
                        backgroundColor: _primary,
                        loading: _loading,
                        onPressed: _submit,
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

class _FancyField extends StatelessWidget {
  const _FancyField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      cursorColor: _primary,
      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
        floatingLabelStyle:
            TextStyle(color: _primary, fontWeight: FontWeight.w600),
        prefixIcon: Icon(icon, color: _primary, size: 20.r),
        filled: true,
        fillColor: _primary.withValues(alpha: 0.04),
        contentPadding:
            EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: _primary.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: _primary.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: _primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: Colors.redAccent.shade200),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide:
              BorderSide(color: Colors.redAccent.shade200, width: 1.5),
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
