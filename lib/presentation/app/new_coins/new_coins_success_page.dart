import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/new_coin_price.dart';
import 'package:lumi_pass/presentation/app/cubit/app_cubit.dart';

/// "The coins are yours."
///
/// Says what was just bought and what the balance now is, and gets out of the
/// way: one button, back to wherever the buyer came from — the shelf, or the
/// booking that was a top-up short of being paid.
class NewCoinsSuccessPage extends StatelessWidget {
  const NewCoinsSuccessPage({super.key, required this.coins});

  /// How many coins the purchase was for. A first monthly pack may add a bonus
  /// on top, which is why the balance below is read live rather than summed.
  final int coins;

  @override
  Widget build(BuildContext context) {
    // The balance was re-synced before this screen opened; watching it means a
    // credit that lands a moment late still shows up without a reload.
    context.watch<AppCubit>();
    final balance = readNewCoins(context).balance;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.brand),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
            child: Column(
              children: [
                const Spacer(),
                Assets.images.paymentSuccess.image(width: 180.w),
                24.kh,
                Text(
                  'new_coins_success_title'.tr(),
                  textAlign: TextAlign.center,
                  style: AppText.heading20.copyWith(color: AppColors.onBrand),
                ),
                12.kh,
                Text(
                  'new_coins_success_body'.tr(args: [coins.toGrouped()]),
                  textAlign: TextAlign.center,
                  style: AppText.regular14.copyWith(
                    color: AppColors.onBrand.withValues(alpha: 0.92),
                    height: 1.5,
                  ),
                ),
                if (balance > 0) ...[
                  8.kh,
                  Text(
                    'new_coins_balance_line'.tr(args: [balance.toGrouped()]),
                    textAlign: TextAlign.center,
                    style:
                        AppText.semibold14.copyWith(color: AppColors.onBrand),
                  ),
                ],
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    height: 52.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.onBrand,
                      borderRadius: BorderRadius.circular(44.r),
                    ),
                    child: Text(
                      'new_coins_success_cta'.tr(),
                      style: AppText.semibold16.copyWith(
                        color: AppColors.brandPurple,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
