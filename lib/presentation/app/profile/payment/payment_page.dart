import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';

@RoutePage()
class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentMethod {
  final String title;
  final String subtitle;
  final Widget icon;
  final Color tint;

  const _PaymentMethod({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tint,
  });
}

class _PaymentPageState extends State<PaymentPage> {
  late final List<_PaymentMethod> methods;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    methods = [
      _PaymentMethod(
        title: 'Credit Card',
        subtitle: 'Visa, Mastercard, UnionPay',
        icon: Assets.icons.mastercard.svg(width: 28.w, height: 28.w),
        tint: const Color(0xFFEFF6FF),
      ),
      _PaymentMethod(
        title: 'PayPal',
        subtitle: 'Pay securely with PayPal',
        icon: Assets.icons.paypal.svg(width: 28.w, height: 28.w),
        tint: const Color(0xFFEFF4FF),
      ),
      _PaymentMethod(
        title: 'Google Pay',
        subtitle: 'Quick tap-to-pay',
        icon: Assets.icons.google.svg(width: 28.w, height: 28.w),
        tint: const Color(0xFFF6FBEF),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FC),
      appBar: const BaseAppBar(title: 'Payment Method'),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 4.h),
              child: Text(
                'Pay with',
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2E3D5D),
                  letterSpacing: -0.4,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                'Choose how you want to check out.',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            18.kh,
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: methods.length,
                separatorBuilder: (_, __) => 12.kh,
                itemBuilder: (context, index) {
                  final method = methods[index];
                  final isSelected = index == _selectedIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(
                          color: isSelected
                              ? primary
                              : Colors.grey.shade200,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? primary.withOpacity(0.12)
                                : Colors.black.withOpacity(0.04),
                            blurRadius: isSelected ? 20 : 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48.w,
                            height: 48.w,
                            decoration: BoxDecoration(
                              color: method.tint,
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Center(child: method.icon),
                          ),
                          14.kw,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  method.title,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                2.kh,
                                Text(
                                  method.subtitle,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 22.w,
                            height: 22.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? primary
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? primary
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? Icon(Icons.check_rounded,
                                    size: 14.sp, color: Colors.white)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
              child: _GradientButton(
                label: 'Continue',
                onTap: () =>
                    context.router.push(const PaymentCardsRoute()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    return GestureDetector(
      onTap: onTap,
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
        child: Center(
          child: Text(
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
