import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/common/widget/container_3d.dart';
import 'package:lumi_pass/common/widget/language_bottom_sheet.dart';
import 'package:lumi_pass/presentation/app/profile/profile_detail/profile_detail_bottomsheet.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/profile/cubit/profile_cubit.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/profile/cubit/profile_state.dart';

import '../../../../../common/router/app_router.dart';

@RoutePage()
class ProfilePage
    extends BasePage<ProfileCubit, ProfileBuildable, ProfileListenable> {
  ProfilePage({super.key});

  final Storage storage = getIt<Storage>();

  @override
  void init(BuildContext context) {
    context.read<ProfileCubit>().load();
    super.init(context);
  }

  @override
  void onFocusGained(BuildContext context) {
    context.read<ProfileCubit>().refreshSilently();
    super.onFocusGained(context);
  }

  @override
  void listener(BuildContext context, ProfileListenable state) {
    if (state.effect == ProfileEffect.login) {
      context.router.replaceAll([LoginRoute()]);
    }
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
                      await context.read<ProfileCubit>().logout();
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
  Widget builder(BuildContext context, ProfileBuildable state) {
    // Read locale to ensure rebuild when language changes
    context.locale;

    final user = state.user;
    final fullName = [user?.firstName, user?.lastName]
        .where((s) => s != null && s.isNotEmpty)
        .join(' ')
        .trim();
    final greetingTitle = fullName.isNotEmpty ? fullName : 'my_account'.tr();
    final childrenCount = state.children.length;
    final childrenSubtitle = childrenCount > 0
        ? '$childrenCount ${'children'.tr()}'
        : 'change_children_info'.tr();

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
              _ProfileHeader(
                name: greetingTitle,
                phone: user?.phoneNumber,
                isPremium: storage.hasPremium() == true,
              ),
              32.kh,
              Expanded(
                child: RefreshIndicator(
                  color: context.colors.primary,
                  onRefresh: () => context.read<ProfileCubit>().load(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                      if (storage.hasPremium() != true)
                        _buildPremiumCTABanner(context),
                      if (storage.hasPremium() != true) 12.kh,
                      _buildStatsGrid(context),
                      16.kh,
                      _buildProfileCatalog(
                        Assets.icons.profile.svg(),
                        'account_info'.tr(),
                        'change_account_info'.tr(),
                        false,
                        context,
                        onTap: () => ProfileDetailBottomsheet.show(context),
                      ),
                      16.kh,
                      _buildProfileCatalog(
                        Assets.icons.group.svg(),
                        'your_children'.tr(),
                        childrenSubtitle,
                        false,
                        context,
                        onTap: () => context.router.push(const ChildrenRoute()),
                      ),
                      16.kh,
                      _buildProfileCatalog(
                        Icon(Icons.receipt_long_rounded,
                            color: context.colors.primary, size: 24.w),
                        'my_bookings'.tr(),
                        'booked_classes_appear_here'.tr(),
                        false,
                        context,
                        onTap: () =>
                            context.router.push(const MyBookingsRoute()),
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
              ),
            ],
          ),
        ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final stats = [
      ('12', 'tashrif'),
      ('8', 'chipta'),
      ('235k', 'tejov'),
    ];
    return Row(
      children: stats.map((s) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A6C4EF2),
                  blurRadius: 24,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  s.$1,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF4A2FD4),
                    height: 1,
                  ),
                ),
                4.kh,
                Text(
                  s.$2,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B6899),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

Widget _buildPremiumCTABanner(BuildContext context) {
  return GestureDetector(
    onTap: () => context.router.push(const PlansRoute()),
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB830), Color(0xFFFF8A30)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8A30).withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: const Center(
              child: Icon(Icons.workspace_premium_rounded,
                  color: Colors.white, size: 24),
            ),
          ),
          12.kw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Premium'ga o'tish",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '30% chegirma · 7 kun bepul',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white),
        ],
      ),
    ),
  );
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.phone,
    required this.isPremium,
  });

  final String name;
  final String? phone;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 72.w,
          height: 72.w,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isPremium
                          ? [const Color(0xFFFFD56A), const Color(0xFFFF8A65)]
                          : [
                              primary.withOpacity(0.22),
                              const Color(0xFFFF7093).withOpacity(0.22),
                            ],
                    ),
                    boxShadow: isPremium
                        ? [
                            BoxShadow(
                              color:
                                  const Color(0xFFFF8A65).withOpacity(0.45),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    size: 36.sp,
                    color: isPremium ? Colors.white : primary,
                  ),
                ),
              ),
              if (isPremium)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFFFD56A), Color(0xFFFF8A65)],
                        ),
                      ),
                      child: Icon(
                        Icons.workspace_premium_rounded,
                        size: 14.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        14.kw,
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isPremium) ...[
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD56A), Color(0xFFFF8A65)],
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.workspace_premium_rounded,
                          size: 12.sp, color: Colors.white),
                      4.kw,
                      Text(
                        'premium_badge'.tr().toUpperCase(),
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                6.kh,
              ],
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: context.colors.black ?? Colors.black,
                  height: 1.15,
                ),
              ),
              if (phone != null && phone!.isNotEmpty) ...[
                4.kh,
                Text(
                  phone!,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: (context.colors.title ?? Colors.grey)
                        .withOpacity(0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

Widget _buildProfileCatalog(Widget icon, String title, String subtitle,
    bool isLast, BuildContext context,
    {Function? onTap, bool? isLoading}) {
  return Container3d(
    padding: EdgeInsets.all(16.w),
    backgroundColor: Colors.white,
    borderColor: const Color(0xFFE8E4F6),
    borderRadius: BorderRadius.circular(18.r),
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
