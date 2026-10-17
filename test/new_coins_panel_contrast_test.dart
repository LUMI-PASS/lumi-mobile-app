import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/data/api_model/new_coins/new_coin_models.dart';
import 'package:lumi_pass/presentation/app/new_coins/widgets/new_coins_widgets.dart';

/// The coin screens follow the theme: a near-white stage with white panels in
/// light, the deepest ink with dark-surface panels in dark, and `textPrimary`
/// on both. Text the colour of its own ground is the failure mode — invisible
/// to the analyzer — so contrast is asserted here, in BOTH themes, against the
/// `coinStage` / `coinPanel` roles the widgets actually paint.
void main() {
  final features = [
    const NewCoinFeature(
      icon: Icons.check_rounded,
      title: 'Activities',
      body: 'Any activity on the catalogue',
      chip: '40 Lumi Coin',
    ),
  ];

  const themes = {
    'light': (Brightness.light, AppColorScheme.light),
    'dark': (Brightness.dark, AppColorScheme.dark),
  };

  double contrast(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    return la > lb ? (la + 0.05) / (lb + 0.05) : (lb + 0.05) / (la + 0.05);
  }

  Widget host(Brightness brightness, AppColorScheme scheme) => ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, __) => MaterialApp(
          theme: ThemeData(brightness: brightness, extensions: [scheme]),
          home: Scaffold(
            backgroundColor: scheme.coinStage,
            body: SingleChildScrollView(
              child: NewCoinPackFeatures(
                tone: NewCoinTone.main(0),
                title: "What's in the pack",
                subtitle: 'Three activities, five days',
                features: features,
              ),
            ),
          ),
        ),
      );

  /// Every `Text` the panel draws, with the colour it is painted in.
  ///
  /// Bare separators ("·") are left out: they are decoration, deliberately
  /// muted, and WCAG's text contrast does not apply to them.
  List<Color?> inkOf(WidgetTester tester) => tester
      .widgetList<Text>(find.byType(Text))
      .where((t) => (t.data ?? '').trim() != '·')
      .map((t) => t.style?.color)
      .toList();

  for (final MapEntry(key: name, value: (brightness, scheme))
      in themes.entries) {
    testWidgets('$name: the panels are painted coinPanel', (tester) async {
      await tester.pumpWidget(host(brightness, scheme));
      await tester.pump();

      final panels = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) => (c.decoration as BoxDecoration?)?.color != null)
          .map((c) => (c.decoration as BoxDecoration).color!)
          .toList();

      // The two cards inside the tone frame.
      expect(
        panels.where((c) => c == scheme.coinPanel),
        hasLength(2),
        reason: 'the header card and the feature list',
      );
    });

    testWidgets('$name: every label on a panel is readable', (tester) async {
      await tester.pumpWidget(host(brightness, scheme));
      await tester.pump();

      final inks = inkOf(tester);
      expect(inks, isNotEmpty);
      for (final ink in inks) {
        expect(ink, isNotNull);
        // WCAG's 4.5:1 floor for body text, against the panel it sits on.
        expect(
          contrast(scheme.coinPanel, ink!),
          greaterThan(4.5),
          reason: 'ink $ink on the $name panel ${scheme.coinPanel}',
        );
      }
    });
  }

  testWidgets('the figure chip does not vanish into the panel',
      (tester) async {
    await tester.pumpWidget(host(Brightness.light, AppColorScheme.light));
    await tester.pump();

    // The chip is the one rounded fill that is neither panel nor tone frame.
    final fills = tester
        .widgetList<Container>(find.byType(Container))
        .map((c) => (c.decoration as BoxDecoration?)?.color)
        .whereType<Color>()
        .toList();
    expect(
      fills,
      isNot(contains(AppColors.inkChip)),
      reason: 'the pale stage chip would read as white-on-white here',
    );
  });

  // ── the stage ─────────────────────────────────────────────────────────────

  /// The pack header is laid out at REAL phone width, not the 800x600 test
  /// surface: ScreenUtil scales `.w`/`.sp` against the design's 390, so on the
  /// default surface the 30sp pack name comes out at double size and overflows
  /// its own row. The overflow is the harness, not the widget.
  void asPhone(WidgetTester tester) {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
  }

  Widget stageHost(
    NewCoinTone tone,
    Brightness brightness,
    AppColorScheme scheme,
  ) =>
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, __) => MaterialApp(
          theme: ThemeData(brightness: brightness, extensions: [scheme]),
          home: Scaffold(
            backgroundColor: scheme.coinStage,
            body: Stack(
              children: [
                Positioned.fill(child: NewCoinsBackdrop(tone: tone)),
                SingleChildScrollView(
                  child: NewCoinPackHeader(
                    pack: const NewCoinPack(
                      id: 'p1',
                      kindKey: 'main',
                      name: 'Start',
                      price: 149000,
                      coins: 40,
                      validDays: 30,
                      pricePerCoin: 3725,
                    ),
                    tone: tone,
                    savingPercent: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  for (final MapEntry(key: name, value: (brightness, scheme))
      in themes.entries) {
    testWidgets('$name: the stage is painted coinStage', (tester) async {
      asPhone(tester);
      await tester
          .pumpWidget(stageHost(NewCoinTone.main(0), brightness, scheme));
      await tester.pump();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, scheme.coinStage);
    });
  }

  testWidgets('every pack tone keeps the top of the wash light enough for '
      'dark ink', (tester) async {
    // The wash leads with the tone's pale tint, which is what the pack's name
    // is actually printed on. A tone whose leading colour went dark would put
    // near-black ink on a near-black band — so each one is checked, not just
    // the first.
    for (var i = 0; i < 6; i++) {
      final tone = NewCoinTone.main(i);
      final ground = tone.light.computeLuminance();
      final ink = AppColors.ink.computeLuminance();
      final ratio = (ground + 0.05) / (ink + 0.05);
      expect(
        ratio,
        greaterThan(4.5),
        reason: 'ink on tone $i\'s pale tint, the top of its wash',
      );
    }
  });

  for (final MapEntry(key: name, value: (brightness, scheme))
      in themes.entries) {
    testWidgets('$name: no label on the stage is its own ground colour',
        (tester) async {
      asPhone(tester);
      await tester
          .pumpWidget(stageHost(NewCoinTone.main(0), brightness, scheme));
      await tester.pump();

      final inks = inkOf(tester);
      expect(inks, isNotEmpty);
      for (final ink in inks) {
        expect(ink, isNotNull);
        // Labels out on the stage may sit on the panel pills or straight on
        // the page, so they have to read on the page itself.
        expect(
          contrast(scheme.coinStage, ink!),
          greaterThan(3),
          reason: 'label painted $ink on the $name stage ${scheme.coinStage}',
        );
      }
    });
  }
}
