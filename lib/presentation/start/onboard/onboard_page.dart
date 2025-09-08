// ignore_for_file: must_be_immutable

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/presentation/start/onboard/cubit/onboarding_cubit.dart';
import 'package:lumi_pass/presentation/start/onboard/cubit/onboarding_state.dart';

@RoutePage()
class OnboardingPage extends BasePage<OnboardingCubit, OnboardingBuildable, OnboardingListenable> {
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

  final PageController _pageController = PageController();
  late List<OnboardingData> _pages;

  @override
  void init(BuildContext context) {
    initialize();
  }

  void initialize() {
    _pages = [
      OnboardingData(
        title: "BEST BOOKING APP",
        subtitle: "Explore The Best Booking App To Meet The ExtraOrdinary",
        backgroundImage: Image.asset(
          'assets/images/onboard1.png',
          fit: BoxFit.cover,
        ),
      ),
      OnboardingData(
        title: "Events With Love",
        subtitle: "Explore The Best Booking App To Meet The ExtraOrdinary",
        backgroundImage: Image.asset(
          'assets/images/onboard1.png',
          fit: BoxFit.cover,
        ),
      ),
      OnboardingData(
        title: "Book Near You",
        subtitle: "Explore The Best Booking App To Meet The ExtraOrdinary",
        backgroundImage: Image.asset(
          'assets/images/onboard2.png',
          fit: BoxFit.cover,
        ),
      ),
    ];
  }

  @override
  Widget builder(BuildContext context, OnboardingBuildable state) {
    return Scaffold(
      backgroundColor: context.colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: _pages[state.index].backgroundImage,
          ),

          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => context.read<OnboardingCubit>().changeIndex(index),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return OnboardingPageWidget(data: _pages[state.index]);
            },
          ),
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: () {
                context.read<OnboardingCubit>().skipAll();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          // Progress Dots
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: state.index == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: state.index == index ? context.colors.onPrimary : context.colors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),

          // Next Button (only show on third page)
          if (state.index == 2)
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  onPressed: () => context.read<OnboardingCubit>().changeIndex(3),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingData data;

  const OnboardingPageWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              data.title,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              data.subtitle,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 200),
          ],
        ),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final Widget backgroundImage;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.backgroundImage,
  });
}
