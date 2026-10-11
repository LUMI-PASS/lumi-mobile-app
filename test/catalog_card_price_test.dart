import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_class_card.dart';

/// A CATALOGUE entry carries a price — the public directory Lumi listed it
/// from had one — but nothing on it is for sale at that price: there is no
/// contract, which is why its detail page has no Book button either. A figure
/// on a card reads as an offer, and a card has no room to say otherwise, so
/// the price belongs on the detail page alone.
///
/// Every class card in the app draws its price through the one widget this
/// exercises — the home rows, "Near you", the see-all grid, search results,
/// saved activities and a centre's own class list.
///
/// Only the negative case is rendered here. The price widget previews the
/// buyer's coupon discount, so drawing one needs an `AppCubit` above it, and a
/// card that is supposed to draw NO price needs no such thing. That is what
/// makes the check below sharp: if the catalogue gate goes, the card reaches
/// for the price widget, which cannot build without that provider — so the
/// regression lands as an exception rather than as a quiet pass.
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

  /// A listed centre with a crawled price, as the feed sends one.
  const catalogClass = HomClass(
    id: 'a1',
    title: 'Shaxmat',
    price: 150000,
    isCatalog: true,
    branch: HomBranch(title: 'Bee Kids', address: 'Chilonzor 12'),
  );

  Widget host(HomClass clazz) => ScreenUtilInit(
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
                homClass: clazz,
                width: 260,
                imageHeight: 150,
                margin: EdgeInsets.zero,
                showDistance: false,
              ),
            ),
          ),
        ),
      );

  testWidgets('a catalogue entry\'s card quotes no price', (tester) async {
    await tester.pumpWidget(host(catalogClass));
    await tester.pumpAndSettle();

    expect(find.textContaining('150 000'), findsNothing);
    expect(
      tester.takeException(),
      isNull,
      reason: 'the card tried to build a price for a catalogue entry',
    );
  });

  testWidgets('the rest of the card is untouched', (tester) async {
    // It is still a venue worth browsing — only the figure goes.
    await tester.pumpWidget(host(catalogClass));
    await tester.pumpAndSettle();

    expect(find.text('Shaxmat'), findsOneWidget);
    expect(find.text('Bee Kids'), findsOneWidget);
  });
}
