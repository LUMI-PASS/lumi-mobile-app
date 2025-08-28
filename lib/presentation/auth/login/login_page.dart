import 'package:auto_route/auto_route.dart';
import 'package:flexobo/common/base/base_page.dart';
import 'package:flexobo/common/extensions/sizedbox_extensions.dart';
import 'package:flexobo/common/extensions/text_extensions.dart';
import 'package:flexobo/common/extensions/theme_extensions.dart';
import 'package:flexobo/common/gen/assets.gen.dart';
import 'package:flexobo/common/gen/strings.dart';
import 'package:flexobo/common/router/app_router.dart';
import 'package:flexobo/common/widget/base_app_bar.dart';
import 'package:flexobo/common/widget/common_button.dart';
import 'package:flexobo/common/widget/common_text_filed.dart';
import 'package:flexobo/presentation/app/widgets/phone_email_form_field.dart';
import 'package:flexobo/presentation/auth/login/bloc/login_cubit.dart';
import 'package:flexobo/presentation/auth/login/bloc/login_state.dart';
import 'package:flexobo/presentation/auth/verify/verify_page.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

@RoutePage()
class LoginPage extends BasePage<LoginCubit, LoginBuildable, LoginListenable> {
  LoginPage({super.key});

  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  void listener(BuildContext context, LoginListenable state) {
    if (state.effect == LoginEffect.main) {
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
              height: 1.sh * 0.38,
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
                          Strings.loginTitle.s(24).w(600),
                          8.kh,
                          Strings.loginSubtitle
                              .s(16)
                              .w(400)
                              .c(context.colors.display)
                              .a(TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  PhoneEmailFormField(
                    phoneController: _phoneController,
                    isMaskMatched: (value) {
                      context.read<LoginCubit>().changePhoneState(value);
                    },
                    isNext: true,
                    focusNode: _phoneFocusNode,
                    nextFocusNode: _passwordFocusNode,
                    errorPhone: state.errorPhone,
                  ),
                  8.kh,
                  CommonTextField(
                    controller: _passwordController,
                    hint: Strings.passwordHint,
                    obscureText: true,
                    errorText: state.errorPassword,
                  ),
                  8.kh,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                          onTap: () {
                            context.router
                                .push(CheckUserRoute(isRegister: false));
                          },
                          child: Strings.forgotPassword
                              .s(12)
                              .w(600)
                              .c(context.colors.primary01))
                    ],
                  ),
                  12.kh,
                  CommonButton.elevated(
                    text: Strings.loginButton,
                    backgroundColor: context.colors.primary01,
                    loading: state.isLoading,
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      context.read<LoginCubit>().login(
                          _phoneController.text.replaceAll("-", "").trim(),
                          _passwordController.text);
                    },
                  ),
                  24.kh,
                  Strings.noAccount.s(14).c(context.colors.display).w(400),
                  4.kh,
                  InkWell(
                      onTap: () {
                        context.router.push(CheckUserRoute(isRegister: true));
                      },
                      child: Strings.register
                          .s(14)
                          .c(context.colors.primary01)
                          .w(600)
                          .o(TextOverflow.ellipsis))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
