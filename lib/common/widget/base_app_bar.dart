import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    return AppBar(
      elevation: 0,
      iconTheme: IconThemeData(
          color: backgroundColor != null
              ? context.colors.onPrimary
              : context.colors.label),
      leading: leading ?? (canPop ? appBarLeading(context) : null),
      centerTitle: centerTitle,
      title: hasIcon
          ? Assets.icons.eye.svg()
          : InkWell(
              onTap: () => onPressed?.call(),
              child: (title ?? '').w(600).s(16).c(context.colors.label),
            ),
      backgroundColor: backgroundColor ?? context.colors.window,
      actions: actions,
      scrolledUnderElevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(52);
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
                  : context.colors.label),
            ),
      backgroundColor: context.colors.window,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(52);
}

Widget appBarLeading(BuildContext context) {
  return InkWell(
    overlayColor: const WidgetStatePropertyAll(Colors.transparent),
    onTap: () => context.router.maybePop(),
    child: Container(
      // width: 32.w,
      // height: 32.h,
      margin: EdgeInsets.only(left: 14.w, bottom: 4.h, top: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: const Color(0XFFCAD9E2).withOpacity(0.4),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Assets.icons.arrowLeft.svg(),
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
      child: Assets.icons.arrowLeft.svg(),
    ),
  );
}
