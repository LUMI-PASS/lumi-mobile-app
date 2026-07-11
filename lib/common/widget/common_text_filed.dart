import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CommonTextField extends StatefulWidget {
  const CommonTextField(
      {super.key,
      this.hint,
      this.controller,
      this.obscureText = false,
      this.prefixIcon,
      this.errorText,
      this.onChanged,
      this.keyboardType,
      this.inputFormatter,
      this.enabled,
      this.suffix,
      this.mask,
      this.maxLength,
      this.enabledBorderColor,
      this.background,
      this.suffixPressed,
      this.moneyInput = false,
      this.autofocus = false,
      this.padding,
      this.initialValue,
      this.textInputAction,
      this.labelText,
      this.onTap,
      this.minLines,
      this.maxLines = 1,
      this.validator,
      this.isNext,
      this.focusNode,
      this.nextFocusNode,
      this.disabledBorderColor,
      this.textColor,
      this.hintColor,
      this.needToCapitalize});

  final String? hint;
  final Widget? prefixIcon;
  final Widget? suffix;
  final TextEditingController? controller;
  final bool obscureText;
  final bool? enabled;
  final String? labelText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatter;
  final Color? enabledBorderColor;
  final Color? disabledBorderColor;
  final Color? background;
  final String? mask;
  final int? maxLength;
  final VoidCallback? suffixPressed;
  final bool moneyInput;
  final bool autofocus;
  final EdgeInsets? padding;
  final String? initialValue;
  final TextInputAction? textInputAction;
  final GestureTapCallback? onTap;
  final int? maxLines;
  final int? minLines;
  final FormFieldValidator? validator;
  final bool? isNext;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final Color? textColor;
  final Color? hintColor;
  final bool? needToCapitalize;

  @override
  State<CommonTextField> createState() => _CommonTextFieldState();
}

class _CommonTextFieldState extends State<CommonTextField> {
  bool passwordVisible = false;
  late MaskTextInputFormatter maskFormatter;
  final FocusNode _textFieldFocusNode = FocusNode();
  List<TextInputFormatter> inputFormatters = [];
  TextEditingController? _internalController;

  TextEditingController get _effectiveController =>
      widget.controller ?? _internalController!;

  @override
  void initState() {
    passwordVisible = widget.obscureText;
    super.initState();
    if (widget.controller == null) {
      _internalController = TextEditingController(text: widget.initialValue);
    }
    maskFormatter = MaskTextInputFormatter(
      mask: widget.mask,
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
    );
    inputFormatters.addAll(widget.inputFormatter ?? []);
    inputFormatters.add(maskFormatter);
    if (widget.needToCapitalize == true) {
      inputFormatters.add(CapitalizeFirstLetterFormatter());
    }
  }

  @override
  void dispose() {
    maskFormatter.clear();
    _internalController?.dispose();
    super.dispose();
  }

  Widget _buildPrefixIcon() {
    if (widget.prefixIcon == null) return const SizedBox.shrink();

    return Container(
      width: 70.w,
      height: 50.h,
      alignment: Alignment.center,
      child: widget.prefixIcon,
    );
  }

