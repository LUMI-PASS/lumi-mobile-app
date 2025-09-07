import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/widget/bouncing_button.dart';
import 'package:lumi_pass/data/base_model/default_theme_colors.dart';

class CommonButton extends StatelessWidget {
  const CommonButton._(this.text, this.loading, this.enabled, this.onPressed, this.radius, this.type,
      {super.key,
      this.backgroundColor,
      this.textColor,
      this.icon,
      this.padding,
      this.prefixIcon,
      this.shadow = false,
      this.borderColor,
      this.isRightIcon});

  final String text;
  final bool loading;
  final bool enabled;
  final VoidCallback? onPressed;
  final double? radius;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? icon;
  final double? padding;
  final CommonButtonType type;
  final Widget? prefixIcon;
  final bool shadow;
  final Color? borderColor;
  final bool? isRightIcon;

  const CommonButton.outlined(
      {required String text,
      bool loading = false,
      bool enabled = true,
      VoidCallback? onPressed,
      double? radius,
      Color? backgroundColor,
      Color? textColor,
      Key? key,
      Widget? icon,
      double? padding,
      Color? borderColor})
      : this._(text, loading, enabled, onPressed, radius, CommonButtonType.outlined,
            backgroundColor: backgroundColor,
            textColor: textColor,
            key: key,
            icon: icon,
            padding: padding,
            borderColor: borderColor);

  CommonButton.elevated({
    required String text,
    bool loading = false,
    bool enabled = true,
    VoidCallback? onPressed,
    Color? backgroundColor,
    Color? textColor,
    Widget? icon,
    double? radius,
    Key? key,
    double? padding,
    bool? isRight,
    bool shadow = false,
  }) : this._(
          backgroundColor: backgroundColor,
          textColor: textColor,
          text,
          loading,
          enabled,
          onPressed,
          radius ?? 16.r,
          CommonButtonType.elevated,
          key: key,
          icon: icon,
          isRightIcon: isRight,
          padding: padding,
          shadow: shadow,
        );

  const CommonButton.text({
    required String text,
    bool loading = false,
    bool enabled = true,
    VoidCallback? onPressed,
    double radius = 0,
    Key? key,
    double? padding,
    Widget? prefixIcon,
  }) : this._(
          text,
          loading,
          enabled,
          onPressed,
          radius,
          CommonButtonType.text,
          key: key,
          padding: padding,
          prefixIcon: prefixIcon,
        );

  VoidCallback? _onPressed() {
    if (!enabled) return null;
    return () {
      if (loading) return;
      onPressed?.call();
    };
  }

  Widget _child(Color color) {
    return loading
        ? Center(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: CircularProgressIndicator(
                strokeWidth: 3.w,
                backgroundColor: color,
              ),
            ),
          )
        : Padding(
            padding: EdgeInsets.symmetric(
              vertical: padding ?? 12.h,
              horizontal: 4.w,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null && isRightIcon == false)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [icon ?? Container(), 6.kw],
                  ),
                Center(child: text.w(600).s(16).c(textColor ?? StaticColors.white)),
                Visibility(
                  visible: icon != null && isRightIcon == true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [6.kw, icon ?? Container()],
                  ),
                ),
              ],
            ),
          );
  }

  Widget _outlined(BuildContext context) {
    return Bouncing(
      onTap: enabled ? _onPressed() : () {},
      child: Container(
        height: 48.sp,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius ?? 16.r),
          border: Border.all(color: borderColor ?? context.colors.primary),
          color: backgroundColor ?? context.colors.onPrimary,
        ),
        child: _child(textColor ?? context.colors.onPrimary),
      ),
    );
  }

  Widget _elevated(BuildContext context) {
    return Container(
      height: 48.h,
      decoration: shadow
          ? BoxDecoration(
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: context.colors.primary2,
                  spreadRadius: 10,
                  blurRadius: 16,
                ),
              ],
            )
          : null,
      child: Bouncing(
        onTap: enabled ? _onPressed() : () {},
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius ?? 16.r),
            color: enabled ? backgroundColor ?? context.colors.primary : context.colors.grey,
          ),
          child: _child(
            enabled ? textColor ?? context.colors.onPrimary : context.colors.primary,
          ),
        ),
      ),
    );
  }

  Widget _text(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
      onPressed: _onPressed(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
              child: text.w(600).s(16).c(context.colors.display).copyWith(
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: context.colors.display))),
          4.kw,
          if (prefixIcon != null) prefixIcon!,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case CommonButtonType.outlined:
        return _outlined(context);
      case CommonButtonType.elevated:
        return _elevated(context);
      case CommonButtonType.text:
        return _text(context);
    }
  }
}

enum CommonButtonType { outlined, elevated, text }
