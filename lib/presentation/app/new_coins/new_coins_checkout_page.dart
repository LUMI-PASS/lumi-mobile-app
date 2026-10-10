import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/last_payment_method.dart';
import 'package:lumi_pass/common/widget/payment_sheet_chrome.dart';
import 'package:lumi_pass/data/api_model/new_coins/new_coin_models.dart';
import 'package:lumi_pass/data/api_model/order/order_model.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/widgets/payment_sheets.dart';
import 'package:lumi_pass/presentation/app/new_coins/new_coins_purchase_controller.dart';
import 'package:lumi_pass/presentation/app/new_coins/widgets/new_coins_widgets.dart';
import 'package:lumi_pass/presentation/app/profile/cards/widgets/add_card_sheet.dart';

/// What [NewCoinsCheckoutPage] pops with once the pack is paid for.
typedef NewCoinsCheckoutResult = ({
  NewCoinPurchase purchase,
  CheckoutResult checkout,
});

/// The checkout for one Lumi Coin pack, on a screen of its own.
///
/// A pack used to be paid for straight from the shelf, through the payment
/// chooser sheet. A sheet has room to pick a method and nothing else; a pack
/// also takes a promocode, and the buyer should see what the code did to the
/// price before paying. So the pack gets the page a booking has always had:
/// what is being bought and its sum, the code, the method, and one Pay button.
///
/// The methods are laid out ON the page rather than behind the chooser sheet:
/// that sheet wears the app's theme, and opening it over this light stage was
/// a second look on one screen. Typing in a new card and the SMS codes still
/// open sheets, dressed in this stage's colours (see `PaymentSheetSkin`).
///
/// It is the shelf's own stage carried one step further — the same light
/// paper in both themes, the pack's colour washing off the top edge, white
/// panels, and the Buy bar in the pack's tone — so paying reads as the next
/// page of the pack rather than a different part of the app.
///
/// Loose coins are not sold here — they take no code and keep the sheet.
///
/// Pops with a [NewCoinsCheckoutResult] when the money has landed; whoever
/// opened the page shows the success screen. Pops with nothing if the buyer
/// backs out, or if the shelf turned out to be stale ([onShelfStale]).
class NewCoinsCheckoutPage extends StatefulWidget {
  const NewCoinsCheckoutPage({
    super.key,
    required this.pack,
    required this.tone,
    this.cardBadge,
    this.onShelfStale,
  });

  final NewCoinPack pack;

  /// The colour the pack wears on the shelf — its coin artwork follows it here.
  final NewCoinTone tone;

  /// The perk shown on the card rail of the chooser ("+10 Lumi Coin"), when
  /// paying for this pack by card earns one.
  final String? cardBadge;

  /// The server refused with a coin rule: the shelf behind this page is out
  /// of date and should re-read itself.
  final VoidCallback? onShelfStale;

  @override
  State<NewCoinsCheckoutPage> createState() => _NewCoinsCheckoutPageState();
}

class _NewCoinsCheckoutPageState extends State<NewCoinsCheckoutPage> {
  late final NewCoinsPurchaseController _buyer = NewCoinsPurchaseController(
    host: this,
    notify: () => setState(() {}),
    onPaid: (purchase, checkout) async {
      Navigator.of(context).pop((purchase: purchase, checkout: checkout));
    },
    onError: _showError,
    sheetSkin: _sheetSkin,
    // The pack on this page lapsed or was withdrawn: there is nothing left to
    // check out, so hand back to the shelf and have it reload.
    onShelfStale: () {
      widget.onShelfStale?.call();
      if (mounted) Navigator.of(context).pop();
    },
  );

  /// The sheets this page opens — add a card, the SMS codes — in the stage's
  /// colours: light, with the pack's own button.
  late final PaymentSheetSkin _sheetSkin = PaymentSheetSkin(
    gradient: widget.tone.button,
    onGradient: widget.tone.onAccent,
    accent: widget.tone.deep,
    background: AppColors.coinStage,
  );

  final _promoCtrl = TextEditingController();
  bool _promoBusy = false;

  /// The refusal for the code last submitted, shown under the field.
  String? _promoError;

  /// The buyer's saved cards — the strip under the card rail.
  final List<PaymentCard> _cards = [];

