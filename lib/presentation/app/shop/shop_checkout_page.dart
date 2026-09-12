import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/image_url.dart';
import 'package:lumi_pass/common/utils/card_input_formatters.dart';
import 'package:lumi_pass/common/utils/multi_lang.dart';
import 'package:lumi_pass/common/utils/payment_error.dart';
import 'package:lumi_pass/common/widget/app_text_field.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/common/widget/coin_amount.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';
import 'package:lumi_pass/data/api_model/order/order_model.dart';
import 'package:lumi_pass/data/api_model/shop/shop_cart.dart';
import 'package:lumi_pass/data/api_model/wallet/wallet_balance.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:lumi_pass/domain/repo/shop/shop_repository.dart';
import 'package:lumi_pass/domain/repo/wallet/wallet_repository.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/widgets/paycom_checkout_page.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/widgets/payment_sheets.dart';
import 'package:lumi_pass/presentation/app/shop/cubit/cart_cubit.dart';
import 'package:lumi_pass/presentation/app/shop/shop_delivery_point_page.dart';

/// Buying merch: where it goes, how it is paid for, and then the same payment
/// machinery a booking uses.
///
/// Nothing about the payment tail is new here. The rail chooser, the card OTP
/// sheet, the gateway webview and the wallet toggle are the booking screen's,
/// and the server answers a merch checkout with the same `CheckoutResult` a
/// booking gets — which is what makes that reuse honest rather than a
/// coincidence worth copying.
///
/// The one thing merch does that a booking cannot: coins may cover the WHOLE
/// order. There is no partner share to protect, so a fully-coin purchase never
/// opens a gateway at all and comes back already paid.
/// Re-provides the basket, then hands off to [_CheckoutView].
///
/// The cubit is a getIt singleton, so this is the same basket the shop shell
/// shows — but a PUSHED route is a sibling of [ShopPage] in the navigator, not
/// a descendant of it, so the shell's `BlocProvider` is not an ancestor here
/// and `context.read<CartCubit>()` threw. Providing `.value` puts it back in
/// scope without forking the basket in two.
@RoutePage()
class ShopCheckoutPage extends StatelessWidget {
  const ShopCheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CartCubit>.value(
      value: getIt<CartCubit>(),
      child: const _CheckoutView(),
    );
  }
}

class _CheckoutView extends StatefulWidget {
  const _CheckoutView();

  @override
  State<_CheckoutView> createState() => _ShopCheckoutPageState();
}

class _ShopCheckoutPageState extends State<_CheckoutView> {
  final _phone = TextEditingController();
  final _name = TextEditingController();
  final _comment = TextEditingController();

  WalletBalance? _wallet;

  /// Which of the basket's two prices is being paid. Not a toggle over a
  /// single price: coins and money are separate prices with no rate between
  /// them, so this picks one of two bills rather than splitting one.
  bool _withCoins = false;
  PaymentSelection? _payment;

  double? _lat;
  double? _lng;
  String _address = '';

  bool _submitting = false;
  String? _error;

  /// The basket, read once per build from the shared cubit.
  ShopCart get _cart => context.read<CartCubit>().state;

  /// A preview only. The server re-prices the basket when it creates the
  /// order, and the response is what is actually charged — which is why
  /// neither of these is ever sent anywhere.
  num get _total => _cart.total;

  /// The same basket, priced in coins. Unrelated to [_total].
  num get _coinTotal => _cart.coinTotal;

  num get _available => _wallet?.available ?? 0;

  /// Whether the wallet covers the WHOLE coin bill. There is no rate, so a
  /// wallet that falls short cannot be topped up with money on this order —
  /// it is coins or it is money.
  bool get _coinsAffordable =>
      _coinTotal > 0 && _available >= _coinTotal && !(_wallet?.isFrozen ?? false);

  /// Paying with coins opens no gateway at all, so there is no rail to pick.
  bool get _fullyCoinFunded => _withCoins;

  bool get _canPay =>
      !_submitting &&
      _lat != null &&
      _address.trim().length >= 5 &&
      _phone.text.trim().length >= 7 &&
      (_withCoins
          ? _coinsAffordable
          : _payment == null || _payment!.isPayable);

  @override
  void initState() {
    super.initState();
    _prefill();
  }

  @override
  void dispose() {
    _phone.dispose();
    _name.dispose();
    _comment.dispose();
    super.dispose();
  }

