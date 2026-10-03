import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/data/api_model/class_full/class_full_model.dart';

/// Five stars, [filled] of them lit. Display only — see [RatePrompt] for the
/// tappable ones.
class RatingStars extends StatelessWidget {
  const RatingStars({super.key, required this.filled, this.size = 14});

  /// How many stars are lit, 0–5. An average is rounded by the caller.
  final int filled;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var star = 1; star <= 5; star++)
          Icon(
            star <= filled ? CupertinoIcons.star_fill : CupertinoIcons.star,
            size: size.sp,
            color: star <= filled ? AppColors.warning : c.disabled,
          ),
      ],
    );
  }
}

/// The rating under a class's title — just "★ 3.9". The count and the reviews
/// themselves are in the reviews card further down; here it is only the score,
/// so it does not compete with the name. Tapping it opens the reviews.
class RatingInline extends StatelessWidget {
  const RatingInline({super.key, required this.rating, this.onTap});
  final RatingSummary rating;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.star_fill, size: 16.sp, color: AppColors.warning),
          4.horizontalSpace,
          Text(
            rating.average.toStringAsFixed(1),
            style: AppText.semibold14.copyWith(color: c.textPrimary),
          ),
        ],
      ),
    );
  }
}

/// "Tap to rate" — a label and five stars to tap, for a viewer who has bought
/// the class. Compact on purpose: it sits under the reviews as the App Store's
/// does, a quiet invitation rather than a block of its own.
///
/// Tapping a star IS the action: it opens the rating sheet with that many
/// stars already picked, so the first gesture is the rating itself rather than
/// a button that leads to one. Once they have rated, the label becomes "your
/// rating", their stars are lit, and tapping one edits it.
///
/// Shared by the class detail page's reviews card and the booking detail page,
/// so a parent can rate from the ticket as well as from the catalog.
class RatePrompt extends StatelessWidget {
  const RatePrompt({super.key, required this.rating, required this.onRate});
  final RatingSummary rating;

  /// Called with the star that was tapped, 1–5.
  final ValueChanged<int> onRate;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final mine = rating.viewerRating ?? 0;

    return Column(
      children: [
        Text(
          mine > 0 ? 'rate_prompt_yours'.tr() : 'rate_prompt_hint'.tr(),
          style: AppText.semibold14.copyWith(color: c.textPrimary),
        ),
        4.verticalSpace,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var star = 1; star <= 5; star++)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onRate(star);
                },
                // The padding is the tap target — the glyph alone is too small
                // a thing to hit.
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 6.h),
                  child: Icon(
                    star <= mine
                        ? CupertinoIcons.star_fill
                        : CupertinoIcons.star,
                    size: 24.sp,
                    // Outlined in the brand colour so empty stars read as
                    // something to press, not as a zero score.
                    color: star <= mine
                        ? AppColors.warning
                        : AppColors.brandPurple,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
