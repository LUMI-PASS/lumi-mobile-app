import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/detail/detail_card.dart';
import 'package:lumi_pass/data/service/remote_config_service.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_icons.dart';
import 'package:url_launcher/url_launcher.dart';

/// Lumi's own support — Telegram and phone — as a detail card, shared by the
/// activity, branch and booking pages so a parent with a problem finds us
/// without going back to the profile tab.
///
/// The same two contacts as the profile's support sheet, read from Remote
/// Config (`support_telegram`, `support_phone`): either row is dropped when
/// the console blanks it, and the whole card when both are.
class SupportContactCard extends StatelessWidget {
  const SupportContactCard({super.key, required this.c});

  final AppColorScheme c;

  /// Whether the card has anything to show — callers use it to drop the gap
  /// they put above it along with the card.
  static bool get isAvailable =>
      RemoteConfigService.instance.hasSupportTelegram ||
      RemoteConfigService.instance.hasSupportPhone;

  /// Telegram's `https://t.me/...` opens the app when it is installed and the
  /// browser when it isn't. Unlike a centre's own links, this one is ours, so
  /// a failure to open it is worth saying.
  Future<void> _open(BuildContext context, Uri uri) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
    } catch (_) {
      // No app for it (a tablet with no dialer, say) — reported below.
    }
    messenger?.showSnackBar(
      SnackBar(content: Text('support_open_failed'.tr())),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isAvailable) return const SizedBox.shrink();
    final config = RemoteConfigService.instance;

    return DetailCard(
      c: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailCardHeader(
            c: c,
            icon: Assets.icons.detail.iconsaxHeadphone,
            iconGradient: AppGradients.brand,
            title: 'detail_support'.tr(),
          ),
          10.verticalSpace,
          Text(
            'detail_support_hint'.tr(),
            style: AppText.regular13.copyWith(color: c.textSecondary),
          ),
          14.verticalSpace,
          if (config.hasSupportTelegram)
            _SupportRow(
              c: c,
              icon: HomeIcon(Assets.icons.telegram,
                  size: 18, color: AppColors.brandPurple),
              label: config.supportTelegramLabel,
              onTap: () =>
                  _open(context, Uri.parse(config.supportTelegramUrl)),
            ),
          if (config.hasSupportTelegram && config.hasSupportPhone)
            8.verticalSpace,
          if (config.hasSupportPhone)
            _SupportRow(
              c: c,
              icon: Icon(Icons.call_rounded,
                  size: 18.w, color: AppColors.brandPurple),
              label: config.supportPhone,
              onTap: () => _open(
                context,
                // `tel:` wants the number unpunctuated.
                Uri.parse(
                  'tel:${config.supportPhone.replaceAll(RegExp(r'[^0-9+]'), '')}',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One tappable contact — the same pill the centre's phones and accounts use.
class _SupportRow extends StatelessWidget {
  const _SupportRow({
    required this.c,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final AppColorScheme c;
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: c.control,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            icon,
            10.horizontalSpace,
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.medium14.copyWith(color: c.textPrimary),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20.w,
              color: c.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
