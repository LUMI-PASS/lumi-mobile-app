import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
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

/// Card brands we can show artwork for.
///
/// The saved-card list is display-only today (Paylov re-collects the full PAN on
/// every charge), but the brand is a fixed vocabulary that the backend will
/// eventually send, so it is modelled as an enum with a non-throwing [fromKey]
/// and an [unknown] fallback rather than raw strings.
enum CardBrand {
  uzcard('uzcard', 'UzCard'),
  humo('humo', 'Humo'),
  mastercard('mastercard', 'MasterCard'),
  unknown('unknown', 'Card');

  const CardBrand(this.key, this.label);

  /// Wire value.
  final String key;

  /// Display name shown next to the masked digits.
  final String label;

  static CardBrand fromKey(String? key) {
    final k = key?.trim().toLowerCase();
    for (final b in values) {
      if (b.key == k) return b;
    }
    return CardBrand.unknown;
  }

  /// Brand artwork, or `null` for [unknown] — the row then falls back to a
  /// neutral card tile.
  AssetGenImage? get artwork => switch (this) {
        CardBrand.uzcard => Assets.images.pay.uzcard,
        CardBrand.humo => Assets.images.pay.humo,
        CardBrand.mastercard => Assets.images.pay.mastercard,
        CardBrand.unknown => null,
      };
}

/// A card shown in the "choose a card" list.
class SavedCard {
  const SavedCard({required this.brand, required this.last4});

  final CardBrand brand;
  final String last4;
}

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
    // No SafeArea: it would reserve the home-indicator inset *outside* the
    // sheet, leaving a dead gap under it. The shell pads for that inset itself.
    useSafeArea: false,
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
    final media = MediaQuery.of(context);
    // Clear the home indicator from *inside* the sheet, and lift the whole
    // thing above the keyboard when a field is focused.
    final bottomInset = media.padding.bottom + media.viewInsets.bottom;
    return Container(
      constraints: BoxConstraints(maxHeight: 0.9.sh),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.only(
        left: 14.w,
        right: 14.w,
        top: 12.h,
        bottom: 12.h + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: 12.h),
            decoration: BoxDecoration(
              // Figma `Pull`: rgba(170,178,188,0.35).
              color: const Color(0xFFAAB2BC).withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          // The card list can outgrow the sheet on small screens, so the body
          // scrolls inside the shell instead of overflowing it.
          Flexible(
            child: SingleChildScrollView(child: child),
          ),
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

/// Figma `Input Bg` — the dark tile behind the "add card" plus. Screen-local.
const Color _kAddCardTile = Color(0xFF2A2A2A);

/// A pale 42px input on the payment sheets (card number, expiry).
class _PayField extends StatelessWidget {
  const _PayField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.suffix,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.inkChip,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              cursorColor: AppColors.link,
              style: AppText.regular14.copyWith(color: AppColors.ink),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                hintText: hint,
                hintStyle:
                    AppText.regular12.copyWith(color: AppColors.inkMuted),
              ),
            ),
          ),
          if (suffix != null) suffix!,
        ],
      ),
    );
  }
}

/// The paired "Cancel" / gradient-CTA footer shared by the payment sheets.
class _SheetActions extends StatelessWidget {
  const _SheetActions({
    required this.primaryLabel,
    required this.onPrimary,
    required this.onCancel,
    this.busy = false,
  });

  final String primaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback? onCancel;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onCancel,
            child: Container(
              height: 50.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(44.r),
              ),
              child: Text('cancel'.tr(),
                  style:
                      AppText.medium16.copyWith(color: AppColors.greeting)),
            ),
          ),
        ),
        8.horizontalSpace,
        Expanded(
          child: GradientButton(
            text: primaryLabel,
            loading: busy,
            onPressed: onPrimary,
          ),
        ),
      ],
    );
  }
}

/// The 44×28 brand tile in the saved-card list. Falls back to a neutral card
/// glyph when the brand has no artwork ([CardBrand.unknown]).
class _CardArtwork extends StatelessWidget {
  const _CardArtwork({required this.brand});

  static const double width = 44;
  static const double height = 28;

  final CardBrand brand;

