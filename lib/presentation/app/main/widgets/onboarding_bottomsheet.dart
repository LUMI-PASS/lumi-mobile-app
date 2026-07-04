import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/utils/display_name_notifier.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/auth/auth_repository.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:dio/dio.dart';

Future<void> showOnboardingBottomsheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isDismissible: true,
    enableDrag: true,
    isScrollControlled: true,
    useSafeArea: false,
    barrierColor: Colors.black.withValues(alpha: 0.45),
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
  final _formKey0 = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  final _storage = getIt<Storage>();
  final _repo = getIt<AuthRepository>();

  int _step = 0;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _parentName.dispose();
    _childName.dispose();
    _childAge.dispose();
    super.dispose();
  }

  Future<void> _skip() async {
    await _storage.needsOnboarding.set(false);
    if (mounted) Navigator.of(context).pop();
  }

  void _nextStep() {
    if (!(_formKey0.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _step = 1;
      _error = null;
    });
  }

  Future<void> _submit() async {
    if (!(_formKey1.currentState?.validate() ?? false)) return;
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

      if (phone.isNotEmpty) {
        // New user — complete registration with phone
        await _repo.register(
            phone: phone, firstName: firstName, lastName: lastName);
        await _storage.pendingPhone.set(null);
      } else {
        // Already authenticated — just update the profile name
        await getIt<Dio>().patch(
          'users/parents/profile',
          data: {
            'first_name': firstName,
            if (lastName.isNotEmpty) 'last_name': lastName,
          },
        );
      }

      await _storage.parentName.set(parent);
      displayNameNotifier.value = parent;

      final childName = _childName.text.trim();
      final childAge = int.tryParse(_childAge.text.trim()) ?? 0;
      await _storage.childName.set(childName);
      await _storage.childAge.set(childAge);
      if (childName.isNotEmpty && childAge > 0) {
        await getIt<OrdersApi>().createChild(name: childName, age: childAge);
      }
      await _storage.needsOnboarding.set(false);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    final keyboard = MediaQuery.of(context).viewInsets.bottom;
    final safeBottom = MediaQuery.of(context).viewPadding.bottom;
    final bottomPad = keyboard > 0 ? keyboard + 8.h : safeBottom + 24.h;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Padding(
              padding: EdgeInsets.only(top: 12.h, bottom: 0),
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, bottomPad),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.04, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: anim,
                        curve: Curves.easeOutCubic,
                      )),
                      child: child,
                    ),
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(_step),
                    child: _step == 0
                        ? _buildStep0(primary)
                        : _buildStep1(primary),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep0(Color primary) {
    return Form(
      key: _formKey0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          28.kh,
          _StepHeader(
            step: 0,
            total: 2,
            emoji: '👋',
            title: 'onboarding_step1_title'.tr(),
            primary: primary,
          ),
          28.kh,
          _CleanField(
            controller: _parentName,
            label: 'onboarding_parent_name'.tr(),
            icon: CupertinoIcons.person,
            primary: primary,
            autofocus: true,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'required'.tr() : null,
          ),
          if (_error != null) ...[10.kh, _ErrorRow(error: _error!)],
          24.kh,
          _PrimaryButton(
            label: 'onboarding_next'.tr(),
            primary: primary,
            onPressed: _nextStep,
          ),
          8.kh,
          _GhostButton(label: 'skip'.tr(), onTap: _skip),
          8.kh,
        ],
      ),
    );
  }

  Widget _buildStep1(Color primary) {
    return Form(
      key: _formKey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          28.kh,
          _StepHeader(
            step: 1,
            total: 2,
            emoji: '🧒',
            title: 'onboarding_step2_title'.tr(),
            primary: primary,
          ),
          28.kh,
          _CleanField(
            controller: _childName,
            label: 'onboarding_child_name'.tr(),
            icon: CupertinoIcons.smiley,
            primary: primary,
            autofocus: true,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'required'.tr() : null,
          ),
          12.kh,
          _CleanField(
            controller: _childAge,
            label: 'onboarding_child_age'.tr(),
            icon: CupertinoIcons.gift,
            primary: primary,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            validator: (v) {
              final n = int.tryParse(v?.trim() ?? '');
              if (n == null || n <= 0 || n > 18) return 'required'.tr();
              return null;
            },
          ),
          if (_error != null) ...[10.kh, _ErrorRow(error: _error!)],
          24.kh,
          _PrimaryButton(
            label: 'onboarding_finish'.tr(),
            primary: primary,
            loading: _loading,
            onPressed: _submit,
          ),
          8.kh,
          _GhostButton(
            label: 'back'.tr(),
            onTap: () => setState(() {
              _step = 0;
              _error = null;
            }),
          ),
          8.kh,
        ],
      ),
    );
  }
}

// ─── Step header ──────────────────────────────────────────────────────────────

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.step,
    required this.total,
    required this.emoji,
    required this.title,
    required this.primary,
  });

  final int step;
  final int total;
  final String emoji;
  final String title;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step dots
        Row(
          children: List.generate(total, (i) {
            final active = i == step;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOut,
              margin: EdgeInsets.only(right: 5.w),
              width: active ? 20.w : 6.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: active ? primary : const Color(0xFFDDE1EB),
                borderRadius: BorderRadius.circular(3.r),
              ),
            );
          }),
        ),
        16.kh,
        // Emoji
        Text(emoji, style: TextStyle(fontSize: 36.sp)),
        12.kh,
        // Title
        Text(
          title,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A1A2E),
            height: 1.2,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

// ─── Clean input field ────────────────────────────────────────────────────────

class _CleanField extends StatelessWidget {
  const _CleanField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.primary,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Color primary;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      autofocus: autofocus,
      cursorColor: primary,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1A1A2E),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: const Color(0xFF9CA3AF),
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: TextStyle(
          color: primary,
          fontWeight: FontWeight.w600,
          fontSize: 12.sp,
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 16.w, right: 12.w),
          child: Icon(icon, color: const Color(0xFF9CA3AF), size: 20.r),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: const Color(0xFFF5F5F7),
        contentPadding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide.none,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        errorStyle: TextStyle(fontSize: 11.sp, color: const Color(0xFFEF4444)),
      ),
    );
  }
}

// ─── Primary button ───────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.primary,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final Color primary;
  final VoidCallback onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onPressed,
      child: Container(
        height: 52.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, const Color(0xFFFF7093)],
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.28),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child:
                      CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.1,
                  ),
                ),
        ),
      ),
    );
  }
}

// ─── Ghost button ─────────────────────────────────────────────────────────────

class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 40.h,
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }
}

// ─── Error row ────────────────────────────────────────────────────────────────

class _ErrorRow extends StatelessWidget {
  const _ErrorRow({required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(CupertinoIcons.exclamationmark_circle,
            size: 14, color: Color(0xFFEF4444)),
        6.kw,
        Expanded(
          child: Text(
            error,
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFFEF4444),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
