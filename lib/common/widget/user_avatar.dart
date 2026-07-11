import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';

/// The person's picture, or the brand-gradient circle with the user glyph when
/// there is none. The single avatar in the app — account screen, child details,
/// profile header, home header.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.file,
    this.imageUrl,
    this.size = 64,
    this.shape = BoxShape.circle,
    this.borderRadius,
    this.background,
    this.iconColor,
  });

  /// A local photo — picked on this device, or the parent's stored avatar.
  final File? file;

  /// A photo the backend serves.
  final String? imageUrl;

  /// Diameter (or side) in design pixels; scaled with `.w`.
  final double size;

  /// Square avatars pass [BoxShape.rectangle] plus a [borderRadius].
  final BoxShape shape;
  final BorderRadius? borderRadius;

  /// Fill behind the glyph. Defaults to the brand gradient when omitted.
  final Color? background;

  /// Glyph tint. Defaults to white, which is what the gradient wants.
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final dimension = size.w;

    return Container(
      width: dimension,
      height: dimension,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: shape == BoxShape.circle ? null : borderRadius,
        color: background,
        gradient: background == null ? AppGradients.brand : null,
      ),
      child: _content(dimension),
    );
  }

  Widget _content(double dimension) {
    if (file != null) {
      return Image.file(
        file!,
        width: dimension,
        height: dimension,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _glyph(dimension),
      );
    }
    if (imageUrl != null) {
      return Image.network(
        imageUrl!,
        width: dimension,
        height: dimension,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _glyph(dimension),
      );
    }
    return _glyph(dimension);
  }

  Widget _glyph(double dimension) {
    // Glyph reads best at ~55% of the circle, matching the Figma avatar.
    final glyphSize = dimension * 0.55;
    return Assets.icons.profile.icUser.svg(
      width: glyphSize,
      height: glyphSize,
      colorFilter: ColorFilter.mode(
        iconColor ?? AppColors.onBrand,
        BlendMode.srcIn,
      ),
    );
  }
}
