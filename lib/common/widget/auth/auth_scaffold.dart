import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';

/// Shared shell for every auth/onboarding screen: brightness-aware background
/// plus a matching status-bar overlay, so the whole flow renders correctly in
/// both light and dark mode.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.child,
    this.resizeToAvoidBottomInset = true,
  });

  final Widget child;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: colors.overlayStyle,
      child: Scaffold(
        backgroundColor: colors.bg,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: SafeArea(child: child),
      ),
    );
  }
}
