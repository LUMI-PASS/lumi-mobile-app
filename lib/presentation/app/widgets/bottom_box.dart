import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BottomBox extends StatelessWidget {
  const BottomBox({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.margin,
    this.padding,
  });

  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: width,
        height: height,
        padding: padding ??
             EdgeInsets.only(
              top: 16.h,
              right: 16.w,
              left: 16.w,
              bottom: 24.h,
            ),
        margin: margin,
        // `bottomBar`, not `onPrimary` — the latter is a fixed white, which left
        // the bar glowing white on a dark page.
        decoration: BoxDecoration(color: context.colors.bottomBar),
        child: child,
      ),
    );
  }
}
