import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

extension TextFieldTypeExtension on ChessTextField {
  Color backgroundColor({bool hasFocus = false}) {
    if (!isValueValid) return ChessColors.errorBg;

    if (hasFocus) return ChessColors.greyG40;

    return ChessColors.greyG40;
  }

  bool get isPhoneType => type == TextFieldType.phone;

  Color labelColor({bool hasFocus = false}) {
    if (readOnly) return ChessColors.greyG400;

    if (!isValueValid) return ChessColors.errorDefault;

    if (hasFocus) return ChessColors.greyG400;

    return ChessColors.greyG400;
  }

  Color get foregroundColor {
    if (readOnly) return ChessColors.greyG40;

    return ChessColors.greyG40;
  }

  bool checkMaskCountry({Country? country}) => country?.isUzbekistan ?? false;
}
