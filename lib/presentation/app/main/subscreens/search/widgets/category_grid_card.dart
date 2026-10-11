import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/number_extensions.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/image_url.dart';
import 'package:lumi_pass/common/widget/bouncing_button.dart';

/// Side of the artwork in the card's bottom-right corner.
const double _kArtSize = 76;

/// The card's height. Fixed, so the artwork has a corner to sit in whatever
/// the name's length — and so every card in the grid is the same shape.
const double _kCardHeight = 104;

/// A category as a large card in the search screen's two-column grid — the
/// name in the top-left corner, the artwork in the bottom-right, running off
/// the card's edge.
///
/// The artwork is a cut-out with no background of its own, so it is painted
/// straight onto the card's surface rather than framed in a white badge: the
/// same picture then sits on a light card in light mode and a dark one in
/// dark. It is drawn larger than the corner holds and clipped by the card,
/// which is what makes it read as part of the card instead of an icon on it.
///
/// The name keeps to the left of the artwork (its column stops short of it),
/// so a two-line name wraps beside the picture, never over it.
class CategoryGridCard extends StatelessWidget {
  const CategoryGridCard({
    super.key,
    required this.title,
    required this.onTap,
    this.imageUrl,
    this.icon,
    this.art,
    this.count,
  });

  final String title;
  final VoidCallback onTap;

  /// How many activities are in this category.
  ///
  /// Null while it is still being counted — the line is then absent rather than
  /// reading "0", which is a different and usually wrong statement. A category
  /// that genuinely holds nothing DOES print 0: it is the one fact that would
  /// stop someone tapping it, and finding out after the tap is worse.
  final int? count;

  /// The category's artwork. Ignored when [icon] is given.
  final String? imageUrl;

  /// A glyph to show instead of artwork — the "all categories" card has no
  /// category behind it, so it has no image to load.
  final Widget? icon;

  /// Artwork bundled with the app, shown in the corner exactly as a category's
  /// own is — the "all categories" card has no category behind it to load a
  /// picture from, so it brings one. Wins over [imageUrl] and [icon].
  final ImageProvider? art;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Bouncing(
      onTap: onTap,
      child: Container(
        height: _kCardHeight.w,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: c.controlBorder),
        ),
        child: Stack(
          children: [
            // Pushed past the corner, so the card's own edge crops it.
            Positioned(
              right: -6.w,
              bottom: -8.w,
              width: _kArtSize.w,
              height: _kArtSize.w,
              child: art != null
                  ? Image(image: art!, fit: BoxFit.contain)
                  : icon != null
                      ? _glyph()
                      : _artwork(context),
            ),
            Padding(
              // The right inset is the artwork's width: the name wraps before
              // it reaches the picture.
              padding: EdgeInsets.fromLTRB(12.w, 12.w, 62.w, 12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Up to two lines: most names fit on one, and the few that
                  // don't wrap instead of being cut short.
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.semibold14.copyWith(color: c.textPrimary),
                  ),
                  // How much is behind the name. Secondary ink and a size
                  // down: it qualifies the category, it is not a second name
                  // for it, and a grid where every card carried two lines of
                  // equal weight would read as a table.
                  if (count != null) ...[
                    2.verticalSpace,
                    Text(
                      'activities_count'.tr(args: [count!.grouped]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          AppText.regular12.copyWith(color: c.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The "all categories" card's glyph, sat in the corner the artwork takes on
  /// the other cards — inset, since a glyph cropped by the edge would just
  /// look cut off.
  Widget _glyph() => Align(
        alignment: const Alignment(-0.1, -0.2),
        child: SizedBox(
          width: 40.w,
          height: 40.w,
          child: FittedBox(child: icon),
        ),
      );

  Widget _artwork(BuildContext context) {
    final url = sanitizeImageUrl(imageUrl);
    if (url == null) return _fallback();
    // Decoded at the size it is painted, for the reason the Home tile does it:
    // a full-resolution bitmap is evicted as soon as the screen is left.
    final decodeSize =
        (_kArtSize.w * MediaQuery.devicePixelRatioOf(context)).round();
    return CachedNetworkImage(
      imageUrl: url,
      // The whole cut-out, not a crop of it: the card's edge does the
      // cropping.
      fit: BoxFit.contain,
      width: _kArtSize.w,
      height: _kArtSize.w,
      memCacheWidth: decodeSize,
      memCacheHeight: decodeSize,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      placeholder: (_, __) => const SizedBox.shrink(),
      errorWidget: (_, __, ___) => _fallback(),
    );
  }

  /// No artwork: the category's initial on the brand gradient, as on Home —
  /// a rounded tile inset in the corner, since it has no shape to crop.
  Widget _fallback() {
    final letter =
        title.isNotEmpty ? title.characters.first.toUpperCase() : '?';
    return Align(
      alignment: const Alignment(-0.1, -0.2),
      child: Container(
        width: 40.w,
        height: 40.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: AppGradients.brand,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          letter,
          style: AppText.bold18.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

/// Placeholder for a [CategoryGridCard] while the categories load.
class CategoryGridCardSkeleton extends StatelessWidget {
  const CategoryGridCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _kCardHeight.w,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
  }
}
