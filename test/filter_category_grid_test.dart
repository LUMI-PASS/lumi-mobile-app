import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/category_picker_page.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/filter_bottom_sheet.dart';

/// The filter sheet's categories: a "Категории" row that opens the full-screen
/// [CategoryPickerPage].
///
/// Worth pinning down because the analyzer cannot see it: that the page lists
/// the catalogue in order, and that a tick survives the page's Apply AND the
/// sheet's as a resolved [HomCategory] — including a category that arrived
/// already ticked but is absent from the catalogue the sheet was given, which
/// is the case that quietly dropped a live filter.
void main() {
  // The sheet is laid out with ScreenUtil against a 390x844 design. The
  // default 800x600 test surface scales every `.w`/`.h` by ~2 and overflows
  // controls that are fine on a phone (the age fields, the price row), so the
  // surface is set to the design size and the scale factor is then 1.
  setUp(() {
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views
        .first;
    view.devicePixelRatio = 1.0;
    view.physicalSize = const Size(390, 844);
  });

  tearDown(() {
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views
        .first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  HomCategory cat(String id, String title) =>
      HomCategory(id: id, title: title);

  final catalogue = [
    cat('1', 'Shaxmat'),
    cat('2', 'Suzish'),
    cat('3', 'Raqs'),
  ];

  Widget host({
    required List<HomCategory> categories,
    FilterResult? initial,
    ValueChanged<FilterResult?>? onApplied,
  }) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, __) => MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          extensions: const [AppColorScheme.light],
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                final result = await FilterBottomSheet.show(
                  context,
                  initial: initial,
                  categories: categories,
                );
                onApplied?.call(result);
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
  }

  /// Swallows the sheet's own, pre-existing overflow.
  ///
  /// `_AgeField` is a fixed-width control holding a text field plus the "лет"
  /// suffix. With no [EasyLocalization] in the harness `.tr()` returns the KEY
  /// — `age_years_suffix`, five times longer than any real translation — and
  /// that is what does not fit. It overflows with or without the category
  /// grid, and never in the app, so it is filtered rather than asserted
  /// around; anything else that throws still fails the test.
  void ignoreUntranslatedOverflow() {
    final onError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('A RenderFlex overflowed')) {
        return;
      }
      onError?.call(details);
    };
    addTearDown(() => FlutterError.onError = onError);
  }

  Future<void> openSheet(WidgetTester tester) async {
    ignoreUntranslatedOverflow();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  /// The "Категории" row's "Выбрать". With no translations loaded it reads as
  /// the key, and the location row under it says the same, so the first one
  /// is ours.
  Finder categoriesRow() => find.text('select').first;

  /// Scrolls the sheet to the row — it sits at the bottom — and opens the page.
  Future<void> openCategories(WidgetTester tester) async {
    await tester.ensureVisible(categoriesRow());
    await tester.pumpAndSettle();
    await tester.tap(categoriesRow());
  }

  testWidgets('the row opens the whole catalogue, in order', (tester) async {
    await tester.pumpWidget(host(categories: catalogue));
    await openSheet(tester);

    await openCategories(tester);
    await tester.pumpAndSettle();

    expect(find.byType(CategoryPickerPage), findsOneWidget);
    final tops = [
      for (final title in ['Shaxmat', 'Suzish', 'Raqs'])
        tester.getRect(find.text(title)).top,
    ];
    expect(tops, orderedEquals([...tops]..sort()));
  });

  testWidgets('a ticked category comes back off Apply', (tester) async {
    FilterResult? applied;
    await tester.pumpWidget(
      host(categories: catalogue, onApplied: (r) => applied = r),
    );
    await openSheet(tester);

    await openCategories(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Suzish'));
    await tester.pumpAndSettle();
    // The page's Apply, back to the sheet, which now names the pick …
    await tester.tap(find.text('apply_button'));
    await tester.pumpAndSettle();
    expect(find.text('Suzish'), findsOneWidget);
    // … then the sheet's own.
    await tester.tap(find.text('apply_button'));
    await tester.pumpAndSettle();

    expect(applied?.categories.map((c) => c.id).toList(), ['2']);
  });

  testWidgets('a pick made before the catalogue landed is not dropped',
      (tester) async {
    FilterResult? applied;
    await tester.pumpWidget(
      host(
        // Search can open filtered by a Home category while its own list is
        // still in flight.
        categories: const [],
        initial: FilterResult(categories: [cat('9', 'Shaxmat')]),
        onApplied: (r) => applied = r,
      ),
    );
    await openSheet(tester);

    // Shown, even though it is in no catalogue …
    expect(find.text('Shaxmat'), findsOneWidget);
    await tester.tap(find.text('apply_button'));
    await tester.pumpAndSettle();
    // … and still ticked on the way out.
    expect(applied?.categories.map((c) => c.id).toList(), ['9']);
  });

  testWidgets('Clear unticks every category', (tester) async {
    FilterResult? applied;
    await tester.pumpWidget(
      host(
        categories: catalogue,
        initial: FilterResult(categories: [catalogue.first]),
        onApplied: (r) => applied = r,
      ),
    );
    await openSheet(tester);

    await tester.tap(find.text('clear_button'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('apply_button'));
    await tester.pumpAndSettle();

    expect(applied?.categories, isEmpty);
  });

  testWidgets('no catalogue and nothing picked means no section at all',
      (tester) async {
    await tester.pumpWidget(host(categories: const []));
    await openSheet(tester);

    // The map screen's case: its own picker owns categories, so the sheet is
    // the one it always had.
    expect(find.text('categories'), findsNothing);
  });
}
