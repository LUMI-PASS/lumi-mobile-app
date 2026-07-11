import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/adaptive_card.dart';
import 'package:lumi_pass/data/api_model/order/order_model.dart';
import 'package:lumi_pass/data/api_model/premium_plan/premium_plan_model.dart';
import 'package:lumi_pass/data/service/analytics_service.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/widgets/payment_sheets.dart';
import 'package:lumi_pass/presentation/app/home/plans/coupon_success_page.dart';
import 'package:lumi_pass/presentation/app/home/plans/premium_success_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

/// Height of a coupon card in the horizontal carousel. Fixed so the [PageView]
/// can size itself; the cards' content is top-aligned inside it.
const double _kCouponCardHeight = 184;

@RoutePage()
class PlansPage extends StatefulWidget {
  const PlansPage({super.key});

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> with WidgetsBindingObserver {
  final HomeRepository _repo = getIt<HomeRepository>();
  final OrdersApi _api = getIt<OrdersApi>();

  final PageController _pageController =
      PageController(viewportFraction: 0.92);

  List<PremiumPlan> _plans = [];
  bool _isLoading = true;
  String? _purchasingId;
  int _selected = 0;

  /// Rail (and card) the buyer picked in the chooser sheet, remembered for the
  /// rest of the session so a second purchase starts from their last choice.
  PaymentSelection? _payment;
  final List<PaymentCard> _cards = [];

  /// A redirect checkout the buyer was sent off to pay. The rails open an
  /// external app, so the only signal we get back is the OS resuming us — at
  /// which point we poll this order until it reads as paid.
  CheckoutResult? _pendingCheckout;
  PremiumPlan? _pendingPlan;
  Timer? _pollTimer;
  bool _navigated = false;

  /// Cycles the coupon carousel on its own. A touch pauses it, so it never
  /// yanks a card out from under the buyer's thumb.
  Timer? _autoScrollTimer;

  static const _pollInterval = Duration(seconds: 2);

  /// A step quicker than the home banner carousel's 5s.
  static const _autoScrollInterval = Duration(seconds: 4);
  static const _autoScrollDuration = Duration(milliseconds: 450);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController.addListener(_onPageScroll);
    _loadPlans();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    _autoScrollTimer?.cancel();
    _pageController
      ..removeListener(_onPageScroll)
      ..dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startAutoScroll();
    } else if (state == AppLifecycleState.paused) {
      _autoScrollTimer?.cancel();
    }

    if (_pendingCheckout == null) return;
    if (state == AppLifecycleState.resumed) {
      _checkPaymentStatus();
      _pollTimer?.cancel();
      _pollTimer = Timer.periodic(_pollInterval, (_) => _checkPaymentStatus());
    } else if (state == AppLifecycleState.paused) {
      _pollTimer?.cancel();
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    if (_plans.length < 2) return;
    _autoScrollTimer = Timer.periodic(_autoScrollInterval, (_) {
      if (!mounted || !_pageController.hasClients || _plans.length < 2) return;
      _pageController.animateToPage(
        (_selected + 1) % _plans.length,
        duration: _autoScrollDuration,
        curve: Curves.easeInOut,
      );
    });
  }

  void _onPageScroll() {
    final page = _pageController.page?.round() ?? 0;
    if (page != _selected) setState(() => _selected = page);
  }

