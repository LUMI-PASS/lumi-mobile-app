import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/constants/constants.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';

class CategoryItemWidget extends StatelessWidget {
  final HomCategory? homeCategoryModel;
  final VoidCallback? onTap;

  const CategoryItemWidget({
    super.key,
    required this.homeCategoryModel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = homeCategoryModel?.id != null
        ? '${Constants.assetsUrl}${homeCategoryModel!.id}'
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150.w,
        margin: EdgeInsets.only(left: 16.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: Colors.white.withOpacity(0.9)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3C539A).withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image with overlay title
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: SizedBox(
                height: 112.h,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (imageUrl != null)
                      CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, error, stackTrace) =>
                            _buildGradientFallback(),
                      )
                    else
                      _buildGradientFallback(),
                    // Gradient overlay at bottom
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(4.w, 32.h, 4.w, 8.h),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                        child: Text(
                          homeCategoryModel?.title ?? '',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            shadows: const [
                              Shadow(blurRadius: 4, color: Colors.black54),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientFallback() {
    final title = homeCategoryModel?.title ?? '';
    final charCode = title.isNotEmpty ? title.codeUnitAt(0) : 65;
    final index = (charCode + title.length) % _gradients.length;

    return Container(
      decoration: BoxDecoration(
        gradient: _gradients[index],
      ),
    );
  }

  static final List<LinearGradient> _gradients = [
    const LinearGradient(colors: [Color(0xFFA652C7), Color(0xFFFF7093)]),
    const LinearGradient(colors: [Color(0xFF307CE0), Color(0xFF24AE74)]),
    const LinearGradient(colors: [Color(0xFFF6B53D), Color(0xFFE6465A)]),
    const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
    const LinearGradient(colors: [Color(0xFF14B8A6), Color(0xFF3B82F6)]),
    const LinearGradient(colors: [Color(0xFFF43F5E), Color(0xFFF97316)]),
  ];
}
