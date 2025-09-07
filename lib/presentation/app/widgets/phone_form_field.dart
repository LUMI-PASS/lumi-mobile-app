import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumi_pass/common/constants/constants.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';

class PhoneFormField extends StatefulWidget {
  PhoneFormField(
      {super.key,
      required this.phoneController,
      required this.isMaskMatched,
      this.errorPhone,
      this.onClear,
      required this.focusNode,
      required this.nextFocusNode,
      this.isNext});

  final TextEditingController phoneController;
  final ValueChanged<bool> isMaskMatched;
  String? errorPhone;
  final VoidCallback? onClear;
  final bool? isNext;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;

  @override
  State<PhoneFormField> createState() => _PhoneFormFieldState();
}

class _PhoneFormFieldState extends State<PhoneFormField> {
  String? _selectedCode;
  String _mask = "";
  final countryMap = Constants.countryMap;
  bool? isMaskMatched;
  String? errorPhone;
  Color textColor = Colors.black;
  bool _isFirstInput = true;

  @override
  void initState() {
    super.initState();
    if (widget.phoneController.text.isNotEmpty) {
      _isFirstInput = false;
      _onInputChanged(widget.phoneController.text);
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

  void _onInputChanged(String value) {
    // If the input is empty, reset everything
    if (value.isEmpty) {
      setState(() {
        _selectedCode = null;
        _mask = "";
        isMaskMatched = null;
        _isFirstInput = true;
      });
      return;
    }

    // If this is the first digit entered, prepend "+"
    if (_isFirstInput && value.isNotEmpty) {
      if (!value.startsWith("+")) {
        value = "+$value";
        widget.phoneController.value = TextEditingValue(
          text: value,
          selection: TextSelection.collapsed(offset: value.length),
        );
      }
      _isFirstInput = false;
    }

    // Ensure "+" is preserved once added
    if (!_isFirstInput && !value.startsWith("+")) {
      value = "+$value";
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
    });
    widget.isMaskMatched(false);
    if (widget.onClear != null) {
      widget.onClear!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
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
      autofocus: false,
      focusNode: widget.focusNode,
      controller: widget.phoneController,
      keyboardType: TextInputType.phone,
      textAlignVertical: TextAlignVertical.center,
      textInputAction: widget.isNext == true ? TextInputAction.next : TextInputAction.done,
      onChanged: _onInputChanged,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF717680)),
      decoration: InputDecoration(
        filled: true,
        labelStyle: GoogleFonts.onest(fontSize: 12.sp, color: context.colors.display),
        fillColor: context.colors.grey.withOpacity(0.2),
        hintText: "Введите номер телефона *",
        errorMaxLines: 5,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        suffix: widget.errorPhone != null ? Assets.icons.errorIcon.svg() : Container(),
        hintStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF717680),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: context.colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: context.colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: context.colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: context.colors.primary01),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: context.colors.errorColor),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
      ],
    );
  }
}
