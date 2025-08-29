import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomSegmentedControl extends StatefulWidget {
  final List<String> segments;
  final Function(int) onSegmentTapped;

  const CustomSegmentedControl({
    super.key,
    required this.segments,
    required this.onSegmentTapped,
  });

  @override
  State<CustomSegmentedControl> createState() => _CustomSegmentedControlState();
}

class _CustomSegmentedControlState extends State<CustomSegmentedControl> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48.h,
      decoration: BoxDecoration(
        color: const Color(0xFFE6ECF0),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            left: selectedIndex *
                (MediaQuery.of(context).size.width - 32.w) /
                widget.segments.length,
            top: 4.h,
            bottom: 4.h,
            width: (MediaQuery.of(context).size.width - 32.w) /
                widget.segments.length,
            child: Container(
              margin: EdgeInsets.only(
                  left: selectedIndex == 0 ? 4.w : 0.w,
                  right: selectedIndex == 1 ? 4.w : 0.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 3,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: List.generate(
              widget.segments.length,
              (index) => Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                    widget.onSegmentTapped(selectedIndex);
                  },
                  child: Container(
                      height: double.infinity,
                      alignment: Alignment.center,
                      child: widget.segments[index]
                          .c(selectedIndex == index
                              ? context.colors.black
                              : const Color(0xFF8E99A1))
                          .w(selectedIndex == index ? 600 : 500)
                          .s(14)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
