import 'dart:async';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lumi_pass/common/env/runtime_env.dart';
import 'package:lumi_pass/common/utils/card_input_formatters.dart';
import 'package:lumi_pass/common/utils/payment_error.dart';
import 'package:lumi_pass/data/api_model/new_coins/new_coin_enums.dart';
import 'package:lumi_pass/data/api_model/new_coins/new_coin_models.dart';
import 'package:lumi_pass/data/api_model/order/order_model.dart';
import 'package:lumi_pass/data/service/analytics_service.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/new_coins/new_coins_repository.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:lumi_pass/presentation/app/cubit/app_cubit.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/widgets/payment_sheets.dart';
import 'package:url_launcher/url_launcher.dart';

/// What is being bought: a pack off the shelf, or [quantity] loose coins.
class NewCoinPurchase {
  const NewCoinPurchase.pack(NewCoinPack this.pack)
      : quantity = 0,
        singlePrice = 0;

  const NewCoinPurchase.single(this.quantity, this.singlePrice) : pack = null;

  final NewCoinPack? pack;
  final int quantity;
  final num singlePrice;

  /// Marks which control shows the spinner while the purchase runs.
  String get key => pack?.id ?? singleKey;

  int get coins => pack?.coins ?? quantity;
  num get price => pack?.price ?? singlePrice * quantity;

  static const singleKey = 'single';
}

/// One coin purchase, from Buy to coins on the balance, on whichever screen
/// hosts it.
///
/// It exists so the Lumi Coin screen and the booking screen run the SAME
/// payment code: the rail chooser, the saved-card charge, the card OTP, the
/// redirect rails and the poll that follows them back. A buyer who is a few
/// coins short on a booking tops up right there — the sheets open over the
/// booking — instead of being sent to another screen to do it.
///
/// The payment half is deliberately what the "Lumi Start" packet screen runs:
/// `showPaymentChooser` for the rail, `showCardOtpSheet` for a card, and a
/// poll on app-resume for the redirect rails.
///
/// The host calls [attach] in `initState` and [dispose] in `dispose`.
class NewCoinsPurchaseController with WidgetsBindingObserver {
  NewCoinsPurchaseController({
    required State host,
    required this.notify,
    required this.onPaid,
    required this.onError,
    this.onShelfStale,
  }) : _host = host;

  final State _host;

  /// The host's `setState` — called whenever [purchasing] or [payment] change.
  final VoidCallback notify;

  /// The money landed and the app-wide balance has been re-read. What the host
  /// shows next — a success screen, or just the refreshed booking — is its own
  /// business.
  final Future<void> Function(NewCoinPurchase purchase, CheckoutResult result)
      onPaid;

  final void Function(String message) onError;

  /// The server refused with a coin rule (a main pack lapsed, a pack was
  /// withdrawn): whatever the host is showing is out of date.
  final VoidCallback? onShelfStale;

  final NewCoinsRepository _repo = getIt<NewCoinsRepository>();
  final OrdersApi _orders = getIt<OrdersApi>();

  /// [NewCoinPurchase.key] of the purchase in flight, or null. One at a time.
  String? purchasing;

  /// Rail the buyer picked. Nothing is picked for them — buying asks first
  /// when this is null.
  PaymentSelection? payment;

  /// A redirect checkout the buyer was sent off to pay. Those rails open an
  /// external app, so the only signal back is the OS resuming us — at which
  /// point this order is polled until it reads as paid.
  ({NewCoinPurchase purchase, CheckoutResult checkout})? _pending;
  Timer? _pollTimer;
  bool _settling = false;

  static const _pollInterval = Duration(seconds: 2);

  bool get _mounted => _host.mounted;
  BuildContext get _context => _host.context;

