import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/auth/gradient_button.dart';

/// App-styled 24h time picker sheet — hour and minute wheels under a brand
/// selection band, with a gradient confirm action.
///
/// Resolves the picked time, or `null` when the user backs out:
/// `final t = await AppTimePickerSheet.show(context, initial: start);`
///
/// [minTime] / [maxTime] constrain the selection to a slot window: values
/// outside the window render disabled and the wheels snap back off them, so an
/// out-of-range time can never be confirmed.
class AppTimePickerSheet extends StatefulWidget {
  const AppTimePickerSheet({
    super.key,
    this.initial,
    this.minTime,
    this.maxTime,
    this.minuteInterval = 5,
  });

  final TimeOfDay? initial;
  final TimeOfDay? minTime;
  final TimeOfDay? maxTime;

  /// Granularity of the minute wheel. Must divide 60 evenly.
  final int minuteInterval;

  static Future<TimeOfDay?> show(
    BuildContext context, {
    TimeOfDay? initial,
    TimeOfDay? minTime,
    TimeOfDay? maxTime,
    int minuteInterval = 5,
  }) {
    return showModalBottomSheet<TimeOfDay>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (_) => AppTimePickerSheet(
        initial: initial,
        minTime: minTime,
        maxTime: maxTime,
        minuteInterval: minuteInterval,
      ),
    );
  }

  @override
  State<AppTimePickerSheet> createState() => _AppTimePickerSheetState();
}

class _AppTimePickerSheetState extends State<AppTimePickerSheet> {
  late final List<int> _minutes = [
    for (var m = 0; m < 60; m += widget.minuteInterval) m,
  ];

  late FixedExtentScrollController _hourCtrl;
  late FixedExtentScrollController _minuteCtrl;

  late int _hour;
  late int _minute;

  int get _minMins => _asMins(widget.minTime) ?? 0;
  int get _maxMins => _asMins(widget.maxTime) ?? 24 * 60 - 1;

  int? _asMins(TimeOfDay? t) => t == null ? null : t.hour * 60 + t.minute;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial ?? TimeOfDay.now();

    // Snap the incoming minute onto the wheel's grid, then pull the whole time
    // inside the window so the sheet never opens on a disabled value.
    final snapped = _snapToGrid(initial.hour * 60 + initial.minute);
    final start = _clamp(snapped);

