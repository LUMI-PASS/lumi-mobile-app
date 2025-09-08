import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:lumi_pass/data/api_model/tarifff/tariff_model.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/wallet/cubit/wallet_cubit.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/wallet/cubit/wallet_state.dart';
import 'package:provider/provider.dart';

class AboutPocketBottomsheet
    extends BasePage<WalletCubit, WalletBuildable, WalletListenable> {
  const AboutPocketBottomsheet({super.key, required this.tariff});

  final Tariff tariff;

  @override
  void listener(BuildContext context, WalletListenable state) {
    if (state.effect == WalletEffect.verify) {
      Navigator.pop(context);
    }
    super.listener(context, state);
  }

  @override
  Widget builder(context, state) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        color: context.colors.window,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88.w,
                height: 2.h,
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: context.colors.grey,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(CupertinoIcons.left_chevron),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              "About this packet:".s(18).w(700)
            ],
          ),
          16.kh,
          Row(
            children: [
              "Packet “${tariff.title}”".s(20).w(700),
              Spacer(),
              "${tariff.coins}".s(20).w(700),
              Assets.icons.coinLumi.image(width: 24.w, height: 24.h),
            ],
          ),
          12.kh,
          _buildPriceCatalog(Assets.icons.dollar.svg(), "Price",
              "${tariff.price!.toString().toFormattedPrice()} SO’M", context),
          12.kh,
          _buildPriceCatalog(Assets.icons.availablitiy.svg(), "Availability",
              "${tariff.validDays} days", context),
          16.kh,
          "About Packet".s(18).w(600),
          16.kh,
          "Best Event Of all time Come Come your friends and family and have a great time. Food from local food trucks will be available for purchase."
              .s(16)
              .w(400)
              .a(TextAlign.start),
          24.kh,
          CommonButton.elevated(
            text: "Purchase",
            loading: state.isSelected,
            onPressed: () => context
                .read<WalletCubit>()
                .purchaseSubscription(tariff.id ?? ""),
          ),
          12.kh,
        ],
      ),
    );
  }

  Widget _buildPriceCatalog(
      Widget icon, String topTitle, String bottomTitle, BuildContext context) {
    return Row(
      children: [
        Container(
          width: 51.w,
          height: 51.h,
          decoration: BoxDecoration(
              color: context.colors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16.r)),
          child: Center(child: icon),
        ),
        12.kw,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            topTitle.s(12).w(600).c(context.colors.title),
            8.kh,
            bottomTitle.s(14).w(400)
          ],
        )
      ],
    );
  }
}
