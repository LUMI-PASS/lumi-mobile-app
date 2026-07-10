import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

/// The "Продолжая, вы подтверждаете … публичной оферты." consent line, with the
/// offer link underlined in brand purple. Figma: centered 12px.
class AuthAgreementText extends StatefulWidget {
  const AuthAgreementText({
    super.key,
    required this.prefix,
    required this.linkText,
    this.suffix = '',
    this.url = 'https://lumipass.uz/public-offer',
  });

  final String prefix;
  final String linkText;
  final String suffix;
  final String url;

  @override
  State<AuthAgreementText> createState() => _AuthAgreementTextState();
}

class _AuthAgreementTextState extends State<AuthAgreementText> {
  late final TapGestureRecognizer _recognizer = TapGestureRecognizer()
    ..onTap = () => launchUrl(
          Uri.parse(widget.url),
          mode: LaunchMode.externalApplication,
        );

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = AppText.regular12.copyWith(color: context.appColors.textSecondary);
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: widget.prefix),
          TextSpan(
            text: widget.linkText,
            style: base.copyWith(
              color: AppColors.link,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.link,
            ),
            recognizer: _recognizer,
          ),
          TextSpan(text: widget.suffix),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
