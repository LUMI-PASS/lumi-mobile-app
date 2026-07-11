import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/bouncing_button.dart';

/// App-styled date range picker sheet — a scrolling month list with the
/// selected span painted as a band between two gradient endpoints.
///
/// Resolves the picked range, or `null` when the user backs out:
/// `final r = await AppDateRangePickerSheet.show(context, initial: range);`
///
/// Tapping a day starts a new span; the next tap closes it (a tap *before* the
/// open start re-anchors the start instead). Confirming with only one day
/// picked returns a single-day range.
DateTime _dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

class AppDateRangePickerSheet extends StatefulWidget {
  const AppDateRangePickerSheet({
    super.key,
    this.initial,
    this.firstDate,
    this.lastDate,
  });

  final DateTimeRange? initial;

  /// Selectable window. Defaults to today .. today + 12 months.
  final DateTime? firstDate;
  final DateTime? lastDate;

  static Future<DateTimeRange?> show(
    BuildContext context, {
    DateTimeRange? initial,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    return showModalBottomSheet<DateTimeRange>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.colors.surface,
      barrierColor: AppColors.ink.withValues(alpha: 0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => AppDateRangePickerSheet(
        initial: initial,
        firstDate: firstDate,
        lastDate: lastDate,
      ),
    );
  }

  @override
  State<AppDateRangePickerSheet> createState() =>
      _AppDateRangePickerSheetState();
}

class _AppDateRangePickerSheetState extends State<AppDateRangePickerSheet> {
  late final DateTime _firstDay;
  late final DateTime _lastDay;
  late final List<DateTime> _months;

  DateTime? _start;
  DateTime? _end;

  @override
  void initState() {
    super.initState();
    final today = _dayOf(DateTime.now());
    _firstDay = _dayOf(widget.firstDate ?? today);
    _lastDay = _dayOf(
      widget.lastDate ?? DateTime(today.year + 1, today.month, today.day),
    );

    _months = [
      for (var m = DateTime(_firstDay.year, _firstDay.month);
          !m.isAfter(DateTime(_lastDay.year, _lastDay.month));
          m = DateTime(m.year, m.month + 1))
        m,
    ];

    final init = widget.initial;
    if (init != null) {
      _start = _dayOf(init.start);
      _end = _dayOf(init.end);
    }
  }

  bool _isSelectable(DateTime day) =>
      !day.isBefore(_firstDay) && !day.isAfter(_lastDay);

