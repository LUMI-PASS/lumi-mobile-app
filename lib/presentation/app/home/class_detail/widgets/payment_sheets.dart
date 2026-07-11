import 'package:easy_localization/easy_localization.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
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

/// Confirms the OTP for a Paylov card payment.
typedef PaymentConfirmCard = Future<PaylovCardConfirmResult> Function({
  required String transactionId,
  required String cid,
  required String otp,
});

/// Payment rail the buyer can pick. Nothing is picked for them — the booking
/// screen starts with no selection and blocks paying until this is set.
enum PaymentRail {
  payme('payme', 'Payme'),
  click('click', 'Click'),
  uzum('uzum', 'Uzum'),
  card('card', '');

  const PaymentRail(this.providerKey, this.brandName);

  /// Backend `payment_provider` value. Every rail — including Payme — routes
  /// through Paylov (WLCM); the direct Paycom path is no longer used.
  final String providerKey;

  /// Wordmark shown in the booking row. Empty for [card], whose row shows the
  /// chosen card's brand + masked number instead.
  final String brandName;
}

/// Card brands we can show artwork for.
///
/// A fixed vocabulary the backend will eventually send, so it is modelled as an
/// enum with a non-throwing [fromKey] and an [unknown] fallback rather than raw
/// strings.
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

  /// Best-effort brand detection from the PAN's issuer prefix — the gateway
  /// doesn't tell us the brand, and the row has to show the right artwork.
  static CardBrand fromPan(String pan) {
    final d = pan.replaceAll(RegExp(r'[^0-9]'), '');
    if (d.length < 4) return CardBrand.unknown;
    final p4 = int.tryParse(d.substring(0, 4)) ?? 0;
    final p2 = int.tryParse(d.substring(0, 2)) ?? 0;
    if (p4 == 8600 || p4 == 5614) return CardBrand.uzcard;
    if (p4 == 9860) return CardBrand.humo;
    if (p2 >= 51 && p2 <= 55) return CardBrand.mastercard;
    if (p4 >= 2221 && p4 <= 2720) return CardBrand.mastercard;
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

/// A card the buyer entered in this session.
///
/// Paylov re-charges the full PAN + expiry on every payment, so the details are
/// kept alongside the display fields; they never leave the booking screen.
class PaymentCard {
  const PaymentCard({
    required this.brand,
    required this.pan,
    required this.expiry,
  });

  /// 16 digits, unformatted.
  final String pan;

  /// MMYY, unformatted.
  final String expiry;

  final CardBrand brand;

  String get last4 =>
      pan.length >= 4 ? pan.substring(pan.length - 4) : pan;

  /// "UzCard •••• 8534" — what the booking row and the card list show.
  String get label => '${brand.label} •••• $last4';
}

/// What the chooser sheet hands back: the rail, plus the card when the buyer
/// picked the card rail.
class PaymentSelection {
  const PaymentSelection({required this.rail, this.card});

  final PaymentRail rail;
  final PaymentCard? card;

  /// A card rail with no card attached can't be charged.
  bool get isPayable => rail != PaymentRail.card || card != null;
}

/// Opens the "choose a payment type" sheet (Figma "Выберите тип оплаты").
///
/// This sheet only *chooses* — it never charges. It returns the selection (or
/// null if dismissed); the caller pays with it from its own CTA. Cards added in
/// the sheet come back attached to the selection so the caller can remember
/// them for the rest of the session.
Future<PaymentSelection?> showPaymentChooser(
  BuildContext context, {
  PaymentSelection? initial,
  List<PaymentCard> cards = const [],
}) {
  return showModalBottomSheet<PaymentSelection>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    // No SafeArea: it would reserve the home-indicator inset *outside* the
    // sheet, leaving a dead gap under it. The shell pads for that inset itself.
    useSafeArea: false,
    builder: (_) => _ChooserSheet(initial: initial, cards: cards),
  );
}

