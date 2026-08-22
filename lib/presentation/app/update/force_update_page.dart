import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:lumi_pass/data/service/app_update_service.dart';
import 'package:lumi_pass/data/service/remote_config_service.dart';

/// Blocking gate for a build below the `min_supported_version` floor.
///
/// Shown as an opaque root-navigator overlay rather than a route, so it covers
/// whatever the app had already navigated to and cannot be escaped: the
/// barrier does not dismiss, there is no close affordance, and the system back
/// button is swallowed by [PopScope].
class ForceUpdatePage extends StatelessWidget {
  const ForceUpdatePage({super.key});

  static Future<void> show(BuildContext context) {
    return showGeneralDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      barrierLabel: 'force_update',
      // Opaque: nothing of the app behind should show through — this reads as
      // a page, not as a dialog over a page the user might still get back to.
      barrierColor: context.colors.scaffoldBg,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => const ForceUpdatePage(),
      transitionBuilder: (_, animation, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // The console can override the body copy ("what's new", a deadline, an
    // apology); blank falls back to the shipped translation.
    final description = RemoteConfigService.instance.updateDescription;

    return PopScope(
      // Mandatory update: the back gesture must not get the user out of here.
      canPop: false,
      child: Material(
        color: c.scaffoldBg,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Column(
              children: [
                const Spacer(),
                Assets.images.mascot.mascotDownload.image(
                  width: 200.w,
                  height: 200.w,
                  fit: BoxFit.contain,
                ),
                24.kh,
                Text(
                  'update_force_title'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: c.textPrimary,
                    height: 1.25,
                  ),
                ),
                10.kh,
                Text(
                  description.isEmpty
                      ? 'update_force_subtitle'.tr()
                      : description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: c.textSecondary,
                    height: 1.4,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: CommonButton.elevated(
                    text: 'update_now'.tr(),
                    onPressed: AppUpdateService.instance.openStore,
                  ),
                ),
                8.kh,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
