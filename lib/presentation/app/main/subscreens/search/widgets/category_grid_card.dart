import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/image_url.dart';
import 'package:lumi_pass/common/widget/bouncing_button.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';

/// Side of the artwork badge in the card's top-left corner.
const double _kBadgeSize = 52;

/// A category as a large card in the search screen's two-column grid — artwork
/// badge in the top-left corner, the name beneath it.
///
/// The card is as tall as its content: the name sits directly under the badge
/// and a second line makes the card taller, rather than every card reserving
/// room for a line most names never use.
///
/// The same category Home shows as a small tile (`CategoryItemWidget`), given
/// room: the surface is the one the "view on map" row above it uses, and the
/// badge is the tile's frosted artwork, so the grid reads as part of the same
/// screen rather than a second visual language.
class CategoryGridCard extends StatelessWidget {
  const CategoryGridCard({
    super.key,
    required this.title,
    required this.onTap,
    this.imageUrl,
    this.icon,
  });

  final String title;
  final VoidCallback onTap;

  /// The category's artwork. Ignored when [icon] is given.
  final String? imageUrl;

  /// A glyph to show instead of artwork — the "all categories" card has no
  /// category behind it, so it has no image to load.
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Bouncing(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: c.controlBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FrostedCard(
              width: _kBadgeSize.w,
              height: _kBadgeSize.w,
              padding: EdgeInsets.zero,
              borderWidth: 1.6,
              // White in both themes: the artwork has a white background, and
              // the glyph card gets the same tile so it reads as one of the
              // set. Its glyph must therefore be a fixed ink (brand purple),
              // not a themed one that would vanish on white in dark mode.
              gradient: AppGradients.artworkWhite,
              borderColor: AppColors.white,
              alignment: Alignment.center,
              clipBehavior: Clip.antiAlias,
              child: icon ?? _artwork(context),
            ),
            10.verticalSpace,
            // Up to two lines: most names fit on one, and the few that don't
            // wrap instead of being cut short.
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppText.semibold14.copyWith(color: c.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _artwork(BuildContext context) {
    final url = sanitizeImageUrl(imageUrl);
    if (url == null) return _fallback();
    // Decoded at the size it is painted, for the reason the Home tile does it:
    // a full-resolution bitmap is evicted as soon as the screen is left.
    final decodeSize =
        (_kBadgeSize.w * MediaQuery.devicePixelRatioOf(context)).round();
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: _kBadgeSize.w,
      height: _kBadgeSize.w,
      memCacheWidth: decodeSize,
      memCacheHeight: decodeSize,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      placeholder: (_, __) => const SizedBox.shrink(),
      errorWidget: (_, __, ___) => _fallback(),
    );
  }

  /// No artwork: the category's initial on the brand gradient, as on Home.
  Widget _fallback() {
    final letter =
        title.isNotEmpty ? title.characters.first.toUpperCase() : '?';
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppGradients.brand),
      child: Center(
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
      // A card with a one-line name: padding, badge, gap and the label.
      height: (12 + _kBadgeSize + 10 + 20 + 12).w,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
  }
}
