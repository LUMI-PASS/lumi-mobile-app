import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomMultiChiplistWidget extends StatefulWidget {
  final List<String> items;
  final List<int>? initialSelectedIndices;
  final ValueChanged<List<int>> onSelectionChanged;
  final EdgeInsets? padding;
  final double spacing;
  final TextStyle? selectedTextStyle;
  final TextStyle? unselectedTextStyle;
  final BoxDecoration? selectedDecoration;
  final BoxDecoration? unselectedDecoration;
  final int? maxSelections;
  final bool allowDeselection;

  const CustomMultiChiplistWidget({
    super.key,
    required this.items,
    required this.onSelectionChanged,
    this.initialSelectedIndices,
    this.padding,
    this.spacing = 8,
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.selectedDecoration,
    this.unselectedDecoration,
    this.maxSelections,
    this.allowDeselection = true,
  });

  @override
  State<CustomMultiChiplistWidget> createState() => _CustomMultiChiplistWidgetState();
}

class _CustomMultiChiplistWidgetState extends State<CustomMultiChiplistWidget> {
  late Set<int> _selectedIndices;

  @override
  void initState() {
    super.initState();
    _selectedIndices = widget.initialSelectedIndices?.toSet() ?? <int>{};
  }

  void _onChipTapped(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        // Item is currently selected
        if (widget.allowDeselection) {
          _selectedIndices.remove(index);
        }
      } else {
        // Item is not selected
        if (widget.maxSelections == null || _selectedIndices.length < widget.maxSelections!) {
          _selectedIndices.add(index);
        } else if (widget.maxSelections == 1) {
          // If max selection is 1, replace the current selection
          _selectedIndices.clear();
          _selectedIndices.add(index);
        }
        // If maxSelections is reached and > 1, do nothing (could optionally remove oldest selection)
      }
    });

    widget.onSelectionChanged(_selectedIndices.toList()..sort());
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1.sw,
      child: Wrap(
        spacing: widget.spacing,
        runSpacing: widget.spacing,
        children: List.generate(widget.items.length, (index) {
          final bool isSelected = _selectedIndices.contains(index);
          final String item = widget.items[index];

          return GestureDetector(
            onTap: () => _onChipTapped(index),
            child: Container(
              padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: isSelected
                  ? (widget.selectedDecoration ??
                  BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: context.colors.black),
                    borderRadius: BorderRadius.circular(24),
                  ))
                  : (widget.unselectedDecoration ??
                  BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(24),
                  )),
              child: Text(
                item,
                style: isSelected
                    ? (widget.selectedTextStyle ?? const TextStyle(color: Colors.white))
                    : (widget.unselectedTextStyle ?? TextStyle(color: Colors.grey.shade700)),
              ),
            ),
          );
        }),
      ),
    );
  }
}