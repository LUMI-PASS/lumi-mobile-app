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
  const NewCoinsBalanceCard({super.key, required this.balance});

  final NewCoinBalance balance;

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
              Text(
                'new_coins_balance_label'.tr(),
                style: AppText.medium14
                    .copyWith(color: onHero.withValues(alpha: 0.85)),
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

/// A translucent pill on the gradient hero, carrying the expiry line.
class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.label, required this.leading});

  final String label;
  final IconData leading;

  @override
  Widget build(BuildContext context) {
    final onHero = context.colors.onPrimary;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: onHero.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(40.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(leading, size: 14.w, color: onHero),
          5.kw,
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.medium12.copyWith(color: onHero),
            ),
          ),
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

/// The colours one pack is shown in: a pale tint, the accent and a deep shade.
///
/// Every pack on the shelf gets its own, so swiping between packs repaints the
/// whole screen — the wash behind the coin, the frame of the card and the Buy
/// button all follow the pack in front.
class NewCoinTone {
  const NewCoinTone({
    required this.light,
    required this.accent,
    required this.deep,
    required this.art,
    this.onAccent = AppColors.white,
  });

  final Color light;
  final Color accent;
  final Color deep;

  /// The glass coin rendered in this tone — the artwork at the top of the
  /// pack's page.
  final AssetGenImage art;

  /// Ink for a label sitting on [button].
  final Color onAccent;

  static final _orange = NewCoinTone(
    art: Assets.icons.coinLumiGlassOrange,
    light: AppColors.coinOrangeLight,
    accent: AppColors.coinOrange,
    deep: AppColors.coinOrangeDeep,
  );
  static final _violet = NewCoinTone(
    art: Assets.icons.coinLumiGlassViolet,
    light: AppColors.coinVioletLight,
    accent: AppColors.brandPink,
    deep: AppColors.brandPurple,
  );
  static final _blue = NewCoinTone(
    art: Assets.icons.coinLumiGlassBlue,
    light: AppColors.coinBlueLight,
    accent: AppColors.coinBlue,
    deep: AppColors.coinBlueDeep,
  );
  static final _gold = NewCoinTone(
    art: Assets.icons.coinLumiGlass,
    light: AppColors.coinGoldLight,
    accent: AppColors.coinGold,
    deep: AppColors.coinGoldDeep,
    onAccent: AppColors.ink,
  );
  static final _mint = NewCoinTone(
    art: Assets.icons.coinLumiGlassMint,
    light: AppColors.coinMintLight,
    accent: AppColors.coinMint,
    deep: AppColors.coinMintDeep,
    onAccent: AppColors.ink,
  );

  static final _mainTones = [_orange, _violet, _blue, _gold];

  /// The tone of the main pack at [index] on the shelf.
  static NewCoinTone main(int index) => _mainTones[index % _mainTones.length];

  /// Extra packs share one tone — they are one kind of thing, a top-up.
  static final NewCoinTone extra = _mint;

  /// Left→right fill of the Buy button.
  LinearGradient get button => LinearGradient(
        colors: [Color.lerp(accent, light, 0.4)!, accent],
      );

  /// Top→bottom frame around the "what's in the pack" card.
  LinearGradient get frame => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [light, accent],
      );

  static NewCoinTone lerp(NewCoinTone a, NewCoinTone b, double t) =>
      NewCoinTone(
        light: Color.lerp(a.light, b.light, t)!,
        accent: Color.lerp(a.accent, b.accent, t)!,
        deep: Color.lerp(a.deep, b.deep, t)!,
        art: t < 0.5 ? a.art : b.art,
        onAccent: Color.lerp(a.onAccent, b.onAccent, t)!,
      );
}

/// The wash behind the screen: the pack's colour at the top edge, gone by the
/// middle.
class NewCoinsBackdrop extends StatelessWidget {
  const NewCoinsBackdrop({super.key, required this.tone});

