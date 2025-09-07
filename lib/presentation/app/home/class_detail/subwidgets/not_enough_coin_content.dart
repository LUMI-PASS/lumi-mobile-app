import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/data/api_model/tarifff/tariff_model.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/subwidgets/pocket_widget.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/wallet/cubit/wallet_cubit.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/wallet/cubit/wallet_state.dart';

class NotEnoughCoinContent
    extends BasePage<WalletCubit, WalletBuildable, WalletListenable> {
  final Function(Tariff, int)? onTariffSelected;
  final int? selectedIndex;

  const NotEnoughCoinContent({
    super.key,
    this.onTariffSelected,
    this.selectedIndex,
  });

  @override
  void init(BuildContext context) {
    context.read<WalletCubit>().getWallet();
    super.init(context);
  }

  @override
  Widget builder(context, state) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: (state.tariffs ?? []).length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final tariff = (state.tariffs ?? [])[index];
        return PocketWidget(
          tariff: tariff,
          isSelected: selectedIndex == index,
          onTap: () {
            onTariffSelected?.call(tariff, index);
          },
        );
      },
    );
  }
}