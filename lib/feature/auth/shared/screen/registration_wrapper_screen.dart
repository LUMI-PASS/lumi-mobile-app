import 'package:auto_route/auto_route.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';

class RegistrationWrapperScreen extends StatefulWidget {
  final Widget body;
  final String title;
  final String subtitle;
  final String primaryButtonLabel;
  final VoidCallback? onPrimaryButtonTap;
  final Icon? leadingIcon;
  final VoidCallback? onLeadingIconTap;
  final String? secondaryButtonLabel;
  final VoidCallback? onSecondaryButtonTap;

  const RegistrationWrapperScreen({
    required this.body,
    required this.onPrimaryButtonTap,
    required this.title,
    required this.subtitle,
    required this.primaryButtonLabel,
    this.leadingIcon,
    this.onLeadingIconTap,
    this.secondaryButtonLabel,
    this.onSecondaryButtonTap,
    super.key,
  });

  @override
  State<RegistrationWrapperScreen> createState() => _RegistrationWrapperScreenState();
}

class _RegistrationWrapperScreenState extends State<RegistrationWrapperScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChessColors.greyG900,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          child: widget.leadingIcon ??
              const Icon(
                Icons.arrow_back,
                color: ChessColors.white,
              ),
          onTap: () {
            widget.onLeadingIconTap ?? context.router.pop();
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  _buildAnimatedText(
                    widget.title,
                    context.textTheme.largeTitle3Bold.copyWith(
                      fontFamily: FontFamily.nunito,
                    ),
                    delay: 200,
                  ),
                  const SizedBox(height: 8),
                  _buildAnimatedText(
                    widget.subtitle,
                    context.textTheme.subheadlineRegular.copyWith(
                      color: ChessColors.greyG20,
                      fontFamily: FontFamily.nunito,
                    ),
                    delay: 400,
                  ),
                  const SizedBox(height: 24),
                  _buildAnimatedWidget(
                    widget.body,
                    delay: 600,
                  ),
                  const SizedBox(height: 16),
                  _buildAnimatedWidget(
                    ChessButton.primary(
                      onPressed: widget.onPrimaryButtonTap != null
                          ? () => widget.onPrimaryButtonTap?.call()
                          : null,
                      label: widget.primaryButtonLabel,
                      background: ChessColors.primaryDefault,
                    ),
                    delay: 800,
                  ),
                  if (widget.secondaryButtonLabel != null) ...[
                    const SizedBox(height: 16),
                    _buildAnimatedWidget(
                      ChessButton.secondary(
                        onPressed: widget.onSecondaryButtonTap,
                        label: widget.secondaryButtonLabel ?? '',
                      ),
                      delay: 1000,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedText(String text, TextStyle? style, {required int delay}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: delay + 400),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Text(text, style: style),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedWidget(Widget widget, {required int delay}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: delay + 400),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: widget,
          ),
        );
      },
    );
  }
}