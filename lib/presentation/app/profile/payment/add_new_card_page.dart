import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:lumi_pass/common/widget/common_text_filed.dart';
import 'package:lumi_pass/presentation/app/widgets/bottom_box.dart';
import 'package:lumi_pass/presentation/app/widgets/card_widget.dart';

@RoutePage()
class AddNewCardPage extends StatelessWidget {
  const AddNewCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BaseAppBar(
        title: "Add New Card",
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardWidget(),
          48.kh,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                "Enter Information".s(25).w(600),
                25.kh,
                "Card Number".s(14).w(500).c(context.colors.label),
                10.kh,
                CommonTextField(
                  hint: "0000 0000 0000 0000",
                  suffix: Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Assets.icons.mastercard.svg(),
                  ),
                ),
                15.kh,
                "Card Holder".s(14).w(500).c(context.colors.label),
                10.kh,
                const CommonTextField(
                  hint: "Enter Card Holder Name",
                ),
                15.kh,
                Row(
                  spacing: 24,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        "Expiration Date".s(14).w(500).c(context.colors.label),
                        10.kh,
                        Row(
                          spacing: 10,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: context.colors.grey.withValues(alpha: 0.2),
                              ),
                              child: Row(
                                spacing: 50,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  "0".s(14).w(500).c(const Color(0xFF717680)),
                                  const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 20,
                                    color: Color(0xFF717680),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: context.colors.grey.withValues(alpha: 0.2),
                              ),
                              child: Row(
                                spacing: 50,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  "0".s(14).w(500).c(const Color(0xFF717680)),
                                  const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 20,
                                    color: Color(0xFF717680),
                                  )
                                ],
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        "CVC".s(14).w(500).c(context.colors.label),
                        10.kh,
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: context.colors.grey.withValues(alpha: 0.2),
                          ),
                          child: Row(
                            spacing: 50,
                            children: [
                              "0".s(14).w(500).c(const Color(0xFF717680)),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 20,
                                color: Color(0xFF717680),
                              )
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
          const Spacer(),
          BottomBox(
            child: CommonButton.elevated(
              onPressed: () => context.router.push(
                const CheckoutRoute(),
              ),
              text: "Add Card",
              textColor: Theme.of(context).cardColor,
            ),
          ),
        ],
      ),
    );
  }
}
