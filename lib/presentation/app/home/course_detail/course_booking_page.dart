import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:lumi_pass/common/env/runtime_env.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/auth/gradient_button.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';
import 'package:lumi_pass/common/widget/pill_card.dart';
import 'package:lumi_pass/data/api_model/order/order_model.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/courses/courses_api.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/widgets/paycom_checkout_page.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/widgets/payment_sheets.dart';
import 'package:lumi_pass/presentation/app/home/course_detail/course_purchase.dart';

/// "Buy the course" — the review-and-pay screen for a whole course or a
/// levelled subcourse.
///
/// Trial lessons are NOT bought here: they're sold one at a time, by date,
/// straight from the calendar on the course detail page — there's nothing
/// left to review once the dates are picked. This screen only ever charges
/// [CoursePurchaseOption.full].
///
/// Pops `true` once the purchase went through (paid in-app, or the buyer came
/// back from the payment-gateway redirect) so the caller knows to reload the
/// course and reflect the new enrolment; pops nothing/`false` otherwise.
@RoutePage()
class CourseBookingPage extends StatefulWidget {
  const CourseBookingPage({
    super.key,
    required this.activityId,
    required this.level,
    required this.courseTitle,
    this.branchTitle,
  });

  final String activityId;
  final CourseLevel level;

  /// The course's own name — shown when [level] has none (a course sold flat,
  /// not as levels).
  final String courseTitle;
  final String? branchTitle;

  @override
  State<CourseBookingPage> createState() => _CourseBookingPageState();
}

class _CourseBookingPageState extends State<CourseBookingPage> {
  PaymentSelection? _payment;
  final List<PaymentCard> _cards = [];
  bool _submitting = false;
  String? _error;

  bool get _isFree => widget.level.coursePrice <= 0;

  @override
  void initState() {
    super.initState();
    _loadLastPaymentMethod();
  }

  Future<void> _loadLastPaymentMethod() async {
    final storage = getIt<Storage>();
    final railKey = storage.lastPaymentRail();
    if (railKey == null || railKey.isEmpty) return;
    PaymentRail? rail;
    for (final r in PaymentRail.values) {
      if (r.name == railKey) {
        rail = r;
        break;
      }
    }
    if (rail == null) return;
    if (rail != PaymentRail.card) {
      if (mounted) setState(() => _payment = PaymentSelection(rail: rail!));
      return;
    }
    final savedId = storage.lastSavedCardId();
    if (savedId == null || savedId.isEmpty) return;
    try {
      final cards = await getIt<OrdersApi>().getSavedCards();
      for (final c in cards) {
        if (c.cardId == savedId) {
          if (mounted) {
            setState(() {
              final pc = PaymentCard.saved(c);
              _payment = PaymentSelection(rail: PaymentRail.card, card: pc);
              if (!_cards.contains(pc)) _cards.add(pc);
            });
          }
          return;
        }
      }
    } catch (_) {
      // Non-fatal — the buyer can pick a method manually.
    }
  }

  void _persistPaymentMethod(PaymentSelection sel) {
    final storage = getIt<Storage>();
    storage.lastPaymentRail.set(sel.rail.name);
    storage.lastSavedCardId.set(sel.card?.savedCardId);
  }

  /// Creates the order for this level. Throws a [CheckoutFriendlyError]
  /// carrying a message safe to show the buyer.
  Future<CheckoutResult> _runCheckout({
    String? provider,
    String? cardNumber,
    String? expireDate,
    String? savedCardId,
  }) async {
    final isRedirect = provider != null && provider != 'card';
    try {
      return await getIt<CoursesApi>().checkout(
        activityId: widget.activityId,
        option: CoursePurchaseOption.full,
        subcourseId: widget.level.id,
        lang: context.locale.languageCode,
        paymentProvider: savedCardId != null ? null : provider,
        returnUrl: isRedirect ? '${RuntimeEnv.baseUrl}paylov/return' : null,
        cardNumber: cardNumber,
        expireDate: expireDate,
        savedCardId: savedCardId,
      );
    } catch (e) {
      throw CheckoutFriendlyError(courseCheckoutErrorMessage(e));
    }
  }

