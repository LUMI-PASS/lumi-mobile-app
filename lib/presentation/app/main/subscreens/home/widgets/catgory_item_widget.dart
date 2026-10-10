import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/image_url.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:shimmer/shimmer.dart';

/// Tilt of the category artwork inside its tile — Figma `Category item` rotates
/// the image 14.75°.
const double _kArtworkTilt = 14.75 * math.pi / 180;

/// Category tile from the redesigned home — a frosted tile whose artwork sits
/// oversized and tilted in the bottom-left corner, with the category label
/// beneath (Figma `Category item`).
class CategoryItemWidget extends StatelessWidget {
  const CategoryItemWidget({
    super.key,
    required this.homeCategoryModel,
    this.onTap,
    this.padding,
    this.width,
  });

  final HomCategory? homeCategoryModel;
  final VoidCallback? onTap;

  /// Outer padding. Defaults to the horizontal row's leading gap; pass
  /// [EdgeInsets.zero] when the tile sits in a grid cell.
  final EdgeInsetsGeometry? padding;

  /// Tile column width. Left null, the column takes the width of its own
  /// label — never narrower than [_minColumn], never wider than [_maxColumn]
  /// — so a row of these is spaced by a fixed gap rather than by columns of
  /// one size, which left a short name like "Ijod" adrift in the room a long
  /// one needed. Pass a width (e.g. `double.infinity`) inside a grid.
  final double? width;

  static double get _minColumn => 52.w;

  /// Just over the longest category name on one line at the label's size.
  static double get _maxColumn => 76.w;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final url = sanitizeImageUrl(homeCategoryModel?.image);
    // Decode the artwork at the size it is actually painted (48pt) instead of
    // the source's full resolution. A full-res bitmap is large enough that
    // Flutter's image cache evicts it as soon as the user leaves Home, so the
    // tile had to re-read and re-decode from disk — and flash its shimmer —
    // every time the screen came back. At tile size the whole row stays
    // resident and re-renders instantly.
    final decodeSize = (48.w * MediaQuery.devicePixelRatioOf(context)).round();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: padding ?? EdgeInsets.only(left: 16.w),
        child: ConstrainedBox(
          constraints: width != null
              ? BoxConstraints.tightFor(width: width)
              : BoxConstraints(minWidth: _minColumn, maxWidth: _maxColumn),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FrostedCard(
                width: 48.w,
                height: 48.w,
                padding: EdgeInsets.zero,
                borderRadius: BorderRadius.circular(14.r),
                borderWidth: 1.6,
                // White in both themes — the artwork has a white background.
                gradient: AppGradients.artworkWhite,
                borderColor: AppColors.white,
                clipBehavior: Clip.antiAlias,
                child: url == null
                    ? _fallback()
                    : CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.cover,
                        memCacheWidth: decodeSize,
                        memCacheHeight: decodeSize,
                        // A cached tile is ready on the first frame; fading it
                        // in would re-introduce the flicker we just removed.
                        fadeInDuration: Duration.zero,
                        fadeOutDuration: Duration.zero,
                        placeholder: (_, __) => _shimmer(c),
                        errorWidget: (_, __, ___) => _fallback(),
                      ),
              ),
              6.verticalSpace,
              // Two lines, for a name too long for [_maxColumn]. The column
              // centres the label under the tile, and `textAlign` centres the
              // second line under the first.
              Text(
                homeCategoryModel?.title ?? '',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppText.medium10.copyWith(color: c.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shimmer(AppColorScheme c) => Shimmer.fromColors(
        baseColor: c.surface,
        highlightColor: c.isDark ? const Color(0xFF2E2E35) : Colors.white,
        child: Container(color: c.surface),
      );

  Widget _fallback() {
    final title = homeCategoryModel?.title ?? '';
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
