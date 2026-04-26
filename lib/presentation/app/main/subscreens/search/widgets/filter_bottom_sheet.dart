import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/widget/container_3d.dart';

enum DatePreset { none, today, tomorrow, thisWeek, custom }

enum Gender { any, boy, girl }

enum PricePreset { any, custom }

class FilterResult {
  final DatePreset datePreset;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? ageYears;
  final Gender gender;
  final PricePreset pricePreset;
  final RangeValues priceRange;

  const FilterResult({
    this.datePreset = DatePreset.none,
    this.fromDate,
    this.toDate,
    this.ageYears,
    this.gender = Gender.any,
    this.pricePreset = PricePreset.any,
    this.priceRange = const RangeValues(0, 100),
  });

  // Keep backward compat
  DateTime? get customDate => fromDate;

  FilterResult copyWith({
    DatePreset? datePreset,
    DateTime? fromDate,
    DateTime? toDate,
    int? ageYears,
    Gender? gender,
    PricePreset? pricePreset,
    RangeValues? priceRange,
  }) {
    return FilterResult(
      datePreset: datePreset ?? this.datePreset,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      ageYears: ageYears ?? this.ageYears,
      gender: gender ?? this.gender,
      pricePreset: pricePreset ?? this.pricePreset,
      priceRange: priceRange ?? this.priceRange,
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  final FilterResult? initial;

  const FilterBottomSheet({super.key, this.initial});

  static Future<FilterResult?> show(
    BuildContext context, {
    FilterResult? initial,
  }) {
    return showModalBottomSheet<FilterResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      barrierColor: Colors.black54,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
  final TextEditingController _ageController = TextEditingController();
  Gender _gender = Gender.any;
  RangeValues _range = const RangeValues(0, 100);
  bool _showCustomDates = false;

  static const double _minPrice = 0;
  static const double _maxPrice = 100;

  @override
  void initState() {
    super.initState();
    final init = widget.initial ?? const FilterResult();
    _datePreset = init.datePreset;
    _fromDate = init.fromDate;
    _toDate = init.toDate;
    _gender = init.gender;
    _range = init.priceRange;
    if (init.ageYears != null) {
      _ageController.text = '${init.ageYears}';
    }
    _showCustomDates = _datePreset == DatePreset.custom;
  }

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _datePreset = DatePreset.none;
      _fromDate = null;
      _toDate = null;
      _ageController.clear();
      _gender = Gender.any;
      _range = const RangeValues(0, 100);
      _showCustomDates = false;
    });
  }

  int? get _parsedAge {
    final text = _ageController.text.trim();
    if (text.isEmpty) return null;
    final val = int.tryParse(text);
    if (val == null || val < 1 || val > 16) return null;
    return val;
  }

  bool get _isPriceChanged =>
      _range.start != _minPrice || _range.end != _maxPrice;

  FilterResult _buildResult() => FilterResult(
        datePreset: _datePreset,
        fromDate: _fromDate,
        toDate: _toDate,
        ageYears: _parsedAge,
        gender: _gender,
        pricePreset: _isPriceChanged ? PricePreset.custom : PricePreset.any,
        priceRange: _range,
      );

