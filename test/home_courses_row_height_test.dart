import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_class_card.dart';

/// How much room the home feed's course row has to reserve for the text under
/// each card's photo.
///
/// The row is a horizontal `ListView` inside a fixed-height `SizedBox`, so the
/// height is a CONSTANT in `home_page.dart` rather than something the cards
/// negotiate. Get it wrong one way and the address clips; the other way and the
/// row ends in a band of empty space — which is what happened when course cards
/// stopped carrying a price and nothing told the row to stop reserving a line
/// for one.
///
/// So the constant is measured here instead of estimated. [_kTextBlock] below
/// must match `_buildCoursesRow`'s own value.
void main() {
  /// The allowance `_buildCoursesRow` reserves for the text block, before the
  /// device's text scale is applied. Keep in step with home_page.dart.
  const double kTextBlock = 84;

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

  /// A course as the feed sends one: a centre with a name and a street, which
  /// is the tallest text block one of these cards can draw — a provider pill, a
  /// one-line title and an address.
  const course = HomClass(
    id: 'c1',
    title: 'Shaxmat kursi',
    isCourse: true,
    category: 'Shaxmat',
    branch: HomBranch(
      title: 'Lumi Chess Club',
      address: 'Amir Temur shoh ko‘chasi 108, Toshkent',
    ),
  );

  Widget host({double textScale = 1.0}) => ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, __) => MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            extensions: const [AppColorScheme.light],
          ),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: HomeCourseCard(
                homClass: course,
                width: 260,
                imageHeight: 150,
                margin: EdgeInsets.zero,
                showDistance: false,
                // Every card on this row is a course, and a course on the
                // home feed carries no price — see `_showsPrice`.
                showPrice: false,
              ),
            ),
          ),
        ),
      );

  /// The text block's height: the whole card, less its photo and the 14pt gap.
  double textBlockOf(WidgetTester tester, {double imageHeight = 150}) {
    final card = tester.getSize(find.byType(HomeCourseCard));
    return card.height - imageHeight - 14;
  }

  testWidgets('a priceless course card fits the allowance, without slack',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    final block = textBlockOf(tester);
    // Fits …
    expect(block, lessThanOrEqualTo(kTextBlock),
        reason: 'text block $block overflows the reserved $kTextBlock');
    // … and is not swimming in room. More than ~16pt spare is the gap this
    // test exists to catch: it shows up as a band of nothing between this row
    // and "Sizga yaqin" below it.
    expect(kTextBlock - block, lessThan(16),
        reason: 'text block $block leaves ${kTextBlock - block}pt unused');
  });

  testWidgets('the allowance scales with the device text size', (tester) async {
    await tester.pumpWidget(host(textScale: 1.6));
    await tester.pumpAndSettle();

    final block = textBlockOf(tester);
    // The row multiplies its allowance by the same scale, so the comparison is
    // against the scaled figure. A large-font device must grow the row rather
    // than clip the address off it.
    expect(block, lessThanOrEqualTo(kTextBlock * 1.6),
        reason: 'text block $block overflows ${kTextBlock * 1.6}');
  });

  // "Obunaga kiradi" draws its entries as raised cards on the coin panel, and
  // sizes its row as the bare card's height plus
  // [HomeCourseCard.cardedExtraHeight]. That figure is the card's own chrome —
  // a tighter gap, a closing strip, a border — so it is checked against what
  // the card actually adds, with the same content in both.
  //
  // Priceless here only because the price line needs the app's cubits; the
  // price sits inside the same text block either way, so it does not change
  // what the chrome adds.
  testWidgets('a carded card is taller than a bare one by cardedExtraHeight',
      (tester) async {
    Widget card({required bool carded}) => ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, __) => MaterialApp(
            theme: ThemeData(
              brightness: Brightness.light,
              extensions: const [AppColorScheme.light],
            ),
            home: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: HomeCourseCard(
                  homClass: course,
                  margin: EdgeInsets.zero,
                  showDistance: false,
                  showPrice: false,
                  carded: carded,
                ),
              ),
            ),
          ),
        );

    await tester.pumpWidget(card(carded: false));
    await tester.pumpAndSettle();
    final bare = tester.getSize(find.byType(HomeCourseCard)).height;

    await tester.pumpWidget(card(carded: true));
    await tester.pumpAndSettle();
    final carded = tester.getSize(find.byType(HomeCourseCard)).height;

    expect(carded - bare, closeTo(HomeCourseCard.cardedExtraHeight, 0.01));
  });
}
