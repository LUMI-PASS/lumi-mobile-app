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
import 'package:flexobo/data/storage/storage.dart';
import 'package:flexobo/di/injection.dart';
import 'package:flexobo/presentation/auth/check_user/cubit/check_user_cubit.dart';
import 'package:flexobo/presentation/auth/verify/cubit/verify_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'cubit/verify_state.dart';
import 'widget/common_pin_put.dart';

@RoutePage()
class VerifyPage
    extends BasePage<VerifyCubit, VerifyBuildable, VerifyListenable> {
  final VerifyStatus verifyStatus;
  final String phoneOrEmail;
  final int? code;
  final String? codeHash;

  VerifyPage(
      {super.key,
      required this.verifyStatus,
      required this.phoneOrEmail,
      this.codeHash,
      this.code});

  final storage = getIt<Storage>();

  @override
  void listener(BuildContext context, VerifyListenable state) {
    if (state.effect == VerifyEffect.success) {
      if (verifyStatus == VerifyStatus.PASSWORDRESET) {
        context.router.push(ForgetPasswordRoute(phoneOrEmail: phoneOrEmail));
      } else if (verifyStatus == VerifyStatus.REGISTER) {
        context.router.push(RegisterRoute(phoneOrMail: phoneOrEmail));
      } else {
        context.router.replaceAll(const [MainRoute()]);
      }
    }
    super.listener(context, state);
  }

  @override
  Widget builder(context, state) {
    return Scaffold(
      body: Column(
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
                        Strings.verificationTitle.s(24).w(600),
                        8.kh,
                        (phoneOrEmail.startsWith("+")
                                ? Strings.smsCodeSentPhone
                                : Strings.smsCodeSentEmail)
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CommonPinPut(
                  onChanged: (text) =>
                      context.read<VerifyCubit>().changeCode(int.parse(text)),
                ),
                24.kh,
                InkWell(
                    onTap: () {
                      if (state.timer == 0) {
                        context.read<VerifyCubit>().timerChange();
                        context.read<VerifyCubit>().checkPhone(
                            phoneOrEmail.replaceAll("-", ""),
                            verifyStatus == VerifyStatus.REGISTER);
                      }
                    },
                    child: (state.timer != 0
                            ? "00:${state.timer}"
                            : Strings.resendCode)
                        .s(14)
                        .w(600)
                        .c(context.colors.primary01)),
                12.kh,
                if (state.error != null)
                  "${state.error}".s(14).c(context.colors.primary2),
                12.kh,
                CommonButton.elevated(
                    text: Strings.nextButton,
                    backgroundColor: context.colors.primary01,
                    loading: state.loading,
                    onPressed: () {
                      context.read<VerifyCubit>().checkCode(
                          phoneOrEmail, storage.codeHash.call() ?? "");
                    }),
                24.kh,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum VerifyStatus { REGISTER, LOGIN, PASSWORDRESET }
