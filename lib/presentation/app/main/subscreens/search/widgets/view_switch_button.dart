import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';

/// The pill that swaps one view of a search for the other: "Списком" on the
/// map, "Карта" on the list. One widget, so the two read as the same switch
/// seen from either side, as 1fit's do.
class ViewSwitchButton extends StatelessWidget {
  const ViewSwitchButton.list({super.key, required this.onTap})
      : _icon = Icons.format_list_bulleted_rounded,
        _labelKey = 'map_list';

  const ViewSwitchButton.map({super.key, required this.onTap})
      : _icon = Icons.map_outlined,
        _labelKey = 'map_view';

  final VoidCallback onTap;
  final IconData _icon;
  final String _labelKey;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: AppGradients.brand,
          borderRadius: BorderRadius.circular(48.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, size: 16.sp, color: AppColors.onBrand),
            4.horizontalSpace,
            Text(
              _labelKey.tr(),
              style: AppText.semibold12.copyWith(color: AppColors.onBrand),
            ),
          ],
        ),
      ),
    );
  }
}
