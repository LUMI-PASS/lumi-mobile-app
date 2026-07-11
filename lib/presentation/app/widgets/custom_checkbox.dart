import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:flutter/material.dart';

class CustomCheckbox extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool>? onChanged;
  final Color activeColor;
  final Color checkColor;
  final Color borderColor;
  final double borderWidth;
  final double size;
  final double borderRadius;
  final Widget? label;
  final EdgeInsetsGeometry padding;
  final bool disabled;
  final Color disabledColor;
  final Color hoverColor;
  final MainAxisAlignment alignment;
  final MainAxisSize mainAxisSize;

  const CustomCheckbox({
    Key? key,
    required this.initialValue,
    this.onChanged,
    this.activeColor = AppColors.error,
    this.checkColor = Colors.white,
    this.borderColor = AppColors.lightTextSecondary,
    this.borderWidth = 1.0,
    this.size = 16.0,
    this.borderRadius = 4.0,
    this.label,
    this.padding = const EdgeInsets.symmetric(vertical: 4.0),
    this.disabled = false,
    this.disabledColor =  const Color(0xFFCAD9E2),
    this.hoverColor = Colors.blue,
    this.alignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.min,
  }) : super(key: key);

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  late bool _isChecked;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.initialValue;
  }

  void _toggleCheckbox() {
    if (widget.disabled) return;
    setState(() {
      _isChecked = !_isChecked;
    });
    widget.onChanged?.call(_isChecked);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: _toggleCheckbox,
      child: Padding(
        padding: widget.padding,
        child: Row(
          mainAxisSize: widget.mainAxisSize,
          mainAxisAlignment: widget.alignment,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.disabled
                    ? widget.disabledColor.withOpacity(0.3)
                    : _isChecked
                    ? widget.activeColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: widget.disabled
                      ? widget.disabledColor
                      : _isChecked
                      ? widget.activeColor
                      : widget.borderColor,
                  width: widget.borderWidth,
                ),
              ),
              child: _isChecked
                  ? Center(
                child: Icon(
                  Icons.check,
                  size: widget.size * 0.75,
                  color: widget.checkColor,
                ),
              )
                  : null,
            ),
            if (widget.label != null)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: widget.label,
              ),
          ],
        ),
      ),
    );
  }
}