/// Opens the OTP step for a Paylov card charge that is awaiting confirmation.
/// Resolves true once the payment is confirmed, false/null if the buyer backs
/// out.
Future<bool?> showCardOtpSheet(
  BuildContext context, {
  required CheckoutResult checkout,
  required PaymentConfirmCard confirmCard,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: false,
    isDismissible: false,
    builder: (_) => _OtpSheet(checkout: checkout, confirmCard: confirmCard),
  );
}

// ─── Shared sheet chrome ──────────────────────────────────────────────────────

class _SheetShell extends StatelessWidget {
  const _SheetShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final media = MediaQuery.of(context);
    // Clear the home indicator from *inside* the sheet, and lift the whole
    // thing above the keyboard when a field is focused.
    final bottomInset = media.padding.bottom + media.viewInsets.bottom;
    return Container(
      constraints: BoxConstraints(maxHeight: 0.9.sh),
      decoration: BoxDecoration(
        color: c.scaffoldBg,
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
        color: AppColors.error.withValues(alpha: 0.12),
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

/// Figma `Input Bg` — the dark tile behind the "add card" plus. Screen-local.
const Color _kAddCardTile = Color(0xFF2A2A2A);

/// A pale input on the payment sheets (card number, expiry).
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
      height: 48.h,
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
              style: AppText.medium16.copyWith(color: AppColors.ink),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                hintText: hint,
                hintStyle:
                    AppText.medium16.copyWith(color: AppColors.inkMuted),
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
                color: AppColors.lightDivider,
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
///
/// The artwork is fitted, not cropped: the brand marks don't share an aspect
/// ratio (UzCard/Humo ship as card rectangles, MasterCard as a near-square
/// logo), so `cover` would slice the edges off the square ones.
class CardArtwork extends StatelessWidget {
  const CardArtwork({super.key, required this.brand, this.width = 44, this.height = 28});

  final CardBrand brand;
  final double width;
  final double height;

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
            : art.image(fit: BoxFit.contain),
      ),
    );
  }
}

// ─── Chooser sheet (rail + card) ──────────────────────────────────────────────

enum _Step { choose, addCard }

class _ChooserSheet extends StatefulWidget {
  const _ChooserSheet({required this.initial, required this.cards});

  final PaymentSelection? initial;
  final List<PaymentCard> cards;

  @override
  State<_ChooserSheet> createState() => _ChooserSheetState();
}

class _ChooserSheetState extends State<_ChooserSheet> {
  _Step _step = _Step.choose;

  /// Null until the buyer picks — the sheet opens with nothing selected unless
  /// it was given a previous choice.
  late PaymentRail? _rail = widget.initial?.rail;
  late PaymentCard? _card = widget.initial?.card;
  late final List<PaymentCard> _cards = [...widget.cards];

  final _numberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();

  String? _error;

  @override
  void dispose() {
    _numberCtrl.dispose();
    _expiryCtrl.dispose();
    super.dispose();
  }

  PaymentSelection? get _selection {
    final rail = _rail;
    if (rail == null) return null;
    final sel = PaymentSelection(
      rail: rail,
      card: rail == PaymentRail.card ? _card : null,
    );
    return sel.isPayable ? sel : null;
  }

  /// Validates the typed PAN + expiry, then keeps the card in the session list
  /// and selects it. No gateway call happens here — the buyer still has to
  /// confirm the choice and pay from the booking screen.
  void _saveCard() {
    final pan = _numberCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    final expiry = _expiryCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (pan.length < 16) {
      setState(() => _error = 'pay_card_number_invalid'.tr());
      return;
    }
    if (expiry.length < 4) {
      setState(() => _error = 'pay_card_expiry_invalid'.tr());
      return;
    }
    final card = PaymentCard(
      brand: CardBrand.fromPan(pan),
      pan: pan,
      expiry: expiry,
    );
    setState(() {
      _error = null;
      _cards.add(card);
      _card = card;
      _rail = PaymentRail.card;
      _numberCtrl.clear();
      _expiryCtrl.clear();
      _step = _Step.choose;
    });
  }

  @override
  Widget build(BuildContext context) {
    return switch (_step) {
      _Step.choose => _buildChoose(),
      _Step.addCard => _buildAddCard(),
    };
  }

