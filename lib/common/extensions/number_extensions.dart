extension StringNumberExtension on String {
  String spaceSeparateNumbers() {
    final result = replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ');
    return result;
  }
}

extension IntNumberExtensions on int {
  String get price => toString().spaceSeparateNumbers();

  /// `15751` → `"15 751"` — a COUNT with its thousands separated.
  ///
  /// The same formatting as [price] under a name that does not claim the
  /// number is money. Three widgets had each grown a private copy of this
  /// (the search count row, the search tab's shortcut cards and its category
  /// cards); they all read this now, so a count is spaced the same way wherever
  /// it appears.
  String get grouped => toString().spaceSeparateNumbers();
}