  /// The account's own phone and name, as a starting point.
  ///
  /// A starting point and not a lock: a parent often has merch delivered to
  /// somebody else's number, so both fields stay editable.
  Future<void> _prefill() async {
    try {
      final storage = getIt<Storage>();
      final phone = storage.userPhone.call();
      if (phone != null && phone.isNotEmpty) _phone.text = phone;
    } catch (_) {
      // No stored profile — the buyer types it.
    }

    try {
      final wallet = await getIt<WalletRepository>().getWallet();
      if (!mounted) return;
      setState(() => _wallet = wallet);
    } catch (_) {
      // No balance means no coin toggle, which is the safe direction: offering
      // a balance we cannot confirm and then being refused at checkout is
      // worse than not offering one.
    }
  }

  Future<void> _pickPoint() async {
    final result = await context.router.push<DeliveryPointResult>(
      ShopDeliveryPointRoute(
        initialLat: _lat,
        initialLng: _lng,
        initialAddress: _address.isEmpty ? null : _address,
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _lat = result.lat;
      _lng = result.lng;
      _address = result.address;
    });
  }

  Future<void> _openChooser() async {
    final selection = await showPaymentChooser(
      context,
      initial: _payment,
      cards: _payment?.card != null ? [_payment!.card!] : const [],
      cardsComingSoon: !kCardPaymentsEnabled,
    );
    if (selection != null && mounted) {
      setState(() => _payment = selection);
    }
  }

  Future<CheckoutResult> _runCheckout({
    String? provider,
    String? cardNumber,
    String? expireDate,
    String? savedCardId,
  }) {
    return getIt<ShopRepository>().checkout(
      items: _cart.toCheckoutItems(),
      lat: _lat!,
      lng: _lng!,
      address: _address.trim(),
      contactName: _name.text.trim(),
      contactPhone: _phone.text.trim(),
      comment: _comment.text.trim(),
      payWith: _withCoins ? 'coins' : 'money',
      paymentProvider: provider,
      cardNumber: cardNumber,
      expireDate: expireDate,
      savedCardId: savedCardId,
      lang: context.locale.languageCode,
    );
  }

  /// The order is paid. Empty the basket — it has become an order — and land
  /// on the orders tab, which explains what happens next.
  void _completePaid(CheckoutResult result) {
    if (!mounted) return;
    context.read<CartCubit>().clear();
    context.router.replace(ShopRoute(initialTab: 2, justPaid: true));
  }

