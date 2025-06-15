import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';

class ChessTextTheme {
  ///   56 px
  final TextStyle largeTitle1Regular;

  ///   56 px
  final TextStyle largeTitle1Bold;

  ///   40 px
  final TextStyle largeTitle2Regular;

  ///   40 px
  final TextStyle largeTitle2Bold;

  ///   32 px
  final TextStyle largeTitle3Regular;

  ///   32 px
  final TextStyle largeTitle3Bold;

  ///   26 px
  final TextStyle title1Bold;

  ///   26 px
  final TextStyle title1Regular;

  ///   24 px
  final TextStyle title2Bold;

  ///   24 px
  final TextStyle title2Regular;

  ///   20 px
  final TextStyle title3Bold;

  ///   20 px
  final TextStyle title3Regular;

  ///   16 px
  final TextStyle headlineBold;

  ///   16 px
  final TextStyle headlineSemibold;

  ///   16 px
  final TextStyle bodyMedium;

  ///   16 px
  final TextStyle bodyRegular;

  ///   15 px
  final TextStyle calloutMedium;

  ///   15 px
  final TextStyle calloutRegular;

  ///   14 px
  final TextStyle subheadlineRegular;

  ///   14 px
  final TextStyle subheadlineSemibold;

  ///   13 px
  final TextStyle footnoteMedium;

  ///   13 px
  final TextStyle footnoteRegular;

  ///   12 px
  final TextStyle caption1Medium;

  ///   12 px
  final TextStyle caption1Regular;

  ///   11 px
  final TextStyle caption2Semibold;

  ///   11 px
  final TextStyle caption2Regular;

  ChessTextTheme({
    required this.largeTitle1Bold,
    required this.largeTitle1Regular,
    required this.largeTitle2Bold,
    required this.largeTitle2Regular,
    required this.largeTitle3Bold,
    required this.largeTitle3Regular,
    required this.title1Bold,
    required this.title1Regular,
    required this.title2Bold,
    required this.title2Regular,
    required this.title3Bold,
    required this.title3Regular,
    required this.headlineBold,
    required this.headlineSemibold,
    required this.bodyMedium,
    required this.bodyRegular,
    required this.calloutMedium,
    required this.calloutRegular,
    required this.subheadlineRegular,
    required this.subheadlineSemibold,
    required this.footnoteMedium,
    required this.footnoteRegular,
    required this.caption1Medium,
    required this.caption1Regular,
    required this.caption2Semibold,
    required this.caption2Regular,
  });

  static ChessTextTheme of(BuildContext context) {
    return _ChessThemeInheritedWidget.of(context).textTheme;
  }

