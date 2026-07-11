import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/data/api_model/order/saved_card.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';

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

// Decorative gradients cycled per saved card. These are the card artwork itself
// (white text sits on them), so they read the same in light and dark.
const List<List<Color>> _kCardGradients = [
  [Color(0xFFA652C7), Color(0xFFFF7093)],
  [Color(0xFF4F46E5), Color(0xFF22D3EE)],
  [Color(0xFF0F172A), Color(0xFF334155)],
  [Color(0xFF0EA5E9), Color(0xFF6366F1)],
];

class _PaymentCardsPageState extends State<PaymentCardsPage> {
  int _currentCardIndex = 0;
  bool _loading = true;
  String? _error;
  List<SavedCard> _cards = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cards = await getIt<OrdersApi>().getSavedCards();
      if (!mounted) return;
      setState(() {
        _cards = cards;
        _loading = false;
        if (_currentCardIndex >= cards.length) _currentCardIndex = 0;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'card_load_error'.tr();
      });
    }
  }

  Future<void> _addCard() async {
    final added = await context.router.push(const AddNewCardRoute());
    if (added == true) _load();
  }

  Future<void> _deleteCard(SavedCard card) async {
    final c = context.colors;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        title: Text('card_delete_title'.tr(),
            style: TextStyle(color: c.textPrimary)),
        content: Text('card_delete_confirm'.tr(args: [card.label]),
            style: TextStyle(color: c.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('cancel'.tr(), style: TextStyle(color: c.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('card_delete_action'.tr(),
                style: TextStyle(color: c.error)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await getIt<OrdersApi>().deleteSavedCard(card.cardId);
      await _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('card_delete_error'.tr())),
        );
      }
    }
  }

  _CardItem _asItem(SavedCard c, int index) => _CardItem(
        brand: c.vendor ?? 'Card',
        last4: c.last4,
        holder: (c.owner?.isNotEmpty ?? false)
            ? c.owner!.toUpperCase()
            : 'LUMI USER',
        expiry: c.expiryDisplay.isEmpty ? '••/••' : c.expiryDisplay,
        gradient: _kCardGradients[index % _kCardGradients.length],
      );

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: BaseAppBar(title: 'card_choose_title'.tr()),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 4.h),
              child: Text(
                'card_your_cards'.tr(),
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w800,
                  color: c.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                'card_swipe_hint'.tr(),
                style: TextStyle(
                  fontSize: 13.sp,
                  color: c.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            28.kh,
            Expanded(child: _cardsArea(c)),
            22.kh,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: GestureDetector(
                onTap: _addCard,
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(
                      color: c.primary.withValues(alpha: 0.4),
                      width: 1,
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
                            colors: [c.primary, const Color(0xFFFF7093)],
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
                              'card_add_new'.tr(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: c.textPrimary,
                              ),
                            ),
                            2.kh,
                            Text(
                              'card_add_new_sub'.tr(),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: c.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 14.sp, color: c.primary),
                    ],
                  ),
                ),
              ),
            ),
            20.kh,
          ],
        ),
      ),
    );
  }

  Widget _cardsArea(AppColorScheme c) {
    if (_loading) {
      return Center(child: CircularProgressIndicator(color: c.primary));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!,
                style: TextStyle(fontSize: 13.sp, color: c.textSecondary)),
            8.kh,
            TextButton(
              onPressed: _load,
              child: Text('card_retry'.tr(),
                  style: TextStyle(color: c.primary)),
            ),
          ],
        ),
      );
    }
    if (_cards.isEmpty) {
      return Center(
        child: Text(
          'card_none'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.sp, color: c.textSecondary),
        ),
      );
    }
    return Column(
      children: [
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
                child: _CreditCard(
                  card: _asItem(_cards[index], index),
                  onDelete: () => _deleteCard(_cards[index]),
                ),
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
                      ? c.primary
                      : c.primary.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CreditCard extends StatelessWidget {
  const _CreditCard({required this.card, this.onDelete});

  final _CardItem card;
  final VoidCallback? onDelete;

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
            color: card.gradient.last.withValues(alpha: 0.35),
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
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
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
              if (onDelete != null) ...[
                8.kw,
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onDelete,
                  child: Icon(Icons.delete_outline_rounded,
                      size: 20.sp, color: Colors.white),
                ),
              ],
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
                        color: Colors.white.withValues(alpha: 0.75),
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
                      color: Colors.white.withValues(alpha: 0.75),
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
