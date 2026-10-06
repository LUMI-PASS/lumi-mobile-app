import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/search_shortcut_card.dart';

/// The "Saqlanganlar" shortcut must never print a "0" under its heart. The
/// card takes a nullable count and draws nothing for null, so the rule lives
/// at the call site — which makes it exactly the kind of thing that comes back
/// the next time someone wires a count up. These pin the card's half of it.
void main() {
  Widget host(int? count) => ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, __) => MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            extensions: const [AppColorScheme.light],
          ),
          home: Scaffold(
            body: SearchShortcutCard(
              icon: Assets.icons.home.heart,
              color: AppColors.error,
              label: 'Saqlanganlar',
              count: count,
              onTap: () {},
            ),
          ),
        ),
      );

  /// Every string the card draws.
  List<String> textsOf(WidgetTester tester) => tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data ?? '')
      .toList();

  testWidgets('a null count prints no number', (tester) async {
    await tester.pumpWidget(host(null));
    await tester.pump();
    expect(textsOf(tester), ['Saqlanganlar']);
  });

  testWidgets('a real count is printed', (tester) async {
    await tester.pumpWidget(host(9));
    await tester.pump();
    expect(textsOf(tester), containsAll(['Saqlanganlar', '9']));
  });

  testWidgets('a zero passed straight through would print "0"',
      (tester) async {
    // Not the behaviour anyone wants — it is why the call site maps an empty
    // set to null rather than to its length. Asserted so that the card is
    // never "fixed" to swallow zeros silently: a caller that genuinely has a
    // zero to show should still be able to, and the one caller that must not
    // show it is the one that decides.
    await tester.pumpWidget(host(0));
    await tester.pump();
    expect(textsOf(tester), containsAll(['Saqlanganlar', '0']));
  });
}