  void _selectDatePreset(DatePreset preset) {
    setState(() {
      _datePreset = preset;
      _showCustomDates = false;
      _fromDate = null;
      _toDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    final textColor = const Color(0xFF1E293B);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          12.kh,
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          16.kh,

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: 'Filters'.s(24).w(700).c(textColor),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36.w,
                      height: 36.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          24.kh,

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Date Section ───
                  _SectionLabel('Date'),
                  12.kh,
                  Row(
                    children: [
                      _DateChip(
                        text: 'Today',
                        selected: _datePreset == DatePreset.today,
                        onTap: () => _selectDatePreset(DatePreset.today),
                      ),
                      8.kw,
                      _DateChip(
                        text: 'Tomorrow',
                        selected: _datePreset == DatePreset.tomorrow,
                        onTap: () => _selectDatePreset(DatePreset.tomorrow),
                      ),
                      8.kw,
                      _DateChip(
                        text: 'This week',
                        selected: _datePreset == DatePreset.thisWeek,
                        onTap: () => _selectDatePreset(DatePreset.thisWeek),
                      ),
                    ],
                  ),
                  12.kh,

                  // Custom date toggle
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showCustomDates = !_showCustomDates;
                        if (_showCustomDates) {
                          _datePreset = DatePreset.custom;
                        }
                      });
                    },
                    child: Container3d(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 12.h),
                      depth: 2,
                      backgroundColor: Colors.white,
                      borderColor: _showCustomDates
                          ? primary.withOpacity(0.3)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(14.r),
                      child: Row(
                        children: [
                          Assets.icons.calendar.svg(
                            colorFilter: ColorFilter.mode(
                                primary, BlendMode.srcIn),
                            width: 20.w,
                            height: 20.h,
                          ),
                          10.kw,
                          Expanded(
                            child: 'Choose from calendar'
                                .s(14)
                                .w(500)
                                .c(const Color(0xFF64748B)),
                          ),
                          AnimatedRotation(
                            duration: const Duration(milliseconds: 200),
                            turns: _showCustomDates ? 0.5 : 0,
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: const Color(0xFF64748B),
                              size: 22.w,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // From/To date pickers
                  if (_showCustomDates) ...[
                    12.kh,
                    Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _DatePickerField(
                              label: 'From',
                              date: _fromDate,
                              hint: 'Start date',
                              onPick: () async {
                                final picked = await _pickDate(_fromDate);
                                if (picked != null) {
                                  setState(() => _fromDate = picked);
                                }
                              },
                            ),
                          ),
                          16.kw,
                          Expanded(
                            child: _DatePickerField(
                              label: 'To',
                              date: _toDate,
                              hint: 'End date',
                              onPick: () async {
                                final picked =
                                    await _pickDate(_toDate ?? _fromDate);
                                if (picked != null) {
                                  setState(() => _toDate = picked);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  28.kh,

                  // ─── Age & Gender Section ───
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Age input
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionLabel('Age'),
                            8.kh,
                            Container(
                              height: 52.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14.r),
                                border:
                                    Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _ageController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(2),
                                      ],
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                        color: textColor,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: '3',
                                        hintStyle: TextStyle(
                                          color: const Color(0xFFBDBDBD),
                                          fontSize: 15.sp,
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 14.w),
                                        border: InputBorder.none,
                                      ),
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: 14.w),
                                    child: 'years'
                                        .s(13)
                                        .w(500)
                                        .c(const Color(0xFF94A3B8)),
                                  ),
                                ],
                              ),
                            ),
                            if (_ageController.text.isNotEmpty &&
                                _parsedAge == null)
                              Padding(
                                padding: EdgeInsets.only(top: 4.h),
                                child: '1-16 only'
                                    .s(11)
                                    .w(500)
                                    .c(const Color(0xFFEF4444)),
                              ),
                          ],
                        ),
                      ),
                      14.kw,
                      // Gender selector
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionLabel('Gender'),
                            8.kh,
                            _GenderSelector(
                              value: _gender,
                              onChanged: (g) => setState(() => _gender = g),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  28.kh,

                  // ─── Price Range Section ───
                  _SectionLabel('Price Range'),
                  16.kh,

                  // Range slider
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      const fraction = (_maxPrice - _minPrice);
                      final startX =
                          (_range.start - _minPrice) / fraction;
                      final endX = (_range.end - _minPrice) / fraction;
                      return Column(
                        children: [
                          SizedBox(
                            height: 50,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  left: (width * startX - 16)
                                      .clamp(0, width - 40),
                                  top: 0,
                                  child:
                                      _PriceLabel(value: _range.start.toInt()),
                                ),
                                Positioned(
                                  left: (width * endX - 16)
                                      .clamp(40, width - 10),
                                  top: 0,
                                  child:
                                      _PriceLabel(value: _range.end.toInt()),
                                ),
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      rangeThumbShape:
                                          _RoundThumbShape(primary: primary),
                                      thumbColor: Colors.white,
                                      activeTrackColor: primary,
                                      inactiveTrackColor:
                                          primary.withOpacity(0.15),
                                      overlayColor:
                                          primary.withOpacity(0.15),
                                      trackHeight: 6,
                                      showValueIndicator:
                                          ShowValueIndicator.never,
                                    ),
                                    child: RangeSlider(
                                      min: _minPrice,
                                      max: _maxPrice,
                                      divisions: 100,
                                      values: _range,
                                      onChanged: (v) =>
                                          setState(() => _range = v),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          8.kh,
                          // Min / Max labels
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _PriceLabel(value: _range.start.toInt()),
                              _PriceLabel(value: _range.end.toInt()),
                            ],
                          ),
                        ],
                      );
                    },
                  ),

                  30.kh,
                ],
              ),
            ),
          ),

          // ─── Action Buttons ───
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 30.h),
            child: Row(
              children: [
                Expanded(
                  child: Container3d(
                    onTap: () {
                      _reset();
                      Navigator.of(context).pop();
                    },
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    depth: 3,
                    backgroundColor: Colors.white,
                    borderColor: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(14.r),
                    child: Center(
                      child: 'RESET'.s(14).w(700).c(textColor),
                    ),
                  ),
                ),
                14.kw,
                Expanded(
                  child: Container3d(
                    onTap: () =>
                        Navigator.of(context).pop(_buildResult()),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    depth: 4,
                    backgroundColor: primary,
                    borderColor: primary,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.34),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    child: Center(
                      child: 'APPLY'.s(14).w(700).c(Colors.white),
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

  Future<DateTime?> _pickDate(DateTime? initial) async {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      barrierColor: Colors.black54,
      initialDate: initial ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
  }
}

// ─── Section label ───

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return text.s(15).w(700).c(const Color(0xFF1E293B));
  }
}

// ─── Date preset chip ───

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    return Expanded(
      child: Container3d(
        onTap: onTap,
        padding: EdgeInsets.symmetric(vertical: 10.h),
        depth: selected ? 3 : 2,
        backgroundColor: selected ? primary : Colors.white,
        borderColor: selected ? primary : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(14.r),
        child: Center(
          child: text.s(13).w(600).c(selected ? Colors.white : const Color(0xFF475569)),
        ),
      ),
    );
  }
}

