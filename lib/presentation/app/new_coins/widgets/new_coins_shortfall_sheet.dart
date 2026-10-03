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

/// What the buyer chose on the shortfall sheet.
enum NewCoinsShortfallAction {
  /// Buy exactly the missing coins as loose ones.
  buyMissing,

  /// Open the Lumi Coin screen to pick a pack.
  openStore,
}

/// "You are N coins short" — shown when a booking costs more coins than the
/// buyer holds, whether the app worked that out or the server answered
/// `insufficient_new_coins`.
///
/// Offers the two ways to fix it and resolves to the one picked, or null when
/// the buyer backs out. [canBuySingle] gates the first: loose coins are sold
/// only on top of a live monthly pack, and offering a purchase the server
/// would refuse is worse than not offering it.
Future<NewCoinsShortfallAction?> showNewCoinsShortfallSheet(
  BuildContext context, {
  required NewCoinShortfall shortfall,
  required bool canBuySingle,
  required num singleCoinPrice,
}) {
  return showModalBottomSheet<NewCoinsShortfallAction>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.8),
    builder: (_) => _ShortfallSheet(
      shortfall: shortfall,
      canBuySingle: canBuySingle,
      singleCoinPrice: singleCoinPrice,
    ),
  );
}

class _ShortfallSheet extends StatelessWidget {
  const _ShortfallSheet({
    required this.shortfall,
    required this.canBuySingle,
    required this.singleCoinPrice,
  });

  final NewCoinShortfall shortfall;
  final bool canBuySingle;
  final num singleCoinPrice;

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
          if (canBuySingle && missing > 0) ...[
            GradientButton(
              text: 'new_coins_shortfall_buy_missing'.tr(args: [
                missing.toGrouped(),
                (singleCoinPrice * missing).toRawUzsPrice(),
              ]),
              onPressed: () =>
                  Navigator.of(context).pop(NewCoinsShortfallAction.buyMissing),
            ),
            8.kh,
          ],
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () =>
                Navigator.of(context).pop(NewCoinsShortfallAction.openStore),
            child: Container(
              height: 50.h,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(44.r),
              ),
              child: Text(
                'new_coins_shortfall_open_store'.tr(),
                style: AppText.medium16.copyWith(color: c.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
