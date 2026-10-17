import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/segmented_slider_track.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/filter_bottom_sheet.dart';

/// A window of the day, in minutes past midnight — what the "By time" filter
/// picks. [FilterResult.dayStart]–[FilterResult.dayEnd] is the whole day.
class DayWindow {
  const DayWindow(this.from, this.to);

  final int from;
  final int to;

  static const all = DayWindow(FilterResult.dayStart, FilterResult.dayEnd);

  bool get isAll => from <= FilterResult.dayStart && to >= FilterResult.dayEnd;

  /// "HH:mm", the shape `discovery/classes` takes `from_time`/`to_time` in.
  static String hhmm(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get label => '${hhmm(from)} – ${hhmm(to)}';

  @override
  bool operator ==(Object other) =>
      other is DayWindow && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);
}

/// The three one-tap windows under the slider.
enum DayPart {
  morning(DayWindow(6 * 60, 12 * 60)),
  afternoon(DayWindow(12 * 60, 18 * 60)),
  evening(DayWindow(18 * 60, FilterResult.dayEnd));

  const DayPart(this.window);

  final DayWindow window;

  String get label => switch (this) {
        DayPart.morning => 'time_morning'.tr(),
        DayPart.afternoon => 'time_afternoon'.tr(),
        DayPart.evening => 'time_evening'.tr(),
      };
}

/// The time window control: the picked range in large type, a two-thumb
/// slider over the day in half-hour steps, and Morning / Afternoon / Evening
/// presets.
///
/// Shared by the map's "By time" sheet ([TimeFilterSheet]) and the full
/// [FilterBottomSheet], so both edit the same value with the same control.
class TimeRangeField extends StatelessWidget {
  const TimeRangeField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final DayWindow value;
  final ValueChanged<DayWindow> onChanged;

  /// Half-hour steps. The slider runs to 24:00 so the steps divide evenly;
  /// the last stop is shown and sent as 23:59.
  static const _step = 30;
  static const _sliderEnd = 24 * 60;

  static double _toSlider(int minutes) => minutes >= FilterResult.dayEnd
      ? _sliderEnd.toDouble()
      : minutes.toDouble();

  static int _fromSlider(double value) {
    final minutes = value.round();
    return minutes >= _sliderEnd ? FilterResult.dayEnd : minutes;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          value.label,
          textAlign: TextAlign.center,
          style: AppText.heading20.copyWith(color: c.primary),
        ),
        8.kh,
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6.h,
            activeTrackColor: c.primary,
            inactiveTrackColor: c.progressTrack,
            overlayColor: c.primary.withValues(alpha: 0.12),
            rangeThumbShape: RingedRangeSliderThumb(color: c.primary),
            // Four quarters of the day, broken at 06:00, 12:00 and 18:00 so
            // the labels under the line have a mark to sit under.
            rangeTrackShape: const SegmentedRangeSliderTrackShape(segments: 4),
            rangeTickMarkShape:
                const RoundRangeSliderTickMarkShape(tickMarkRadius: 0),
            showValueIndicator: ShowValueIndicator.never,
          ),
          child: RangeSlider(
            min: 0,
            max: _sliderEnd.toDouble(),
            divisions: _sliderEnd ~/ _step,
            values: RangeValues(_toSlider(value.from), _toSlider(value.to)),
            onChanged: (v) {
              // Thumbs that meet would be an empty window.
              if (v.end - v.start < _step) return;
              onChanged(DayWindow(_fromSlider(v.start), _fromSlider(v.end)));
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final mark in const [
                0,
                6 * 60,
                12 * 60,
                18 * 60,
                FilterResult.dayEnd
              ])
                Text(
                  DayWindow.hhmm(mark),
                  style: AppText.regular12.copyWith(color: c.textSecondary),
                ),
            ],
          ),
        ),
        16.kh,
        Row(
          children: [
            for (final part in DayPart.values) ...[
              if (part != DayPart.values.first) 8.kw,
              Expanded(
                child: _DayPartChip(
                  label: part.label,
                  selected: value == part.window,
                  // A second tap on the active preset widens back to the day.
                  onTap: () => onChanged(
                      value == part.window ? DayWindow.all : part.window),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// A preset under the slider — [FilterPill]'s look, stretched to a third of
/// the row so the three line up.
class _DayPartChip extends StatelessWidget {
  const _DayPartChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? null : c.control,
          gradient: selected ? AppGradients.indigo : null,
          borderRadius: BorderRadius.circular(40.r),
        ),
        child: Text(
          label,
          style: AppText.semibold12.copyWith(
            color: selected ? AppColors.onBrand : c.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// The map's "By time" chip: [TimeRangeField] alone in a sheet, with Clear and
/// Apply. Returns the picked window, [DayWindow.all] when cleared, and null
/// when dismissed.
class TimeFilterSheet extends StatefulWidget {
  const TimeFilterSheet({super.key, required this.initial});

  final DayWindow initial;

  static Future<DayWindow?> show(
    BuildContext context, {
    required DayWindow initial,
  }) {
    return showModalBottomSheet<DayWindow>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.colors.surface,
      barrierColor: AppColors.ink.withValues(alpha: 0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => TimeFilterSheet(initial: initial),
    );
  }

  @override
  State<TimeFilterSheet> createState() => _TimeFilterSheetState();
}

class _TimeFilterSheetState extends State<TimeFilterSheet> {
  late DayWindow _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Column(
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
          'filter_class_time'.tr(),
          style: AppText.heading20.copyWith(color: c.textPrimary),
        ),
        16.kh,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          child: TimeRangeField(
            value: _value,
            onChanged: (v) => setState(() => _value = v),
          ),
        ),
        24.kh,
        Padding(
          padding: EdgeInsets.fromLTRB(
            14.w,
            0,
            14.w,
            16.h + MediaQuery.of(context).padding.bottom,
          ),
          child: Row(
            children: [
              Expanded(
                child: FilterSheetButton(
                  label: 'clear_button'.tr(),
                  enabled: !_value.isAll,
                  onTap: () => setState(() => _value = DayWindow.all),
                ),
              ),
              8.kw,
              Expanded(
                child: FilterSheetButton(
                  label: 'apply_button'.tr(),
                  gradient: AppGradients.brand,
                  onTap: () => Navigator.of(context).pop(_value),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
