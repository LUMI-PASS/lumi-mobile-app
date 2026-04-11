import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/widget/container_3d.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/service/photo_service.dart';
import 'package:shimmer/shimmer.dart';

class CategoryItemWidget extends StatefulWidget {
  final HomCategory? homeCategoryModel;
  final VoidCallback? onTap;

  const CategoryItemWidget({
    super.key,
    required this.homeCategoryModel,
    this.onTap,
  });

  @override
  State<CategoryItemWidget> createState() => _CategoryItemWidgetState();
}

class _CategoryItemWidgetState extends State<CategoryItemWidget> {
  String? _resolvedImageUrl;
  bool _imageOk = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _resolveImage();
  }

  @override
  void didUpdateWidget(CategoryItemWidget old) {
    super.didUpdateWidget(old);
    if (old.homeCategoryModel?.id != widget.homeCategoryModel?.id) {
      _resolveImage();
    }
  }

  Future<void> _resolveImage() async {
    final cat = widget.homeCategoryModel;
    final catId = cat?.id;
    final hasPhoto = cat?.hasPhoto == true;

    final fallback =
        (hasPhoto && catId != null) ? PhotoService.getImageUrl(catId) : null;

    setState(() {
      _resolvedImageUrl = fallback;
      _imageOk = fallback != null;
      _isLoading = true;
    });

    if (catId != null) {
      try {
        final photos = await PhotoService.instance
            .getCategoryPhotos(catId, limit: 1);
        if (mounted && photos.isNotEmpty) {
          setState(() {
            _resolvedImageUrl = photos.first;
            _imageOk = true;
            _isLoading = false;
          });
          return;
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container3d(
      onTap: widget.onTap,
      width: 150.w,
      margin: EdgeInsets.only(left: 16.w),
      padding: EdgeInsets.zero,
      backgroundColor: Colors.white,
      borderColor: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(22.r),
      depth: 4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: SizedBox(
              height: 112.h,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Shimmer while loading
                  if (_isLoading && !_imageOk)
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade200,
                      highlightColor: Colors.grey.shade50,
                      child: Container(color: Colors.white),
                    ),

                  if (_imageOk && _resolvedImageUrl != null)
                    CachedNetworkImage(
                      imageUrl: _resolvedImageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Shimmer.fromColors(
                        baseColor: Colors.grey.shade200,
                        highlightColor: Colors.grey.shade50,
                        child: Container(color: Colors.white),
                      ),
                      errorWidget: (_, __, ___) =>
                          _buildGradientFallback(),
                    )
                  else if (!_isLoading)
                    _buildGradientFallback(),

                  // Gradient overlay at bottom
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding:
                          EdgeInsets.fromLTRB(4.w, 32.h, 4.w, 8.h),
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
                        widget.homeCategoryModel?.title ?? '',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                                blurRadius: 4,
                                color: Colors.black54),
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
    );
  }

  Widget _buildGradientFallback() {
    final title = widget.homeCategoryModel?.title ?? '';
    final charCode = title.isNotEmpty ? title.codeUnitAt(0) : 65;
    final index = (charCode + title.length) % _gradients.length;

    return Container(
      decoration: BoxDecoration(
        gradient: _gradients[index],
      ),
    );
  }

  static final List<LinearGradient> _gradients = [
    const LinearGradient(
        colors: [Color(0xFFA652C7), Color(0xFFFF7093)]),
    const LinearGradient(
        colors: [Color(0xFF307CE0), Color(0xFF24AE74)]),
    const LinearGradient(
        colors: [Color(0xFFF6B53D), Color(0xFFE6465A)]),
    const LinearGradient(
        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
    const LinearGradient(
        colors: [Color(0xFF14B8A6), Color(0xFF3B82F6)]),
    const LinearGradient(
        colors: [Color(0xFFF43F5E), Color(0xFFF97316)]),
  ];
}