  Future<void> _loadPlans() async {
    setState(() => _isLoading = true);
    try {
      final data = await _repo.getPremiumPlans();
      if (!mounted) return;
      setState(() => _plans = data.where((p) => p.isActive != false).toList());
      _startAutoScroll();
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openHistory() => context.router.push(const PaymentHistoryRoute());

  /// Buy CTA. The chooser sheet only *picks* a rail — the charge happens here,
  /// once the buyer has confirmed one.
  Future<void> _purchase(PremiumPlan plan) async {
    if (plan.id == null || _purchasingId != null) return;

    final picked = await showPaymentChooser(
      context,
      initial: _payment,
      cards: _cards,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _payment = picked;
      final card = picked.card;
      if (card != null && !_cards.contains(card)) _cards.add(card);
    });
    if (!picked.isPayable) return;

    await _pay(plan, picked);
  }

  Future<void> _pay(PremiumPlan plan, PaymentSelection payment) async {
    setState(() => _purchasingId = plan.id);
    getIt<AnalyticsService>().logEvent(
      AnalyticsEvent.planPurchaseStarted,
      params: {
        'plan_id': plan.id!,
        'payment_provider': payment.rail.providerKey,
        if (plan.discountPercentage != null)
          'discount_percentage': plan.discountPercentage!.round(),
      },
    );
    final card = payment.card;
    try {
      final result = await _api.checkoutSubscription(
        tariffId: plan.id!,
        paymentProvider: payment.rail.providerKey,
        cardNumber: card?.pan,
        expireDate: card?.expiry,
      );
      if (!mounted) return;
      setState(() => _purchasingId = null);

      if (result.isCardOtpPending) {
        // The card rail finishes inside the app: confirm the OTP in a sheet.
        final paid = await showCardOtpSheet(
          context,
          checkout: result,
          confirmCard: ({
            required String transactionId,
            required String cid,
            required String otp,
          }) =>
              _api.paylovConfirmCard(
            transactionId: transactionId,
            cid: cid,
            otp: otp,
          ),
        );
        if (paid == true && mounted) await _finishSuccess(plan, result);
      } else if (result.checkoutUrl.isNotEmpty) {
        await _openRedirect(plan, result);
      } else {
        _showError('pay_generic_error'.tr());
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _purchasingId = null);
      _showError(e.toString());
    }
  }

  /// Redirect rails hand off to an external app. We stay on this page and poll
  /// the order once the OS brings us back.
  Future<void> _openRedirect(PremiumPlan plan, CheckoutResult result) async {
    final uri = Uri.tryParse(result.checkoutUrl);
    if (uri == null) {
      _showError('pay_generic_error'.tr());
      return;
    }
    final launched =
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      _showError('pay_generic_error'.tr());
      return;
    }
    if (!mounted) return;
    setState(() {
      _pendingCheckout = result;
      _pendingPlan = plan;
    });
  }

  Future<void> _checkPaymentStatus() async {
    final checkout = _pendingCheckout;
    final plan = _pendingPlan;
    if (_navigated || checkout == null || plan == null || !mounted) return;
    if (checkout.orderId.isEmpty) return;
    try {
      final detail = await _api.getOrderDetail(checkout.orderId);
      if (detail.order.isPaid) await _finishSuccess(plan, checkout);
    } catch (_) {
      // A hiccup while polling is non-fatal — the next tick retries.
    }
  }

