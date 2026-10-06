import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/search_shortcut_card.dart';

/// The search tab's shortcut row went from two cards to three, which cut each
/// one from ~170pt to ~114pt. Uzbek labels are the long ones ("Mashg'ulotlar",
/// "Saqlanganlar") and a card is only as wide as a third of the screen, so
/// these pin down that the row still fits and that nothing is truncated — an
/// ellipsis on a two-word label is invisible to the analyzer and easy to miss
/// on a big simulator.
void main() {
  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.devicePixelRatio = 1.0;
    // The narrowest phone the design targets.
    view.physicalSize = const Size(360, 780);
  });

  tearDown(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  Widget host({int? savedCount}) => ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, __) => MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            extensions: const [AppColorScheme.light],
          ),
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SearchShortcutCard(
                        icon: Assets.icons.location,
                        color: AppColors.green,
                        label: 'Xaritada',
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SearchShortcutCard(
                        icon: Assets.icons.home.book,
                        color: AppColors.brandPink,
                        // No count on this one in the app — the catalogue
                        // total is on the "all categories" card in the grid
                        // below.
                        label: "Mashg'ulotlar",
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SearchShortcutCard(
                        icon: Assets.icons.home.heart,
                        color: AppColors.error,
                        label: 'Saqlanganlar',
                        count: savedCount,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  /// True when [text]'s painted glyphs were cut short by its ellipsis.
  bool isTruncated(WidgetTester tester, String text) {
    final widget = tester.widget<Text>(find.text(text));
    final painter = TextPainter(
      text: TextSpan(text: widget.data, style: widget.style),
      maxLines: widget.maxLines,
      textAlign: widget.textAlign ?? TextAlign.start,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: tester.getSize(find.text(text)).width);
    return painter.didExceedMaxLines;
  }

  testWidgets('three cards fit the narrowest phone, labels intact',
      (tester) async {
    await tester.pumpWidget(host(savedCount: 9));
    await tester.pumpAndSettle();

    for (final label in ['Xaritada', "Mashg'ulotlar", 'Saqlanganlar']) {
      expect(find.text(label), findsOneWidget, reason: label);
      expect(isTruncated(tester, label), isFalse, reason: label);
    }
    // No RenderFlex overflow was thrown while laying the row out.
    expect(tester.takeException(), isNull);
  });

  testWidgets('zero saved still shows, because it is a fact', (tester) async {
    await tester.pumpWidget(host(savedCount: 0));
    await tester.pumpAndSettle();

    // Nothing saved is what explains the empty screen behind the tap.
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('grouped in threes, and an uncounted card prints nothing',
      (tester) async {
    await tester.pumpWidget(host(savedCount: 15751));
    await tester.pumpAndSettle();
    expect(find.text('15 751'), findsOneWidget);

    await tester.pumpWidget(host(savedCount: null));
    await tester.pumpAndSettle();
    expect(find.textContaining(RegExp(r'^\d')), findsNothing);
  });
}
