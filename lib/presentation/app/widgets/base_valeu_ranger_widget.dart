import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class BaseSliderWidget extends StatefulWidget {
  final double minValue;
  final double maxValue;
  final double initialStartValue;
  final double initialEndValue;
  final String? prefix;
  final String? suffix;
  final Color activeTrackColor;
  final Color inactiveTrackColor;
  final Color thumbColor;
  final Color labelTextColor;
  final Color valueTextColor;
  final String title;
  final TextStyle? titleStyle;
  final ValueChanged<RangeValues>? onChanged;
  final int? divisions;
  final double? stepSize;

  const BaseSliderWidget({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.initialStartValue,
    required this.initialEndValue,
    this.prefix,
    this.suffix,
    this.activeTrackColor = const Color(0xFF0C1A2B),
    this.inactiveTrackColor = const Color(0xFFE6E6E6),
    this.thumbColor = Colors.white,
    this.labelTextColor = Colors.black,
    this.valueTextColor = Colors.black,
    this.title = 'Price Range',
    this.titleStyle,
    this.onChanged,
    this.divisions,
    this.stepSize,
  })  : assert(minValue < maxValue),
        assert(initialStartValue >= minValue && initialStartValue <= maxValue),
        assert(initialEndValue >= minValue && initialEndValue <= maxValue),
        assert(initialStartValue <= initialEndValue);

  @override
  State<BaseSliderWidget> createState() => _BaseSliderWidgetState();
}

class _BaseSliderWidgetState extends State<BaseSliderWidget> {
  late RangeValues _currentRangeValues;

  @override
  void initState() {
    super.initState();
    _currentRangeValues = RangeValues(
      widget.initialStartValue,
      widget.initialEndValue,
    );
  }

  @override
  void didUpdateWidget(covariant BaseSliderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialStartValue != widget.initialStartValue ||
        oldWidget.initialEndValue != widget.initialEndValue) {
      _currentRangeValues = RangeValues(
        widget.initialStartValue,
        widget.initialEndValue,
      );
    }
  }

  int? _getDivisions() {
    if (widget.divisions != null) return widget.divisions;
    if (widget.stepSize != null) {
      final steps = (widget.maxValue - widget.minValue) / widget.stepSize!;
      return steps.floor();
    }
    return null; // No divisions by default
  }

  String _formatValue(double value) {
    final isWhole = value == value.roundToDouble();
    final formatted = isWhole
        ? NumberFormat('#,##0', 'en_US').format(value).replaceAll(',', ' ')
        : NumberFormat('#,##0', 'en_US').format(value).replaceAll(',', ' ');
    return '${widget.prefix ?? ''}$formatted${widget.suffix ?? ''}';
  }


  @override
  Widget build(BuildContext context) {
    final divisions = _getDivisions();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            rangeThumbShape: const RoundRangeSliderThumbShape(
              enabledThumbRadius: 12,
              elevation: 4,
            ),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
            rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
            activeTrackColor: widget.activeTrackColor,
            inactiveTrackColor: widget.inactiveTrackColor,
            thumbColor: widget.thumbColor,
            overlayColor: widget.thumbColor.withOpacity(0.2),
            rangeValueIndicatorShape: const PaddleRangeSliderValueIndicatorShape(),
            valueIndicatorColor: widget.activeTrackColor,
            valueIndicatorTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
            showValueIndicator: ShowValueIndicator.always,
            trackHeight: 8.h,
          ),
          child: RangeSlider(
            values: _currentRangeValues,
            min: widget.minValue,
            max: widget.maxValue,
            divisions: divisions,
            labels: RangeLabels(
              _formatValue(_currentRangeValues.start),
              _formatValue(_currentRangeValues.end),
            ),
            onChanged: (values) {
              setState(() {
                _currentRangeValues = values;
              });
              widget.onChanged?.call(_currentRangeValues);
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatValue(_currentRangeValues.start),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: widget.valueTextColor,
              ),
            ),
            Text(
              _formatValue(_currentRangeValues.end),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: widget.valueTextColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
