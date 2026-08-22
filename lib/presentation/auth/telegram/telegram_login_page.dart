import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/auth/auth_agreement_text.dart';
import 'package:lumi_pass/common/widget/auth/auth_badges.dart';
import 'package:lumi_pass/common/widget/auth/auth_fields.dart';
import 'package:lumi_pass/common/widget/auth/auth_scaffold.dart';
import 'package:lumi_pass/common/widget/auth/gradient_button.dart';
import 'package:lumi_pass/common/widget/bouncing_button.dart';
import 'package:lumi_pass/presentation/auth/telegram/cubit/telegram_login_cubit.dart';
import 'package:lumi_pass/presentation/auth/telegram/cubit/telegram_login_state.dart';

/// "Telegram orqali kirish" — the user gets a code from the bot instead of an
/// SMS and types it here. There is no phone-number step: the server resolves
/// the account from the code the bot issued.
@RoutePage()
class TelegramLoginPage extends BasePage<TelegramLoginCubit,
    TelegramLoginBuildable, TelegramLoginListenable> {
  TelegramLoginPage({super.key});

  final _codeController = TextEditingController();

  @override
  void init(BuildContext context) {
    super.init(context);
    // Fetch the bot link and open the chat straight away — the user already
    // said "sign in with Telegram" by getting here, so a second tap to open it
    // earns nothing.
    context.read<TelegramLoginCubit>().start();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  void listener(BuildContext context, TelegramLoginListenable state) {
    if (state.effect == TelegramLoginEffect.success) {
      context.router.replaceAll(const [MainRoute()]);
    }
    super.listener(context, state);
  }

  @override
  Widget builder(BuildContext context, TelegramLoginBuildable state) {
    final colors = context.colors;
    final hasError = state.error != null;
    final complete = state.code.length == state.codeLength;

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
                    'telegram_login_title'.tr(),
                    textAlign: TextAlign.center,
                    style: AppText.title24.copyWith(color: colors.textPrimary),
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Text(
                      'telegram_login_step2'.tr(),
                      textAlign: TextAlign.center,
                      style: AppText.regular14
                          .copyWith(color: colors.textSecondary),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  OtpCodeField(
                    controller: _codeController,
                    hasError: hasError,
                    length: state.codeLength,
                    onChanged: (text) {
                      final cubit = context.read<TelegramLoginCubit>();
                      cubit.changeCode(text);
                      if (text.length == state.codeLength) cubit.submit(text);
                    },
                  ),
                  if (hasError) ...[
                    SizedBox(height: 8.h),
                    Text(
                      '${state.error}',
                      textAlign: TextAlign.center,
                      style:
                          AppText.regular12.copyWith(color: AppColors.error),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // The launch can drop the user into Telegram before the bot has
                // answered, or fail outright when Telegram is not installed —
                // either way they need a way back to the chat.
                AuthTextButton(
                  text: 'telegram_login_open'.tr(),
                  onPressed: () =>
                      context.read<TelegramLoginCubit>().reopenBot(),
                ),
                SizedBox(height: 4.h),
                GradientButton(
                  text: 'verify_button'.tr(),
                  loading: state.loading || state.openingBot,
                  enabled: complete,
                  onPressed: () =>
                      context.read<TelegramLoginCubit>().submit(state.code),
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

/// Entry point from the phone-number screen.
class TelegramLoginButton extends StatelessWidget {
  const TelegramLoginButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Bouncing(
      onTap: () => onPressed?.call(),
      child: Container(
        height: 50.h,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(44.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.icons.telegram.svg(
              width: 20.r,
              height: 20.r,
              colorFilter: ColorFilter.mode(
                colors.textPrimary,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'telegram_login_button'.tr(),
              style: AppText.medium16.copyWith(color: colors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
