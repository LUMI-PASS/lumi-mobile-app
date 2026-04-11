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
        horizontal: 20.w,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        color: context.colors.window,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),

          // Header
          Row(
            children: [
              IconButton(
                icon: const Icon(CupertinoIcons.left_chevron),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: "About this packet".s(20).w(700).a(TextAlign.center),
              ),
              SizedBox(width: 48.w),
            ],
          ),
          20.kh,

          // Package title + coins badge
          Row(
            children: [
              Expanded(
                child: "${tariff.title}".s(20).w(700).c(context.colors.primary),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: context.colors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    "${tariff.coins}".s(16).w(700).c(context.colors.primary),
                    4.kw,
                    Assets.icons.coinLumi.image(width: 24.w, height: 24.h),
                  ],
                ),
              ),
            ],
          ),
          20.kh,

          // Price card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: context.colors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Assets.icons.dollar.svg(width: 20.w, height: 20.h),
                      ),
                      12.kw,
                      "Price".s(16).w(600),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      "Price:".s(14).w(500),
                      "${(tariff.price ?? 0).toString().toFormattedPrice()} so'm"
                          .s(14)
                          .w(700)
                          .c(context.colors.primary),
                    ],
                  ),
                ),
              ],
            ),
          ),
          12.kh,

          // Availability card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: context.colors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Assets.icons.availablitiy.svg(width: 20.w, height: 20.h),
                      ),
                      12.kw,
                      "Availability".s(16).w(600),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      "Valid for:".s(14).w(500),
                      "${tariff.validDays} days"
                          .s(14)
                          .w(700)
                          .c(context.colors.primary),
                    ],
                  ),
                ),
              ],
            ),
          ),
          24.kh,

          // Purchase button
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
}
