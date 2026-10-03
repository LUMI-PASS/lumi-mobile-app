import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/common/widget/coin_amount.dart';
import 'package:lumi_pass/data/api_model/new_coins/new_coin_models.dart';
import 'package:lumi_pass/data/api_model/order/order_model.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/new_coins/new_coins_repository.dart';
import 'package:lumi_pass/presentation/app/cubit/app_cubit.dart';
import 'package:lumi_pass/presentation/app/new_coins/new_coins_history_page.dart';
import 'package:lumi_pass/presentation/app/new_coins/new_coins_purchase_controller.dart';
import 'package:lumi_pass/presentation/app/new_coins/new_coins_success_page.dart';
import 'package:lumi_pass/presentation/app/new_coins/widgets/new_coins_widgets.dart';

/// The "Lumi Coin" screen: what the buyer holds, when it expires, and the
/// shelf — main packs, extra packs and loose coins.
///
/// Lumi Coin is NOT the cashback wallet: it is bought with money in packs and
/// pays for an activity booking outright, instead of money.
///
/// The payment half is deliberately the code the "Lumi Start" packet screen
/// runs: `showPaymentChooser` for the rail, `showCardOtpSheet` for a card, and
/// a poll on app-resume for the redirect rails. A second implementation of any
/// of those is a second set of payment bugs.
@RoutePage()
class NewCoinsPage extends StatefulWidget {
  const NewCoinsPage({
    super.key,
    this.buySingle,
    this.topUpFor,
    this.returnOnPurchase = false,
  });

  /// Opened to buy exactly this many loose coins — the booking screen's "you
  /// are N short" sheet. The stepper is preset and the purchase starts as soon
  /// as the shelf has loaded, provided this buyer may buy loose coins at all.
  final int? buySingle;

  /// Opened because a booking is this many coins short. The shelf then leads
  /// with the extra packs — a top-up is what the buyer came for — and opens
  /// on the cheapest pack that covers the gap. Extras are sold only on top of
  /// a live main pack, so without one the main packs still lead.
  final int? topUpFor;

  /// Close the screen once a purchase succeeds, instead of staying on the
  /// shelf. Set by a caller the buyer wants to get back to — a booking that
  /// was one top-up short of being paid.
  final bool returnOnPurchase;

  @override
  State<NewCoinsPage> createState() => _NewCoinsPageState();
}

class _NewCoinsPageState extends State<NewCoinsPage> {
  final NewCoinsRepository _repo = getIt<NewCoinsRepository>();

  NewCoinCatalogue _catalogue = NewCoinCatalogue.empty;
  NewCoinBalance _balance = NewCoinBalance.empty;
  bool _isLoading = true;
  bool _failed = false;

  /// Runs a purchase from Buy to coins on the balance — the same controller
  /// the booking screen tops up with.
  late final NewCoinsPurchaseController _buyer = NewCoinsPurchaseController(
    host: this,
    notify: () => setState(() {}),
    onPaid: _finishSuccess,
    onError: _showError,
    // The shelf on screen is out of date — a main pack lapsed, or a pack was
    // withdrawn. Refresh it under the message.
    onShelfStale: _load,
  );

  /// [NewCoinPurchase.key] of the purchase in flight, or null. One at a time:
  /// every other buy button is inert while it is set.
  String? get _purchasing => _buyer.purchasing;

  int _singleQuantity = 1;

  /// Id of the pack the buy bar pays for — whichever card of the carousel is
  /// in front.
  String? _selectedId;

  /// Narrower than the screen, so the neighbouring packs' cards peek in.
  final PageController _pageController = PageController(viewportFraction: 0.86);

  /// The [NewCoinsPage.buySingle] hand-off has run. It fires once — a reload
  /// after a failed payment must not restart a purchase nobody re-asked for.
  bool _autoBuyDone = false;

  @override
  void initState() {
    super.initState();
    _buyer.attach();
    final preset = widget.buySingle;
    if (preset != null && preset > 0) {
      _singleQuantity = preset.clamp(1, NewCoinSingleCard.maxQuantity);
    }
    _load();
  }

