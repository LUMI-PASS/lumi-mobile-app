import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/bouncing_button.dart';

/// A shortcut at the top of the search tab — a coloured glyph over a short
/// label, centred in a card ("On the map", "Courses").
///
/// The row of these is where the ways into the catalog that are not a category
/// live. Each one gets its own [color], so they are told apart at a glance and
/// not by reading; the card itself is the same surface as the category cards
/// below it.
class SearchShortcutCard extends StatelessWidget {
  const SearchShortcutCard({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final SvgGenImage icon;

  /// Tints the glyph and, faintly, the disc behind it.
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Bouncing(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 14.w),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: c.controlBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: icon.svg(
                width: 24.w,
                height: 24.w,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
            ),
            10.verticalSpace,
            Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: AppText.semibold14.copyWith(color: c.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
