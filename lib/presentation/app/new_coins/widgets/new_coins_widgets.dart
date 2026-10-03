import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/coin_amount.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';
import 'package:lumi_pass/data/api_model/new_coins/new_coin_models.dart';
import 'package:lumi_pass/presentation/app/shop/widgets/shop_quantity_stepper.dart';

/// The balance, and the clock on it.
///
/// Leads with the one number that can be spent, then the deadline that
/// matters most — the soonest one — and only then the lots behind it. Coins
/// expire batch by batch, so "N coins expire on DATE" is the line a parent
/// needs before the list that explains it.
class NewCoinsBalanceCard extends StatelessWidget {
  const NewCoinsBalanceCard({
    super.key,
    required this.balance,
    required this.onHistory,
  });

  final NewCoinBalance balance;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final expiry = balance.nearestExpiry;

    return FrostedCard(
      padding: EdgeInsets.all(16.w),
      borderRadius: BorderRadius.circular(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'new_coins_balance_label'.tr(),
                      style: AppText.regular13.copyWith(color: c.textSecondary),
                    ),
                    6.kh,
                    CoinAmount(
                      amount: balance.balance,
                      style: AppText.heading20,
                      color: c.textPrimary,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onHistory,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'new_coins_history'.tr(),
                      style: AppText.medium14.copyWith(color: c.textSecondary),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20.w,
                      color: c.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (expiry != null && balance.nearestExpiryCoins > 0) ...[
            10.kh,
            Text(
              'new_coins_expire_on'.tr(args: [
                balance.nearestExpiryCoins.toGrouped(),
                expiry.toRussianShortFormat(context),
              ]),
              style: AppText.regular13.copyWith(color: AppColors.warning),
            ),
          ],
          if (balance.lots.isNotEmpty) ...[
            12.kh,
            Divider(height: 1, color: c.border),
            for (final lot in balance.lots) ...[
              10.kh,
              _LotRow(lot: lot),
            ],
          ],
        ],
      ),
    );
  }
}

class _LotRow extends StatelessWidget {
  const _LotRow({required this.lot});

  final NewCoinLot lot;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final expiresAt = lot.expiresAt;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lot.kind.labelKey.tr(),
                style: AppText.medium14.copyWith(color: c.textPrimary),
              ),
              2.kh,
              Text(
                // Loose coins carry no deadline, and saying so is the point of
                // buying them.
                expiresAt == null
                    ? 'new_coins_never_expire'.tr()
                    : 'new_coins_valid_until'
                        .tr(args: [expiresAt.toRussianShortFormat(context)]),
                style: AppText.regular12.copyWith(color: c.textSecondary),
              ),
            ],
          ),
        ),
        CoinAmount(
          amount: lot.coinsLeft,
          style: AppText.semibold14,
          color: c.textPrimary,
        ),
      ],
    );
  }
}

/// One pack on the shelf: what it holds, how long it lasts, what a coin works
/// out at, and the button that buys it.
///
/// [lockedNote] greys the card out and explains why under the button — used
/// for extra packs offered to someone without a live monthly pack. The card
/// still renders, so the buyer can see what the monthly pack unlocks.
class NewCoinPackCard extends StatelessWidget {
  const NewCoinPackCard({
    super.key,
    required this.pack,
    required this.onBuy,
    this.bonus = 0,
    this.isLoading = false,
    this.enabled = true,
    this.lockedNote,
  });

  final NewCoinPack pack;
  final VoidCallback onBuy;

  /// Coins added on the buyer's first monthly pack. 0 hides the badge.
  final int bonus;
  final bool isLoading;

  /// False while another purchase is in flight.
  final bool enabled;
  final String? lockedNote;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final locked = lockedNote != null;
    final perCoin = pack.pricePerCoin;
    final facts = [
      if (pack.validDays > 0)
        'new_coins_valid_days'.tr(args: ['${pack.validDays}']),
      if (perCoin != null && perCoin > 0)
        'new_coins_per_coin'.tr(args: [perCoin.toRawUzsPrice()]),
    ];

