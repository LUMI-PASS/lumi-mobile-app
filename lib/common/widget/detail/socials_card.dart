import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/detail/detail_card.dart';
import 'package:lumi_pass/data/api_model/socials/centre_socials.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_icons.dart';
import 'package:url_launcher/url_launcher.dart';

/// The centre's own accounts — Instagram, Telegram, website — as a detail
/// card, shared by the activity and the branch page so a catalogue centre
/// reads the same on both.
///
/// Only a CATALOGUE centre has any: a venue Lumi listed from a public
/// directory, with no contract behind it, nothing on it to book and so no
/// Book button on its pages (see `is_catalog`). These rows are what a parent
/// is given instead, which is why the card carries [hint] — a page with no
/// call to action and no word about why is just a dead end.
class CentreSocialsCard extends StatelessWidget {
  const CentreSocialsCard({
    super.key,
    required this.c,
    required this.socials,
    this.hint,
  });

  final AppColorScheme c;
  final CentreSocials socials;

  /// One line above the rows, saying why there is nothing to book here. Null
  /// leaves it out.
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final links = socials.openable;
    // Nothing openable — a centre whose only account is a value we cannot
    // resolve. An empty card is worse than no card.
    if (links.isEmpty) return const SizedBox.shrink();

    return DetailCard(
      c: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailCardHeader(
            c: c,
            icon: Assets.icons.social.website,
            iconGradient: AppGradients.brand,
            title: 'detail_socials'.tr(),
          ),
          if (hint != null && hint!.isNotEmpty) ...[
            10.verticalSpace,
            Text(
              hint!,
              style: AppText.regular13.copyWith(color: c.textSecondary),
            ),
          ],
          14.verticalSpace,
          ...List.generate(links.length, (i) {
            return Padding(
              padding: EdgeInsets.only(bottom: i == links.length - 1 ? 0 : 8.h),
              child: _SocialRow(c: c, link: links[i]),
            );
          }),
        ],
      ),
    );
  }
}

/// One tappable account row — the same pill the venue's phone numbers use.
class _SocialRow extends StatelessWidget {
  const _SocialRow({required this.c, required this.link});

  final AppColorScheme c;
  final SocialLink link;

  /// The glyph for a network. Telegram's already exists at the top of the icon
  /// set (the sign-in screen uses it), so it is reused rather than duplicated
  /// into `icons/social/`. An unmodelled network gets the globe — it is a link
  /// and nothing more is known about it.
  SvgGenImage get _icon {
    switch (link.network) {
      case SocialNetwork.instagram:
        return Assets.icons.social.instagram;
      case SocialNetwork.telegram:
        return Assets.icons.telegram;
      case SocialNetwork.facebook:
        return Assets.icons.social.facebook;
      case SocialNetwork.youtube:
        return Assets.icons.social.youtube;
      case SocialNetwork.tiktok:
        return Assets.icons.social.tiktok;
      case SocialNetwork.website:
      case SocialNetwork.unknown:
        return Assets.icons.social.website;
    }
  }

  /// Opens the account in the network's own app when it is installed, and in
  /// the browser otherwise — which is what `externalApplication` resolves to.
  ///
  /// Silent on failure, like the venue phone row: a link that will not open is
  /// not worth a snackbar, and the value came from a directory crawl rather
  /// than from us.
  Future<void> _open() async {
    final url = link.url;
    if (url == null) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _open,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: c.control,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            HomeIcon(_icon, size: 18, color: AppColors.brandPurple),
            10.horizontalSpace,
            Expanded(
              child: Text(
                link.label,
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
