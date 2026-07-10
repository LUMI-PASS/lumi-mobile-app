import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/auth/gradient_button.dart';
import 'package:lumi_pass/data/api_model/order/order_model.dart';
import 'package:lumi_pass/data/service/analytics_service.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:lumi_pass/presentation/app/home/booking_complete/booking_complete_page.dart';
import 'package:lumi_pass/presentation/app/home/plans/coupon_success_page.dart';
import 'package:lumi_pass/presentation/app/home/plans/premium_success_page.dart';
import 'package:url_launcher/url_launcher.dart';

class PaycomCheckoutPage extends StatefulWidget {
  const PaycomCheckoutPage({
    super.key,
    required this.result,
    this.isSubscription = false,
    this.planDiscountPercentage,
    this.provider,
  });

  final CheckoutResult result;
  final bool isSubscription;
  final int? planDiscountPercentage;

  /// Selected payment rail: 'payme' | 'click' | 'uzum' | 'paylov' | null.
  final String? provider;

  /// Human display name for the gateway the buyer is being sent to.
  String get providerName {
    switch ((provider ?? result.paymentProvider ?? '').toLowerCase()) {
      case 'uzum':
        return 'Uzum';
      case 'click':
        return 'Click';
      case 'paylov':
        return 'Paylov';
      case 'payme':
      default:
        return 'Payme';
    }
  }

  @override
  State<PaycomCheckoutPage> createState() => _PaycomCheckoutPageState();
}

