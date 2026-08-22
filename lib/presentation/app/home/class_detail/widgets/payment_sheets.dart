import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/utils/payment_error.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/auth/auth_fields.dart';
import 'package:lumi_pass/common/widget/auth/auth_misc.dart';
import 'package:lumi_pass/common/utils/card_input_formatters.dart';
import 'package:lumi_pass/common/widget/payment_sheet_chrome.dart';
import 'package:lumi_pass/data/api_model/order/order_model.dart';
import 'package:lumi_pass/data/api_model/order/saved_card.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';

// CardBrand and CardArtwork moved to the shared chrome; re-exported so the
// booking screens that import them from here keep working.
export 'package:lumi_pass/common/widget/payment_sheet_chrome.dart'
    show CardArtwork, CardBrand;

/// Whether paying by card is live.
///
/// The rail is built end-to-end — chooser form → `checkout(provider: card)` →
/// OTP confirm, plus saved cards charged through the same OTP challenge.
///
/// Set false to dim the card row back down: it still renders, with a "coming
/// soon" badge, so the buyer sees the rail is on the way but can't pick it.
/// That is the switch to reach for if the gateway starts refusing cards —
/// nothing else needs to change.
///
/// It does NOT gate the subscriptions screen, which pins the card row off for
/// its own reason (see `plans_page.dart`).
const bool kCardPaymentsEnabled = true;

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

/// A card offered in the chooser. Two flavours:
///  • a **bound** card ([savedCardId] set) — a WLCM token; charged server-side
///    with no PAN and no OTP;
///  • a **session** card (PAN + expiry, [savedCardId] null) — entered this
///    session and charged one-shot through the Paylov card checkout (OTP each
///    time). The PAN never leaves the booking screen.
class PaymentCard {
  const PaymentCard({
    required this.brand,
    required this.pan,
    required this.expiry,
    this.savedCardId,
  });

  /// 16 digits for a session card; the masked PAN for a bound card (only
  /// [last4] is read from it).
  final String pan;

  /// MMYY, unformatted. Empty for a bound card.
  final String expiry;

  final CardBrand brand;

  /// WLCM cardId token when this is a bound (saved) card; null for a session
  /// card that must still be charged with its PAN.
  final String? savedCardId;

  bool get isSaved => savedCardId != null;

  String get last4 {
    final d = pan.replaceAll(RegExp(r'[^0-9]'), '');
    return d.length >= 4 ? d.substring(d.length - 4) : d;
  }

  /// "UzCard •••• 8534" — what the booking row and the card list show.
  String get label => '${brand.label} •••• $last4';

  /// A bound card loaded from the backend.
  factory PaymentCard.saved(SavedCard c) => PaymentCard(
        brand: CardBrand.fromKey(c.vendor) == CardBrand.unknown
            ? CardBrand.fromPan(c.maskedNumber ?? '')
            : CardBrand.fromKey(c.vendor),
        pan: c.maskedNumber ?? '',
        expiry: '',
        savedCardId: c.id,
      );
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
/// This sheet only *chooses* — it never charges the order. A card typed into it
/// is BOUND (`/cards/verify` + OTP) and saved to the buyer's list; paying with
/// it is a separate, deliberate act on the caller's own Pay CTA.
///
/// Returns the selection (or null if dismissed). Cards added in the sheet come
/// back attached to it so the caller can remember them for the session.
Future<PaymentSelection?> showPaymentChooser(
  BuildContext context, {
  PaymentSelection? initial,
  List<PaymentCard> cards = const [],
  bool cardsComingSoon = false,
}) {
  return showModalBottomSheet<PaymentSelection>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    // No SafeArea: it would reserve the home-indicator inset *outside* the
    // sheet, leaving a dead gap under it. The shell pads for that inset itself.
    useSafeArea: false,
    builder: (_) => _ChooserSheet(
      initial: initial,
      cards: cards,
      cardsComingSoon: cardsComingSoon,
    ),
  );
}

/// Opens the OTP step for a Paylov card charge that is awaiting confirmation.
/// Resolves true once the payment is confirmed, false/null if the buyer backs
/// out.
Future<bool?> showCardOtpSheet(
  BuildContext context, {
  required String transactionId,
  required String cid,
  String? otpSentPhone,
  required PaymentConfirmCard confirmCard,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: false,
    isDismissible: false,
    builder: (_) => _OtpSheet(
      transactionId: transactionId,
      cid: cid,
      otpSentPhone: otpSentPhone,
      confirmCard: confirmCard,
    ),
  );
}

