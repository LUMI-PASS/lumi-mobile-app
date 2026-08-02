import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/constants/districts.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/bouncing_button.dart';
import 'package:lumi_pass/common/widget/date_range_picker_sheet.dart';

enum DatePreset { none, today, tomorrow, thisWeek, custom }

enum Gender { any, boy, girl }

enum PricePreset { any, custom }

class FilterResult {
  final DatePreset datePreset;
  final DateTime? fromDate;
  final DateTime? toDate;

  /// Lower bound of the age range (the "от" field).
  final int? ageYears;

  /// Upper bound of the age range (the "до" field).
  final int? ageToYears;
  final Gender gender;
  final PricePreset pricePreset;
  final RangeValues priceRange;

  /// Tashkent district slugs the buyer ticked. Empty = anywhere; the backend
  /// takes them as a comma-separated `districts` query param.
  final Set<String> districts;

  const FilterResult({
    this.datePreset = DatePreset.none,
    this.fromDate,
    this.toDate,
    this.ageYears,
    this.ageToYears,
    this.gender = Gender.any,
    this.pricePreset = PricePreset.any,
    this.priceRange = const RangeValues(minPrice, maxPrice),
    this.districts = const {},
  });

  static const double minPrice = 10000;
  static const double maxPrice = 400000;

  // Keep backward compat
  DateTime? get customDate => fromDate;

  FilterResult copyWith({
    DatePreset? datePreset,
    DateTime? fromDate,
    DateTime? toDate,
    int? ageYears,
    int? ageToYears,
    Gender? gender,
    PricePreset? pricePreset,
    RangeValues? priceRange,
    Set<String>? districts,
  }) {
    return FilterResult(
      datePreset: datePreset ?? this.datePreset,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      ageYears: ageYears ?? this.ageYears,
      ageToYears: ageToYears ?? this.ageToYears,
      gender: gender ?? this.gender,
      pricePreset: pricePreset ?? this.pricePreset,
      priceRange: priceRange ?? this.priceRange,
      districts: districts ?? this.districts,
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  final FilterResult? initial;

  const FilterBottomSheet({
    super.key,
    this.initial,
  });

  static Future<FilterResult?> show(
    BuildContext context, {
    FilterResult? initial,
  }) {
    return showModalBottomSheet<FilterResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.colors.surface,
      barrierColor: AppColors.ink.withValues(alpha: 0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => FilterBottomSheet(initial: initial),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late DatePreset _datePreset;
  DateTime? _fromDate;
  DateTime? _toDate;
  final TextEditingController _ageFromController = TextEditingController();
  final TextEditingController _ageToController = TextEditingController();
  Gender _gender = Gender.any;
  Set<String> _districts = <String>{};
  RangeValues _range =
      const RangeValues(FilterResult.minPrice, FilterResult.maxPrice);

  @override
  void initState() {
    super.initState();
    final init = widget.initial ?? const FilterResult();
    _datePreset = init.datePreset;
    _fromDate = init.fromDate;
    _toDate = init.toDate;
    _gender = init.gender;
    _districts = {...init.districts};
    _range = init.priceRange;
    if (init.ageYears != null) _ageFromController.text = '${init.ageYears}';
    if (init.ageToYears != null) _ageToController.text = '${init.ageToYears}';
  }

  @override
  void dispose() {
    _ageFromController.dispose();
    _ageToController.dispose();
    super.dispose();
  }

  int? _parseAge(TextEditingController controller) {
    final value = int.tryParse(controller.text.trim());
    if (value == null || value < 1 || value > 16) return null;
    return value;
  }

  bool get _isPriceChanged =>
      _range.start != FilterResult.minPrice ||
      _range.end != FilterResult.maxPrice;

  FilterResult _buildResult() => FilterResult(
        datePreset: _datePreset,
        fromDate: _fromDate,
        toDate: _toDate,
        ageYears: _parseAge(_ageFromController),
        ageToYears: _parseAge(_ageToController),
        gender: _gender,
        pricePreset: _isPriceChanged ? PricePreset.custom : PricePreset.any,
        priceRange: _range,
        districts: _districts,
      );

  void _selectDatePreset(DatePreset preset) {
    setState(() {
      _datePreset = preset;
      _fromDate = null;
      _toDate = null;
    });
  }

  Future<void> _pickDateRange() async {
    final picked = await AppDateRangePickerSheet.show(
      context,
      initial: _fromDate != null && _toDate != null
          ? DateTimeRange(start: _fromDate!, end: _toDate!)
          : null,
    );
    if (picked == null) return;
    setState(() {
      _datePreset = DatePreset.custom;
      _fromDate = picked.start;
      _toDate = picked.end;
    });
  }

  String get _calendarChipLabel {
    if (_datePreset != DatePreset.custom || _fromDate == null) {
      return 'filter_choose_calendar'.tr();
    }
    final from = _fmtDate(_fromDate!);
    return _toDate == null ? from : '$from – ${_fmtDate(_toDate!)}';
  }

  static String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

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
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      'filter_title'.tr(),
                      textAlign: TextAlign.center,
                      style: AppText.heading20.copyWith(color: c.textPrimary),
                    ),
                  ),
                  8.kh,
                  _Section(
                    label: 'filter_date'.tr(),
                    child: Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        _FilterChip(
                          label: 'today'.tr(),
                          selected: _datePreset == DatePreset.today,
                          onTap: () => _selectDatePreset(DatePreset.today),
                        ),
                        _FilterChip(
                          label: 'tomorrow'.tr(),
                          selected: _datePreset == DatePreset.tomorrow,
                          onTap: () => _selectDatePreset(DatePreset.tomorrow),
                        ),
                        _FilterChip(
                          label: 'this_week'.tr(),
                          selected: _datePreset == DatePreset.thisWeek,
                          onTap: () => _selectDatePreset(DatePreset.thisWeek),
                        ),
                        _FilterChip(
                          label: _calendarChipLabel,
                          selected: _datePreset == DatePreset.custom,
                          onTap: _pickDateRange,
                        ),
                      ],
                    ),
                  ),
                  16.kh,
                  _Section(
                    label: 'age'.tr(),
                    child: Row(
                      children: [
                        Expanded(
                          child: _AgeField(
                            controller: _ageFromController,
                            hint: 'age_from'.tr(),
                          ),
                        ),
                        8.kw,
                        Expanded(
                          child: _AgeField(
                            controller: _ageToController,
                            hint: 'age_to'.tr(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  16.kh,
                  _Section(
                    label: 'filter_district'.tr(),
                    child: Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        for (final d in kTashkentDistricts)
                          _FilterChip(
                            label: d.label,
                            selected: _districts.contains(d.key),
                            // Multi-select: each chip toggles on its own, so a
                            // parent can pick the two districts they'd actually
                            // travel to. No chip selected = anywhere.
                            onTap: () => setState(() {
                              if (!_districts.remove(d.key)) {
                                _districts.add(d.key);
                              }
                            }),
                          ),
                      ],
                    ),
                  ),
                  16.kh,
                  _Section(
                    label: 'gender'.tr(),
                    child: Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        _FilterChip(
                          label: 'gender_all'.tr(),
                          selected: _gender == Gender.any,
                          onTap: () => setState(() => _gender = Gender.any),
                        ),
                        _FilterChip(
                          label: 'filter_for_boys'.tr(),
                          selected: _gender == Gender.boy,
                          onTap: () => setState(() => _gender = Gender.boy),
                        ),
                        _FilterChip(
                          label: 'filter_for_girls'.tr(),
                          selected: _gender == Gender.girl,
                          onTap: () => setState(() => _gender = Gender.girl),
                        ),
                      ],
                    ),
                  ),
                  16.kh,
                  _Section(
                    label: 'price_label'.tr(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _fmtPrice(_range.start),
                              style: AppText.semibold12
                                  .copyWith(color: c.textPrimary),
                            ),
                            Text(
                              _fmtPrice(_range.end),
                              style: AppText.semibold12
                                  .copyWith(color: c.textPrimary),
                            ),
                          ],
                        ),
                        6.kh,
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 6.h,
                            activeTrackColor: c.primary,
                            inactiveTrackColor: c.progressTrack,
                            overlayColor: c.primary.withValues(alpha: 0.12),
                            rangeThumbShape: _RoundThumbShape(color: c.primary),
                            rangeTrackShape:
                                const RoundedRectRangeSliderTrackShape(),
                            showValueIndicator: ShowValueIndicator.never,
                          ),
                          child: RangeSlider(
                            min: FilterResult.minPrice,
                            max: FilterResult.maxPrice,
                            values: _range,
                            onChanged: (v) => setState(() => _range = v),
                          ),
                        ),
                      ],
                    ),
                  ),
                  16.kh,
                ],
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
                    onTap: () => Navigator.of(context).pop(_buildResult()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _fmtPrice(double value) {
    final grouped = value.toInt().toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => ' ',
        );
    return '$grouped ${'uzs_currency'.tr()}';
  }
}

