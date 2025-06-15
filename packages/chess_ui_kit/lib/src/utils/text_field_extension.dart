import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

extension TextFieldTypeExtension on ChessTextField {
  Color backgroundColor({bool hasFocus = false}) {
    if (!isValueValid) return ChessColors.errorBg;

    if (hasFocus) return ChessColors.greyG300;

    return ChessColors.greyG400;
  }

  bool get isPhoneType => type == TextFieldType.phone;

  Color labelColor({bool hasFocus = false}) {
    if (readOnly) return ChessColors.white;

    if (!isValueValid) return ChessColors.errorDefault;

    if (hasFocus) return ChessColors.white;

    return ChessColors.white;
  }

  Color get foregroundColor {
    if (readOnly) return ChessColors.greyG60;

    return ChessColors.white;
  }

  bool checkMaskCountry({Country? country}) => country?.isUzbekistan ?? false;
}