  // ── Step: choose rail (and card, on the card rail) ──────────────────────────
  Widget _buildChoose() {
    final c = context.colors;
    final isCard = _rail == PaymentRail.card;
    final selection = _selection;
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
          _railTile(
            PaymentRail.click,
            logo: Assets.images.pay.clickLight,
            logoHeight: 20,
          ),
          4.verticalSpace,
          _railTile(PaymentRail.payme,
              logo: Assets.images.pay.payme, logoHeight: 24),
          4.verticalSpace,
          _railTile(PaymentRail.uzum,
              logo: Assets.images.pay.uzum, logoHeight: 24),
          4.verticalSpace,
          _railTile(PaymentRail.card),
          // The card list belongs to the card rail — it only appears once that
          // rail is picked, as in the design.
          if (isCard) ...[
            20.verticalSpace,
            Text('pay_choose_card'.tr(),
                style: AppText.semibold14.copyWith(color: AppColors.inkMuted)),
            14.verticalSpace,
            for (var i = 0; i < _cards.length; i++) ...[
              if (i > 0) _cardDivider(),
              _cardRow(_cards[i]),
            ],
            if (_cards.isNotEmpty) _cardDivider(),
            _addCardRow(),
          ],
          20.verticalSpace,
          _SheetActions(
            primaryLabel: 'pay_select'.tr(),
            onCancel: () => Navigator.of(context).pop(),
            // Stays disabled until the choice can actually be paid with: a rail,
            // and on the card rail a card to charge.
            onPrimary: selection == null
                ? null
                : () => Navigator.of(context).pop(selection),
          ),
        ],
      ),
    );
  }

  /// One payment-rail tile: a pale card holding the provider wordmark (or the
  /// card icon + label for the card rail) and the selection radio.
  Widget _railTile(
    PaymentRail r, {
    AssetGenImage? logo,
    double logoHeight = 20,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() {
        _error = null;
        _rail = r;
      }),
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
            _radio(_rail == r),
          ],
        ),
      ),
    );
  }

  /// Hairline between saved-card rows, inset past the artwork as in the design.
  Widget _cardDivider() => Padding(
        padding: EdgeInsets.only(left: 60.w),
        child: Container(height: 1, color: AppColors.lightDivider),
      );

  Widget _cardRow(PaymentCard card) {
    final selected = identical(_card, card);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() {
        _error = null;
        _rail = PaymentRail.card;
        _card = card;
      }),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: Row(
          children: [
            CardArtwork(brand: card.brand),
            16.horizontalSpace,
            Expanded(
              child: Text(
                card.label,
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
              width: 44.w,
              height: 28.h,
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
          color: AppColors.tagGreen,
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
    final c = context.colors;
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
            onCancel: () => setState(() {
              _error = null;
              _step = _Step.choose;
            }),
            onPrimary: _saveCard,
          ),
        ],
      ),
    );
  }
}

// ─── OTP sheet (card charge confirmation) ─────────────────────────────────────

class _OtpSheet extends StatefulWidget {
  const _OtpSheet({required this.checkout, required this.confirmCard});

  final CheckoutResult checkout;
  final PaymentConfirmCard confirmCard;

  @override
  State<_OtpSheet> createState() => _OtpSheetState();
}

class _OtpSheetState extends State<_OtpSheet> {
  final _otpCtrl = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
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
        transactionId: widget.checkout.transactionId ?? '',
        cid: widget.checkout.cid ?? '',
        otp: otp,
      );
      if (!mounted) return;
      if (res.success) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _busy = false;
          _error = res.message ?? 'pay_code_invalid'.tr();
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e is CheckoutFriendlyError ? e.message : e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final phone = widget.checkout.otpSentPhone;
    return _SheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('pay_confirm'.tr(),
              style: AppText.heading20.copyWith(color: c.textPrimary)),
          8.verticalSpace,
          Text(
            phone != null
                ? 'pay_code_sent_to'.tr(args: [phone])
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
          _SheetActions(
            primaryLabel: 'next'.tr(),
            busy: _busy,
            onCancel: _busy ? null : () => Navigator.of(context).pop(false),
            onPrimary: _confirm,
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
