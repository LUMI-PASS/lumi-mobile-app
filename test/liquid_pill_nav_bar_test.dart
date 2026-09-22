import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/presentation/app/main/widgets/liquid_pill_nav_bar.dart';

/// The spring blob is driven by a `Ticker`, not an `AnimationController` with
/// a duration, so these assert on behaviour (what got selected, that the body
/// stretches while travelling and settles afterwards) rather than on frames.
void main() {
  const items = [
    LiquidNavDestination(asset: 'a.svg', label: 'A'),
    LiquidNavDestination(asset: 'b.svg', label: 'B'),
    LiquidNavDestination(asset: 'c.svg', label: 'C'),
    LiquidNavDestination(asset: 'd.svg', label: 'D'),
  ];

  /// Width of the travelling blob right now, read off its `Positioned`.
  double blobWidth(WidgetTester tester) {
    final rect = tester.getRect(
      find.byKey(const ValueKey('liquid-blob')).first,
    );
    return rect.width;
  }

  Widget host({
    required int index,
    required ValueChanged<int> onTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 400,
            child: LiquidPillNavBar(
              items: items,
              selectedIndex: index,
              onTap: onTap,
              bottomPadding: 0,
              iconBuilder: (ctx, item, progress, size) =>
                  SizedBox(width: size, height: size),
              labelBuilder: (ctx, item, progress) => Text(item.label),
            ),
          ),
        ),
      ),
    );
  }

  // Labels and icons are `IgnorePointer`; one gesture surface over the whole
  // bar handles taps and drags alike, so a tap on a label legitimately lands
  // on that surface instead — hence `warnIfMissed: false`.
  testWidgets('a tap reports the item under the finger', (tester) async {
    final taps = <int>[];
    await tester.pumpWidget(host(index: 0, onTap: taps.add));

    await tester.tap(find.text('C'), warnIfMissed: false);
    await tester.pump();

    expect(taps, [2]);
  });

  testWidgets('re-tapping the selected item reports nothing', (tester) async {
    final taps = <int>[];
    await tester.pumpWidget(host(index: 1, onTap: taps.add));

    await tester.tap(find.text('B'), warnIfMissed: false);
    await tester.pump();

    expect(taps, isEmpty);
  });

  testWidgets('a drag across the bar commits once, on release',
      (tester) async {
    final taps = <int>[];
    await tester.pumpWidget(host(index: 0, onTap: taps.add));

    final start = tester.getCenter(find.text('A'));
    final gesture = await tester.startGesture(start);
    for (var i = 1; i <= 6; i++) {
      await gesture.moveBy(const Offset(50, 0));
      await tester.pump(const Duration(milliseconds: 16));
    }
    // Every tab was passed over, but nothing has been pushed yet.
    expect(taps, isEmpty);

    await gesture.up();
    await tester.pump();

    expect(taps.length, 1);
    expect(taps.single, greaterThan(0));
  });

  testWidgets('the body stretches while travelling and settles at rest',
      (tester) async {
    await tester.pumpWidget(host(index: 0, onTap: (_) {}));
    await tester.pumpAndSettle();
    final resting = blobWidth(tester);

    await tester.pumpWidget(host(index: 3, onTap: (_) {}));
    await tester.pump(const Duration(milliseconds: 80));
    // The tail lags the head, so mid-flight the body is drawn out.
    expect(blobWidth(tester), greaterThan(resting));

    await tester.pumpAndSettle();
    // The ticker stops itself once the springs settle — pumpAndSettle
    // returning at all is that assertion — and the body is back to size.
    expect(blobWidth(tester), closeTo(resting, 0.5));
  });
}
