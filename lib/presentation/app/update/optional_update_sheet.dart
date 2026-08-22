import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:lumi_pass/data/service/app_update_service.dart';
import 'package:lumi_pass/data/service/remote_config_service.dart';

/// Soft nudge for a build that is behind `latest_app_version` but still above
/// the supported floor: the user can update now or carry on.
///
/// Pops `true` when the user chose to update — the caller uses that to decide
/// whether to remember a "Later" for this version.
class OptionalUpdateSheet extends StatelessWidget {
  const OptionalUpdateSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => const OptionalUpdateSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final config = RemoteConfigService.instance;
    final description = config.updateDescription;

    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 20.h),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: c.divider,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            16.kh,
            Assets.images.mascot.mascotDownload.image(
              width: 140.w,
              height: 140.w,
              fit: BoxFit.contain,
            ),
            14.kh,
            Text(
              'update_optional_title'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19.sp,
                fontWeight: FontWeight.w800,
                color: c.textPrimary,
                height: 1.25,
              ),
            ),
            8.kh,
            Text(
              description.isEmpty
                  ? 'update_optional_subtitle'.tr()
                  : description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: c.textSecondary,
                height: 1.4,
              ),
            ),
            // The version the store is on, when the console names one — makes
            // the nudge concrete rather than a vague "there is an update".
            if (config.latestAppVersion.isNotEmpty) ...[
              6.kh,
              Text(
                'update_version_label'
                    .tr(args: [config.latestAppVersion]),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: c.textMuted,
                ),
              ),
            ],
            20.kh,
            SizedBox(
              width: double.infinity,
              child: CommonButton.elevated(
                text: 'update_now'.tr(),
                onPressed: () {
                  Navigator.of(context).pop(true);
                  AppUpdateService.instance.openStore();
                },
              ),
            ),
            8.kh,
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'update_later'.tr(),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: c.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
