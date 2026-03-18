import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/constants/constants.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/utils/input_validators.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:lumi_pass/common/widget/common_text_filed.dart';
import 'package:lumi_pass/data/api_model/profile_model/profile_model.dart';
import 'package:lumi_pass/presentation/auth/register/cubit/register_cubit.dart';
import 'package:lumi_pass/presentation/auth/register/cubit/register_state.dart';
import 'package:lumi_pass/presentation/auth/verify/verify_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

@RoutePage()
class RegisterPage
    extends BasePage<RegisterCubit, RegisterBuildable, RegisterListenable> {
  RegisterPage({super.key, required this.phoneOrMail});

  final String phoneOrMail;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final FocusNode _firstNameFocusNode = FocusNode();
  final FocusNode _lastNameFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    super.dispose();
  }

  @override
  void listener(BuildContext context, RegisterListenable state) {
    if (state.effect == RegisterEffect.main) {
      context.router.replaceAll([
        VerifyRoute(
            verifyStatus: VerifyStatus.REGISTER, phoneOrEmail: phoneOrMail)
      ]);
    }
    super.listener(context, state);
  }

  @override
  Widget builder(context, state) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: MediaQuery.of(context).viewPadding.top),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                24.kh,
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Assets.images.congrats.image(width: 123.w, height: 123.h),
                  ],
                ),
                12.kh,
                "Create your \n Account".s(26).w(600),
                12.kh,
                CommonTextField(
                  autofocus: true,
                  focusNode: _firstNameFocusNode,
                  controller: _firstNameController,
                  hint: "First name",
                  validator: (value) =>
                      InputValidators.required(value, "First name"),
                  isNext: true,
                  needToCapitalize: true,
                  nextFocusNode: _lastNameFocusNode,
                ),
                16.kh,
                CommonTextField(
                  controller: _lastNameController,
                  hint: "Last name",
                  focusNode: _lastNameFocusNode,
                  validator: (value) =>
                      InputValidators.required(value, "Last name"),
                  needToCapitalize: true,
                ),
                16.kh,
                // Phone number (read-only)
                CommonTextField(
                  hint: "Phone number",
                  enabled: false,
                  initialValue: phoneOrMail,
                ),
                16.kh,
                // Gender selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    "Gender".s(16).w(500),
                    8.kh,
                    Row(
                      children: [
                        Expanded(
                          child: _GenderOption(
                            label: "Male",
                            isSelected: state.isSelected == false,
                            onTap: () => context
                                .read<RegisterCubit>()
                                .changeState(false),
                          ),
                        ),
                        12.kw,
                        Expanded(
                          child: _GenderOption(
                            label: "Female",
                            isSelected: state.isSelected == true,
                            onTap: () => context
                                .read<RegisterCubit>()
                                .changeState(true),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                16.kh,
                // District dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    "District".s(16).w(500),
                    8.kh,
                    Container(
                      height: 56.h,
                      decoration: BoxDecoration(
                        color: context.colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: context.colors.grey),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: state.selectedDistrict,
                          hint: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: "Select district".s(15).w(400).c(
                                const Color(0xFF717680)),
                          ),
                          isExpanded: true,
                          icon: Padding(
                            padding: EdgeInsets.only(right: 16.w),
                            child: Icon(Icons.keyboard_arrow_down,
                                color: context.colors.grey),
                          ),
                          items: Constants.tashkentDistricts
                              .map((district) => DropdownMenuItem<String>(
                                    value: district,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.w),
                                      child: district.s(15).w(400),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) => context
                              .read<RegisterCubit>()
                              .selectDistrict(value),
                        ),
                      ),
                    ),
                  ],
                ),
                24.kh,
                CommonButton.elevated(
                  text: "Registration",
                  backgroundColor: context.colors.primary,
                  loading: state.isLoading,
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        state.selectedDistrict != null) {
                      context.read<RegisterCubit>().register(ProfileModel(
                            firstName: _firstNameController.text,
                            lastName: _lastNameController.text,
                            phoneNumber: phoneOrMail.startsWith("+")
                                ? phoneOrMail.replaceAll("-", "")
                                : null,
                            gender: state.isSelected ? "FEMALE" : "MALE",
                            city: "Tashkent",
                            country: "Uzbekistan",
                            district: state.selectedDistrict,
                          ));
                    }
                  },
                ),
                24.kh,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  const _GenderOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? context.colors.primary
                : context.colors.primary.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8.r),
          color: isSelected
              ? context.colors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? context.colors.primary : Colors.grey,
              size: 20.r,
            ),
            SizedBox(width: 8.w),
            Text(label).s(16).w(isSelected ? 600 : 400),
          ],
        ),
      ),
    );
  }
}
