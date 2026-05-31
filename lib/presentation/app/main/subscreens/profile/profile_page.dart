import 'dart:io' show Platform;

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/env/runtime_env.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/data/service/remote_config_service.dart';
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
      if (!RemoteConfigService.instance.isInReview) {
        context.router.replaceAll([LoginRoute()]);
      }
    } else if (state.effect == ProfileEffect.deleted) {
      if (RemoteConfigService.instance.isInReview) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        context.read<ProfileCubit>().load();
      } else {
        context.router.replaceAll([LoginRoute()]);
      }
    }
  }

  Future<void> _shareApp(BuildContext context) async {
    final storeUrl = Platform.isIOS
        ? 'https://apps.apple.com/uz/app/lumipass/id6761327966'
        : 'https://play.google.com/store/apps/details?id=uz.lumi.mobileapp';
    final text = '${'share_app_text'.tr()}\n$storeUrl';
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;
    await Share.share(text, subject: 'share_app'.tr(), sharePositionOrigin: origin);
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

  bool get _hasRealToken => storage.tokens.call()?.access != null;

  bool get _isReviewGuest =>
      RemoteConfigService.instance.isInReview && !_hasRealToken;

  static const _privilegedPhones = {
    '+998940286169',
    '+998920233421',
    '+998123456789',
  };

  bool _isPrivilegedPhone(String? phone) {
    if (phone == null) return false;
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    return _privilegedPhones.any(
      (p) => p.replaceAll(RegExp(r'[^\d]'), '') == digits,
    );
  }

  @override
  Widget builder(BuildContext context, ProfileBuildable state) {
    // Read locale to ensure rebuild when language changes
    context.locale;

    final primary = context.colors.primary;
    final showGuest = _isReviewGuest;
    final cubit = context.read<ProfileCubit>();
    final showBanner = cubit.showDeletedBanner;

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
                  primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showBanner)
                  _DeletedInfoBar(
                    onDismiss: () => cubit.dismissDeletedBanner(),
                  ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        32.kh,
                        if (showGuest) ...[
                          _GuestProfileHeader(
                            onLogin: () => context.router.replaceAll([LoginRoute()]),
                          ),
                        ] else ...[
                          _ProfileHeader(
                            name: greetingTitle,
                            phone: user?.phoneNumber,
                            isPremium: false,
                          ),
                        ],
                        32.kh,
                        Expanded(
                          child: RefreshIndicator(
                            color: primary,
                            onRefresh: () => context.read<ProfileCubit>().load(),
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 64.0),
                              child: Column(
                                children: [
                                  if (!showGuest) ...[
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
                                          color: primary, size: 24.w),
                                      'my_bookings'.tr(),
                                      'booked_classes_appear_here'.tr(),
                                      false,
                                      context,
                                      onTap: () => context.router.push(const MyBookingsRoute()),
                                    ),
                                    16.kh,
                                  ],
                                  _buildProfileCatalog(
                                    Icon(Icons.translate_rounded,
                                        color: primary, size: 24.w),
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
                                        color: primary, size: 24.w),
                                    'faq'.tr(),
                                    'faq_subtitle'.tr(),
                                    false,
                                    context,
                                    onTap: () {
                                      context.router.push(const FaqRoute());
                                    },
                                  ),
                                  16.kh,
                                  _buildProfileCatalog(
                                    Icon(Icons.share_rounded,
                                        color: primary, size: 24.w),
                                    'share_app'.tr(),
                                    'share_app_subtitle'.tr(),
                                    false,
                                    context,
                                    onTap: () => _shareApp(context),
                                  ),
                                  if (!showGuest) ...[
                                    16.kh,
                                    _buildProfileCatalog(
                                      Icon(Icons.logout,
                                          color: primary, size: 24.w),
                                      'log_out'.tr(),
                                      'log_out_subtitle'.tr(),
                                      true,
                                      context,
                                      onTap: () => _showLogoutSheet(context),
                                    ),
                                  ],
                                  if (!showGuest && RuntimeEnv.isSwitcherPhone(user?.phoneNumber)) ...[
                                    16.kh,
                                    _DevEnvToggleTile(
                                      onSwitch: () async {
                                        await context.read<ProfileCubit>().logout();
                                      },
                                    ),
                                  ],
                                  if (!showGuest && _isPrivilegedPhone(user?.phoneNumber)) ...[
                                    16.kh,
                                    const _FcmTokenTile(),
                                  ],
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
          ),
        ],
      ),
    );
  }

}