  /// Marks the plan active and hands off to the success screen. Mirrors what
  /// the old checkout page did on a paid subscription.
  Future<void> _finishSuccess(PremiumPlan plan, CheckoutResult result) async {
    if (_navigated) return;
    _navigated = true;
    _pollTimer?.cancel();

    final discount = plan.discountPercentage?.round();
    getIt<AnalyticsService>().logEvent(
      AnalyticsEvent.paymentSucceeded,
      params: {
        'plan_id': plan.id ?? '',
        if (discount != null) 'discount_percentage': discount,
      },
    );
    await getIt<Storage>().hasPremium.set(true);
    if (discount != null) {
      await getIt<Storage>().planDiscountPercentage.set(discount);
    }
    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => discount != null && discount > 0
            ? CouponSuccessPage(discountPercentage: discount)
            : const PremiumSuccessPage(),
      ),
    );
    if (!mounted) return;
    setState(() {
      _navigated = false;
      _pendingCheckout = null;
      _pendingPlan = null;
    });
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

  /// Highest discount across all plans — drives the hero's "До N%" chip.
  double get _bestDiscount => _plans.fold<double>(
        0,
        (max, p) => (p.discountPercentage ?? 0) > max
            ? (p.discountPercentage ?? 0)
            : max,
      );

  /// The single card that earns the "BEST OFFER" ribbon. Indexed rather than
  /// compared by value, so plans tied on the top discount don't all get one.
  /// `-1` when no plan carries a discount.
  int get _bestOfferIndex => _bestDiscount > 0
      ? _plans.indexWhere((p) => p.discountPercentage == _bestDiscount)
      : -1;

  PremiumPlan? get _selectedPlan =>
      _selected < _plans.length ? _plans[_selected] : null;

  @override
  Widget build(BuildContext context) {
    final plan = _selectedPlan;
    return Scaffold(
      backgroundColor: context.colors.pageBg,
      body: Stack(
        children: [
          // Soft green wash bleeding out from behind the ticket artwork.
          Positioned(
            top: -80.h,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: 320.h,
                decoration: const BoxDecoration(
                  gradient: AppGradients.greenGlow,
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
                      _Hero(bestDiscount: _bestDiscount),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: _HistoryTile(onTap: _openHistory),
                      ),
                      24.kh,
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          'coupons_title'.tr(),
                          style: AppText.semibold18
                              .copyWith(color: context.colors.textSection),
                        ),
                      ),
                      16.kh,
                      if (_isLoading)
                        const _CouponsShimmer()
                      else if (_plans.isEmpty)
                        const _EmptyPlans()
                      // A lone coupon has nothing to page to, so it spans the
                      // width rather than leaving the carousel's peek gap.
                      else if (_plans.length == 1)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: SizedBox(
                            height: _kCouponCardHeight.h,
                            child: _CouponCard(
                              plan: _plans.first,
                              isBestOffer: _bestOfferIndex == 0,
                            ),
                          ),
                        )
                      else ...[
                        SizedBox(
                          height: _kCouponCardHeight.h,
                          // A finger on the carousel halts the auto-advance;
                          // it picks back up once the touch ends.
                          child: Listener(
                            onPointerDown: (_) => _autoScrollTimer?.cancel(),
                            onPointerUp: (_) => _startAutoScroll(),
                            onPointerCancel: (_) => _startAutoScroll(),
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: _plans.length,
                              padEnds: false,
                              itemBuilder: (_, i) => Padding(
                                padding: EdgeInsets.only(
                                  left: 16.w,
                                  right: i == _plans.length - 1 ? 16.w : 0,
                                ),
                                child: _CouponCard(
                                  plan: _plans[i],
                                  isBestOffer: i == _bestOfferIndex,
                                ),
                              ),
                            ),
                          ),
                        ),
                        12.kh,
                        _Dots(count: _plans.length, active: _selected),
                      ],
                      32.kh,
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          'plan_how_title'.tr(),
                          style: AppText.semibold18
                              .copyWith(color: context.colors.textSection),
                        ),
                      ),
                      16.kh,
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: _HowItWorks(),
                      ),
                    ],
                  ),
                ),
                if (plan != null)
                  _BuyBar(
                    price: plan.price ?? 0,
                    isLoading: _purchasingId == plan.id,
                    onBuy: () => _purchase(plan),
                  ),
              ],
            ),
          ),
          // Sits outside the scroll view so it stays put as the page scrolls.
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
                color: context.colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero — ticket artwork, rotated chips, close button, title ────────────────

class _Hero extends StatelessWidget {
  const _Hero({required this.bestDiscount});

  final double bestDiscount;

  @override
  Widget build(BuildContext context) {
    final art = 218.w;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 232.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // The two chips are anchored to the artwork (not the screen), so
              // they keep hugging the ticket's corners on any width. They
              // deliberately overflow the artwork's box — hence `Clip.none`.
              SizedBox(
                width: art,
                height: art,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Assets.images.imageDiscount.image(fit: BoxFit.contain),
                    // Figma centres these chips on a point near the ticket's
                    // top-left / bottom-right corner, so most of each chip
                    // hangs off the artwork.
                    _ArtChip(
                      label: 'coupon_plans_title'.tr(),
                      art: art,
                      centerX: 0.072,
                      centerY: 0.293,
                      angle: -0.385, // −22.04°
                    ),
                    if (bestDiscount > 0)
                      _ArtChip(
                        label: 'coupon_up_to'.tr(namedArgs: {
                          'percent': _fmtPercent(bestDiscount),
                        }),
                        art: art,
                        centerX: 0.944,
                        centerY: 0.647,
                        angle: 0.217, // 12.45°
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 48.w),
          child: Column(
            children: [
              Text(
                'coupon_offers_title'.tr(),
                textAlign: TextAlign.center,
                style: AppText.semibold24
                    .copyWith(color: context.colors.textPrimary),
              ),
              4.kh,
              Text(
                'coupon_plans_subtitle'.tr(),
                textAlign: TextAlign.center,
                style: AppText.regular12
                    .copyWith(color: context.colors.textSecondary),
              ),
            ],
          ),
        ),
        24.kh,
      ],
    );
  }
}

