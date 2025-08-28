import 'package:auto_route/auto_route.dart';
import 'package:flexobo/common/base/base_page.dart';
import 'package:flexobo/common/extensions/sizedbox_extensions.dart';
import 'package:flexobo/common/extensions/text_extensions.dart';
import 'package:flexobo/common/extensions/theme_extensions.dart';
import 'package:flexobo/common/gen/assets.gen.dart';
import 'package:flexobo/common/gen/strings.dart';
import 'package:flexobo/common/router/app_router.dart';
import 'package:flexobo/common/utils/input_validators.dart';
import 'package:flexobo/common/widget/base_app_bar.dart';
import 'package:flexobo/common/widget/common_button.dart';
import 'package:flexobo/common/widget/common_text_filed.dart';
import 'package:flexobo/data/api_model/register/register_model.dart';
import 'package:flexobo/presentation/app/widgets/phone_form_field.dart';
import 'package:flexobo/presentation/auth/register/cubit/register_cubit.dart';
import 'package:flexobo/presentation/auth/register/cubit/register_state.dart';
import 'package:flexobo/presentation/auth/verify/verify_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

@RoutePage()
class RegisterPage
    extends BasePage<RegisterCubit, RegisterBuildable, RegisterListenable> {
  RegisterPage({super.key, required this.phoneOrMail});

  final String phoneOrMail;

  final TextEditingController _passwordControllerController =
      TextEditingController();
  final TextEditingController _resetPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _resetPasswordFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _passwordControllerController.clear();
    _resetPasswordController.clear();
    _nameController.clear();
    super.dispose();
  }

  @override
  void listener(BuildContext context, RegisterListenable state) {
    if (state.effect == RegisterEffect.main) {
      context.router.replaceAll([const MainRoute()]);
    }
    super.listener(context, state);
  }

  @override
  Widget builder(context, state) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 1.sh * 0.4,
              child: Stack(
                children: [
                  Positioned(
                    top: (-110).h,
                    left: 0,
                    right: 0,
                    child: Assets.images.pattern
                        .image(width: 1.sw, fit: BoxFit.cover, height: 480.h),
                  ),
                  Positioned(
                    top: 200.h,
                    left: 25.w,
                    right: 25.w,
                    bottom: 0,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Strings.registrationTitle.s(24).w(600),
                          8.kh,
                          Strings.registrationSubtitle
                              .s(16)
                              .w(400)
                              .c(context.colors.display)
                              .a(TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                      top: MediaQuery.of(context).viewPadding.top + 16.h,
                      left: 16.w,
                      child: AppBarLeadingScreens(context)),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CommonTextField(
                      autofocus: true,
                      focusNode: _nameFocusNode,
                      controller: _nameController,
                      hint: Strings.fullNameHint,
                      validator: (value) =>
                          InputValidators.required(value, "Ф.И.О"),
                      isNext: true,
                      needToCapitalize: true,
                      nextFocusNode: _passwordFocusNode,
                    ),
                    16.kh,
                    CommonTextField(
                      controller: _passwordControllerController,
                      hint: Strings.passwordHint,
                      isNext: true,
                      nextFocusNode: _resetPasswordFocusNode,
                      focusNode: _passwordFocusNode,
                      obscureText: true,
                      validator: (value) => InputValidators.password(value),
                    ),
                    16.kh,
                    CommonTextField(
                      focusNode: _resetPasswordFocusNode,
                      controller: _resetPasswordController,
                      hint: Strings.confirmPasswordHint,
                      obscureText: true,
                      validator: (value) => InputValidators.confirmPassword(
                          value, _passwordControllerController.text),
                    ),
                    16.kh,
                    CommonButton.elevated(
                      text: Strings.nextButton,
                      backgroundColor: context.colors.primary01,
                      loading: state.isLoading,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<RegisterCubit>().register(RegisterModel(
                                fio: _nameController.text,
                                password: _passwordControllerController.text,
                                phoneNumber: phoneOrMail.startsWith("+")
                                    ? phoneOrMail.replaceAll("-", "")
                                    : null,
                                email: phoneOrMail.startsWith("+")
                                    ? null
                                    : phoneOrMail,
                              ));
                        }
                      },
                    ),
                    24.kh,
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     "У вас уже есть аккаунт?"
                    //         .s(14)
                    //         .c(context.colors.display)
                    //         .w(400),
                    //     4.kw,
                    //     InkWell(
                    //         onTap: () {
                    //           context.router.pop();
                    //         },
                    //         child: "Войти"
                    //             .s(14)
                    //             .c(context.colors.primary01)
                    //             .w(600)),
                    //   ],
                    // )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
