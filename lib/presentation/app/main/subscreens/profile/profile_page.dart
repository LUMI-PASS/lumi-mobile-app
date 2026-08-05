import 'dart:io' show Platform;
import 'package:lumi_pass/common/styles/app_color_scheme.dart';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/env/runtime_env.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/styles/theme_mode_notifier.dart';
import 'package:lumi_pass/common/utils/avatar_notifier.dart';
import 'package:lumi_pass/common/utils/photo_urls.dart';
import 'package:lumi_pass/common/widget/theme_transition_overlay.dart';
import 'package:lumi_pass/common/widget/user_avatar.dart';
import 'package:lumi_pass/common/widget/control_chip.dart';
import 'package:lumi_pass/data/api_model/child_model/child_model.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/service/remote_config_service.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
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

  /// The account screen owns the edit form and the delete confirmation, but
  /// not the delete itself — it pops `true` and we run it here, where the
  /// post-delete navigation lives.
  ///
  /// The parent we already hold is handed over, so the screen doesn't refetch
  /// it. `push` is left untyped on purpose: `push<bool>` makes auto_route cast
  /// the page to `AutoRoutePage<bool>` and throw.
  Future<void> _openAccountDetails(
    BuildContext context,
    ProfileCubit cubit,
    HomForUser user,
  ) async {
    final deleteRequested = await context.router.push(
      ProfileDetailRoute(user: user),
    );
    if (deleteRequested == true) {
      await cubit.deleteAccount();
    } else {
      await cubit.refreshSilently();
    }
  }

  /// Child details, in edit mode when [child] is given and add mode when it
  /// isn't. The screen saves through its own cubit, so we just refresh the
  /// children strip once it comes back.
  Future<void> _openChildDetails(
    BuildContext context,
    ProfileCubit cubit,
    ChildModel? child,
  ) async {
    await context.router.push(ChildDetailRoute(child: child));
    await cubit.refreshSilently();
  }

  Future<void> _shareApp(BuildContext context) async {
    final storeUrl = Platform.isIOS
        ? 'https://apps.apple.com/uz/app/lumipass/id6761327966'
        : 'https://play.google.com/store/apps/details?id=uz.lumi.mobileapp';
    final text = '${'share_app_text'.tr()}\n$storeUrl';
    final box = context.findRenderObject() as RenderBox?;
    final origin =
        box == null ? null : box.localToGlobal(Offset.zero) & box.size;
    await Share.share(text,
        subject: 'share_app'.tr(), sharePositionOrigin: origin);
  }

  /// The two ways to reach support, both configured in Firebase Remote Config
  /// (`support_telegram`, `support_phone`) so the numbers can change without an
  /// app release. Either row is dropped when its value is blanked in the
  /// console; the caller hides the whole entry when both are.
  void _showSupportSheet(BuildContext context) {
    final c = context.colors;
    final config = RemoteConfigService.instance;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: EdgeInsets.fromLTRB(
          24.w,
          16.h,
          24.w,
          16.h + MediaQuery.of(sheetContext).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: c.scaffoldBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: c.control,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            24.kh,
            Text(
              'contact_support'.tr(),
              style: AppText.heading20.copyWith(color: c.textPrimary),
            ),
            8.kh,
            Text(
              'support_sheet_subtitle'.tr(),
              textAlign: TextAlign.center,
              style: AppText.regular14.copyWith(color: c.textSecondary),
            ),
            20.kh,
            if (config.hasSupportTelegram) ...[
              _SupportOption(
                iconAsset: _ProfileIcons.telegram,
                title: 'support_via_telegram'.tr(),
                value: config.supportTelegramLabel,
                onTap: () => _openSupport(
                  sheetContext,
                  Uri.parse(config.supportTelegramUrl),
                ),
              ),
              12.kh,
            ],
            if (config.hasSupportPhone)
              _SupportOption(
                iconAsset: _ProfileIcons.support,
                title: 'support_via_phone'.tr(),
                value: config.supportPhone,
                onTap: () => _openSupport(
                  sheetContext,
                  // `tel:` wants the number unpunctuated.
                  Uri.parse(
                    'tel:${config.supportPhone.replaceAll(RegExp(r'[^0-9+]'), '')}',
                  ),
                ),
              ),
            8.kh,
          ],
        ),
      ),
    );
  }

  /// Closes the sheet, then hands off. Telegram's `https://t.me/...` opens the
  /// app when it is installed and the browser when it isn't, so there is no
  /// scheme to fall back from.
  Future<void> _openSupport(BuildContext context, Uri uri) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    Navigator.of(context).pop();
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
    } catch (_) {
      // No app for it (a tablet with no dialer, say) — reported below.
    }
    messenger?.showSnackBar(
      SnackBar(content: Text('support_open_failed'.tr())),
    );
  }

  void _showLogoutSheet(BuildContext context) {
    final c = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 16.h),
        decoration: BoxDecoration(
          color: c.scaffoldBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: c.control,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            24.kh,
            Assets.icons.icLogout.svg(width: 48.w, height: 48.w),
            16.kh,
            Text(
              'log_out'.tr(),
              style: AppText.heading20.copyWith(color: c.textPrimary),
            ),
            8.kh,
            Text(
              'log_out_subtitle'.tr(),
              textAlign: TextAlign.center,
              style: AppText.regular14.copyWith(color: c.textSecondary),
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
                        color: c.surface,
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      child: Center(
                        child: Text(
                          'cancel'.tr(),
                          style:
                              AppText.medium16.copyWith(color: c.textPrimary),
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
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      child: Center(
                        child: Text(
                          'log_out'.tr(),
                          style: AppText.medium16.copyWith(color: Colors.white),
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
    // Read locale to ensure rebuild when language changes.
    context.locale;

    final showGuest = _isReviewGuest;
    final cubit = context.read<ProfileCubit>();
    final showBanner = cubit.showDeletedBanner;

    final user = state.user;
    final fullName = [user?.firstName, user?.lastName]
        .where((s) => s != null && s.isNotEmpty)
        .join(' ')
        .trim();
    final displayName = fullName.isNotEmpty ? fullName : 'my_account'.tr();

    // Rebuild the whole screen the instant the theme toggle flips, instead of
    // relying only on MediaQuery.platformBrightness propagating down the tab.
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, _, __) {
        final c = context.colors;
        return _buildScaffold(
            context, state, c, showGuest, cubit, showBanner, displayName, user);
      },
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    ProfileBuildable state,
    AppColorScheme c,
    bool showGuest,
    ProfileCubit cubit,
    bool showBanner,
    String displayName,
    HomForUser? user,
  ) {
    return Scaffold(
      backgroundColor: c.scaffoldBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showBanner)
              _DeletedInfoBar(onDismiss: () => cubit.dismissDeletedBanner()),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
              child: Text(
                'profile_title'.tr(),
                style: AppText.heading20.copyWith(color: c.textPrimary),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.brandPurple,
                onRefresh: () => context.read<ProfileCubit>().load(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    16.w,
                    4.h,
                    16.w,
                    24.h + 64.0 + MediaQuery.of(context).viewPadding.bottom,
                  ),
                  children: [
                    if (showGuest)
                      _GuestProfileHeader(
                        onLogin: () =>
                            context.router.replaceAll([LoginRoute()]),
                      )
                    else
                      _ProfileHeaderCard(
                        name: displayName,
                        phone: user?.phoneNumber,
                        onEdit: user == null
                            ? null
                            : () => _openAccountDetails(context, cubit, user),
                      ),
                    if (!showGuest) ...[
                      20.kh,
                      _SectionLabel('my_children'.tr()),
                      12.kh,
                      _ChildrenSection(
                        children: state.children,
                        onEdit: (child) =>
                            _openChildDetails(context, cubit, child),
                        onAdd: () => _openChildDetails(context, cubit, null),
                      ),
                    ],
                    20.kh,
                    _SectionLabel('settings_title'.tr()),
                    12.kh,
                    if (!showGuest) ...[
                      _MenuRow(
                        iconAsset: _ProfileIcons.bookings,
                        label: 'my_bookings'.tr(),
                        onTap: () =>
                            context.router.push(const MyBookingsRoute()),
                      ),
                      8.kh,
                    ],
                    const _ThemeToggleRow(),
                    8.kh,
                    _MenuRow(
                      iconAsset: _ProfileIcons.language,
                      label: 'select_language'.tr(),
                      trailingValue: context.locale.languageCode.toUpperCase(),
                      onTap: () =>
                          context.router.push(const ChangeLanguageRoute()),
                    ),
                    8.kh,
                    _MenuRow(
                      iconAsset: _ProfileIcons.faq,
                      label: 'faq'.tr(),
                      onTap: () => context.router.push(const FaqRoute()),
                    ),
                    // Hidden outright when the console has blanked both
                    // contacts — a support row that opens an empty sheet is
                    // worse than no row.
                    if (RemoteConfigService.instance.hasSupportTelegram ||
                        RemoteConfigService.instance.hasSupportPhone) ...[
                      8.kh,
                      _MenuRow(
                        iconAsset: _ProfileIcons.support,
                        label: 'contact_support'.tr(),
                        onTap: () => _showSupportSheet(context),
                      ),
                    ],
                    8.kh,
                    _MenuRow(
                      iconAsset: _ProfileIcons.share,
                      label: 'share_app'.tr(),
                      onTap: () => _shareApp(context),
                    ),
                    if (!showGuest) ...[
                      8.kh,
                      _MenuRow(
                        iconAsset: _ProfileIcons.logout,
                        label: 'logout_account'.tr(),
                        danger: true,
                        onTap: () => _showLogoutSheet(context),
                      ),
                    ],
                    if (!showGuest &&
                        RuntimeEnv.isSwitcherPhone(user?.phoneNumber)) ...[
                      12.kh,
                      _DevEnvToggleTile(
                        onSwitch: () async {
                          await context.read<ProfileCubit>().logout();
                        },
                      ),
                    ],
                    if (!showGuest &&
                        _isPrivilegedPhone(user?.phoneNumber)) ...[
                      12.kh,
                      const _FcmTokenTile(),
                    ],
                    16.kh,
                    const _VersionLabel(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 18/Semibold muted section header ("Мои дети", "Настройки").
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppText.bold18.copyWith(color: context.colors.textSecondary),
    );
  }
}

/// Rounded header pill: avatar + name/phone + "Edit" button (Figma 96-6472).
class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({
    required this.name,
    required this.phone,
    required this.onEdit,
  });

  final String name;
  final String? phone;

  /// Null until the parent has loaded — there is nothing to edit yet.
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: EdgeInsets.fromLTRB(8.w, 8.h, 16.w, 8.h),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(40.r),
      ),
      child: Row(
        children: [
          ValueListenableBuilder<String?>(
            valueListenable: parentAvatarNotifier,
            builder: (_, __, ___) => UserAvatar(
              file: parentAvatarFile(),
              size: 56,
            ),
          ),
          12.kw,
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.semibold16.copyWith(color: c.textPrimary),
                ),
                if (phone != null && phone!.isNotEmpty) ...[
                  2.kh,
                  Text(
                    phone!,
                    style: AppText.medium12.copyWith(color: c.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          8.kw,
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onEdit,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: c.control,
                borderRadius: BorderRadius.circular(40.r),
              ),
              child: Text(
                'edit_profile'.tr(),
                style: AppText.medium12.copyWith(color: c.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal "Мои дети" strip — child avatars followed by an add-child slot.
class _ChildrenSection extends StatelessWidget {
  const _ChildrenSection({
    required this.children,
    required this.onEdit,
    required this.onAdd,
  });

  final List<ChildModel> children;
  final ValueChanged<ChildModel> onEdit;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          for (final child in children)
            Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: _ChildChip(child: child, onTap: () => onEdit(child)),
            ),
          _AddChildChip(onTap: onAdd),
        ],
      ),
    );
  }
}

class _ChildChip extends StatelessWidget {
  const _ChildChip({required this.child, required this.onTap});

  final ChildModel child;
  final VoidCallback onTap;

  String get _initial {
    final f = child.firstName;
    return (f != null && f.isNotEmpty) ? f[0].toUpperCase() : '?';
  }

  Widget get _initialText => Text(
        _initial,
        style: AppText.semibold16.copyWith(color: AppColors.brandPurple),
      );

  /// The uploaded photo, when the child has one — the endpoint 404s otherwise.
  String? get _photoUrl => (child.id != null && child.hasPhoto == true)
      ? childPhotoUrl(child.id!)
      : null;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 72.w,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  alignment: Alignment.center,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.brandPurple.withOpacity(0.12),
                  ),
                  child: _photoUrl != null
                      ? Image.network(
                          _photoUrl!,
                          width: 48.w,
                          height: 48.w,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _initialText,
                        )
                      : _initialText,
                ),
                Positioned(
                  right: -2.w,
                  bottom: -2.w,
                  child: _EditBadge(onTap: onTap),
                ),
              ],
            ),
            6.kh,
            Text(
              child.firstName ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.medium12.copyWith(color: c.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

/// The pencil badge hanging off a child avatar — opens that child's details.
class _EditBadge extends StatelessWidget {
  const _EditBadge({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ControlChip(
      onTap: onTap,
      width: 22.w,
      height: 22.w,
      padding: EdgeInsets.zero,
      borderWidth: 1.5,
      child: Assets.icons.profile.icEdit.svg(
        width: 12.w,
        height: 12.w,
        colorFilter: ColorFilter.mode(
          context.colors.textSecondary,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

class _AddChildChip extends StatelessWidget {
  const _AddChildChip({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 72.w,
        child: Column(
          children: [
            DottedCircle(
              size: 48.w,
              color: c.controlBorder,
              child:
                  Icon(Icons.add_rounded, size: 22.sp, color: c.textSecondary),
            ),
            6.kh,
            Text(
              'add_child_short'.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.medium12.copyWith(color: c.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// A circle with a dashed border, used for the add-child affordance.
class DottedCircle extends StatelessWidget {
  const DottedCircle({
    super.key,
    required this.size,
    required this.color,
    required this.child,
  });

  final double size;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedCirclePainter(color),
      child: SizedBox(
        width: size,
        height: size,
        child: Center(child: child),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final radius = size.width / 2;
    final center = Offset(radius, radius);
    const dashCount = 28;
    const gap = 0.35; // fraction of each segment left empty
    final sweep = (2 * 3.1415926 / dashCount);
    for (var i = 0; i < dashCount; i++) {
      final start = i * sweep;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep * (1 - gap),
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// A settings list pill: gradient-tinted icon badge + label + trailing
/// (value/chevron, or a custom widget such as a switch). [danger] paints the
/// label red for destructive rows (logout).
/// Figma (node 96-1829) Iconsax glyphs used by the profile settings rows.
class _ProfileIcons {
  static final bookings = Assets.icons.detail.iconsaxAiCalendar;
  static final language = Assets.icons.detail.iconsaxLanguageCircle;
  static final faq = Assets.icons.detail.iconsaxQuestionMark;
  static final share = Assets.icons.detail.iconsaxCircleShare;
  static final support = Assets.icons.call;
  static final telegram = Assets.icons.telegram;
  static final logout = Assets.icons.icLogout;
}

/// One way to reach support inside [_showSupportSheet] — the brand glyph, what
/// it does, and the contact itself under it.
class _SupportOption extends StatelessWidget {
  const _SupportOption({
    required this.iconAsset,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final SvgGenImage iconAsset;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(40.r),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brandPurple.withOpacity(0.12),
              ),
              child: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (rect) =>
                    AppGradients.brand.createShader(rect),
                child: iconAsset.svg(width: 20.sp, height: 20.sp),
              ),
            ),
            12.kw,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.semibold14.copyWith(color: c.textPrimary),
                  ),
                  2.kh,
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.regular12.copyWith(color: c.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 20.sp, color: c.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    this.icon,
    this.iconAsset,
    required this.label,
    this.trailingValue,
    this.trailing,
    this.danger = false,
    this.onTap,
  }) : assert(icon != null || iconAsset != null);

  /// Material fallback glyph (used by rows without a Figma asset, e.g. theme).
  final IconData? icon;

  /// Iconsax SVG asset. Tinted with the brand gradient, or red when [danger].
  final SvgGenImage? iconAsset;
  final String label;
  final String? trailingValue;
  final Widget? trailing;
  final bool danger;
  final VoidCallback? onTap;

  /// Renders the row glyph: a Material icon, or an Iconsax SVG tinted with the
  /// brand gradient (or solid red for destructive rows, matching Figma).
  Widget _rowIcon(Color accent) {
    if (iconAsset == null) {
      return Icon(icon, size: 20.sp, color: accent);
    }
    final svg = iconAsset!.svg(
      width: 20.sp,
      height: 20.sp,
      colorFilter: danger
          ? const ColorFilter.mode(AppColors.error, BlendMode.srcIn)
          : null,
    );
    if (danger) return svg;
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (rect) => AppGradients.brand.createShader(rect),
      child: svg,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final accent = danger ? AppColors.error : AppColors.brandPurple;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(40.r),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withOpacity(0.12),
              ),
              child: _rowIcon(accent),
            ),
            12.kw,
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.semibold14.copyWith(
                  color: danger ? AppColors.error : c.textPrimary,
                ),
              ),
            ),
            if (trailing != null)
              trailing!
            else ...[
              if (trailingValue != null) ...[
                Text(
                  trailingValue!,
                  style: AppText.regular14.copyWith(color: c.textSecondary),
                ),
                6.kw,
              ],
              Icon(Icons.chevron_right_rounded,
                  size: 20.sp, color: c.textSecondary),
              8.kw,
            ],
          ],
        ),
      ),
    );
  }
}

/// Dark-theme toggle, styled as a settings pill with an inline switch.
/// Persists via [setThemeMode]; the app root applies it everywhere.
///
/// The circular reveal grows out of the switch, so the switch carries a
/// [GlobalKey] — its own box is the origin. A `Builder` here would hand back
/// the whole row instead, putting the origin at the row's centre.
class _ThemeToggleRow extends StatefulWidget {
  const _ThemeToggleRow();

  @override
  State<_ThemeToggleRow> createState() => _ThemeToggleRowState();
}

class _ThemeToggleRowState extends State<_ThemeToggleRow> {
  final _switchKey = GlobalKey();

  /// Snapshots the screen, flips the theme, then reveals it in a circle
  /// centred on the switch. Falls back to an instant switch when the overlay
  /// or the render box isn't there.
  void _toggle(bool isDark) {
    void flip() => setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);

    final overlay = ThemeTransitionOverlay.maybeOf(context);
    final box = _switchKey.currentContext?.findRenderObject() as RenderBox?;
    if (overlay == null || box == null) {
      flip();
      return;
    }

    overlay.toggleTheme(
      position: box.localToGlobal(box.size.center(Offset.zero)),
      isDarkening: isDark,
      onToggle: flip,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        final isDark =
            resolveBrightness(mode, MediaQuery.platformBrightnessOf(context)) ==
                Brightness.dark;
        return _MenuRow(
          icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          label: 'dark_mode'.tr(),
          onTap: () => _toggle(isDark),
          trailing: Switch.adaptive(
            key: _switchKey,
            value: isDark,
            activeColor: AppColors.brandPurple,
            onChanged: (_) => _toggle(isDark),
          ),
        );
      },
    );
  }
}

/// "Версия приложения: x.y.z" line at the bottom of the profile.
class _VersionLabel extends StatelessWidget {
  const _VersionLabel();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snap) {
        final v = snap.hasData ? snap.data!.version : '';
        if (v.isEmpty) return const SizedBox.shrink();
        return Center(
          child: Text(
            '${'app_version'.tr()}: $v',
            style: AppText.medium12.copyWith(color: c.textSecondary),
          ),
        );
      },
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
    final c = context.colors;
    return Container(
      padding: EdgeInsets.fromLTRB(8.w, 8.h, 16.w, 8.h),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(40.r),
      ),
      child: Row(
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.brandPurple.withOpacity(0.12),
            ),
            child: Icon(Icons.person_outline_rounded,
                size: 28.sp, color: AppColors.brandPurple),
          ),
          12.kw,
          Expanded(
            child: Text(
              'my_account'.tr(),
              style: AppText.semibold16.copyWith(color: c.textPrimary),
            ),
          ),
          8.kw,
          GestureDetector(
            onTap: onLogin,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                gradient: AppGradients.brand,
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Text(
                'login_button'.tr(),
                style: AppText.medium14.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
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
                    color:
                        hasError ? Colors.red.shade300 : Colors.grey.shade500,
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDev ? Colors.orange.shade50 : Colors.green.shade50,
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
                    color: context.colors.textPrimary,
                  ),
                ),
                4.kh,
                Text(
                  isDev
                      ? '🟠 DEV — dev-mobile-api.lumipass.uz'
                      : '🟢 PROD — mobile-api.lumipass.uz',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color:
                        isDev ? Colors.orange.shade700 : Colors.green.shade700,
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
