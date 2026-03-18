import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:lumi_pass/common/widget/common_text_filed.dart';
import 'package:lumi_pass/presentation/auth/login/bloc/login_cubit.dart';
import 'package:lumi_pass/presentation/auth/login/bloc/login_state.dart';
import 'package:lumi_pass/presentation/auth/verify/verify_page.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

@RoutePage()
class LoginPage extends BasePage<LoginCubit, LoginBuildable, LoginListenable> {
  LoginPage({super.key});

  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  void listener(BuildContext context, LoginListenable state) {
    if (state.effect == LoginEffect.verify) {
      context.router.replaceAll([
        VerifyRoute(
            verifyStatus: VerifyStatus.LOGIN,
            phoneOrEmail: "+998${_phoneController.text}")
      ]);
    } else {
      context.router
          .replaceAll([RegisterRoute(phoneOrMail: "+998${_phoneController.text}")]);
    }
    super.listener(context, state);
  }

  @override
  Widget builder(context, state) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24).copyWith(
            top: MediaQuery.of(context).padding.top,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Assets.images.congrats.image(width: 123.w, height: 123.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  12.kh,
                  "Telefon raqamingizni \nkiriting".s(20).w(600),
                  24.kh,
                  CommonTextField(
                    controller: _phoneController,
                    autofocus: true,
                    prefixIcon: "+998".s(12).w(400),
                    mask: "##-###-##-##",
                    hint: "12-345-67-89",
                    onChanged: (text) => context
                        .read<LoginCubit>()
                        .changePhoneState(text.length == 9),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CommonButton.elevated(
                  text: "Davom etish",
                  backgroundColor: context.colors.primary,
                  loading: state.isLoading,
                  enabled: state.isSelected,
                  onPressed: () {
                    context
                        .read<LoginCubit>()
                        .login("+998${_phoneController.text}");
                  }),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