  Future<void> _pay() async {
    // Coins cover it all: no rail to pick and no gateway to open. The server
    // marks the order paid on the spot and mints the delivery order.
    if (_fullyCoinFunded) {
      await _payWithCoinsOnly();
      return;
    }

    if (_payment == null) {
      await _openChooser();
      if (!mounted || _payment == null) return;
    }
    final payment = _payment!;
    final card = payment.card;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      // A bound card: create the PENDING order, then charge the token. Still an
      // OTP — the rail has nothing that would let us skip it.
      if (card != null && card.isSaved) {
        final order = await _runCheckout(savedCardId: card.savedCardId);
        final charge = await getIt<OrdersApi>().payOrderWithSavedCard(
          orderId: order.orderId,
          cardId: card.savedCardId!,
        );
        if (!mounted) return;
        setState(() => _submitting = false);
        if (!charge.otpRequired) {
          _completePaid(order);
          return;
        }
        final paid = await showCardOtpSheet(
          context,
          transactionId: charge.transactionId ?? '',
          cid: charge.cid ?? '',
          otpSentPhone: charge.otpSentPhone,
          confirmCard: ({
            required String transactionId,
            required String cid,
            required String otp,
          }) =>
              getIt<OrdersApi>().paylovConfirmCard(
            transactionId: transactionId,
            cid: cid,
            otp: otp,
          ),
        );
        if (paid == true && mounted) _completePaid(order);
        return;
      }

      final result = await _runCheckout(
        provider: payment.rail.providerKey,
        cardNumber: card?.pan,
        // MM/YY as typed → YYMM, which is what WLCM wants. The shared
        // converter, not a local copy: the booking screen learned the hard way
        // that "3003" can only be YY=30 MM=03.
        expireDate: card == null ? null : expiryToYyMm(card.expiry),
      );
      if (!mounted) return;
      setState(() => _submitting = false);

      if (result.isCardOtpPending) {
        final paid = await showCardOtpSheet(
          context,
          transactionId: result.transactionId ?? '',
          cid: result.cid ?? '',
          otpSentPhone: result.otpSentPhone,
          confirmCard: ({
            required String transactionId,
            required String cid,
            required String otp,
          }) =>
              getIt<OrdersApi>().paylovConfirmCard(
            transactionId: transactionId,
            cid: cid,
            otp: otp,
          ),
        );
        if (paid == true && mounted) _completePaid(result);
      } else if (result.checkoutUrl.isNotEmpty) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PaycomCheckoutPage(
              result: result,
              provider: payment.rail.providerKey,
              walletApplied: result.walletAmount,
            ),
          ),
        );
        if (mounted) _completePaid(result);
      } else {
        setState(() => _error = 'pay_generic_error'.tr());
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = PaymentError.fromDio(e) ?? 'pay_generic_error'.tr();
      });
    }
  }

  Future<void> _payWithCoinsOnly() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final result = await _runCheckout();
      if (!mounted) return;
      setState(() => _submitting = false);
      _completePaid(result);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = PaymentError.fromDio(e) ?? 'pay_generic_error'.tr();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: BaseAppBar(title: 'shop_checkout_title'.tr()),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
        children: [
          // ── What is being bought ──────────────────────────────────────────
          for (final line in _cart.lines) ...[
            FrostedCard(
              borderRadius: BorderRadius.circular(16.r),
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: SizedBox(
                      width: 56.w,
                      height: 56.w,
                      child: sanitizeImageUrl(line.product.image) == null
                          ? Container(color: c.surface)
                          : CachedNetworkImage(
                              imageUrl: sanitizeImageUrl(line.product.image)!,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) =>
                                  Container(color: c.surface),
                            ),
                    ),
                  ),
                  12.kw,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          multiLang(line.product.name),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.semibold14
                              .copyWith(color: c.textPrimary),
                        ),
                        4.kh,
                        Text(
                          '${line.product.price.toRawUzsPrice()} × ${line.count}',
                          style: AppText.regular12
                              .copyWith(color: c.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    line.lineTotal.toRawUzsPrice(),
                    style: AppText.semibold14.copyWith(color: c.textPrimary),
                  ),
                ],
              ),
            ),
            12.kh,
          ],

          20.kh,
          _SectionTitle('shop_delivery_title'.tr()),
          8.kh,
          Text(
            'shop_delivery_promise'.tr(),
            style: AppText.regular12.copyWith(color: c.textSecondary),
          ),
          12.kh,

          GestureDetector(
            onTap: _pickPoint,
            child: FrostedCard(
              borderRadius: BorderRadius.circular(16.r),
              padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 20.w,
                    color: _address.isEmpty
                        ? c.textSecondary
                        : AppColors.brandPurple,
                  ),
                  10.kw,
                  Expanded(
                    child: Text(
                      _address.isEmpty
                          ? 'shop_pick_on_map'.tr()
                          : _address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.medium14.copyWith(
                        color: _address.isEmpty
                            ? c.textSecondary
                            : c.textPrimary,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right,
                      color: c.textSecondary, size: 20.w),
                ],
              ),
            ),
          ),

          12.kh,
          AppTextField(
            controller: _name,
            label: 'shop_contact_name'.tr(),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
          ),
          12.kh,
          AppTextField(
            controller: _phone,
            label: 'shop_contact_phone'.tr(),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            showClearButton: true,
            onChanged: (_) => setState(() {}),
          ),
          6.kh,
          // The hint sits under the field rather than in Material's helperText
          // slot, which this field does not have — and which would have been
          // styled as an error anyway.
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text(
              'shop_contact_phone_hint'.tr(),
              style: AppText.regular12.copyWith(color: c.textSecondary),
            ),
          ),
          12.kh,
          AppTextField(
            controller: _comment,
            label: 'shop_courier_note'.tr(),
            maxLines: 3,
            minLines: 1,
          ),

          20.kh,
          _SectionTitle('shop_payment_title'.tr()),
          12.kh,

          _PayWithSwitch(
            withCoins: _withCoins,
            moneyTotal: _total,
            coinTotal: _coinTotal,
            available: _available,
            coinsAffordable: _coinsAffordable,
            enabled: !_submitting,
            onChanged: (coins) => setState(() => _withCoins = coins),
          ),

          // A rail only has to be chosen when there is something left to
          // charge. Asking a buyer whose coins already cover the order to pick
          // a bank is asking a question with no consequence.
          if (!_fullyCoinFunded) ...[
            12.kh,
            GestureDetector(
              onTap: _submitting ? null : _openChooser,
              child: FrostedCard(
                borderRadius: BorderRadius.circular(16.r),
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _payment == null
                            ? 'shop_choose_payment'.tr()
                            : (_payment!.card?.label ??
                                _payment!.rail.brandName),
                        style: AppText.medium14.copyWith(
                          color: _payment == null
                              ? c.textSecondary
                              : c.textPrimary,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        color: c.textSecondary, size: 20.w),
                  ],
                ),
              ),
            ),
          ],

          20.kh,
          // One total, in the unit actually being charged. Showing both here
          // would be the one place a buyer might try to add them together.
          if (_withCoins)
            Row(
              children: [
                Expanded(
                  child: Text(
                    'shop_total'.tr(),
                    style: AppText.semibold16.copyWith(color: c.textPrimary),
                  ),
                ),
                CoinAmount(
                  amount: _coinTotal,
                  style: AppText.bold18,
                  color: AppColors.brandPurple,
                  iconSize: 20,
                ),
              ],
            )
          else
            _TotalRow(
              label: 'shop_total'.tr(),
              value: _total.toRawUzsPrice(),
              strong: true,
            ),

          if (_error != null) ...[
            16.kh,
            Text(
              _error!,
              style: AppText.regular13.copyWith(color: AppColors.error),
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
        child: SizedBox(
          height: 52.h,
          child: ElevatedButton(
            onPressed: _canPay ? _pay : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandPurple,
              disabledBackgroundColor: context.colors.disabled,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
            child: _submitting
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    // The button says the amount in the unit being charged —
                    // coins have no so'm figure to quote.
                    _withCoins
                        ? 'shop_pay'.tr(args: [_coinTotal.toGrouped()])
                        : 'shop_pay'.tr(args: [_total.toRawUzsPrice()]),
                    style: AppText.semibold16
                        .copyWith(color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style:
            AppText.semibold16.copyWith(color: context.colors.textPrimary),
      );
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: (strong ? AppText.semibold14 : AppText.regular13)
                .copyWith(color: strong ? c.textPrimary : c.textSecondary),
          ),
        ),
        Text(
          value,
          style: (strong ? AppText.semibold16 : AppText.regular13)
              .copyWith(color: c.textPrimary),
        ),
      ],
    );
  }
}

