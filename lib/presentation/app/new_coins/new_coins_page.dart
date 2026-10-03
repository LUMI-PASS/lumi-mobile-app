import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/env/runtime_env.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/card_input_formatters.dart';
import 'package:lumi_pass/common/utils/payment_error.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/common/widget/adaptive_card.dart';
import 'package:lumi_pass/common/widget/segmented_tabs.dart';
import 'package:lumi_pass/data/api_model/new_coins/new_coin_enums.dart';
import 'package:lumi_pass/data/api_model/new_coins/new_coin_models.dart';
import 'package:lumi_pass/data/api_model/order/order_model.dart';
import 'package:lumi_pass/data/service/analytics_service.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/new_coins/new_coins_repository.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:lumi_pass/presentation/app/cubit/app_cubit.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/widgets/payment_sheets.dart';
import 'package:lumi_pass/presentation/app/new_coins/new_coins_history_page.dart';
import 'package:lumi_pass/presentation/app/new_coins/new_coins_success_page.dart';
import 'package:lumi_pass/presentation/app/new_coins/widgets/new_coins_widgets.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

/// What is being bought: a pack off the shelf, or [quantity] loose coins.
class _Purchase {
  const _Purchase.pack(NewCoinPack this.pack)
      : quantity = 0,
        singlePrice = 0;

  const _Purchase.single(this.quantity, this.singlePrice) : pack = null;

  final NewCoinPack? pack;
  final int quantity;
  final num singlePrice;

  /// Marks which card shows the spinner while the purchase runs.
  String get key => pack?.id ?? _singleKey;

  int get coins => pack?.coins ?? quantity;
  num get price => pack?.price ?? singlePrice * quantity;

  static const _singleKey = 'single';
}

/// The "Lumi Coin" screen: what the buyer holds, when it expires, and the
/// shelf — main packs, extra packs and loose coins.
///
/// Lumi Coin is NOT the cashback wallet: it is bought with money in packs and
/// pays for an activity booking outright, instead of money.
///
/// The payment half is deliberately the code the "Lumi Start" packet screen
/// runs: `showPaymentChooser` for the rail, `showCardOtpSheet` for a card, and
/// a poll on app-resume for the redirect rails. A second implementation of any
/// of those is a second set of payment bugs.
@RoutePage()
class NewCoinsPage extends StatefulWidget {
  const NewCoinsPage({
    super.key,
    this.buySingle,
    this.topUpFor,
    this.returnOnPurchase = false,
  });

  /// Opened to buy exactly this many loose coins — the booking screen's "you
  /// are N short" sheet. The stepper is preset and the purchase starts as soon
  /// as the shelf has loaded, provided this buyer may buy loose coins at all.
  final int? buySingle;

  /// Opened because a booking is this many coins short. The shelf then leads
  /// with the extra packs — a top-up is what the buyer came for — and opens
  /// on the cheapest pack that covers the gap. Extras are sold only on top of
  /// a live main pack, so without one the main packs still lead.
  final int? topUpFor;

  /// Close the screen once a purchase succeeds, instead of staying on the
  /// shelf. Set by a caller the buyer wants to get back to — a booking that
  /// was one top-up short of being paid.
  final bool returnOnPurchase;

  @override
  State<NewCoinsPage> createState() => _NewCoinsPageState();
}

