import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:lumi_pass/common/env/runtime_env.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/cashback.dart';
import 'package:lumi_pass/common/widget/auth/gradient_button.dart';
import 'package:lumi_pass/common/widget/cashback_badge.dart';
import 'package:lumi_pass/common/widget/coin_amount.dart';
import 'package:lumi_pass/common/widget/use_balance_row.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';
import 'package:lumi_pass/common/widget/pill_card.dart';
import 'package:lumi_pass/data/api_model/order/order_model.dart';
import 'package:lumi_pass/data/api_model/wallet/cashback_config.dart';
import 'package:lumi_pass/data/api_model/wallet/cashback_preview.dart';
import 'package:lumi_pass/data/api_model/wallet/wallet_balance.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/courses/courses_api.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:lumi_pass/domain/repo/wallet/wallet_repository.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/widgets/paycom_checkout_page.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/widgets/payment_sheets.dart';
import 'package:lumi_pass/presentation/app/home/course_detail/course_purchase.dart';
import 'package:lumi_pass/common/utils/card_input_formatters.dart';

/// The review-and-pay screen for a course — the whole thing, a levelled
/// subcourse, or a single TRIAL lesson.
///
/// A trial used to be charged inline from the detail page, which meant the one
/// purchase on the screen that skipped the payment-method picker, the saved
/// cards and the error mapping every other purchase goes through. Passing
/// [trialLesson] routes it through here instead, so trying a course is paid for
/// exactly like booking a class is.
///
/// Pops `true` once the purchase went through (paid in-app, or the buyer came
/// back from the payment-gateway redirect) so the caller knows to reload the
/// course and reflect the new enrolment; pops nothing/`false` otherwise.
@RoutePage()
class CourseBookingPage extends StatefulWidget {
  const CourseBookingPage({
    super.key,
    required this.activityId,
    required this.level,
    required this.courseTitle,
    this.branchTitle,
    this.trialLesson,
  });

  final String activityId;
  final CourseLevel level;

  /// The course's own name — shown when [level] has none (a course sold flat,
  /// not as levels).
  final String courseTitle;
  final String? branchTitle;

  /// Set to buy ONE trial lesson instead of the course. Its date is what the
  /// order is written against — trials are sold by date, since which session
  /// "lesson 2" refers to rolls forward as dates pass.
  final CourseLesson? trialLesson;

  @override
  State<CourseBookingPage> createState() => _CourseBookingPageState();
}

class _CourseBookingPageState extends State<CourseBookingPage> {
  PaymentSelection? _payment;
  final List<PaymentCard> _cards = [];
  bool _submitting = false;
  String? _error;

  /// This course's cashback rate, fetched once on open.
  ///
  /// A trial lesson and a full enrolment are priced by two different rules, so
  /// the fetch has to say which is being bought. Starts at
  /// [CashbackPreview.none], which renders nothing.
  CashbackPreview _cashback = CashbackPreview.none;

  // ── Wallet ─────────────────────────────────────────────────────────────────
  /// Spendable balance, fetched once on open. Empty until it lands, which keeps
  /// the "Use balance" row hidden rather than flickering in.
  WalletBalance _wallet = WalletBalance.empty;

  /// Per-order redemption ceiling from the public config. The server clamps
  /// regardless, so an optimistic default can only ever offer too much.
  num _maxRedeemPercent = 100;

  /// Whether the buyer switched the wallet on. The amount is derived from the
  /// live total rather than stored, so changing quantity or applying a
  /// promocode re-prices it with no stale figure underneath.
  bool _useWallet = false;

  /// Which age bracket to enrol at, for a FLAT course priced by more than one
  /// tier (`widget.level.id == null` — a level has its own single price, not
  /// tiers, so this stays null there). Defaults to the first tier, which the
  /// server already sends cheapest-first — the same one checkout would
  /// default to if none were named, so the price shown never disagrees with
  /// what an untouched picker would charge.
  CourseAgeTier? _selectedTier;

  /// Buying one trial lesson rather than the course.
  bool get _isTrial => widget.trialLesson != null;

  /// How many places to buy — one per child. Full enrolments only: a trial is
  /// one child trying one lesson, and the server refuses a quantity on one.
  int _quantity = 1;

  /// Server-side ceiling (`MAX_COURSE_QUANTITY`). Mirrored so the stepper stops
  /// where checkout would start refusing rather than after it.
  static const int _maxQuantity = 10;

  bool get _canPickQuantity => !_isTrial;

  /// Places left in the cohort, when the centre capped it. The stepper stops
  /// here too: offering a fourth place in a three-place cohort only produces a
  /// refusal at the end of the flow.
  int get _quantityCeiling {
    final left = widget.level.seatsLeft;
    if (left == null || left <= 0) return _maxQuantity;
    return left < _maxQuantity ? left : _maxQuantity;
  }

  // ── Promocode ───────────────────────────────────────────────────────────────
  final TextEditingController _promoCtrl = TextEditingController();
  PromocodePreview? _appliedPromo;
  bool _promoLoading = false;
  String? _promoError;