class _DeletedInfoBar extends StatelessWidget {
  const _DeletedInfoBar({required this.onDismiss});
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: const Color(0xFFFFF3CD),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 18.w,
            color: const Color(0xFFD97706),
          ),
          10.kw,
          Expanded(
            child: Text(
              'account_deleted_info'.tr(),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF92400E),
              ),
            ),
          ),
          8.kw,
          GestureDetector(
            onTap: onDismiss,
            child: Icon(
              Icons.close_rounded,
              size: 16.w,
              color: const Color(0xFF92400E).withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuestProfileHeader extends StatelessWidget {
  const _GuestProfileHeader({required this.onLogin});
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    return Row(
      children: [
        Container(
          width: 72.w,
          height: 72.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primary.withOpacity(0.1),
          ),
          child: Icon(Icons.person_outline_rounded,
              size: 36.sp, color: primary.withOpacity(0.5)),
        ),
        16.kw,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'my_account'.tr(),
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: context.colors.black ?? Colors.black,
                ),
              ),
              8.kh,
              GestureDetector(
                onTap: onLogin,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    'login_button'.tr(),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
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

class _FcmTokenTile extends StatefulWidget {
  const _FcmTokenTile();

  @override
  State<_FcmTokenTile> createState() => _FcmTokenTileState();
}

class _FcmTokenTileState extends State<_FcmTokenTile> {
  String? _token;
  String? _error;

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.getToken().then((t) {
      if (mounted) setState(() => _token = t);
    }).catchError((Object e) {
      if (mounted) setState(() => _error = e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    final token = _token;
    final error = _error;
    final hasError = error != null;
    final copyText = error ?? token;
    return GestureDetector(
      onTap: copyText == null
          ? null
          : () {
              Clipboard.setData(ClipboardData(text: copyText));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(hasError ? 'Error copied' : 'FCM token copied'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: hasError ? Colors.red.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: hasError ? Colors.red.shade200 : Colors.grey.shade300,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasError
                      ? Icons.error_outline
                      : Icons.notifications_active_outlined,
                  size: 15.w,
                  color: hasError ? Colors.red.shade400 : Colors.grey.shade600,
                ),
                6.kw,
                Text(
                  'FCM Token',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color:
                        hasError ? Colors.red.shade400 : Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                if (copyText != null)
                  Icon(
                    Icons.copy_outlined,
                    size: 14.w,
                    color: hasError
                        ? Colors.red.shade300
                        : Colors.grey.shade500,
                  ),
              ],
            ),
            8.kh,
            Text(
              copyText ?? '...',
              style: TextStyle(
                fontSize: 10.sp,
                color: hasError ? Colors.red.shade700 : Colors.grey.shade700,
                fontFamily: 'monospace',
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _DevEnvToggleTile extends StatefulWidget {
  const _DevEnvToggleTile({required this.onSwitch});
  final Future<void> Function() onSwitch;

  @override
  State<_DevEnvToggleTile> createState() => _DevEnvToggleTileState();
}

class _DevEnvToggleTileState extends State<_DevEnvToggleTile> {
  bool _loading = false;

  Future<void> _toggle(bool toDev) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
        title: Row(
          children: [
            Icon(Icons.swap_horiz_rounded,
                color: toDev ? Colors.orange : Colors.green, size: 24.w),
            8.kw,
            Text(
              toDev ? 'Switch to DEV' : 'Switch to PROD',
              style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          toDev
              ? 'You will be switched to the development server (dev-mobile-api.lumipass.uz) and logged out. OTP will always be 1234.'
              : 'You will be switched to the production server (mobile-api.lumipass.uz) and logged out.',
          style: TextStyle(fontSize: 14.sp, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              toDev ? 'Switch to DEV' : 'Switch to PROD',
              style: TextStyle(
                color: toDev ? Colors.orange : Colors.green,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _loading = true);
    await RuntimeEnv.setDev(toDev);
    await widget.onSwitch();
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDev = RuntimeEnv.isDev;
    final primary = context.colors.primary;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDev
            ? Colors.orange.shade50
            : Colors.green.shade50,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDev ? Colors.orange.shade200 : Colors.green.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: (isDev ? Colors.orange : Colors.green).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Icon(
                Icons.developer_mode_rounded,
                size: 24.w,
                color: isDev ? Colors.orange.shade700 : Colors.green.shade700,
              ),
            ),
          ),
          16.kw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Server Environment',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: context.colors.black ?? Colors.black,
                  ),
                ),
                4.kh,
                Text(
                  isDev ? '🟠 DEV — dev-mobile-api.lumipass.uz' : '🟢 PROD — mobile-api.lumipass.uz',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDev ? Colors.orange.shade700 : Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          _loading
              ? SizedBox(
                  width: 28.w,
                  height: 28.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isDev ? Colors.orange : Colors.green,
                  ),
                )
              : Switch.adaptive(
                  value: isDev,
                  activeColor: Colors.orange,
                  inactiveThumbColor: Colors.green.shade600,
                  inactiveTrackColor: Colors.green.shade100,
                  onChanged: _toggle,
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