  @override
  void dispose() {
    _buyer.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _failed = false;
    });
    // Keeps the app-wide balance (profile tile, booking option) in step with
    // what this screen is about to show. Not awaited — it swallows its own
    // failures and this screen reads its own copy below.
    getIt<AppCubit>().syncNewCoins();
    try {
      final results = await Future.wait([
        _repo.getCatalogue(),
        // A balance that cannot be read is an empty one, not a broken screen:
        // the shelf is still worth showing.
        _repo.getBalance().catchError((_) => NewCoinBalance.empty),
      ]);
      if (!mounted) return;
      setState(() {
        _catalogue = results[0] as NewCoinCatalogue;
        _balance = results[1] as NewCoinBalance;
        // Keep the pick across a reload when that pack is still on the shelf.
        if (_selectedPack == null) _selectedId = _defaultPick()?.id;
      });
      _showSelectedCard();
      _maybeAutoBuy();
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Starts the loose-coin purchase the screen was opened for.
  void _maybeAutoBuy() {
    if (_autoBuyDone || widget.buySingle == null) return;
    _autoBuyDone = true;
    if (!_canBuySingle) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _buy(_singlePurchase);
    });
  }

  /// Extra packs are shown only to someone who may buy them — a locked shelf
  /// is a row of things the buyer cannot have.
  List<NewCoinPack> get _extras =>
      _catalogue.canBuyExtras ? _catalogue.extra : const [];

  /// Every pack on offer, in carousel order.
  List<NewCoinPack> get _shelf => _extrasFirst
      ? [..._extras, ..._catalogue.main]
      : [..._catalogue.main, ..._extras];

  /// Brings the carousel to the selected pack once it has been laid out — the
  /// top-up hand-off opens on a pack that is rarely the first card.
  void _showSelectedCard() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) return;
      final index = _shelf.indexWhere((p) => p.id == _selectedId);
      if (index > 0) _pageController.jumpToPage(index);
    });
  }

  /// The main pack whose coin is cheapest — the one worth a badge. Null when
  /// there is nothing to compare it with.
  String? get _bestOfferId {
    if (_catalogue.main.length < 2) return null;
    NewCoinPack? best;
    for (final p in _catalogue.main) {
      final perCoin = p.pricePerCoin ?? 0;
      if (perCoin <= 0) continue;
      if (best == null || perCoin < (best.pricePerCoin ?? 0)) best = p;
    }
    return best?.id;
  }

  /// Whether paying for the pack in front BY CARD brings the first-pack gift:
  /// it is still on offer, and the pack is a main one.
  bool get _bonusOnCard =>
      _catalogue.firstPackBonus > 0 &&
      _catalogue.main.any((p) => p.id == _selectedId);

  /// A booking that came up short sent the buyer here: extras lead.
  bool get _extrasFirst => widget.topUpFor != null && _extras.isNotEmpty;

  /// The pack the Buy button starts on. For a top-up, the cheapest pack that
  /// covers the gap — extras before main packs — so the default purchase is
  /// the smallest one that lets the booking go through. Otherwise the first
  /// main pack.
  NewCoinPack? _defaultPick() {
    final missing = widget.topUpFor;
    if (missing != null) {
      for (final shelf in [_extras, _catalogue.main]) {
        final covering = shelf.where((p) => p.coins >= missing).toList()
          ..sort((a, b) => a.price.compareTo(b.price));
        if (covering.isNotEmpty) return covering.first;
      }
      if (_extras.isNotEmpty) return _extras.last;
    }
    return _catalogue.main.isEmpty ? null : _catalogue.main.first;
  }

  NewCoinPack? get _selectedPack {
    for (final pack in [..._catalogue.main, ..._extras]) {
      if (pack.id == _selectedId) return pack;
    }
    return null;
  }

  /// How much cheaper a coin is in [pack] than in the dearest main pack, as a
  /// whole percent. 0 for that dearest pack itself and for extras.
  int _savingPercent(NewCoinPack pack) {
    num dearest = 0;
    for (final p in _catalogue.main) {
      final perCoin = p.pricePerCoin ?? 0;
      if (perCoin > dearest) dearest = perCoin;
    }
    final perCoin = pack.pricePerCoin ?? 0;
    if (dearest <= 0 || perCoin <= 0 || perCoin >= dearest) return 0;
    return ((dearest - perCoin) / dearest * 100).round();
  }

  bool get _canBuySingle =>
      _catalogue.canBuyExtras && _catalogue.singleCoinPrice > 0;

  NewCoinPurchase get _singlePurchase =>
      NewCoinPurchase.single(_singleQuantity, _catalogue.singleCoinPrice);

  // ── Buying ─────────────────────────────────────────────────────────────────

  /// The perk to show on the card rail of the payment sheet: the first-pack
  /// gift is for a main pack paid by card, and it is said there because that
  /// is where the method is being chosen.
  String? get _cardBadge => _bonusOnCard
      ? 'new_coins_amount'.tr(args: ['+${_catalogue.firstPackBonus}'])
      : null;

  Future<void> _buy(NewCoinPurchase purchase) => _buyer.buy(purchase,
      cardBadge: purchase.pack == null ? null : _cardBadge);

  /// Hands off to the success screen, then either returns to whoever opened
  /// this screen or reloads the shelf with the new balance on it.
  Future<void> _finishSuccess(
    NewCoinPurchase purchase,
    CheckoutResult result,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NewCoinsSuccessPage(coins: purchase.coins),
      ),
    );
    if (!mounted) return;
    if (widget.returnOnPurchase) {
      context.router.maybePop(true);
      return;
    }
    await _load();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, maxLines: 3),
        backgroundColor: context.colors.error,
      ),
    );
  }

  /// The tone [pack] is shown in: main packs take theirs by shelf position,
  /// extras share one.
  NewCoinTone _toneOf(NewCoinPack pack) {
    final index = _catalogue.main.indexWhere((p) => p.id == pack.id);
    return index < 0 ? NewCoinTone.extra : NewCoinTone.main(index);
  }

  /// Where the carousel is, as a fraction between cards — [fallback] until it
  /// has been laid out.
  double _pageOr(int fallback) {
    if (_pageController.hasClients && _pageController.position.haveDimensions) {
      return _pageController.page ?? fallback.toDouble();
    }
    return fallback.toDouble();
  }

  /// What buying [pack] gives, row by row. Only what is true of this pack for
  /// this buyer: the gift row goes once the gift has been had, and a figure
  /// the server did not send is a row left out.
  List<NewCoinFeature> _featuresOf(NewCoinPack pack) {
    final isMain = _catalogue.main.any((p) => p.id == pack.id);
    final bonus = isMain ? _catalogue.firstPackBonus : 0;

    // The price of one coin is not a row here: the pack is sold as a pack, and
    // what it saves is already the badge on its header.
    return [
      NewCoinFeature(
        icon: Icons.toll_rounded,
        title: 'new_coins_feat_coins_title'.tr(),
        body: 'new_coins_step3'.tr(),
        chip: 'new_coins_amount'.tr(args: [pack.coins.toGrouped()]),
      ),
      if (bonus > 0)
        NewCoinFeature(
          icon: Icons.card_giftcard_rounded,
          title: 'new_coins_feat_bonus_title'.tr(),
          body: 'new_coins_feat_bonus_body'.tr(),
          chip: 'new_coins_amount'.tr(args: ['+${bonus.toGrouped()}']),
        ),
      if (pack.validDays > 0)
        NewCoinFeature(
          icon: Icons.schedule_rounded,
          title: 'new_coins_feat_valid_title'.tr(),
          body: 'new_coins_feat_valid_body'.tr(args: ['${pack.validDays}']),
          chip: 'new_coins_days'.tr(args: ['${pack.validDays}']),
        ),
      if (isMain)
        NewCoinFeature(
          icon: Icons.autorenew_rounded,
          title: 'new_coins_feat_carry_title'.tr(),
          body: 'new_coins_feat_carry_body'.tr(),
        )
      else
        NewCoinFeature(
          icon: Icons.add_circle_outline_rounded,
          title: 'new_coins_feat_extra_title'.tr(),
          body: 'new_coins_feat_extra_body'.tr(),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Nothing on the shelf and nothing held: the feature is not live for this
    // user, and a deep link here lands on the empty state rather than on a
    // screen of headings with nothing under them.
    final empty = !_catalogue.isOnSale && _balance.balance <= 0;

    // Loading wears the shelf's own stage — the wash, the back pill, the Buy
    // bar's place — so the packs arrive into the screen that was already
    // there, rather than a light list of blocks flipping to a dark showcase.
    if (_isLoading) {
      return _NewCoinsLoading(onBack: () => context.router.maybePop());
    }

    if (_failed || empty) {
      return Scaffold(
        backgroundColor: c.pageBg,
        appBar: BaseAppBar(title: 'new_coins_title'.tr()),
        body: _NewCoinsUnavailable(onRetry: _load),
      );
    }

    final shelf = _shelf;
    final pack = _selectedPack;
    final busy = _purchasing != null;
    final selected = shelf.indexWhere((p) => p.id == _selectedId);
    final active = selected < 0 ? 0 : selected;
    final tones = [for (final p in shelf) _toneOf(p)];
    final top = MediaQuery.of(context).viewPadding.top;

    // The shelf is a showcase and is dark in both themes: each pack's colour
    // is a glow fading into black, which a light page cannot carry. The
    // payment sheets and "my coins" open from the State's own context, above
    // this override, so they keep the app's theme.
    return Theme(
      data: Theme.of(context).copyWith(
        brightness: Brightness.dark,
        extensions: const [AppColorScheme.dark],
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: AppColors.coinStage,
          body: Stack(
            children: [
              // The wash follows the swipe, blending from one pack's colour
              // into the next rather than snapping when the page settles.
              if (tones.isNotEmpty)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _pageController,
                      builder: (_, __) {
                        final page =
                            _pageOr(active).clamp(0.0, tones.length - 1.0);
                        final from = page.floor();
                        final to = page.ceil();
                        return NewCoinsBackdrop(
                          tone: NewCoinTone.lerp(
                            tones[from],
                            tones[to],
                            page - from,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              // ONE vertical scroll for the whole shelf, with the pager inside
              // it — so the pack in front and the neighbours peeking in at
              // the edges move up and down as a single sheet.
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    top: top + 52.h,
                    // Clears the buy bar, so the last row can be scrolled out
                    // from under it.
                    bottom: MediaQuery.of(context).viewPadding.bottom + 150.h,
                  ),
                  child: Stack(
                    children: [
                      // A PageView has no height of its own. Every page is
                      // laid out here, unseen, on top of one another, so the
                      // stack — and the pager filling it — is as tall as the
                      // tallest pack.
                      TickerMode(
                        enabled: false,
                        child: ExcludeSemantics(
                          child: IgnorePointer(
                            child: Opacity(
                              opacity: 0,
                              child: Stack(
                                children: [
                                  for (var i = 0; i < shelf.length; i++)
                                    Align(
                                      alignment: Alignment.topCenter,
                                      child: FractionallySizedBox(
                                        widthFactor:
                                            _pageController.viewportFraction,
                                        child: _packPage(
                                          shelf[i],
                                          i,
                                          tones[i],
                                          active,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: shelf.length,
                          // Swiping to a pack is choosing it. Locked while a
                          // purchase is in flight, so the button cannot
                          // change subject under it.
                          physics: busy
                              ? const NeverScrollableScrollPhysics()
                              : null,
                          onPageChanged: (i) =>
                              setState(() => _selectedId = shelf[i].id),
                          itemBuilder: (_, i) => Align(
                            alignment: Alignment.topCenter,
                            child: _packPage(shelf[i], i, tones[i], active),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // One action: the pack in front and Buy. The rail is asked for
              // when Buy is pressed, not chosen up here as a second decision.
              if (pack != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: NewCoinsBuyBar(
                    tone: tones[active],
                    price: pack.price,
                    isLoading: _purchasing == pack.id,
                    onBuy: busy ? null : () => _buy(NewCoinPurchase.pack(pack)),
                    dots: shelf.length > 1
                        ? NewCoinsDots(count: shelf.length, active: active)
                        : null,
                  ),
                ),
              Positioned(
                top: top + 8.h,
                left: 16.w,
                right: 16.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _TopPill(
                      onTap: () => context.router.maybePop(),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 20.w,
                        color: AppColors.white,
                      ),
                    ),
                    // What the buyer holds, and the way to the deadlines and
                    // the history behind it — off the shelf, which is for
                    // choosing a pack and nothing else.
                    _TopPill(
                      onTap: _openMine,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CoinAmount(
                            amount: _balance.balance,
                            style: AppText.semibold14,
                            color: AppColors.white,
                          ),
                          2.kw,
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18.w,
                            color: AppColors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// One pack's page: its header, then what is in it. It does not scroll —
  /// the shelf around the pager does.
  Widget _packPage(
    NewCoinPack pack,
    int index,
    NewCoinTone tone,
    int active,
  ) {
    final busy = _purchasing != null;
    final isMain = _catalogue.main.any((p) => p.id == pack.id);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Only the pack in front has a header: a neighbour's would be cut
          // in half by the screen edge, so it fades out with distance and
          // leaves just its card peeking in.
          AnimatedBuilder(
            animation: _pageController,
            builder: (_, child) => Opacity(
              opacity:
                  (1 - (_pageOr(active) - index).abs() * 1.8).clamp(0.0, 1.0),
              child: child,
            ),
            child: NewCoinPackHeader(
              pack: pack,
              tone: tone,
              isBestOffer: pack.id == _bestOfferId,
              savingPercent: isMain ? _savingPercent(pack) : 0,
            ),
          ),
          20.kh,
          // Loose coins have no place on the shelf. The one way to them is the
          // booking screen's "you are N short" hand-off, which opens this
          // screen to buy exactly that many — and only then is the card shown.
          if (widget.buySingle != null && _canBuySingle) ...[
            NewCoinSingleCard(
              unitPrice: _catalogue.singleCoinPrice,
              quantity: _singleQuantity,
              isLoading: _purchasing == NewCoinPurchase.singleKey,
              enabled: !busy,
              onChanged: (q) => setState(() => _singleQuantity = q),
              onBuy: () => _buy(_singlePurchase),
            ),
            12.kh,
          ],
          NewCoinPackFeatures(
            tone: tone,
            title: 'new_coins_pack_includes'.tr(),
            subtitle: pack.description ?? 'new_coins_hero_subtitle'.tr(),
            features: _featuresOf(pack),
          ),
        ],
      ),
    );
  }

  /// What the buyer holds: the balance, the deadlines behind it, and under
  /// them every movement that led there — in a sheet over the shelf.
  void _openMine() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (sheetContext, scroll) {
          final c = sheetContext.colors;
          return Container(
            decoration: BoxDecoration(
              color: c.pageBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: ListView(
              controller: scroll,
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 32.h),
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: c.border,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
                18.kh,
                Text(
                  'new_coins_tab_mine'.tr(),
                  style: AppText.semibold18.copyWith(color: c.textSection),
                ),
                12.kh,
                NewCoinsBalanceCard(balance: _balance),
                20.kh,
                Text(
                  'new_coins_history'.tr(),
                  style: AppText.semibold18.copyWith(color: c.textSection),
                ),
                12.kh,
                const NewCoinsHistoryList(),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// A translucent control floating over the wash at the top of the shelf.
class _TopPill extends StatelessWidget {
  const _TopPill({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 40.w,
        constraints: BoxConstraints(minWidth: 40.w),
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(40.r),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.18)),
        ),
        child: child,
      ),
    );
  }
}

/// The shelf while it loads: the stage and its wash exactly as the loaded
/// screen draws them, with the first pack's page sketched in shimmer — the
/// coin, the name and price, the pill, the "what's in the pack" card and the
/// Buy button.
///
/// The shapes are translucent white and breathe rather than sweep: a shimmer
/// repaints its child in its own opaque colours, which would cut flat blocks
/// out of the wash this screen is about.
class _NewCoinsLoading extends StatefulWidget {
  const _NewCoinsLoading({required this.onBack});

  final VoidCallback onBack;

  @override
  State<_NewCoinsLoading> createState() => _NewCoinsLoadingState();
}

class _NewCoinsLoadingState extends State<_NewCoinsLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<double> _pulse = Tween(begin: 0.45, end: 1.0)
      .animate(CurvedAnimation(parent: _breath, curve: Curves.easeInOut));

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onBack = widget.onBack;
    final top = MediaQuery.of(context).viewPadding.top;
    final bottom = MediaQuery.of(context).viewPadding.bottom;
    // The first main pack leads the shelf, so its tone is the one the loaded
    // screen most often opens on.
    final tone = NewCoinTone.main(0);
    final ghost = AppColors.white.withValues(alpha: 0.22);

    Widget bar(double width, double height) => Container(
          width: width.w,
          height: height.h,
          decoration: BoxDecoration(
            color: ghost,
            borderRadius: BorderRadius.circular(height.h),
          ),
        );

    Widget row() => Padding(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          child: Row(
            children: [
              Container(
                width: 26.w,
                height: 26.w,
                decoration: BoxDecoration(color: ghost, shape: BoxShape.circle),
              ),
              14.kw,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [bar(150, 14), 8.kh, bar(210, 10)],
              ),
            ],
          ),
        );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.coinStage,
        body: Stack(
          children: [
            Positioned.fill(child: NewCoinsBackdrop(tone: tone)),
            Positioned.fill(
              child: FadeTransition(
                opacity: _pulse,
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  // The loaded page's own insets: under the top pills, and
                  // one carousel card wide.
                  padding: EdgeInsets.fromLTRB(
                    0.07.sw + 6.w,
                    top + 52.h,
                    0.07.sw + 6.w,
                    0,
                  ),
                  child: Column(
                    children: [
                      // The coin, in the box NewCoinArt gives it.
                      SizedBox(
                        height: 168.w,
                        child: Center(
                          child: Container(
                            width: 132.w,
                            height: 132.w,
                            decoration: BoxDecoration(
                              color: ghost,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      14.kh,
                      bar(180, 26),
                      12.kh,
                      bar(110, 14),
                      16.kh,
                      bar(170, 36),
                      20.kh,
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 12.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(24.r),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32.w,
                                    height: 32.w,
                                    decoration: BoxDecoration(
                                      color: ghost,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  12.kw,
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      bar(140, 14),
                                      8.kh,
                                      bar(200, 10),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            6.kh,
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 14.w),
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(24.r),
                              ),
                              child: Column(
                                children: [row(), row(), row(), row()],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Where the Buy bar will be: its fade to the stage colour, and
            // the button's shape under it.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(16.w, 36.h, 16.w, 16.h + bottom),
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
                child: FadeTransition(
                  opacity: _pulse,
                  child: Container(
                    height: 58.h,
                    decoration: BoxDecoration(
                      color: ghost,
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: top + 8.h,
              left: 16.w,
              child: _TopPill(
                onTap: onBack,
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 20.w,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Nothing on sale, or the shelf could not be loaded. Says so and offers the
/// one thing that can help: looking again.
class _NewCoinsUnavailable extends StatelessWidget {
  const _NewCoinsUnavailable({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Assets.images.empty.image(width: 140.w),
            16.kh,
            Text(
              'new_coins_empty_title'.tr(),
              textAlign: TextAlign.center,
              style: AppText.semibold16.copyWith(color: c.textPrimary),
            ),
            8.kh,
            Text(
              'new_coins_empty_body'.tr(),
              textAlign: TextAlign.center,
              style: AppText.regular14.copyWith(color: c.textSecondary),
            ),
            20.kh,
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
                decoration: BoxDecoration(
                  gradient: AppGradients.brand,
                  borderRadius: BorderRadius.circular(44.r),
                ),
                child: Text(
                  'retry'.tr(),
                  style: AppText.medium14.copyWith(color: c.onPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