/// Section label + its content, the 8px-gap block the sheet repeats.
class _Section extends StatelessWidget {
  const _Section({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppText.medium14.copyWith(color: context.colors.textPrimary),
        ),
        8.kh,
        child,
      ],
    );
  }
}

/// Pill chip — indigo gradient when selected, flat control fill otherwise.
class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
    final textColor = selected ? AppColors.onBrand : c.textPrimary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: selected ? null : c.control,
          gradient: selected ? AppGradients.indigo : null,
          borderRadius: BorderRadius.circular(40.r),
        ),
        child: Text(label, style: AppText.semibold12.copyWith(color: textColor)),
      ),
    );
  }
}

/// One of the two age bounds — a 40h field with a trailing "лет" suffix.
class _AgeField extends StatelessWidget {
  const _AgeField({required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: c.control,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
              style: AppText.regular12.copyWith(color: c.textPrimary),
              cursorColor: c.primary,
              decoration: InputDecoration(
                isCollapsed: true,
                hintText: hint,
                hintStyle: AppText.regular12.copyWith(color: c.textMuted),
                border: InputBorder.none,
              ),
            ),
          ),
          8.kw,
          Text(
            'age_years_suffix'.tr(),
            style: AppText.regular12.copyWith(color: c.textMuted),
          ),
        ],
      ),
    );
  }
}

/// Pill action button sized like the app's primary [GradientButton] (50h /
/// 44r) — [gradient] makes it the primary one.
class _SheetButton extends StatelessWidget {
  const _SheetButton({
    required this.label,
    required this.onTap,
    this.gradient,
  });

  final String label;
  final VoidCallback onTap;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Bouncing(
      onTap: onTap,
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
    );
  }
}

/// Flat 20px round thumb — a filled brand dot with a thin light ring.
class _RoundThumbShape extends RangeSliderThumbShape {
  const _RoundThumbShape({required this.color});

  final Color color;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(20, 20);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = true,
    bool isOnTop = false,
    bool isPressed = false,
    required SliderThemeData sliderTheme,
    TextDirection textDirection = TextDirection.ltr,
    Thumb thumb = Thumb.start,
    double? textScaleFactor,
    Size? sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    canvas.drawCircle(center, 10, Paint()..color = color);
    canvas.drawCircle(
      center,
      9,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.onBrand.withValues(alpha: 0.35),
    );
  }
}