  final NewCoinTone tone;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0, 0.14, 0.34, 0.56],
              colors: [
                tone.light,
                tone.accent.withValues(alpha: 0.88),
                tone.accent.withValues(alpha: 0.3),
                tone.accent.withValues(alpha: 0),
              ],
            ),
          ),
        ),
        // A pale bloom off the top edge, so the colour reads as lit rather
        // than as a flat band.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.35, -1.05),
              radius: 0.75,
              colors: [
                AppColors.white.withValues(alpha: 0.38),
                AppColors.white.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// The coin, floating over a glow of the pack's colour.
class NewCoinArt extends StatefulWidget {
  const NewCoinArt({super.key, required this.tone});

  final NewCoinTone tone;

  @override
  State<NewCoinArt> createState() => _NewCoinArtState();
}

class _NewCoinArtState extends State<NewCoinArt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final box = 168.w;
    final coin = 132.w;
    final tone = widget.tone;
    return SizedBox(
      width: box,
      height: box,
      child: Stack(
        alignment: Alignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.white.withValues(alpha: 0.6),
                  tone.light.withValues(alpha: 0),
                ],
              ),
            ),
            child: SizedBox(width: box, height: box),
          ),
          AnimatedBuilder(
            animation: _float,
            builder: (_, child) => Transform.translate(
              offset: Offset(
                0,
                -6.h * Curves.easeInOut.transform(_float.value) + 3.h,
              ),
              child: child,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: tone.accent.withValues(alpha: 0.55),
                    blurRadius: 36.r,
                    offset: Offset(0, 12.h),
                  ),
                ],
              ),
              // The rendered glass coin in the pack's colour, for the hero
              // only. Inline amounts keep the flat `coinLumi`, which stays
              // legible at text size.
              child: tone.art.image(
                width: coin,
                height: coin,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The top of one pack's page: the coin, the pack's name, what it costs, and
/// a pill with the two numbers that define it — how many coins, for how long.
class NewCoinPackHeader extends StatelessWidget {
  const NewCoinPackHeader({
    super.key,
    required this.pack,
    required this.tone,
    this.isBestOffer = false,
    this.savingPercent = 0,
  });

  final NewCoinPack pack;
  final NewCoinTone tone;
  final bool isBestOffer;

  /// How much cheaper a coin is here than in the dearest main pack. 0 hides it.
  final int savingPercent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NewCoinArt(tone: tone),
        8.kh,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                pack.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.phone32.copyWith(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
            ),
            if (isBestOffer) ...[8.kw, const _BestOfferBadge()],
          ],
        ),
        4.kh,
        Text(
          pack.price.toRawUzsPrice(),
          style: AppText.semibold16.copyWith(color: AppColors.white),
        ),
        14.kh,
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(40.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CoinAmount(
                amount: pack.coins,
                style: AppText.semibold14,
                color: AppColors.white,
              ),
              if (pack.validDays > 0) ...[
                8.kw,
                Text(
                  '·',
                  style: AppText.semibold14.copyWith(color: AppColors.inkMuted),
                ),
                8.kw,
                Text(
                  'new_coins_days'.tr(args: ['${pack.validDays}']),
                  style: AppText.semibold14.copyWith(color: AppColors.white),
                ),
              ],
              if (savingPercent > 0) ...[
                8.kw,
                _ValueChip(
                  label: 'new_coins_save_badge'.tr(args: ['$savingPercent']),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// A light pill carrying one figure — "40 Lumi Coin", "30 days", "−12%".
class _ValueChip extends StatelessWidget {
  const _ValueChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.inkChip,
        borderRadius: BorderRadius.circular(40.r),
      ),
      child: Text(
        label,
        style: AppText.semibold12.copyWith(color: AppColors.ink),
      ),
    );
  }
}

/// One line of what a pack gives: what it is, a sentence about it, and the
/// figure — on a chip — when there is one.
class NewCoinFeature {
  const NewCoinFeature({
    required this.icon,
    required this.title,
    this.body,
    this.chip,
  });

  final IconData icon;
  final String title;
  final String? body;
  final String? chip;
}

/// "What's in the pack": a frame in the pack's colour around two dark panels —
/// a heading, then every [NewCoinFeature] as a row.
class NewCoinPackFeatures extends StatelessWidget {
  const NewCoinPackFeatures({
    super.key,
    required this.tone,
    required this.title,
    required this.subtitle,
    required this.features,
  });

  final NewCoinTone tone;
  final String title;
  final String subtitle;
  final List<NewCoinFeature> features;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        gradient: tone.frame,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.coinPanel,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Row(
              children: [
                Assets.icons.coinLumi.image(width: 32.w, height: 32.w),
                12.kw,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            AppText.semibold16.copyWith(color: AppColors.white),
                      ),
                      2.kh,
                      Text(
                        subtitle,
                        style: AppText.regular13
                            .copyWith(color: AppColors.inkMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          6.kh,
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
              color: AppColors.coinPanel,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Column(
              children: [
                for (var i = 0; i < features.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.white.withValues(alpha: 0.07),
                    ),
                  _FeatureRow(feature: features[i]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.feature});

  final NewCoinFeature feature;

  @override
  Widget build(BuildContext context) {
    final body = feature.body;
    final chip = feature.chip;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: Row(
        children: [
          Icon(
            feature.icon,
            size: 26.w,
            color: AppColors.white.withValues(alpha: 0.85),
          ),
          14.kw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: AppText.semibold16.copyWith(color: AppColors.white),
                ),
                if (body != null) ...[
                  2.kh,
                  Text(
                    body,
                    style:
                        AppText.regular13.copyWith(color: AppColors.inkMuted),
                  ),
                ],
                if (chip != null) ...[8.kh, _ValueChip(label: chip)],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The one action on the screen, pinned to the bottom in the colour of the
/// pack in front: Buy, with the price on a chip beside it. The page scrolls
/// away underneath, behind a fade to the page colour.
class NewCoinsBuyBar extends StatelessWidget {
  const NewCoinsBuyBar({
    super.key,
    required this.tone,
    required this.price,
    required this.isLoading,
    required this.onBuy,
    this.dots,
  });

  final NewCoinTone tone;
  final num price;
  final bool isLoading;
  final VoidCallback? onBuy;

  /// The carousel's page dots, shown over the button. Null with a lone pack.
  final Widget? dots;

  @override
  Widget build(BuildContext context) {
    final dots = this.dots;
    return Container(
      padding: EdgeInsets.fromLTRB(
        16.w,
        36.h,
        16.w,
        16.h + MediaQuery.of(context).viewPadding.bottom,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, 0.32, 1],
          colors: [
            AppColors.coinStage.withValues(alpha: 0),
            AppColors.coinStage.withValues(alpha: 0.94),
            AppColors.coinStage,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dots != null) ...[dots, 14.kh],
          GestureDetector(
            onTap: isLoading ? null : onBuy,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              height: 58.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: tone.button,
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: tone.accent.withValues(alpha: 0.5),
                    blurRadius: 24.r,
                    offset: Offset(0, 8.h),
                  ),
                ],
              ),
              child: isLoading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(tone.onAccent),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'new_coins_buy_btn'.tr(),
                          style:
                              AppText.semibold16.copyWith(color: tone.onAccent),
                        ),
                        10.kw,
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 9.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: tone.onAccent.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            price.toRawUzsPrice(),
                            style: AppText.semibold14
                                .copyWith(color: tone.onAccent),
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