// ─── Date picker field ───

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.date,
    required this.hint,
    required this.onPick,
  });

  final String label;
  final DateTime? date;
  final String hint;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label.s(11).w(600).c(const Color(0xFF94A3B8)),
        6.kh,
        GestureDetector(
          onTap: onPick,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 16.w, color: context.colors.primary),
                8.kw,
                Expanded(
                  child: Text(
                    date != null ? _fmtDate(date!) : hint,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: date != null
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFBDBDBD),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}

// ─── Gender selector ───

class _GenderSelector extends StatelessWidget {
  const _GenderSelector({required this.value, required this.onChanged});
  final Gender value;
  final ValueChanged<Gender> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Gender>(
          isExpanded: true,
          value: value,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: const Color(0xFF64748B), size: 22.w),
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
          ),
          items: [
            _genderItem(Gender.any, 'Both', const Color(0xFF7C3AED)),
            _genderItem(Gender.boy, 'Boys', const Color(0xFF4F46E5)),
            _genderItem(Gender.girl, 'Girls', const Color(0xFFEC4899)),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }

  DropdownMenuItem<Gender> _genderItem(Gender g, String label, Color color) {
    return DropdownMenuItem(
      value: g,
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Price label ───

class _PriceLabel extends StatelessWidget {
  const _PriceLabel({required this.value});
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        '$value'.s(13).w(700).c(const Color(0xFFFBBF24)),
        3.kw,
        'so\'m'.s(12).w(600).c(const Color(0xFFFBBF24)),
      ],
    );
  }
}

// ─── Round thumb shape for range slider ───

class _RoundThumbShape extends RangeSliderThumbShape {
  final Color primary;
  const _RoundThumbShape({required this.primary});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size(28, 28);

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
    final Canvas canvas = context.canvas;
    const double radius = 14;

    // Shadow
    canvas.drawCircle(
      center + const Offset(0, 2),
      radius + 1,
      Paint()
        ..color = Colors.black.withOpacity(0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // White circle
    canvas.drawCircle(center, radius, Paint()..color = Colors.white);

    // Border
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = primary,
    );

    // Inner dot
    canvas.drawCircle(center, 4, Paint()..color = primary);
  }
}
