import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomFilterListWidget extends StatefulWidget {
  final List<FilterItem> filterItems;
  final double height;
  final double spacing;
  final Color selectedBackgroundColor;
  final Color unselectedBackgroundColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Function(int)? onFilterSelected;
  final int initialSelectedIndex;

  const CustomFilterListWidget({
    super.key,
    required this.filterItems,
    this.height = 48.0,
    this.spacing = 8.0,
    this.selectedBackgroundColor = const Color(0xFF0A192F),
    this.unselectedBackgroundColor = const Color(0xFFF0F0F0),
    this.selectedTextColor = Colors.white,
    this.unselectedTextColor = Colors.black54,
    this.borderRadius,
    this.padding,
    this.onFilterSelected,
    this.initialSelectedIndex = 0,
  });

  @override
  State<CustomFilterListWidget> createState() => _CustomFilterListWidgetState();
}

class _CustomFilterListWidgetState extends State<CustomFilterListWidget> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialSelectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.filterItems.length,
        separatorBuilder: (context, index) => SizedBox(width: widget.spacing),
        itemBuilder: (context, index) {
          final item = widget.filterItems[index];
          final isSelected = _selectedIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
              widget.onFilterSelected?.call(index);
            },
            child: Container(
              padding: widget.padding ?? EdgeInsets.symmetric(vertical: 4.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? widget.selectedBackgroundColor
                    : widget.unselectedBackgroundColor,
                borderRadius: BorderRadius.circular(widget.borderRadius ?? 44.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.unselectedIcon != null && item.selectedIcon != null) ...[
                   _selectedIndex==index ? item.selectedIcon! : item.unselectedIcon!,
                    6.kw,
                  ],
                  item.label.s(14).w(_selectedIndex==index ? 600 : 400).c(_selectedIndex==index ? context.colors.onPrimary : context.colors.textSecondary),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class FilterItem {
  final String label;
  final Widget? unselectedIcon;
  final Widget? selectedIcon;
  final dynamic value;

  FilterItem({
    required this.label,
    this.selectedIcon,
    this.unselectedIcon,
    this.value,
  });
}