// ─── Shared sheet chrome ──────────────────────────────────────────────────────

/// Figma `Input Bg` — the dark tile behind the "add card" plus. Screen-local.
const Color _kAddCardTile = Color(0xFF2A2A2A);

// ─── Chooser sheet (rail + card) ──────────────────────────────────────────────

enum _Step { choose, addCard, bindOtp }

class _ChooserSheet extends StatefulWidget {
  const _ChooserSheet({
    required this.initial,
    required this.cards,
    this.cardsComingSoon = false,
  });

  final PaymentSelection? initial;
  final List<PaymentCard> cards;

  /// Shows the card rail as an inert "coming soon" row: no radio, no card list,
  /// no add-card step. The rail still appears — the buyer should see that paying
  /// by card is on the way — but it cannot be picked.
  final bool cardsComingSoon;

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
  final _otpCtrl = TextEditingController();

  String? _error;

  /// True while a bind request is in flight — keeps the buyer from firing a
  /// second OTP by tapping again.
  bool _busy = false;

  /// The in-progress card verification: the card has been charged 100 soum and
  /// the bank has SMSed an OTP we're waiting on.
  CardVerifySession? _binding;

  @override
  void initState() {
    super.initState();
    _loadSavedCards();
  }

  /// Pulls the buyer's bound cards from the backend and shows them at the top of
  /// the card list. Non-fatal on failure — a card can still be entered manually.
  Future<void> _loadSavedCards() async {
    // The card rail can't be picked, so its cards are never shown — don't pay
    // for the request.
    if (widget.cardsComingSoon) return;
    try {
      final saved = await getIt<OrdersApi>().getSavedCards();
      if (!mounted || saved.isEmpty) return;
      setState(() {
        final tokens = _cards.map((c) => c.savedCardId).whereType<String>().toSet();
        var i = 0;
        for (final s in saved) {
          if (tokens.contains(s.id)) continue;
          _cards.insert(i++, PaymentCard.saved(s));
        }
      });
    } catch (_) {
      // Ignore — the manual add-card path remains available.
    }
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _expiryCtrl.dispose();
    _otpCtrl.dispose();
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

  /// Validates the typed PAN + expiry and **binds** the card: `/cards/verify`
  /// charges it 100 soum, the bank SMSes the cardholder a code, and confirming
  /// that code on the next step is what saves the card ([_confirmBinding]).
  ///
  /// Adding a card does not pay for anything. This sheet used to run the whole
  /// checkout from here — typing a card charged the full order on the spot and
  /// saved nothing — so a buyer who only meant to add a card was billed for the
  /// booking. Now the card lands in their list and they press Pay themselves.
  Future<void> _saveCard() async {
    final pan = _numberCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    // Two orders of the same four digits: the field is typed MM/YY, the gateway
    // reads YYMM. Sending it as typed reports every valid card as expired, so
    // the bind gets the converted form and a session card keeps the typed one
    // (the booking screen converts that itself on the way out).
    final typed = _expiryCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    final expiry = expiryToYyMm(_expiryCtrl.text);
    if (pan.length < 16) {
      setState(() => _error = 'pay_card_number_invalid'.tr());
      return;
    }
    if (expiry.isEmpty) {
      setState(() => _error = 'pay_card_expiry_invalid'.tr());
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final session = await getIt<OrdersApi>().verifyCard(
        cardNumber: pan,
        expireDate: expiry,
      );
      if (!mounted) return;
      setState(() {
        _busy = false;
        _binding = session;
        _otpCtrl.clear();
        _step = _Step.bindOtp;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      final status = e.response?.statusCode;
      // Already bound. "Add this card" is satisfied by picking the one they
      // have, rather than by an error about a card that is sitting right there.
      if (status == 409) {
        if (await _selectAlreadySavedCard(pan)) return;
        if (!mounted) return;
      }
      // Card management is off in this environment (no WLCM credentials, no PAN
      // cipher). The rail still works one-shot, so keep the number for this
      // booking — the charge is still the buyer's own Pay tap, never this sheet.
      if (status == 503) {
        _useSessionCard(pan, typed);
        return;
      }
      // Keep the buyer on the form with what they typed — a rejected card is
      // usually a typo, and clearing it makes them start over.
      setState(() {
        _busy = false;
        _error = PaymentError.fromDio(e) ??
            _dioMessage(
              e,
              status == 409
                  ? 'card_already_saved'.tr()
                  : 'card_save_error'.tr(),
            );
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'card_save_error'.tr();
      });
    }
  }

  /// Selects the card the buyer just tried to add again, when the backend
  /// refuses the bind because it is already saved.
  ///
  /// Matched on what survives masking — see [_maskMatchesPan]. Returns false
  /// when there is no match — a 409 also covers "a verification for this card is
  /// already in progress", which no card in the list can satisfy — so the caller
  /// shows the refusal instead.
  Future<bool> _selectAlreadySavedCard(String pan) async {
    List<SavedCard> saved;
    try {
      saved = await getIt<OrdersApi>().getSavedCards();
    } catch (_) {
      return false;
    }
    SavedCard? match;
    for (final c in saved) {
      if (_maskMatchesPan(c.maskedNumber, pan)) {
        match = c;
        break;
      }
    }
    if (match == null) return false;
    if (!mounted) return true;
    final card = PaymentCard.saved(match);
    setState(() {
      _busy = false;
      _error = null;
      _binding = null;
      _cards.removeWhere((c) => c.savedCardId == card.savedCardId);
      _cards.insert(0, card);
      _card = card;
      _rail = PaymentRail.card;
      _numberCtrl.clear();
      _expiryCtrl.clear();
      _step = _Step.choose;
    });
    return true;
  }

  /// Whether a masked PAN from the server is the number the buyer just typed.
  ///
  /// Compares the BIN as well as the last four: "860012******9012" keeps both,
  /// and two of a buyer's cards sharing their last four digits is not rare
  /// enough to guess at — the card picked here is the one that gets charged.
  /// Falls back to the last four when the mask hides the BIN too.
  bool _maskMatchesPan(String? masked, String pan) {
    final m = (masked ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (m.length < 4 || pan.length < 4) return false;
    if (m.substring(m.length - 4) != pan.substring(pan.length - 4)) return false;
    if (m.length < 10) return true;
    return m.substring(0, 6) == pan.substring(0, 6);
  }

  /// Picks a card from the list. **Selection only — this must not charge.**
  ///
  /// It used to pay on tap, on the reasoning that choosing a card is the
  /// instruction to pay with it. That held while the only cards here were typed
  /// during checkout. Saved cards broke it: the row carries a radio button and
  /// the sheet has its own Select button, so tapping reads as "choose this" —
  /// and it was instead charging the card and sending an OTP before the buyer
  /// had seen the Pay button, let alone pressed it.
  void _selectCard(PaymentCard card) {
    setState(() {
      _error = null;
      _rail = PaymentRail.card;
      _card = card;
    });
  }

  /// Exchanges the SMS code for a saved card, then selects it and returns to
  /// the list. Nothing is paid here: the buyer confirms the choice and presses
  /// Pay, which charges the order through `/cards/pay` — and gets its own OTP,
  /// because this rail issues no token and challenges every charge.
  Future<void> _confirmBinding() async {
    final session = _binding;
    final otp = _otpCtrl.text.trim();
    if (session == null) return;
    if (otp.isEmpty) {
      setState(() => _error = 'pay_enter_code'.tr());
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final saved = await getIt<OrdersApi>().confirmCardVerification(
        verificationId: session.verificationId,
        otp: otp,
      );
      if (!mounted) return;
      final card = PaymentCard.saved(saved);
      setState(() {
        _busy = false;
        _binding = null;
        _error = null;
        // The bound card may already be listed if WLCM had it from an earlier
        // session; don't show it twice.
        _cards.removeWhere((c) => c.savedCardId == card.savedCardId);
        _cards.insert(0, card);
        _card = card;
        _rail = PaymentRail.card;
        _numberCtrl.clear();
        _expiryCtrl.clear();
        _otpCtrl.clear();
        _step = _Step.choose;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = _dioMessage(e, 'pay_code_invalid'.tr());
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'pay_code_invalid'.tr();
      });
    }
  }

  /// Fallback for a backend that can't bind (503): keep the PAN in memory for
  /// this booking only, to be charged one-shot from the caller's Pay CTA. The
  /// card is not saved, so it is gone when the sheet is.
  void _useSessionCard(String pan, String expiry) {
    final card = PaymentCard(
      brand: CardBrand.fromPan(pan),
      pan: pan,
      expiry: expiry,
    );
    setState(() {
      _busy = false;
      _error = null;
      _binding = null;
      _cards.add(card);
      _card = card;
      _rail = PaymentRail.card;
      _numberCtrl.clear();
      _expiryCtrl.clear();
      _step = _Step.choose;
    });
  }

  /// Server-supplied error text when there is one — the gateway's reason ("card
  /// expired", "wrong code") is far more useful than a generic failure line.
  String _dioMessage(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map) {
      final msg = data['message'];
      final raw = msg is String
          ? msg
          : (msg is List && msg.isNotEmpty ? msg.first.toString() : null);
      // A known gateway code becomes a sentence the buyer can act on; anything
      // else is passed through as the server wrote it.
      final localized = PaymentError.fromText(raw);
      if (localized != null) return localized;
      if (raw != null && raw.isNotEmpty) return raw;
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    return switch (_step) {
      _Step.choose => _buildChoose(),
      _Step.addCard => _buildAddCard(),
      _Step.bindOtp => _buildBindOtp(),
    };
  }

  // ── Step: choose rail (and card, on the card rail) ──────────────────────────
  Widget _buildChoose() {
    final c = context.colors;
    final isCard = !widget.cardsComingSoon && _rail == PaymentRail.card;
    final selection = _selection;
    return PaymentSheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text('pay_choose_type'.tr(),
                style: AppText.heading20.copyWith(color: c.textPrimary)),
          ),
          20.verticalSpace,
          if (_error != null) PaymentErrorNote(message: _error!),
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
          _railTile(PaymentRail.card, disabled: widget.cardsComingSoon),
          // The card list belongs to the card rail — it only appears once that
          // rail is picked, as in the design.
          if (isCard) ...[
            20.verticalSpace,
            Text('pay_choose_card'.tr(),
                style: AppText.semibold14.copyWith(color: context.colors.textSecondary)),
            14.verticalSpace,
            for (var i = 0; i < _cards.length; i++) ...[
              if (i > 0) _cardDivider(),
              _cardRow(_cards[i]),
            ],
            if (_cards.isNotEmpty) _cardDivider(),
            _addCardRow(),
          ],
          20.verticalSpace,
          PaymentSheetActions(
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
    bool disabled = false,
  }) {
    final c = context.colors;
    // A disabled rail is dimmed and shows a "coming soon" badge where its radio
    // would be — it reads as not-yet rather than broken.
    final tile = Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: c.control,
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
              colorFilter: ColorFilter.mode(c.textPrimary, BlendMode.srcIn),
            ),
            12.horizontalSpace,
            Text('pay_with_card'.tr(),
                style: AppText.semibold16.copyWith(color: c.textPrimary)),
          ],
          const Spacer(),
          if (disabled) const _ComingSoonBadge() else _radio(_rail == r),
        ],
      ),
    );

    if (disabled) {
      return Opacity(
        opacity: 0.5,
        // Swallows the tap so the row can't be selected, and so a tap doesn't
        // fall through to whatever sits under it.
        child: IgnorePointer(child: tile),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() {
        _error = null;
        _rail = r;
      }),
      child: tile,
    );
  }

  /// Hairline between saved-card rows, inset past the artwork as in the design.
  Widget _cardDivider() => Padding(
        padding: EdgeInsets.only(left: 60.w),
        child: Container(height: 1, color: context.colors.divider),
      );

  Widget _cardRow(PaymentCard card) {
    final selected = identical(_card, card);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _selectCard(card),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: Row(
          children: [
            CardArtwork(brand: card.brand),
            16.horizontalSpace,
            Expanded(
              child: Text(
                card.label,
                style: AppText.medium16.copyWith(color: context.colors.textPrimary),
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
                  style: AppText.medium16.copyWith(color: context.colors.textPrimary)),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 18.sp, color: context.colors.textPrimary),
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
        border: Border.all(color: context.colors.textSecondary),
      ),
    );
  }

  // ── Step: add card (Figma 131:3526) ─────────────────────────────────────────
  Widget _buildAddCard() {
    final c = context.colors;
    return PaymentSheetShell(
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
                      AppText.regular14.copyWith(color: context.colors.textSecondary),
                ),
              ],
            ),
          ),
          20.verticalSpace,
          if (_error != null) PaymentErrorNote(message: _error!),
          PaymentField(
            controller: _numberCtrl,
            hint: 'pay_card_number_hint'.tr(),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              const CardNumberInputFormatter(),
            ],
            suffix: Assets.icons.icCardScan.svg(
              width: 24.w,
              height: 24.w,
              colorFilter:
                  ColorFilter.mode(context.colors.textPrimary, BlendMode.srcIn),
            ),
          ),
          12.verticalSpace,
          // The expiry is a short field in the design, not full-bleed.
          SizedBox(
            width: 170.w,
            child: PaymentField(
              controller: _expiryCtrl,
              hint: 'pay_card_expiry_hint'.tr(),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
                const ExpiryInputFormatter(),
              ],
            ),
          ),
          24.verticalSpace,
          PaymentSheetActions(
            primaryLabel: 'pay_add_card'.tr(),
            busy: _busy,
            onCancel: _busy
                ? null
                : () => setState(() {
                      _error = null;
                      _step = _Step.choose;
                    }),
            onPrimary: _busy ? null : _saveCard,
          ),
        ],
      ),
    );
  }

  // ── Step: confirm the binding OTP ───────────────────────────────────────────
  /// Shown after the PAN is submitted: WLCM has SMSed the cardholder a code,
  /// and confirming it is what turns the card into a saved (tokenized) one.
  Widget _buildBindOtp() {
    final c = context.colors;
    final phone = _binding?.otpSentPhone;
    return PaymentSheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('card_confirm_title'.tr(),
              style: AppText.heading20.copyWith(color: c.textPrimary)),
          8.verticalSpace,
          Text(
            phone != null && phone.isNotEmpty
                ? 'pay_code_sent_to'.tr(args: [phone])
                : 'pay_code_sent'.tr(),
            textAlign: TextAlign.center,
            style: AppText.regular14.copyWith(color: c.textSecondary),
          ),
          20.verticalSpace,
          if (_error != null) PaymentErrorNote(message: _error!),
          OtpCodeField(controller: _otpCtrl, length: 6),
          20.verticalSpace,
          PaymentSheetActions(
            primaryLabel: 'next'.tr(),
            busy: _busy,
            // Backing out drops the half-finished binding — the card is only
            // ever saved once its OTP is confirmed.
            onCancel: _busy
                ? null
                : () => setState(() {
                      _error = null;
                      _binding = null;
                      _otpCtrl.clear();
                      _step = _Step.addCard;
                    }),
            onPrimary: _busy ? null : _confirmBinding,
          ),
        ],
      ),
    );
  }
}

