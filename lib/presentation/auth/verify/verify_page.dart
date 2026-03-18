import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/presentation/app/widgets/base_box.dart';
import 'package:lumi_pass/presentation/auth/verify/cubit/verify_cubit.dart';
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

  String _formatTimer(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void listener(BuildContext context, VerifyListenable state) {
    if (state.effect == VerifyEffect.success) {
      context.router.replaceAll(const [MainRoute()]);
    }
    super.listener(context, state);
  }

  @override
  Widget builder(context, state) {
    return Scaffold(
      body: SizedBox(
        height: 1.sh,
        width: 1.sw,
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).viewPadding.top + 24.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Assets.images.congrats.image(width: 123.w, height: 123.h),
                24.kw,
              ],
            ),
            Center(
              child: BaseBox(
                margin: const EdgeInsets.all(24),
                backgroundColor: const Color(0xFFA652C7).withValues(alpha: 0.2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    "Verify phone number".s(24).w(500),
                    8.kh,
                    "We Have Sent Code To Your Phone Number"
                        .s(14)
                        .w(400)
                        .a(TextAlign.center),
                    12.kh,
                    phoneOrEmail.s(12).w(500),
                    16.kh,
                    CommonPinPut(
                      onChanged: (text) {
                        if (text.length == 4) {
                          context
                              .read<VerifyCubit>()
                              .changeCode(int.tryParse(text));
                        }
                      },
                    ),
                    12.kh,
                    InkWell(
                        onTap: () {
                          if (state.timer == 0) {
                            context.read<VerifyCubit>().resendOtp(
                                phoneOrEmail.replaceAll("-", ""));
                          }
                        },
                        child: (state.timer != 0
                                ? _formatTimer(state.timer)
                                : "Resend code")
                            .s(14)
                            .w(600)
                            .c(context.colors.primary01)),
                    12.kh,
                    if (state.error != null)
                      "${state.error}".s(14).c(context.colors.primary2),
                    12.kh,
                    CommonButton.elevated(
                        text: "Verify",
                        backgroundColor: context.colors.primary,
                        loading: state.loading,
                        onPressed: () {
                          context.read<VerifyCubit>().checkCode(
                              phoneOrEmail,
                              storage.codeHash.call() ?? "",
                              verifyStatus == VerifyStatus.REGISTER);
                        }),
                    24.kh,
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

enum VerifyStatus { REGISTER, LOGIN, PASSWORDRESET }
