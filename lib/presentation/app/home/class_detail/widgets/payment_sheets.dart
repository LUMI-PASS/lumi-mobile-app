import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/auth/auth_fields.dart';
import 'package:lumi_pass/common/widget/auth/auth_misc.dart';
import 'package:lumi_pass/common/widget/auth/gradient_button.dart';
import 'package:lumi_pass/data/api_model/order/order_model.dart';

/// Starts a checkout for the chosen rail and returns how to pay for it.
///  • [provider] null  → the direct Payme (Paycom) flow — returns a checkout URL.
///  • [provider] 'click'/'uzum'/'paylov' → Paylov redirect — returns a checkout URL.
///  • [provider] 'card' → Paylov card — also pass [cardNumber]+[expireDate]; the
///    result carries transaction_id/cid for the OTP step.
typedef PaymentStartCheckout = Future<CheckoutResult> Function({
  String? provider,
  String? cardNumber,
  String? expireDate,
});

/// Confirms the OTP for a Paylov card payment.
typedef PaymentConfirmCard = Future<PaylovCardConfirmResult> Function({
  required String transactionId,
  required String cid,
  required String otp,
});

typedef CheckoutResultCallback = void Function(CheckoutResult result);

/// The redesigned payment flow (Figma "Выберите тип оплаты → Добавить карту →
/// Подтверждение"), now wired to the live gateway.
///
/// Redirect rails (Payme via the proven direct flow, Click/Uzum via Paylov)
/// call [onRedirect] with the checkout result so the caller can open the
/// checkout page. The card rail collects the PAN + expiry, runs a Paylov card
/// checkout, confirms the OTP in-sheet and then calls [onCardPaid].
/// Payment rail the buyer can pick — exposed so the booking screen can show the
/// current choice in its "Способ оплаты" row.
enum PaymentRail { payme, click, uzum, card }

void showPaymentFlow(
  BuildContext context, {
  required PaymentStartCheckout startCheckout,
  required PaymentConfirmCard confirmCard,
  required CheckoutResultCallback onRedirect,
  required CheckoutResultCallback onCardPaid,
  PaymentRail initial = PaymentRail.card,
  ValueChanged<PaymentRail>? onRailChanged,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _PaymentSheet(
      startCheckout: startCheckout,
      confirmCard: confirmCard,
      onRedirect: onRedirect,
      onCardPaid: onCardPaid,
      initial: initial,
      onRailChanged: onRailChanged,
    ),
  );
}

PaymentRail _railOf(_PayMethod m) => switch (m) {
      _PayMethod.payme => PaymentRail.payme,
      _PayMethod.click => PaymentRail.click,
      _PayMethod.uzum => PaymentRail.uzum,
      _PayMethod.card => PaymentRail.card,
    };
_PayMethod _methodOf(PaymentRail r) => switch (r) {
      PaymentRail.payme => _PayMethod.payme,
      PaymentRail.click => _PayMethod.click,
      PaymentRail.uzum => _PayMethod.uzum,
      PaymentRail.card => _PayMethod.card,
    };

// ─── Shared sheet chrome ──────────────────────────────────────────────────────