  /// The first tap (or a tap before an open start) anchors the span; the next
  /// one closes it.
  void _onDayTap(DateTime day) {
    setState(() {
      final start = _start;
      if (start == null || _end != null || day.isBefore(start)) {
        _start = day;
        _end = null;
        return;
      }
      _end = day;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final start = _start;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          12.kh,
          Container(
            width: 32.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: c.textSecondary.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          12.kh,
          Text(
            'select_period'.tr(),
            style: AppText.heading20.copyWith(color: c.textPrimary),
          ),
          4.kh,
          Text(
            _rangeLabel,
            style: AppText.regular13.copyWith(color: c.textMuted),
          ),
          12.kh,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Row(
              children: [
                for (var weekday = 1; weekday <= 7; weekday++)
                  Expanded(
                    child: Text(
                      'weekday_short_$weekday'.tr(),
                      textAlign: TextAlign.center,
                      style: AppText.semibold12.copyWith(color: c.textMuted),
                    ),
                  ),
              ],
            ),
          ),
          8.kh,
          Divider(height: 1, color: c.divider),
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(14.w, 16.h, 14.w, 8.h),
              physics: const BouncingScrollPhysics(),
              itemCount: _months.length,
              itemBuilder: (_, index) => _MonthGrid(
                month: _months[index],
                start: _start,
                end: _end,
                isSelectable: _isSelectable,
                onDayTap: _onDayTap,
              ),
            ),
          ),
          Padding(
            // `useSafeArea` on a modal sheet only guards the top, so the home
            // indicator has to be paid for here.
            padding: EdgeInsets.fromLTRB(
              14.w,
              4.h,
              14.w,
              16.h + MediaQuery.of(context).padding.bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _SheetButton(
                    label: 'cancel_button'.tr(),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                8.kw,
                Expanded(
                  child: _SheetButton(
                    label: 'apply_button'.tr(),
                    gradient: AppGradients.brand,
                    // Nothing picked yet — there is no range to hand back.
                    onTap: start == null
                        ? null
                        : () => Navigator.of(context).pop(
                              DateTimeRange(start: start, end: _end ?? start),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _rangeLabel {
    final start = _start;
    if (start == null) return 'select_period_hint'.tr();
    final from = _fmtDay(start);
    final end = _end;
    return end == null ? from : '$from – ${_fmtDay(end)}';
  }

  static String _fmtDay(DateTime d) =>
      '${d.day} ${'month_short_${d.month}'.tr()} ${d.year}';
}

/// One month — its name, then the day grid, weeks running Monday → Sunday.
class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.start,
    required this.end,
    required this.isSelectable,
    required this.onDayTap,
  });

  final DateTime month;
  final DateTime? start;
  final DateTime? end;
  final bool Function(DateTime) isSelectable;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    // Blank cells before the 1st so it lands under its weekday column.
    final leading = DateTime(month.year, month.month).weekday - 1;
    final cells = leading + daysInMonth;
    final rows = (cells / 7).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${'month_full_${month.month}'.tr()} ${month.year}',
          style: AppText.semibold14.copyWith(color: c.textPrimary),
        ),
        8.kh,
        for (var row = 0; row < rows; row++)
          Row(
            children: [
              for (var col = 0; col < 7; col++)
                Expanded(
                  child: Builder(
                    builder: (_) {
                      final dayNumber = row * 7 + col - leading + 1;
                      if (dayNumber < 1 || dayNumber > daysInMonth) {
                        return SizedBox(height: 44.h);
                      }
                      return _DayCell(
                        day: DateTime(month.year, month.month, dayNumber),
                        start: start,
                        end: end,
                        isSelectable: isSelectable,
                        onTap: onDayTap,
                      );
                    },
                  ),
                ),
            ],
          ),
        16.kh,
      ],
    );
  }
}

/// A single day. The span between the endpoints is a flat [AppColorScheme.control]
/// band, painted as two half-cells so consecutive days join up seamlessly; the
/// endpoints themselves sit on top as indigo gradient circles.
class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.start,
    required this.end,
    required this.isSelectable,
    required this.onTap,
  });

  final DateTime day;
  final DateTime? start;
  final DateTime? end;
  final bool Function(DateTime) isSelectable;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    final isStart = start != null && _sameDay(day, start!);
    final isEnd = end != null && _sameDay(day, end!);
    final isEndpoint = isStart || isEnd;
    final enabled = isSelectable(day);
    final isToday = _sameDay(day, DateTime.now());

    // A band exists only once the span is closed and covers more than one day.
    final hasSpan = start != null && end != null && !_sameDay(start!, end!);
    final inSpan = hasSpan && day.isAfter(start!) && day.isBefore(end!);
    final bandLeft = hasSpan && (inSpan || isEnd);
    final bandRight = hasSpan && (inSpan || isStart);

    final Color textColor;
    if (isEndpoint) {
      textColor = AppColors.onBrand;
    } else if (!enabled) {
      textColor = c.disabled;
    } else if (isToday) {
      textColor = c.primary;
    } else {
      textColor = c.textPrimary;
    }

    return GestureDetector(
      onTap: enabled ? () => onTap(day) : null,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 44.h,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              children: [
                Expanded(child: _Band(show: bandLeft, color: c.control)),
                Expanded(child: _Band(show: bandRight, color: c.control)),
              ],
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 38.h,
              height: 38.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: isEndpoint ? AppGradients.indigo : null,
                shape: BoxShape.circle,
                border: isToday && !isEndpoint
                    ? Border.all(color: c.primary, width: 1.5)
                    : null,
              ),
              child: Text(
                '${day.day}',
                style: AppText.semibold14.copyWith(color: textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Half of a day cell's span band — a full-height fill, or nothing.
class _Band extends StatelessWidget {
  const _Band({required this.show, required this.color});

  final bool show;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38.h,
      child: show ? ColoredBox(color: color) : null,
    );
  }
}

/// Pill action button sized like the app's primary `GradientButton` (50h / 44r)
/// — [gradient] makes it the primary one. A null [onTap] renders it dimmed.
class _SheetButton extends StatelessWidget {
  const _SheetButton({
    required this.label,
    required this.onTap,
    this.gradient,
  });

  final String label;
  final VoidCallback? onTap;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = onTap != null;

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Bouncing(
        onTap: () => onTap?.call(),
        child: Container(
          height: 50.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: gradient == null ? c.control : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(44.r),
          ),
          child: Text(
            label,
            style: AppText.medium16.copyWith(
              color: gradient == null ? c.textPrimary : AppColors.onBrand,
            ),
          ),
        ),
      ),
    );
  }
}