class _PaycomCheckoutPageState extends State<PaycomCheckoutPage>
    with WidgetsBindingObserver {
  bool _launching = false;
  bool _launched = false;
  bool _navigated = false;
  String? _error;
  Timer? _pollTimer;

  // Polling cadence after the user returns from Paycom. We tick fast initially
  // so the success screen feels instantaneous, then back off — Paycom's
  // PerformTransaction webhook usually arrives within a couple of seconds.
  static const _pollInterval = Duration(seconds: 2);

  /// Common funnel params attached to every checkout/payment event so the
  /// booking and subscription flows can be segmented in one funnel.
  Map<String, Object?> get _funnelParams => {
        'checkout_type': widget.isSubscription ? 'subscription' : 'booking',
        'order_id': widget.result.orderId,
        'amount': widget.result.totalAmount,
        'currency': widget.result.currency,
      };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getIt<AnalyticsService>()
        .logEvent(AnalyticsEvent.checkoutPageOpened, params: _funnelParams);
    WidgetsBinding.instance.addPostFrameCallback((_) => _openPaycom());
  }

  @override
  void dispose() {
    // The page leaves the tree without a confirmed payment → user backed out.
    // (_navigated is only set once we route to a success screen.)
    if (!_navigated) {
      getIt<AnalyticsService>().logEvent(
        AnalyticsEvent.paymentAbandoned,
        params: {..._funnelParams, 'reached_payme': _launched},
      );
    }
    _pollTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Paycom opens externally; the only way back is the OS resuming this app.
    // Treat resume as the trigger to poll the order status and auto-advance.
    if (state == AppLifecycleState.resumed && _launched) {
      _checkPaymentStatus();
      _startPolling();
    } else if (state == AppLifecycleState.paused) {
      _pollTimer?.cancel();
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _checkPaymentStatus());
  }

  Future<void> _checkPaymentStatus() async {
    if (_navigated || !mounted) return;
    final orderId = widget.result.orderId;
    if (orderId.isEmpty) return;
    try {
      final detail = await getIt<OrdersApi>().getOrderDetail(orderId);
      if (detail.order.isPaid) {
        await _finishSuccess();
      }
    } catch (_) {
      // Network hiccups during polling are non-fatal — the next tick retries.
    }
  }

  Future<void> _finishSuccess() async {
    if (_navigated) return;
    _navigated = true;
    _pollTimer?.cancel();
    getIt<AnalyticsService>()
        .logEvent(AnalyticsEvent.paymentSucceeded, params: _funnelParams);
    if (widget.isSubscription) {
      await getIt<Storage>().hasPremium.set(true);
      if (widget.planDiscountPercentage != null) {
        await getIt<Storage>().planDiscountPercentage.set(widget.planDiscountPercentage!);
      }
      if (!mounted) return;
      // If the plan carries a coupon discount, show the coupon success screen
      // (which also fetches and displays the eligible activity count).
      // For plans without a discount, fall back to the generic premium success.
      if (widget.planDiscountPercentage != null && widget.planDiscountPercentage! > 0) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => CouponSuccessPage(
              discountPercentage: widget.planDiscountPercentage!,
            ),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PremiumSuccessPage()),
        );
      }
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BookingCompletePage(
          status: BookingResultStatus.paid,
          result: widget.result,
          lines: _resultLines(widget.result),
        ),
      ),
    );
  }

  /// Order-details rows derived from the checkout result (the external redirect
  /// flow has no per-tier breakdown, so it shows date + ticket count).
  List<OrderLine> _resultLines(CheckoutResult r) {
    const dir = 'assets/icons/detail';
    final out = <OrderLine>[];
    if (r.ticketDate.isNotEmpty) {
      out.add(OrderLine(
        label: 'book_date_time'.tr(),
        value: r.ticketDate,
        iconAsset: '$dir/iconsax-ai-calendar.svg',
      ));
    }
    if (r.ticketNumbers.isNotEmpty) {
      out.add(OrderLine(
        label: 'pay_tickets'.tr(),
        value: '${r.ticketNumbers.length}',
        iconAsset: '$dir/iconsax-ai-users.svg',
      ));
    }
    if (r.discountAmount > 0) {
      out.add(OrderLine(
        label: 'promo_discount'.tr(),
        value: '−${r.discountAmount.toRawUzsPrice()}',
        iconAsset: '$dir/iconsax-ticket-discount.svg',
        negative: true,
      ));
    }
    return out;
  }

  Future<void> _openPaycom() async {
    if (_launching) return;
    setState(() {
      _launching = true;
      _error = null;
    });
    try {
      final uri = Uri.parse(widget.result.checkoutUrl);
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) {
        setState(() => _error = 'pay_open_failed'.tr(args: [widget.providerName]));
        getIt<AnalyticsService>().logEvent(
          AnalyticsEvent.paymeOpenFailed,
          params: {..._funnelParams, 'reason': 'launch_returned_false'},
        );
      } else {
        setState(() => _launched = true);
        getIt<AnalyticsService>()
            .logEvent(AnalyticsEvent.paymeRedirect, params: _funnelParams);
        _startPolling();
      }
    } catch (e) {
      setState(() => _error = e.toString());
      getIt<AnalyticsService>().logEvent(
        AnalyticsEvent.paymeOpenFailed,
        params: {..._funnelParams, 'reason': 'exception'},
      );
    } finally {
      if (mounted) setState(() => _launching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final isSub = widget.isSubscription;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: c.overlayStyle,
      child: Scaffold(
        backgroundColor: c.bg,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Container(
                        width: 40.w,
                        height: 40.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: c.control,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: c.controlBorder),
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            size: 16.sp, color: c.textPrimary),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        isSub ? 'plans_title'.tr() : 'payment_title'.tr(),
                        textAlign: TextAlign.center,
                        style: AppText.bold18.copyWith(color: c.textPrimary),
                      ),
                    ),
                    SizedBox(width: 40.w),
                  ],
                ),
                24.kh,
                _SummaryCard(result: widget.result, isSubscription: isSub),
                if (_error != null) ...[
                  16.kh,
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline_rounded,
                            color: AppColors.error, size: 18.sp),
                        10.kw,
                        Expanded(
                          child: Text(_error!,
                              style: AppText.regular12
                                  .copyWith(color: AppColors.error)),
                        ),
                      ],
                    ),
                  ),
                ],
                const Spacer(),
                if (_launched) ...[
                  _StatusIndicator(
                    message: isSub
                        ? 'pay_wait_subscription'.tr()
                        : 'pay_wait_booking'.tr(),
                  ),
                  16.kh,
                ],
                GradientButton(
                  text: _launched
                      ? 'pay_open_gateway_again'.tr(args: [widget.providerName])
                      : 'pay_open_gateway'.tr(args: [widget.providerName]),
                  loading: _launching,
                  onPressed: _openPaycom,
                ),
                if (!_launched) ...[
                  12.kh,
                  Text(
                    'pay_redirect_note'.tr(args: [widget.providerName]),
                    textAlign: TextAlign.center,
                    style: AppText.regular12.copyWith(color: c.textSecondary),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.result, required this.isSubscription});

  final CheckoutResult result;
  final bool isSubscription;

  @override
  Widget build(BuildContext context) {
    final orderTail = result.orderId.length >= 6
        ? result.orderId.substring(result.orderId.length - 6)
        : result.orderId;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: AppGradients.brand,
        boxShadow: [
          BoxShadow(
            color: AppColors.brandPurple.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.white.withOpacity(0.35)),
                ),
                child: Text(
                  isSubscription
                      ? 'plans_title'.tr().toUpperCase()
                      : '${'order_details'.tr()} #$orderTail',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                isSubscription
                    ? Icons.workspace_premium_rounded
                    : Icons.confirmation_number_rounded,
                color: Colors.white,
                size: 22.sp,
              ),
            ],
          ),
          18.kh,
          Text(
            'pay_total_amount'.tr(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          6.kh,
          Text(
            result.totalAmount.toRawUzsPrice(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 28.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          if (!isSubscription && result.ticketNumbers.isNotEmpty) ...[
            16.kh,
            Divider(color: Colors.white.withOpacity(0.25), height: 1),
            14.kh,
            Text(
              '${'pay_tickets'.tr()} · ${result.ticketDate}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            8.kh,
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: result.ticketNumbers
                  .map(
                    (n) => Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '#$n',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: c.controlBorder),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16.w,
            height: 16.w,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPurple),
            ),
          ),
          12.kw,
          Expanded(
            child: Text(
              message,
              style: AppText.regular12.copyWith(color: c.textSecondary, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
