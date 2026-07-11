import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';

/// A pill filter chip — selected shows the brand blue→purple gradient, otherwise
/// a muted surface fill (Figma 96-3204). Used by the Bookings tab and
/// Profile → My Bookings.
class PillFilterChip extends StatelessWidget {
  const PillFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          gradient: selected ? AppGradients.indigo : null,
          color: selected ? null : c.surface,
          borderRadius: BorderRadius.circular(40.r),
        ),
        child: Text(
          label,
          style: AppText.semibold12.copyWith(
            color: selected ? Colors.white : c.textSecondary,
          ),
        ),
      ),
    );
  }
}