class _SheetShell extends StatelessWidget {
  const _SheetShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 8.h,
        bottom: 16.h + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              color: c.control,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Inline error banner shown inside a payment step when a gateway call fails.
class _ErrorNote extends StatelessWidget {
  const _ErrorNote({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              size: 16.sp, color: AppColors.error),
          8.horizontalSpace,
          Expanded(
            child: Text(message,
                style: AppText.regular12.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ─── Payment sheet (choose → add card → OTP) ──────────────────────────────────

enum _PayMethod { click, payme, uzum, card }

enum _Step { choose, addCard, otp }

/// Maps a UI method to the backend `payment_provider`. Every rail — including
/// Payme — now routes through Paylov (WLCM); the direct Paycom path is no longer
/// used from booking, so the app never falls back to Paycom.
String _providerFor(_PayMethod m) {
  switch (m) {
    case _PayMethod.payme:
      return 'payme';
    case _PayMethod.click:
      return 'click';
    case _PayMethod.uzum:
      return 'uzum';
    case _PayMethod.card:
      return 'card';
  }
}

class _PaymentSheet extends StatefulWidget {
  const _PaymentSheet({
    required this.startCheckout,
    required this.confirmCard,
    required this.onRedirect,
    required this.onCardPaid,
    required this.initial,
    this.onRailChanged,
  });

  final PaymentStartCheckout startCheckout;
  final PaymentConfirmCard confirmCard;
  final CheckoutResultCallback onRedirect;
  final CheckoutResultCallback onCardPaid;
  final PaymentRail initial;
  final ValueChanged<PaymentRail>? onRailChanged;

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  _Step _step = _Step.choose;
  late _PayMethod _method = _methodOf(widget.initial);
  int _cardIndex = 0;

  void _selectMethod(_PayMethod m) {
    setState(() => _method = m);
    widget.onRailChanged?.call(_railOf(m));
  }

  final _numberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();

  bool _busy = false;
  String? _error;
  // The Paylov card checkout awaiting OTP confirmation.
  CheckoutResult? _cardCheckout;

  // Illustrative saved cards. Paylov charges a full PAN + expiry each time, so
  // paying still routes through the add-card step; these are display only.
  static const _cards = [
    'UzCard •••• 8534',
    'Humo •••• 8534',
    'MasterCard •••• 8534',
  ];

  @override
  void dispose() {
    _numberCtrl.dispose();
    _expiryCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  void _fail(Object e) {
    setState(() {
      _busy = false;
      _error = e is CheckoutFriendlyError ? e.message : e.toString();
    });
  }

  /// Pop the sheet and hand the result back to the caller.
  void _closeWith(void Function() action) {
    Navigator.of(context).pop();
    action();
  }

  // ── Redirect rails (Payme direct, Click/Uzum via Paylov) ────────────────────
  Future<void> _payRedirect() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result =
          await widget.startCheckout(provider: _providerFor(_method));
      if (!mounted) return;
      _closeWith(() => widget.onRedirect(result));
    } catch (e) {
      if (mounted) _fail(e);
    }
  }

  // ── Card rail step 1: PAN + expiry → Paylov card checkout ───────────────────
  Future<void> _startCardCheckout() async {
    final pan = _numberCtrl.text.replaceAll(RegExp(r'\s'), '');
    final expiry = _expiryCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (pan.length < 16) {
      setState(() => _error = 'pay_card_number_invalid'.tr());
      return;
    }
    if (expiry.length < 4) {
      setState(() => _error = 'pay_card_expiry_invalid'.tr());
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await widget.startCheckout(
        provider: 'card',
        cardNumber: pan,
        expireDate: expiry,
      );
      if (!mounted) return;
      // A card checkout should return a transaction to confirm via OTP. If the
      // gateway instead handed back a redirect URL, honour that path.
      if (result.isCardOtpPending) {
        setState(() {
          _busy = false;
          _cardCheckout = result;
          _step = _Step.otp;
        });
      } else if (result.checkoutUrl.isNotEmpty) {
        _closeWith(() => widget.onRedirect(result));
      } else {
        setState(() {
          _busy = false;
          _error = 'pay_generic_error'.tr();
        });
      }
    } catch (e) {
      if (mounted) _fail(e);
    }
  }

  // ── Card rail step 2: OTP confirmation ──────────────────────────────────────
  Future<void> _confirmOtp() async {
    final checkout = _cardCheckout;
    if (checkout == null) return;
    final otp = _otpCtrl.text.trim();
    if (otp.isEmpty) {
      setState(() => _error = 'pay_enter_code'.tr());
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final res = await widget.confirmCard(
        transactionId: checkout.transactionId ?? '',
        cid: checkout.cid ?? '',
        otp: otp,
      );
      if (!mounted) return;
      if (res.success) {
        _closeWith(() => widget.onCardPaid(checkout));
      } else {
        setState(() {
          _busy = false;
          _error = res.message ?? 'pay_code_invalid'.tr();
        });
      }
    } catch (e) {
      if (mounted) _fail(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case _Step.choose:
        return _buildChoose();
      case _Step.addCard:
        return _buildAddCard();
      case _Step.otp:
        return _buildOtp();
    }
  }

  // ── Step: choose method ─────────────────────────────────────────────────────
  Widget _buildChoose() {
    final c = context.appColors;
    return _SheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text('pay_choose_type'.tr(),
                style: AppText.bold18.copyWith(color: c.textPrimary)),
          ),
          16.verticalSpace,
          if (_error != null) _ErrorNote(message: _error!),
          _methodLogo('click', 20, _PayMethod.click),
          4.verticalSpace,
          _methodLogo('payme', 24, _PayMethod.payme),
          4.verticalSpace,
          _methodLogo('uzum', 24, _PayMethod.uzum),
          4.verticalSpace,
          _cardRow(),
          // Always show the saved cards + "Добавить карту" so every option
          // (click / payme / uzum / card + card-adding) is visible at once.
          16.verticalSpace,
          Text('pay_choose_card'.tr(),
              style: AppText.regular12.copyWith(color: c.textSecondary)),
          8.verticalSpace,
          ...List.generate(_cards.length, (i) {
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: _savedCard(_cards[i], i),
            );
          }),
          _addCardRow(),
          16.verticalSpace,
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _busy ? null : () => Navigator.of(context).pop(),
                  child: Container(
                    height: 50.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Text('cancel'.tr(),
                        style:
                            AppText.medium16.copyWith(color: c.textPrimary)),
                  ),
                ),
              ),
              12.horizontalSpace,
              Expanded(
                child: GradientButton(
                  text: 'pay_now'.tr(),
                  loading: _busy,
                  onPressed: () {
                    if (_method == _PayMethod.card) {
                      setState(() {
                        _error = null;
                        _step = _Step.addCard;
                      });
                    } else {
                      _payRedirect();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _methodLogo(String asset, double h, _PayMethod m) {
    final c = context.appColors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _selectMethod(m),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Image.asset('assets/icons/pay/$asset.png',
                height: h.h, fit: BoxFit.contain),
            const Spacer(),
            _radio(_method == m),
          ],
        ),
      ),
    );
  }

  Widget _cardRow() {
    final c = context.appColors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _selectMethod(_PayMethod.card),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(Icons.credit_card_rounded, size: 18.sp, color: c.textPrimary),
            10.horizontalSpace,
            Text('pay_with_card'.tr(),
                style: AppText.medium16.copyWith(color: c.textPrimary)),
            const Spacer(),
            _radio(_method == _PayMethod.card),
          ],
        ),
      ),
    );
  }

  Widget _savedCard(String label, int i) {
    final c = context.appColors;
    final selected = _method == _PayMethod.card && _cardIndex == i;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() => _cardIndex = i);
        _selectMethod(_PayMethod.card);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              width: 32.w,
              height: 22.h,
              decoration: BoxDecoration(
                color: c.control,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child:
                  Icon(Icons.credit_card, size: 14.sp, color: c.textSecondary),
            ),
            10.horizontalSpace,
            Text(label, style: AppText.medium14.copyWith(color: c.textPrimary)),
            const Spacer(),
            _radio(selected),
          ],
        ),
      ),
    );
  }

  Widget _addCardRow() {
    final c = context.appColors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() {
        _error = null;
        _step = _Step.addCard;
      }),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.add, size: 18.sp, color: c.textPrimary),
            ),
            10.horizontalSpace,
            Text('pay_add_card'.tr(),
                style: AppText.medium16.copyWith(color: c.textPrimary)),
            const Spacer(),
            Icon(Icons.chevron_right_rounded,
                size: 20.sp, color: c.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _radio(bool selected) {
    if (selected) {
      return Icon(Icons.check_circle_rounded,
          size: 22.sp, color: AppColors.badgeGreen);
    }
    return Container(
      width: 20.w,
      height: 20.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: context.appColors.controlBorder, width: 1.5),
      ),
    );
  }

  // ── Step: add card ──────────────────────────────────────────────────────────
  Widget _buildAddCard() {
    final c = context.appColors;
    return _SheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader('pay_add_card'.tr(),
              onBack: _busy ? null : () => setState(() => _step = _Step.choose)),
          16.verticalSpace,
          if (_error != null) _ErrorNote(message: _error!),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(Icons.credit_card_rounded,
                    size: 18.sp, color: c.textSecondary),
                10.horizontalSpace,
                Expanded(
                  child: TextField(
                    controller: _numberCtrl,
                    keyboardType: TextInputType.number,
                    cursorColor: AppColors.brandPurple,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(16),
                      _CardNumberFormatter(),
                    ],
                    style: AppText.medium16.copyWith(color: c.textPrimary),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '0000 0000 0000 0000',
                      hintStyle:
                          AppText.medium16.copyWith(color: c.textPlaceholder),
                    ),
                  ),
                ),
              ],
            ),
          ),
          12.verticalSpace,
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 16.sp, color: c.textSecondary),
                10.horizontalSpace,
                Expanded(
                  child: TextField(
                    controller: _expiryCtrl,
                    keyboardType: TextInputType.number,
                    cursorColor: AppColors.brandPurple,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                      _ExpiryFormatter(),
                    ],
                    style: AppText.medium16.copyWith(color: c.textPrimary),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'MM/YY',
                      hintStyle:
                          AppText.medium16.copyWith(color: c.textPlaceholder),
                    ),
                  ),
                ),
              ],
            ),
          ),
          20.verticalSpace,
          GradientButton(
            text: 'pay_send_sms'.tr(),
            loading: _busy,
            onPressed: _startCardCheckout,
          ),
        ],
      ),
    );
  }

  // ── Step: OTP ───────────────────────────────────────────────────────────────
  Widget _buildOtp() {
    final c = context.appColors;
    return _SheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('pay_confirm'.tr(),
              style: AppText.heading20.copyWith(color: c.textPrimary)),
          8.verticalSpace,
          Text(
            _cardCheckout?.otpSentPhone != null
                ? 'pay_code_sent_to'.tr(args: [_cardCheckout!.otpSentPhone!])
                : 'pay_code_sent'.tr(),
            textAlign: TextAlign.center,
            style: AppText.regular14.copyWith(color: c.textSecondary),
          ),
          20.verticalSpace,
          if (_error != null) _ErrorNote(message: _error!),
          OtpCodeField(controller: _otpCtrl),
          16.verticalSpace,
          const CountdownTimer(seconds: 57),
          16.verticalSpace,
          Text('pay_resend'.tr(),
              style: AppText.medium14.copyWith(color: c.textSecondary)),
          20.verticalSpace,
          GradientButton(
            text: 'next'.tr(),
            loading: _busy,
            onPressed: _confirmOtp,
          ),
        ],
      ),
    );
  }

  Widget _stepHeader(String title, {VoidCallback? onBack}) {
    final c = context.appColors;
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onBack,
          child: Icon(Icons.arrow_back_ios_new_rounded,
              size: 16.sp, color: c.textPrimary),
        ),
        Expanded(
          child: Center(
            child: Text(title,
                style: AppText.bold18.copyWith(color: c.textPrimary)),
          ),
        ),
        SizedBox(width: 16.sp),
      ],
    );
  }
}

/// Wrapper so a caller can surface a clean, localized error message to the
/// sheet instead of a raw exception string.
class CheckoutFriendlyError implements Exception {
  const CheckoutFriendlyError(this.message);
  final String message;
  @override
  String toString() => message;
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(' ', '');
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i != 0 && i % 4 == 0) buf.write(' ');
      buf.write(digits[i]);
    }
    return TextEditingValue(
      text: buf.toString(),
      selection: TextSelection.collapsed(offset: buf.length),
    );
  }
}

/// Formats an expiry as MM/YY while the underlying value stays 4 digits (MMYY).
class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2) buf.write('/');
      buf.write(digits[i]);
    }
    return TextEditingValue(
      text: buf.toString(),
      selection: TextSelection.collapsed(offset: buf.length),
    );
  }
}
