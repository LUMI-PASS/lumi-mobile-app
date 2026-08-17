import 'dart:async';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/payment_error.dart';
import 'package:lumi_pass/common/widget/payment_sheet_chrome.dart';
import 'package:lumi_pass/data/api_model/order/saved_card.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:pinput/pinput.dart';

/// Confirms the code the bank SMSed for a card verification.
///
/// Returns the saved card on success, or null if the user gave up.
Future<SavedCard?> showCardVerifyOtpSheet(
  BuildContext context, {
  required CardVerifySession session,
  required String pan,
  required String expiry,
}) {
  return showModalBottomSheet<SavedCard>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    backgroundColor: Colors.transparent,
    builder: (_) => _CardOtpSheet(session: session, pan: pan, expiry: expiry),
  );
}

class _CardOtpSheet extends StatefulWidget {
  const _CardOtpSheet({
    required this.session,
    required this.pan,
    required this.expiry,
  });

  final CardVerifySession session;
  final String pan;
  final String expiry;

  @override
  State<_CardOtpSheet> createState() => _CardOtpSheetState();
}

class _CardOtpSheetState extends State<_CardOtpSheet> {
  static const _resendAfter = Duration(seconds: 60);

  final _otpCtrl = TextEditingController();
  final _otpFocus = FocusNode();

  late CardVerifySession _session;
  Timer? _timer;
  int _secondsLeft = _resendAfter.inSeconds;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpCtrl.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendAfter.inSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) t.cancel();
    });
  }

  String get _countdown {
    final s = _secondsLeft.clamp(0, _resendAfter.inSeconds);
    return '${(s ~/ 60).toString().padLeft(2, '0')}:'
        '${(s % 60).toString().padLeft(2, '0')}';
  }

  Future<void> _confirm() async {
    final otp = _otpCtrl.text.trim();
    if (otp.length < 4 || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final card = await getIt<OrdersApi>().confirmCardVerification(
        verificationId: _session.verificationId,
        otp: otp,
      );
      if (!mounted) return;
      Navigator.of(context).pop(card);
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = PaymentError.fromDio(e) ?? 'pay_code_invalid'.tr();
        _otpCtrl.clear();
      });
      _otpFocus.requestFocus();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'card_save_error'.tr();
      });
    }
  }

  /// Asks for the code again.
  ///
  /// The server hands back the attempt that is still in flight rather than
  /// opening a new one, so this does **not** charge the card a second time —
  /// which is exactly why resend calls the API instead of only restarting the
  /// timer.
  Future<void> _resend() async {
    if (_secondsLeft > 0 || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final session = await getIt<OrdersApi>().verifyCard(
        cardNumber: widget.pan,
        expireDate: widget.expiry,
      );
      if (!mounted) return;
      setState(() {
        _session = session;
        _busy = false;
        _otpCtrl.clear();
      });
      _startCountdown();
      _otpFocus.requestFocus();
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = PaymentError.fromDio(e) ?? 'card_save_error'.tr();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final canResend = _secondsLeft <= 0 && !_busy;

    final base = PinTheme(
      width: 44.w,
      height: 48.h,
      textStyle: AppText.semibold18.copyWith(color: c.textPrimary),
      decoration: BoxDecoration(
        color: c.control,
        borderRadius: BorderRadius.circular(12.r),
      ),
    );

    return PaymentSheetShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('card_confirm_title'.tr(),
              style: AppText.bold18.copyWith(color: c.textPrimary)),
          6.kh,
          Text(
            (_session.otpSentPhone?.isNotEmpty ?? false)
                ? 'pay_code_sent_to'.tr(args: [_session.otpSentPhone!])
                : 'pay_code_sent'.tr(),
            style: AppText.regular13.copyWith(color: c.textSecondary),
          ),
          18.kh,
          Center(
            child: Pinput(
              length: 6,
              controller: _otpCtrl,
              focusNode: _otpFocus,
              autofocus: true,
              keyboardType: TextInputType.number,
              separatorBuilder: (_) => 8.kw,
              defaultPinTheme: base,
              focusedPinTheme: base.copyWith(
                decoration: base.decoration!.copyWith(
                  border: Border.all(color: AppColors.brandPurple, width: 1.5),
                ),
              ),
              errorPinTheme: base.copyWith(
                decoration: base.decoration!.copyWith(
                  border: Border.all(color: AppColors.error, width: 1.5),
                ),
              ),
              forceErrorState: _error != null,
              // Six digits in means there is nothing left to decide — asking
              // for a second tap on Confirm only adds a step.
              onCompleted: (_) => _confirm(),
            ),
          ),
          if (_error != null) ...[
            14.kh,
            PaymentErrorNote(message: _error!),
          ],
          14.kh,
          Row(
            children: [
              if (!canResend)
                Text(_countdown,
                    style: AppText.regular13.copyWith(color: c.textSecondary)),
              const Spacer(),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: canResend ? _resend : null,
                child: Text(
                  'card_resend_code'.tr(),
                  style: AppText.semibold14.copyWith(
                    color:
                        canResend ? AppColors.brandPurple : c.textPlaceholder,
                  ),
                ),
              ),
            ],
          ),
          16.kh,
          PaymentSheetActions(
            primaryLabel: 'card_confirm_action'.tr(),
            busy: _busy,
            onPrimary:
                _otpCtrl.text.trim().length >= 4 && !_busy ? _confirm : null,
            onCancel: _busy ? null : () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