  NewCoinPack get _pack => widget.pack;
  PromocodePreview? get _promo => _buyer.promoFor(_pack);
  num get _total => _promo?.totalAmount ?? _pack.price;
  bool get _paying => _buyer.purchasing != null;

  @override
  void initState() {
    super.initState();
    _buyer.attach();
    _loadPayment();
  }

  /// Reads the saved cards, then offers whatever paid last time — as every
  /// other checkout does. Neither failing is fatal: the buyer picks a method.
  Future<void> _loadPayment() async {
    if (kCardPaymentsEnabled) {
      try {
        final saved = await getIt<OrdersApi>().getSavedCards();
        if (!mounted) return;
        setState(() => _cards.addAll(saved.map(PaymentCard.saved)));
      } catch (_) {}
    }
    final restored = await restoreLastPaymentMethod();
    if (!mounted || restored == null || _buyer.payment != null) return;
    final card = restored.card;
    setState(() {
      // Point at the strip's own instance of the card, so it shows as picked.
      _buyer.payment = card == null
          ? restored
          : PaymentSelection(rail: restored.rail, card: _listed(card) ?? card);
    });
  }

  PaymentCard? _listed(PaymentCard card) {
    for (final c in _cards) {
      if (c.savedCardId == card.savedCardId) return c;
    }
    return null;
  }

