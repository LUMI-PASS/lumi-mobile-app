import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/painting.dart';

abstract class ChessShadows {
  ChessShadows._();

  static const List<BoxShadow> shadowXs = [
    BoxShadow(
      color: Color(0x1A000000), // 10% black
      offset: Offset(0, 1),
      spreadRadius: 0,
      blurStyle: BlurStyle.normal,
      blurRadius: 2,
    )
  ];

  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x1F000000), // 12% black
      offset: Offset(0, 1),
      spreadRadius: 0,
      blurStyle: BlurStyle.normal,
      blurRadius: 3,
    ),
    BoxShadow(
      color: Color(0x0D000000), // 5% black
      offset: Offset(0, 1),
      spreadRadius: 1,
      blurStyle: BlurStyle.normal,
      blurRadius: 2,
    )
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x26000000), // 15% black
      offset: Offset(0, 4),
      spreadRadius: -2,
      blurStyle: BlurStyle.normal,
      blurRadius: 6,
    ),
    BoxShadow(
      color: Color(0x0F000000), // 6% black
      offset: Offset(0, 2),
      spreadRadius: -2,
      blurStyle: BlurStyle.normal,
      blurRadius: 4,
    )
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x33000000), // 20% black
      offset: Offset(0, 10),
      spreadRadius: -3,
      blurStyle: BlurStyle.normal,
      blurRadius: 15,
    ),
    BoxShadow(
      color: Color(0x1A000000), // 10% black
      offset: Offset(0, 4),
      spreadRadius: -2,
      blurStyle: BlurStyle.normal,
      blurRadius: 6,
    )
  ];

  static const List<BoxShadow> shadowXl = [
    BoxShadow(
      color: Color(0x40000000), // 25% black
      blurStyle: BlurStyle.normal,
      offset: Offset(0, 20),
      blurRadius: 25,
      spreadRadius: -5,
    ),
    BoxShadow(
      color: Color(0x1A000000), // 10% black
      blurStyle: BlurStyle.normal,
      offset: Offset(0, 8),
      blurRadius: 10,
      spreadRadius: -4,
    )
  ];

  static const List<BoxShadow> shadow2xl = [
    BoxShadow(
      color: Color(0x4D000000), // 30% black
      blurStyle: BlurStyle.normal,
      offset: Offset(0, 25),
      blurRadius: 50,
      spreadRadius: -12,
    ),
  ];

  static const List<BoxShadow> shadow3xl = [
    BoxShadow(
      color: Color(0x59000000), // 35% black
      blurStyle: BlurStyle.normal,
      offset: Offset(0, 35),
      blurRadius: 60,
      spreadRadius: -15,
    ),
  ];

  // Additional dark-themed shadows
  static const List<BoxShadow> shadowInner = [
    BoxShadow(
      color: Color(0x26000000), // 15% black
      offset: Offset(0, 2),
      spreadRadius: -2,
      blurStyle: BlurStyle.inner,
      blurRadius: 4,
    )
  ];

  static const List<BoxShadow> shadowGlow = [
    BoxShadow(
      color: Color(0x4D3B82F6), // Blue glow with 30% opacity
      offset: Offset(0, 0),
      spreadRadius: 0,
      blurStyle: BlurStyle.normal,
      blurRadius: 8,
    )
  ];

  static const List<BoxShadow> shadowAccent = [
    BoxShadow(
      color: Color(0x33667EEA), // Purple accent with 20% opacity
      offset: Offset(0, 4),
      spreadRadius: 0,
      blurStyle: BlurStyle.normal,
      blurRadius: 12,
    )
  ];
}