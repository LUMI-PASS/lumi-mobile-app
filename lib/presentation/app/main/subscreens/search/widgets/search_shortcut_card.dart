import 'package:flutter/material.dart';
import 'package:lumi_pass/common/extensions/number_extensions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/bouncing_button.dart';

/// A shortcut at the top of the search tab — a coloured glyph, a short label,
/// and how many things are behind it ("On the map", "Activities", "Saved").
///
/// The row of these is where the ways into the catalog that are not a category
/// live. Each one gets its own [color], so they are told apart at a glance and
/// not by reading; the card itself is the same surface as the category cards
/// below it.
///
/// Typography is a notch smaller than those cards' on purpose. Three of these
/// share a screen width, which leaves each one about a third of it — at the
/// category cards' 14pt, "Mashg'ulotlar" ran past two lines and ellipsised.
///
/// The colour is deliberately faint. Three saturated discs in a row, each with
/// a coloured number under it, turned the top of the tab into the loudest thing
/// on a screen whose actual subject is the category grid below. [color] now
/// tints only the glyph; the disc behind it is a wash, the border is the
/// lightest the palette has, and the count is plain ink. The green / pink / red
/// are hints that tell the three cards apart, not blocks of colour competing
/// with the content.
class SearchShortcutCard extends StatelessWidget {
  const SearchShortcutCard({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    this.count,
  });

  final SvgGenImage icon;

  /// Tints the glyph and, faintly, the disc behind it.
  final Color color;
  final String label;
  final VoidCallback onTap;

  /// How many things are behind the card, printed under the label in the
  /// card's own colour.
  ///
  /// The point is to answer "is it worth tapping" before the tap: a shelf of
  /// nine saved activities and an empty one look identical otherwise, and a
  /// catalogue is more inviting when it says how big it is. Null while the
  /// number is still being fetched — the line is then absent rather than
  /// reading "0", which would be a different and wrong statement.
  final int? count;

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
          // `divider`, not `controlBorder`: this card is a surface to read, not
          // a control to operate, and the heavier edge drew a box around every
          // one of the three.
          border: Border.all(color: c.divider),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: icon.svg(
                width: 22.w,
                height: 22.w,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
            ),
            8.verticalSpace,
            Text(
              label,
              // One line is enough for every label at this size; two is the
              // safety net for a translation longer than the ones we ship.
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: AppText.semibold12.copyWith(color: c.textPrimary),
            ),
            if (count != null) ...[
              2.verticalSpace,
              Text(
                count!.grouped,
                maxLines: 1,
                textAlign: TextAlign.center,
                // Bigger than the label, so the number still reads as the fact
                // the card carries and the label as what names it — but in
                // ordinary ink. Coloured, it was a third accent on a card that
                // already has two, and three of those in a row read as a
                // warning rather than as a count.
                style: AppText.semibold14.copyWith(color: c.textPrimary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
