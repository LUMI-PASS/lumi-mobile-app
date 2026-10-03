import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/adaptive_card.dart';
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

/// Height of a pack card in the carousel. Fixed so the [PageView] can size
/// itself; the card's content is top-aligned inside it.
const double kNewCoinPackCardHeight = 176;

/// The top of the Lumi Coin screen: the coin, the name on a tilted chip, the
/// first-pack gift on another, and one line saying what coins are for.
///
/// The composition is the coupons screen's hero (`plans_page.dart`) — artwork
/// with two rotated chips hanging off its corners over a soft glow — so the
/// two shops read as the same family.
class NewCoinsHero extends StatelessWidget {
  const NewCoinsHero({super.key, this.bonus = 0});

  /// Coins added to the buyer's first main pack. 0 hides the chip.
  final int bonus;

  @override
  Widget build(BuildContext context) {
    final art = 112.w;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 176.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: art,
                height: art,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Assets.icons.coinLumi.image(
                      width: art,
                      height: art,
                      fit: BoxFit.contain,
                    ),
                    _HeroArtChip(
                      label: 'new_coins_title'.tr(),
                      art: art,
                      centerX: -0.18,
                      centerY: 0.2,
                      angle: -0.385,
                    ),
                    if (bonus > 0)
                      _HeroArtChip(
                        label: 'new_coins_bonus_badge'
                            .tr(args: [bonus.toGrouped()]),
                        art: art,
                        centerX: 1.2,
                        centerY: 0.82,
                        angle: 0.217,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 48.w),
          child: Text(
            'new_coins_hero_subtitle'.tr(),
            textAlign: TextAlign.center,
            style:
                AppText.regular12.copyWith(color: context.colors.textSecondary),
          ),
        ),
        16.kh,
      ],
    );
  }
}

/// A tilted chip pinned to a point on the hero artwork — [centerX]/[centerY]
/// are fractions of the artwork box and mark where the chip's centre lands.
class _HeroArtChip extends StatelessWidget {
  const _HeroArtChip({
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
    final c = context.colors;
    return Positioned(
      left: centerX * art,
      top: centerY * art,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Transform.rotate(
          angle: angle,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: c.border),
            ),
            child: Text(
              label,
              style: AppText.semibold14.copyWith(color: c.textPrimary),
            ),
          ),
        ),
      ),
    );
  }
}

/// One pack, as a card in the carousel: what kind it is, how many coins, and
/// underneath — small — what it costs, how long it lasts and what a coin
/// works out at.
///
/// The card itself has no button. Swiping to it is choosing it, and the buy
/// bar under the carousel pays for whichever card is in front.
class NewCoinPackCard extends StatelessWidget {
  const NewCoinPackCard({
    super.key,
    required this.pack,
    this.isBestOffer = false,
    this.bonus = 0,
    this.savingPercent = 0,
  });

  final NewCoinPack pack;
  final bool isBestOffer;

  /// First-pack gift, shown on main packs. 0 hides it.
  final int bonus;

  /// How much cheaper a coin is here than in the dearest main pack. 0 hides it.
  final int savingPercent;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final perCoin = pack.pricePerCoin;

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
                  pack.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bold18.copyWith(color: c.textPrimary),
                ),
              ),
              if (isBestOffer) ...[8.kw, const _BestOfferBadge()],
            ],
          ),
          14.kh,
          // The headline: how many coins — the thing being compared — big and
          // in the brand colour, with the gift beside it when there is one.
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                pack.coins.toGrouped(),
                style: AppText.phone32.copyWith(
                  fontSize: 40.sp,
                  fontWeight: FontWeight.w900,
                  color: c.primary,
                  height: 1,
                ),
              ),
              8.kw,
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 3.h),
                  child: Text(
                    'new_coins_title'.tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.semibold24.copyWith(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: c.primary,
                    ),
                  ),
                ),
              ),
              if (bonus > 0) ...[
                8.kw,
                Padding(
                  padding: EdgeInsets.only(bottom: 5.h),
                  child: _GreenChip(
                    label: 'new_coins_bonus_badge'.tr(args: ['$bonus']),
                  ),
                ),
              ],
            ],
          ),
          8.kh,
          Text(
            'coupon_valid_days_short'
                .tr(namedArgs: {'days': '${pack.validDays}'}),
            style: AppText.regular12.copyWith(color: c.textMuted),
          ),
          12.kh,
          // Price and the per-coin figure, deliberately small: the buy bar
          // below repeats the price next to the button.
          Row(
            children: [
              Text(
                pack.price.toRawUzsPrice(),
                style: AppText.semibold12.copyWith(color: c.textSecondary),
              ),
              if (perCoin != null && perCoin > 0) ...[
                6.kw,
                Text('·',
                    style: AppText.regular12.copyWith(color: c.textMuted)),
                6.kw,
                Flexible(
                  child: Text(
                    'new_coins_per_coin'.tr(args: [perCoin.toRawUzsPrice()]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.regular12.copyWith(color: c.textMuted),
                  ),
                ),
              ],
              if (savingPercent > 0) ...[
                8.kw,
                _GreenChip(
                  label: 'new_coins_save_badge'.tr(args: ['$savingPercent']),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _GreenChip extends StatelessWidget {
  const _GreenChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(40.r),
      ),
      child: Text(
        label,
        style: AppText.semibold12.copyWith(color: AppColors.green),
      ),
    );
  }
}

/// "BEST OFFER" — the coupons screen's badge, on the pack whose coin is
/// cheapest.
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

/// Which card of the carousel is in front.
class NewCoinsDots extends StatelessWidget {
  const NewCoinsDots({super.key, required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 8.w,
          height: 8.w,
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          decoration: BoxDecoration(
            color: i == active ? c.textPrimary : c.border,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

/// "How it works" — three numbered steps, laid out as on the coupons screen.
class NewCoinsHowItWorks extends StatelessWidget {
  const NewCoinsHowItWorks({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
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
                  text: 'new_coins_step1'.tr(),
                ),
              ),
              8.kw,
              Expanded(
                child: _StepCard(
                  icon: Assets.icons.coupons.icAddInvoice,
                  number: '02',
                  text: 'new_coins_step2'.tr(),
                ),
              ),
            ],
          ),
        ),
        8.kh,
        _StepCard(
          icon: Assets.icons.coupons.icCoupon,
          number: '03',
          text: 'new_coins_step3'.tr(),
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

/// The one action on the screen: the price of the pack in front, and Buy.
class NewCoinsBuyBar extends StatelessWidget {
  const NewCoinsBuyBar({
    super.key,
    required this.price,
    required this.isLoading,
    required this.onBuy,
  });

  final num price;
  final bool isLoading;
  final VoidCallback? onBuy;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      color: c.bottomBar,
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
                'new_coins_price_label'.tr(),
                style: AppText.regular14.copyWith(color: c.textSecondary),
              ),
              4.kh,
              Text(
                price.toRawUzsPrice(),
                style: AppText.bold16.copyWith(color: c.textPrimary),
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
                          valueColor: AlwaysStoppedAnimation(c.onPrimary),
                        ),
                      )
                    : Text(
                        'new_coins_buy_btn'.tr(),
                        style: AppText.medium16.copyWith(color: c.onPrimary),
                      ),
              ),
            ),
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
