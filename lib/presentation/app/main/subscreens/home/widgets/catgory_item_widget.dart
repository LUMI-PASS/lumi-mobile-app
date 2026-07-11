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

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: padding ?? EdgeInsets.only(left: 16.w),
        child: SizedBox(
          width: width ?? 64.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                                placeholder: (_, __) => _shimmer(c),
                                errorWidget: (_, __, ___) => _fallback(),
                          ),
              ),
              8.verticalSpace,
              Text(
                homeCategoryModel?.title ?? '',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.medium13.copyWith(color: c.textPrimary),
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
