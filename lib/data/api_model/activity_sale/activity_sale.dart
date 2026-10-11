/// A centre's own sale on an activity: a percentage off lessons on some
/// dates, optionally only on some weekdays and between some hours — "20% off,
/// 1–31 October, Monday to Friday, 09:00 to 18:00".
///
/// Everything here is about the LESSON, never about the purchase: a Tuesday
/// 11:00 visit is discounted whenever it is bought, a Saturday visit is not.
/// So a sale is never a number to print on its own — where it has days or
/// hours, they are printed with it.
///
/// [covers] and [priceAfter] repeat the server's rules
/// (`activity-discount.rules.ts`) so a slot can be priced before checkout.
/// The server prices the order itself and is the one that counts; change one
/// and change the other.
class ActivitySale {
  const ActivitySale({
    required this.percent,
    required this.startDate,
    required this.endDate,
    this.days = const [],
    this.startTime,
    this.endTime,
  });

  /// Whole percent off the list price.
  final int percent;

  /// First and last lesson date covered, inclusive — `YYYY-MM-DD`.
  final String startDate;
  final String endDate;

  /// Weekdays it runs on, as the server counts them: 0 = Sunday … 6 =
  /// Saturday. Empty means every day.
  final List<int> days;

  /// The hours it runs between, `HH:mm`, by the lesson's START. Both or
  /// neither; neither means all day.
  final String? startTime;
  final String? endTime;

  bool get hasHours =>
      (startTime?.isNotEmpty ?? false) && (endTime?.isNotEmpty ?? false);

  /// Whether it is limited to part of the week or of the day — i.e. whether
  /// the percentage needs a condition printed beside it.
  bool get isConditional => days.isNotEmpty || hasHours;

  /// Whether a lesson on [date] starting at [startTime] (`HH:mm`) is on sale.
  ///
  /// A sale with hours needs a lesson with a start time: a visit bought for a
  /// day and not for an hour cannot be shown to fall inside the window.
  bool covers(DateTime date, {String? startTime}) {
    if (percent <= 0) return false;
    final key = dateKey(date);
    // Both formats sort as text, so they are compared as text.
    if (key.compareTo(startDate) < 0 || key.compareTo(endDate) > 0) {
      return false;
    }
    // DateTime counts Monday as 1 and Sunday as 7; the server counts Sunday 0.
    if (days.isNotEmpty && !days.contains(date.weekday % 7)) return false;
    if (!hasHours) return true;
    if (startTime == null || startTime.isEmpty) return false;
    return startTime.compareTo(this.startTime!) >= 0 &&
        startTime.compareTo(endTime!) < 0;
  }

  /// [price] with this sale taken off, in whole so'm — rounded to the nearest,
  /// as the server rounds it.
  num priceAfter(num price) => discountedBy(price, percent);

  static String dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// [price] with [percent] off, in whole so'm.
  static num discountedBy(num price, int percent) {
    if (price <= 0 || percent <= 0) return price;
    return (price * (100 - (percent > 100 ? 100 : percent)) / 100).round();
  }

  /// The sale that takes the most off a lesson, or null. Sales never stack.
  static ActivitySale? best(
    List<ActivitySale> sales,
    DateTime date, {
    String? startTime,
  }) {
    ActivitySale? best;
    for (final sale in sales) {
      if (!sale.covers(date, startTime: startTime)) continue;
      if (best == null || sale.percent > best.percent) best = sale;
    }
    return best;
  }

  /// Never throws: a sale the build cannot read is no sale, and the price
  /// shown is then the list price — which the server will not charge above.
  static ActivitySale? tryParse(Object? json) {
    if (json is! Map) return null;
    final percent = (json['percent'] as num?)?.toInt() ?? 0;
    final start = json['start_date']?.toString() ?? '';
    final end = json['end_date']?.toString() ?? '';
    if (percent <= 0 || start.isEmpty || end.isEmpty) return null;
    final days = json['days'];
    return ActivitySale(
      percent: percent,
      startDate: start,
      endDate: end,
      days: days is List
          ? days.whereType<num>().map((d) => d.toInt()).toList()
          : const [],
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
    );
  }

  /// For the freezed card model, which wants a `fromJson` that returns one.
  /// A card with an unreadable sale is dropped to no sale by [saleFromJson].
  static ActivitySale? saleFromJson(Object? json) => tryParse(json);

  static List<ActivitySale> listFromJson(Object? json) => json is List
      ? json.map(tryParse).whereType<ActivitySale>().toList()
      : const [];

  Map<String, dynamic> toJson() => {
        'percent': percent,
        'start_date': startDate,
        'end_date': endDate,
        'days': days,
        'start_time': startTime,
        'end_time': endTime,
      };
}
