import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/auth/gradient_button.dart';
import 'package:lumi_pass/data/api_model/new_coins/new_coin_models.dart';

/// "You are N coins short" — shown when a booking costs more coins than the
/// buyer holds, whether the app worked that out or the server answered
/// `insufficient_new_coins`.
///
/// One way to fix it: choose a pack. Coins are not sold one by one — the
/// buyer always buys a whole pack, and the Lumi Coin screen shows only the
/// packs big enough for the gap. Resolves to true when "Choose a pack" was
/// tapped, null when the buyer backs out.
Future<bool?> showNewCoinsShortfallSheet(
  BuildContext context, {
  required NewCoinShortfall shortfall,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.8),
    builder: (_) => _ShortfallSheet(shortfall: shortfall),
  );
}

class _ShortfallSheet extends StatelessWidget {
  const _ShortfallSheet({required this.shortfall});

  final NewCoinShortfall shortfall;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final missing = shortfall.missing;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        14.w,
        12.h,
        14.w,
        MediaQuery.of(context).viewPadding.bottom + 24.h,
      ),
      decoration: BoxDecoration(
        color: c.scaffoldBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pull handle.
          Container(
            width: 32.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.inkMuted.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          12.kh,
          Assets.icons.coinLumi.image(
            width: 48.w,
            height: 48.w,
            excludeFromSemantics: true,
          ),
          8.kh,
          Text(
            'new_coins_shortfall_title'.tr(args: [missing.toGrouped()]),
            textAlign: TextAlign.center,
            style: AppText.semibold18.copyWith(color: c.textPrimary),
          ),
          8.kh,
          Text(
            'new_coins_shortfall_body'.tr(args: [
              shortfall.required.toGrouped(),
              shortfall.available.toGrouped(),
            ]),
            textAlign: TextAlign.center,
            style: AppText.regular14.copyWith(color: c.textSecondary),
          ),
          24.kh,
          GradientButton(
            text: 'new_coins_shortfall_open_store'.tr(),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }
}
