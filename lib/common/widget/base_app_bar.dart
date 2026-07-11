import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:lumi_pass/common/widget/control_chip.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BaseAppBar(
      {super.key,
      this.title,
      this.actions,
      this.centerTitle = true,
      this.leading,
      this.hasIcon = false,
      this.backgroundColor,
      this.onPressed});

  final String? title;
  final bool centerTitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool hasIcon;
  final Color? backgroundColor;
  final Function? onPressed;

  @override
  Widget build(BuildContext context) {
    final canPop = context.router.canPop();
    final foreground = backgroundColor != null
        ? context.colors.onPrimary
        : context.colors.textPrimary;

    return AppBar(
      elevation: 0,
      backgroundColor: backgroundColor ?? Colors.transparent,
      iconTheme: IconThemeData(color: foreground),
      leadingWidth: 68.w,
      leading: leading ?? (canPop ? appBarLeading(context) : null),
      centerTitle: centerTitle,
      title: hasIcon
          ? Assets.icons.eye.svg()
          : InkWell(
              onTap: () => onPressed?.call(),
              child: Text(
                title ?? '',
                style: AppText.semibold16.copyWith(color: foreground),
              ),
            ),
      actions: actions,
      scrolledUnderElevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

class AppBarIos extends StatelessWidget implements PreferredSizeWidget {
  const AppBarIos(
      {super.key,
      this.title,
      this.actions,
      this.centerTitle = true,
      this.leading,
      this.hasIcon = false,
      this.backgroundColor,
      this.onPressed});

  final String? title;
  final bool centerTitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool hasIcon;
  final Color? backgroundColor;
  final Function? onPressed;

  @override
  Widget build(BuildContext context) {
    final canPop = context.router.canPop();
    return AppBar(
      elevation: 0,
      leading: leading ?? (canPop ? appBarLeading(context) : null),
      centerTitle: centerTitle,
      title: hasIcon
          ? Assets.icons.eye.svg()
          : InkWell(
              onTap: () => onPressed?.call(),
              child: (title ?? '').w(500).s(16).c(backgroundColor != null
                  ? context.colors.onPrimary
                  : context.colors.textPrimary),
            ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(52);
}

/// The back chip — a [ControlChip] holding the rounded left arrow, inset 16
/// from the leading edge.
///
/// Deliberately *not* a `FrostedCard`: this sits on a themed page, so it has
/// to darken in dark mode. A frosted chip here would be a white square glued
/// to a dark page, with an invisible white glyph on it.
Widget appBarLeading(BuildContext context) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: EdgeInsets.only(left: 16.w),
      child: ControlChip(
        onTap: () => context.router.maybePop(),
        width: 36.w,
        height: 36.w,
        padding: EdgeInsets.zero,
        borderWidth: 1.5,
        child: Assets.icons.arrowLeftRounded.svg(
          width: 18.w,
          height: 18.w,
          colorFilter: ColorFilter.mode(
            context.colors.textPrimary,
            BlendMode.srcIn,
          ),
        ),
      ),
    ),
  );
}

Widget AppBarLeadingScreens(BuildContext context) {
  return InkWell(
    overlayColor: const WidgetStatePropertyAll(Colors.transparent),
    onTap: () {
      print("context.router.canPop() ::: ${context.router.canPop()}");
      try {
        context.router.maybePop();
      } catch (e) {
        print("error:::: $e");
      }
    },
    child: Container(
      width: 32.w,
      height: 32.h,
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 6.w),
      decoration: BoxDecoration(
        color: const Color(0XFFCAD9E2).withOpacity(0.4),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Assets.icons.arrowLeftRounded.svg(),
    ),
  );
}