  num get _promoDiscount => _appliedPromo?.discountAmount ?? 0;

  /// What the order costs before any discount: the per-place price times the
  /// places bought.
  num get _subtotal => _price * (_canPickQuantity ? _quantity : 1);

  /// What is actually charged. Never below zero — a code worth more than the
  /// order settles it free rather than owing the buyer money.
  num get _payable {
    final t = _subtotal - _promoDiscount;
    return t < 0 ? 0 : t;
  }

  /// Age tiers price the WHOLE course; a trial lesson carries its own price,
  /// so there is nothing to pick.
  bool get _hasAgeTierChoice =>
      !_isTrial &&
      widget.level.id == null &&
      widget.level.ageTiers.length > 1;

  /// The price actually being charged: the trial lesson's own price, else the
  /// picked tier once there is a choice to make, else the level's own default.
  num get _price =>
      widget.trialLesson?.price ?? _selectedTier?.price ?? widget.level.coursePrice;

  bool get _isFree => _payable <= 0;

  /// When this enrolment starts. Purely descriptive — picking a date here
  /// doesn't change which lessons are booked, the price, or seats; it's just
  /// saved on the order (`Order.starts_at`). Picked from the course's own
  /// upcoming lesson dates (`widget.level.courseLessons`) rather than an
  /// open calendar, so every choice is a real lesson day. Defaults to the
  /// first one, same as what checkout would default to if this were left
  /// unsent.
  DateTime? _selectedStartDate;

  @override
  void initState() {
    super.initState();
    if (_hasAgeTierChoice) _selectedTier = widget.level.ageTiers.first;
    if (widget.level.courseLessons.isNotEmpty) {
      _selectedStartDate =
          DateTime.tryParse(widget.level.courseLessons.first.date);
    }
    _loadLastPaymentMethod();
    _loadCashbackRate();
    _loadWallet();
  }

  @override
  void dispose() {
    _promoCtrl.dispose();
    super.dispose();
  }

  /// Fetch the cashback rate for what's being bought — `trial` and `full` are
  /// separately configured rules, so which one is asked for decides the rate.
  ///
  /// Never throws; a failure leaves the earn line hidden rather than promising
  /// a credit that then doesn't arrive.
  Future<void> _loadCashbackRate() async {
    final preview = await getIt<WalletRepository>().getCashbackPreview(
      activityId: widget.activityId,
      purchase: _isTrial ? 'trial' : 'full',
    );
    if (!mounted) return;
    setState(() => _cashback = preview);
  }

  /// Balance + redemption cap. Both failures collapse to "no wallet": the buyer
  /// can still pay by card, and offering a balance we couldn't confirm only
  /// produces a refusal at checkout.
  Future<void> _loadWallet() async {
    final repo = getIt<WalletRepository>();
    final results = await Future.wait([
      repo.getWallet().catchError((_) => WalletBalance.empty),
      repo.getCashbackConfig().catchError((_) => const CashbackConfig()),
    ]);
    if (!mounted) return;
    final wallet = results[0] as WalletBalance;
    final config = results[1] as CashbackConfig;
    setState(() {
      _wallet = wallet;
      _maxRedeemPercent = config.maxRedeemPercent;
      if (!config.isEnabled) _useWallet = false;
    });
  }

  /// Live preview of what the wallet would cover. Checkout re-decides it.
  num get _walletApplied {
    if (!_useWallet) return 0;
    return walletRedeemableFor(
      available: _wallet.available,
      orderAmount: _payable,
      maxRedeemPercent: _maxRedeemPercent,
    );
  }

  /// What the card is actually charged, after the wallet.
  num get _gatewayTotal {
    final t = _payable - _walletApplied;
    return t < 0 ? 0 : t;
  }

  /// Nothing left for a gateway — a promocode covered it, or the wallet did.
  /// Both take the same terminal-PAID path; there is no second free branch.
  bool get _skipsGateway => _isFree || _gatewayTotal <= 0;

