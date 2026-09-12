import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';

/// What the user picked in [CategoryPickerSheet].
///
/// A wrapper rather than a bare `HomCategory?`, because "all categories" and
/// "dismissed the sheet" are different answers and both would otherwise be
/// `null`: the sheet returns `null` on dismissal and a result carrying a `null`
/// [category] when the filter was cleared.
class CategoryPickerResult {
  const CategoryPickerResult(this.category);

  /// Null = no category filter ("all categories").
  final HomCategory? category;
}

/// The categories list as a bottom sheet — what the map screen's "category"
/// dropdown opens.
///
/// Single-select with an explicit "all categories" row at the top, so clearing
/// the filter is a choice in the list rather than a second tap on the active
/// chip (which is how the old bottom chip strip cleared, and was invisible).
class CategoryPickerSheet extends StatelessWidget {
  const CategoryPickerSheet({
    super.key,
    required this.categories,
    this.selected,
  });

  final List<HomCategory> categories;
  final HomCategory? selected;

  static Future<CategoryPickerResult?> show(
    BuildContext context, {
    required List<HomCategory> categories,
    HomCategory? selected,
  }) {
    return showModalBottomSheet<CategoryPickerResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.colors.surface,
      barrierColor: AppColors.ink.withValues(alpha: 0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => CategoryPickerSheet(
        categories: categories,
        selected: selected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          12.kh,
          Container(
            width: 32.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: c.textSecondary.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          12.kh,
          Text(
            'pick_category'.tr(),
            style: AppText.heading20.copyWith(color: c.textPrimary),
          ),
          12.kh,
          Flexible(
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(
                14.w,
                0,
                14.w,
                16.h + MediaQuery.of(context).padding.bottom,
              ),
              physics: const BouncingScrollPhysics(),
              itemCount: categories.length + 1,
              separatorBuilder: (_, __) => 8.kh,
              itemBuilder: (context, i) {
                // Row 0 is "all categories" — the cleared filter.
                final category = i == 0 ? null : categories[i - 1];
                return _CategoryRow(
                  label: category == null
                      ? 'all_categories'.tr()
                      : category.title ?? '',
                  selected: category == null
                      ? selected == null
                      : category.id == selected?.id,
                  onTap: () => Navigator.of(context)
                      .pop(CategoryPickerResult(category)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
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
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          gradient: selected ? AppGradients.indigo : null,
          color: selected ? null : c.control,
          borderRadius: BorderRadius.circular(16.r),
          border: selected ? null : Border.all(color: c.controlBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.medium14.copyWith(
                  color: selected ? Colors.white : c.textPrimary,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_rounded, size: 20.sp, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
