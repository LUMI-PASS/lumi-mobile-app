import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/navigation_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:lumi_pass/common/widget/loading_view.dart';
import 'package:lumi_pass/data/api_model/child_model/child_model.dart';
import 'package:lumi_pass/data/api_model/tarifff/tariff_model.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/subwidgets/child_widget.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/subwidgets/not_enough_coin_content.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/subwidgets/pocket_widget.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/widgets/get_ticket_bottomsheet.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/wallet/cubit/wallet_state.dart';
import 'package:lumi_pass/presentation/app/profile/children/cubit/children_cubit.dart';
import 'package:lumi_pass/presentation/app/profile/children/cubit/children_state.dart';

import '../../../main/subscreens/wallet/cubit/wallet_cubit.dart';
import 'about_pocket_bottomsheet.dart';

class ChooseChildBottomsheet
    extends BasePage<ChildrenCubit, ChildrenBuildable, ChildrenListenable> {
  bool hasEnoughCoin = true;
  int selectedChildIndex = 0;
  int selectedTariffIndex = -1; // -1 means no tariff selected
  Tariff? selectedTariff;

  ChooseChildBottomsheet({super.key, this.classId});

  final String? classId;

  @override
  void init(BuildContext context) {
    if (hasEnoughCoin) {
      context.read<ChildrenCubit>().getChildren();
    }
    super.init(context);
  }

  void _onTariffSelected(Tariff tariff, int index) {
    setState(() {
      selectedTariff = tariff;
      selectedTariffIndex = index;
    });
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
              ? state.isLoading
                  ? LoadingView()
                  : Column(
                      children: List.generate(
                        (state.childrenList ?? []).length,
                        (index) => ChildWidget(
                          childModel: (state.childrenList ?? [])[index],
                          isSelected: state.selectedIndex == index,
                          onTap: () =>
                              context.read<ChildrenCubit>().selectIndex(index),
                        ),
                      ),
                    )
              : NotEnoughCoinContent(
                  onTariffSelected: _onTariffSelected,
                  selectedIndex: state.selectedIndex,
                ),
          48.kh,
          CommonButton.elevated(
            text: "Next",
            onPressed: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return hasEnoughCoin
                      ? GetTicketBottomsheet(
                          childId:
                              (state.childrenList ?? [])[state.selectedIndex]
                                  .id,
                          classId: classId,
                        )
                      : AboutPocketBottomsheet(
                          tariff: selectedTariff ?? Tariff(),
                        );
                },
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
              );
            },
          ),
          12.kh,
        ],
      ),
    );
  }
}
