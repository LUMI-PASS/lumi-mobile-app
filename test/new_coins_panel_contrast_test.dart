import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/data/api_model/new_coins/new_coin_models.dart';
import 'package:lumi_pass/presentation/app/new_coins/widgets/new_coins_widgets.dart';

/// The shelf is a LIGHT screen in both themes: a near-white stage, a pale wash
/// of the pack's colour off the top edge, and white panels inside the tone
/// frame. Everything drawn on it therefore takes a fixed DARK ink, and
/// white-on-white is the failure mode throughout — invisible to the analyzer,
/// so asserted here rather than eyeballed.
///
/// These cover both of the screen's grounds: the panels, and the stage the
/// pack's own header sits out on.
void main() {
  final features = [
    const NewCoinFeature(
      icon: Icons.check_rounded,
      title: 'Activities',
      body: 'Any activity on the catalogue',
      chip: '40 Lumi Coin',
    ),
  ];

  Widget host() => ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, __) => MaterialApp(
          // The shelf's own override: the page is LIGHT whatever the app is.
          theme: ThemeData(
            brightness: Brightness.light,
            extensions: const [AppColorScheme.light],
          ),
          home: Scaffold(
            backgroundColor: AppColors.coinStage,
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
  List<Color?> inkOf(WidgetTester tester) => tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.style?.color)
      .toList();

  testWidgets('the panels are a light surface', (tester) async {
    await tester.pumpWidget(host());
    await tester.pump();

    final panels = tester
        .widgetList<Container>(find.byType(Container))
        .where((c) => (c.decoration as BoxDecoration?)?.color != null)
        .map((c) => (c.decoration as BoxDecoration).color!)
        .toList();

    // The two cards inside the tone frame.
    expect(
      panels.where((c) => c == AppColors.coinPanel),
      hasLength(2),
      reason: 'the header card and the feature list',
    );
    // Whatever `coinPanel` is set to, it has to be a light surface — this is
    // the thing the ink below is chosen against.
    expect(AppColors.coinPanel.computeLuminance(), greaterThan(0.8));
  });

  testWidgets('every label on a panel is dark enough to read', (tester) async {
    await tester.pumpWidget(host());
    await tester.pump();

    final inks = inkOf(tester);
    expect(inks, isNotEmpty);

    for (final ink in inks) {
      expect(ink, isNotNull);
      // Contrast against the panel, per WCAG. 4.5:1 is the floor for body
      // text; every label here clears it by a wide margin.
      final a = AppColors.coinPanel.computeLuminance();
      final b = ink!.computeLuminance();
      final ratio = (a > b) ? (a + 0.05) / (b + 0.05) : (b + 0.05) / (a + 0.05);
      expect(ratio, greaterThan(4.5), reason: 'ink $ink on the white panel');
    }
  });

  testWidgets('the figure chip does not vanish into the panel',
      (tester) async {
    await tester.pumpWidget(host());
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

  Widget stageHost(NewCoinTone tone) => ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, __) => MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            extensions: const [AppColorScheme.light],
          ),
          home: Scaffold(
            backgroundColor: AppColors.coinStage,
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

  testWidgets('the stage is a light ground', (tester) async {
    expect(
      AppColors.coinStage.computeLuminance(),
      greaterThan(0.8),
      reason: 'the header ink below is chosen against this',
    );
    asPhone(tester);
    await tester.pumpWidget(stageHost(NewCoinTone.main(0)));
    await tester.pump();

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, AppColors.coinStage);
  });

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

  testWidgets('no label on the stage is painted white', (tester) async {
    asPhone(tester);
    await tester.pumpWidget(stageHost(NewCoinTone.main(0)));
    await tester.pump();

    final inks = inkOf(tester);
    expect(inks, isNotEmpty);
    for (final ink in inks) {
      expect(ink, isNotNull);
      expect(
        ink!.computeLuminance(),
        lessThan(0.5),
        reason: 'label painted $ink out on the light stage',
      );
    }
  });
}
