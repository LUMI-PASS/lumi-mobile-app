import 'package:flutter/material.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

/// Big centered phone entry — "+998 000 00 00". The `+998` prefix is fixed;
/// the grey placeholder digits and typed digits share one large rounded style.
class PhoneNumberField extends StatefulWidget {
  const PhoneNumberField({
    super.key,
    required this.onChanged,
    this.autofocus = true,
  });

  /// Emits the raw 9-digit national number (no prefix, no separators).
  final ValueChanged<String> onChanged;
  final bool autofocus;

  @override
  State<PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<PhoneNumberField> {
  late final MaskTextInputFormatter _mask = MaskTextInputFormatter(
    mask: '## ### ## ##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text('+998 ',
              style: AppText.phone32.copyWith(color: colors.textPrimary)),
          IntrinsicWidth(
            child: TextField(
              autofocus: widget.autofocus,
              keyboardType: TextInputType.number,
              inputFormatters: [_mask],
              style: AppText.phone32.copyWith(color: colors.textPrimary),
              cursorColor: AppColors.brandPurple,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: '00 000 00 00',
                hintStyle:
                    AppText.phone32.copyWith(color: colors.textPlaceholder),
              ),
              onChanged: (text) => widget.onChanged(_mask.getUnmaskedText()),
            ),
          ),
        ],
      ),
    );
  }
}

/// Large centered 4-digit code display — "0 0 0 0". Turns red on error.
class OtpCodeField extends StatelessWidget {
  const OtpCodeField({
    super.key,
    required this.controller,
    this.focusNode,
    this.onChanged,
    this.hasError = false,
    this.autofocus = true,
    this.length = 4,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final bool hasError;
  final bool autofocus;

  /// Digits the code has. Our own SMS login sends 4; a bank's payment OTP is 6,
  /// so the payment sheets pass 6 — a field capped at 4 silently swallowed the
  /// last two digits and every confirmation failed.
  final int length;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = hasError ? AppColors.error : colors.textPrimary;
    // 56pt glyphs at 14pt tracking fit four digits across the narrowest phone;
    // six need to come down or the line overflows its box.
    final base = length > 4
        ? AppText.code56.copyWith(fontSize: 40.sp)
        : AppText.code56;
    final tracking = length > 4 ? 8.w : 14.w;
    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      showCursor: true,
      cursorColor: AppColors.brandPurple,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(length),
      ],
      style: base.copyWith(color: color, letterSpacing: tracking),
      decoration: InputDecoration(
        isCollapsed: true,
        border: InputBorder.none,
        counterText: '',
        hintText: '0' * length,
        hintStyle:
            base.copyWith(color: colors.textPlaceholder, letterSpacing: tracking),
      ),
      onChanged: onChanged,
    );
  }
}
