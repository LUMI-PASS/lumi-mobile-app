import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

abstract class StaticColors {
  static const black = Color(0xFF000000);
  static const blueWhale = Color(0xFFA652C7);
  static const white = Color(0xFFFFFFFF);
  static const vividCerulean = Color(0xFF639223);
  static const midnight = Color(0xFF242B3A);
  static const raven = Color(0xFF6D717C);
  static const aluminium = Color(0xFF203645);
  static const solitude = Color(0xFFEFEEF5);
  static const bittersweet = Color(0xFFFF4028);
  static const speechGreen = Color(0xFF1F2731);
  static const limeGreen = Color(0xFF34AD40);
  static const limeOpacityGreen = Color(0xFFDCFAE6);
  static const viking = Color(0xFF41B0B7);
  static const whiteLilac = Color(0xFFD5D7DA);
  static const mahogany = Color(0xFFC93E3E);
  static final snow = const Color(0xFF40281A).withOpacity(0.1);
  static const lavender = Colors.blue;
  static const primary = Color(0xFFA652C7);
}

@singleton
class DefaultThemeColors {
  final primary = StaticColors.blueWhale;
  final primary01 = StaticColors.speechGreen;
  final primary2 = StaticColors.bittersweet;
  final primary005 = StaticColors.blueWhale.withOpacity(0.05);
  final onPrimary = StaticColors.white;
  final black = StaticColors.black;
  final headline = StaticColors.blueWhale;
  final greenHeadline = StaticColors.limeGreen;
  final greenHeadlineOpacity = StaticColors.limeOpacityGreen;
  final window = StaticColors.solitude;
  final window05 = StaticColors.solitude.withOpacity(0.5);
  final label = StaticColors.midnight;
  final title = StaticColors.raven;
  final title01 = StaticColors.raven.withOpacity(0.1);
  final errorColor = StaticColors.bittersweet;
  final display = StaticColors.aluminium;
  final avatarMain = StaticColors.speechGreen;
  final avatarSecond = StaticColors.viking;
  final grey = StaticColors.whiteLilac;
  final grey05 = StaticColors.whiteLilac.withOpacity(0.5);
  final disable = StaticColors.vividCerulean.withOpacity(0.15);
  final warningDark = StaticColors.mahogany;
  final warningLight = StaticColors.snow;
  final differ = StaticColors.lavender;
}
