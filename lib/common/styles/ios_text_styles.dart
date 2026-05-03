import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// iOS-style typography. One family, one rhythm — only weight, size and
/// color change. Use these everywhere in the activity / branch detail
/// screens so the layout reads like a native iOS list.
class IOSText {
  IOSText._();

  // Keep the app's existing font (Onest); only weight/size/spacing vary so
  // the layout reads with iOS rhythm but uses the typeface already shipped.
  static const String _family = 'Onest';
  static const String _displayFamily = 'Onest';

  static const Color primary = Color(0xFF0E0C2B);
  static const Color secondary = Color(0xFF6B6E80);
  static const Color tertiary = Color(0xFF9A9DAE);
  static const Color separator = Color(0xFFE5E5EA);
  static const Color tint = Color(0xFF6C4EF2);
  static const Color groupedBg = Color(0xFFF2F2F7);

  static TextStyle largeTitle({Color? color}) => TextStyle(
        fontFamily: _displayFamily,
        fontFamilyFallback: const ['Inter', 'Roboto'],
        fontSize: 28.sp,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.4,
        color: color ?? primary,
      );

  static TextStyle title({Color? color}) => TextStyle(
        fontFamily: _displayFamily,
        fontFamilyFallback: const ['Inter', 'Roboto'],
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: -0.2,
        color: color ?? primary,
      );

  static TextStyle headline({Color? color}) => TextStyle(
        fontFamily: _family,
        fontFamilyFallback: const ['Inter', 'Roboto'],
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.1,
        color: color ?? primary,
      );

  static TextStyle body({Color? color}) => TextStyle(
        fontFamily: _family,
        fontFamilyFallback: const ['Inter', 'Roboto'],
        fontSize: 15.sp,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: color ?? primary,
      );

  static TextStyle bodyEmphasized({Color? color}) =>
      body(color: color).copyWith(fontWeight: FontWeight.w600);

  static TextStyle subhead({Color? color}) => TextStyle(
        fontFamily: _family,
        fontFamilyFallback: const ['Inter', 'Roboto'],
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        height: 1.35,
        color: color ?? secondary,
      );

  static TextStyle footnote({Color? color}) => TextStyle(
        fontFamily: _family,
        fontFamilyFallback: const ['Inter', 'Roboto'],
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
        height: 1.3,
        color: color ?? secondary,
      );

  static TextStyle caption({Color? color}) => TextStyle(
        fontFamily: _family,
        fontFamilyFallback: const ['Inter', 'Roboto'],
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        height: 1.25,
        color: color ?? tertiary,
      );

  static TextStyle sectionHeader({Color? color}) => caption(color: color).copyWith(
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.1,
        color: color ?? secondary,
      );
}

/// Reusable iOS-style "card" container — light grouped background,
/// rounded corners, subtle separator. Use to wrap detail sections so
/// every block reads with the same rhythm.
class IOSSection extends StatelessWidget {
  const IOSSection({
    super.key,
    this.title,
    required this.child,
    this.padding,
  });

  final String? title;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(4.w, 4.h, 4.w, 8.h),
              child: Text(
                title!.toUpperCase(),
                style: IOSText.sectionHeader(),
              ),
            ),
          ],
          Container(
            width: double.infinity,
            padding: padding ?? EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: IOSText.separator, width: 0.5),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

class IOSRow extends StatelessWidget {
  const IOSRow({
    super.key,
    required this.label,
    required this.value,
    this.valueStyle,
    this.icon,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18.sp, color: IOSText.secondary),
            SizedBox(width: 10.w),
          ],
          Expanded(
            child: Text(label, style: IOSText.body(color: IOSText.secondary)),
          ),
          SizedBox(width: 12.w),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: valueStyle ?? IOSText.body(),
            ),
          ),
        ],
      ),
    );
  }
}
