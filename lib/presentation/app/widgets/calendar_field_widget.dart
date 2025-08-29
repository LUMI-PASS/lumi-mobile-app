import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:lumi_pass/common/widget/common_text_filed.dart';
import 'package:flutter/material.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

enum CalendarFieldType { single, range }

class CalendarFieldWidget extends StatefulWidget {
  final CalendarFieldType type;
  final List<DateTime?> initialDates;
  final Function(List<DateTime?>) onDatesSelected;
  final String? placeholder;
  final Color? primaryColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final Color? hintColor;
  final Widget? prefixIcon;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final EdgeInsetsGeometry? padding;
  final Size? dialogSize;
  final bool enabled;
  final String Function(List<DateTime?>)? dateFormatter;
  final FormFieldValidator? validator;

  const CalendarFieldWidget({
    super.key,
    required this.type,
    required this.onDatesSelected,
    this.initialDates = const [],
    this.placeholder,
    this.primaryColor,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.hintColor,
    this.prefixIcon,
    this.textStyle,
    this.hintStyle,
    this.padding,
    this.dialogSize,
    this.enabled = true,
    this.validator,
    this.dateFormatter,
  });

  @override
  State<CalendarFieldWidget> createState() => _CalendarFieldWidgetState();
}

class _CalendarFieldWidgetState extends State<CalendarFieldWidget> {
  List<DateTime?> _selectedDates = [];

  @override
  void initState() {
    super.initState();
    _selectedDates = List.from(widget.initialDates);
  }

  @override
  void didUpdateWidget(CalendarFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialDates != widget.initialDates) {
      _selectedDates = List.from(widget.initialDates);
    }
  }

  String _formatDates() {
    if (widget.dateFormatter != null) {
      return widget.dateFormatter!(_selectedDates);
    }

    if (_selectedDates.isEmpty || _selectedDates.first == null) {
      return '';
    }

    if (widget.type == CalendarFieldType.single) {
      return _formatDate(_selectedDates.first!);
    } else {
      // Range type
      if (_selectedDates.length == 1 || _selectedDates[1] == null) {
        return _formatDate(_selectedDates.first!);
      } else {
        return '${_formatDate(_selectedDates.first!)} - ${_formatDate(_selectedDates[1]!)}';
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Future<void> _showCalendarPicker() async {
    if (!widget.enabled) return;

    final results = await showCalendarDatePicker2Dialog(
      context: context,
      dialogSize: widget.dialogSize ?? const Size(350, 420),
      value: _selectedDates,
      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: widget.type == CalendarFieldType.range
            ? CalendarDatePicker2Type.range
            : CalendarDatePicker2Type.single,
        selectedDayHighlightColor: context.colors.display,
        weekdayLabelTextStyle: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
        controlsTextStyle: TextStyle(
          color: context.colors.display,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),

        selectedDayTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        dayTextStyle: const TextStyle(fontSize: 14),
        centerAlignModePicker: true,
        firstDayOfWeek: 1,
        firstDate: DateTime.now(),
      ),
    );

    if (results != null) {
      setState(() {
        _selectedDates = results;
      });
      widget.onDatesSelected(results);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayText = _formatDates();

    return InkWell(
      onTap: _showCalendarPicker,
      child: CommonTextField(
        validator: (value) {
          if (_selectedDates.isEmpty) {
            return Strings.fieldError;
          }
          return null;
        },
        prefixIcon: widget.prefixIcon ?? Assets.icons.calendar.svg(),
        hint: displayText.isNotEmpty
            ? displayText
            : widget.placeholder ?? "Когда",
        enabled: false,
        hintColor: displayText.isEmpty
            ? const Color(0xFF717680)
            : context.colors.primary,
      ),
    );
  }
}
