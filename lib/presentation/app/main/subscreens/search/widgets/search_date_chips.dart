import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/date_range_picker_sheet.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/filter_bottom_sheet.dart';

/// "When": Today · Tomorrow · This week · a calendar range, as a row under the
/// search field. The filter sheet's "Sana" section, moved out to where a parent
/// sees it before ever opening the sheet — "what is on today" is the first
/// question, not a buried one.
///
/// One tap applies: picking a preset narrows the list at once, tapping the lit
/// one again lifts it. The calendar chip opens the range picker and then reads
/// as the range it holds, with an × to clear it.
class SearchDateChips extends StatelessWidget {
  const SearchDateChips({
    super.key,
    required this.filter,
    required this.onChanged,
  });

  final FilterResult filter;
  final ValueChanged<FilterResult> onChanged;

  void _toggle(DatePreset preset) {
    onChanged(_withDate(
      filter.datePreset == preset ? DatePreset.none : preset,
      null,
      null,
    ));
  }

  Future<void> _pickRange(BuildContext context) async {
    final from = filter.fromDate;
    final to = filter.toDate;
    final picked = await AppDateRangePickerSheet.show(
      context,
      initial: filter.datePreset == DatePreset.custom && from != null
          ? DateTimeRange(start: from, end: to ?? from)
          : null,
    );
    if (picked == null) return;
    onChanged(_withDate(DatePreset.custom, picked.start, picked.end));
  }

  /// [FilterResult.copyWith] reads null as "keep", so clearing the dates needs
  /// the whole filter rebuilt with them left out.
  FilterResult _withDate(DatePreset preset, DateTime? from, DateTime? to) {
    final f = filter;
    final next = FilterResult(
      datePreset: preset,
      fromDate: from,
      toDate: to,
      kind: f.kind,
      ageYears: f.ageYears,
      ageToYears: f.ageToYears,
      gender: f.gender,
      pricePreset: f.pricePreset,
      priceRange: f.priceRange,
      districts: f.districts,
      categories: f.categories,
      fromMinute: f.fromMinute,
      toMinute: f.toMinute,
    );
    return f.hasRadius
        ? next.copyWith(
            radiusKm: f.radiusKm,
            nearLat: f.nearLat,
            nearLng: f.nearLng,
          )
        : next;
  }

  static String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}';

  String get _rangeLabel {
    final from = filter.fromDate;
    if (filter.datePreset != DatePreset.custom || from == null) {
      return 'filter_choose_calendar'.tr();
    }
    final to = filter.toDate;
    if (to == null || DateUtils.isSameDay(from, to)) return _fmt(from);
    return '${_fmt(from)} – ${_fmt(to)}';
  }

  @override
  Widget build(BuildContext context) {
    final preset = filter.datePreset;
    final custom = preset == DatePreset.custom;
    return SizedBox(
      height: 36.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        physics: const BouncingScrollPhysics(),
        children: [
          _DateChip(
            label: 'today'.tr(),
            selected: preset == DatePreset.today,
            onTap: () => _toggle(DatePreset.today),
          ),
          8.horizontalSpace,
          _DateChip(
            label: 'tomorrow'.tr(),
            selected: preset == DatePreset.tomorrow,
            onTap: () => _toggle(DatePreset.tomorrow),
          ),
          8.horizontalSpace,
          _DateChip(
            label: 'this_week'.tr(),
            selected: preset == DatePreset.thisWeek,
            onTap: () => _toggle(DatePreset.thisWeek),
          ),
          8.horizontalSpace,
          _DateChip(
            label: _rangeLabel,
            selected: custom,
            leadingCalendar: true,
            onTap: () => _pickRange(context),
            onClear: custom ? () => _toggle(DatePreset.custom) : null,
          ),
        ],
      ),
    );
  }
}

/// One date pill: a quiet outlined surface at rest, the brand gradient when lit.
///
/// The gradient is a layer that fades in over the resting surface, rather
/// than one decoration lerped into the other. Lerping a gradient against a
/// flat colour does not cross-fade — the colour fades out on its own curve
/// while the gradient scales in on another, so the chip went see-through
/// half way and blinked. The label's colour and the chip's width animate
/// too, so the calendar chip growing into "14.11 – 20.11" slides instead of
/// jumping.
class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.leadingCalendar = false,
    this.onClear,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool leadingCalendar;

  /// Shown as a trailing × while set — the calendar chip's own way off, since
  /// tapping it re-opens the picker instead.
  final VoidCallback? onClear;

  static const _duration = Duration(milliseconds: 220);
  static const _curve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final radius = BorderRadius.circular(40.r);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: selected ? 1 : 0),
        duration: _duration,
        curve: _curve,
        builder: (context, t, child) {
          final fg = Color.lerp(c.textPrimary, AppColors.onBrand, t)!;
          final iconColor = Color.lerp(c.textSecondary, AppColors.onBrand, t)!;
          return DecoratedBox(
            decoration: BoxDecoration(
              color: c.control,
              borderRadius: radius,
              border: Border.all(
                color: Color.lerp(c.controlBorder, c.control, t)!,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: t,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppGradients.indigo,
                        borderRadius: radius,
                      ),
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: _duration,
                  curve: _curve,
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      leadingCalendar ? 10.w : 14.w,
                      0,
                      onClear != null ? 6.w : 14.w,
                      0,
                    ),
                    child: SizedBox(
                      height: 36.h - 2,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (leadingCalendar) ...[
                            Assets.icons.calendar.svg(
                              width: 16.w,
                              height: 16.w,
                              colorFilter:
                                  ColorFilter.mode(iconColor, BlendMode.srcIn),
                            ),
                            6.horizontalSpace,
                          ],
                          Text(
                            label,
                            maxLines: 1,
                            style: AppText.semibold14.copyWith(color: fg),
                          ),
                          if (onClear != null)
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: onClear,
                              child: Padding(
                                padding: EdgeInsets.only(left: 4.w),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 16.sp,
                                  color: fg,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
