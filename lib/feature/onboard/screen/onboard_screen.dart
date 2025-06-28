import 'package:auto_route/auto_route.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumi_pass/di/get_it.dart';
import 'package:lumi_pass/feature/app_init/cubit/app_init_cubit.dart';

@RoutePage()
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;
  late List<OnboardingData> _pages;

  @override
  void initState() {
    initialize();
    super.initState();
  }

  void initialize() {
    _pages = [
      OnboardingData(
        title: "BEST BOOKING APP",
        subtitle: "Explore The Best Booking App To Meet The ExtraOrdinary",
        backgroundImage: ChessUiKitAssets.images.onboard1.image(
          fit: BoxFit.cover, // This will make the image cover the entire area
        ),
      ),
      OnboardingData(
        title: "Events With Love",
        subtitle: "Explore The Best Booking App To Meet The ExtraOrdinary",
        backgroundImage: ChessUiKitAssets.images.onboard2.image(
          fit: BoxFit.cover,
        ),
      ),
      OnboardingData(
        title: "Book Near You",
        subtitle: "Explore The Best Booking App To Meet The ExtraOrdinary",
        backgroundImage: ChessUiKitAssets.images.onboard1.image(
          fit: BoxFit.cover,
        ),
      ),
    ];
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _onNextPressed() {
    if (_currentPage == 2) {
      // Call checkAuth on third page
      context.read<AppInitCubit>().checkAuth();
    } else {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AppInitCubit>(),
      child: Scaffold(
        backgroundColor: ChessColors.black,
        body: Stack(
          children: [
            // Background image positioned to fill entire screen
            Positioned.fill(
              child: _pages[_currentPage].backgroundImage,
            ),

            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return OnboardingPage(data: _pages[index]);
              },
            ),
            Positioned(
              top: 50,
              right: 20,
              child: TextButton(
                onPressed: () {
                  context.read<AppInitCubit>().checkAuth();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
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
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? ChessColors.primaryDefaultWeak
                          : ChessColors.primaryBgStrong,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            // Next Button (only show on third page)
            if (_currentPage == 2)
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Center(
                  child: ElevatedButton(
                    onPressed: _onNextPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding:
                      EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
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
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const OnboardingPage({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              data.title,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              data.subtitle,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 200),
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