  Widget _buildSuffixIcon() {
    if (widget.obscureText) {
      return Container(
        width: 48.w, // Fixed width for consistency
        height: 64.h, // Match field height
        alignment: Alignment.center,
        child: InkWell(
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          child: passwordVisible
              ? Assets.icons.eye.svg(width: 16.w, height: 16.h)
              : Assets.icons.eyeOff.svg(width: 16.w, height: 16.h),
          onTap: () {
            setState(() => passwordVisible = !passwordVisible);
          },
        ),
      );
    } else if (widget.suffix != null) {
      return GestureDetector(
        onTap: () {
          _effectiveController.clear();
          widget.suffixPressed?.call();
        },
        child: Container(
          width: 48.w,
          height: 64.h,
          alignment: Alignment.center,
          child: widget.suffix,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 64.h,
          child: TextFormField(
            focusNode: widget.focusNode,
            onFieldSubmitted: (_) {
              if (widget.isNext == true) {
                FocusScope.of(context).requestFocus(widget.nextFocusNode);
              }
            },
            validator: widget.validator,
            textAlignVertical: TextAlignVertical.center,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            autofocus: widget.autofocus,
            enabled: widget.enabled,
            controller: _effectiveController,
            onTap: widget.onTap,
            keyboardType: widget.keyboardType,
            obscureText: passwordVisible,
            cursorColor: context.colors.primary,
            textAlign: TextAlign.start,
            inputFormatters: inputFormatters,
            onChanged: widget.onChanged == null
                ? null
                : (phone) {
                    final number = widget.moneyInput
                        ? phone.replaceAll(' ', '')
                        : maskFormatter.unmaskText(phone);
                    widget.onChanged!(number);
                  },
            textInputAction: widget.isNext == true
                ? TextInputAction.next
                : TextInputAction.done,
            decoration: InputDecoration(
              filled: true,
              labelText: widget.labelText,
              alignLabelWithHint: true,
              labelStyle:
                  AppText.medium12.copyWith(color: context.colors.textPrimary),
              fillColor:
                  widget.background ?? context.colors.border.withOpacity(0.2),
              hintText: widget.hint,
              error: null,
              // errorMaxLines: 5,
              // Fixed content padding for consistent height
              contentPadding: widget.padding ??
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              // Use custom prefix icon with fixed dimensions
              prefixIcon: widget.prefixIcon != null ? _buildPrefixIcon() : null,
              prefixIconConstraints: widget.prefixIcon != null
                  ? BoxConstraints(
                      minWidth: 60.w,
                      maxWidth: 64.w,
                      minHeight: 50.h,
                      maxHeight: 50.h,
                    )
                  : null,
              hintStyle: AppText.regular16.copyWith(
                color: widget.hintColor ?? context.colors.textPlaceholder,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                    color: widget.disabledBorderColor ?? context.colors.border),
                borderRadius: BorderRadius.circular(12.r),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: widget.enabledBorderColor ?? context.colors.border),
                borderRadius: BorderRadius.circular(12.r),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: widget.disabledBorderColor ?? context.colors.border),
                borderRadius: BorderRadius.circular(12.r),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: widget.enabledBorderColor ?? context.colors.primary),
                borderRadius: BorderRadius.circular(12.r),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: context.colors.error),
                borderRadius: BorderRadius.circular(12.r),
              ),
              // errorStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, color: context.colors.error),
              // Use custom suffix icon with fixed dimensions
              suffixIcon: (widget.obscureText || widget.suffix != null)
                  ? _buildSuffixIcon()
                  : null,
              suffixIconConstraints:
                  (widget.obscureText || widget.suffix != null)
                      ? BoxConstraints(
                          minWidth: 48.w,
                          maxWidth: 48.w,
                          minHeight: 50.h,
                          maxHeight: 50.h,
                        )
                      : null,
            ),
            style: AppText.regular16.copyWith(
              color: widget.textColor ?? context.colors.textPrimary,
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          2.kh,
          widget.errorText!.s(12).c(context.colors.error)
        ]
      ],
    );
  }
}

class PriceInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text;

    newText = newText.replaceAll(RegExp(r'\D'), '');

    String formattedText = '';
    int len = newText.length;
    for (int i = len - 1; i >= 0; i--) {
      formattedText = newText[i] + formattedText;
      if ((len - i) % 3 == 0 && i != 0) {
        formattedText = ' $formattedText';
      }
    }

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class CapitalizeFirstLetterFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    final capitalized = text[0].toUpperCase() + text.substring(1);
    return newValue.copyWith(
      text: capitalized,
      selection: TextSelection.collapsed(offset: capitalized.length),
    );
  }
}
