import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/card_input_formatters.dart';
import 'package:lumi_pass/common/utils/payment_error.dart';
import 'package:lumi_pass/common/widget/payment_sheet_chrome.dart';
import 'package:lumi_pass/data/api_model/order/saved_card.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';

import 'card_otp_sheet.dart';

/// Adds a card: number + expiry, then the OTP step.
///
/// Returns the saved [SavedCard] once the whole flow succeeds, or null if the
/// user backed out.
Future<SavedCard?> showAddCardSheet(BuildContext context) {
  return showModalBottomSheet<SavedCard>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _AddCardSheet(),
  );
}

class _AddCardSheet extends StatefulWidget {
  const _AddCardSheet();

  @override
  State<_AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends State<_AddCardSheet> {
  final _numberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _expiryFocus = FocusNode();

  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _numberCtrl.dispose();
    _expiryCtrl.dispose();
    _expiryFocus.dispose();
    super.dispose();
  }

  String get _pan => _numberCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');

  bool get _isValid =>
      _pan.length >= 16 && expiryToMmYy(_expiryCtrl.text).isNotEmpty;

  /// Starts verification (which charges the card) and hands off to the OTP
  /// step. The two sheets are stacked rather than merged so backing out of the
  /// code screen returns to the form with the number still typed.
  Future<void> _submit() async {
    if (!_isValid || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final session = await getIt<OrdersApi>().verifyCard(
        cardNumber: _pan,
        expireDate: expiryToMmYy(_expiryCtrl.text),
      );
      if (!mounted) return;
      setState(() => _busy = false);
      final saved = await showCardVerifyOtpSheet(
        context,
        session: session,
        pan: _pan,
        expiry: expiryToMmYy(_expiryCtrl.text),
      );
      if (!mounted || saved == null) return;
      Navigator.of(context).pop(saved);
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        // 409 is the one case with a precise cause the gateway can't phrase:
        // this exact card is already in the user's list.
        _error = e.response?.statusCode == 409
            ? 'card_already_saved'.tr()
            : PaymentError.fromDio(e) ?? _serverMessage(e);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'card_save_error'.tr();
      });
    }
  }

  String _serverMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      final m = data['message'];
      return m is List ? m.join(', ') : m.toString();
    }
    return 'card_save_error'.tr();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return PaymentSheetShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('card_add_title'.tr(),
              style: AppText.bold18.copyWith(color: c.textPrimary)),
          12.kh,
          PaymentField(
            controller: _numberCtrl,
            hint: 'pay_card_number_hint'.tr(),
            keyboardType: TextInputType.number,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(19),
              const CardNumberInputFormatter(),
            ],
            suffix: CardArtwork(brand: CardBrand.fromPan(_pan)),
          ),
          10.kh,
          PaymentField(
            controller: _expiryCtrl,
            focusNode: _expiryFocus,
            hint: 'pay_card_expiry_hint'.tr(),
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              const ExpiryInputFormatter(),
            ],
          ),
          12.kh,
          // The charge is disclosed before it happens, not after. An
          // unannounced debit from a screen that says "add card" reads as
          // fraud, and support hears about it.
          _VerificationNotice(),
          if (_error != null) ...[
            12.kh,
            PaymentErrorNote(message: _error!),
          ],
          16.kh,
          PaymentSheetActions(
            primaryLabel: 'card_continue'.tr(),
            busy: _busy,
            onPrimary: _isValid && !_busy ? _submit : null,
            onCancel: _busy ? null : () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

/// Explains the verification charge in the user's language, before they tap.
class _VerificationNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.brandPurple.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              size: 16.sp, color: AppColors.brandPurple),
          8.kw,
          Expanded(
            child: Text(
              'card_verify_notice'.tr(),
              style: AppText.regular12
                  .copyWith(color: c.textSecondary, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
