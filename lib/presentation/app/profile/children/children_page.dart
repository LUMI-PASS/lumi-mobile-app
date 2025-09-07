import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:lumi_pass/common/widget/loading_view.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/subwidgets/child_widget.dart';
import 'package:lumi_pass/presentation/app/profile/children/cubit/children_cubit.dart';
import 'package:lumi_pass/presentation/app/profile/children/cubit/children_state.dart';
import 'package:lumi_pass/presentation/app/widgets/bottom_box.dart';
import 'package:lumi_pass/presentation/app/widgets/empty_view.dart';

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
  void onFocusGained(BuildContext context) {
    context.read<ChildrenCubit>().getChildren();
    super.onFocusGained(context);
  }

  @override
  Widget builder(context, state) {
    return RefreshIndicator(
      onRefresh: () => context.read<ChildrenCubit>().getChildren(),
      child: Scaffold(
        appBar: const BaseAppBar(
          title: "My children",
        ),
        body: state.isLoading
            ? const LoadingView()
            : Column(
                children: [
                  (state.childrenList ?? []).isEmpty
                      ? const Expanded(
                          child: EmptyView(
                            text: "No children found",
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (context, index) {
                            return ChildWidget(
                                childModel: (state.childrenList ?? [])[index],
                                isSelected: state.selectedIndex == index,
                                onTap: () {});
                          },
                          itemCount: (state.childrenList ?? []).length,
                        )),
                  BottomBox(
                    child: CommonButton.outlined(
                      onPressed: () => context.router.push(
                        AddChildRoute(childModel: null, parentId: null),
                      ),
                      text: "Add child",
                      textColor: context.colors.primary,
                    ),
                  )
                ],
              ),
      ),
    );
  }
}

int? getAge(String? dob) {
  if (dob == null) return null;
  try {
    final birthDate = DateTime.parse(dob);
    final now = DateTime.now();

    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  } catch (_) {
    return null;
  }
}
