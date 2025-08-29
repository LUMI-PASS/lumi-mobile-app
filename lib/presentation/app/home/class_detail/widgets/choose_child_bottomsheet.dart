import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/navigation_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/subwidgets/child_widget.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/subwidgets/not_enough_coin_content.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/subwidgets/pocket_widget.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/widgets/get_ticket_bottomsheet.dart';

import 'about_pocket_bottomsheet.dart';

class ChooseChildBottomsheet extends StatefulWidget {
  const ChooseChildBottomsheet({super.key});

  @override
  State<ChooseChildBottomsheet> createState() => _ChooseChildBottomsheetState();
}

class _ChooseChildBottomsheetState extends State<ChooseChildBottomsheet> {
  bool hasEnoughCoin = true;
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
            children: [
              "YOUR BALANCE:".s(18).w(600).c(context.colors.primary),
              Spacer(),
              (hasEnoughCoin ? "50" : "0")
                  .s(18)
                  .w(600)
                  .c(context.colors.primary),
              Assets.icons.coinLumi.image(width: 24.w, height: 24.h),
            ],
          ),
          16.kh,
          (hasEnoughCoin
                  ? "Choose your child: "
                  : "You do not have enough coins. Purchase in one click!")
              .s(15)
              .w(700),
          12.kh,
          hasEnoughCoin
              ? Column(
                  children: List.generate(
                      4,
                      (index) => ChildWidget(
                            isSelected: selectedIndex == index,
                            onTap: () => setState(() {
                              selectedIndex = index;
                            }),
                          )))
              : NotEnoughCoinContent(),
          48.kh,
          CommonButton.elevated(
            text: "Next",
            onPressed: () {
              Navigator.pop(context);
              showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return hasEnoughCoin
                        ? const GetTicketBottomsheet()
                        : const AboutPocketBottomsheet();
                  },
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true);
            },
          ),
          12.kh,
        ],
      ),
    );
  }
}
