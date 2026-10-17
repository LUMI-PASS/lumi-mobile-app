import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/image_url.dart';
import 'package:lumi_pass/common/widget/bouncing_button.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';

/// What the user picked in [CategoryPickerSheet].
///
/// A wrapper rather than a bare `List<HomCategory>`, because "cleared to all
/// categories" and "dismissed the sheet" are different answers and both would
/// otherwise be an empty list: the sheet returns `null` on dismissal and a
/// result carrying an empty [categories] when the filter was cleared.
class CategoryPickerResult {
  const CategoryPickerResult(this.categories);

  /// Empty = no category filter ("all categories").
  final List<HomCategory> categories;
}

/// The categories list as a bottom sheet — what the map screen's "category"
/// dropdown opens.
///
/// Multi-select. There is no "all categories" row: nothing ticked already
/// means every category, so the row would only repeat it. Each row toggles on
/// its own — like the
/// district chips in [FilterBottomSheet] — and the picks only take effect on
/// Apply, so a parent can tick several before the sheet narrows anything.
class CategoryPickerSheet extends StatefulWidget {
  const CategoryPickerSheet({
    super.key,
    required this.categories,
    this.selected = const [],
  });

  final List<HomCategory> categories;
  final List<HomCategory> selected;

  static Future<CategoryPickerResult?> show(
    BuildContext context, {
    required List<HomCategory> categories,
    List<HomCategory> selected = const [],
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
  State<CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<CategoryPickerSheet> {
  late final Set<String> _selectedIds = {
    for (final c in widget.selected)
      if (c.id != null) c.id!,
  };

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
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 16.h),
              physics: const BouncingScrollPhysics(),
              itemCount: widget.categories.length,
              separatorBuilder: (_, __) => 8.kh,
              itemBuilder: (context, i) {
                final category = widget.categories[i];
                final id = category.id;
                return _CategoryRow(
                  label: category.title ?? '',
                  icon: _artwork(category),
                  selected: id != null && _selectedIds.contains(id),
                  onTap: () {
                    if (id == null) return;
                    setState(() {
                      if (!_selectedIds.remove(id)) _selectedIds.add(id);
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              14.w,
              4.h,
              14.w,
              16.h + MediaQuery.of(context).padding.bottom,
            ),
            child: _SheetButton(
              label: 'apply_button'.tr(),
              gradient: AppGradients.brand,
              onTap: () => Navigator.of(context).pop(
                CategoryPickerResult([
                  for (final cat in widget.categories)
                    if (_selectedIds.contains(cat.id)) cat,
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The category's own artwork, as home's category grid shows it — so the
/// sheet is recognised at a glance, not read row by row.
Widget _artwork(HomCategory category) {
  final url = sanitizeImageUrl(category.image);
  if (url == null) {
    return Icon(
      Icons.category_rounded,
      size: 20.sp,
      color: AppColors.brandPurple,
    );
  }
  return CachedNetworkImage(
    imageUrl: url,
    fit: BoxFit.cover,
    // Decoded at roughly the size it is painted; see `CategoryItemWidget`.
    memCacheWidth: 120,
    memCacheHeight: 120,
    fadeInDuration: Duration.zero,
    errorWidget: (_, __, ___) => Icon(
      Icons.category_rounded,
      size: 20.sp,
      color: AppColors.brandPurple,
    ),
  );
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;

  /// Drawn on the same white tile in both states, so the artwork — which has
  /// a white background of its own — never sits on the selected gradient.
  final Widget icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(8.w, 8.h, 16.w, 8.h),
        decoration: BoxDecoration(
          gradient: selected ? AppGradients.indigo : null,
          color: selected ? null : c.control,
          borderRadius: BorderRadius.circular(16.r),
          border: selected ? null : Border.all(color: c.controlBorder),
        ),
        child: Row(
          children: [
            FrostedCard(
              width: 40.w,
              height: 40.w,
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(12.r),
              borderWidth: 1.6,
              gradient: AppGradients.artworkWhite,
              borderColor: AppColors.white,
              clipBehavior: Clip.antiAlias,
              alignment: Alignment.center,
              child: icon,
            ),
            12.horizontalSpace,
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

/// Same button the filter sheet's Apply uses (kept local — that one is
/// library-private to `filter_bottom_sheet.dart`).
class _SheetButton extends StatelessWidget {
  const _SheetButton({
    required this.label,
    required this.onTap,
    this.gradient,
  });

  final String label;
  final VoidCallback onTap;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Bouncing(
      onTap: onTap,
      child: Container(
        height: 50.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: gradient == null ? c.control : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(44.r),
        ),
        child: Text(
          label,
          style: AppText.medium16.copyWith(
            color: gradient == null ? c.textPrimary : AppColors.onBrand,
          ),
        ),
      ),
    );
  }
}
