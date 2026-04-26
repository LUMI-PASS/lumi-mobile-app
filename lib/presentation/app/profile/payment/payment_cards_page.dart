import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';

@RoutePage()
class PaymentCardsPage extends StatefulWidget {
  const PaymentCardsPage({super.key});

  @override
  State<PaymentCardsPage> createState() => _PaymentCardsPageState();
}

class _CardItem {
  final String brand;
  final String last4;
  final String holder;
  final String expiry;
  final List<Color> gradient;

  const _CardItem({
    required this.brand,
    required this.last4,
    required this.holder,
    required this.expiry,
    required this.gradient,
  });
}

class _PaymentCardsPageState extends State<PaymentCardsPage> {
  int _currentCardIndex = 0;

  final List<_CardItem> _cards = const [
    _CardItem(
      brand: 'Mastercard',
      last4: '0411',
      holder: 'LUMI USER',
      expiry: '10/26',
      gradient: [Color(0xFFA652C7), Color(0xFFFF7093)],
    ),
    _CardItem(
      brand: 'Visa',
      last4: '8823',
      holder: 'LUMI USER',
      expiry: '05/27',
      gradient: [Color(0xFF4F46E5), Color(0xFF22D3EE)],
    ),
    _CardItem(
      brand: 'Uzcard',
      last4: '1207',
      holder: 'LUMI USER',
      expiry: '09/28',
      gradient: [Color(0xFF0F172A), Color(0xFF334155)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FC),
      appBar: const BaseAppBar(title: 'Choose Card'),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 4.h),
              child: Text(
                'Your cards',
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
                'Swipe through your saved cards or add a new one.',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            28.kh,
            SizedBox(
              height: 210.h,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.86),
                onPageChanged: (i) => setState(() => _currentCardIndex = i),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  return AnimatedPadding(
                    duration: const Duration(milliseconds: 220),
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: _currentCardIndex == index ? 0 : 14.h,
                    ),
                    child: _CreditCard(card: _cards[index]),
                  );
                },
              ),
            ),
            16.kh,
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _cards.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    width: _currentCardIndex == i ? 22.w : 6.w,
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: _currentCardIndex == i
                          ? primary
                          : primary.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                ),
              ),
            ),
            22.kh,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: GestureDetector(
                onTap: () => context.router.push(const AddNewCardRoute()),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(
                      color: primary.withOpacity(0.4),
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44.w,
                        height: 44.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [primary, const Color(0xFFFF7093)],
                          ),
                        ),
                        child: Icon(Icons.add_rounded,
                            size: 22.sp, color: Colors.white),
                      ),
                      14.kw,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add a new card',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            2.kh,
                            Text(
                              'Securely save a card for fast payments.',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 14.sp, color: primary),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
              child: GestureDetector(
                onTap: () => context.router.push(const CheckoutRoute()),
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
                      'Use this card',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
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

class _CreditCard extends StatelessWidget {
  const _CreditCard({required this.card});

  final _CardItem card;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: card.gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: card.gradient.last.withOpacity(0.35),
            blurRadius: 22,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Assets.icons.card.svg(width: 36.w, height: 26.h),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  card.brand.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '•••• •••• •••• ${card.last4}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          18.kh,
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CARDHOLDER',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                    4.kh,
                    Text(
                      card.holder,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EXPIRES',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                  4.kh,
                  Text(
                    card.expiry,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              14.kw,
              Assets.icons.mastercard.svg(width: 36.w, height: 36.w),
            ],
          ),
        ],
      ),
    );
  }
}
