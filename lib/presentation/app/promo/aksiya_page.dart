import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/env/runtime_env.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/card_input_formatters.dart';
import 'package:lumi_pass/common/utils/payment_error.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/common/widget/pill_card.dart';
import 'package:lumi_pass/data/api_model/order/order_model.dart';
import 'package:lumi_pass/data/api_model/promo/promo_campaign.dart';
import 'package:lumi_pass/data/service/analytics_service.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:lumi_pass/domain/repo/promo/promo_repository.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/widgets/payment_sheets.dart';
import 'package:lumi_pass/presentation/app/promo/aksiya_pass_page.dart';
import 'package:lumi_pass/presentation/app/promo/aksiya_success_page.dart';
import 'package:lumi_pass/presentation/app/promo/widgets/aksiya_widgets.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

/// The "аксия" screen: the bundle, what it costs, and how to buy it.
///
/// Its own screen rather than a card on the tariffs page, because it is a
/// different product with a different promise — a prepaid set of visits with a
/// deadline, not a standing discount — and the deadline has to be stated before
/// the money is taken, not discovered afterwards.
///
/// The payment half is deliberately the same code the tariffs screen runs:
/// `showPaymentChooser` for the rail, `showCardOtpSheet` for a card, and a poll
/// on app-resume for the redirect rails. A second implementation of any of those
/// is a second set of payment bugs.
@RoutePage()
class AksiyaPage extends StatefulWidget {
  const AksiyaPage({super.key, this.slug});

  /// Which bundle to show. Null means "the best one on sale" — the list is
  /// already ordered, so the first row is it. Deep links pass a slug.
  final String? slug;

  @override
  State<AksiyaPage> createState() => _AksiyaPageState();
}

class _AksiyaPageState extends State<AksiyaPage> with WidgetsBindingObserver {
  final PromoRepository _repo = getIt<PromoRepository>();
  final OrdersApi _orders = getIt<OrdersApi>();

  PromoCampaign? _campaign;
  bool _isLoading = true;
  bool _failed = false;
  bool _purchasing = false;

  /// Rail the buyer picked from the same chooser the booking checkout uses.
  /// Nothing is picked for them — buying is blocked until this is set.
  PaymentSelection? _payment;

  /// A redirect checkout the buyer was sent off to pay. Those rails open an
  /// external app, so the only signal we get back is the OS resuming us — at
  /// which point we poll this order until it reads as paid.
  CheckoutResult? _pendingCheckout;
  Timer? _pollTimer;
  bool _navigated = false;

