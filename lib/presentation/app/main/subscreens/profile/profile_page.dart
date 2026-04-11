import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/common/widget/container_3d.dart';
import 'package:lumi_pass/common/widget/language_bottom_sheet.dart';
import 'package:lumi_pass/presentation/app/widgets/base_box.dart';

import '../../../../../common/router/app_router.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Storage storage = getIt<Storage>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Force rebuild when locale changes
    context.locale;
  }

  void _showLogoutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            24.kh,
            Icon(Icons.logout_rounded, size: 48.w, color: Colors.red.shade400),
            16.kh,
            Text(
              'log_out'.tr(),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
            8.kh,
            Text(
              'log_out_subtitle'.tr(),
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade500,
              ),
            ),
            24.kh,
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Center(
                        child: Text(
                          'cancel'.tr(),
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                12.kw,
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      await storage.logout();
                      if (context.mounted) {
                        context.router.replaceAll([LoginRoute()]);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(
                        color: Colors.red.shade500,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Center(
                        child: Text(
                          'log_out'.tr(),
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 8.h),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Read locale to ensure rebuild when language changes
    context.locale;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -20,
            right: -40,
            child: Opacity(
              opacity: 0.15,
              child: Assets.icons.background.registrationMisc.svg(
                width: 240.w,
                height: 240.w,
                colorFilter: ColorFilter.mode(
                  context.colors.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              32.kh,
              'my_account'.tr().s(32).w(700).c(context.colors.black ?? Colors.black),
              32.kh,
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildProfileCatalog(
                        Assets.icons.profile.svg(),
                        'account_info'.tr(),
                        'change_account_info'.tr(),
                        false,
                        context,
                        onTap: () => context.router.push(ProfileDetailRoute()),
                      ),
                      16.kh,
                      _buildProfileCatalog(
                        Assets.icons.group.svg(),
                        'your_children'.tr(),
                        'change_children_info'.tr(),
                        false,
                        context,
                        onTap: () => context.router.push(const ChildrenRoute()),
                      ),
                      16.kh,
                      _buildProfileCatalog(
                        Assets.icons.attendence.svg(),
                        'attendance_history'.tr(),
                        'view_attendance'.tr(),
                        false,
                        context,
                        onTap: () {
                          context.router.push(const AttendanceHistoryRoute());
                        },
                      ),
                      16.kh,

                      _buildProfileCatalog(
                        Icon(Icons.translate_rounded,
                            color: context.colors.primary, size: 24.w),
                        'select_language'.tr(),
                        context.locale.languageCode.toUpperCase(),
                        false,
                        context,
                        onTap: () => showLanguageBottomSheet(
                          context,
                          onChanged: () => setState(() {}),
                        ),
                      ),
                      16.kh,
                      _buildProfileCatalog(
                        Icon(Icons.help_outline,
                            color: context.colors.primary, size: 24.w),
                        'faq'.tr(),
                        'faq_subtitle'.tr(),
                        false,
                        context,
                        onTap: () {
                          context.router.push(const FaqRoute());
                        },
                      ),
                      16.kh,

                      // Log out
                      _buildProfileCatalog(
                        Icon(Icons.logout,
                            color: context.colors.primary, size: 24.w),
                        'log_out'.tr(),
                        'log_out_subtitle'.tr(),
                        true,
                        context,
                        onTap: () => _showLogoutSheet(context),
                      ),
                    ],
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
}

Widget _buildProfileCatalog(Widget icon, String title, String subtitle,
    bool isLast, BuildContext context,
    {Function? onTap, bool? isLoading}) {
  return Container3d(
    padding: EdgeInsets.all(16.w),
    backgroundColor: Colors.white,
    borderColor: Colors.grey.shade200,
    borderRadius: BorderRadius.circular(16.r),
    depth: 3,
    onTap: () => onTap?.call(),
    child: Row(
      children: [
        Container(
          width: 48.w,
          height: 48.h,
          decoration: BoxDecoration(
            color: (context.colors.primary ?? Colors.purple).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(child: icon),
        ),
        16.kw,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title.s(16).w(600).c(context.colors.black ?? Colors.black),
              4.kh,
              subtitle
                  .s(14)
                  .w(400)
                  .c(context.colors.title.withOpacity(0.6) ?? Colors.grey),
            ],
          ),
        ),
        8.kw,
        isLoading ?? false
            ? SizedBox(
                width: 20.w,
                height: 20.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.colors.primary,
                ),
              )
            : Icon(
                Icons.arrow_forward_ios,
                size: 16.w,
                color: context.colors.black.withOpacity(0.4) ?? Colors.grey,
              ),
      ],
    ),
  );
}