    return FrostedCard(
      padding: EdgeInsets.all(16.w),
      borderRadius: BorderRadius.circular(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: locked ? 0.55 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        pack.name,
                        style:
                            AppText.semibold16.copyWith(color: c.textPrimary),
                      ),
                    ),
                    if (bonus > 0) _BonusBadge(coins: bonus),
                  ],
                ),
                8.kh,
                CoinAmount(
                  amount: pack.coins,
                  style: AppText.heading20,
                  color: c.textPrimary,
                ),
                if (facts.isNotEmpty) ...[
                  6.kh,
                  Text(
                    facts.join(' · '),
                    style: AppText.regular13.copyWith(color: c.textSecondary),
                  ),
                ],
                if ((pack.description ?? '').isNotEmpty) ...[
                  6.kh,
                  Text(
                    pack.description!,
                    style: AppText.regular13.copyWith(color: c.textSecondary),
                  ),
                ],
                14.kh,
                NewCoinsBuyButton(
                  label: 'new_coins_buy_for'
                      .tr(args: [pack.price.toRawUzsPrice()]),
                  onTap: onBuy,
                  isLoading: isLoading,
                  enabled: enabled && !locked,
                ),
              ],
            ),
          ),
          if (locked) ...[
            8.kh,
            Text(
              lockedNote!,
              style: AppText.regular12.copyWith(color: c.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

/// "+N bonus" — the first-pack gift, on the packs that earn it.
class _BonusBadge extends StatelessWidget {
  const _BonusBadge({required this.coins});

  final int coins;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(40.r),
      ),
      child: Text(
        'new_coins_bonus_badge'.tr(args: [coins.toGrouped()]),
        style: AppText.semibold12.copyWith(color: AppColors.green),
      ),
    );
  }
}

/// Loose coins: a stepper, and the sum it comes to at the unit price.
///
/// For the one or two a booking is short. They never expire, which is why they
/// cost more per coin than a pack — and why they are sold only on top of a
/// live monthly pack ([lockedNote] says so when there is none).
class NewCoinSingleCard extends StatelessWidget {
  const NewCoinSingleCard({
    super.key,
    required this.unitPrice,
    required this.quantity,
    required this.onChanged,
    required this.onBuy,
    this.isLoading = false,
    this.enabled = true,
    this.lockedNote,
  });

  /// The server refuses more than this in one purchase.
  static const maxQuantity = 1000;

  final num unitPrice;
  final int quantity;
  final ValueChanged<int> onChanged;
  final VoidCallback onBuy;
  final bool isLoading;
  final bool enabled;
  final String? lockedNote;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final locked = lockedNote != null;
    final live = enabled && !locked && !isLoading;

    return FrostedCard(
      padding: EdgeInsets.all(16.w),
      borderRadius: BorderRadius.circular(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: locked ? 0.55 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'new_coins_single_title'.tr(),
                            style: AppText.semibold16
                                .copyWith(color: c.textPrimary),
                          ),
                          4.kh,
                          Text(
                            // Unit price × quantity, spelled out: the total on
                            // the button should never be a number the buyer
                            // has to take on trust.
                            '${unitPrice.toRawUzsPrice()} × $quantity',
                            style: AppText.regular13
                                .copyWith(color: c.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    ShopQuantityStepper(
                      count: quantity,
                      onDecrease: live && quantity > 1
                          ? () => onChanged(quantity - 1)
                          : null,
                      onIncrease: live && quantity < maxQuantity
                          ? () => onChanged(quantity + 1)
                          : null,
                    ),
                  ],
                ),
                6.kh,
                Text(
                  'new_coins_single_hint'.tr(),
                  style: AppText.regular13.copyWith(color: c.textSecondary),
                ),
                14.kh,
                NewCoinsBuyButton(
                  label: 'new_coins_buy_for'
                      .tr(args: [(unitPrice * quantity).toRawUzsPrice()]),
                  onTap: onBuy,
                  isLoading: isLoading,
                  enabled: enabled && !locked,
                ),
              ],
            ),
          ),
          if (locked) ...[
            8.kh,
            Text(
              lockedNote!,
              style: AppText.regular12.copyWith(color: c.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

/// The buy action on a pack card — the brand pill `AksiyaBottomBar` uses, at
/// card width.
class NewCoinsBuyButton extends StatelessWidget {
  const NewCoinsBuyButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onTap;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final live = enabled && !isLoading;
    return GestureDetector(
      onTap: live ? onTap : null,
      child: Container(
        height: 46.h,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: enabled ? AppGradients.brand : null,
          color: enabled ? null : c.disabled,
          borderRadius: BorderRadius.circular(44.r),
        ),
        child: isLoading
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(c.onPrimary),
                ),
              )
            : Text(
                label,
                style: AppText.medium16.copyWith(color: c.onPrimary),
              ),
      ),
    );
  }
}
