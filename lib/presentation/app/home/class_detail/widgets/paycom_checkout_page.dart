import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/data/api_model/order/order_model.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/presentation/app/home/booking_complete/booking_complete_page.dart';
import 'package:lumi_pass/presentation/app/home/plans/premium_success_page.dart';
import 'package:url_launcher/url_launcher.dart';

class PaycomCheckoutPage extends StatefulWidget {
  const PaycomCheckoutPage({
    super.key,
    required this.result,
    this.isSubscription = false,
  });

  final CheckoutResult result;
  final bool isSubscription;

  @override
  State<PaycomCheckoutPage> createState() => _PaycomCheckoutPageState();
}

class _PaycomCheckoutPageState extends State<PaycomCheckoutPage> {
  bool _launching = false;
  bool _launched = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openPaycom());
  }

  Future<void> _finishSuccess() async {
    if (widget.isSubscription) {
      await getIt<Storage>().hasPremium.set(true);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PremiumSuccessPage()),
      );
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const BookingCompletePage()),
    );
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
        setState(() => _error = 'Could not open Paycom checkout.');
      } else {
        setState(() => _launched = true);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _launching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    final isSub = widget.isSubscription;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: Opacity(
              opacity: 0.08,
              child: Assets.icons.background.premiumMisc.svg(
                width: 260.w,
                height: 260.w,
                colorFilter: ColorFilter.mode(primary, BlendMode.srcIn),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16.sp,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        isSub ? 'plans_title'.tr() : 'Payment',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(width: 44.w),
                    ],
                  ),
                  24.kh,
                  _SummaryCard(
                    result: widget.result,
                    isSubscription: isSub,
                  ),
                  20.kh,
                  if (_error != null) ...[
                    Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline_rounded,
                              color: const Color(0xFFB91C1C), size: 18.sp),
                          10.kw,
                          Expanded(
                            child: Text(
                              _error!,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: const Color(0xFFB91C1C),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    12.kh,
                  ],
                  const Spacer(),
                  _PrimaryGradientButton(
                    label: _launched
                        ? 'Open Paycom again'
                        : 'Open Paycom',
                    loading: _launching,
                    onTap: _launching ? null : _openPaycom,
                  ),
                  12.kh,
                  _SecondaryButton(
                    label: isSub
                        ? 'I completed the payment'
                        : 'I completed the payment',
                    onTap: _finishSuccess,
                  ),
                  14.kh,
                  Text(
                    _launched
                        ? 'Once you finish in Paycom, tap “I completed the payment”. Your ${isSub ? 'subscription' : 'booking'} will activate after confirmation.'
                        : 'You will be redirected to Paycom to complete payment.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
    final primary = context.colors.primary;
    final orderTail = result.orderId.length >= 6
        ? result.orderId.substring(result.orderId.length - 6)
        : result.orderId;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, const Color(0xFFFF7093)],
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.25),
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
                padding: EdgeInsets.symmetric(
                    horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(20.r),
                  border:
                      Border.all(color: Colors.white.withOpacity(0.35)),
                ),
                child: Text(
                  isSubscription
                      ? 'SUBSCRIPTION'
                      : 'ORDER #$orderTail',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
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
            'Total amount',
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
              'Tickets · ${result.ticketDate}',
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

class _PrimaryGradientButton extends StatelessWidget {
  const _PrimaryGradientButton({
    required this.label,
    required this.loading,
    required this.onTap,
  });

  final String label;
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            colors: [primary, const Color(0xFFFF7093)],
          ),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: loading
              ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }
}