    _hour = start ~/ 60;
    _minute = start % 60;
    _hourCtrl = FixedExtentScrollController(initialItem: _hour);
    _minuteCtrl = FixedExtentScrollController(
      initialItem: _minutes.indexOf(_minute).clamp(0, _minutes.length - 1),
    );
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minuteCtrl.dispose();
    super.dispose();
  }

  /// Rounds [mins] down onto the minute grid.
  int _snapToGrid(int mins) =>
      (mins ~/ 60) * 60 + (mins % 60) ~/ widget.minuteInterval * widget.minuteInterval;

  /// Pulls [mins] into [_minMins].._maxMins, landing on a grid value.
  int _clamp(int mins) {
    if (mins < _minMins) {
      // Round the floor *up* to the grid — rounding down would fall below it.
      final m = _minMins % 60;
      final rem = m % widget.minuteInterval;
      return rem == 0 ? _minMins : _minMins + (widget.minuteInterval - rem);
    }
    if (mins > _maxMins) return _snapToGrid(_maxMins);
    return mins;
  }

  bool _hourEnabled(int h) {
    // A hour is reachable when at least one of its grid minutes is in range.
    for (final m in _minutes) {
      if (_inRange(h * 60 + m)) return true;
    }
    return false;
  }

  bool _minuteEnabled(int m) => _inRange(_hour * 60 + m);

  bool _inRange(int mins) => mins >= _minMins && mins <= _maxMins;

  void _onHourChanged(int index) {
    setState(() => _hour = index);
    // The new hour may not admit the current minute (first/last hour of the
    // window) — walk the minute wheel to the nearest legal value.
    if (_inRange(_hour * 60 + _minute)) return;
    final target = _clamp(_hour * 60 + _minute);
    if (target ~/ 60 != _hour) {
      // The whole hour is out of the window; bounce the hour wheel back too.
      _hourCtrl.animateToItem(
        target ~/ 60,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
      setState(() => _hour = target ~/ 60);
    }
    _snapMinuteTo(target % 60);
  }

  void _onMinuteChanged(int index) {
    final m = _minutes[index];
    if (_minuteEnabled(m)) {
      setState(() => _minute = m);
      return;
    }
    _snapMinuteTo(_clamp(_hour * 60 + m) % 60);
  }

  void _snapMinuteTo(int minute) {
    setState(() => _minute = minute);
    final index = _minutes.indexOf(minute).clamp(0, _minutes.length - 1);
    if (_minuteCtrl.selectedItem == index) return;
    // Deferred: the wheel is mid-notification, it can't be driven from inside.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_minuteCtrl.hasClients) return;
      _minuteCtrl.animateToItem(
        index,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  String _two(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        14.w,
        12.h,
        14.w,
        MediaQuery.of(context).viewPadding.bottom + 24.h,
      ),
      decoration: BoxDecoration(
        color: c.scaffoldBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pull handle.
          Container(
            width: 32.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.inkMuted.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          16.verticalSpace,
          Text(
            'book_select_time'.tr(),
            style: AppText.semibold18.copyWith(color: c.textPrimary),
          ),
          if (widget.minTime != null || widget.maxTime != null) ...[
            4.verticalSpace,
            Text(
              'time_picker_range'.tr(
                args: [
                  _fmt(widget.minTime ?? const TimeOfDay(hour: 0, minute: 0)),
                  _fmt(widget.maxTime ?? const TimeOfDay(hour: 23, minute: 59)),
                ],
              ),
              style: AppText.regular13.copyWith(color: c.textSecondary),
            ),
          ],
          16.verticalSpace,
          _Wheels(
            hour: _hour,
            minute: _minute,
            minutes: _minutes,
            hourCtrl: _hourCtrl,
            minuteCtrl: _minuteCtrl,
            hourEnabled: _hourEnabled,
            minuteEnabled: _minuteEnabled,
            onHourChanged: _onHourChanged,
            onMinuteChanged: _onMinuteChanged,
            two: _two,
          ),
          20.verticalSpace,
          Row(
            children: [
              Expanded(
                child: _CancelButton(
                  label: 'cancel'.tr(),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
              8.horizontalSpace,
              Expanded(
                child: GradientButton(
                  text: 'continue'.tr(),
                  onPressed: () => Navigator.of(context)
                      .pop(TimeOfDay(hour: _hour, minute: _minute)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(TimeOfDay t) => '${_two(t.hour)}:${_two(t.minute)}';
}

/// Hour : minute wheels sharing one highlighted selection band.
class _Wheels extends StatelessWidget {
  const _Wheels({
    required this.hour,
    required this.minute,
    required this.minutes,
    required this.hourCtrl,
    required this.minuteCtrl,
    required this.hourEnabled,
    required this.minuteEnabled,
    required this.onHourChanged,
    required this.onMinuteChanged,
    required this.two,
  });

  final int hour;
  final int minute;
  final List<int> minutes;
  final FixedExtentScrollController hourCtrl;
  final FixedExtentScrollController minuteCtrl;
  final bool Function(int) hourEnabled;
  final bool Function(int) minuteEnabled;
  final ValueChanged<int> onHourChanged;
  final ValueChanged<int> onMinuteChanged;
  final String Function(int) two;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final itemExtent = 46.h;

    return SizedBox(
      height: 190.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Selection band — the brand-tinted pill the picked time sits in.
          Container(
            height: itemExtent,
            margin: EdgeInsets.symmetric(horizontal: 24.w),
            decoration: BoxDecoration(
              color: c.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: c.primary.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _Wheel(
                  controller: hourCtrl,
                  itemExtent: itemExtent,
                  count: 24,
                  selected: hour,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 14.w),
                  label: (i) => two(i),
                  enabled: hourEnabled,
                  onChanged: onHourChanged,
                ),
              ),
              Text(
                ':',
                style: AppText.semibold24.copyWith(color: c.textPrimary),
              ),
              Expanded(
                child: _Wheel(
                  controller: minuteCtrl,
                  itemExtent: itemExtent,
                  count: minutes.length,
                  selected: minutes.indexOf(minute),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 14.w),
                  label: (i) => two(minutes[i]),
                  enabled: (i) => minuteEnabled(minutes[i]),
                  onChanged: onMinuteChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One column. [enabled] is asked per *index*, so the caller decides what an
/// index means (an hour, or a slot on the minute grid).
class _Wheel extends StatelessWidget {
  const _Wheel({
    required this.controller,
    required this.itemExtent,
    required this.count,
    required this.selected,
    required this.alignment,
    required this.padding,
    required this.label,
    required this.enabled,
    required this.onChanged,
  });

  final FixedExtentScrollController controller;
  final double itemExtent;
  final int count;
  final int selected;
  final Alignment alignment;
  final EdgeInsets padding;
  final String Function(int) label;
  final bool Function(int) enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: itemExtent,
      diameterRatio: 1.6,
      perspective: 0.003,
      overAndUnderCenterOpacity: 0.55,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: count,
        builder: (context, index) {
          final isSelected = index == selected;
          final isEnabled = enabled(index);
          final Color color;
          if (!isEnabled) {
            color = c.disabled;
          } else if (isSelected) {
            color = c.textPrimary;
          } else {
            color = c.textSecondary;
          }
          return Container(
            alignment: alignment,
            padding: padding,
            child: Text(
              label(index),
              style: (isSelected ? AppText.semibold24 : AppText.regular16)
                  .copyWith(color: color),
            ),
          );
        },
      ),
    );
  }
}

/// Flat secondary action, matching the cancel-booking sheet's pill.
class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 50.h,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(44.r),
          border: Border.all(color: c.border),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.medium16.copyWith(color: c.textPrimary),
        ),
      ),
    );
  }
}
