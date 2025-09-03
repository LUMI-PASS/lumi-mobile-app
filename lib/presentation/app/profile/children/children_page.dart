import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/subwidgets/child_widget.dart';
import 'package:lumi_pass/presentation/app/profile/children/cubit/children_cubit.dart';
import 'package:lumi_pass/presentation/app/profile/children/cubit/children_state.dart';
import 'package:lumi_pass/presentation/app/widgets/bottom_box.dart';

@RoutePage()
class ChildrenPage
    extends BasePage<ChildrenCubit, ChildrenBuildable, ChildrenListenable> {
  const ChildrenPage({super.key});

  @override
  void init(BuildContext context) {
    context.read<ChildrenCubit>().getChildren();
    super.init(context);
  }

  @override
  Widget builder(context, state) {
    return Scaffold(
      appBar: BaseAppBar(
        title: "My children",
      ),
      body: Column(
        children: [
          Expanded(child: ListView.builder(itemBuilder: (context, index) {
            return ChildWidget(
                isSelected: state.selectedIndex == index, onTap: () {});
          })),
          BottomBox(child: CommonButton.outlined(text: "Add child"))
        ],
      ),
    );
  }
}
