import 'package:flutter/material.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:smart_auth/smart_auth.dart';

/// Big centered phone entry — "+998 000 00 00". The `+998` prefix is fixed;
/// the grey placeholder digits and typed digits share one large rounded style.
class PhoneNumberField extends StatefulWidget {
  const PhoneNumberField({
    super.key,
    required this.onChanged,
    this.autofocus = true,
  });

  /// Emits the raw 9-digit national number (no prefix, no separators).
  final ValueChanged<String> onChanged;
  final bool autofocus;

  @override
  State<PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<PhoneNumberField> {
  late final MaskTextInputFormatter _mask = MaskTextInputFormatter(
    mask: '## ### ## ##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text('+998 ',
              style: AppText.phone32.copyWith(color: colors.textPrimary)),
          IntrinsicWidth(
            child: TextField(
              autofocus: widget.autofocus,
              keyboardType: TextInputType.number,
              inputFormatters: [_mask],
              style: AppText.phone32.copyWith(color: colors.textPrimary),
              cursorColor: AppColors.brandPurple,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: '00 000 00 00',
                hintStyle:
                    AppText.phone32.copyWith(color: colors.textPlaceholder),
              ),
              onChanged: (text) => widget.onChanged(_mask.getUnmaskedText()),
            ),
          ),
        ],
      ),
    );
  }
}

/// Large centered 4-digit code display — "0 0 0 0". Turns red on error.
/// The one-time-code entry. Looks like a plain big number field, but it is the
/// autofill target for the login SMS, so the plumbing matters:
///
///  * `autofillHints: oneTimeCode` is what makes iOS put "From Messages: 1234"
///    on the QuickType bar and what maps to Android's `smsOTPCode` hint. Without
///    it neither platform ever offers the code, no matter what the SMS says.
///  * The [AutofillGroup] is required for the Android autofill framework to see
///    the field at all; iOS tolerates its absence, Android does not.
///  * [smsAutofill] additionally listens for the SMS itself through the Google
///    SMS User Consent API (Android only), which fills the field after a single
///    system "Allow" tap even when the keyboard suggestion does not appear.
///    Switching to the silent SMS Retriever API needs the 11-char app signature
///    appended to the SMS body — see docs, and `SmartAuth().getAppSignature()`.
class OtpCodeField extends StatefulWidget {
  const OtpCodeField({
    super.key,
    required this.controller,
    this.focusNode,
    this.onChanged,
    this.hasError = false,
    this.autofocus = true,
    this.length = 4,
    this.smsAutofill = false,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final bool hasError;
  final bool autofocus;

  /// Digits the code has. Our own SMS login sends 4; a bank's payment OTP is 6,
  /// so the payment sheets pass 6 — a field capped at 4 silently swallowed the
  /// last two digits and every confirmation failed.
  final int length;

  /// Listen for our own login SMS and fill the field from it. Only meaningful
  /// on Android, and only for codes we send ourselves — a bank's payment OTP
  /// arrives from a sender we do not control, so the sheets leave this off.
  final bool smsAutofill;

  @override
  State<OtpCodeField> createState() => _OtpCodeFieldState();
}

class _OtpCodeFieldState extends State<OtpCodeField> {
  SmartAuth? _smartAuth;

  @override
  void initState() {
    super.initState();
    if (widget.smsAutofill && defaultTargetPlatform == TargetPlatform.android) {
      _smartAuth = SmartAuth();
      _listenForSms();
    }
  }

  @override
  void dispose() {
    _smartAuth?.removeSmsListener();
    super.dispose();
  }

  /// Re-arms itself after every delivery: a resend must autofill too, and the
  /// consent listener is single-shot.
  Future<void> _listenForSms() async {
    while (mounted && _smartAuth != null) {
      final res = await _smartAuth!.getSmsCode(
        // Exactly our own code length. `\d{4,7}` — the package default — would
        // happily return the first four digits of some unrelated number.
        matcher: '\\d{${widget.length}}',
        useUserConsentApi: true,
      );
      if (!mounted) return;
      if (res.codeFound && res.code!.length == widget.length) {
        widget.controller.text = res.code!;
        widget.onChanged?.call(res.code!);
      }
      if (!res.succeed) return; // listener torn down or unavailable
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = widget.hasError ? AppColors.error : colors.textPrimary;
    // 56pt glyphs at 14pt tracking fit four digits across the narrowest phone;
    // six need to come down or the line overflows its box.
    final base = widget.length > 4
        ? AppText.code56.copyWith(fontSize: 40.sp)
        : AppText.code56;
    final tracking = widget.length > 4 ? 8.w : 14.w;
    return AutofillGroup(
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        keyboardType: TextInputType.number,
        autofillHints: const [AutofillHints.oneTimeCode],
        textAlign: TextAlign.center,
        showCursor: true,
        cursorColor: AppColors.brandPurple,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(widget.length),
        ],
        style: base.copyWith(color: color, letterSpacing: tracking),
        decoration: InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          counterText: '',
          hintText: '0' * widget.length,
          hintStyle: base.copyWith(
              color: colors.textPlaceholder, letterSpacing: tracking),
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
