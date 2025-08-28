import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BasicChipList extends StatefulWidget {
  final List<String> items;
  final int initialSelectedIndex;
  final ValueChanged<int> onSelected;
  final EdgeInsets? padding;
  final double spacing;
  final TextStyle? selectedTextStyle;
  final TextStyle? unselectedTextStyle;
  final BoxDecoration? selectedDecoration;
  final BoxDecoration? unselectedDecoration;

  const BasicChipList({
    Key? key,
    required this.items,
    required this.initialSelectedIndex,
    required this.onSelected,
    this.padding,
    this.spacing = 8,
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.selectedDecoration,
    this.unselectedDecoration,
  }) : super(key: key);

  @override
  State<BasicChipList> createState() => _BasicChipListState();
}

class _BasicChipListState extends State<BasicChipList> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialSelectedIndex;
  }

  @override
  void didUpdateWidget(BasicChipList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSelectedIndex != oldWidget.initialSelectedIndex) {
      setState(() {
        _selectedIndex = widget.initialSelectedIndex;
      });
    }
  }

  void _onChipTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1.sw,
      child: Wrap(
        spacing: widget.spacing,
        runSpacing: widget.spacing,
        children: List.generate(widget.items.length, (index) {
          final bool isSelected = index == _selectedIndex;
          final String item = widget.items[index];

          return GestureDetector(
            onTap: () => _onChipTapped(index),
            child: Container(
              padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: isSelected
                  ? (widget.selectedDecoration ??
                  BoxDecoration(
                    color: Colors.black,
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