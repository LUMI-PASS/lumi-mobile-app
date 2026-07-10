import 'package:flutter/material.dart';
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
    final colors = context.appColors;
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
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final bool hasError;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final color = hasError ? AppColors.error : colors.textPrimary;
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
        LengthLimitingTextInputFormatter(4),
      ],
      style: AppText.code56.copyWith(color: color, letterSpacing: 14.w),
      decoration: InputDecoration(
        isCollapsed: true,
        border: InputBorder.none,
        counterText: '',
        hintText: '0000',
        hintStyle: AppText.code56
            .copyWith(color: colors.textPlaceholder, letterSpacing: 14.w),
      ),
      onChanged: onChanged,
    );
  }
}
