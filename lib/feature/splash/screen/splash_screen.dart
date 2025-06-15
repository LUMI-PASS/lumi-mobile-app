import 'package:auto_route/auto_route.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _indicatorController;

  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _indicatorFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOut,
    ));

    _logoScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    // Text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutBack,
    ));

    // Indicator animations
    _indicatorController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _indicatorFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _indicatorController,
      curve: Curves.easeOut,
    ));

    // Start animations with delays
    _startAnimations();
  }

  void _startAnimations() {
    // Logo animation starts immediately
    _logoController.forward();

    // Text animation starts after 400ms
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _textController.forward();
    });

    // Indicator animation starts after 800ms
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _indicatorController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _indicatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Animated Logo
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _logoFadeAnimation,
                      child: ScaleTransition(
                        scale: _logoScaleAnimation,
                        child: ChessUiKitAssets.images.logoPng.image(
                          height: 80,
                          width: 80,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Animated Text
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _textFadeAnimation,
                      child: SlideTransition(
                        position: _textSlideAnimation,
                        child: Text(
                          "Founders \n Academy",
                          style: context.textTheme.title1Regular
                              .copyWith(color: ChessColors.white),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Animated Indicator
                AnimatedBuilder(
                  animation: _indicatorController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _indicatorFadeAnimation,
                      child: ChessUiKitAssets.lotties.indicator.lottie(
                        height: 36,
                        width: 36,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}