import 'package:flutter/material.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/widget/common_button.dart';

enum DatePreset { today, tomorrow, thisWeek, custom }

enum Gender { any, boy, girl }

enum PricePreset { any, custom }

class FilterResult {
  final DatePreset datePreset;
  final DateTime? customDate;
  final int? ageYears;
  final Gender gender;
  final PricePreset pricePreset;
  final RangeValues priceRange;

  const FilterResult({
    this.datePreset = DatePreset.tomorrow,
    this.customDate,
    this.ageYears,
    this.gender = Gender.any,
    this.pricePreset = PricePreset.any,
    this.priceRange = const RangeValues(10, 34),
  });

  FilterResult copyWith({
    DatePreset? datePreset,
    DateTime? customDate,
    int? ageYears,
    Gender? gender,
    PricePreset? pricePreset,
    RangeValues? priceRange,
  }) {
    return FilterResult(
      datePreset: datePreset ?? this.datePreset,
      customDate: customDate ?? this.customDate,
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
  DateTime? _customDate;
  int? _ageYears;
  Gender _gender = Gender.any;
  PricePreset _pricePreset = PricePreset.any;
  RangeValues _range = const RangeValues(10, 34);

  static const double _minPrice = 0;
  static const double _maxPrice = 100;

  @override
  void initState() {
    super.initState();
    final init = widget.initial ?? const FilterResult();
    _datePreset = init.datePreset;
    _customDate = init.customDate;
    _ageYears = init.ageYears;
    _gender = init.gender;
    _pricePreset = init.pricePreset;
    _range = init.priceRange;
  }

  void _reset() {
    setState(() {
      _datePreset = DatePreset.tomorrow;
      _customDate = null;
      _ageYears = null;
      _gender = Gender.any;
      _pricePreset = PricePreset.any;
      _range = const RangeValues(10, 34);
    });
  }

  FilterResult _buildResult() => FilterResult(
        datePreset: _datePreset,
        customDate: _customDate,
        ageYears: _ageYears,
        gender: _gender,
        pricePreset: _pricePreset,
        priceRange: _range,
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black87;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          10.kh,
          Container(
            width: 56,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          12.kh,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Assets.icons.arrowLeftIos.svg(),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                'Filter'.s(24).w(700).c(theme.textTheme.titleLarge?.color ?? textColor),
              ],
            ),
          ),
          46.kh,
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Segmented(
                    items: const ['Today', 'Tomorrow', 'This week'],
                    index: {
                      DatePreset.today: 0,
                      DatePreset.tomorrow: 1,
                      DatePreset.thisWeek: 2,
                      DatePreset.custom: 1,
                    }[_datePreset]!,
                    primary: primary,
                    onChanged: (i) {
                      setState(() {
                        _datePreset = [DatePreset.today, DatePreset.tomorrow, DatePreset.thisWeek][i];
                        if (_datePreset != DatePreset.custom) _customDate = null;
                      });
                    },
                  ),
                  12.kh,
                  _PillButton(
                    leading: Assets.icons.calendar.svg(
                      colorFilter: ColorFilter.mode(primary, BlendMode.srcIn),
                    ),
                    label: _customDate == null ? 'Choose from calendar' : 'Chosen: ${_fmtDate(_customDate!)}',
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF807A7A),
                    ),
                    onTap: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        barrierColor: Colors.black54,
                        initialDate: _customDate ?? now,
                        firstDate: DateTime(now.year - 1),
                        lastDate: DateTime(now.year + 2),
                      );
                      if (picked != null) {
                        setState(() {
                          _customDate = picked;
                          _datePreset = DatePreset.custom;
                        });
                      }
                    },
                  ),
                  20.kh,
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Label('Age', color: textColor),
                            8.kh,
                            _PillButton(
                              leading: Assets.icons.outlinedCalendar.svg(),
                              label: _ageYears == null ? 'Any age' : '${_ageYears!} years',
                              onTap: () async {
                                final v = await _pickAge(context, _ageYears);
                                if (v != null) setState(() => _ageYears = v);
                              },
                            ),
                          ],
                        ),
                      ),
                      14.kw,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Label('Gender', color: textColor),
                            8.kh,
                            _PillButton(
                              leading: Assets.icons.outlinedPerson.svg(),
                              label: {
                                Gender.any: 'Any',
                                Gender.boy: 'boy',
                                Gender.girl: 'girl',
                              }[_gender]!,
                              onTap: () async {
                                final v = await _pickGender(context, _gender);
                                if (v != null) setState(() => _gender = v);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  20.kh,
                  _Label('Price Range', color: textColor),
                  8.kh,
                  _PillDropdown<PricePreset>(
                    value: _pricePreset,
                    items: [
                      DropdownMenuItem(value: PricePreset.any, child: 'Any price'.w(600)),
                      DropdownMenuItem(value: PricePreset.custom, child: 'Custom'.w(600)),
                    ],
                    onChanged: (v) => setState(() => _pricePreset = v ?? PricePreset.any),
                  ),
                  if (_pricePreset == PricePreset.custom) ...[
                    33.kh,
                    _Label('Select price', color: textColor),
                    46.kh,
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        const fraction = (_maxPrice - _minPrice);
                        final startX = (_range.start - _minPrice) / fraction;
                        final endX = (_range.end - _minPrice) / fraction;
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Value labels above thumbs
                            Positioned(
                              left: width * startX - 12,
                              top: -30,
                              child: _PriceLabel(value: _range.start),
                            ),
                            Positioned(
                              left: width * endX - 12,
                              top: -30,
                              child: _PriceLabel(value: _range.end),
                            ),
                            SliderTheme(
                              data: theme.sliderTheme.copyWith(
                                rangeThumbShape: _RectChevronThumbShape(primary: primary),
                                thumbColor: Colors.white,
                                activeTrackColor: primary,
                                inactiveTrackColor: primary.withValues(alpha: 0.2),
                                overlayColor: primary.withValues(alpha: 0.2),
                                trackHeight: 6,
                                showValueIndicator: ShowValueIndicator.never,
                              ),
                              child: RangeSlider(
                                min: _minPrice,
                                max: _maxPrice,
                                values: _range,
                                onChanged: (v) => setState(() => _range = v),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(bottom: 30),
            child: Row(
              children: [
                Expanded(
                  child: CommonButton.outlined(
                    text: "RESET",
                    onPressed: _reset,
                    textColor: context.colors.black,
                  ),
                  // _GhostButton(
                  //   text: 'RESET',
                  //   onTap: _reset,
                  // ),
                ),
                14.kw,
                Expanded(
                  child: CommonButton.elevated(
                    text: "APPLY",
                    onPressed: () => Navigator.of(context).pop(_buildResult()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // Legacy helper no longer used

  Future<int?> _pickAge(BuildContext ctx, int? current) async {
    int temp = current ?? 7;
    return showDialog<int>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Select age'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$temp years', style: const TextStyle(fontWeight: FontWeight.w600)),
              Slider(
                min: 1,
                max: 18,
                divisions: 17,
                value: temp.toDouble(),
                thumbColor: context.colors.primary,
                overlayColor: WidgetStateProperty.all(context.colors.primary.withValues(alpha: 0.2)),
                inactiveColor: context.colors.primary.withValues(alpha: 0.2),
                activeColor: context.colors.primary,
                onChanged: (v) => setState(() => temp = v.toInt()),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CommonButton.elevated(text: "Select", onPressed: () => Navigator.pop(ctx, temp)),
          ),
        ],
      ),
    );
  }

  Future<Gender?> _pickGender(BuildContext ctx, Gender current) async {
    Gender temp = current;
    return showDialog<Gender>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Select gender'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: Gender.values
                .map((g) => RadioListTile<Gender>(
                      activeColor: context.colors.primary,
                      value: g,
                      groupValue: temp,
                      onChanged: (v) => setState(() => temp = v ?? temp),
                      title: Text({Gender.any: 'Any', Gender.boy: 'boy', Gender.girl: 'girl'}[g]!),
                    ))
                .toList(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CommonButton.elevated(text: "Select", onPressed: () => Navigator.pop(ctx, temp)),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final Color color;
  const _Label(this.text, {required this.color});

  @override
  Widget build(BuildContext context) {
    return text.w(700).c(color);
  }
}

class _Segmented extends StatelessWidget {
  final List<String> items;
  final int index;
  final ValueChanged<int> onChanged;
  final Color primary;

  const _Segmented({
    required this.items,
    required this.index,
    required this.onChanged,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: List.generate(items.length, (i) {
        final selected = i == index;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == items.length - 1 ? 0 : 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              height: 44,
              decoration: BoxDecoration(
                color: selected ? primary : theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: selected ? primary : theme.dividerColor),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onChanged(i),
                child: Center(
                  child:
                      items[i].w(600).c(selected ? Colors.white : (theme.textTheme.bodyLarge?.color ?? Colors.black87)),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _PillButton extends StatelessWidget {
  final Widget? leading;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _PillButton({
    this.leading,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                10.kw,
              ],
              Expanded(
                child: label.s(15).w(400).c(
                      const Color(0xFF807A7A),
                    ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class _PillDropdown<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _PillDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).cardColor,
              border: Border.all(
                width: 3,
                color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
              ),
            ),
            child: Assets.icons.dollarRounded.svg(),
          ),
          10.kw,
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                isExpanded: true,
                value: value,
                items: items,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Unused legacy button classes removed.

class _RectChevronThumbShape extends RangeSliderThumbShape {
  final double thumbSize = 36;
  final Color primary;
  const _RectChevronThumbShape({required this.primary});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size(thumbSize, thumbSize);

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

    final RRect rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: thumbSize, height: thumbSize),
      const Radius.circular(10),
    );

    // Thumb body
    final Paint thumbPaint = Paint()..color = Colors.white;
    canvas.drawRRect(rect, thumbPaint);

    // Border
    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = primary.withValues(alpha: 0.12);
    canvas.drawRRect(rect, borderPaint);

    // Inner chevrons
    const double iconSize = 10;
    final Path left = Path();
    final Path right = Path();
    const double gap = 4;

    final Offset leftCenter = center.translate(-gap, 0);
    final Offset rightCenter = center.translate(gap, 0);

    // Draw small triangles to suggest chevrons
    left.moveTo(leftCenter.dx + iconSize / 2, leftCenter.dy - iconSize / 2);
    left.lineTo(leftCenter.dx - iconSize / 2, leftCenter.dy);
    left.lineTo(leftCenter.dx + iconSize / 2, leftCenter.dy + iconSize / 2);
    left.close();

    right.moveTo(rightCenter.dx - iconSize / 2, rightCenter.dy - iconSize / 2);
    right.lineTo(rightCenter.dx + iconSize / 2, rightCenter.dy);
    right.lineTo(rightCenter.dx - iconSize / 2, rightCenter.dy + iconSize / 2);
    right.close();

    final Paint chevronPaint = Paint()..color = primary;
    canvas.drawPath(left, chevronPaint);
    canvas.drawPath(right, chevronPaint);
  }
}

class _PriceLabel extends StatelessWidget {
  final double value;
  const _PriceLabel({required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        value.toInt().toString().w(700).c(const Color(0xFFFF9F0A)),
        4.kw,
        Assets.icons.dollar.svg(),
      ],
    );
  }
}