  static String? _toYyMm(String? expiry) {
    if (expiry == null) return null;
    final digits = expiry.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != 4) return expiry;
    return digits.substring(2, 4) + digits.substring(0, 2);
  }

  /// Redirect rails (Payme, Click/Uzum via Paylov): open the gateway page and,
  /// once the buyer comes back, close this screen too — same shape as the
  /// booking flow, just without its own success screen.
  Future<void> _completeRedirect(CheckoutResult result) async {
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaycomCheckoutPage(
          result: result,
          provider: _payment?.rail.name ?? PaymentRail.card.name,
        ),
      ),
    );
    if (mounted) Navigator.of(context).pop(true);
  }

  void _completePaid() {
    if (mounted) Navigator.of(context).pop(true);
  }

  /// Charges a card typed into the chooser sheet, without closing it first —
  /// mirrors the ticket-booking flow's own [CardSubmitted] handler.
  Future<String?> _payWithEnteredCard(PaymentCard card) async {
    try {
      if (card.savedCardId != null) {
        final order = await _runCheckout(savedCardId: card.savedCardId);
        if (!mounted) return null;
        final paid = await getIt<OrdersApi>().payOrderWithSavedCard(
          orderId: order.orderId,
          cardId: card.savedCardId!,
        );
        if (!mounted) return null;
        if (paid.success) {
          _completePaid();
          return null;
        }
        return paid.message ?? 'pay_generic_error'.tr();
      }

      final result = await _runCheckout(
        provider: PaymentRail.card.providerKey,
        cardNumber: card.pan,
        expireDate: _toYyMm(card.expiry),
      );
      if (!mounted) return null;

      if (result.isCardOtpPending) {
        final paid = await showCardOtpSheet(
          context,
          checkout: result,
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
        if (paid == true && mounted) _completePaid();
        return null;
      }
      if (result.checkoutUrl.isNotEmpty) {
        await _completeRedirect(result);
        return null;
      }
      return result.paylovMessage ?? 'pay_generic_error'.tr();
    } on CheckoutFriendlyError catch (e) {
      return e.message;
    } catch (e) {
      return courseCheckoutErrorMessage(e);
    }
  }

  Future<void> _openChooser() async {
    final picked = await showPaymentChooser(
      context,
      initial: _payment,
      cards: _cards,
      onCardSubmitted: _payWithEnteredCard,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _payment = picked;
      final card = picked.card;
      if (card != null && !_cards.contains(card)) _cards.add(card);
      _error = null;
    });
    _persistPaymentMethod(picked);
  }

  Future<void> _pay() async {
    if (_submitting) return;

    // Fully discounted / free levels have nothing to charge, so there's no
    // method to pick — just create the order.
    if (_isFree) {
      setState(() {
        _submitting = true;
        _error = null;
      });
      try {
        await _runCheckout();
        if (!mounted) return;
        _completePaid();
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _submitting = false;
          _error = e is CheckoutFriendlyError
              ? e.message
              : courseCheckoutErrorMessage(e);
        });
      }
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
      if (card != null && card.isSaved) {
        final order = await _runCheckout(savedCardId: card.savedCardId);
        final paid = await getIt<OrdersApi>().payOrderWithSavedCard(
          orderId: order.orderId,
          cardId: card.savedCardId!,
        );
        if (!mounted) return;
        if (paid.success) {
          _completePaid();
        } else {
          setState(() {
            _submitting = false;
            _error = paid.message ?? 'pay_generic_error'.tr();
          });
        }
        return;
      }

      final result = await _runCheckout(
        provider: payment.rail.providerKey,
        cardNumber: card?.pan,
        expireDate: _toYyMm(card?.expiry),
      );
      if (!mounted) return;
      setState(() => _submitting = false);

      if (result.isCardOtpPending) {
        final paid = await showCardOtpSheet(
          context,
          checkout: result,
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
        if (paid == true && mounted) _completePaid();
      } else if (result.checkoutUrl.isNotEmpty) {
        await _completeRedirect(result);
      } else {
        setState(
            () => _error = result.paylovMessage ?? 'pay_generic_error'.tr());
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error =
            e is CheckoutFriendlyError ? e.message : courseCheckoutErrorMessage(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.canvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(c),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w).copyWith(
                  top: 16.h,
                  bottom: 24.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(c, 'course_full_title'.tr()),
                    _courseCard(c),
                    if (widget.level.enrollment?.hasTrial == true) ...[
                      8.kh,
                      Text(
                        'course_upsell_body_short'.tr(),
                        style: AppText.regular12.copyWith(color: c.textMuted),
                      ),
                    ],
                    if (!_isFree) ...[
                      20.kh,
                      _paymentMethodRow(c),
                    ],
                    20.kh,
                    _breakdownSection(c),
                    if (_error != null) ...[
                      12.kh,
                      Text(_error!,
                          style: AppText.regular12
                              .copyWith(color: AppColors.error)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomBar(c),
    );
  }

  Widget _header(AppColorScheme c) => Padding(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
        child: Row(
          children: [
            FrostedCard(
              onTap: () => Navigator.of(context).maybePop(),
              padding: EdgeInsets.all(8.w),
              child: Assets.icons.detail.arrow.svg(
                width: 16.w,
                height: 16.w,
                colorFilter:
                    const ColorFilter.mode(AppColors.ink, BlendMode.srcIn),
              ),
            ),
            Expanded(
              child: Text(
                'course_buy_cta'.tr(),
                textAlign: TextAlign.center,
                style: AppText.medium16.copyWith(color: c.textPrimary),
              ),
            ),
            SizedBox(width: 32.w),
          ],
        ),
      );

  Widget? _bottomBar(AppColorScheme c) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      color: c.scaffoldBg,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h + bottomInset),
      child: GradientButton(
        text: _isFree
            ? 'book_free_cta'.tr()
            : 'book_pay_cta'
                .tr(args: [widget.level.coursePrice.toRawUzsPrice()]),
        loading: _submitting,
        onPressed: _pay,
      ),
    );
  }

  Widget _sectionHeader(AppColorScheme c, String title) => Padding(
        padding: EdgeInsets.only(left: 8.w, bottom: 14.h),
        child: Text(title,
            style: AppText.semibold14.copyWith(color: c.textSecondary)),
      );

  // "Butun kurs" — what's being bought, and for how much.
  Widget _courseCard(AppColorScheme c) {
    final level = widget.level;
    return PillCard(
      leading: PillIconBadge(
        child: Assets.icons.detail.iconsaxReceipt.svg(
          width: 20.w,
          height: 20.w,
          colorFilter: const ColorFilter.mode(AppColors.ink, BlendMode.srcIn),
        ),
      ),
      child: PillCaption(
        captionFirst: true,
        title: level.name ?? widget.courseTitle,
        subtitle: widget.branchTitle,
      ),
      trailing: PillActionChip(label: level.coursePrice.toRawUzsPrice()),
    );
  }

  Widget _paymentMethodRow(AppColorScheme c) {
    final payment = _payment;
    final card = payment?.card;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(c, 'book_payment_method'.tr()),
        PillCard(
          onTap: _openChooser,
          leading: PillIconBadge(child: _paymentLeading(payment)),
          child: PillCaption(
            title: payment == null
                ? 'book_pick_payment'.tr()
                : (card?.label ?? payment.rail.brandName),
            subtitle: 'book_pay_method_label'.tr(),
            captionFirst: true,
            titleColor: payment == null ? AppColors.greeting : null,
          ),
          trailing: PillActionChip(
            label: payment == null ? 'book_choose'.tr() : 'book_change'.tr(),
            onTap: _openChooser,
          ),
        ),
      ],
    );
  }

  Widget _paymentLeading(PaymentSelection? payment) {
    final card = payment?.card;
    if (card != null) {
      return CardArtwork(brand: card.brand, width: 30, height: 20);
    }
    switch (payment?.rail) {
      case PaymentRail.payme:
        return Assets.images.pay.paymeLogo.image(width: 22.w, height: 22.w);
      case PaymentRail.click:
        return Assets.images.pay.clickLogo.image(width: 22.w, height: 22.w);
      case PaymentRail.uzum:
        return Assets.images.pay.uzumLogo.image(width: 22.w, height: 22.w);
      case PaymentRail.card:
      case null:
        return Assets.icons.icCard.svg(
          width: 20.w,
          height: 20.w,
          colorFilter: const ColorFilter.mode(AppColors.ink, BlendMode.srcIn),
        );
    }
  }

  // "Hisob" — the frosted price-breakdown card.
  Widget _breakdownSection(AppColorScheme c) {
    final level = widget.level;
    return FrostedCard(
      borderWidth: 2,
      borderRadius: BorderRadius.circular(12.r),
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
                child: Assets.icons.detail.iconsaxReceipt.svg(
                  width: 14.w,
                  height: 14.w,
                  colorFilter: const ColorFilter.mode(
                      AppColors.onBrand, BlendMode.srcIn),
                ),
              ),
              6.kw,
              Text('book_payment_summary'.tr(),
                  style: AppText.semibold16.copyWith(color: AppColors.ink)),
            ],
          ),
          16.kh,
          Row(
            children: [
              Assets.icons.detail.iconsaxReceipt.svg(
                width: 20.w,
                height: 20.w,
                colorFilter: const ColorFilter.mode(
                    AppColors.greeting, BlendMode.srcIn),
              ),
              8.kw,
              Expanded(
                child: Text(
                  'course_lessons_count'.tr(
                    namedArgs: {'count': '${level.courseLessons.length}'},
                  ),
                  style:
                      AppText.regular14.copyWith(color: AppColors.inkMuted),
                ),
              ),
              Text(
                level.coursePrice.toRawUzsPrice(),
                style: AppText.semibold14.copyWith(color: AppColors.ink),
              ),
            ],
          ),
          16.kh,
          Row(
            children: [
              Expanded(
                child: Text('book_grand_total'.tr(),
                    style: AppText.bold18.copyWith(color: AppColors.inkMuted)),
              ),
              Text(level.coursePrice.toRawUzsPrice(),
                  style: AppText.bold18.copyWith(color: AppColors.ink)),
            ],
          ),
        ],
      ),
    );
  }
}
