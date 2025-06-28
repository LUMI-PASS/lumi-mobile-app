import 'package:flutter/painting.dart';

/// Colors from https://www.figma.com/file/7iqNEV4Modb3qmTsVDjH0t/UzChess?type=design&node-id=231-12969&mode=design&t=ZbTlZzhcFbg1Tk3l-0
abstract class ChessColors {
  ChessColors._();

  // Base colors
  static const black = Color(0xff000000);
  static const white = Color(0xffffffff);
  static const transparent = Color(0x00000000);
  static const window = Color(0xFFF3F5F6);

  // Grey colors
  static const greyG10 = Color(0xfffafafa);
  static const greyG20 = Color(0xfff6f6f6);
  static const greyG30 = Color(0xffececec);
  static const greyG40 = Color(0xffe0e0e0);
  static const greyG50 = Color(0xffc4c4c4);
  static const greyG60 = Color(0xffb6b6b6);
  static const greyG70 = Color(0xffaaaaaa);
  static const greyG80 = Color(0xff9c9c9c);
  static const greyG90 = Color(0xff8e8e8e);
  static const greyG100 = Color(0xff808080);
  static const greyG200 = Color(0xff717272);
  static const greyG300 = Color(0xff636464);
  static const greyG400 = Color(0xff575858);
  static const greyG500 = Color(0xff494a4a);
  static const greyG600 = Color(0xff3d3e3e);
  static const greyG700 = Color(0xff2d2e2e);
  static const greyG800 = Color(0xff1f2020);
  static const greyG900 = Color(0xff131414);

  // Primary colors
  static const primaryBg = Color(0xffe7f1fb);
  static const primaryBgStrong = Color(0xffb391ed);
  static const primaryDefaultWeak = Color(0xff996def);
  static const primaryDefault = Color(0xff6c1dea);
  static const primaryDefaultStrong = Color(0xff4b0b99);

  // Success colors
  static const successBg = Color(0xffeff6f5);
  static const successBgStrong = Color(0xffc6e6de);
  static const successDefaultWeak = Color(0xff3ca98f);
  static const successDefault = Color(0xff119676);
  static const successDefaultStrong = Color(0xff0e8064);

  // Warning colors
  static const warningBg = Color(0xfffffae7);
  static const warningBgStrong = Color(0xfffff3c6);
  static const warningDefaultWeak = Color(0xfffed63b);
  static const warningDefault = Color(0xfffecd10);
  static const warningDefaultStrong = Color(0xffd8ae0e);

  // Error colors
  static const errorBg = Color(0xffffe6ed);
  static const errorBgStrong = Color(0xfffd96b5);
  static const errorDefaultWeak = Color(0xfffc6b97);
  static const errorDefault = Color(0xfffa004b);
  static const errorDefaultStrong = Color(0xffaf0035);
}