class _NewCoinsPageState extends State<NewCoinsPage>
    with WidgetsBindingObserver {
  final NewCoinsRepository _repo = getIt<NewCoinsRepository>();
  final OrdersApi _orders = getIt<OrdersApi>();

  NewCoinCatalogue _catalogue = NewCoinCatalogue.empty;
  NewCoinBalance _balance = NewCoinBalance.empty;
  bool _isLoading = true;
  bool _failed = false;

  /// [_Purchase.key] of the purchase in flight, or null. One at a time: every
  /// other buy button is inert while it is set.
  String? _purchasing;

  int _singleQuantity = 1;

  /// Id of the pack the buy bar pays for — whichever card of the carousel is
  /// in front.
  String? _selectedId;

  /// 0 = the shelf, 1 = what the buyer holds. The balance and its history are
  /// deliberately off the shelf: that tab is for choosing a pack and nothing
  /// else.
  int _tab = 0;

  final PageController _pageController = PageController(viewportFraction: 0.92);

  /// The [NewCoinsPage.buySingle] hand-off has run. It fires once — a reload
  /// after a failed payment must not restart a purchase nobody re-asked for.
  bool _autoBuyDone = false;

  /// Rail the buyer picked from the same chooser the booking checkout uses.
  /// Nothing is picked for them — buying asks first when this is null.
  PaymentSelection? _payment;

  /// A redirect checkout the buyer was sent off to pay. Those rails open an
  /// external app, so the only signal we get back is the OS resuming us — at
  /// which point we poll this order until it reads as paid.
  ({_Purchase purchase, CheckoutResult checkout})? _pendingCheckout;
  Timer? _pollTimer;
  bool _navigated = false;

  static const _pollInterval = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final preset = widget.buySingle;
    if (preset != null && preset > 0) {
      _singleQuantity = preset.clamp(1, NewCoinSingleCard.maxQuantity);
    }
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_pendingCheckout == null) return;
    if (state == AppLifecycleState.resumed) {
      _checkPaymentStatus();
      _pollTimer?.cancel();
      _pollTimer = Timer.periodic(_pollInterval, (_) => _checkPaymentStatus());
    } else if (state == AppLifecycleState.paused) {
      _pollTimer?.cancel();
    }
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _failed = false;
    });
    // Keeps the app-wide balance (profile tile, booking option) in step with
    // what this screen is about to show. Not awaited — it swallows its own
    // failures and this screen reads its own copy below.
    getIt<AppCubit>().syncNewCoins();
    try {
      final results = await Future.wait([
        _repo.getCatalogue(),
        // A balance that cannot be read is an empty one, not a broken screen:
        // the shelf is still worth showing.
        _repo.getBalance().catchError((_) => NewCoinBalance.empty),
      ]);
      if (!mounted) return;
      setState(() {
        _catalogue = results[0] as NewCoinCatalogue;
        _balance = results[1] as NewCoinBalance;
        // Keep the pick across a reload when that pack is still on the shelf.
        if (_selectedPack == null) _selectedId = _defaultPick()?.id;
      });
      _showSelectedCard();
      _maybeAutoBuy();
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Starts the loose-coin purchase the screen was opened for.
  void _maybeAutoBuy() {
    if (_autoBuyDone || widget.buySingle == null) return;
    _autoBuyDone = true;
    if (!_canBuySingle) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _buy(_singlePurchase);
    });
  }

  /// Extra packs are shown only to someone who may buy them — a locked shelf
  /// is a row of things the buyer cannot have.
  List<NewCoinPack> get _extras =>
      _catalogue.canBuyExtras ? _catalogue.extra : const [];

  /// Every pack on offer, in carousel order.
  List<NewCoinPack> get _shelf => _extrasFirst
      ? [..._extras, ..._catalogue.main]
      : [..._catalogue.main, ..._extras];

  /// Brings the carousel to the selected pack once it has been laid out — the
  /// top-up hand-off opens on a pack that is rarely the first card.
  void _showSelectedCard() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) return;
      final index = _shelf.indexWhere((p) => p.id == _selectedId);
      if (index > 0) _pageController.jumpToPage(index);
    });
  }

  /// The main pack whose coin is cheapest — the one worth a badge. Null when
  /// there is nothing to compare it with.
  String? get _bestOfferId {
    if (_catalogue.main.length < 2) return null;
    NewCoinPack? best;
    for (final p in _catalogue.main) {
      final perCoin = p.pricePerCoin ?? 0;
      if (perCoin <= 0) continue;
      if (best == null || perCoin < (best.pricePerCoin ?? 0)) best = p;
    }
    return best?.id;
  }

  /// Whether paying for the pack in front BY CARD brings the first-pack gift:
  /// it is still on offer, and the pack is a main one.
  bool get _bonusOnCard =>
      _catalogue.firstPackBonus > 0 &&
      _catalogue.main.any((p) => p.id == _selectedId);

  /// A booking that came up short sent the buyer here: extras lead.
  bool get _extrasFirst => widget.topUpFor != null && _extras.isNotEmpty;

  /// The pack the Buy button starts on. For a top-up, the cheapest pack that
  /// covers the gap — extras before main packs — so the default purchase is
  /// the smallest one that lets the booking go through. Otherwise the first
  /// main pack.
  NewCoinPack? _defaultPick() {
    final missing = widget.topUpFor;
    if (missing != null) {
      for (final shelf in [_extras, _catalogue.main]) {
        final covering = shelf.where((p) => p.coins >= missing).toList()
          ..sort((a, b) => a.price.compareTo(b.price));
        if (covering.isNotEmpty) return covering.first;
      }
      if (_extras.isNotEmpty) return _extras.last;
    }
    return _catalogue.main.isEmpty ? null : _catalogue.main.first;
  }

  NewCoinPack? get _selectedPack {
    for (final pack in [..._catalogue.main, ..._extras]) {
      if (pack.id == _selectedId) return pack;
    }
    return null;
  }

  /// How much cheaper a coin is in [pack] than in the dearest main pack, as a
  /// whole percent. 0 for that dearest pack itself and for extras.
  int _savingPercent(NewCoinPack pack) {
    num dearest = 0;
    for (final p in _catalogue.main) {
      final perCoin = p.pricePerCoin ?? 0;
      if (perCoin > dearest) dearest = perCoin;
    }
    final perCoin = pack.pricePerCoin ?? 0;
    if (dearest <= 0 || perCoin <= 0 || perCoin >= dearest) return 0;
    return ((dearest - perCoin) / dearest * 100).round();
  }

  bool get _canBuySingle =>
      _catalogue.canBuyExtras && _catalogue.singleCoinPrice > 0;

  _Purchase get _singlePurchase =>
      _Purchase.single(_singleQuantity, _catalogue.singleCoinPrice);

  // ── Buying ─────────────────────────────────────────────────────────────────

  /// Opens the rail chooser and remembers what the buyer picked.
  ///
  /// **Picking alone never charges** — exactly as on the packet screen. A card
  /// typed into the sheet is bound and saved there; coins are paid for from a
  /// Buy button.
  Future<PaymentSelection?> _choosePayment() async {
    if (_purchasing != null) return null;
    final picked = await showPaymentChooser(
      context,
      initial: _payment,
      cards: [if (_payment?.card != null) _payment!.card!],
      cardsComingSoon: !kCardPaymentsEnabled,
      // The first-pack gift is for a main pack paid by card. Said here, on the
      // card rail, because this is where the method is being chosen.
      cardBadge: _bonusOnCard
          ? 'new_coins_amount'.tr(args: ['+${_catalogue.firstPackBonus}'])
          : null,
    );
    if (picked == null || !mounted) return null;
    setState(() => _payment = picked);
    return picked;
  }

  /// A Buy button: pays with the rail already picked, or opens the chooser and
  /// pays with whatever comes back. The buyer has pressed Buy either way, so
  /// the pick completes that instruction.
  Future<void> _buy(_Purchase purchase) async {
    if (_purchasing != null) return;
    final payment = _payment ?? await _choosePayment();
    if (payment == null || !mounted) return;
    await _pay(purchase, payment);
  }

  Future<NewCoinPurchaseResult> _request(
    _Purchase purchase, {
    String? paymentProvider,
    String? returnUrl,
    String? cardNumber,
    String? expireDate,
    String? savedCardId,
  }) {
    final lang = context.locale.languageCode;
    final pack = purchase.pack;
    if (pack != null) {
      return _repo.purchasePack(
        pack.id,
        lang: lang,
        paymentProvider: paymentProvider,
        returnUrl: returnUrl,
        cardNumber: cardNumber,
        expireDate: expireDate,
        savedCardId: savedCardId,
      );
    }
    return _repo.purchaseSingle(
      quantity: purchase.quantity,
      lang: lang,
      paymentProvider: paymentProvider,
      returnUrl: returnUrl,
      cardNumber: cardNumber,
      expireDate: expireDate,
      savedCardId: savedCardId,
    );
  }

  Future<void> _pay(_Purchase purchase, PaymentSelection payment) async {
    setState(() => _purchasing = purchase.key);
    getIt<AnalyticsService>().logEvent(
      AnalyticsEvent.newCoinsPurchaseStarted,
      params: {
        'pack_id': purchase.pack?.id ?? '',
        'kind': purchase.pack?.kindKey ?? 'single',
        'coins': purchase.coins,
        'payment_provider': payment.rail.providerKey,
        'amount': purchase.price,
      },
    );

    final card = payment.rail == PaymentRail.card ? payment.card : null;
    final isRedirect = payment.rail != PaymentRail.card;
    try {
      // A saved card creates the order and nothing else; the charge is its own
      // call, which is what opens the OTP session.
      if (card != null && card.isSaved) {
        final order =
            (await _request(purchase, savedCardId: card.savedCardId)).checkout;
        if (!mounted) return;
        final charge = await _orders.payOrderWithSavedCard(
          orderId: order.orderId,
          cardId: card.savedCardId!,
        );
        if (!mounted) return;
        setState(() => _purchasing = null);
        if (!charge.otpRequired) {
          await _finishSuccess(purchase, order);
          return;
        }
        await _confirmCardOtp(
          purchase,
          order,
          transactionId: charge.transactionId ?? '',
          cid: charge.cid ?? '',
          otpSentPhone: charge.otpSentPhone,
        );
        return;
      }

      final result = (await _request(
        purchase,
        paymentProvider: payment.rail.providerKey,
        // Only a redirect rail has anywhere to bounce the buyer back from; the
        // card rail never leaves the app.
        returnUrl: isRedirect ? '${RuntimeEnv.baseUrl}paylov/return' : null,
        cardNumber: card?.pan,
        // Typed MM/YY, sent YYMM — the same conversion the booking screens run.
        expireDate: card == null ? null : expiryToYyMm(card.expiry),
      ))
          .checkout;
      if (!mounted) return;
      setState(() => _purchasing = null);

      if (result.isCardOtpPending) {
        await _confirmCardOtp(
          purchase,
          result,
          transactionId: result.transactionId ?? '',
          cid: result.cid ?? '',
          otpSentPhone: result.otpSentPhone,
        );
      } else if (result.status == 'paid') {
        // Nothing left to charge — the rail settled it outright.
        await _finishSuccess(purchase, result);
      } else if (result.checkoutUrl.isNotEmpty) {
        await _openRedirect(purchase, result);
      } else {
        _showError(result.paylovMessage ?? 'pay_generic_error'.tr());
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _purchasing = null);
      _showError(_errorMessage(e));
    }
  }

  /// A coin refusal in the buyer's own language, else whatever the gateway
  /// said, else the generic line.
  String _errorMessage(Object e) {
    if (e is DioException) {
      final code = NewCoinErrorCode.fromResponse(e.response?.data);
      final key = code.messageKey;
      if (key != null) {
        // The shelf on screen is out of date — a main pack lapsed, or a
        // pack was withdrawn. Refresh it under the message.
        _load();
        return key.tr();
      }
    }
    return PaymentError.fromDio(e) ?? 'pay_generic_error'.tr();
  }

  /// Collects the SMS code for a card charge and, once the gateway confirms it,
  /// hands off to the same success path a redirect payment takes. Backing out
  /// of the sheet leaves the order PENDING — nothing is charged and no coins
  /// are minted, because they only appear when the money lands.
  Future<void> _confirmCardOtp(
    _Purchase purchase,
    CheckoutResult order, {
    required String transactionId,
    required String cid,
    String? otpSentPhone,
  }) async {
    final paid = await showCardOtpSheet(
      context,
      transactionId: transactionId,
      cid: cid,
      otpSentPhone: otpSentPhone,
      confirmCard: ({
        required String transactionId,
        required String cid,
        required String otp,
      }) =>
          _orders.paylovConfirmCard(
        transactionId: transactionId,
        cid: cid,
        otp: otp,
      ),
    );
    if (paid == true && mounted) await _finishSuccess(purchase, order);
  }

  /// Redirect rails hand off to an external app. We stay on this page and poll
  /// the order once the OS brings us back.
  Future<void> _openRedirect(_Purchase purchase, CheckoutResult result) async {
    final uri = Uri.tryParse(result.checkoutUrl);
    if (uri == null) {
      _showError('pay_generic_error'.tr());
      return;
    }
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      _showError('pay_generic_error'.tr());
      return;
    }
    if (!mounted) return;
    setState(
      () => _pendingCheckout = (purchase: purchase, checkout: result),
    );
  }

  Future<void> _checkPaymentStatus() async {
    final pending = _pendingCheckout;
    if (_navigated || pending == null || !mounted) return;
    if (pending.checkout.orderId.isEmpty) return;
    try {
      final detail = await _orders.getOrderDetail(pending.checkout.orderId);
      if (detail.order.isPaid) {
        await _finishSuccess(pending.purchase, pending.checkout);
      }
    } catch (_) {
      // A hiccup while polling is non-fatal — the next tick retries.
    }
  }

  /// Hands off to the success screen, then either returns to whoever opened
  /// this screen or reloads the shelf with the new balance on it.
  Future<void> _finishSuccess(_Purchase purchase, CheckoutResult result) async {
    if (_navigated) return;
    _navigated = true;
    _pollTimer?.cancel();

    getIt<AnalyticsService>().logEvent(
      AnalyticsEvent.paymentSucceeded,
      params: {
        'product': 'new_coins',
        'pack_id': purchase.pack?.id ?? '',
        // What was actually charged. AppsFlyer maps this onto af_revenue —
        // without it the purchase lands in the dashboard as a zero-value
        // conversion.
        'amount': result.totalAmount == 0 ? purchase.price : result.totalAmount,
        'currency': result.currency,
      },
    );

    // Publish the balance BEFORE the success screen opens: the profile tile
    // and the booking the buyer may be heading back to both read it.
    await getIt<AppCubit>().syncNewCoins();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NewCoinsSuccessPage(coins: purchase.coins),
      ),
    );
    if (!mounted) return;
    if (widget.returnOnPurchase) {
      context.router.maybePop(true);
      return;
    }
    setState(() {
      _navigated = false;
      _pendingCheckout = null;
    });
    await _load();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, maxLines: 3),
        backgroundColor: context.colors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Nothing on the shelf and nothing held: the feature is not live for this
    // user, and a deep link here lands on the empty state rather than on a
    // screen of headings with nothing under them.
    final empty = !_catalogue.isOnSale && _balance.balance <= 0;

    if (_isLoading || _failed || empty) {
      return Scaffold(
        backgroundColor: c.pageBg,
        appBar: BaseAppBar(title: 'new_coins_title'.tr()),
        body: _isLoading
            ? const _NewCoinsShimmer()
            : _NewCoinsUnavailable(onRetry: _load),
      );
    }

    final pack = _selectedPack;
    final busy = _purchasing != null;
    return Scaffold(
      backgroundColor: c.pageBg,
      body: Stack(
        children: [
          // Soft wash bleeding out from behind the coin, as on the coupons
          // screen.
          Positioned(
            top: -80.h,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: 300.h,
                decoration: const BoxDecoration(
                  gradient: AppGradients.ticketStubGlow,
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.only(bottom: 24.h),
                    children: [
                      NewCoinsHero(bonus: _catalogue.firstPackBonus),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: SegmentedTabs(
                          segments: [
                            'new_coins_tab_packs'.tr(),
                            'new_coins_tab_mine'.tr(),
                          ],
                          selected: _tab,
                          onChanged: (i) {
                            setState(() => _tab = i);
                            if (i == 0) _showSelectedCard();
                          },
                        ),
                      ),
                      if (_tab == 0) ..._shelfTab() else ..._mineTab(),
                    ],
                  ),
                ),
                // One action, and only on the shelf: the pack in front and
                // Buy. The rail is asked for when Buy is pressed, not chosen
                // up here as a second decision.
                if (_tab == 0 && pack != null)
                  NewCoinsBuyBar(
                    price: pack.price,
                    isLoading: _purchasing == pack.id,
                    onBuy: busy ? null : () => _buy(_Purchase.pack(pack)),
                  ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).viewPadding.top + 16.h,
            right: 20.w,
            child: AdaptiveCard(
              onTap: () => context.router.maybePop(),
              tone: CardTone.control,
              bordered: true,
              padding: EdgeInsets.all(8.w),
              child: Icon(
                Icons.close_rounded,
                size: 16.sp,
                color: c.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 12.h),
        child: Text(
          title,
          style: AppText.semibold18.copyWith(color: context.colors.textSection),
        ),
      );

  /// The shelf: one pack in front at a time, and how coins work under it.
  List<Widget> _shelfTab() {
    final busy = _purchasing != null;
    final shelf = _shelf;
    final bestId = _bestOfferId;
    final active = shelf.indexWhere((p) => p.id == _selectedId);

    Widget card(NewCoinPack pack) {
      final isMain = _catalogue.main.any((p) => p.id == pack.id);
      return NewCoinPackCard(
        pack: pack,
        isBestOffer: pack.id == bestId,
        savingPercent: isMain ? _savingPercent(pack) : 0,
      );
    }

    return [
      // Loose coins have no place on the shelf. The one way to them is the
      // booking screen's "you are N short" hand-off, which opens this screen
      // to buy exactly that many — and only then is the card shown.
      if (widget.buySingle != null && _canBuySingle) ...[
        16.kh,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: NewCoinSingleCard(
            unitPrice: _catalogue.singleCoinPrice,
            quantity: _singleQuantity,
            isLoading: _purchasing == _Purchase._singleKey,
            enabled: !busy,
            onChanged: (q) => setState(() => _singleQuantity = q),
            onBuy: () => _buy(_singlePurchase),
          ),
        ),
      ],
      _sectionTitle('new_coins_tab_packs'.tr()),
      // A lone pack has nothing to page to, so it spans the width rather
      // than leaving the carousel's peek gap.
      if (shelf.length == 1)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: SizedBox(
            height: kNewCoinPackCardHeight.h,
            child: card(shelf.first),
          ),
        )
      else ...[
        SizedBox(
          height: kNewCoinPackCardHeight.h,
          child: PageView.builder(
            controller: _pageController,
            itemCount: shelf.length,
            padEnds: false,
            // Swiping to a card is choosing it. Locked while a purchase is
            // in flight, so the bar cannot change subject under it.
            physics: busy ? const NeverScrollableScrollPhysics() : null,
            onPageChanged: (i) => setState(() => _selectedId = shelf[i].id),
            itemBuilder: (_, i) => Padding(
              padding: EdgeInsets.only(
                left: 16.w,
                right: i == shelf.length - 1 ? 16.w : 0,
              ),
              child: card(shelf[i]),
            ),
          ),
        ),
        12.kh,
        NewCoinsDots(count: shelf.length, active: active < 0 ? 0 : active),
      ],
      _sectionTitle('plan_how_title'.tr()),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: NewCoinsHowItWorks(),
      ),
    ];
  }

  /// What the buyer holds: the balance, the deadlines behind it, and under
  /// them every movement that led there.
  List<Widget> _mineTab() => [
        16.kh,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: NewCoinsBalanceCard(balance: _balance),
        ),
        _sectionTitle('new_coins_history'.tr()),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: NewCoinsHistoryList(),
        ),
      ];
}

