import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flexobo/common/base/base_page.dart';
import 'package:flexobo/common/extensions/sizedbox_extensions.dart';
import 'package:flexobo/common/extensions/text_extensions.dart';
import 'package:flexobo/common/extensions/theme_extensions.dart';
import 'package:flexobo/common/gen/assets.gen.dart';
import 'package:flexobo/common/gen/strings.dart';
import 'package:flexobo/common/router/app_router.dart';
import 'package:flexobo/common/widget/common_button.dart';
import 'package:flexobo/presentation/app/widgets/base_box.dart';
import 'package:flexobo/presentation/app/widgets/bottom_box.dart';
import 'package:flexobo/presentation/app/cubit/app_cubit.dart';
import 'package:flexobo/presentation/app/cubit/app_state.dart';
import 'package:flexobo/presentation/profile/language/lang/language.dart';
import 'package:flexobo/presentation/profile/language/lang/language_service.dart';
import 'package:flexobo/presentation/start/onboard/cubit/onboarding_cubit.dart';
import 'package:flexobo/presentation/start/onboard/cubit/onboarding_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

@RoutePage()
class OnboardingPage extends BasePage<OnboardingCubit, OnboardingBuildable,
    OnboardingListenable> {
  OnboardingPage({super.key});

  final controller = PageController(initialPage: 0);

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
    return Scaffold(
      backgroundColor: context.colors.primary,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: EdgeInsets.only(left: 14.w, right: 14.w, bottom: 32.h),
        child: Column(
          children: [
            SizedBox(
              height: 148.h,
              child: Stack(
                children: [
                  Positioned(
                      top: 0.h,
                      left: 0.h,
                      right: 0.h,
                      bottom: 0.h,
                      child: Assets.images.frameFlexobo.image(height: 128.h)),
                  Positioned(
                    bottom: 12.h,
                    right: 0.h,
                    child: BaseBox(
                      onTap: () {
                        context.read<OnboardingCubit>().skipAll();
                      },
                      backgroundColor: context.colors.display,
                      padding:
                          EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
                      child:
                          Strings.skip.s(14).w(500).c(context.colors.onPrimary),
                    ),
                  ),
                  Positioned(
                    bottom: 12.h,
                    left: 0.h,
                    child: BaseBox(
                      onTap: () {
                        _showLanguageBottomSheet(context);
                      },
                      backgroundColor: context.colors.display,
                      padding:
                          EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
                      child: Builder(
                        builder: (context) {
                          final appCubit = context.watch<AppCubit>();
                          final currentLanguage =
                              appCubit.state.buildable?.language ??
                                  Language.from(context);
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              currentLanguage.icon,
                              4.kw,
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 16.w,
                                color: context.colors.onPrimary,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
            16.kh,
            Assets.images.onboardIcon.image(width: 138.w, height: 32.h),
            16.kh,
            SizedBox(
              width: 1.sw,
              height: 1.sh * 0.6,
              child: PageView.builder(
                controller: controller,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Onboard.values[state.index].icon,
                      24.kh,
                      Onboard.values[state.index].title
                          .s(24)
                          .w(600)
                          .c(context.colors.onPrimary)
                          .a(TextAlign.center),
                      16.kh,
                      Onboard.values[state.index].description
                          .s(14)
                          .w(400)
                          .c(context.colors.onPrimary)
                          .a(TextAlign.center),
                    ],
                  );
                },
                onPageChanged: (index) {
                  context.read<OnboardingCubit>().changeIndex(index);
                },
                itemCount: Onboard.values.length,
              ),
            ),
            16.kh,
            AnimatedSmoothIndicator(
              activeIndex: state.index,
              count: 3,
              effect: CustomizableEffect(
                dotDecoration: DotDecoration(
                  color: context.colors.title01,
                  width: 8.w,
                  height: 8.h,
                  borderRadius: BorderRadius.circular(5),
                  dotBorder: DotBorder(
                    width: 1.w,
                    color: context.colors.primary01,
                  ),
                ),
                activeDotDecoration: DotDecoration(
                  color: context.colors.onPrimary,
                  width: 24.w,
                  height: 8.h,
                  borderRadius: BorderRadius.circular(5),
                  dotBorder: DotBorder(
                    width: 1.w,
                    color: context.colors.primary,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: state.index != 0
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.end,
              children: [
                Flexible(
                  child: state.index != 0
                      ? SizedBox(
                          height: 48.h,
                          child: CommonButton.elevated(
                            backgroundColor: context.colors.display,
                            text: Strings.backButton,
                            onPressed: () => context
                                .read<OnboardingCubit>()
                                .changeIndex(state.index - 1),
                          ),
                        )
                      : SizedBox(),
                ),
                8.kw,
                Flexible(
                  child: CommonButton.elevated(
                    isRight: true,
                    backgroundColor: context.colors.primary2,
                    text: Strings.nextButton,
                    icon: Assets.icons.arrowRight.svg(),
                    onPressed: () => context
                        .read<OnboardingCubit>()
                        .changeIndex(state.index + 1),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    final appCubit = context.read<AppCubit>();
    final initialLanguage =
        appCubit.state.buildable?.language ?? Language.from(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _LanguageBottomSheetContent(initialLanguage: initialLanguage),
    );
  }
}

class _LanguageBottomSheetContent extends StatefulWidget {
  final Language initialLanguage;

  const _LanguageBottomSheetContent({required this.initialLanguage});

  @override
  _LanguageBottomSheetContentState createState() =>
      _LanguageBottomSheetContentState();
}

class _LanguageBottomSheetContentState
    extends State<_LanguageBottomSheetContent> {
  late Language selectedLanguage;

  @override
  void initState() {
    super.initState();
    selectedLanguage = widget.initialLanguage;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.onPrimary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            8.kh,
            Strings.selectLanguage.s(20).w(500).c(context.colors.primary),
            8.kh,
            Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                Language.values.length,
                (index) => _buildLanguageOption(
                  Language.values[index],
                  Language.values[index].icon,
                  context,
                  selectedLanguage,
                  selectedLanguage == Language.values[index],
                  () {
                    setState(() {
                      selectedLanguage = Language.values[index];
                    });
                  },
                ),
              ),
            ),
            12.kh,
            CommonButton.elevated(
              text: Strings.saveButton,
              backgroundColor: context.colors.primary,
              onPressed: () async {
                await _handleLanguageWithService(context, selectedLanguage);
              },
            ),
            24.kh
          ],
        ),
      ),
    );
  }

  Future<void> _handleLanguageWithService(
      BuildContext context, Language selectedLanguage) async {
    try {
      context.read<AppCubit>().selectLanguage(selectedLanguage);
      await LanguageService().changeLanguage(context, selectedLanguage.locale);
    } catch (e) {}

    Navigator.of(context).pop();
  }

  Widget _buildLanguageOption(
      Language language,
      Widget flagIcon,
      BuildContext context,
      Language? currentSelectedLanguage,
      bool isSelected,
      VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
        decoration: BoxDecoration(
          border: Border.all(
              color: isSelected ? context.colors.primary : context.colors.grey),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            flagIcon,
            16.kw,
            language.name
                .s(14)
                .c(isSelected
                    ? context.colors.primary
                    : const Color(0xFF414651))
                .w(500),
            const Spacer(),
            Radio(
              value: language.name,
              groupValue: currentSelectedLanguage?.name,
              onChanged: (value) {
                onTap();
              },
              activeColor: context.colors.primary,
              fillColor: MaterialStateProperty.all(context.colors.primary),
            )
          ],
        ),
      ),
    );
  }
}