/// Coins or money — two prices for the same basket, one of which will be paid.
///
/// Two cards rather than a switch, because a switch implies a single bill with
/// something subtracted from it, and that is exactly the mental model this
/// screen must NOT create. Each card carries its own total in its own unit, so
/// the choice reads as "this bill or that bill".
///
/// The coin card goes dead when the wallet cannot cover the whole coin price.
/// There is no rate between the two prices, so a short wallet cannot be topped
/// up with money here — the card says how short it is instead of offering a
/// part-payment that does not exist.
class _PayWithSwitch extends StatelessWidget {
  const _PayWithSwitch({
    required this.withCoins,
    required this.moneyTotal,
    required this.coinTotal,
    required this.available,
    required this.coinsAffordable,
    required this.enabled,
    required this.onChanged,
  });

  final bool withCoins;
  final num moneyTotal;
  final num coinTotal;
  final num available;
  final bool coinsAffordable;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Column(
      children: [
        _Option(
          selected: !withCoins,
          enabled: enabled,
          onTap: () => onChanged(false),
          title: 'shop_pay_with_money'.tr(),
          trailing: Text(
            moneyTotal.toRawUzsPrice(),
            style: AppText.semibold14.copyWith(color: c.textPrimary),
          ),
        ),
        10.kh,
        _Option(
          selected: withCoins,
          enabled: enabled && coinsAffordable,
          onTap: () => onChanged(true),
          title: 'shop_pay_with_coins'.tr(),
          subtitle: coinsAffordable
              ? null
              : 'shop_coins_short'.tr(args: [
                  (coinTotal - available).clamp(0, coinTotal).toGrouped(),
                ]),
          trailing: CoinAmount(
            amount: coinTotal,
            style: AppText.semibold14,
            color: coinsAffordable ? c.textPrimary : c.textMuted,
          ),
        ),
      ],
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.selected,
    required this.enabled,
    required this.onTap,
    required this.title,
    required this.trailing,
    this.subtitle,
  });

  final bool selected;
  final bool enabled;
  final VoidCallback onTap;
  final String title;
  final Widget trailing;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.55,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: selected ? AppColors.brandPurple : c.border,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 20.w,
                color: selected ? AppColors.brandPurple : c.textPlaceholder,
              ),
              10.kw,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppText.medium14.copyWith(color: c.textPrimary),
                    ),
                    if (subtitle != null) ...[
                      2.kh,
                      Text(
                        subtitle!,
                        style: AppText.regular12
                            .copyWith(color: AppColors.warning),
                      ),
                    ],
                  ],
                ),
              ),
              8.kw,
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