/// Rotated dark chip pinned to a point on the ticket artwork. Stays dark in
/// both themes by design — it paints over a photo-like asset.
///
/// [centerX] / [centerY] are fractions of the artwork box and mark where the
/// chip's *centre* lands. `Align` can't express that: its `Alignment` insets by
/// the child's own size, so a chip this wide would get dragged back toward the
/// middle. `Positioned` + a −50% [FractionalTranslation] pins the centre exactly,
/// whatever the translated label's width turns out to be.
class _ArtChip extends StatelessWidget {
  const _ArtChip({
    required this.label,
    required this.art,
    required this.centerX,
    required this.centerY,
    required this.angle,
  });

  final String label;
  final double art;
  final double centerX;
  final double centerY;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: centerX * art,
      top: centerY * art,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Transform.rotate(
          angle: angle,
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              label,
              style: AppText.semibold14.copyWith(color: AppColors.white),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Payment-history entry row ───────────────────────────────────────────────

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AdaptiveCard(
      onTap: onTap,
      tone: CardTone.control,
      borderRadius: BorderRadius.circular(40.r),
      padding: EdgeInsets.fromLTRB(8.w, 8.h, 16.w, 8.h),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Assets.icons.coupons.icFiles.svg(
                width: 20.w,
                height: 20.w,
                colorFilter:
                    ColorFilter.mode(colors.textPrimary, BlendMode.srcIn),
              ),
            ),
          ),
          8.kw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'coupon_history_title'.tr(),
                  style:
                      AppText.semibold14.copyWith(color: colors.textPrimary),
                ),
                4.kh,
                Text(
                  'coupon_history_subtitle'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      AppText.regular12.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          8.kw,
          Icon(
            Icons.chevron_right_rounded,
            size: 24.sp,
            color: colors.textPrimary,
          ),
        ],
      ),
    );
  }
}

// ─── Coupon card ─────────────────────────────────────────────────────────────

class _CouponCard extends StatelessWidget {
  const _CouponCard({required this.plan, required this.isBestOffer});

  final PremiumPlan plan;
  final bool isBestOffer;

  @override
  Widget build(BuildContext context) {
    final discount = plan.discountPercentage ?? 0;
    final activities = plan.activitiesLimit ?? 0;
    final duration = plan.durationDays ?? 0;

    return AdaptiveCard(
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
                child: Assets.icons.coupons.icRocket.svg(
                  width: 14.w,
                  height: 14.w,
                ),
              ),
              12.kw,
              Expanded(
                child: Text(
                  plan.localizedTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bold18
                      .copyWith(color: context.colors.textPrimary),
                ),
              ),
              if (isBestOffer) ...[8.kw, const _BestOfferBadge()],
            ],
          ),
          8.kh,
          if (discount > 0)
            _Condition(
              text: 'coupon_cond_discount'
                  .tr(namedArgs: {'percent': _fmtPercent(discount)}),
            ),
          if (activities > 0)
            _Condition(
              text: 'coupon_cond_activities'
                  .tr(namedArgs: {'count': '$activities'}),
            ),
          if (duration > 0)
            _Condition(
              text:
                  'coupon_cond_duration'.tr(namedArgs: {'days': '$duration'}),
            ),
          const Spacer(),
          Text(
            (plan.price ?? 0).toRawUzsPrice(),
            style:
                AppText.bold16.copyWith(color: context.colors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _BestOfferBadge extends StatelessWidget {
  const _BestOfferBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(6.w, 2.h, 9.w, 2.h),
      decoration: BoxDecoration(
        gradient: AppGradients.indigo,
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.icons.coupons.icLightning.svg(width: 12.w, height: 12.w),
          4.kw,
          Text(
            'coupon_best_offer'.tr(),
            style: AppText.bold10.copyWith(color: AppColors.white),
          ),
        ],
      ),
    );
  }
}

