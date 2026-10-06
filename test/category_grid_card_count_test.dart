import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/category_grid_card.dart';

/// The count line on a category card.
///
/// Counts are fetched per category, one request each, and they land at
/// different times — so the card has to read correctly in all three states: not
/// counted yet, counted at zero, and counted. The difference between the first
/// two is the one worth pinning down: "we have not asked yet" must never render
/// as "there is nothing here".
///
/// Asserted STRUCTURALLY — whether the line exists — rather than on its text.
/// The line is `activities_count` with the number substituted into the
/// translation's `{}`, and with no [EasyLocalization] in the harness `.tr()`
/// returns the bare key, dropping the argument. The grouping of the number
/// itself is covered where it actually lives, in `number_extensions_test.dart`.
void main() {
  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.devicePixelRatio = 1.0;
    view.physicalSize = const Size(390, 844);
  });

  tearDown(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  Widget host({int? count}) => ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, __) => MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            extensions: const [AppColorScheme.light],
          ),
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                // One column of the two-column grid.
                width: 170,
                child: CategoryGridCard(
                  title: 'Shaxmat',
                  count: count,
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      );

  /// Every string the card paints. The first is the artwork fallback's initial
  /// — this card is given no image — then the title, then the count line.
  List<String> texts(WidgetTester tester) => [
        for (final text in tester.widgetList<Text>(find.byType(Text)))
          text.data ?? '',
      ];

  testWidgets('a counted category carries a line under its name',
      (tester) async {
    await tester.pumpWidget(host(count: 24));
    await tester.pumpAndSettle();

    expect(texts(tester), ['S', 'Shaxmat', 'activities_count']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an empty category still carries it — zero is a fact',
      (tester) async {
    await tester.pumpWidget(host(count: 0));
    await tester.pumpAndSettle();

    // The one thing that would stop someone tapping the card. Finding out
    // after the tap is worse.
    expect(texts(tester), ['S', 'Shaxmat', 'activities_count']);
  });

  testWidgets('a category not counted yet carries no line', (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    expect(texts(tester), ['S', 'Shaxmat']);
  });
}
