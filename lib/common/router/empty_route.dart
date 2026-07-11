import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';

@RoutePage()
class EmptyRouterPage extends StatefulWidget {
  const EmptyRouterPage({super.key});

  @override
  State<EmptyRouterPage> createState() => _EmptyRouterPageState();
}

class _EmptyRouterPageState extends State<EmptyRouterPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background matching the onboarding style
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF5F3FF),
                  Color(0xFFEDE9FE),
                  Colors.white,
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),

          // Decorative circles
          Positioned(
            top: -60, right: -60,
            child: _DecoCircle(size: 220, color: const Color(0xFFA652C7).withOpacity(0.08)),
          ),
          Positioned(
            bottom: 140, left: -50,
            child: _DecoCircle(size: 160, color: const Color(0xFFA652C7).withOpacity(0.06)),
          ),
          Positioned(
            top: 300, right: -24,
            child: _DecoCircle(size: 100, color: const Color(0xFFFF7093).withOpacity(0.07)),
          ),

          // Centered content
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Assets.icons.lumiLogo.image(
                      width: 96,
                      height: 96,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'LumiPass',
                      style: TextStyle(
                        fontFamily: 'Onest',
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFA652C7),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'For every family',
                      style: TextStyle(
                        fontFamily: 'Onest',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF9B6FAA),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 40),
                    const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA652C7)),
                        backgroundColor: Color(0x33A652C7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DecoCircle extends StatelessWidget {
  const _DecoCircle({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
