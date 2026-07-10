import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/auth/auth_misc.dart';
import 'package:lumi_pass/common/widget/auth/auth_scaffold.dart';
import 'package:lumi_pass/common/widget/auth/gradient_button.dart';
import 'package:lumi_pass/presentation/start/onboard/cubit/onboarding_cubit.dart';
import 'package:lumi_pass/presentation/start/onboard/cubit/onboarding_state.dart';

@RoutePage()
class OnboardingPage
    extends BasePage<OnboardingCubit, OnboardingBuildable, OnboardingListenable> {
  OnboardingPage({super.key});

  final PageController _pageController = PageController();

  static const _images = [
    'assets/icons/main/onboard1.png',
    'assets/icons/main/onboard2.png',
    'assets/icons/main/onboard3.png',
  ];

  @override
  void listener(BuildContext context, OnboardingListenable state) {
    switch (state.effect) {
      case OnboardEffect.home:
        context.router.replaceAll([const MainRoute()]);
        break;
      case OnboardEffect.login:
        context.router.replaceAll([LoginRoute()]);
        break;
    }
  }

  @override
  Widget builder(BuildContext context, OnboardingBuildable state) {
    final colors = context.appColors;
    const pages = Onboard.values;
    final isLast = state.index == pages.length - 1;

    return AuthScaffold(
      child: Column(
        children: [
          SizedBox(height: 24.h),
          const LumiWordmark(height: 24),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) =>
                  context.read<OnboardingCubit>().changeIndex(i),
              itemCount: pages.length,
              itemBuilder: (context, index) => _OnboardSlide(
                image: _images[index],
                title: pages[index].title,
                subtitle: pages[index].description,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
            child: Column(
              children: [
                PageDots(count: pages.length, index: state.index),
                SizedBox(height: 20.h),
                GradientButton(
                  text: isLast ? 'get_started'.tr() : 'continue_button'.tr(),
                  onPressed: () {
                    if (isLast) {
                      context.read<OnboardingCubit>().changeIndex(pages.length);
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                      );
                    }
                  },
                ),
                SizedBox(height: 4.h),
                AuthTextButton(
                  text: 'skip'.tr(),
                  color: colors.textSecondary,
                  onPressed: () =>
                      context.read<OnboardingCubit>().skipAll(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardSlide extends StatelessWidget {
  const _OnboardSlide({
    required this.image,
    required this.title,
    required this.subtitle,
  });

  final String image;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.asset(image, fit: BoxFit.contain),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppText.title24.copyWith(color: colors.textPrimary),
          ),
          SizedBox(height: 10.h),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppText.regular14.copyWith(color: colors.textSecondary),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}