  static const _pollInterval = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
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
    try {
      final slug = widget.slug;
      final PromoCampaign? campaign;
      if (slug != null && slug.isNotEmpty) {
        campaign = await _repo.getCampaign(slug);
      } else {
        // The list is already ordered best-offer-first, so the first row is the
        // one to show when no particular bundle was asked for.
        final all = await _repo.getCampaigns();
        campaign = all.isEmpty ? null : all.first;
      }
      if (!mounted) return;
      setState(() {
        _campaign = campaign;
        // A screen reached by a deep link to a retired campaign has nothing to
        // show — that is an empty state, not a crash.
        _failed = campaign == null;
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Buying ─────────────────────────────────────────────────────────────────

  /// Opens the rail chooser and remembers what the buyer picked.
  ///
  /// **Picking alone never charges.** A card typed into the sheet is bound and
  /// saved there; the bundle is paid for from the Buy bar. The tariffs screen
  /// learned this the hard way — paying on pick meant "Change" charged the plan
  /// before the buyer ever pressed Buy.
  Future<PaymentSelection?> _choosePayment() async {
    if (_purchasing) return null;
    final picked = await showPaymentChooser(
      context,
      initial: _payment,
      cards: [if (_payment?.card != null) _payment!.card!],
      cardsComingSoon: !kCardPaymentsEnabled,
    );
    if (picked == null || !mounted) return null;
    setState(() => _payment = picked);
    return picked;
  }

  /// Buy CTA: pays with the rail already picked, or opens the chooser and pays
  /// with whatever comes back. The buyer has pressed Buy either way, so the
  /// pick completes that instruction rather than starting a payment nobody
  /// asked for.
  Future<void> _purchase() async {
    final campaign = _campaign;
    if (campaign == null || _purchasing) return;
    final payment = _payment ?? await _choosePayment();
    if (payment == null || !mounted) return;
    await _pay(campaign, payment);
  }

  Future<void> _pay(PromoCampaign campaign, PaymentSelection payment) async {
    setState(() => _purchasing = true);
    getIt<AnalyticsService>().logEvent(
      AnalyticsEvent.aksiyaPurchaseStarted,
      params: {
        'campaign_slug': campaign.slug,
        'campaign_id': campaign.id,
        'payment_provider': payment.rail.providerKey,
        'activities_count': campaign.activitiesCount,
        'valid_days': campaign.validDays,
        'amount': campaign.price,
      },
    );

    final card = payment.rail == PaymentRail.card ? payment.card : null;
    final isRedirect = payment.rail != PaymentRail.card;
    try {
      // A saved card creates the order and nothing else; the charge is its own
      // call, which is what opens the OTP session.
      if (card != null && card.isSaved) {
        final order = await _repo.purchase(
          campaign.slug,
          savedCardId: card.savedCardId,
        );
        if (!mounted) return;
        final charge = await _orders.payOrderWithSavedCard(
          orderId: order.orderId,
          cardId: card.savedCardId!,
        );
        if (!mounted) return;
        setState(() => _purchasing = false);
        if (!charge.otpRequired) {
          await _finishSuccess(campaign, order);
          return;
        }
        await _confirmCardOtp(
          campaign,
          order,
          transactionId: charge.transactionId ?? '',
          cid: charge.cid ?? '',
          otpSentPhone: charge.otpSentPhone,
        );
        return;
      }

      final result = await _repo.purchase(
        campaign.slug,
        paymentProvider: payment.rail.providerKey,
        // Only a redirect rail has anywhere to bounce the buyer back from; the
        // card rail never leaves the app.
        returnUrl: isRedirect ? '${RuntimeEnv.baseUrl}paylov/return' : null,
        cardNumber: card?.pan,
        // Typed MM/YY, sent YYMM — the same conversion the booking screens run.
        expireDate: card == null ? null : expiryToYyMm(card.expiry),
      );
      if (!mounted) return;
      setState(() => _purchasing = false);

      if (result.isCardOtpPending) {
        await _confirmCardOtp(
          campaign,
          result,
          transactionId: result.transactionId ?? '',
          cid: result.cid ?? '',
          otpSentPhone: result.otpSentPhone,
        );
      } else if (result.status == 'paid') {
        // Nothing left to charge — the rail settled it outright.
        await _finishSuccess(campaign, result);
      } else if (result.checkoutUrl.isNotEmpty) {
        await _openRedirect(result);
      } else {
        _showError(result.paylovMessage ?? 'pay_generic_error'.tr());
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _purchasing = false);
      _showError(PaymentError.fromDio(e) ?? 'pay_generic_error'.tr());
    }
  }

  /// Collects the SMS code for a card charge and, once the gateway confirms it,
  /// hands off to the same success path a redirect payment takes. Backing out of
  /// the sheet leaves the order PENDING — nothing is charged and no pass is
  /// minted, because the pass is only created when the money lands.
  Future<void> _confirmCardOtp(
    PromoCampaign campaign,
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
    if (paid == true && mounted) await _finishSuccess(campaign, order);
  }

  /// Redirect rails hand off to an external app. We stay on this page and poll
  /// the order once the OS brings us back.
  Future<void> _openRedirect(CheckoutResult result) async {
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
    setState(() => _pendingCheckout = result);
  }

  Future<void> _checkPaymentStatus() async {
    final checkout = _pendingCheckout;
    final campaign = _campaign;
    if (_navigated || checkout == null || campaign == null || !mounted) return;
    if (checkout.orderId.isEmpty) return;
    try {
      final detail = await _orders.getOrderDetail(checkout.orderId);
      if (detail.order.isPaid) await _finishSuccess(campaign, checkout);
    } catch (_) {
      // A hiccup while polling is non-fatal — the next tick retries.
    }
  }

  /// Hands off to the success screen, then reloads so the offer screen comes
  /// back showing the pass the buyer now holds rather than the Buy bar.
  Future<void> _finishSuccess(
    PromoCampaign campaign,
    CheckoutResult result,
  ) async {
    if (_navigated) return;
    _navigated = true;
    _pollTimer?.cancel();

    getIt<AnalyticsService>().logEvent(
      AnalyticsEvent.paymentSucceeded,
      params: {
        'campaign_slug': campaign.slug,
        'product': 'aksiya',
        // What was actually charged. AppsFlyer maps this onto af_revenue —
        // without it the purchase lands in the dashboard as a zero-value
        // conversion and ROAS per campaign is wrong.
        'amount': result.totalAmount == 0 ? campaign.price : result.totalAmount,
        'currency': result.currency,
      },
    );

    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AksiyaSuccessPage(campaign: campaign),
      ),
    );
    if (!mounted) return;
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

  /// Off to pick somewhere to spend a visit. The discovery tab is the right
  /// destination even for a scoped campaign: the eligible activities are not
  /// known to this screen, and checkout is where the rule is enforced.
  void _openDiscovery() {
    context.router.push(SearchDiscoveryRoute());
  }

  void _openPass(String passId) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AksiyaPassPage(passId: passId)),
    );
  }

  /// Glyph inside the payment row's badge: the rail's brand mark, or a neutral
  /// card icon when nothing is picked. Mirrors the booking screen's
  /// `_paymentLeading` — square marks, since the round badge is too narrow for
  /// the full wordmarks.
  Widget _paymentLeading(PaymentSelection? payment) {
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

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final campaign = _campaign;

    return Scaffold(
      backgroundColor: c.pageBg,
      appBar: BaseAppBar(title: 'aksiya_title'.tr()),
      body: Stack(
        children: [
          // Soft wash bleeding out from behind the hero.
          Positioned(
            top: -60.h,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: 280.h,
                decoration:
                    const BoxDecoration(gradient: AppGradients.greenGlow),
              ),
            ),
          ),
          if (_isLoading)
            const _AksiyaShimmer()
          else if (campaign == null || _failed)
            _AksiyaUnavailable(onRetry: _load)
          else
            _content(campaign),
        ],
      ),
      bottomNavigationBar:
          campaign == null || _isLoading ? null : _bottomBar(campaign),
    );
  }

  Widget _content(PromoCampaign campaign) {
    final c = context.colors;
    final held = campaign.heldPass;

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      children: [
        AksiyaHero(campaign: campaign),
        // Someone who already owns the bundle is shown what is left on it
        // first — that, not the pitch, is what they opened this screen for.
        if (held != null) ...[
          16.kh,
          AksiyaPassCard.fromSummary(
            held,
            onTap: () => _openPass(held.id),
          ),
        ],
        if ((campaign.description ?? '').isNotEmpty) ...[
          20.kh,
          Text(
            campaign.description!,
            style: AppText.regular14.copyWith(color: c.textSecondary),
          ),
        ],
        20.kh,
        Text(
          'aksiya_how_it_works'.tr(),
          style: AppText.semibold18.copyWith(color: c.textSection),
        ),
        12.kh,
        AksiyaSteps(campaign: campaign),
        20.kh,
        AksiyaHighlights(campaign: campaign),
        // The payment row is hidden once a pass is held: there is nothing left
        // to pay for on this screen, and offering a rail would be offering to
        // sell a second bundle the campaign has already refused.
        if (held == null && campaign.canPurchase) ...[
          8.kh,
          Text(
            'aksiya_payment_section'.tr(),
            style: AppText.semibold18.copyWith(color: c.textSection),
          ),
          12.kh,
          PillCard(
            onTap: _purchasing ? null : _choosePayment,
            leading: PillIconBadge(child: _paymentLeading(_payment)),
            trailing: PillActionChip(
              label: _payment == null ? 'book_choose'.tr() : 'book_change'.tr(),
              onTap: _purchasing ? null : _choosePayment,
            ),
            child: PillCaption(
              captionFirst: true,
              subtitle: 'book_pay_method_label'.tr(),
              // The card rail has no wordmark — the card itself is its name, as
              // in the booking and tariffs rows.
              title: _payment == null
                  ? 'book_pick_payment'.tr()
                  : _payment!.rail == PaymentRail.card
                      ? (_payment!.card?.label ?? 'pay_with_card'.tr())
                      : _payment!.rail.brandName,
              titleColor: _payment == null ? c.textSecondary : null,
            ),
          ),
        ],
      ],
    );
  }

  Widget _bottomBar(PromoCampaign campaign) {
    final held = campaign.heldPass;
    // Already own it: the bar stops selling and starts sending. A second bundle
    // would just expire alongside the first.
    if (held != null) {
      return AksiyaBottomBar(
        label: 'aksiya_spend_cta'.tr(),
        onTap: _openDiscovery,
      );
    }
    if (!campaign.canPurchase) {
      return AksiyaBottomBar(
        label: 'aksiya_unavailable_cta'.tr(),
        onTap: () {},
        enabled: false,
      );
    }
    return AksiyaBottomBar(
      caption: 'aksiya_price_label'.tr(),
      amount: campaign.price,
      label: 'aksiya_buy_cta'.tr(),
      isLoading: _purchasing,
      onTap: _purchase,
    );
  }
}

class _AksiyaShimmer extends StatelessWidget {
  const _AksiyaShimmer();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget block(double height, {double radius = 16}) => Container(
          height: height.h,
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(radius.r),
          ),
        );

    return Shimmer.fromColors(
      baseColor: c.surface,
      highlightColor: c.control,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          block(196, radius: 24),
          8.kh,
          block(78),
          block(78),
          block(78),
        ],
      ),
    );
  }
}

/// Nothing on sale, or a deep link to a bundle that has since been retired.
/// An offer that no longer exists is an empty state, not an error — so it says
/// so and offers the one thing that can help: looking again.
class _AksiyaUnavailable extends StatelessWidget {
  const _AksiyaUnavailable({required this.onRetry});

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
              'aksiya_empty_title'.tr(),
              textAlign: TextAlign.center,
              style: AppText.semibold16.copyWith(color: c.textPrimary),
            ),
            8.kh,
            Text(
              'aksiya_empty_body'.tr(),
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