/// Bulleted condition line inside a coupon card.
///
/// Secondary copy, so it takes [AppColorScheme.textMuted] — the same `#85848c`
/// the ticket card uses for its meta lines. Only the plan name and the price
/// carry [AppColorScheme.textPrimary].
class _Condition extends StatelessWidget {
  const _Condition({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4.w,
            height: 4.w,
            margin: EdgeInsets.only(top: 6.h),
            decoration: BoxDecoration(
              color: context.colors.primary,
              shape: BoxShape.circle,
            ),
          ),
          4.kw,
          Expanded(
            child: Text(
              text,
              style:
                  AppText.regular12.copyWith(color: context.colors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Carousel dots ───────────────────────────────────────────────────────────

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 8.w,
          height: 8.w,
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          decoration: BoxDecoration(
            color: isActive
                ? context.colors.textPrimary
                : context.colors.border,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

// ─── "How it works" — three numbered step cards ──────────────────────────────

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    return Column(
      // Without this the third card shrink-wraps its text instead of spanning
      // the row above it.
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _StepCard(
                  icon: Assets.icons.coupons.icMagicSelection,
                  number: '01',
                  text: 'plan_step1'.tr(),
                ),
              ),
              8.kw,
              Expanded(
                child: _StepCard(
                  icon: Assets.icons.coupons.icAddInvoice,
                  number: '02',
                  text: 'plan_step2'.tr(),
                ),
              ),
            ],
          ),
        ),
        8.kh,
        _StepCard(
          icon: Assets.icons.coupons.icCoupon,
          number: '03',
          text: 'plan_step3'.tr(),
        ),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.icon,
    required this.number,
    required this.text,
  });

  final SvgGenImage icon;
  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: -6.h,
            child: ShaderMask(
              // The numeral fades out top→bottom rather than sitting at a flat
              // opacity. `srcIn` paints the gradient through the glyphs.
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) =>
                  AppGradients.stepNumeral.createShader(bounds),
              child: Text(
                number,
                style: AppText.semibold24.copyWith(
                  fontSize: 36.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              icon.svg(width: 30.w, height: 30.w),
              32.kh,
              Text(
                text,
                style: AppText.regular14
                    .copyWith(color: context.colors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Sticky buy bar ──────────────────────────────────────────────────────────

class _BuyBar extends StatelessWidget {
  const _BuyBar({
    required this.price,
    required this.isLoading,
    required this.onBuy,
  });

  final num price;
  final bool isLoading;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.bottomBar,
      padding: EdgeInsets.fromLTRB(
        16.w,
        16.h,
        16.w,
        16.h + MediaQuery.of(context).viewPadding.bottom,
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'coupon_price_label'.tr(),
                style: AppText.regular14
                    .copyWith(color: context.colors.textSecondary),
              ),
              4.kh,
              Text(
                price.toRawUzsPrice(),
                style: AppText.bold16
                    .copyWith(color: context.colors.textPrimary),
              ),
            ],
          ),
          24.kw,
          Expanded(
            child: GestureDetector(
              onTap: isLoading ? null : onBuy,
              child: Container(
                height: 50.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: AppGradients.brand,
                  borderRadius: BorderRadius.circular(44.r),
                ),
                child: isLoading
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            context.colors.onPrimary,
                          ),
                        ),
                      )
                    : Text(
                        'coupon_buy_btn'.tr(),
                        style: AppText.medium16
                            .copyWith(color: context.colors.onPrimary),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Loading / empty states ──────────────────────────────────────────────────

class _CouponsShimmer extends StatelessWidget {
  const _CouponsShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Shimmer.fromColors(
        baseColor: context.colors.control,
        highlightColor: context.colors.surface,
        child: Container(
          height: _kCouponCardHeight.h,
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }
}

class _EmptyPlans extends StatelessWidget {
  const _EmptyPlans();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
      child: Column(
        children: [
          Assets.icons.coupons.icCoupon.svg(width: 40.w, height: 40.w),
          16.kh,
          Text(
            'no_plans_yet'.tr(),
            textAlign: TextAlign.center,
            style:
                AppText.semibold16.copyWith(color: context.colors.textPrimary),
          ),
          8.kh,
          Text(
            'no_plans_hint'.tr(),
            textAlign: TextAlign.center,
            style: AppText.regular13
                .copyWith(color: context.colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

String _fmtPercent(double v) => v.toStringAsFixed(v % 1 == 0 ? 0 : 1);
