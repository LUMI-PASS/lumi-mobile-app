import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/image_url.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:shimmer/shimmer.dart';

/// Category tile from the redesigned home — a rounded icon tile on the
/// `Color/Shape` surface with the category label beneath (Figma `Category item`).
class CategoryItemWidget extends StatelessWidget {
  const CategoryItemWidget({
    super.key,
    required this.homeCategoryModel,
    this.onTap,
  });

  final HomCategory? homeCategoryModel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final url = sanitizeImageUrl(homeCategoryModel?.image);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(left: 16.w),
        child: SizedBox(
          width: 64.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: url != null
                      ? CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.contain,
                          placeholder: (_, __) => _shimmer(c),
                          errorWidget: (_, __, ___) => _fallback(),
                        )
                      : _fallback(),
                ),
              ),
              8.verticalSpace,
              Text(
                homeCategoryModel?.title ?? '',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppText.medium13.copyWith(color: c.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shimmer(AppColors c) => Shimmer.fromColors(
        baseColor: c.surface,
        highlightColor: c.isDark ? const Color(0xFF2E2E35) : Colors.white,
        child: Container(color: c.surface),
      );

  Widget _fallback() {
    final title = homeCategoryModel?.title ?? '';
    final letter = title.isNotEmpty ? title.characters.first.toUpperCase() : '?';
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
