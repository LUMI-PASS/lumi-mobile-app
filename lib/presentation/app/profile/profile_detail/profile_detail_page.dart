import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:lumi_pass/common/widget/common_text_filed.dart';
import 'package:lumi_pass/common/widget/loading_view.dart';
import 'package:lumi_pass/presentation/app/profile/profile_detail/cubit/profile_detail_cubit.dart';

import 'cubit/profile_detail_state.dart';

@RoutePage()
class ProfileDetailPage
    extends BasePage<ProfileDetailCubit, ProfileDetailBuildable, ProfileDetailListenable> {
  const ProfileDetailPage({super.key});

  @override
  void init(BuildContext context) {
    context.read<ProfileDetailCubit>().getProfileDetail();
  }

  @override
  Widget builder(context, state) {
    return Scaffold(
      appBar: BaseAppBar(
        title: "Account Information",
      ),
      body: state.isLoading
          ? LoadingView()
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        "Full name".s(15).w(600),
                        8.kh,
                        CommonTextField(
                          background: context.colors.onPrimary,
                          hint: "John Doe",
                        ),
                        12.kh,
                        "Phone number".s(15).w(600),
                        8.kh,
                        CommonTextField(
                          background: context.colors.onPrimary,
                          hint: "12-345-67-89",
                          prefixIcon: " +998  ".s(15).w(600),
                        ),
                        12.kh,
                        "City".s(15).w(600),
                        8.kh,
                        CommonTextField(
                          background: context.colors.onPrimary,
                          hint: "Tashkent",
                        ),
                        12.kh,
                        "District".s(15).w(600),
                        8.kh,
                        CommonTextField(
                          background: context.colors.onPrimary,
                          hint: "Qoraqamish",
                        ),
                        "Street name".s(15).w(600),
                        8.kh,
                        CommonTextField(
                          background: context.colors.onPrimary,
                          hint: "Labzak, 23",
                        ),
                      ],
                    ),
                  ),
                  CommonButton.elevated(
                    text: "Save Changes",
                    backgroundColor: context.colors.primary,
                  )
                ],
              ),
            ),
    );
  }
}
