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
                  // The figure above already says how many: the count is
                  // repeated only when a PART of the balance goes first.
                  label: balance.nearestExpiryCoins >= balance.balance
                      ? 'new_coins_valid_until'
                          .tr(args: [expiry.toRussianShortFormat(context)])
                      : 'new_coins_expire_on'.tr(args: [
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
///
/// In light it leads with [NewCoinTone.light], the pale tint, and lets the
/// full-strength accent through only as a trace, so the stage's dark ink is
/// readable the whole way down. In dark the pale tint would be a glaring band
/// under white ink, so the wash is the pack's deep shade instead, thinning
/// into the dark stage.
class NewCoinsBackdrop extends StatelessWidget {
  const NewCoinsBackdrop({super.key, required this.tone});

  final NewCoinTone tone;

  @override
  Widget build(BuildContext context) {
    final isDark = context.colors.isDark;
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0, 0.18, 0.38, 0.6],
              colors: isDark
                  ? [
                      tone.deep.withValues(alpha: 0.62),
                      tone.deep.withValues(alpha: 0.38),
                      tone.accent.withValues(alpha: 0.10),
                      tone.accent.withValues(alpha: 0),
                    ]
                  : [
                      tone.light,
                      tone.light.withValues(alpha: 0.78),
                      tone.accent.withValues(alpha: 0.14),
                      tone.accent.withValues(alpha: 0),
                    ],
            ),
          ),
        ),
        // A pale bloom off the top edge, so the colour reads as lit rather
        // than as a flat band. Strong on the light stage, where it has only a
        // pale wash to show against; a hint on the dark one.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.35, -1.05),
              radius: 0.75,
              colors: [
                AppColors.white.withValues(alpha: isDark ? 0.12 : 0.6),
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
              // The pack's own colour, denser at the centre, gives the coin
              // a ground to sit on: the pale tint on the light stage, a glow
              // of the accent on the dark one.
              gradient: RadialGradient(
                colors: context.colors.isDark
                    ? [
                        tone.accent.withValues(alpha: 0.38),
                        tone.accent.withValues(alpha: 0),
                      ]
                    : [
                        tone.light.withValues(alpha: 0.85),
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
              // only. Inline amounts keep the plain `coinLumi`, which stays
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
    this.isCurrent = false,
  });

  final NewCoinPack pack;
  final NewCoinTone tone;
  final bool isBestOffer;

  /// The buyer's live tariff. Its badge takes the place of "best offer":
  /// the two side by side do not fit beside the name.
  final bool isCurrent;

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
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            if (isCurrent) ...[
              8.kw,
              const _CurrentPlanBadge()
            ] else if (isBestOffer) ...[
              8.kw,
              const _BestOfferBadge()
            ],
          ],
        ),
        4.kh,
        Text(
          pack.price.toRawUzsPrice(),
          style: AppText.semibold16.copyWith(
              color: context.colors.textPrimary.withValues(alpha: 0.7)),
        ),
        14.kh,
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
          decoration: BoxDecoration(
            // Paper on the wash, the same move the top pills make.
            color: context.colors.coinPanel.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(40.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CoinAmount(
                amount: pack.coins,
                style: AppText.semibold14,
                color: context.colors.textPrimary,
              ),
              if (pack.validDays > 0) ...[
                8.kw,
                Text(
                  '·',
                  style: AppText.semibold14.copyWith(color: AppColors.inkMuted),
                ),
                8.kw,
                // Flexible, so a long translation of the deadline shortens
                // instead of pushing the saving chip off the end of the pill.
                // The coin amount and the chip are the two figures that must
                // stay whole; this one reads fine clipped.
                Flexible(
                  child: Text(
                    'new_coins_days'.tr(args: ['${pack.validDays}']),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.semibold14
                        .copyWith(color: context.colors.textPrimary),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// A pill carrying one figure — "40 Lumi Coin", "30 days", "−12%".
///
/// One fill, not two: both of its grounds are the stage's paper — the
/// header's own pill and a feature row's panel — so the chip is a tint of the
/// ink it carries either way.
class _ValueChip extends StatelessWidget {
  const _ValueChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: context.colors.textPrimary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(40.r),
      ),
      child: Text(
        label,
        style: AppText.semibold12.copyWith(color: context.colors.textPrimary),
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

/// "What's in the pack": a frame in the pack's colour around two paper panels
/// — a heading, then every [NewCoinFeature] as a row.
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
              color: context.colors.coinPanel,
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
                        style: AppText.semibold16
                            .copyWith(color: context.colors.textPrimary),
                      ),
                      2.kh,
                      Text(
                        subtitle,
                        style: AppText.regular13
                            .copyWith(color: context.colors.textSecondary),
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
              color: context.colors.coinPanel,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Column(
              children: [
                for (var i = 0; i < features.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: context.colors.textPrimary.withValues(alpha: 0.08),
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
            color: context.colors.textPrimary.withValues(alpha: 0.75),
          ),
          14.kw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: AppText.semibold16
                      .copyWith(color: context.colors.textPrimary),
                ),
                if (body != null) ...[
                  2.kh,
                  Text(
                    body,
                    style: AppText.regular13
                        .copyWith(color: context.colors.textSecondary),
                  ),
                ],
                if (chip != null) ...[
                  8.kh,
                  _ValueChip(label: chip),
                ],
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
    required this.isLoading,
    required this.onBuy,
    this.price,
    this.dots,
    this.label,
    this.isCurrent = false,
    this.onChangePlan,
  });

  final NewCoinTone tone;

  /// The button's word. Null is "Buy".
  final String? label;

  /// The pack in front is the buyer's live tariff. With [onChangePlan] the
  /// button offers to change it; without, it says so, is dimmed, and does
  /// nothing.
  final bool isCurrent;

  /// What "change subscription" does on the live tariff — the shelf brings
  /// another pack forward, where the real change-of-tariff button is.
  final VoidCallback? onChangePlan;

  /// Shown on a chip beside the label. Null leaves the label alone — the
  /// checkout page states the sum just above the bar and need not repeat it.
  final num? price;
  final bool isLoading;
  final VoidCallback? onBuy;

  /// The carousel's page dots, shown over the button. Null with a lone pack.
  final Widget? dots;

  @override
  Widget build(BuildContext context) {
    final dots = this.dots;
    final price = this.price;
    return Container(
      padding: EdgeInsets.fromLTRB(
        16.w,
        36.h,
        16.w,
        // `padding`, not `viewPadding`: on the Тарифы tab the tabs scaffold
        // runs `extendBody: true`, so Flutter reports the nav pill's height
        // here and Buy clears it. Pushed full-screen there is no pill and
        // this is the safe-area inset, exactly as before.
        16.h + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, 0.32, 1],
          colors: [
            context.colors.coinStage.withValues(alpha: 0),
            context.colors.coinStage.withValues(alpha: 0.94),
            context.colors.coinStage,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dots != null) ...[dots, 14.kh],
          GestureDetector(
            onTap: isLoading
                ? null
                : isCurrent
                    ? onChangePlan
                    : onBuy,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 220),
              opacity: isCurrent && onChangePlan == null ? 0.55 : 1,
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
                            isCurrent
                                ? (onChangePlan != null
                                    ? 'new_coins_change_subscription'.tr()
                                    : 'new_coins_current_plan'.tr())
                                : label ?? 'new_coins_buy_btn'.tr(),
                            style: AppText.semibold16
                                .copyWith(color: tone.onAccent),
                          ),
                          if (price != null && !isCurrent) ...[
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
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Current plan" — on the pack the buyer holds now, in that pack's colour.
/// "Current" — on the buyer's live tariff. Dressed exactly like
/// [_BestOfferBadge], whose place it takes: the pack's own tone washed into
/// the card behind it, so a badge in that tone all but disappeared.
class _CurrentPlanBadge extends StatelessWidget {
  const _CurrentPlanBadge();

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
          Icon(Icons.check_rounded, size: 12.w, color: AppColors.white),
          4.kw,
          Text(
            'new_coins_current_badge'.tr(),
            // Line box trimmed to the glyphs, split evenly above and below,
            // so the word centres on the icon beside it instead of riding
            // low under the font's default leading.
            style: AppText.bold10.copyWith(
              color: AppColors.white,
              height: 1.0,
              leadingDistribution: TextLeadingDistribution.even,
            ),
            textHeightBehavior: const TextHeightBehavior(
              applyHeightToFirstAscent: false,
              applyHeightToLastDescent: false,
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
            // Line box trimmed to the glyphs, split evenly above and below,
            // so the word centres on the icon beside it instead of riding
            // low under the font's default leading.
            style: AppText.bold10.copyWith(
              color: AppColors.white,
              height: 1.0,
              leadingDistribution: TextLeadingDistribution.even,
            ),
            textHeightBehavior: const TextHeightBehavior(
              applyHeightToFirstAscent: false,
              applyHeightToLastDescent: false,
            ),
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
