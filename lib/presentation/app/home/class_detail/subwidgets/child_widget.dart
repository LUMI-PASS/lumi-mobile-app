import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';

class ChildWidget extends StatefulWidget {
  const ChildWidget({super.key, required this.isSelected, required this.onTap});

  final bool isSelected;
  final Function onTap;

  @override
  State<ChildWidget> createState() => _ChildWidgetState();
}

class _ChildWidgetState extends State<ChildWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => widget.onTap(),
      child: Container(
        width: 1.sw,
        margin: EdgeInsets.symmetric( vertical: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            color: widget.isSelected
                ? context.colors.primary
                : context.colors.onPrimary,
            border: Border.all(
                color: widget.isSelected
                    ? context.colors.grey
                    : context.colors.primary)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            "Samandra Watkins".s(16).w(700).c(widget.isSelected
                ? context.colors.onPrimary
                : context.colors.black),
            12.kh,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFF94C7).withOpacity(0.3),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: "3 years".s(12).w(700).c(widget.isSelected
                  ? context.colors.onPrimary
                  : context.colors.black),
            )
          ],
        ),
      ),
    );
  }
}
