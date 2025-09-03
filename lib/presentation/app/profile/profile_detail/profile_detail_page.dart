import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
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
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/presentation/app/profile/profile_detail/cubit/profile_detail_cubit.dart';
import 'package:lumi_pass/presentation/app/widgets/bottom_box.dart';

import 'cubit/profile_detail_state.dart';

@RoutePage()
class ProfileDetailPage extends BasePage<ProfileDetailCubit,
    ProfileDetailBuildable, ProfileDetailListenable> {
  ProfileDetailPage({super.key});

  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController phoneController;
  late final TextEditingController cityController;
  late final TextEditingController districtController;
  late final TextEditingController streetController;

  @override
  void init(BuildContext context) {
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    phoneController = TextEditingController();
    cityController = TextEditingController();
    districtController = TextEditingController();
    streetController = TextEditingController();

    context.read<ProfileDetailCubit>().getProfileDetail();
  }

  @override
  void listener(BuildContext context, ProfileDetailListenable state) {
    if (state.effect == ProfileDetailEffect.verify) {
      context.router.pop();
    }
    super.listener(context, state);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    cityController.dispose();
    districtController.dispose();
    streetController.dispose();
    super.dispose();
  }

  void _populateFields(HomForUser? homeModel) {
    if (homeModel != null) {
      firstNameController.text = homeModel.firstName ?? '';
      lastNameController.text = homeModel.lastName ?? '';
      phoneController.text =
          (homeModel.phoneNumber ?? '').replaceAll("+998", "");
      cityController.text = homeModel.city ?? '';
      districtController.text = homeModel.district ?? '';
    }
  }

  @override
  Widget builder(context, state) {
    if (state.homeModel != null && !state.isLoading) {
      _populateFields(state.homeModel);
    }

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
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          "First name".s(15).w(600),
                          8.kh,
                          CommonTextField(
                            controller: firstNameController,
                            background: context.colors.onPrimary,
                            hint: "Enter first name",
                          ),
                          12.kh,
                          "Last name".s(15).w(600),
                          8.kh,
                          CommonTextField(
                            controller: lastNameController,
                            background: context.colors.onPrimary,
                            hint: "Enter last name",
                          ),
                          12.kh,
                          "Phone number".s(15).w(600),
                          8.kh,
                          CommonTextField(
                            controller: phoneController,
                            background: context.colors.onPrimary,
                            hint: "12-345-67-89",
                            prefixIcon: "+998 |".s(15).w(600),
                            mask: "##-###-##-##",
                            enabled: false,
                          ),
                          12.kh,
                          "City".s(15).w(600),
                          8.kh,
                          CommonTextField(
                            controller: cityController,
                            background: context.colors.onPrimary,
                            hint: "Tashkent",
                          ),
                          12.kh,
                          "District".s(15).w(600),
                          8.kh,
                          CommonTextField(
                            controller: districtController,
                            background: context.colors.onPrimary,
                            hint: "Qoraqamish",
                          ),
                          // 12.kh,
                          // "Street name".s(15).w(600),
                          // 8.kh,
                          // CommonTextField(
                          //   controller: streetController,
                          //   background: context.colors.onPrimary,
                          //   hint: "Labzak, 23",
                          // ),
                        ],
                      ),
                    ),
                  ),
                  BottomBox(
                    child: CommonButton.elevated(
                      text: "Save Changes",
                      backgroundColor: context.colors.primary,
                      loading: state.success,
                      onPressed: () =>
                          _saveChanges(context, state.homeModel?.id ?? ""),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _saveChanges(BuildContext context, String id) {
    context.read<ProfileDetailCubit>().updateProfile(HomForUser(
          id: id,
          firstName: firstNameController.text,
          lastName: lastNameController.text,
          phoneNumber: phoneController.text,
          city: cityController.text,
          district: districtController.text,
          // Consider adding street if it's part of the profile update
          // street: streetController.text,
        ));
  }
}
