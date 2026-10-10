import 'package:flutter/material.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/bouncing_button.dart';

/// Primary pill button from the Figma auth flow — pink→purple gradient.
/// Matches "Далее" / "Потвердить" / "Подтвердить".
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.enabled = true,
    this.loading = false,
    this.gradient,
    this.foreground,
  });

  /// Overrides the brand gradient — for a sheet reskinned to its host screen
  /// (see `PaymentSheetSkin`). Null is the brand pink→purple.
  final Gradient? gradient;

  /// Ink on [gradient]. Null is the brand's own.
  final Color? foreground;

  final String text;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final active = enabled && !loading;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Bouncing(
        onTap: () {
          if (active) onPressed?.call();
        },
        child: Container(
          height: 50.h,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: gradient ?? AppGradients.brand,
            borderRadius: BorderRadius.circular(44.r),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (loading)
                SizedBox(
                  width: 22.r,
                  height: 22.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        foreground ?? AppColors.onBrand),
                  ),
                )
              else
                Text(
                  text,
                  style: AppText.medium16
                      .copyWith(color: foreground ?? AppColors.onBrand),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Flat text button ("Пропустить" / "Отправить снова" / "Далее" link).
class AuthTextButton extends StatelessWidget {
  const AuthTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color,
  });

  final String text;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Bouncing(
      onTap: () => onPressed?.call(),
      child: Container(
        height: 50.h,
        alignment: Alignment.center,
        color: Colors.transparent,
        child: Text(
          text,
          style: AppText.medium16
              .copyWith(color: color ?? context.colors.textPrimary),
        ),
      ),
    );
  }
}