  @override
  Widget build(BuildContext context) {
    final art = brand.artwork;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4.r),
      child: SizedBox(
        width: width.w,
        height: height.h,
        child: art == null
            ? ColoredBox(
                color: AppColors.inkChip,
                child: Icon(Icons.credit_card_rounded,
                    size: 16.sp, color: AppColors.inkMuted),
              )
            : art.image(fit: BoxFit.cover),
      ),
    );
  }
}

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
    SavedCard(brand: CardBrand.uzcard, last4: '8534'),
    SavedCard(brand: CardBrand.humo, last4: '8534'),
    SavedCard(brand: CardBrand.mastercard, last4: '8534'),
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
    final isCard = _method == _PayMethod.card;
    return _SheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text('pay_choose_type'.tr(),
                style: AppText.heading20.copyWith(color: c.textPrimary)),
          ),
          20.verticalSpace,
          if (_error != null) _ErrorNote(message: _error!),
          // The Click wordmark ships in two tints; the rail tiles are always the
          // pale `inkChip` fill, so the dark glyph is the one that reads.
          _methodTile(
            _PayMethod.click,
            logo: Assets.images.pay.clickLight,
            logoHeight: 20,
          ),
          4.verticalSpace,
          _methodTile(_PayMethod.payme,
              logo: Assets.images.pay.payme, logoHeight: 24),
          4.verticalSpace,
          _methodTile(_PayMethod.uzum,
              logo: Assets.images.pay.uzum, logoHeight: 24),
          4.verticalSpace,
          _methodTile(_PayMethod.card),
          // The card list belongs to the card rail — it only appears once that
          // rail is picked, as in the design.
          if (isCard) ...[
            20.verticalSpace,
            Text('pay_choose_card'.tr(),
                style: AppText.semibold14.copyWith(color: AppColors.inkMuted)),
            14.verticalSpace,
            for (var i = 0; i < _cards.length; i++) ...[
              if (i > 0) _cardDivider(),
              _savedCardRow(_cards[i], i),
            ],
            _cardDivider(),
            _addCardRow(),
          ],
          20.verticalSpace,
          _SheetActions(
            primaryLabel: 'pay_now'.tr(),
            busy: _busy,
            onCancel: _busy ? null : () => Navigator.of(context).pop(),
            onPrimary: () {
              // The card rail needs a PAN + expiry before it can charge, so it
              // advances to the add-card step; the redirect rails pay directly.
              if (isCard) {
                setState(() {
                  _error = null;
                  _step = _Step.addCard;
                });
              } else {
                _payRedirect();
              }
            },
          ),
        ],
      ),
    );
  }

  /// One payment-rail tile: a pale card holding the provider wordmark (or the
  /// card icon + label for the card rail) and the selection radio.
  Widget _methodTile(
    _PayMethod m, {
    AssetGenImage? logo,
    double logoHeight = 20,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _selectMethod(m),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.inkChip,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            if (logo != null)
              logo.image(height: logoHeight.h, fit: BoxFit.contain)
            else ...[
              Assets.icons.icCard.svg(
                width: 20.w,
                height: 20.w,
                colorFilter:
                    const ColorFilter.mode(AppColors.ink, BlendMode.srcIn),
              ),
              12.horizontalSpace,
              Text('pay_with_card'.tr(),
                  style: AppText.semibold16.copyWith(color: AppColors.ink)),
            ],
            const Spacer(),
            _radio(_method == m),
          ],
        ),
      ),
    );
  }

  /// Hairline between saved-card rows, inset past the artwork as in the design.
  Widget _cardDivider() => Padding(
        padding: EdgeInsets.only(left: 60.w),
        child: Container(height: 1, color: AppColors.divider),
      );

  Widget _savedCardRow(SavedCard card, int i) {
    final selected = _method == _PayMethod.card && _cardIndex == i;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() => _cardIndex = i);
        _selectMethod(_PayMethod.card);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: Row(
          children: [
            _CardArtwork(brand: card.brand),
            16.horizontalSpace,
            Expanded(
              child: Text(
                '${card.brand.label} •••• ${card.last4}',
                style: AppText.medium16.copyWith(color: AppColors.ink),
              ),
            ),
            _radio(selected),
          ],
        ),
      ),
    );
  }

  Widget _addCardRow() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() {
        _error = null;
        _step = _Step.addCard;
      }),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: _CardArtwork.width.w,
              height: _CardArtwork.height.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _kAddCardTile,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Icon(Icons.add_rounded,
                  size: 18.sp, color: AppColors.onBrand),
            ),
            16.horizontalSpace,
            Expanded(
              child: Text('pay_add_card'.tr(),
                  style: AppText.medium16.copyWith(color: AppColors.ink)),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 18.sp, color: AppColors.ink),
          ],
        ),
      ),
    );
  }

  /// Figma `_Checkbox base`: a hollow grey ring, or a filled green disc with a
  /// white tick once picked.
  Widget _radio(bool selected) {
    if (selected) {
      return Container(
        width: 16.w,
        height: 16.w,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.green,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.check_rounded, size: 11.sp, color: AppColors.onBrand),
      );
    }
    return Container(
      width: 16.w,
      height: 16.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.inkMuted),
      ),
    );
  }

  // ── Step: add card (Figma 131:3526) ─────────────────────────────────────────
  Widget _buildAddCard() {
    final c = context.appColors;
    return _SheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Text('pay_add_card'.tr(),
                    style: AppText.heading20.copyWith(color: c.textPrimary)),
                8.verticalSpace,
                Text(
                  'pay_add_card_subtitle'.tr(),
                  textAlign: TextAlign.center,
                  style:
                      AppText.regular14.copyWith(color: AppColors.inkMuted),
                ),
              ],
            ),
          ),
          20.verticalSpace,
          if (_error != null) _ErrorNote(message: _error!),
          _PayField(
            controller: _numberCtrl,
            hint: 'pay_card_number_hint'.tr(),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              _CardNumberFormatter(),
            ],
            suffix: Assets.icons.icCardScan.svg(
              width: 24.w,
              height: 24.w,
              colorFilter:
                  const ColorFilter.mode(AppColors.ink, BlendMode.srcIn),
            ),
          ),
          12.verticalSpace,
          // The expiry is a short field in the design, not full-bleed.
          SizedBox(
            width: 170.w,
            child: _PayField(
              controller: _expiryCtrl,
              hint: 'pay_card_expiry_hint'.tr(),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
                _ExpiryFormatter(),
              ],
            ),
          ),
          24.verticalSpace,
          _SheetActions(
            primaryLabel: 'pay_add_card'.tr(),
            busy: _busy,
            onCancel: _busy
                ? null
                : () => setState(() {
                      _error = null;
                      _step = _Step.choose;
                    }),
            onPrimary: _startCardCheckout,
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
