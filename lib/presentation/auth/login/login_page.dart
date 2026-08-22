import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/auth/auth_agreement_text.dart';
import 'package:lumi_pass/common/widget/auth/auth_badges.dart';
import 'package:lumi_pass/common/widget/auth/auth_fields.dart';
import 'package:lumi_pass/common/widget/auth/auth_scaffold.dart';
import 'package:lumi_pass/common/widget/auth/gradient_button.dart';
import 'package:lumi_pass/presentation/auth/login/bloc/login_cubit.dart';
import 'package:lumi_pass/presentation/auth/login/bloc/login_state.dart';
import 'package:lumi_pass/presentation/auth/telegram/telegram_login_page.dart';
import 'package:lumi_pass/presentation/auth/verify/verify_page.dart';

/// "Авторизация" — phone-number entry.
@RoutePage()
class LoginPage extends BasePage<LoginCubit, LoginBuildable, LoginListenable> {
  LoginPage({super.key});

  final ValueNotifier<String> _digits = ValueNotifier('');

  String get _phone => '+998${_digits.value}';

  @override
  void dispose() {
    _digits.dispose();
    super.dispose();
  }

  @override
  void listener(BuildContext context, LoginListenable state) {
    if (state.effect == LoginEffect.verify) {
      context.router.push(
        VerifyRoute(
          verifyStatus: VerifyStatus.LOGIN,
          phoneOrEmail: _phone,
          code: state.code,
        ),
      );
    }
    super.listener(context, state);
  }

  @override
  Widget builder(BuildContext context, LoginBuildable state) {
    final colors = context.colors;

    return AuthScaffold(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: 40.h),
                  const AuthIconBadgeRow(),
                  SizedBox(height: 12.h),
                  Text(
                    'auth_title'.tr(),
                    textAlign: TextAlign.center,
                    style: AppText.title24.copyWith(color: colors.textPrimary),
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Text(
                      'auth_subtitle'.tr(),
                      textAlign: TextAlign.center,
                      style: AppText.regular14
                          .copyWith(color: colors.textSecondary),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  PhoneNumberField(
                    onChanged: (digits) {
                      _digits.value = digits;
                      context
                          .read<LoginCubit>()
                          .changePhoneState(digits.length == 9);
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GradientButton(
                  text: 'continue_button'.tr(),
                  loading: state.isLoading,
                  enabled: state.isSelected,
                  onPressed: () => context.read<LoginCubit>().login(_phone),
                ),
                SizedBox(height: 12.h),
                // The way in that does not depend on SMS arriving.
                TelegramLoginButton(
                  onPressed: () =>
                      context.router.push(TelegramLoginRoute()),
                ),
                SizedBox(height: 16.h),
                AuthAgreementText(
                  prefix: 'oferta_agree_prefix'.tr(),
                  linkText: 'oferta_link_text'.tr(),
                  suffix: 'oferta_agree_suffix'.tr(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
