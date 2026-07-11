import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';
import 'package:lumi_pass/common/widget/common_button.dart';

/// Full-screen "no internet" state, pushed by [ConnectivityInterceptor] when a
/// request fails with a connection error.
///
/// Pops with `true` when the user asks to retry. Popping any other way (system
/// back) yields `null`, which the interceptor also treats as a retry.
@RoutePage<bool>()
class ConnectionErrorPage extends StatelessWidget {
  const ConnectionErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              const Spacer(),
              FrostedCard(
                width: 72.w,
                height: 72.w,
                borderRadius: BorderRadius.circular(20.r),
                alignment: Alignment.center,
                child: Assets.images.noInternet.image(width: 36.w, height: 36.w),
              ),
              12.kh,
              Text(
                Strings.noInternetTitle,
                textAlign: TextAlign.center,
                style: AppText.semibold18
                    .copyWith(color: context.colors.textPrimary),
              ),
              4.kh,
              Text(
                Strings.noInternetDesc,
                textAlign: TextAlign.center,
                style: AppText.regular14
                    .copyWith(color: context.colors.textSecondary),
              ),
              const Spacer(),
              CommonButton.elevated(
                text: Strings.retry,
                onPressed: () => context.router.maybePop(true),
              ),
              16.kh,
            ],
          ),
        ),
      ),
    );
  }
}
