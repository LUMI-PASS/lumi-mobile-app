import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/utils/input_validators.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:lumi_pass/common/widget/common_text_filed.dart';
import 'package:lumi_pass/data/api_model/profile_model/profile_model.dart';
import 'package:lumi_pass/data/api_model/register/register_model.dart';
import 'package:lumi_pass/presentation/app/widgets/phone_form_field.dart';
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
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _firstNameFocusNode = FocusNode();
  final FocusNode _lastNameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();

  // Gender selection variable
  String? _selectedGender;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _passwordFocusNode.dispose();
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
                  isNext: true,
                  nextFocusNode: _passwordFocusNode,
                  focusNode: _lastNameFocusNode,
                  validator: (value) =>
                      InputValidators.required(value, "Last name"),
                  needToCapitalize: true,
                ),
                16.kh,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    "Gender".s(16).w(500),
                    8.kh,
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => context
                                .read<RegisterCubit>()
                                .changeState(false),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12.h, horizontal: 16.w),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: state.isSelected == false
                                      ? context.colors.primary
                                      : context.colors.primary.withOpacity(0.3),
                                  width: state.isSelected == false ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(8.r),
                                color: state.isSelected == false
                                    ? context.colors.primary.withOpacity(0.1)
                                    : Colors.transparent,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    state.isSelected == false
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    color: state.isSelected == false
                                        ? context.colors.primary
                                        : Colors.grey,
                                    size: 20.r,
                                  ),
                                  8.kw,
                                  const Text("Male")
                                      .s(16)
                                      .w(state.isSelected == false ? 600 : 400),
                                ],
                              ),
                            ),
                          ),
                        ),
                        12.kw,
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                context.read<RegisterCubit>().changeState(true),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12.h, horizontal: 16.w),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: state.isSelected == true
                                      ? context.colors.primary
                                      : context.colors.primary.withOpacity(0.3),
                                  width: state.isSelected == true ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(8.r),
                                color: state.isSelected == true
                                    ? context.colors.primary.withOpacity(0.1)
                                    : Colors.transparent,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    state.isSelected == true
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    color: state.isSelected == true
                                        ? context.colors.primary
                                        : Colors.grey,
                                    size: 20.r,
                                  ),
                                  8.kw,
                                  Text("Female")
                                      .s(16)
                                      .w(state.isSelected == true ? 600 : 400),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                24.kh,
                CommonButton.elevated(
                  text: "Registration",
                  backgroundColor: context.colors.primary,
                  loading: state.isLoading,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.read<RegisterCubit>().register(ProfileModel(
                            firstName: _firstNameController.text,
                            lastName: _lastNameController.text,
                            phoneNumber: phoneOrMail.startsWith("+")
                                ? phoneOrMail.replaceAll("-", "")
                                : null,
                            gender: state.isSelected ? "FEMALE" : "MALE",
                            city: "Tashkent",
                            country: "Uzbekistan",
                            password: phoneOrMail,
                            district: "Tashkent",
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
