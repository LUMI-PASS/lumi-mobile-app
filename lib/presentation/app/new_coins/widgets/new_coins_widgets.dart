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
/// A brand-gradient hero: the one number that can be spent, large, then the
/// deadline that matters most — the soonest one. The lots behind that number
/// are listed underneath only when there is more than one, because a single
/// lot says nothing the hero has not already said.
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
    final onHero = c.onPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: AppGradients.brand,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'new_coins_balance_label'.tr(),
                      style: AppText.medium14
                          .copyWith(color: onHero.withValues(alpha: 0.85)),
                    ),
                  ),
                  _HeroChip(
                    label: 'new_coins_history'.tr(),
                    onTap: onHistory,
                    trailing: Icons.chevron_right_rounded,
                  ),
                ],
              ),
              10.kh,
              CoinAmount(
                amount: balance.balance,
                style: AppText.phone32,
                color: onHero,
              ),
              if (expiry != null && balance.nearestExpiryCoins > 0) ...[
                14.kh,
                _HeroChip(
                  leading: Icons.schedule_rounded,
                  label: 'new_coins_expire_on'.tr(args: [
                    balance.nearestExpiryCoins.toGrouped(),
                    expiry.toRussianShortFormat(context),
                  ]),
                ),
              ],
            ],
          ),
        ),
        if (balance.lots.length > 1) ...[
          12.kh,
          FrostedCard(
            padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 14.h),
            borderRadius: BorderRadius.circular(20.r),
            child: Column(
              children: [
                for (final lot in balance.lots) ...[
                  10.kh,
                  _LotRow(lot: lot),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// A translucent pill on the gradient hero — the history link and the expiry
/// line share it so the hero has one kind of secondary element, not two.
class _HeroChip extends StatelessWidget {
  const _HeroChip({
    required this.label,
    this.onTap,
    this.leading,
    this.trailing,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? leading;
  final IconData? trailing;

  @override
  Widget build(BuildContext context) {
    final onHero = context.colors.onPrimary;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: onHero.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(40.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              Icon(leading, size: 14.w, color: onHero),
              5.kw,
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.medium12.copyWith(color: onHero),
              ),
            ),
            if (trailing != null) Icon(trailing, size: 16.w, color: onHero),
          ],
        ),
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

/// "+N Lumi Coin with your first pack" — the gift, said once above the shelf
/// instead of as a badge repeated on every tile.
class NewCoinsBonusBanner extends StatelessWidget {
  const NewCoinsBonusBanner({super.key, required this.coins});

  final int coins;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Icon(Icons.card_giftcard_rounded, size: 20.w, color: AppColors.green),
          10.kw,
          Expanded(
            child: Text(
              'new_coins_first_pack_banner'.tr(args: [coins.toGrouped()]),
              style: AppText.medium14.copyWith(color: AppColors.green),
            ),
          ),
        ],
      ),
    );
  }
}

/// One pack on the shelf, as a tile to pick: how many coins, what it costs,
/// how long it lasts and what a coin works out at.
///
/// Picking is all a tile does — the single Buy button under the shelf pays
/// for whichever one is selected, so four packs are four choices rather than
/// four competing buttons. [savingPercent] is how much cheaper a coin is here
/// than in the dearest pack beside it; 0 hides the badge.
class NewCoinPackTile extends StatelessWidget {
  const NewCoinPackTile({
    super.key,
    required this.pack,
    required this.selected,
    required this.onTap,
    this.savingPercent = 0,
  });

  final NewCoinPack pack;
  final bool selected;
  final VoidCallback? onTap;
  final int savingPercent;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final perCoin = pack.pricePerCoin;

    return FrostedCard(
      onTap: onTap,
      padding: EdgeInsets.all(14.w),
      borderRadius: BorderRadius.circular(20.r),
      borderColor: selected ? AppColors.brandPurple : null,
      borderWidth: selected ? 2 : 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: CoinAmount(
                    amount: pack.coins,
                    style: AppText.semibold24,
                    color: c.textPrimary,
                  ),
                ),
              ),
              if (savingPercent > 0) ...[
                6.kw,
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(40.r),
                  ),
                  child: Text(
                    'new_coins_save_badge'.tr(args: ['$savingPercent']),
                    style: AppText.semibold12.copyWith(color: AppColors.green),
                  ),
                ),
              ],
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              pack.price.toRawUzsPrice(),
              style: AppText.semibold16.copyWith(color: c.textPrimary),
            ),
          ),
          4.kh,
          Text(
            [
              if (pack.validDays > 0)
                'new_coins_days'.tr(args: ['${pack.validDays}']),
              if (perCoin != null && perCoin > 0)
                'new_coins_per_coin'.tr(args: [perCoin.toGrouped()]),
            ].join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.regular12.copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Loose coins: a stepper, and the sum it comes to at the unit price.
///
/// For the one or two a booking is short. They never expire, which is why they
/// cost more per coin than a pack — and why they are sold only on top of a
/// live main pack ([lockedNote] says so when there is none).
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
