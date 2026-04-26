import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';

@RoutePage()
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController _couponCtrl = TextEditingController();
  bool _couponApplied = false;

  static const double _subtotal = 58.96;
  static const double _delivery = 3.59;
  static const double _couponDiscount = 5.00;

  double get _total => _subtotal + _delivery - (_couponApplied ? _couponDiscount : 0);

  @override
  void dispose() {
    _couponCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FC),
      appBar: const BaseAppBar(title: 'Checkout'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeroCard(total: _total),
                    22.kh,
                    Text(
                      'Apply coupon',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    10.kh,
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(
                                  color: Colors.grey.shade200),
                            ),
                            child: TextField(
                              controller: _couponCtrl,
                              decoration: InputDecoration(
                                hintText: 'Enter promo code',
                                prefixIcon: Padding(
                                  padding: EdgeInsets.all(12.w),
                                  child: Assets.icons.coupon.svg(
                                      width: 16.w, height: 16.w),
                                ),
                                hintStyle: TextStyle(
                                  fontSize: 13.sp,
                                  color: const Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w500,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 14.h, horizontal: 0),
                              ),
                            ),
                          ),
                        ),
                        10.kw,
                        GestureDetector(
                          onTap: () => setState(() =>
                              _couponApplied = _couponCtrl.text.isNotEmpty),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20.w, vertical: 14.h),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14.r),
                              gradient: LinearGradient(
                                colors: [primary, const Color(0xFFFF7093)],
                              ),
                            ),
                            child: Text(
                              'Apply',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_couponApplied) ...[
                      10.kh,
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                              color: const Color(0xFFA7F3D0)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_rounded,
                                size: 16.sp,
                                color: const Color(0xFF059669)),
                            8.kw,
                            Expanded(
                              child: Text(
                                'Coupon applied · −\$${_couponDiscount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF047857),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    24.kh,
                    Container(
                      padding: EdgeInsets.all(18.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18.r),
                        border:
                            Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _SummaryRow(
                              label: 'Subtotal',
                              value:
                                  '\$${_subtotal.toStringAsFixed(2)}'),
                          12.kh,
                          _SummaryRow(
                              label: 'Delivery',
                              value:
                                  '\$${_delivery.toStringAsFixed(2)}'),
                          if (_couponApplied) ...[
                            12.kh,
                            _SummaryRow(
                              label: 'Coupon',
                              value:
                                  '−\$${_couponDiscount.toStringAsFixed(2)}',
                              valueColor: const Color(0xFF059669),
                            ),
                          ],
                          16.kh,
                          Divider(
                              color: Colors.grey.shade200, height: 1),
                          16.kh,
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              Text(
                                '\$${_total.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w900,
                                  color: primary,
                                  letterSpacing: -0.4,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 15.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18.r),
                    gradient: LinearGradient(
                      colors: [primary, const Color(0xFFFF7093)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_rounded,
                          size: 16.sp, color: Colors.white),
                      8.kw,
                      Text(
                        'Pay \$${_total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, const Color(0xFFFF7093)],
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.25),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.shopping_bag_rounded,
                    color: Colors.white, size: 18.sp),
              ),
              10.kw,
              Text(
                'Order summary',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          18.kh,
          Text(
            'Amount due',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          6.kh,
          Text(
            '\$${total.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            color: valueColor ?? const Color(0xFF1E293B),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
