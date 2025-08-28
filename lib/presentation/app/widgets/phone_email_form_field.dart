import 'package:flexobo/common/constants/constants.dart';
import 'package:flexobo/common/extensions/sizedbox_extensions.dart';
import 'package:flexobo/common/extensions/text_extensions.dart';
import 'package:flexobo/common/extensions/theme_extensions.dart';
import 'package:flexobo/common/gen/assets.gen.dart';
import 'package:flexobo/common/gen/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class PhoneEmailFormField extends StatefulWidget {
  PhoneEmailFormField(
      {super.key,
      required this.phoneController,
      required this.isMaskMatched,
      this.errorPhone,
      this.onClear,
      this.isNext,
      this.focusNode,
      this.nextFocusNode});

  final TextEditingController phoneController;
  final ValueChanged<bool> isMaskMatched;
  String? errorPhone;
  final VoidCallback? onClear;
  final bool? isNext;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;

  @override
  State<PhoneEmailFormField> createState() => _PhoneEmailFormFieldState();
}

class _PhoneEmailFormFieldState extends State<PhoneEmailFormField> {
  String? _selectedCode;
  String _mask = "";
  final countryMap = Constants.countryMap;
  bool? isMaskMatched;
  String? errorPhone;
  Color textColor = Colors.black;
  bool _isFirstInput = true;
  bool _isEmail = false;

  // Regular expressions for validation
  final RegExp _emailRegex = RegExp(r'^[a-zA-Z0-9@._\-]+$');
  final RegExp _validEmailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final RegExp _emailStartRegex = RegExp(r'^[a-zA-Z@._\-]');
  final RegExp _phoneRegex = RegExp(r'^[0-9\+\-\(\) ]+$');

  @override
  void initState() {
    super.initState();
    if (widget.phoneController.text.isNotEmpty) {
      _isFirstInput = false;
      if (_phoneRegex.hasMatch(widget.phoneController.text)) {
        _isEmail = false;
        _onInputChanged(widget.phoneController.text);
      } else {
        _isEmail = true;
        _validateEmail(widget.phoneController.text);
      }
      setState(() {});
    }
  }

  void _checkIfMaskIsComplete(String input) {
    if (_mask.isEmpty) return;
    int expectedDigits = _mask.split('').where((char) => char == '#').length;
    setState(() {
      isMaskMatched = input.length == expectedDigits;
      if (isMaskMatched == true) {
        widget.errorPhone = null;
      }
    });

    widget.isMaskMatched(isMaskMatched ?? false);
  }

  void _validateEmail(String email) {
    setState(() {
      isMaskMatched = _validEmailRegex.hasMatch(email);
    });
    widget.isMaskMatched(isMaskMatched ?? false);
  }

  void _onInputChanged(String value) {
    if (value.isEmpty) {
      setState(() {
        _selectedCode = null;
        _mask = "";
        isMaskMatched = null;
        _isFirstInput = true;
        _isEmail = false;
      });
      return;
    }

    // Detect if input is an email based on first character
    if (_isFirstInput) {
      if (_emailStartRegex.hasMatch(value)) {
        setState(() {
          _isEmail = true;
        });
        _validateEmail(value);
        return;
      } else {
        setState(() {
          _isEmail = false;
        });
      }
    }

    // If already determined to be email, validate it
    if (_isEmail) {
      _validateEmail(value);
      return;
    }

    // Phone number formatting logic
    if (_isFirstInput && value.isNotEmpty) {
      if (!value.startsWith("+")) {
        value = "+" + value;
        widget.phoneController.value = TextEditingValue(
          text: value,
          selection: TextSelection.collapsed(offset: value.length),
        );
      }
      _isFirstInput = false;
    }

    if (!_isFirstInput && !value.startsWith("+")) {
      value = "+" + value;
      widget.phoneController.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }

    if (_selectedCode == null || !value.startsWith(_selectedCode!)) {
      _selectedCode = null;
      for (var country in countryMap) {
        if (value.startsWith(country["code"]!)) {
          setState(() {
            _selectedCode = country["code"];
            _mask = country["mask"]!;
          });
          break;
        }
      }
    }

    if (_selectedCode != null && value.startsWith(_selectedCode!)) {
      String remaining = value.replaceFirst(_selectedCode!, '');
      _applyMask(remaining);
      _checkIfMaskIsComplete(remaining);
    }
  }

  void _applyMask(String input) {
    if (_mask.isEmpty) return;

    String result = _selectedCode!;
    int inputIndex = 0;
    for (int i = 0; i < _mask.length && inputIndex < input.length; i++) {
      if (_mask[i] == '#') {
        // Add the next digit from input
        if (inputIndex < input.length) {
          result += input[inputIndex];
          inputIndex++;
        }
      } else {
        result += _mask[i];
      }
    }

    widget.phoneController.value = TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }

  void _clearInput() {
    widget.phoneController.clear();
    setState(() {
      _selectedCode = null;
      _mask = "";
      isMaskMatched = null;
      widget.errorPhone = null;
      _isFirstInput = true;
      _isEmail = false;
    });
    widget.isMaskMatched(false);
    if (widget.onClear != null) {
      widget.onClear!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 50.h,
          child: TextFormField(
              autofocus: true,
              textInputAction: widget.isNext == true
                  ? TextInputAction.next
                  : TextInputAction.done,
              controller: widget.phoneController,
              onFieldSubmitted: (_) {
                if (widget.isNext == true) {
                  FocusScope.of(context).requestFocus(widget.nextFocusNode);
                }
                if (isMaskMatched != true) {
                  errorPhone = "Телефон указан в неправильном формате.";
                } else {
                  errorPhone = null;
                }
                setState(() {});
              },
              // keyboardType: _isEmail ? TextInputType.emailAddress : TextInputType.phone,
              textAlignVertical: TextAlignVertical.center,
              onChanged: _onInputChanged,
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: textColor),
              decoration: InputDecoration(
                  filled: true,
                  alignLabelWithHint: true,
                  labelStyle: GoogleFonts.onest(
                      fontSize: 12, color: context.colors.display),
                  fillColor: context.colors.grey.withOpacity(0.2),
                  hintText: Strings.emailOrPhoneHint,
                  errorMaxLines: 5,
                  contentPadding:  EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  suffixIcon: widget.errorPhone != null
                      ? Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 12.h),
                          child: Assets.icons.errorIcon
                              .svg(width: 16.w, height: 16.h),
                        )
                      : null,
                  hintStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF717680),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: context.colors.grey),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: context.colors.grey),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: context.colors.grey),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: context.colors.primary01),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: context.colors.primary2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: context.colors.primary2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  errorStyle: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: context.colors.primary2)),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@.]')),
                LengthLimitingTextInputFormatter(_isEmail ? 100 : 20),
              ]),
        ),
        if (widget.errorPhone != null)
          ...[
            2.kh,
            widget.errorPhone!.s(12).c(context.colors.warningDark)
          ]

      ],
    );
  }
}
