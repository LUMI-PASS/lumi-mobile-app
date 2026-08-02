import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  /// Tile column width. Defaults to the horizontal row's fixed 64pt; pass
  /// `null`-widening (e.g. `double.infinity`) inside a grid.
  final double? width;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final url = sanitizeImageUrl(homeCategoryModel?.image);
    // Decode the artwork at the size it is actually painted (56pt) instead of
    // the source's full resolution. A full-res bitmap is large enough that
    // Flutter's image cache evicts it as soon as the user leaves Home, so the
    // tile had to re-read and re-decode from disk — and flash its shimmer —
    // every time the screen came back. At tile size the whole row stays
    // resident and re-renders instantly.
    final decodeSize = (56.w * MediaQuery.devicePixelRatioOf(context)).round();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: padding ?? EdgeInsets.only(left: 16.w),
        child: SizedBox(
          width: width ?? 64.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FrostedCard(
                width: 56.w,
                height: 56.w,
                padding: EdgeInsets.zero,
                borderWidth: 1.6,
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
              8.verticalSpace,
              // Two lines: at 64pt most category names don't survive a single
              // line, so the label wraps instead of being cut short.
              //
              // Full-width so `textAlign.center` centres against the tile. A
              // shrink-wrapped Text centres only its own second line, which
              // leaves a one-line label sitting off-centre under the artwork.
              SizedBox(
                width: double.infinity,
                child: Text(
                  homeCategoryModel?.title ?? '',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.medium12.copyWith(color: c.textPrimary),
                ),
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
