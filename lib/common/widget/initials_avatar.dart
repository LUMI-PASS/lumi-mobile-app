import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';

/// The brand-gradient circle carrying a name's first letter — the stand-in
/// wherever a person has no photo (account screen, child details).
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.name, this.size = 64});

  final String name;

  /// Diameter in design pixels; scaled with `.w`.
  final double size;

  String get _initial {
    final trimmed = name.trim();
    return trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppGradients.brand,
      ),
      child: Text(
        _initial,
        style: AppText.heading20.copyWith(color: AppColors.onBrand),
      ),
    );
  }
}