  @override
  void dispose() {
    _buyer.dispose();
    _promoCtrl.dispose();
    super.dispose();
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

  void _select(PaymentSelection selection) {
    setState(() => _buyer.payment = selection);
    if (selection.isPayable) rememberPaymentMethod(selection);
  }

  /// Picks a rail. The card rail takes the card already chosen, else the first
  /// saved one; with no cards at all it is picked but not yet payable, and the
  /// strip under it offers to add one.
  void _selectRail(PaymentRail rail) {
    if (_paying) return;
    if (rail != PaymentRail.card) return _select(PaymentSelection(rail: rail));
    _select(PaymentSelection(
      rail: rail,
      card: _buyer.payment?.card ?? (_cards.isEmpty ? null : _cards.first),
    ));
  }

  /// Binds a new card in the add-card sheet and picks it. Nothing is charged
  /// for the pack here — that is still the Buy bar.
  Future<void> _addCard() async {
    if (_paying) return;
    final saved = await showAddCardSheet(context, skin: _sheetSkin);
    if (saved == null || !mounted) return;
    final card = PaymentCard.saved(saved);
    _cards.removeWhere((c) => c.savedCardId == card.savedCardId);
    _cards.insert(0, card);
    _select(PaymentSelection(rail: PaymentRail.card, card: card));
  }

  /// Previews the typed code. Returns whether it was accepted.
  Future<bool> _applyPromo() async {
    final code = _promoCtrl.text.trim();
    if (code.isEmpty || _promoBusy) return false;
    FocusScope.of(context).unfocus();
    setState(() {
      _promoBusy = true;
      _promoError = null;
    });
    final error = await _buyer.applyPromo(_pack, code);
    if (!mounted) return false;
    setState(() {
      _promoBusy = false;
      _promoError = error;
      if (error == null) _promoCtrl.clear();
    });
    return error == null;
  }

  /// The Pay button. A code typed but never applied is applied first: paying
  /// with it still in the field means "use this", and dropping it silently
  /// would charge the full price. A refusal stays on the page, under the field.
  Future<void> _pay() async {
    if (_paying || _promoBusy) return;
    if (_promo == null && _promoCtrl.text.trim().isNotEmpty) {
      if (!await _applyPromo()) return;
    }
    final payment = _buyer.payment;
    if (payment == null) {
      _showError('book_pick_payment'.tr());
      return;
    }
    // The card rail with no card behind it: adding one is the next step.
    if (!payment.isPayable) {
      await _addCard();
      if (_buyer.payment?.isPayable != true) return;
    }
    await _buyer.buy(
      NewCoinPurchase.pack(_pack),
      cardBadge: widget.cardBadge,
    );
  }

  /// The stage is light in both themes, as the shelf is (see `NewCoinsPage`),
  /// so its ink is read off the light table rather than the app's theme. The
  /// State's own `context` sits ABOVE the override below — which is also why
  /// the chooser sheet it opens keeps the app's theme.
  static const AppColorScheme _c = AppColorScheme.light;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Theme(
      data: Theme.of(context).copyWith(
        brightness: Brightness.light,
        extensions: const [AppColorScheme.light],
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: AppColors.coinStage,
          // The Buy bar stays where it is and the keyboard covers it: riding
          // up over the keyboard it sat on top of the promocode being typed.
          // The field is near the top of the page, so nothing it needs is
          // hidden.
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: NewCoinsBackdrop(tone: widget.tone),
                ),
              ),
              Positioned.fill(
                child: Column(
                  children: [
                    // The list starts BELOW the top bar and fades out as it
                    // reaches it. The bar has no fill of its own — the pack's
                    // wash shows through it — so rows scrolling under it ran
                    // straight through the title. A fade keeps the wash and
                    // still gets them out of the way.
                    SizedBox(height: media.viewPadding.top + 58.h),
                    Expanded(
                      child: ShaderMask(
                        blendMode: BlendMode.dstIn,
                        shaderCallback: (bounds) => LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0, 18.h / bounds.height],
                          colors: const [Colors.transparent, Colors.black],
                        ).createShader(bounds),
                        child: ListView(
                          padding: EdgeInsets.fromLTRB(
                            16.w,
                            16.h,
                            16.w,
                            // Clears the Buy bar floating over the list.
                            media.padding.bottom + 120.h,
                          ),
                          children: [
                            _detailsCard(),
                            8.verticalSpace,
                            _totalCard(),
                            8.verticalSpace,
                            Container(
                              padding:
                                  EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
                              decoration: BoxDecoration(
                                color: AppColors.coinPanel,
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 2.w, bottom: 10.h),
                                    child: Text(
                                      'promo_have_code'.tr(),
                                      style: AppText.medium16
                                          .copyWith(color: AppColors.ink),
                                    ),
                                  ),
                                  _promoSection(),
                                ],
                              ),
                            ),
                            // In the scroll, under the code — not pinned over
                            // the button: the card strip makes this block grow,
                            // and pinned it squeezed the receipt above it.
                            22.verticalSpace,
                            _paymentSection(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Over the list, as on the shelf: the bar's own fade to the
              // stage colour is what cuts the content off above the button.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: NewCoinsBuyBar(
                  tone: widget.tone,
                  isLoading: _paying,
                  onBuy: _promoBusy ? null : _pay,
                ),
              ),
              Positioned(
                top: media.viewPadding.top + 8.h,
                left: 16.w,
                right: 16.w,
                child: _topBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The shelf's back pill, with the page's name centred beside it.
  Widget _topBar() {
    return SizedBox(
      height: 46.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                width: 40.w,
                height: 40.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.coinPanel.withValues(alpha: 0.72),
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: AppColors.ink.withValues(alpha: 0.08)),
                ),
                child: Icon(Icons.arrow_back_rounded,
                    size: 20.w, color: AppColors.ink),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'new_coins_checkout_title'.tr(),
                style: AppText.semibold16.copyWith(color: AppColors.ink),
              ),
              Text(
                'new_coins_title'.tr(),
                style: AppText.regular13.copyWith(color: _c.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// The receipt: what is being bought, row by row under hairlines — the
  /// pack, the coins in it, how long they last, and its price.
  Widget _detailsCard() {
    final applied = _promo;
    final rows = <Widget>[
      _row('new_coins_pack_label'.tr(), Text(_pack.name, style: _value)),
      _row(
        'new_coins_feat_coins_title'.tr(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${_pack.coins}', style: _value),
            5.horizontalSpace,
            Assets.icons.coinLumi.image(width: 18.w, height: 18.w),
          ],
        ),
      ),
      if (_pack.validDays > 0)
        _row(
          'new_coins_feat_valid_title'.tr(),
          Text('new_coins_days'.tr(args: ['${_pack.validDays}']),
              style: _value),
        ),
      _row(
          'price_label'.tr(), Text(_pack.price.toRawUzsPrice(), style: _value)),
      if (applied != null)
        _row(
          'booking_promocode_discount'.tr(),
          Text(
            '−${applied.discountAmount.toRawUzsPrice()}',
            style: _value.copyWith(color: _c.success),
          ),
        ),
    ];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.coinPanel,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const _DashedDivider(),
            rows[i],
          ],
        ],
      ),
    );
  }

  TextStyle get _value => AppText.medium16.copyWith(color: AppColors.ink);

  Widget _row(String label, Widget value) => Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: AppText.regular16.copyWith(color: AppColors.ink)),
            ),
            8.horizontalSpace,
            value,
          ],
        ),
      );

  /// What is charged, on a card of its own so it is the one figure that
  /// stands out.
  Widget _totalCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.coinPanel,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text('amount_due'.tr(),
                style: AppText.medium16.copyWith(color: AppColors.ink)),
          ),
          Text(_total.toRawUzsPrice(),
              style: AppText.semibold24.copyWith(color: AppColors.ink)),
        ],
      ),
    );
  }

  /// The promocode: a field with Apply, or the applied code and a way to
  /// remove it. What the code took off is on the receipt above, not here.
  Widget _promoSection() {
    final applied = _promo;
    if (applied != null) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: _c.control,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Assets.icons.detail.icDiscount.svg(width: 20.w),
            10.horizontalSpace,
            Expanded(
              child: Text(
                applied.code,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.semibold14.copyWith(color: AppColors.ink),
              ),
            ),
            8.horizontalSpace,
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _paying ? null : _buyer.clearPromo,
              child: Icon(Icons.close_rounded,
                  size: 18.sp, color: _c.textSecondary),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PaymentField(
          controller: _promoCtrl,
          hint: 'promo_hint'.tr(),
          enabled: !_promoBusy && !_paying,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _applyPromo(),
          // The error belongs to the code that was submitted, so it stops
          // being true the moment the buyer edits the field.
          onChanged: (_) {
            if (_promoError != null) setState(() => _promoError = null);
          },
          // A small Buy button: the same gradient and ink as the bar at the
          // bottom, so the two actions on the page read as one family.
          suffix: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _promoBusy || _paying ? null : _applyPromo,
            child: Container(
              height: 32.h,
              constraints: BoxConstraints(minWidth: 72.w),
              margin: EdgeInsets.only(left: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: widget.tone.button,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: _promoBusy
                  ? SizedBox(
                      width: 14.w,
                      height: 14.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(widget.tone.onAccent),
                      ),
                    )
                  : Text(
                      'promo_apply'.tr(),
                      style: AppText.semibold14
                          .copyWith(color: widget.tone.onAccent),
                    ),
            ),
          ),
        ),
        if (_promoError != null) ...[
          8.verticalSpace,
          Padding(
            padding: EdgeInsets.only(left: 8.w),
            child: Text(
              _promoError!,
              style: AppText.regular12.copyWith(color: _c.error),
            ),
          ),
        ],
      ],
    );
  }

  /// The methods, on the page: the rails four to a row, each its own mark,
  /// and — under them once the card rail is picked — the buyer's
  /// cards on a strip of their own.
  Widget _paymentSection() {
    final payment = _buyer.payment;
    final badge = widget.cardBadge;
    final rails = [
      PaymentRail.click,
      PaymentRail.payme,
      PaymentRail.uzum,
      if (kCardPaymentsEnabled) PaymentRail.card,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 10.h),
          child: Text(
            'book_pick_payment'.tr(),
            style: AppText.semibold16.copyWith(color: AppColors.ink),
          ),
        ),
        Row(
          children: [
            for (var i = 0; i < rails.length; i++) ...[
              if (i > 0) 8.horizontalSpace,
              Expanded(child: _railTile(rails[i], payment?.rail == rails[i])),
            ],
          ],
        ),
        // What paying by card earns, said where the method is being chosen.
        if (badge != null && kCardPaymentsEnabled) ...[
          10.verticalSpace,
          Padding(
            padding: EdgeInsets.only(left: 6.w),
            child: Text(
              '${'pay_with_card'.tr()}: $badge',
              style: AppText.medium13.copyWith(color: _c.success),
            ),
          ),
        ],
        if (payment?.rail == PaymentRail.card) ...[
          10.verticalSpace,
          SizedBox(
            height: 100.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: _cards.length + 1,
              separatorBuilder: (_, __) => 8.horizontalSpace,
              itemBuilder: (_, i) => i < _cards.length
                  ? _cardTile(_cards[i], identical(payment?.card, _cards[i]))
                  : _addCardTile(),
            ),
          ),
        ],
      ],
    );
  }

  /// A hollow ring, or the pack's colour with a tick once picked.
  Widget _radio(bool selected) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 22.w,
        height: 22.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? widget.tone.accent : null,
          border: selected
              ? null
              : Border.all(
                  color: AppColors.ink.withValues(alpha: 0.2),
                  width: 1.5,
                ),
        ),
        child: selected
            ? Icon(Icons.check_rounded, size: 14.w, color: widget.tone.onAccent)
            : null,
      );

  /// A tile on the stage's white paper, ringed in the pack's colour when
  /// picked — the shape the rails and the cards share.
  Widget _tile({
    required bool selected,
    required VoidCallback onTap,
    required Widget child,
    double? width,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: width,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.coinPanel,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: selected
                ? widget.tone.accent
                : AppColors.ink.withValues(alpha: 0.06),
            width: 1.5,
          ),
        ),
        child: child,
      ),
    );
  }

  /// The three wallets are their own wordmarks and need no caption; the card
  /// rail has no brand to show, so it is an icon with its name.
  Widget _railTile(PaymentRail rail, bool selected) {
    final Widget mark = switch (rail) {
      PaymentRail.click =>
        Assets.images.pay.clickLight.image(height: 20.h, fit: BoxFit.contain),
      PaymentRail.payme =>
        Assets.images.pay.payme.image(height: 24.h, fit: BoxFit.contain),
      PaymentRail.uzum =>
        Assets.images.pay.uzum.image(height: 24.h, fit: BoxFit.contain),
      PaymentRail.card => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.icons.icCard.svg(
              width: 20.w,
              height: 20.w,
              colorFilter:
                  const ColorFilter.mode(AppColors.ink, BlendMode.srcIn),
            ),
            8.horizontalSpace,
            Flexible(
              child: Text(
                'pay_card_short'.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.semibold14.copyWith(color: AppColors.ink),
              ),
            ),
          ],
        ),
    };
    // Four to a row leaves no room for a radio inside the tile, so the tick
    // rides on its corner: small, over the ring, clear of the mark. The ring
    // alone said "picked" by colour only.
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _tile(
          selected: selected,
          onTap: () => _selectRail(rail),
          child: SizedBox(
            height: 28.h,
            child: Center(child: FittedBox(fit: BoxFit.scaleDown, child: mark)),
          ),
        ),
        Positioned(
          top: -5.w,
          right: -5.w,
          child: IgnorePointer(
            child: AnimatedScale(
              // Not on the card rail: the chosen card on the strip under it
              // already carries the tick.
              scale: selected && rail != PaymentRail.card ? 1 : 0,
              duration: const Duration(milliseconds: 150),
              child: Container(
                width: 18.w,
                height: 18.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: widget.tone.accent,
                  shape: BoxShape.circle,
                  // A rim of the stage colour lifts it off the ring.
                  border: Border.all(color: AppColors.coinStage, width: 2),
                ),
                child: Icon(Icons.check_rounded,
                    size: 11.w, color: widget.tone.onAccent),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _cardTile(PaymentCard card, bool selected) {
    return _tile(
      width: 132.w,
      selected: selected,
      onTap: () {
        if (_paying) return;
        _select(PaymentSelection(rail: PaymentRail.card, card: card));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CardArtwork(brand: card.brand),
              const Spacer(),
              _radio(selected),
            ],
          ),
          const Spacer(),
          Text(
            card.brand.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.semibold12.copyWith(color: _c.textSecondary),
          ),
          Text(
            '•••• ${card.last4}',
            maxLines: 1,
            style: AppText.semibold16.copyWith(color: AppColors.ink),
          ),
        ],
      ),
    );
  }

  /// The strip's last tile — opens the add-card sheet.
  Widget _addCardTile() {
    return _tile(
      width: 132.w,
      selected: false,
      onTap: _addCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44.w,
            height: 28.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.ink.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(Icons.add_rounded, size: 18.sp, color: AppColors.ink),
          ),
          const Spacer(),
          Text(
            'pay_add_card'.tr(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.semibold14.copyWith(color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}

/// The rule between receipt rows — dashed, as on a paper receipt.
class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 1),
      painter: _DashPainter(AppColors.ink.withValues(alpha: 0.16)),
    );
  }
}

class _DashPainter extends CustomPainter {
  const _DashPainter(this.color);

  final Color color;

  static const double _dash = 5;
  static const double _gap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    final y = size.height / 2;
    for (double x = 0; x < size.width; x += _dash + _gap) {
      final end = x + _dash;
      canvas.drawLine(
        Offset(x, y),
        Offset(end > size.width ? size.width : end, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}
