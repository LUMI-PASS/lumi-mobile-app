import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:lumi_pass/common/widget/common_text_filed.dart';
import 'package:lumi_pass/data/api_model/child_model/child_model.dart';
import 'package:lumi_pass/presentation/app/widgets/base_box.dart';
import 'package:lumi_pass/presentation/app/widgets/bottom_box.dart';

import 'cubit/children_cubit.dart';
import 'cubit/children_state.dart';

@RoutePage()
class AddChildPage extends BasePage<ChildrenCubit, ChildrenBuildable, ChildrenListenable> {
  final ChildModel? childModel;

  const AddChildPage({super.key, required this.childModel});

  @override
  Widget builder(context, state) {
    return Scaffold(
      appBar: BaseAppBar(
        title: childModel != null ? "Update child" : "Add child",
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  "Full Name".s(15).w(600),
                  12.kh,
                  CommonTextField(
                    hint: "Joseph Ren",
                    disabledBorderColor: context.colors.primary,
                    enabledBorderColor: context.colors.primary,
                    onChanged: (value) {},
                    prefixIcon: BaseBox(
                      width: 32,
                      height: 32,
                      radius: 10,
                      padding: const EdgeInsets.all(4),
                      backgroundColor: context.colors.primary,
                      child: Assets.icons.profilee.svg(),
                    ),
                  ),
                  "Phone number".s(15).w(600),
                  12.kh,
                  CommonTextField(
                    disabledBorderColor: context.colors.primary,
                    enabledBorderColor: context.colors.primary,
                    hint: "+998900000909",
                    prefixIcon: BaseBox(
                      width: 32,
                      height: 32,
                      radius: 10,
                      padding: const EdgeInsets.all(4),
                      backgroundColor: context.colors.primary,
                      child: Assets.icons.call.svg(),
                    ),
                    onChanged: (value) {},
                  ),
                  "Gender".s(15).w(600),
                  12.kh,
                  CommonTextField(
                    disabledBorderColor: context.colors.primary,
                    enabledBorderColor: context.colors.primary,
                    hint: "Helicopter",
                    onChanged: (value) {},
                  ),
                  "Location".s(15).w(600),
                  12.kh,
                  CommonTextField(
                    enabledBorderColor: context.colors.primary,
                    disabledBorderColor: context.colors.primary,
                    hint: "Yakkasaroy st., Tashkent city",
                    onChanged: (value) {},
                    prefixIcon: BaseBox(
                      width: 32,
                      height: 32,
                      radius: 10,
                      padding: const EdgeInsets.all(4),
                      backgroundColor: context.colors.primary,
                      child: Assets.icons.location.svg(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          BottomBox(
            child: CommonButton.elevated(
              loading: state.buttonLoading,
              onPressed: () {
                context.read<ChildrenCubit>().submit(childModel!, false);
              },
              text: childModel != null ? "Update child" : "Add child",
            ),
          )
        ],
      ),
    );
  }
}
