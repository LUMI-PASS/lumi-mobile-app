import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/auth/auth_agreement_text.dart';
import 'package:lumi_pass/common/widget/auth/auth_badges.dart';
import 'package:lumi_pass/common/widget/auth/auth_fields.dart';
import 'package:lumi_pass/common/widget/auth/auth_misc.dart';
import 'package:lumi_pass/common/widget/auth/auth_scaffold.dart';
import 'package:lumi_pass/common/widget/auth/gradient_button.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/presentation/auth/verify/cubit/verify_cubit.dart';
import 'package:lumi_pass/presentation/auth/verify/cubit/verify_state.dart';

@RoutePage()
class VerifyPage
    extends BasePage<VerifyCubit, VerifyBuildable, VerifyListenable> {
  final VerifyStatus verifyStatus;
  final String phoneOrEmail;
  final int? code;
  final String? codeHash;

  VerifyPage({
    super.key,
    required this.verifyStatus,
    required this.phoneOrEmail,
    this.codeHash,
    this.code,
  });

  final storage = getIt<Storage>();
  final _codeController = TextEditingController();

  @override
  void init(BuildContext context) {
    super.init(context);
    if (code != null) {
      context.read<VerifyCubit>().setOtpCode(code);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  void listener(BuildContext context, VerifyListenable state) {
    if (state.effect == VerifyEffect.success) {
      context.router.replaceAll(const [MainRoute()]);
    }
    super.listener(context, state);
  }

  void _submit(BuildContext context) {
    context.read<VerifyCubit>().checkCode(
          phoneOrEmail,
          storage.codeHash.call() ?? '',
          verifyStatus == VerifyStatus.REGISTER,
        );
  }

  @override
  Widget builder(BuildContext context, VerifyBuildable state) {
    final colors = context.colors;
    final hasError = state.error != null;

    // Auto-fill the field when an SMS code is captured.
    if (state.otpCode != null &&
        _codeController.text != state.otpCode.toString()) {
      final sms = state.otpCode.toString();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _codeController.value = TextEditingValue(
          text: sms,
          selection: TextSelection.collapsed(offset: sms.length),
        );
      });
    }

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
                    'confirm_title'.tr(),
                    textAlign: TextAlign.center,
                    style: AppText.title24.copyWith(color: colors.textPrimary),
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: Text.rich(
                      TextSpan(
                        style: AppText.regular14
                            .copyWith(color: colors.textSecondary),
                        children: [
                          TextSpan(text: 'confirm_code_sent_prefix'.tr()),
                          TextSpan(
                            text: phoneOrEmail,
                            style: AppText.semibold14
                                .copyWith(color: colors.textPrimary),
                          ),
                          TextSpan(text: 'confirm_code_sent_suffix'.tr()),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  OtpCodeField(
                    controller: _codeController,
                    hasError: hasError,
                    onChanged: (text) {
                      if (text.length == 4) {
                        context
                            .read<VerifyCubit>()
                            .changeCode(int.tryParse(text));
                        _submit(context);
                      }
                    },
                  ),
                  if (hasError) ...[
                    SizedBox(height: 8.h),
                    Text(
                      '${state.error}',
                      textAlign: TextAlign.center,
                      style: AppText.regular12
                          .copyWith(color: AppColors.error),
                    ),
                  ],
                  SizedBox(height: 12.h),
                  CountdownTimer(seconds: state.timer),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.timer == 0) ...[
                  AuthTextButton(
                    text: 'resend_code'.tr(),
                    onPressed: () => context
                        .read<VerifyCubit>()
                        .resendOtp(phoneOrEmail.replaceAll('-', '')),
                  ),
                  SizedBox(height: 4.h),
                ],
                GradientButton(
                  text: 'verify_button'.tr(),
                  loading: state.loading,
                  onPressed: () => _submit(context),
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

enum VerifyStatus { REGISTER, LOGIN, PASSWORDRESET }