  void attach() => WidgetsBinding.instance.addObserver(this);

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_pending == null) return;
    if (state == AppLifecycleState.resumed) {
      _checkPaymentStatus();
      _pollTimer?.cancel();
      _pollTimer = Timer.periodic(_pollInterval, (_) => _checkPaymentStatus());
    } else if (state == AppLifecycleState.paused) {
      _pollTimer?.cancel();
    }
  }

  void _set(VoidCallback change) {
    change();
    if (_mounted) notify();
  }

  /// Opens the rail chooser and remembers what the buyer picked.
  ///
  /// **Picking alone never charges.** A card typed into the sheet is bound and
  /// saved there; coins are paid for from a Buy button. [cardBadge] is the
  /// perk shown on the card rail, when paying by card earns one.
  Future<PaymentSelection?> choosePayment({String? cardBadge}) async {
    if (purchasing != null) return null;
    final picked = await showPaymentChooser(
      _context,
      initial: payment,
      cards: [if (payment?.card != null) payment!.card!],
      cardsComingSoon: !kCardPaymentsEnabled,
      cardBadge: cardBadge,
    );
    if (picked == null || !_mounted) return null;
    _set(() => payment = picked);
    return picked;
  }

  /// A Buy button: pays with the rail already picked, or opens the chooser and
  /// pays with whatever comes back. The buyer has pressed Buy either way, so
  /// the pick completes that instruction.
  Future<void> buy(NewCoinPurchase purchase, {String? cardBadge}) async {
    if (purchasing != null) return;
    final picked = payment ?? await choosePayment(cardBadge: cardBadge);
    if (picked == null || !_mounted) return;
    await _pay(purchase, picked);
  }

  Future<NewCoinPurchaseResult> _request(
    NewCoinPurchase purchase, {
    String? paymentProvider,
    String? returnUrl,
    String? cardNumber,
    String? expireDate,
    String? savedCardId,
  }) {
    final lang = _context.locale.languageCode;
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

  Future<void> _pay(NewCoinPurchase purchase, PaymentSelection payment) async {
    _set(() => purchasing = purchase.key);
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
        if (!_mounted) return;
        final charge = await _orders.payOrderWithSavedCard(
          orderId: order.orderId,
          cardId: card.savedCardId!,
        );
        if (!_mounted) return;
        _set(() => purchasing = null);
        if (!charge.otpRequired) {
          await _finish(purchase, order);
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
      if (!_mounted) return;
      _set(() => purchasing = null);

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
        await _finish(purchase, result);
      } else if (result.checkoutUrl.isNotEmpty) {
        await _openRedirect(purchase, result);
      } else {
        onError(result.paylovMessage ?? 'pay_generic_error'.tr());
      }
    } catch (e) {
      if (!_mounted) return;
      _set(() => purchasing = null);
      onError(_errorMessage(e));
    }
  }

  /// A coin refusal in the buyer's own language, else whatever the gateway
  /// said, else the generic line.
  String _errorMessage(Object e) {
    if (e is DioException) {
      final code = NewCoinErrorCode.fromResponse(e.response?.data);
      final key = code.messageKey;
      if (key != null) {
        onShelfStale?.call();
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
    NewCoinPurchase purchase,
    CheckoutResult order, {
    required String transactionId,
    required String cid,
    String? otpSentPhone,
  }) async {
    final paid = await showCardOtpSheet(
      _context,
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
    if (paid == true && _mounted) await _finish(purchase, order);
  }

  /// Redirect rails hand off to an external app. The host screen stays where
  /// it is and the order is polled once the OS brings us back.
  Future<void> _openRedirect(
    NewCoinPurchase purchase,
    CheckoutResult result,
  ) async {
    final uri = Uri.tryParse(result.checkoutUrl);
    if (uri == null) {
      onError('pay_generic_error'.tr());
      return;
    }
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      onError('pay_generic_error'.tr());
      return;
    }
    if (!_mounted) return;
    _pending = (purchase: purchase, checkout: result);
  }

  Future<void> _checkPaymentStatus() async {
    final pending = _pending;
    if (_settling || pending == null || !_mounted) return;
    if (pending.checkout.orderId.isEmpty) return;
    try {
      final detail = await _orders.getOrderDetail(pending.checkout.orderId);
      if (detail.order.isPaid) {
        await _finish(pending.purchase, pending.checkout);
      }
    } catch (_) {
      // A hiccup while polling is non-fatal — the next tick retries.
    }
  }

  /// The money landed: record it, re-read the balance, and hand over to the
  /// host. Runs once per purchase however many signals report it paid.
  Future<void> _finish(NewCoinPurchase purchase, CheckoutResult result) async {
    if (_settling) return;
    _settling = true;
    _pollTimer?.cancel();
    _pending = null;

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

    try {
      // Publish the balance BEFORE the host reacts: the profile tile and the
      // booking the buyer may be looking at both read it.
      await getIt<AppCubit>().syncNewCoins();
      if (_mounted) await onPaid(purchase, result);
    } finally {
      _settling = false;
    }
  }
}
