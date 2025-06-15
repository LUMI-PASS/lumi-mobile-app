import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class ChessNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final SvgPicture? errorImage;
  final String baseUrl;
  final BorderRadius? borderRadius;
  final Color? shimmerBaseColor;
  final Color? shimmerHighlightColor;

  const ChessNetworkImage({
    required this.imageUrl,
    required this.baseUrl,
    this.errorImage,
    this.height,
    this.width,
    this.fit,
    this.borderRadius,
    this.shimmerBaseColor,
    this.shimmerHighlightColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl.formatUrl(baseUrl),
        fit: fit,
        height: height,
        width: width,
        placeholder: (context, url) => _buildShimmerPlaceholder(isDarkMode),
        errorWidget: (context, error, stackTrace) {
          return errorImage ??
              ChessUiKitAssets.images.errorImage.image(
                height: height,
                width: width,
                fit: BoxFit.cover,
              );
        },
      ),
    );
  }

  Widget _buildShimmerPlaceholder(bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: shimmerBaseColor ??
          (isDarkMode ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB)),
      highlightColor: shimmerHighlightColor ??
          (isDarkMode ? const Color(0xFF374151) : const Color(0xFFF9FAFB)),
      period: const Duration(milliseconds: 1200),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
          borderRadius: borderRadius,
        ),
        child: _buildShimmerContent(isDarkMode),
      ),
    );
  }

  Widget _buildShimmerContent(bool isDarkMode) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        // Loading text placeholder
        Container(
          width: 60,
          height: 12,
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }
}

// Alternative version with just a simple shimmer box
class ChessNetworkImageSimple extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final SvgPicture? errorImage;
  final String baseUrl;
  final BorderRadius? borderRadius;

  const ChessNetworkImageSimple({
    required this.imageUrl,
    required this.baseUrl,
    this.errorImage,
    this.height,
    this.width,
    this.fit,
    this.borderRadius,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const isDarkMode = true;

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl.formatUrl(baseUrl),
        fit: fit,
        height: height,
        width: width,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: isDarkMode ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
          highlightColor: isDarkMode ? const Color(0xFF374151) : const Color(0xFFF9FAFB),
          child: Container(
            height: height,
            width: width,
            color: isDarkMode ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
          ),
        ),
        errorWidget: (context, error, stackTrace) {
          return errorImage ??
              ChessUiKitAssets.images.errorImage.image(
                height: height,
                width: width,
                fit: BoxFit.cover,
              );
        },
      ),
    );
  }
}