class _NewCoinsShimmer extends StatelessWidget {
  const _NewCoinsShimmer();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget block(double height) => Container(
          height: height.h,
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(20.r),
          ),
        );

    return Shimmer.fromColors(
      baseColor: c.surface,
      highlightColor: c.control,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        physics: const NeverScrollableScrollPhysics(),
        children: [block(120), 8.kh, block(170), block(170)],
      ),
    );
  }
}

/// Nothing on sale, or the shelf could not be loaded. Says so and offers the
/// one thing that can help: looking again.
class _NewCoinsUnavailable extends StatelessWidget {
  const _NewCoinsUnavailable({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Assets.images.empty.image(width: 140.w),
            16.kh,
            Text(
              'new_coins_empty_title'.tr(),
              textAlign: TextAlign.center,
              style: AppText.semibold16.copyWith(color: c.textPrimary),
            ),
            8.kh,
            Text(
              'new_coins_empty_body'.tr(),
              textAlign: TextAlign.center,
              style: AppText.regular14.copyWith(color: c.textSecondary),
            ),
            20.kh,
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
                decoration: BoxDecoration(
                  gradient: AppGradients.brand,
                  borderRadius: BorderRadius.circular(44.r),
                ),
                child: Text(
                  'retry'.tr(),
                  style: AppText.medium14.copyWith(color: c.onPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