/// "Tez orada" pill shown on a payment rail that isn't live yet.
class _ComingSoonBadge extends StatelessWidget {
  const _ComingSoonBadge();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(40.r),
        border: Border.all(color: c.controlBorder),
      ),
      child: Text(
        'coming_soon'.tr(),
        style: AppText.semibold12.copyWith(color: c.textSecondary),
      ),
    );
  }
}

// ─── OTP sheet (card charge confirmation) ─────────────────────────────────────

class _OtpSheet extends StatefulWidget {
  const _OtpSheet({
    required this.transactionId,
    required this.cid,
    required this.otpSentPhone,
    required this.confirmCard,
  });

  /// The gateway's OTP session. Taken as loose fields rather than a
  /// [CheckoutResult] because two different calls open one: a card typed at
  /// checkout, and a saved card being charged.
  final String transactionId;
  final String cid;
  final String? otpSentPhone;
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
        transactionId: widget.transactionId,
        cid: widget.cid,
        otp: otp,
      );
      if (!mounted) return;
      if (res.success) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _busy = false;
          // The gateway's own reason, localized — a declined card is not a
          // "wrong code", and telling the buyer to re-enter the SMS would send
          // them round a loop that cannot succeed.
          _error = PaymentError.fromText(res.message) ??
              res.message ??
              'pay_code_invalid'.tr();
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = PaymentError.fromDio(e) ??
            (e is CheckoutFriendlyError ? e.message : 'pay_generic_error'.tr());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final phone = widget.otpSentPhone;
    return PaymentSheetShell(
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
          if (_error != null) PaymentErrorNote(message: _error!),
          OtpCodeField(controller: _otpCtrl, length: 6),
          16.verticalSpace,
          const CountdownTimer(seconds: 57),
          16.verticalSpace,
          Text('pay_resend'.tr(),
              style: AppText.medium14.copyWith(color: c.textSecondary)),
          20.verticalSpace,
          PaymentSheetActions(
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
