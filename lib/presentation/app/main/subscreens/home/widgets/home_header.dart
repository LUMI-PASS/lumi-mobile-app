import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/utils/avatar_notifier.dart';
import 'package:lumi_pass/common/widget/user_avatar.dart';
import 'package:lumi_pass/domain/repo/notifications/notifications_api.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_icons.dart';
import 'package:lumi_pass/common/widget/new_coin_price.dart';
import 'package:lumi_pass/common/widget/coin_amount.dart';

/// Home top bar — avatar + greeting with the notification bell on the right,
/// and a tappable search field underneath (Figma `User bar`). The field is a
/// button, not an input: tapping it opens the search screen, which owns the
/// real `TextField`.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.name,
    required this.onSearchTap,
    required this.onProfileTap,
  });

  final String name;
  final VoidCallback onSearchTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onProfileTap,
                  child: Row(
                    children: [
                      ValueListenableBuilder<String?>(
                        valueListenable: parentAvatarNotifier,
                        builder: (_, __, ___) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: c.controlBorder),
                          ),
                          child: UserAvatar(
                            file: parentAvatarFile(),
                            size: 40,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(16.r),
                            background: c.control,
                            iconColor: c.textSecondary,
                          ),
                        ),
                      ),
                      8.horizontalSpace,
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${'greeting'.tr()},',
                              style: AppText.regular13
                                  .copyWith(color: AppColors.greeting),
                            ),
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.semibold16
                                  .copyWith(color: c.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              8.horizontalSpace,
              const _NewCoinsButton(),
              const _NotificationButton(),
            ],
          ),
          8.verticalSpace,
          _SearchFieldButton(onTap: onSearchTap),
        ],
      ),
    );
  }
}

/// Looks like the search screen's field, behaves like a button.
class _SearchFieldButton extends StatelessWidget {
  const _SearchFieldButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 40.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: c.controlBorder),
        ),
        child: Row(
          children: [
            HomeIcon(Assets.icons.home.search,
                size: 16, color: c.textPlaceholder),
            8.horizontalSpace,
            Expanded(
              child: Text(
                'search_hint'.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.regular14.copyWith(color: c.textPlaceholder),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Square icon button on the `control` surface (Figma right-side avatars).
class _ControlButton extends StatelessWidget {
  const _ControlButton({required this.icon, required this.onTap});

  final SvgGenImage icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: c.control,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: c.controlBorder),
        ),
        child: HomeIcon(icon, size: 16, color: c.textPrimary),
      ),
    );
  }
}

/// The Lumi Coin balance, one tap from the shelf — sized and tinted as the
/// bell beside it so the two read as one row of controls.
///
/// Renders nothing (not even its gap) while the feature is not live for this
/// user: no pack on sale and no coins held.
class _NewCoinsButton extends StatelessWidget {
  const _NewCoinsButton();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final coins = watchNewCoins(context);
    if (!coins.isVisible) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.router.push(NewCoinsRoute()),
        child: Container(
          // The bell is an 8-padded 16 glyph; the same box height here.
          height: 34.w,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: c.control,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: c.controlBorder),
          ),
          child: CoinAmount(
            amount: coins.balance,
            style: AppText.semibold14,
            color: c.textPrimary,
            iconSize: 16,
          ),
        ),
      ),
    );
  }
}

class _NotificationButton extends StatefulWidget {
  const _NotificationButton();

  @override
  State<_NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<_NotificationButton> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchCount();
  }

  Future<void> _fetchCount() async {
    try {
      final count = await getIt<NotificationsApi>().getUnreadCount();
      if (mounted) setState(() => _unreadCount = count);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _ControlButton(
          icon: Assets.icons.home.notification,
          onTap: () async {
            await context.router.push(const NotificationsRoute());
            _fetchCount();
          },
        ),
        if (_unreadCount > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: EdgeInsets.all(2.r),
              constraints: BoxConstraints(minWidth: 16.w, minHeight: 16.w),
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
                border: Border.all(color: c.scaffoldBg, width: 1.5),
              ),
              child: Text(
                _unreadCount > 99 ? '99+' : '$_unreadCount',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8.sp,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
