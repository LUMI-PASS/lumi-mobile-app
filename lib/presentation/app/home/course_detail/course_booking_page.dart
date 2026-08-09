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

  /// Which age bracket to enrol at, for a FLAT course priced by more than one
  /// tier (`widget.level.id == null` — a level has its own single price, not
  /// tiers, so this stays null there). Defaults to the first tier, which the
  /// server already sends cheapest-first — the same one checkout would
  /// default to if none were named, so the price shown never disagrees with
  /// what an untouched picker would charge.
  CourseAgeTier? _selectedTier;

  bool get _hasAgeTierChoice =>
      widget.level.id == null && widget.level.ageTiers.length > 1;

  /// The price actually being charged: the picked tier once there is a
  /// choice to make, otherwise the level's own default price.
  num get _price => _selectedTier?.price ?? widget.level.coursePrice;

  bool get _isFree => _price <= 0;

  /// When this enrolment starts. Purely descriptive — picking a date here
  /// doesn't change which lessons are booked, the price, or seats; it's just
  /// saved on the order (`Order.starts_at`). Picked from the course's own
  /// upcoming lesson dates (`widget.level.courseLessons`) rather than an
  /// open calendar, so every choice is a real lesson day. Defaults to the
  /// first one, same as what checkout would default to if this were left
  /// unsent.
  DateTime? _selectedStartDate;

  @override
  void initState() {
    super.initState();
    if (_hasAgeTierChoice) _selectedTier = widget.level.ageTiers.first;
    if (widget.level.courseLessons.isNotEmpty) {
      _selectedStartDate =
          DateTime.tryParse(widget.level.courseLessons.first.date);
    }
    _loadLastPaymentMethod();
  }

  static String _isoDate(DateTime d) {
    String two(int v) => v < 10 ? '0$v' : '$v';
    return '${d.year}-${two(d.month)}-${two(d.day)}';
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
        ageFrom: _selectedTier?.ageFrom,
        ageTo: _selectedTier?.ageTo,
        startsAt:
            _selectedStartDate != null ? _isoDate(_selectedStartDate!) : null,
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
        _error = e is CheckoutFriendlyError
            ? e.message
            : courseCheckoutErrorMessage(e);
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
                padding: EdgeInsets.only(top: 16.h, bottom: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full-bleed, like the normal booking page's own date
                    // strip: it has its own horizontal padding so its chips
                    // scroll edge to edge, and sits right under the header
                    // rather than inside the rest of the form's padding.
                    _startDateSection(c),
                    16.kh,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionHeader(c, 'course_full_title'.tr()),
                          _courseCard(c),
                          if (_hasAgeTierChoice) ...[
                            20.kh,
                            _ageTierSection(c),
                          ],
                          if (widget.level.enrollment?.hasTrial == true) ...[
                            8.kh,
                            Text(
                              'course_upsell_body_short'.tr(),
                              style: AppText.regular12
                                  .copyWith(color: c.textMuted),
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
                colorFilter: ColorFilter.mode(c.textPrimary, BlendMode.srcIn),
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
            : 'book_pay_cta'.tr(args: [_price.toRawUzsPrice()]),
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
          colorFilter: ColorFilter.mode(c.textPrimary, BlendMode.srcIn),
        ),
      ),
      child: PillCaption(
        captionFirst: true,
        title: level.name ?? widget.courseTitle,
        subtitle: widget.branchTitle,
      ),
      trailing: PillActionChip(label: _price.toRawUzsPrice()),
    );
  }

  // "Yoshni tanlang" — single-select age-tier picker. Only shown for a FLAT
  // course priced by more than one tier (`_hasAgeTierChoice`); a level has
  // its own single price, so this never renders alongside a level purchase.
  // Unlike a normal activity's ticket rows (+/- quantity per tier), this is
  // pick-exactly-one, the same shape as choosing a level.
  Widget _ageTierSection(AppColorScheme c) {
    final tiers = widget.level.ageTiers;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(c, 'course_choose_age_title'.tr()),
        Column(
          children: [
            for (final tier in tiers) ...[
              if (tier != tiers.first) 8.kh,
              PillCard(
                onTap: () => setState(() => _selectedTier = tier),
                leading: PillIconBadge(
                  child: _radio(identical(_selectedTier, tier)),
                ),
                child: PillCaption(
                  title: '${tier.rangeLabel} ${'age_years_suffix'.tr()}',
                ),
                trailing: PillActionChip(label: tier.price.toRawUzsPrice()),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // "Boshlanish sanasi" — optional start date, picked from the course's own
  // upcoming lesson dates so every choice is a real lesson day. Purely
  // descriptive (see _selectedStartDate): picking one never changes which
  // lessons are booked, the price, or seats, it's just saved on the order.
  // Mirrors the normal booking page's own date strip exactly — same bare
  // placement right under the header, no label, no fixed height (a fixed
  // height is what overflowed here originally: the chip is three lines of
  // text whose height moves with the user's text-scale factor). Duplicated
  // locally rather than shared, since that strip is tightly coupled to
  // per-session slot fetching this screen has no use for.
  Widget _startDateSection(AppColorScheme c) {
    final lessons = widget.level.courseLessons;
    if (lessons.isEmpty) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        children: [
          for (var i = 0; i < lessons.length; i++) ...[
            if (i > 0) 4.kw,
            _startDateChip(lessons[i]),
          ],
        ],
      ),
    );
  }

  Widget _startDateChip(CourseLesson lesson) {
    final date = DateTime.tryParse(lesson.date);
    if (date == null) return const SizedBox.shrink();
    final isSelected = _selectedStartDate != null &&
        _isoDate(_selectedStartDate!) == lesson.date;
    final dayColor = context.colors.textPrimary;
    final mutedColor = context.colors.textSecondary;
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('weekday_short_${date.weekday}'.tr(),
            style: AppText.regular12.copyWith(color: mutedColor)),
        4.kh,
        Text('${date.day}',
            style: AppText.bold18.copyWith(color: dayColor, height: 1.0)),
        4.kh,
        Text('month_short_${date.month}'.tr(),
            style: AppText.regular12.copyWith(color: mutedColor)),
      ],
    );
    final padding = EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w);
    return SizedBox(
      width: 48.w,
      child: isSelected
          ? FrostedCard(
              onTap: () => setState(() => _selectedStartDate = date),
              padding: padding,
              borderRadius: BorderRadius.circular(56.r),
              child: content,
            )
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _selectedStartDate = date),
              child: Padding(padding: padding, child: content),
            ),
    );
  }

  /// Hollow ring, or a filled green disc with a white tick once picked —
  /// same shape as the payment-method chooser's own radio dot.
  Widget _radio(bool selected) {
    if (selected) {
      return Container(
        width: 16.w,
        height: 16.w,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.tagGreen,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.check_rounded, size: 11.sp, color: AppColors.onBrand),
      );
    }
    return Container(
      width: 16.w,
      height: 16.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: context.colors.textSecondary),
      ),
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
            titleColor: payment == null ? c.textSecondary : null,
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
          colorFilter:
              ColorFilter.mode(context.colors.textPrimary, BlendMode.srcIn),
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
                  style: AppText.semibold16.copyWith(color: c.textPrimary)),
            ],
          ),
          16.kh,
          Row(
            children: [
              Assets.icons.detail.iconsaxReceipt.svg(
                width: 20.w,
                height: 20.w,
                colorFilter: ColorFilter.mode(c.textSecondary, BlendMode.srcIn),
              ),
              8.kw,
              Expanded(
                child: Text(
                  'course_lessons_count'.tr(
                    namedArgs: {'count': '${level.courseLessons.length}'},
                  ),
                  style: AppText.regular14.copyWith(color: c.textSecondary),
                ),
              ),
              Text(
                _price.toRawUzsPrice(),
                style: AppText.semibold14.copyWith(color: c.textPrimary),
              ),
            ],
          ),
          16.kh,
          Row(
            children: [
              Expanded(
                child: Text('book_grand_total'.tr(),
                    style: AppText.bold18.copyWith(color: c.textSecondary)),
              ),
              Text(_price.toRawUzsPrice(),
                  style: AppText.bold18.copyWith(color: c.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }
}