  factory ChessTextTheme.defaultTheme() {
    const largeTitle1 = TextStyle(
      fontSize: 54,
      height: 68 / 56,
      fontWeight: FontWeight.w600,
      fontFamily: FontFamily.nunito,
    );

    const largeTitle2 = TextStyle(
      fontSize: 40,
      height: 48 / 40,
      fontFamily: FontFamily.nunito,
      fontWeight: FontWeight.w600,
    );

    const largeTitle3 = TextStyle(
      fontSize: 32,
      height: 38 / 32,
      fontFamily: FontFamily.nunito,
      fontWeight: FontWeight.w600,
    );

    const title1 = TextStyle(
      fontSize: 26,
      height: 34 / 26,
      fontFamily: FontFamily.nunito,
      fontWeight: FontWeight.w600,
    );

    const title2 = TextStyle(
      fontSize: 24,
      height: 32 / 24,
      fontFamily: FontFamily.nunito,
      fontWeight: FontWeight.w600,
    );

    const title3 = TextStyle(
      fontSize: 20,
      height: 28 / 20,
      fontFamily: FontFamily.nunito,
      fontWeight: FontWeight.w600,
    );

    const headline = TextStyle(
      fontSize: 16,
      height: 24 / 16,
      letterSpacing: -0.2,
      fontFamily: FontFamily.nunito,
      fontWeight: FontWeight.w600,
    );

    const body = TextStyle(
      fontSize: 16,
      height: 24 / 16,
      letterSpacing: -0.2,
      fontFamily: FontFamily.nunito,
      fontWeight: FontWeight.w600,
    );

    const callout = TextStyle(
      fontSize: 15,
      height: 22 / 15,
      letterSpacing: -0.16,
      fontFamily: FontFamily.nunito,
      fontWeight: FontWeight.w600,
    );

    const subheadline = TextStyle(
      fontSize: 14,
      height: 20 / 14,
      letterSpacing: -0.1,
      fontFamily: FontFamily.nunito,
      fontWeight: FontWeight.w600,
    );

    const footnote = TextStyle(
      fontSize: 13,
      height: 18 / 13,
      letterSpacing: -0.08,
      fontFamily: FontFamily.nunito,
      fontWeight: FontWeight.w600,
    );

    const caption1 = TextStyle(
      fontSize: 12,
      height: 16 / 12,
      fontFamily: FontFamily.nunito,
      fontWeight: FontWeight.w600,
    );

    const caption2 = TextStyle(
      fontSize: 11,
      height: 14 / 11,
      fontFamily: FontFamily.nunito,
      fontWeight: FontWeight.w600,
    );

    return ChessTextTheme(
      largeTitle1Bold: largeTitle1.copyWith(fontWeight: FontWeight.w800),
      largeTitle1Regular: largeTitle1,
      largeTitle2Bold: largeTitle2.copyWith(fontWeight: FontWeight.w800),
      largeTitle2Regular: largeTitle2,
      largeTitle3Bold: largeTitle3.copyWith(fontWeight: FontWeight.w800),
      largeTitle3Regular: largeTitle3,
      title1Bold: title1.copyWith(fontWeight: FontWeight.w800),
      title1Regular: title1,
      title2Bold: title2.copyWith(fontWeight: FontWeight.w800),
      title2Regular: title2,
      title3Bold: title3.copyWith(fontWeight: FontWeight.w800),
      title3Regular: title3,
      headlineSemibold: headline,
      headlineBold: headline.copyWith(fontWeight: FontWeight.w800),
      bodyRegular: body,
      bodyMedium: body.copyWith(fontWeight: FontWeight.w500),
      calloutRegular: callout,
      calloutMedium: callout.copyWith(fontWeight: FontWeight.w500),
      subheadlineRegular: subheadline,
      subheadlineSemibold: subheadline.copyWith(fontWeight: FontWeight.w600),
      footnoteRegular: footnote,
      footnoteMedium: footnote.copyWith(fontWeight: FontWeight.w500),
      caption1Regular: caption1,
      caption1Medium: caption1.copyWith(fontWeight: FontWeight.w500),
      caption2Regular: caption2,
      caption2Semibold: caption2.copyWith(fontWeight: FontWeight.w600),
    );
  }

  TextTheme get theme => TextTheme(
        displayLarge: largeTitle1Regular,
        displayMedium: largeTitle2Regular,
        displaySmall: largeTitle3Regular,
        headlineLarge: title1Regular,
        headlineMedium: title2Regular,
        headlineSmall: title3Regular,
        titleLarge: headlineSemibold,
        titleMedium: bodyRegular,
        titleSmall: calloutRegular,
        labelLarge: subheadlineRegular,
        labelMedium: subheadlineSemibold,
        labelSmall: footnoteRegular,
        bodyLarge: caption1Regular,
        bodyMedium: caption1Medium,
        bodySmall: caption2Regular,
      );

  Map<String, TextStyle> get htmlStyle => {
        "h1": largeTitle3Regular,
        "h2": title2Regular,
        "h3": title3Regular,
        "h4": bodyMedium,
        "h5": caption1Medium,
        "h6": caption2Regular,
        "p": bodyRegular,
        "li": bodyRegular,
        "blockquote": bodyRegular.copyWith(fontWeight: FontWeight.bold),
      };
}

class _ChessThemeInheritedWidget extends InheritedWidget {
  const _ChessThemeInheritedWidget({
    required this.textTheme,
    required super.child,
  });

  final ChessTextTheme textTheme;

  static _ChessThemeInheritedWidget of(BuildContext context) {
    final _ChessThemeInheritedWidget? result = context
        .dependOnInheritedWidgetOfExactType<_ChessThemeInheritedWidget>();
    assert(result != null, 'No ChessThemeWidget found in context');

    return result!;
  }

  @override
  bool updateShouldNotify(_ChessThemeInheritedWidget old) {
    return old.textTheme != textTheme;
  }
}

class ChessThemeProvider extends StatelessWidget {
  final WidgetBuilder builder;

  const ChessThemeProvider({
    required this.builder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return _ChessThemeInheritedWidget(
      textTheme: ChessTextTheme.defaultTheme(),
      child: Builder(builder: builder),
    );
  }
}
