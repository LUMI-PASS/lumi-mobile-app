import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BaseBox extends StatelessWidget {
  const BaseBox(
      {super.key,
      required this.child,
      this.width,
      this.height,
      this.selected = false,
      this.margin,
      this.padding,
      this.onTap,
      this.backgroundColor,
      this.radius,
      this.shadow});

  final Widget child;
  final double? width;
  final double? height;
  final bool selected;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? radius;
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      child: Container(
        height: height,
        width: width,
        padding: padding ??  EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        margin: margin,
        decoration: BoxDecoration(
            color: backgroundColor ?? context.colors.onPrimary,
            borderRadius: BorderRadius.circular((radius ?? 16).r),
            border: selected ? Border.all(color: context.colors.primary) : null,
            boxShadow: shadow),
        child: child,
      ),
    );
  }
}
