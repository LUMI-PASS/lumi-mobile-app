import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/home_page.dart';

/// Home's category grid is two rows of five, and which category
/// lands in which cell is arithmetic — easy to get subtly wrong (a horizontal
/// grid fills by COLUMN, which would put the second category under the first
/// instead of beside it) and invisible to the analyzer.
void main() {
  const columns = HomePage.categoryGridColumns;

  test('the first screen reads as two rows: 1-5 over 6-10', () {
    final grid = columns(10);
    expect(grid.map((c) => c.first), [0, 1, 2, 3, 4]);
    expect(grid.map((c) => c.last), [5, 6, 7, 8, 9]);
  });

  test('anything past ten follows in columns of two', () {
    expect(columns(15).skip(5), [
      [10, 11],
      [12, 13],
      [14],
    ]);
  });

  test('a short second row leaves its trailing cells empty', () {
    expect(columns(7), [
      [0, 5],
      [1, 6],
      [2],
      [3],
      [4],
    ]);
  });

  test('five or fewer stay a single row', () {
    expect(columns(3), [
      [0],
      [1],
      [2],
    ]);
    expect(columns(0), isEmpty);
  });

  test('every category appears exactly once', () {
    for (var n = 0; n <= 23; n++) {
      final seen = columns(n).expand((c) => c).toList()..sort();
      expect(seen, [for (var i = 0; i < n; i++) i], reason: 'n=$n');
    }
  });
}
