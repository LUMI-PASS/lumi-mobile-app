import 'package:easy_localization/easy_localization.dart';
import 'package:lumi_pass/data/api_model/activity_sale/activity_sale.dart';

/// How a centre's sale is put into words — see [ActivitySale].
///
/// One place, because the rule that matters is the same on every surface: a
/// percentage that only holds on some days or hours is never printed without
/// them. A parent who taps "−20%" and finds the Saturday slot at full price
/// has been misled, however correct the small print was.

/// "−20%".
String salePercentLabel(ActivitySale sale) => '−${sale.percent}%';

/// The days of [serverDays] (0 = Sunday … 6 = Saturday) as short names, Monday
/// first. Three or more days in a row fold into a range — "Du–Ju"; anything
/// else is listed — "Du, Cho, Ju". [shortName] takes 1 = Monday … 7 = Sunday.
String foldWeekdays(List<int> serverDays, String Function(int) shortName) {
  // Monday first, Sunday last: 0 becomes 7.
  final days = serverDays.map((d) => d == 0 ? 7 : d).toSet().toList()..sort();
  if (days.isEmpty) return '';
  final contiguous = days.last - days.first == days.length - 1;
  if (contiguous && days.length >= 3) {
    return '${shortName(days.first)}–${shortName(days.last)}';
  }
  return days.map(shortName).join(', ');
}

/// When the sale holds within its dates — "Du–Ju · 09:00–18:00" — or null for
/// one that holds all day, every day, and so needs nothing said.
String? saleWhenLabel(ActivitySale sale) {
  if (!sale.isConditional) return null;
  return [
    if (sale.days.isNotEmpty)
      foldWeekdays(sale.days, (d) => 'weekday_short_$d'.tr()),
    if (sale.hasHours) '${sale.startTime}–${sale.endTime}',
  ].join(' · ');
}

String _dayMonth(String date) {
  final parsed = DateTime.tryParse(date);
  if (parsed == null) return date;
  return '${parsed.day} ${'month_short_${parsed.month}'.tr().toLowerCase()}';
}

/// The dates it runs — "31 okt gacha" once it has started, "13 okt – 31 okt"
/// while it is still ahead, so a badge never promises a price that today's
/// lesson does not have.
String saleDatesLabel(ActivitySale sale, {DateTime? now}) {
  final today = ActivitySale.dateKey(now ?? DateTime.now());
  if (sale.startDate.compareTo(today) > 0) {
    return '${_dayMonth(sale.startDate)} – ${_dayMonth(sale.endDate)}';
  }
  return 'sale_until'.tr(args: [_dayMonth(sale.endDate)]);
}

/// Everything about the sale but its size, on one line — "Du–Ju · 09:00–18:00
/// · 31 okt gacha" — for the places that have room for it.
String saleTermsLabel(ActivitySale sale, {DateTime? now}) => [
      if (saleWhenLabel(sale) != null) saleWhenLabel(sale)!,
      saleDatesLabel(sale, now: now),
    ].join(' · ');