  /// Validate the code against the CURRENT subtotal and preview the new total.
  /// Re-checked server-side at checkout — this only shows the buyer what to
  /// expect, it never decides the charge.
  Future<void> _applyPromo() async {
    final code = _promoCtrl.text.trim();
    if (code.isEmpty || _promoLoading) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _promoLoading = true;
      _promoError = null;
    });
    try {
      final preview = await getIt<OrdersApi>().validatePromocode(
        code: code,
        subtotal: _subtotal,
        activityId: widget.activityId,
        count: _canPickQuantity ? _quantity : 1,
      );
      if (!mounted) return;
      setState(() {
        _appliedPromo = preview;
        _promoLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _appliedPromo = null;
        // Reuses the course error mapping, which already turns a structured
        // `error_code` into something a buyer can act on.
        _promoError = courseCheckoutErrorMessage(e);
        _promoLoading = false;
      });
    }
  }

  /// A applied code was priced against the old subtotal, so changing the number
  /// of places has to drop it — otherwise the screen shows a discount the
  /// server will recompute to something else.
  void _setQuantity(int next) {
    setState(() {
      _quantity = next;
      _appliedPromo = null;
      _promoError = null;
    });
  }

  static String _isoDate(DateTime d) {
    String two(int v) => v < 10 ? '0$v' : '$v';
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  Future<void> _loadLastPaymentMethod() async {
    final storage = getIt<Storage>();
    final railKey = storage.lastPaymentRail();
    if (railKey == null || railKey.isEmpty) return;
    PaymentRail? rail;
    for (final r in PaymentRail.values) {
      if (r.name == railKey) {
        rail = r;
        break;
      }
    }
    if (rail == null) return;
    if (rail != PaymentRail.card) {
      if (mounted) setState(() => _payment = PaymentSelection(rail: rail!));
      return;
    }
    final savedId = storage.lastSavedCardId();
    if (savedId == null || savedId.isEmpty) return;
    try {
      final cards = await getIt<OrdersApi>().getSavedCards();
      for (final c in cards) {
        if (c.id == savedId) {
          if (mounted) {
            setState(() {
              final pc = PaymentCard.saved(c);
              _payment = PaymentSelection(rail: PaymentRail.card, card: pc);
              if (!_cards.contains(pc)) _cards.add(pc);
            });
          }
          return;
        }
      }
    } catch (_) {
      // Non-fatal — the buyer can pick a method manually.
    }
  }

  void _persistPaymentMethod(PaymentSelection sel) {
    final storage = getIt<Storage>();
    storage.lastPaymentRail.set(sel.rail.name);
    storage.lastSavedCardId.set(sel.card?.savedCardId);
  }

  /// Creates the order for this level. Throws a [CheckoutFriendlyError]
  /// carrying a message safe to show the buyer.
  Future<CheckoutResult> _runCheckout({
    String? provider,
    String? cardNumber,
    String? expireDate,
    String? savedCardId,
  }) async {
    final isRedirect = provider != null && provider != 'card';
    try {
      return await getIt<CoursesApi>().checkout(
        activityId: widget.activityId,
        option: _isTrial
            ? CoursePurchaseOption.trial
            : CoursePurchaseOption.full,
        subcourseId: widget.level.id,
        quantity: _canPickQuantity ? _quantity : null,
        promocode: _appliedPromo != null ? _promoCtrl.text.trim() : null,
        // Trials are selected by DATE server-side, and priced over exactly the
        // lessons being sold — so this one date is the whole order.
        trialDates: _isTrial ? [widget.trialLesson!.date] : null,
        // Both belong to a full enrolment only; a trial has neither an age tier
        // nor a start date to choose.
        ageFrom: _isTrial ? null : _selectedTier?.ageFrom,
        ageTo: _isTrial ? null : _selectedTier?.ageTo,
        startsAt: !_isTrial && _selectedStartDate != null
            ? _isoDate(_selectedStartDate!)
            : null,
        lang: context.locale.languageCode,
        paymentProvider: savedCardId != null ? null : provider,
        returnUrl: isRedirect ? '${RuntimeEnv.baseUrl}paylov/return' : null,
        cardNumber: cardNumber,
        expireDate: expireDate,
        savedCardId: savedCardId,
        // Intent only — the server decides the amount and returns it as
        // `wallet_amount` on the result.
        useWallet: _useWallet,
      );
    } catch (e) {
      throw CheckoutFriendlyError(courseCheckoutErrorMessage(e));
    }
  }

  /// MM/YY as typed → YYMM as the gateway wants. Delegates to the shared
  /// converter so the swap has exactly one definition — getting it backwards
  /// reports a valid card as expired.
  static String? _toYyMm(String? expiry) {
    if (expiry == null) return null;
    final converted = expiryToYyMm(expiry);
    return converted.isEmpty ? expiry : converted;
  }

  /// Redirect rails (Payme, Click/Uzum via Paylov): open the gateway page and,
  /// once the buyer comes back, close this screen too — same shape as the
  /// booking flow, just without its own success screen.
  Future<void> _completeRedirect(CheckoutResult result) async {
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaycomCheckoutPage(
          result: result,
          provider: _payment?.rail.name ?? PaymentRail.card.name,
          cashbackEarned: result.cashbackEstimate > 0
              ? result.cashbackEstimate
              : cashbackFor(_cashback, result.payableAmount),
          walletApplied: result.walletAmount,
        ),
      ),
    );
    if (mounted) Navigator.of(context).pop(true);
  }

  void _completePaid() {
    if (mounted) Navigator.of(context).pop(true);
  }

  /// Charges a card typed into the chooser sheet, without closing it first —
  /// mirrors the ticket-booking flow's own [CardSubmitted] handler.
  Future<String?> _payWithEnteredCard(PaymentCard card) async {
    try {
      // A saved card spares the buyer typing the number — not the code: this
      // rail challenges every charge.
      if (card.savedCardId != null) {
        final order = await _runCheckout(savedCardId: card.savedCardId);
        if (!mounted) return null;
        final charge = await getIt<OrdersApi>().payOrderWithSavedCard(
          orderId: order.orderId,
          cardId: card.savedCardId!,
        );
        if (!mounted) return null;
        if (!charge.otpRequired) {
          _completePaid();
          return null;
        }
        final paid = await showCardOtpSheet(
          context,
          transactionId: charge.transactionId ?? '',
          cid: charge.cid ?? '',
          otpSentPhone: charge.otpSentPhone,
          confirmCard: ({
            required String transactionId,
            required String cid,
            required String otp,
          }) =>
              getIt<OrdersApi>().paylovConfirmCard(
            transactionId: transactionId,
            cid: cid,
            otp: otp,
          ),
        );
        if (paid == true && mounted) _completePaid();
        return null;
      }

      final result = await _runCheckout(
        provider: PaymentRail.card.providerKey,
        cardNumber: card.pan,
        expireDate: _toYyMm(card.expiry),
      );
      if (!mounted) return null;

      if (result.isCardOtpPending) {
        final paid = await showCardOtpSheet(
          context,
          transactionId: result.transactionId ?? '',
          cid: result.cid ?? '',
          otpSentPhone: result.otpSentPhone,
          confirmCard: ({
            required String transactionId,
            required String cid,
            required String otp,
          }) =>
              getIt<OrdersApi>().paylovConfirmCard(
            transactionId: transactionId,
            cid: cid,
            otp: otp,
          ),
        );
        if (paid == true && mounted) _completePaid();
        return null;
      }
      if (result.checkoutUrl.isNotEmpty) {
        await _completeRedirect(result);
        return null;
      }
      return result.paylovMessage ?? 'pay_generic_error'.tr();
    } on CheckoutFriendlyError catch (e) {
      return e.message;
    } catch (e) {
      return courseCheckoutErrorMessage(e);
    }
  }

  Future<void> _openChooser() async {
    final picked = await showPaymentChooser(
      context,
      initial: _payment,
      cards: _cards,
      onCardSubmitted: _payWithEnteredCard,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _payment = picked;
      final card = picked.card;
      if (card != null && !_cards.contains(card)) _cards.add(card);
      _error = null;
    });
    _persistPaymentMethod(picked);
  }

  Future<void> _pay() async {
    if (_submitting) return;

    // Nothing to charge — a fully discounted level, or the wallet covering
    // the whole thing. No method to pick; just create the order, which comes
    // back already paid. One branch for both cases, deliberately.
    if (_skipsGateway) {
      setState(() {
        _submitting = true;
        _error = null;
      });
      try {
        await _runCheckout();
        if (!mounted) return;
        _completePaid();
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _submitting = false;
          _error = e is CheckoutFriendlyError
              ? e.message
              : courseCheckoutErrorMessage(e);
        });
      }
      return;
    }

    if (_payment == null) {
      await _openChooser();
      if (!mounted || _payment == null) return;
    }
    final payment = _payment!;
    final card = payment.card;

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      if (card != null && card.isSaved) {
        final order = await _runCheckout(savedCardId: card.savedCardId);
        final charge = await getIt<OrdersApi>().payOrderWithSavedCard(
          orderId: order.orderId,
          cardId: card.savedCardId!,
        );
        if (!mounted) return;
        if (!charge.otpRequired) {
          _completePaid();
          return;
        }
        setState(() => _submitting = false);
        final paid = await showCardOtpSheet(
          context,
          transactionId: charge.transactionId ?? '',
          cid: charge.cid ?? '',
          otpSentPhone: charge.otpSentPhone,
          confirmCard: ({
            required String transactionId,
            required String cid,
            required String otp,
          }) =>
              getIt<OrdersApi>().paylovConfirmCard(
            transactionId: transactionId,
            cid: cid,
            otp: otp,
          ),
        );
        if (paid == true && mounted) _completePaid();
        return;
      }

      final result = await _runCheckout(
        provider: payment.rail.providerKey,
        cardNumber: card?.pan,
        expireDate: _toYyMm(card?.expiry),
      );
      if (!mounted) return;
      setState(() => _submitting = false);

      if (result.isCardOtpPending) {
        final paid = await showCardOtpSheet(
          context,
          transactionId: result.transactionId ?? '',
          cid: result.cid ?? '',
          otpSentPhone: result.otpSentPhone,
          confirmCard: ({
            required String transactionId,
            required String cid,
            required String otp,
          }) =>
              getIt<OrdersApi>().paylovConfirmCard(
            transactionId: transactionId,
            cid: cid,
            otp: otp,
          ),
        );
        if (paid == true && mounted) _completePaid();
      } else if (result.checkoutUrl.isNotEmpty) {
        await _completeRedirect(result);
      } else {
        setState(
            () => _error = result.paylovMessage ?? 'pay_generic_error'.tr());
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e is CheckoutFriendlyError
            ? e.message
            : courseCheckoutErrorMessage(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.canvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(c),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(top: 16.h, bottom: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full-bleed, like the normal booking page's own date
                    // strip: it has its own horizontal padding so its chips
                    // scroll edge to edge, and sits right under the header
                    // rather than inside the rest of the form's padding.
                    //
                    // A trial has no start date to PICK — the ladder decides
                    // which lesson is on sale — but it still has a date and a
                    // time, and the buyer is told both further down.
                    if (!_isTrial) ...[
                      _startDateSection(c),
                      16.kh,
                    ],
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionHeader(
                            c,
                            _isTrial
                                ? 'course_trial_book_title'.tr()
                                : 'course_full_title'.tr(),
                          ),
                          _courseCard(c),
                          // When the lesson runs. Sits right under the card the
                          // way the class booking page puts its schedule under
                          // the class — same question, same place on the page.
                          if (_isTrial) ...[
                            20.kh,
                            _trialScheduleSection(c),
                          ],
                          if (_hasAgeTierChoice) ...[
                            20.kh,
                            _ageTierSection(c),
                          ],
                          if (_canPickQuantity) ...[
                            20.kh,
                            _quantitySection(c),
                          ],
                          20.kh,
                          _promoSection(c),
                          // "The trial fee isn't credited" is about buying the
                          // COURSE after a trial — meaningless while buying the
                          // trial itself.
                          if (!_isTrial &&
                              widget.level.enrollment?.hasTrial == true) ...[
                            8.kh,
                            Text(
                              'course_upsell_body_short'.tr(),
                              style: AppText.regular12
                                  .copyWith(color: c.textMuted),
                            ),
                          ],
                          if (!_skipsGateway) ...[
                            20.kh,
                            _paymentMethodRow(c),
                          ],
                          // The wallet is a payment method, not a competing
                          // discount, so it is offered regardless of what
                          // promocode or coupon already applied.
                          if (_wallet.available > 0) ...[
                            20.kh,
                            UseBalanceRow(
                              wallet: _wallet,
                              enabled: !_submitting,
                              applied: _walletApplied,
                              onChanged: (v) => setState(() => _useWallet = v),
                            ),
                          ],
                          20.kh,
                          _breakdownSection(c),
                          if (_error != null) ...[
                            12.kh,
                            Text(_error!,
                                style: AppText.regular12
                                    .copyWith(color: AppColors.error)),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomBar(c),
    );
  }

  Widget _header(AppColorScheme c) => Padding(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
        child: Row(
          children: [
            FrostedCard(
              onTap: () => Navigator.of(context).maybePop(),
              padding: EdgeInsets.all(8.w),
              child: Assets.icons.detail.arrow.svg(
                width: 16.w,
                height: 16.w,
                colorFilter: ColorFilter.mode(c.textPrimary, BlendMode.srcIn),
              ),
            ),
            Expanded(
              child: Text(
                'course_buy_cta'.tr(),
                textAlign: TextAlign.center,
                style: AppText.medium16.copyWith(color: c.textPrimary),
              ),
            ),
            SizedBox(width: 32.w),
          ],
        ),
      );

  Widget? _bottomBar(AppColorScheme c) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      color: c.scaffoldBg,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h + bottomInset),
      child: GradientButton(
        text: _skipsGateway
            ? 'book_free_cta'.tr()
            // What the CARD is charged, after the wallet.
            : 'book_pay_cta'.tr(args: [_gatewayTotal.toRawUzsPrice()]),
        loading: _submitting,
        onPressed: _pay,
      ),
    );
  }

  Widget _sectionHeader(AppColorScheme c, String title) => Padding(
        padding: EdgeInsets.only(left: 8.w, bottom: 14.h),
        child: Text(title,
            style: AppText.semibold14.copyWith(color: c.textSecondary)),
      );

  // "Butun kurs" — what's being bought, and for how much. For a trial that is
  // ONE named lesson on a given date, not the course, and the card has to say
  // so: the price alone would look like a suspiciously cheap whole course.
  Widget _courseCard(AppColorScheme c) {
    final level = widget.level;
    final trial = widget.trialLesson;

    final title = trial != null
        ? 'course_trial_lesson_no'.tr(namedArgs: {'n': '${trial.lessonNo}'})
        : (level.name ?? widget.courseTitle);

    final subtitle = trial != null
        ? [_trialDateLabel(trial), level.name ?? widget.courseTitle]
            .where((s) => s.isNotEmpty)
            .join(' · ')
        : widget.branchTitle;

    return PillCard(
      leading: PillIconBadge(
        child: Assets.icons.detail.iconsaxReceipt.svg(
          width: 20.w,
          height: 20.w,
          colorFilter: ColorFilter.mode(c.textPrimary, BlendMode.srcIn),
        ),
      ),
      child: PillCaption(
        captionFirst: true,
        title: title,
        subtitle: subtitle,
      ),
      trailing: PillActionChip(
        label: _isFree ? 'price_free'.tr() : _price.toRawUzsPrice(),
      ),
    );
  }

  String _trialDateLabel(CourseLesson lesson) {
    final d = DateTime.tryParse(lesson.date);
    if (d == null) return lesson.date;
    return '${d.day} ${'month_short_${d.month}'.tr()}, '
        '${'weekday_short_${d.weekday}'.tr()}';
  }

  /// "Nechta bola?" — how many places this order buys.
  ///
  /// A place is a cohort seat, so the stepper stops at whichever comes first:
  /// the product ceiling, or the seats the centre has left. Running past either
  /// only earns a refusal at the end of the flow, after the buyer has picked a
  /// card.
  Widget _quantitySection(AppColorScheme c) {
    final ceiling = _quantityCeiling;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(c, 'course_quantity_title'.tr()),
        PillCard(
          leading: PillIconBadge(
            child: Assets.icons.home.profile2user.svg(
              width: 20.w,
              height: 20.w,
              colorFilter: ColorFilter.mode(c.textPrimary, BlendMode.srcIn),
            ),
          ),
          child: PillCaption(
            title: 'course_quantity_label'.tr(),
            subtitle: _price.toRawUzsPrice(),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StepButton(
                icon: Icons.remove_rounded,
                onTap: _quantity > 1 ? () => _setQuantity(_quantity - 1) : null,
              ),
              SizedBox(
                width: 36.w,
                child: Text(
                  '$_quantity',
                  textAlign: TextAlign.center,
                  style: AppText.bold16.copyWith(color: c.textPrimary),
                ),
              ),
              _StepButton(
                icon: Icons.add_rounded,
                onTap: _quantity < ceiling
                    ? () => _setQuantity(_quantity + 1)
                    : null,
              ),
            ],
          ),
        ),
        if (_quantity >= ceiling) ...[
          8.kh,
          Text(
            'course_quantity_max'.tr(namedArgs: {'count': '$ceiling'}),
            style: AppText.regular12.copyWith(color: c.textMuted),
          ),
        ],
      ],
    );
  }

  /// Promocode entry — the same affordance a class booking has.
  ///
  /// The discount is only ever a PREVIEW here: checkout revalidates it and the
  /// server decides the charge, so a stale or spoofed preview cannot move money.
  Widget _promoSection(AppColorScheme c) {
    final applied = _appliedPromo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(c, 'promo_title'.tr()),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _promoCtrl,
                enabled: applied == null,
                textCapitalization: TextCapitalization.characters,
                style: AppText.regular14.copyWith(color: c.textPrimary),
                decoration: InputDecoration(
                  hintText: 'promo_hint'.tr(),
                  hintStyle:
                      AppText.regular14.copyWith(color: c.textMuted),
                  filled: true,
                  fillColor: c.surface,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: c.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: c.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: c.primary),
                  ),
                ),
              ),
            ),
            8.kw,
            applied == null
                ? _PromoActionButton(
                    label: 'promo_apply'.tr(),
                    loading: _promoLoading,
                    onTap: _applyPromo,
                  )
                : _PromoActionButton(
                    label: 'promo_remove'.tr(),
                    onTap: () => setState(() {
                      _appliedPromo = null;
                      _promoError = null;
                      _promoCtrl.clear();
                    }),
                  ),
          ],
        ),
        if (_promoError != null) ...[
          8.kh,
          Text(_promoError!,
              style: AppText.regular12.copyWith(color: AppColors.error)),
        ],
        if (applied != null) ...[
          8.kh,
          Text(
            'promo_applied'.tr(
              namedArgs: {'amount': applied.discountAmount.toRawUzsPrice()},
            ),
            style: AppText.regular12.copyWith(color: AppColors.green),
          ),
        ],
      ],
    );
  }

  // "Yoshni tanlang" — single-select age-tier picker. Only shown for a FLAT
  // course priced by more than one tier (`_hasAgeTierChoice`); a level has
  // its own single price, so this never renders alongside a level purchase.
  // Unlike a normal activity's ticket rows (+/- quantity per tier), this is
  // pick-exactly-one, the same shape as choosing a level.
  Widget _ageTierSection(AppColorScheme c) {
    final tiers = widget.level.ageTiers;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(c, 'course_choose_age_title'.tr()),
        Column(
          children: [
            for (final tier in tiers) ...[
              if (tier != tiers.first) 8.kh,
              PillCard(
                onTap: () => setState(() => _selectedTier = tier),
                leading: PillIconBadge(
                  child: _radio(identical(_selectedTier, tier)),
                ),
                child: PillCaption(
                  title: '${tier.rangeLabel} ${'age_years_suffix'.tr()}',
                ),
                trailing: PillActionChip(label: tier.price.toRawUzsPrice()),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // "Boshlanish sanasi" — optional start date, picked from the course's own
  // upcoming lesson dates so every choice is a real lesson day. Purely
  // descriptive (see _selectedStartDate): picking one never changes which
  // lessons are booked, the price, or seats, it's just saved on the order.
  // Mirrors the normal booking page's own date strip exactly — same bare
  // placement right under the header, no label, no fixed height (a fixed
  // height is what overflowed here originally: the chip is three lines of
  // text whose height moves with the user's text-scale factor). Duplicated
  // locally rather than shared, since that strip is tightly coupled to
  // per-session slot fetching this screen has no use for.
  Widget _startDateSection(AppColorScheme c) {
    final lessons = widget.level.courseLessons;
    if (lessons.isEmpty) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        children: [
          for (var i = 0; i < lessons.length; i++) ...[
            if (i > 0) 4.kw,
            _startDateChip(lessons[i]),
          ],
        ],
      ),
    );
  }

  Widget _startDateChip(CourseLesson lesson) {
    final date = DateTime.tryParse(lesson.date);
    if (date == null) return const SizedBox.shrink();
    final isSelected = _selectedStartDate != null &&
        _isoDate(_selectedStartDate!) == lesson.date;
    return _dateChip(
      date,
      selected: isSelected,
      onTap: () => setState(() => _selectedStartDate = date),
    );
  }

  /// One day in a date strip. [onTap] null renders the same chip with nothing
  /// to press — a date that is being STATED rather than offered.
  Widget _dateChip(
    DateTime date, {
    required bool selected,
    VoidCallback? onTap,
  }) {
    final dayColor = context.colors.textPrimary;
    final mutedColor = context.colors.textSecondary;
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('weekday_short_${date.weekday}'.tr(),
            style: AppText.regular12.copyWith(color: mutedColor)),
        4.kh,
        Text('${date.day}',
            style: AppText.bold18.copyWith(color: dayColor, height: 1.0)),
        4.kh,
        Text('month_short_${date.month}'.tr(),
            style: AppText.regular12.copyWith(color: mutedColor)),
      ],
    );
    final padding = EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w);
    return SizedBox(
      width: 48.w,
      child: selected
          ? FrostedCard(
              onTap: onTap,
              padding: padding,
              borderRadius: BorderRadius.circular(56.r),
              child: content,
            )
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: Padding(padding: padding, child: content),
            ),
    );
  }

  /// When the trial lesson runs — the date strip, then the window inside it.
  ///
  /// Laid out like the class booking page's own schedule, because a buyer is
  /// answering the same question: "when is this?". It is STATED, not picked:
  /// trials are a ladder and only the next unbought lesson is ever on sale (see
  /// the trial section on the detail page), so there is exactly one date this
  /// booking can be for. Offering a strip to choose from would be offering a
  /// choice that doesn't exist — but saying nothing at all, which is what this
  /// screen used to do, sent people to pay without ever being told the date.
  Widget _trialScheduleSection(AppColorScheme c) {
    final lesson = widget.trialLesson;
    final date = lesson == null ? null : DateTime.tryParse(lesson.date);
    if (date == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(c, 'book_date_time'.tr()),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _dateChip(date, selected: true),
            12.kw,
            Expanded(child: _trialTimeLabel(c, lesson!)),
          ],
        ),
      ],
    );
  }

  /// The lesson's window, "10:00 – 11:00".
  ///
  /// Nothing at all when the centre never set times on the trial's schedule:
  /// the chip beside it already carries the day, so an empty clock row would
  /// add a heading and no fact.
  Widget _trialTimeLabel(AppColorScheme c, CourseLesson lesson) {
    final start = lesson.startTime?.trim() ?? '';
    final end = lesson.endTime?.trim() ?? '';
    if (start.isEmpty) return const SizedBox.shrink();
    final value = end.isEmpty ? start : '$start – $end';

    return Row(
      children: [
        Assets.icons.detail.icCalendar.svg(
          width: 18.w,
          height: 18.w,
          colorFilter: ColorFilter.mode(c.textSecondary, BlendMode.srcIn),
        ),
        8.kw,
        Expanded(
          child: Text(
            value,
            style: AppText.semibold14.copyWith(color: c.textPrimary),
          ),
        ),
      ],
    );
  }

  /// Hollow ring, or a filled green disc with a white tick once picked —
  /// same shape as the payment-method chooser's own radio dot.
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

  Widget _paymentMethodRow(AppColorScheme c) {
    final payment = _payment;
    final card = payment?.card;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(c, 'book_payment_method'.tr()),
        PillCard(
          onTap: _openChooser,
          leading: PillIconBadge(child: _paymentLeading(payment)),
          child: PillCaption(
            title: payment == null
                ? 'book_pick_payment'.tr()
                : (card?.label ?? payment.rail.brandName),
            subtitle: 'book_pay_method_label'.tr(),
            captionFirst: true,
            titleColor: payment == null ? c.textSecondary : null,
          ),
          trailing: PillActionChip(
            label: payment == null ? 'book_choose'.tr() : 'book_change'.tr(),
            onTap: _openChooser,
          ),
        ),
      ],
    );
  }

  Widget _paymentLeading(PaymentSelection? payment) {
    final card = payment?.card;
    if (card != null) {
      return CardArtwork(brand: card.brand, width: 30, height: 20);
    }
    switch (payment?.rail) {
      case PaymentRail.payme:
        return Assets.images.pay.paymeLogo.image(width: 22.w, height: 22.w);
      case PaymentRail.click:
        return Assets.images.pay.clickLogo.image(width: 22.w, height: 22.w);
      case PaymentRail.uzum:
        return Assets.images.pay.uzumLogo.image(width: 22.w, height: 22.w);
      case PaymentRail.card:
      case null:
        return Assets.icons.icCard.svg(
          width: 20.w,
          height: 20.w,
          colorFilter:
              ColorFilter.mode(context.colors.textPrimary, BlendMode.srcIn),
        );
    }
  }

  // "Hisob" — the frosted price-breakdown card.
  Widget _breakdownSection(AppColorScheme c) {
    final level = widget.level;
    return FrostedCard(
      borderWidth: 2,
      borderRadius: BorderRadius.circular(12.r),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  gradient: AppGradients.indigo,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Assets.icons.detail.iconsaxReceipt.svg(
                  width: 14.w,
                  height: 14.w,
                  colorFilter: const ColorFilter.mode(
                      AppColors.onBrand, BlendMode.srcIn),
                ),
              ),
              6.kw,
              Text('book_payment_summary'.tr(),
                  style: AppText.semibold16.copyWith(color: c.textPrimary)),
            ],
          ),
          16.kh,
          Row(
            children: [
              Assets.icons.detail.iconsaxReceipt.svg(
                width: 20.w,
                height: 20.w,
                colorFilter: ColorFilter.mode(c.textSecondary, BlendMode.srcIn),
              ),
              8.kw,
              Expanded(
                child: Text(
                  // A trial buys ONE lesson. Quoting the whole course's lesson
                  // count against the trial's price read as though twelve
                  // lessons were being charged for.
                  _isTrial
                      ? 'course_trial_lesson_one'.tr()
                      : 'course_lessons_count'.tr(
                          namedArgs: {
                            'count': '${level.courseLessons.length}',
                          },
                        ),
                  style: AppText.regular14.copyWith(color: c.textSecondary),
                ),
              ),
              Text(
                _subtotal.toRawUzsPrice(),
                style: AppText.semibold14.copyWith(color: c.textPrimary),
              ),
            ],
          ),
          if (_promoDiscount > 0) ...[
            12.kh,
            Row(
              children: [
                Expanded(
                  child: Text('book_discount'.tr(),
                      style:
                          AppText.regular14.copyWith(color: c.textSecondary)),
                ),
                Text('- ${_promoDiscount.toRawUzsPrice()}',
                    style:
                        AppText.semibold14.copyWith(color: AppColors.green)),
              ],
            ),
          ],
          16.kh,
          Row(
            children: [
              Expanded(
                child: Text('book_grand_total'.tr(),
                    style: AppText.bold18.copyWith(color: c.textSecondary)),
              ),
              Text(
                  _isFree ? 'price_free'.tr() : _payable.toRawUzsPrice(),
                  style: AppText.bold18.copyWith(color: c.textPrimary)),
            ],
          ),
          // The wallet split hangs below the grand total rather than reducing
          // it: the course still costs the total, this is how much of it comes
          // off the balance instead of the card.
          if (_walletApplied > 0) ...[
            12.kh,
            Row(
              children: [
                Expanded(
                  child: Text('wallet_paid_from_balance'.tr(),
                      style:
                          AppText.regular14.copyWith(color: c.textSecondary)),
                ),
                CoinAmount(
                  amount: _walletApplied,
                  prefix: '−',
                  style: AppText.semibold14,
                  color: AppColors.green,
                ),
              ],
            ),
            8.kh,
            Row(
              children: [
                Expanded(
                  child: Text('wallet_left_to_pay'.tr(),
                      style: AppText.semibold14.copyWith(color: c.textPrimary)),
                ),
                Text(_gatewayTotal.toRawUzsPrice(),
                    style: AppText.bold18.copyWith(color: c.textPrimary)),
              ],
            ),
          ],
          // Below the total, never among the discount rows above: cashback is
          // credited after payment, not taken off the price. Priced off what
          // the CARD pays — wallet money earns nothing, or the balance would
          // refill itself.
          if (cashbackFor(_cashback, _gatewayTotal) > 0) ...[
            12.kh,
            CashbackEarnLine(preview: _cashback, orderAmount: _gatewayTotal),
          ],
        ],
      ),
    );
  }
}

/// Round +/- control for the places stepper. Disabled (null [onTap]) at the
/// ends of the range rather than hidden, so the control keeps its shape.
class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? c.primary.withValues(alpha: 0.12) : c.surface,
          border: Border.all(color: enabled ? Colors.transparent : c.border),
        ),
        child: Icon(
          icon,
          size: 18.sp,
          color: enabled ? c.primary : c.textMuted,
        ),
      ),
    );
  }
}

/// Apply / remove button beside the promocode field.
class _PromoActionButton extends StatelessWidget {
  const _PromoActionButton({
    required this.label,
    required this.onTap,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 15.h),
        decoration: BoxDecoration(
          gradient: AppGradients.brand,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: loading
            ? SizedBox(
                width: 16.w,
                height: 16.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: AppText.semibold14.copyWith(color: Colors.white),
              ),
      ),
    );
  }
}
