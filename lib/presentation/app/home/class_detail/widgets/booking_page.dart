import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/utils/coupon_discount.dart';
import 'package:lumi_pass/common/utils/payment_error.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/env/runtime_env.dart';
import 'package:lumi_pass/common/utils/catalog_revision.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';
import 'package:lumi_pass/common/widget/pill_card.dart';
import 'package:lumi_pass/common/widget/shaker.dart';
import 'package:lumi_pass/common/widget/time_picker_sheet.dart';
import 'package:lumi_pass/data/api_model/class_full/class_full_model.dart';
import 'package:lumi_pass/data/api_model/order/order_model.dart';
import 'package:lumi_pass/data/api_model/order/promo_error_code.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/data/service/analytics_service.dart';
import 'package:lumi_pass/data/service/remote_config_service.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/auth/gradient_button.dart';
import 'package:lumi_pass/domain/repo/courses/courses_api.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:lumi_pass/presentation/app/cubit/app_cubit.dart';
import 'package:lumi_pass/presentation/app/cubit/app_state.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/widgets/paycom_checkout_page.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/widgets/payment_sheets.dart';
import 'package:lumi_pass/presentation/app/home/booking_complete/booking_complete_page.dart';

const _kLookaheadDays = 30;

String _isoDateStatic(DateTime d) {
  String two(int v) => v < 10 ? '0$v' : '$v';
  return '${d.year}-${two(d.month)}-${two(d.day)}';
}

/// "Buy tickets" — a full page, not a bottom sheet.
///
/// It used to be a `showModalBottomSheet` opened with `useSafeArea: false`, so
/// its own header slid under the notch / Dynamic Island. A booking is a
/// multi-section form with its own back navigation, so it belongs on the
/// router as a page with a real [SafeArea].
@RoutePage()
class BookingPage extends StatefulWidget {
  const BookingPage({
    super.key,
    required this.clazz,
    this.coursePrice,
    this.level,
    this.courseOption,
  });

  final ClassFullModel clazz;

  /// Which subcourse is being bought, on a course sold as subcourses. Null on a
  /// flat course (the whole thing is the product) and on a plain class.
  ///
  /// Also the source of the trial calendar: [CourseLevel.trialNextDates] is the
  /// set of upcoming days the backend will accept for the next trial lesson.
  final CourseLevel? level;

  /// Buying the whole course, or ONE trial lesson. Null means this isn't a
  /// course purchase at all.
  ///
  /// A trial changes what the date strip means: the days come from the course's
  /// own schedule rather than a rolling lookahead, and the day the buyer picks
  /// IS the lesson they are buying.
  final CoursePurchaseOption? courseOption;

  /// Set only for a course: the package price from `/courses/:id`, which the
  /// detail page already had. Null falls back to the class's own price, so a
  /// failed side fetch never blocks the sale.
  ///
  /// A course runs through this same page rather than one of its own — it just
  /// has nothing to pick, so the date strip, the ticket steppers, the slot
  /// picker and the promo field all drop out and what's left is the summary,
  /// the payment method and the total.
  final num? coursePrice;

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  // ageTiers mode: _tierCounts[tierIdx][durIdx] = count
  late final List<List<int>> _tierCounts;
  // legacy flat mode: _flatCounts[rangeIdx] = count
  late final List<int> _flatCounts;

  late final List<_AvailableDate> _availableDates;
  _AvailableDate? _selectedDate;
  ScheduleSlotInfo? _selectedSlot;
  bool _loadingSlots = false;
  bool _slotsLoaded = false;
  bool _submitting = false;

  /// The buyer's payment choice. Null until they pick one in the chooser sheet
  /// — paying is blocked until then.
  PaymentSelection? _payment;

  /// Cards offered in the chooser's card list — anything the buyer enters during
  /// this session. (Tokenized saved cards live in the profile card screen; they
  /// need the WLCM token-pay path before they can be charged from booking.)
  final List<PaymentCard> _cards = [];

  // Missing input is flagged by shaking the control itself, so each one the pay
  // CTA can block on is addressable.
  final _ticketShake = GlobalKey<ShakerState>();
  final _dateShake = GlobalKey<ShakerState>();
  final _timeShake = GlobalKey<ShakerState>();
  final _paymentShake = GlobalKey<ShakerState>();

  /// Gateway/network failures only. Validation never lands here — it shakes the
  /// offending control instead of printing a message at the bottom of the page.
  String? _error;

  // ─── Coupon discount ──────────────────────────────────────────────────────
  /// Whether the buyer owns an active coupon plan at all. Distinct from
  /// [_hasCoupon]: owning a plan is what locks promocodes out, even on a class
  /// the plan can't discount.
  ///
  /// Reads `AppCubit`'s live Cubit state, not a one-off `Storage` read, so this
  /// answers correctly the instant a purchase completes or a sync resolves.
  ///
  /// `read`, not `watch`: this getter is reached from [_pay] as well as from
  /// build, and `watch` outside a build throws
  /// ("Tried to listen to a value exposed with provider, from outside of the
  /// widget tree"). The rebuild is subscribed once in [build] instead.
  bool get _hasCouponPlan {
    final app = _appState;
    return app.hasPremium && app.planDiscountPercentage > 0;
  }

  AppBuildable get _appState =>
      context.read<AppCubit>().state.buildable ?? const AppBuildable();

  /// The coupon's percentage on THIS class. A coupon is funded from Lumi's
  /// share of the booking, so it is capped at that share (and is 0 on a class
  /// whose share is too thin to carry one) — exactly what checkout charges.
  num get _couponPct {
    final app = _appState;
    final plan = app.hasPremium ? app.planDiscountPercentage : 0;
    return effectiveCouponPercent(
      plan,
      widget.clazz.discountPercentage,
      isCourse: widget.clazz.isCourse,
    );
  }

  bool get _hasCoupon => _couponPct > 0;
  num _applyDiscount(num price) =>
      _hasCoupon ? (price * (100 - _couponPct) / 100).round() : price;
  num get _discountedTotal => _applyDiscount(_total);

  // ─── Promocode ─────────────────────────────────────────────────────────────
  // Coupon plans and promocodes never stack, so this whole block is hidden
  // (and never sent) whenever [_hasCouponPlan] is true. Only customers without
  // an active coupon plan can enter a promocode.
  final TextEditingController _promoCtrl = TextEditingController();
  PromocodePreview? _appliedPromo;
  bool _promoLoading = false;
  String? _promoError;

  num get _promoDiscount => _appliedPromo?.discountAmount ?? 0;

  /// The amount the user actually pays. A coupon plan and a promocode are
  /// mutually exclusive: the coupon plan auto-discounts (and hides the promo
  /// field); otherwise an applied promocode reduces the total.
  num get _payableTotal {
    if (_hasCouponPlan) return _discountedTotal;
    final t = _total - _promoDiscount;
    return t < 0 ? 0 : t;
  }

  /// A 100%-off order: a promocode reduced the payable total to zero for an
  /// order that actually has tickets. There's nothing to charge, so the order is
  /// still created but we skip payment-method selection and the checkout
  /// redirect — it goes straight to the success screen. Restricted to
  /// promocodes: a coupon plan that happens to hit 100% still runs the normal
  /// pay flow.
  /// A course has no tickets to count — a free trial IS the whole order — so
  /// the ticket test would keep the payment picker on screen while asking the
  /// buyer to choose a card for a lesson that costs nothing. What makes an
  /// order free is simply that there is nothing left to charge.
  bool get _isFree =>
      !_hasCouponPlan &&
      (_isCourse || _totalTickets > 0) &&
      _payableTotal == 0;

  /// Validate the entered code against the current subtotal and show a preview
  /// of the new total. The discount is re-checked server-side at checkout.
  Future<void> _applyPromo() async {
    final code = _promoCtrl.text.trim();
    if (code.isEmpty || _promoLoading) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _promoLoading = true;
      _promoError = null;
    });
    try {
      final preview = await getIt<OrdersApi>().validatePromocode(
        code: code,
        subtotal: _total,
        activityId: widget.clazz.id,
        count: _totalTickets,
      );
      if (!mounted) return;
      setState(() {
        _appliedPromo = preview;
        _promoLoading = false;
      });
    } on DioException catch (e) {
      final data = e.response?.data;
      if (!mounted) return;
      setState(() {
        _appliedPromo = null;
        _promoError = _promoErrorMessage(data);
        _promoLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _appliedPromo = null;
        _promoError = 'promo_invalid'.tr();
        _promoLoading = false;
      });
    }
  }

  /// Turns a backend promocode error into a localized, user-facing message.
  /// Known structured errors (tagged with an `error_code`) are localized here;
  /// anything else falls back to the server message, then a generic invalid
  /// string.
  String _promoErrorMessage(dynamic data) {
    if (data is! Map) return 'promo_invalid'.tr();
    final rawCode = data['error_code'];
    final serverMessage = _serverMessage(data['message']);

    switch (PromoErrorCode.fromKey(rawCode is String ? rawCode : null)) {
      case PromoErrorCode.maxOrder:
        final raw = data['max_order_amount'];
        final amount = raw is num ? raw : num.tryParse('$raw') ?? 0;
        return 'promo_max_order'.tr(args: [amount.toRawUzsPrice()]);
      // The class's margin is too thin to fund any promocode discount.
      case PromoErrorCode.notApplicable:
        return 'promo_not_applicable'.tr();
      case PromoErrorCode.courseOnly:
        return 'promo_course_only'.tr();
      // Nothing left to redeem for this buyer.
      case PromoErrorCode.alreadyUsed:
        return 'promo_already_used'.tr();
      // Uses remain, but fewer than the tickets in this order. Usage is counted
      // by tickets, so name the cap — the buyer can still book a smaller order.
      case PromoErrorCode.ticketLimit:
        final raw = data['ticket_limit'];
        final limit = raw is num ? raw.toInt() : int.tryParse('$raw') ?? 1;
        return limit <= 1
            ? 'promo_one_ticket_only'.tr()
            : 'promo_ticket_limit'.tr(args: ['$limit']);
      case PromoErrorCode.unknown:
        return _untaggedUsageMessage(serverMessage) ??
            serverMessage ??
            'promo_invalid'.tr();
    }
  }

  /// The backend's own `message`, which is either a string or a list of
  /// validation strings.
  static String? _serverMessage(dynamic message) {
    if (message == null) return null;
    return message is List ? message.join(', ') : message.toString();
  }

  /// Servers that predate the tagged usage errors send the limit rejections as
  /// plain English prose with no `error_code`. Match their wording so an older
  /// backend still shows a localized message instead of leaking English.
  static String? _untaggedUsageMessage(String? message) {
    if (message == null) return null;
    final m = message.toLowerCase();
    if (m.contains('usage limit reached') ||
        m.contains('already used this promocode')) {
      return 'promo_already_used'.tr();
    }
    return null;
  }

  void _removePromo() {
    setState(() {
      _appliedPromo = null;
      _promoError = null;
      _promoCtrl.clear();
    });
  }

  /// Drop a previewed promocode whenever the order subtotal changes — the
  /// cached discount would otherwise be stale. The user re-applies on step 1.
  void _resetPromoOnChange() {
    if (_appliedPromo != null || _promoError != null) {
      _appliedPromo = null;
      _promoError = null;
    }
  }

  Widget _buildPromoSection() {
    final applied = _appliedPromo;

    // Applied: the field is replaced by the code + what it saved, and the
    // trailing chip becomes the "remove" affordance.
    if (applied != null) {
      return PillCard(
        leading: PillIconBadge(
          child: Assets.icons.detail.icDiscount.svg(width: 20.w),
        ),
        child: PillCaption(
          title: applied.code,
          subtitle: 'promo_applied_saved'
              .tr(args: [applied.discountAmount.toRawUzsPrice()]),
          subtitleColor: AppColors.tagGreen,
        ),
        trailing: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _removePromo,
          child: Icon(Icons.close_rounded,
              size: 18.sp, color: context.colors.textSecondary),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PillCard(
          leading: PillIconBadge(
            child: Assets.icons.detail.icDiscount.svg(width: 20.w),
          ),
          child: TextField(
            controller: _promoCtrl,
            enabled: !_promoLoading,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _applyPromo(),
            // The error belongs to the code that was submitted, so it stops
            // being true the moment the user edits the field.
            onChanged: (_) {
              if (_promoError != null) setState(() => _promoError = null);
            },
            cursorColor: AppColors.link,
            style:
                AppText.semibold14.copyWith(color: context.colors.textPrimary),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: 'promo_hint'.tr(),
              hintStyle: AppText.semibold14
                  .copyWith(color: context.colors.textSecondary),
            ),
          ),
          trailing: PillActionChip(
            label: 'promo_apply'.tr(),
            onTap: _promoLoading ? null : _applyPromo,
            child: _promoLoading
                ? SizedBox(
                    width: 14.w,
                    height: 14.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.brandPink),
                    ),
                  )
                : null,
          ),
        ),
        if (_promoError != null) ...[
          8.kh,
          Padding(
            padding: EdgeInsets.only(left: 8.w),
            child: Text(
              _promoError!,
              style: AppText.regular12.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ],
    );
  }

  // ── Required-booking flow ──────────────────────────────────────────────────
  // For classes whose category is `required_booking`, every individual ticket
  // gets its own [start, end] window — different attendees can show up at
  // different times within the same activity. We track one entry per ticket;
  // the list is resized in lock-step with `_totalTickets`.
  final List<_TicketWindow> _customWindows = [];
  // ISO dates that have at least one scheduled slot (pre-fetched on open).
  Set<String> _scheduledDates = {};
  bool _prefetchingDays = false;

  bool get _requiresBookingSlot =>
      widget.clazz.category?.requiresBookingTimeSlot ?? false;

  /// Every ticket in the required-booking flow has both ends of its window set.
  bool get _windowsComplete {
    if (_customWindows.length < _totalTickets) return false;
    return _customWindows
        .take(_totalTickets)
        .every((w) => w.start != null && w.end != null);
  }

  String _fmtTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Parses "HH:MM" string to a TimeOfDay. Returns null if invalid.
  TimeOfDay? _parseTime(String? s) {
    if (s == null || s.isEmpty) return null;
    final parts = s.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  /// Derives the earliest start and latest end across all slots for the
  /// currently selected day. Returns null when no slots are loaded yet.
  ({TimeOfDay min, TimeOfDay max})? _slotBounds() {
    final slots = _selectedDate?.slots ?? const [];
    if (slots.isEmpty) return null;
    final starts = slots
        .map((s) => _parseTime(s.startTime))
        .whereType<TimeOfDay>()
        .toList();
    final ends =
        slots.map((s) => _parseTime(s.endTime)).whereType<TimeOfDay>().toList();
    if (starts.isEmpty || ends.isEmpty) return null;
    int toMin(TimeOfDay t) => t.hour * 60 + t.minute;
    final minT = starts.reduce((a, b) => toMin(a) < toMin(b) ? a : b);
    final maxT = ends.reduce((a, b) => toMin(a) > toMin(b) ? a : b);
    return (min: minT, max: maxT);
  }

  /// Pre-fetches which dates in the lookahead window have scheduled slots.
  /// Only called for `required_booking` activities so we can grey out
  /// unavailable date chips before the user taps them.
  Future<void> _prefetchScheduleDays() async {
    final id = widget.clazz.id;
    if (id == null) return;
    setState(() => _prefetchingDays = true);
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final from = _isoDate(today);
      final to = _isoDate(today.add(const Duration(days: _kLookaheadDays - 1)));
      final days =
          await getIt<OrdersApi>().getScheduleDays(id, from: from, to: to);
      if (!mounted) return;
      setState(() {
        _scheduledDates = {
          for (final d in days)
            if (d.slots.isNotEmpty) d.date,
        };
        _prefetchingDays = false;
      });
      // The page opened on today before this landed. If today turns out to have
      // no session, move to the first day that does — the buyer should arrive
      // on a date they can actually book, not on an empty one they have to
      // discover and correct themselves.
      final selected = _selectedDate;
      if (_scheduledDates.isNotEmpty &&
          (selected == null || !_scheduledDates.contains(selected.isoKey))) {
        final first = _availableDates
            .where((d) => _scheduledDates.contains(d.isoKey))
            .firstOrNull;
        if (first != null) await _onDateTapped(first);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _prefetchingDays = false);
    }
  }

  /// Resize `_customWindows` to match the current ticket count, preserving
  /// any windows the user has already filled in for earlier indexes.
  void _syncCustomWindows() {
    final target = _totalTickets;
    if (_customWindows.length == target) return;
    if (_customWindows.length > target) {
      _customWindows.removeRange(target, _customWindows.length);
    } else {
      while (_customWindows.length < target) {
        _customWindows.add(const _TicketWindow());
      }
    }
  }

  Future<void> _pickTimeFor(int index, {required bool start}) async {
    if (index < 0 || index >= _customWindows.length) return;
    final cur = _customWindows[index];
    final bounds = _slotBounds();

    // Default initial time: slot open time for start, one hour later for end.
    TimeOfDay defaultStart =
        bounds?.min ?? const TimeOfDay(hour: 10, minute: 0);
    TimeOfDay defaultEnd = bounds != null
        ? TimeOfDay(
            hour: (defaultStart.hour + 1).clamp(0, bounds.max.hour),
            minute: defaultStart.minute,
          )
        : const TimeOfDay(hour: 11, minute: 0);

    final initial =
        start ? (cur.start ?? defaultStart) : (cur.end ?? defaultEnd);

    // Clamp initial within slot bounds before opening picker.
    TimeOfDay clamped = initial;
    if (bounds != null) {
      final minM = bounds.min.hour * 60 + bounds.min.minute;
      final maxM = bounds.max.hour * 60 + bounds.max.minute;
      final initM = clamped.hour * 60 + clamped.minute;
      if (initM < minM) clamped = bounds.min;
      if (initM > maxM) clamped = bounds.max;
    }

    // When the selected date is today, the picker floor is the later of the
    // slot open-time and the current wall-clock time so users can't book past.
    final isToday = _selectedDate != null &&
        _selectedDate!.isoKey == _isoDate(DateTime.now());
    TimeOfDay? effectiveMin = bounds?.min;
    if (start && isToday) {
      final now = TimeOfDay.now();
      if (effectiveMin == null ||
          now.hour * 60 + now.minute >
              effectiveMin.hour * 60 + effectiveMin.minute) {
        effectiveMin = now;
      }
    }

    if (!mounted) return;
    final picked = await AppTimePickerSheet.show(
      context,
      initial: clamped,
      minTime: effectiveMin,
      maxTime: bounds?.max,
    );
    if (picked == null) return;
    setState(() {
      var next = cur;
      if (start) {
        next = next.copyWith(start: picked);
        // Auto-fill end from ticket duration when available.
        final descs = _ticketDescriptors();
        final durMins = index < descs.length ? descs[index].duration : null;
        if (durMins != null && durMins > 0) {
          final totalMins = picked.hour * 60 + picked.minute + durMins;
          var autoEnd = TimeOfDay(
            hour: (totalMins ~/ 60).clamp(0, 23),
            minute: totalMins % 60,
          );
          if (bounds != null) {
            final maxM = bounds.max.hour * 60 + bounds.max.minute;
            if (autoEnd.hour * 60 + autoEnd.minute > maxM) autoEnd = bounds.max;
          }
          next = next.copyWith(end: autoEnd);
        } else if (next.end != null) {
          // Push end forward if it's now <= start.
          final s = picked.hour * 60 + picked.minute;
          final e = next.end!.hour * 60 + next.end!.minute;
          if (e <= s) {
            final newEnd = TimeOfDay(
              hour: ((picked.hour + 1) % 24).clamp(0, bounds?.max.hour ?? 23),
              minute: picked.minute,
            );
            next = next.copyWith(end: newEnd);
          }
        }
      } else {
        next = next.copyWith(end: picked);
        // Auto-adjust start = end - duration when duration is known.
        final descs = _ticketDescriptors();
        final durMins = index < descs.length ? descs[index].duration : null;
        if (durMins != null && durMins > 0) {
          final endMins = picked.hour * 60 + picked.minute;
          final startMins = endMins - durMins;
          if (startMins >= 0) {
            var autoStart = TimeOfDay(
              hour: startMins ~/ 60,
              minute: startMins % 60,
            );
            if (bounds != null) {
              final minM = bounds.min.hour * 60 + bounds.min.minute;
              if (autoStart.hour * 60 + autoStart.minute < minM) {
                autoStart = bounds.min;
              }
            }
            next = next.copyWith(start: autoStart);
          }
        }
      }
      _customWindows[index] = next;
      _error = null;
    });
  }

  // Cache slot fetches per ISO date so re-tapping a day is instant.
  final Map<String, List<ScheduleSlotInfo>> _slotCache = {};

  bool get _hasAgeTiers => widget.clazz.ageTiers.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (_hasAgeTiers) {
      _tierCounts = widget.clazz.ageTiers
          .map((t) => List<int>.filled(t.durations.length.clamp(1, 999), 0))
          .toList();
      _flatCounts = const [];
    } else {
      _flatCounts = List<int>.filled(widget.clazz.pricesSummary.length, 0);
      _tierCounts = const [];
    }
    // Render the next [_kLookaheadDays] days locally so the carousel is
    // immediately interactive. Slot data is fetched lazily — only when the
    // user taps a date — via the per-date `/slots?date=` endpoint.
    _availableDates = _buildLookaheadDates();
    // Pre-select the buyer's last-used payment method so repeat checkouts are
    // one tap. Async for the card rail (needs the saved-card lookup).
    _loadLastPaymentMethod();
    // Pre-fetch which days actually have sessions, so the strip greys out the
    // ones that don't BEFORE the user taps anything. This used to run only for
    // required-booking classes; every other class rendered a month of days that
    // all looked bookable, and emptiness was only discovered one tap at a time.
    // Courses answer this from their own calendar and need no round trip.
    if (!_isCourse) _prefetchScheduleDays();
    // Auto-select so the user sees slots immediately on open: today for a
    // class, and for a course the nearest day it actually runs — today is
    // usually not one, and selecting it would open on a refusal.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final first = _isCourse ? _firstCourseDay : _availableDates.firstOrNull;
      if (first != null) _onDateTapped(first);
    });
  }

  @override
  void dispose() {
    _promoCtrl.dispose();
    super.dispose();
  }

  /// Buying one trial lesson rather than a whole course / a class ticket.
  bool get _isTrial => widget.courseOption == CoursePurchaseOption.trial;

  /// The days the calendar offers — a continuous run from today, for a course
  /// exactly as for a class.
  ///
  /// It used to list ONLY a course's session dates, which made the strip skip
  /// (10, 11, 12, 17, 18…) and read as broken. A calendar should show the days
  /// either side of the ones you can pick; which of them the course actually
  /// runs on is said by [_courseScheduleKeys] instead, and drawn as enabled vs
  /// disabled.
  List<_AvailableDate> _buildLookaheadDates() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return List<_AvailableDate>.generate(_kLookaheadDays, (i) {
      final d = today.add(Duration(days: i));
      return _AvailableDate(date: d, isoKey: _isoDate(d), slots: const []);
    });
  }

  /// The days this course actually runs, as ISO keys — everything else in the
  /// calendar is a day it doesn't.
  ///
  /// A trial draws from the set the backend will accept for the buyer's next
  /// trial lesson; a whole course from the subcourse's own lesson dates. Empty
  /// for a plain class, and empty for a course whose dates didn't load — in
  /// both cases the strip falls back to offering every day rather than
  /// greying out the whole month.
  Set<String> get _courseScheduleKeys {
    if (!_isCourse) return const {};
    final level = widget.level;
    final iso = _isTrial
        ? (level?.trialNextDates ?? const <String>[])
        : (level?.courseLessons ?? const <CourseLesson>[])
            .map((l) => l.date)
            .toList();
    return iso.toSet();
  }

  /// Whether [key] is a day this course runs. Always true when we have no
  /// schedule to go on, so an unknown never blocks a purchase.
  bool _isCourseDay(String key) {
    final keys = _courseScheduleKeys;
    return keys.isEmpty || keys.contains(key);
  }

  /// The nearest day the course runs, which is what the page opens on.
  _AvailableDate? get _firstCourseDay {
    for (final d in _availableDates) {
      if (_isCourseDay(d.isoKey)) return d;
    }
    return _availableDates.isEmpty ? null : _availableDates.first;
  }

  /// Fetches slots for [d] on demand and updates the selected day. Days are
  /// always rendered as active in the carousel — emptiness is only revealed
  /// after the user taps and the per-date response comes back.
  Future<void> _onDateTapped(_AvailableDate d) async {
    // A course can't start — and a trial can't be booked — on a day it doesn't
    // run. The chip is greyed to say so; the tap says why rather than silently
    // moving the selection somewhere the backend would refuse.
    if (_isCourse && !_isCourseDay(d.isoKey)) {
      _flag(_dateShake);
      setState(() => _error = 'course_no_lesson_that_day'.tr());
      return;
    }
    setState(() {
      _selectedDate = d;
      _selectedSlot = null;
      _slotsLoaded = false;
      _error = null;
    });
    final id = widget.clazz.id;
    if (id == null) return;
    // Buying a WHOLE course books no single session: the day picked here is a
    // start date, and the month it opens is shown instead of a slot list, so
    // the query would be one whose answer nothing reads.
    //
    // A trial is the opposite — it books one session on one day, off the
    // activity's own schedule, exactly like a class ticket. It must keep
    // asking, or the times never load and the buyer picks a day with no hour
    // attached to it.
    if (_isCourse && !_isTrial) return;

    // Pre-fetch already confirmed this date has no slots — skip the network
    // call and say so. Applies to every class now that the pre-fetch runs for
    // all of them: a day the strip greys out shouldn't still be queried.
    if (!_prefetchingDays &&
        _scheduledDates.isNotEmpty &&
        !_scheduledDates.contains(d.isoKey)) {
      _slotCache[d.isoKey] = const [];
      setState(() {
        _selectedDate = d.withSlots(const []);
        _selectedSlot = null;
        _slotsLoaded = true;
      });
      return;
    }

    final cached = _slotCache[d.isoKey];
    if (cached != null) {
      setState(() {
        _selectedDate = d.withSlots(cached);
        _selectedSlot = cached.isNotEmpty ? cached.first : null;
        _slotsLoaded = true;
      });
      return;
    }

    setState(() => _loadingSlots = true);
    try {
      final slots = await getIt<OrdersApi>().getScheduleSlotsForDate(
        id,
        date: d.isoKey,
      );
      if (!mounted) return;
      _slotCache[d.isoKey] = slots;
      setState(() {
        _selectedDate = d.withSlots(slots);
        _selectedSlot = slots.isNotEmpty ? slots.first : null;
        _loadingSlots = false;
        _slotsLoaded = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingSlots = false;
        _slotsLoaded = false;
        _error = e is DioException
            ? (e.response?.data is Map
                ? (e.response?.data['message']?.toString() ?? e.message)
                : e.message)
            : e.toString();
      });
    }
  }

  static String _isoDate(DateTime d) {
    String two(int v) => v < 10 ? '0$v' : '$v';
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  /// A course is sold as one package: no dates, no seats, no slots.
  bool get _isCourse => widget.clazz.isCourse;

  num get _total {
    if (_isCourse) {
      // The picked subcourse decides the price — Beginner and Advanced cost
      // different amounts, and the class-level fallback below is the whole
      // course's headline figure, which is the wrong number for either of them.
      // A trial is priced per lesson, not per course.
      final level = widget.level;
      if (_isTrial) {
        // A trial NEVER costs the course price — that is the thing it exists to
        // avoid committing to. `next_price` of 0 is a real answer ("first
        // lesson free"), so only a null may fall back, and only as far as the
        // next unbought lesson's own price. Testing `> 0` here is what put the
        // whole course's figure in front of a buyer being offered a free trial.
        final next = level?.trialNextPrice;
        if (next != null) return next;
        final lesson = level?.trialLessons
            .where((l) => l.isAvailable)
            .firstOrNull;
        return lesson?.price ?? 0;
      }
      if ((level?.coursePrice ?? 0) > 0) {
        return level!.coursePrice;
      }
      final package = widget.coursePrice ?? 0;
      if (package > 0) return package;
      final min = widget.clazz.priceMin;
      return min > 0 ? min : widget.clazz.price;
    }
    if (_hasAgeTiers) {
      num sum = 0;
      for (var t = 0; t < _tierCounts.length; t++) {
        final durs = widget.clazz.ageTiers[t].durations;
        for (var d = 0; d < _tierCounts[t].length; d++) {
          final price = d < durs.length ? durs[d].price : 0;
          sum += price * _tierCounts[t][d];
        }
      }
      return sum;
    }
    num sum = 0;
    for (var i = 0; i < _flatCounts.length; i++) {
      sum += widget.clazz.pricesSummary[i].price * _flatCounts[i];
    }
    return sum;
  }

  int get _totalTickets {
    if (_hasAgeTiers) {
      return _tierCounts.expand((l) => l).fold(0, (a, b) => a + b);
    }
    return _flatCounts.fold(0, (a, b) => a + b);
  }

  void _bumpTier(int t, int d, int delta) {
    setState(() {
      final next = _tierCounts[t][d] + delta;
      if (next < 0) return;
      if (delta > 0) {
        final avail = _selectedSlot?.availableSlots;
        if (avail != null && _totalTickets >= avail) {
          _error = 'book_max_capacity_reached'.tr(args: ['$avail']);
          return;
        }
      }
      _tierCounts[t][d] = next;
      _syncCustomWindows();
      _resetPromoOnChange();
      _error = null;
    });
  }

  void _bumpFlat(int i, int delta) {
    setState(() {
      final next = _flatCounts[i] + delta;
      if (next < 0) return;
      if (delta > 0) {
        final avail = _selectedSlot?.availableSlots;
        if (avail != null && _totalTickets >= avail) {
          _error = 'book_max_capacity_reached'.tr(args: ['$avail']);
          return;
        }
      }
      _flatCounts[i] = next;
      _syncCustomWindows();
      _resetPromoOnChange();
      _error = null;
    });
  }

  /// One descriptor per individual ticket, in the same iteration order the
  /// submit path uses. Powers the per-ticket time-window UI.
  List<_TicketDescriptor> _ticketDescriptors() {
    final out = <_TicketDescriptor>[];
    if (_hasAgeTiers) {
      final tiers = widget.clazz.ageTiers;
      for (var t = 0; t < _tierCounts.length; t++) {
        for (var d = 0; d < _tierCounts[t].length; d++) {
          final count = _tierCounts[t][d];
          if (count <= 0) continue;
          final tier = tiers[t];
          final dur = tier.durations[d];
          for (var i = 0; i < count; i++) {
            out.add(_TicketDescriptor(
              ageFrom: tier.ageFrom,
              ageTo: tier.ageTo,
              ageLabel: tier.rangeLabel,
              duration: dur.duration,
              durationLabel: dur.durationLabel,
            ));
          }
        }
      }
    } else {
      final ranges = widget.clazz.pricesSummary;
      for (var i = 0; i < _flatCounts.length; i++) {
        final count = _flatCounts[i];
        if (count <= 0) continue;
        final r = ranges[i];
        for (var k = 0; k < count; k++) {
          out.add(_TicketDescriptor(
            ageFrom: r.ageFrom,
            ageTo: r.ageTo,
            ageLabel: r.rangeLabel,
          ));
        }
      }
    }
    return out;
  }

  /// Builds the CheckoutItems for the current selection (age tiers, flat
  /// ranges, or per-ticket time windows for required-booking categories).
  List<CheckoutItem> _buildCheckoutItems() {
    final items = <CheckoutItem>[];
    if (_requiresBookingSlot) {
      // Each ticket has its own time window — emit one CheckoutItem per
      // ticket (count = 1) so the backend can record the window per booking.
      final descriptors = _ticketDescriptors();
      for (var i = 0; i < descriptors.length; i++) {
        final desc = descriptors[i];
        final win = i < _customWindows.length
            ? _customWindows[i]
            : const _TicketWindow();
        items.add(CheckoutItem(
          ageFrom: desc.ageFrom,
          ageTo: desc.ageTo,
          count: 1,
          duration: desc.duration,
          startTime: win.start != null ? _fmtTime(win.start!) : null,
          endTime: win.end != null ? _fmtTime(win.end!) : null,
        ));
      }
    } else if (_hasAgeTiers) {
      final tiers = widget.clazz.ageTiers;
      for (var t = 0; t < _tierCounts.length; t++) {
        for (var d = 0; d < _tierCounts[t].length; d++) {
          if (_tierCounts[t][d] > 0) {
            items.add(CheckoutItem(
              ageFrom: tiers[t].ageFrom,
              ageTo: tiers[t].ageTo,
              count: _tierCounts[t][d],
              duration: tiers[t].durations[d].duration,
              // Send slot times so the backend can enforce capacity per slot
              startTime: _selectedSlot?.startTime,
              endTime: _selectedSlot?.endTime,
            ));
          }
        }
      }
    } else {
      final ranges = widget.clazz.pricesSummary;
      for (var i = 0; i < _flatCounts.length; i++) {
        if (_flatCounts[i] > 0) {
          items.add(CheckoutItem(
            ageFrom: ranges[i].ageFrom,
            ageTo: ranges[i].ageTo,
            count: _flatCounts[i],
            // Send slot times so the backend can enforce capacity per slot
            startTime: _selectedSlot?.startTime,
            endTime: _selectedSlot?.endTime,
          ));
        }
      }
    }
    return items;
  }

  /// Scrolls the control into view and shakes it — the "you still owe me this"
  /// signal, delivered where the user has to act rather than as a line of red
  /// text elsewhere on the page.
  Future<void> _flag(GlobalKey<ShakerState> key) async {
    final ctx = key.currentContext;
    if (ctx != null) {
      await Scrollable.ensureVisible(
        ctx,
        alignment: 0.2,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
    key.currentState?.shake();
  }

  /// Checks the form before charging. Returns false — and shakes whatever is
  /// still missing — when the user can't pay yet.
  bool _validateForPayment() {
    if (_error != null) setState(() => _error = null);
    // A course has no tickets or slots to validate, but it does have a day: the
    // trial lesson being bought, or the month's start date. The calendar
    // auto-selects the nearest one, so this only fires if that was cleared.
    if (_isCourse) {
      if (widget.clazz.id == null) return false;
      if (_selectedDate == null && _availableDates.isNotEmpty) {
        _flag(_dateShake);
        setState(() => _error = 'book_pick_date'.tr());
        return false;
      }
      return true;
    }
    // Each branch says what is missing as well as shaking the field. A shake
    // alone reads as "the button is broken" — the buyer taps Pay, no request
    // goes out, and nothing on screen explains why.
    if (_totalTickets == 0) {
      _flag(_ticketShake);
      setState(() => _error = 'book_select_tickets'.tr());
      return false;
    }
    if (_selectedDate == null) {
      _flag(_dateShake);
      setState(() => _error = 'book_pick_date'.tr());
      return false;
    }
    // Required-booking classes carry a per-ticket [start, end]; the backend
    // records the window per booking, so an unset one can't be sent.
    if (_requiresBookingSlot && !_windowsComplete) {
      _flag(_timeShake);
      setState(() => _error = 'book_select_time'.tr());
      return false;
    }
    // Slot-based classes: the class may not run on the chosen day (slots loaded
    // but empty) — block with a clear message instead of letting the backend
    // reject the checkout. When the day does have sessions, one must be picked.
    if (!_requiresBookingSlot && _selectedDate != null) {
      final slots = _selectedDate!.slots;
      if (_slotsLoaded && !_loadingSlots && slots.isEmpty) {
        _flag(_timeShake);
        setState(() => _error = 'book_no_slots_for_day'.tr());
        return false;
      }
      if (slots.isNotEmpty && _selectedSlot == null) {
        _flag(_timeShake);
        setState(() => _error = 'book_pick_slot'.tr());
        return false;
      }
    }
    // Payment method is handled in _pay: if none is chosen, the pay CTA opens
    // the chooser rather than blocking here.
    if (widget.clazz.id == null) return false;
    return true;
  }

  /// Creates the order and returns how to pay for it. [provider] null keeps the
  /// direct Payme flow; 'click'/'uzum' route through Paylov; 'card' also sends
  /// [cardNumber]+[expireDate]. Throws a [CheckoutFriendlyError] carrying the
  /// server message so the payment sheet can show it inline.
  Future<CheckoutResult> _runCheckout({
    String? provider,
    String? cardNumber,
    String? expireDate,
    String? savedCardId,
  }) async {
    final id = widget.clazz.id!;
    final items = _buildCheckoutItems();
    // Redirect rails (payme/click/uzum/paylov) send WLCM the URL to bounce the
    // buyer back to after paying. The card rail is confirmed in-app via OTP and
    // never redirects, so it doesn't need one. Derived from the live base URL so
    // dev and prod each hit their own /paylov/return.
    final isRedirect = provider != null && provider != 'card';
    try {
      final result = await getIt<OrdersApi>().checkout(
        activityId: id,
        items: items,
        ticketDate: _selectedDate!.isoKey,
        // Coupon plan and promocode never stack — only send a code when the
        // user has no coupon plan (the promo field is hidden in that case).
        promoCode: _hasCouponPlan ? null : _appliedPromo?.code,
        // A saved-card checkout sends only saved_card_id (no provider): the
        // order is created PENDING and charged via the token afterwards.
        paymentProvider: savedCardId != null ? null : provider,
        returnUrl: isRedirect ? '${RuntimeEnv.baseUrl}paylov/return' : null,
        cardNumber: cardNumber,
        expireDate: expireDate,
        savedCardId: savedCardId,
      );
      getIt<AnalyticsService>().logEvent(
        AnalyticsEvent.bookingCheckoutStarted,
        params: {
          'activity_id': id,
          'ticket_count': _totalTickets,
          'ticket_date': _selectedDate!.isoKey,
          'used_coupon': _hasCoupon.toString(),
          'requires_booking_slot': _requiresBookingSlot.toString(),
          'provider': provider ?? 'payme',
        },
      );
      return result;
    } on DioException catch (e) {
      final raw = e.response?.data is Map
          ? (e.response?.data['message']?.toString() ??
              e.response?.statusMessage ??
              e.message ??
              '')
          : (e.message ?? '');
      // The backend rejects a day the class doesn't run on with an English
      // message like "Class doesn't run on MON. Available: SUN". Surface a
      // clean, localized message instead of the raw string.
      final low = raw.toLowerCase();
      final isDayUnavailable = low.contains('run on') &&
          (low.contains('available') ||
              low.contains("doesn't") ||
              low.contains('does not'));
      // A gateway code ("card_not_found", "insufficient_funds") arrives wrapped
      // in our own prose. Say what the buyer can actually do about it rather
      // than surfacing the machine string.
      final gateway = PaymentError.fromText(raw);
      final msg = isDayUnavailable
          ? 'book_no_slots_for_day'.tr()
          : gateway ?? (raw.isNotEmpty ? raw : 'book_network_error'.tr());
      getIt<AnalyticsService>().logEvent(
        AnalyticsEvent.bookingCheckoutFailed,
        params: {
          'activity_id': id,
          'reason': 'dio',
          if (e.response?.statusCode != null)
            'status_code': e.response!.statusCode!,
          'provider': provider ?? 'payme',
        },
      );
      throw CheckoutFriendlyError(msg);
    }
  }

  /// Redirect rails (Payme direct, Click/Uzum via Paylov): close the booking
  /// sheet and open the checkout page, which launches the URL and polls for the
  /// paid webhook.
  /// MM/YY (as typed) -> YYMM (as WLCM expects). Anything that isn't exactly
  /// four digits is passed through untouched — the backend rejects it with a
  /// clear 400 rather than us silently reordering something unexpected.
  static String? _toYyMm(String? expiry) {
    if (expiry == null) return null;
    final digits = expiry.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != 4) return expiry;
    return digits.substring(2, 4) + digits.substring(0, 2);
  }

  Future<void> _completeRedirect(CheckoutResult result) async {
    // Snapshot before we close: was a coupon slot consumed for this order?
    final usedCoupon = _hasCoupon;
    final requiresSlot = _requiresBookingSlot;
    final id = widget.clazz.id;
    markCatalogChanged();
    if (!mounted) return;
    // Truthy for the same reason as in [_completeCardPaid]: the course detail
    // page reloads on it, so a trial bought through the gateway unlocks the
    // next rung instead of coming back to a stale ladder.
    Navigator.of(context).pop(true); // close booking sheet
    if (!RemoteConfigService.instance.isInReview) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PaycomCheckoutPage(
            result: result,
            provider: _payment?.rail.name ?? PaymentRail.card.name,
          ),
        ),
      );
    }
    // Re-sync premium status so the discount badge disappears immediately when
    // the last coupon activity slot was consumed (coins hit 0 at checkout time).
    if (usedCoupon) {
      getIt<AppCubit>().syncSubscription();
    }
    if (requiresSlot && mounted) {
      getIt<AnalyticsService>().logEvent(
        AnalyticsEvent.bookingRequested,
        params: {'activity_id': id},
      );
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const _BookingRequestedPage()),
      );
    }
  }

  /// The order breakdown (per-tier tickets + date + discount). Rendered both in
  /// the on-page summary card ([_breakdownSection]) and, mapped to [OrderLine],
  /// on the success screen — one source so the two can never disagree.
  List<_SummaryLine> _summaryLines() {
    final out = <_SummaryLine>[];

    // A course is priced as one package, so it leads with that line instead of
    // per-ticket rows — the date and promocode lines below still apply.
    if (_isCourse) {
      out.add(_SummaryLine(
        icon: Assets.icons.detail.iconsaxAiCalendar,
        // Name what is actually being bought: one trial lesson, a named
        // subcourse, or the course. A subcourse charged under a bare "Course"
        // line gave the buyer no way to check they picked the right one.
        label: _isTrial
            ? 'course_trial_lesson_one'.tr()
            : (widget.level?.name?.trim().isNotEmpty == true
                ? widget.level!.name!.trim()
                : 'course_full_title'.tr()),
        value: _total.toRawUzsPrice(),
      ));
    }

    void addTicket({
      required int ageFrom,
      required int? ageTo,
      required String rangeLabel,
      required num price,
      required int count,
    }) {
      if (count <= 0) return;
      final sub = (_hasCoupon ? _applyDiscount(price) : price) * count;
      out.add(_SummaryLine(
        icon: ageFrom >= 6 || ageTo == null
            ? Assets.icons.detail.iconsaxAiUsers
            : Assets.icons.detail.babyGirl,
        label: '$rangeLabel (${count}x)',
        value: sub.toRawUzsPrice(),
      ));
    }

    if (_isCourse) {
      // no per-ticket rows: the package line above is the price
    } else if (_hasAgeTiers) {
      for (var t = 0; t < _tierCounts.length; t++) {
        final tier = widget.clazz.ageTiers[t];
        for (var d = 0; d < _tierCounts[t].length; d++) {
          addTicket(
            ageFrom: tier.ageFrom,
            ageTo: tier.ageTo,
            rangeLabel: tier.rangeLabel,
            price: tier.durations[d].price,
            count: _tierCounts[t][d],
          );
        }
      }
    } else {
      for (var i = 0; i < _flatCounts.length; i++) {
        final r = widget.clazz.pricesSummary[i];
        addTicket(
          ageFrom: r.ageFrom,
          ageTo: r.ageTo,
          rangeLabel: r.rangeLabel,
          price: r.price,
          count: _flatCounts[i],
        );
      }
    }

    if (_selectedDate != null) {
      final slot = _selectedSlot;
      // The whole window, not just when it opens — the summary is the last
      // thing the buyer reads before paying, so it spells out what they get.
      final time = slot == null
          ? ''
          : slot.endTime.isEmpty
              ? ' ${slot.startTime}'
              : ' ${slot.startTime} – ${slot.endTime}';
      out.add(_SummaryLine(
        icon: Assets.icons.detail.icCalendar,
        label: 'book_date_time'.tr(),
        value:
            '${_selectedDate!.date.day} ${'month_short_${_selectedDate!.date.month}'.tr()}$time',
      ));
    }
    if (!_isCourse && !_hasCouponPlan && _promoDiscount > 0) {
      out.add(_SummaryLine(
        icon: Assets.icons.detail.iconsaxTicketDiscount,
        label: 'promo_discount'.tr(),
        value: '−${_promoDiscount.toRawUzsPrice()}',
        negative: true,
      ));
    }
    return out;
  }

  /// The same breakdown, in the shape the success screen expects.
  List<OrderLine> _orderLines() => _summaryLines()
      .map((l) => OrderLine(
            label: l.label,
            value: l.value,
            iconAsset: l.icon,
            negative: l.negative,
          ))
      .toList();

  /// Card rail: the OTP was confirmed and the order is already paid — go
  /// straight to the success screen (no external checkout redirect needed).
  void _completeCardPaid(CheckoutResult result) {
    final usedCoupon = _hasCoupon;
    final requiresSlot = _requiresBookingSlot;
    final id = widget.clazz.id;
    final lines = _orderLines();
    // Course card prices are per-viewer and this purchase just moved them.
    markCatalogChanged();
    if (!mounted) return;
    // Pop TRUE, not bare: the course detail page reloads on a truthy result,
    // and without it a bought trial left the ladder showing the old state —
    // the next lesson stayed locked until the screen was reopened. Harmless
    // for a class, whose caller doesn't read the result.
    Navigator.of(context).pop(true); // close booking sheet
    if (requiresSlot) {
      getIt<AnalyticsService>().logEvent(
        AnalyticsEvent.bookingRequested,
        params: {'activity_id': id},
      );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const _BookingRequestedPage()),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BookingCompletePage(
            status: BookingResultStatus.paid,
            result: result,
            lines: lines,
          ),
        ),
      );
    }
    if (usedCoupon) {
      getIt<AppCubit>().syncSubscription();
    }
  }

  // ─── Single-screen booking page (Figma 60:6122) ───────────────────────────
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // The one subscription to the coupon plan. The getters that read it
    // ([_hasCouponPlan], [_couponPct]) use `read`, because [_pay] reaches them
    // too and `watch` may only be called during a build — so the dependency is
    // registered here, once, and the page still rebuilds when a plan lands.
    context.watch<AppCubit>();
    return Scaffold(
      backgroundColor: c.canvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(c),
            Expanded(
              child: SingleChildScrollView(
                // Only the header is pinned; the date strip scrolls away with
                // the rest of the form.
                padding: EdgeInsets.only(bottom: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full-bleed: the strip has its own horizontal padding so
                    // its chips can scroll edge to edge.
                    if (_availableDates.isNotEmpty)
                      Shaker(
                        key: _dateShake,
                        child: _DateStrip(
                          dates: _availableDates,
                          selected: _selectedDate,
                          // "Days that DO have a session" — everything else is
                          // greyed. For a course that is its own calendar; for
                          // a required-booking class, the pre-fetched schedule.
                          unavailableDates: _isCourse
                              ? (_courseScheduleKeys.isEmpty
                                  ? null
                                  : _courseScheduleKeys)
                              : (_prefetchingDays ? null : _scheduledDates),
                          // The month a whole-course purchase covers, lit up in
                          // the calendar itself. Moving the start date moves the
                          // whole window with it.
                          inRangeDates: _courseMonthKeys,
                          onPickDate: _onDateTapped,
                        ),
                      ),
                    16.kh,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // A course shows everything an activity does — the
                          // schedule, the tariffs, the slots, the promocode —
                          // with its package pill on top naming what is being
                          // bought and for how much.
                          if (_isCourse) ...[
                            _courseSection(c),
                            20.kh,
                          ],
                          Shaker(key: _ticketShake, child: _ticketSection(c)),
                          20.kh,
                          Shaker(
                            key: _timeShake,
                            // Buying a whole month of a course: the lessons are
                            // the course's own, not slots to be picked off the
                            // activity's calendar, so the month is SHOWN rather
                            // than chosen from.
                            child: _isCourse && !_isTrial
                                ? _courseMonthSection(c)
                                : _requiresBookingSlot
                                    ? _customWindowsSection(c)
                                    : _slotsSection(c),
                          ),
                          // A fully-discounted order has nothing to charge, so
                          // the payment-method picker is hidden entirely.
                          if (!_isFree) ...[
                            20.kh,
                            Shaker(
                              key: _paymentShake,
                              child: _paymentMethodRow(c),
                            ),
                          ],
                          if (!_hasCouponPlan) ...[
                            20.kh,
                            _promoSection(c),
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

  /// Back control + centered title. Replaces the old drag handle: the screen is
  /// a page now, so it gets a real header inside the [SafeArea].
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
                _isCourse ? 'course_buy_cta'.tr() : 'buy_tickets'.tr(),
                textAlign: TextAlign.center,
                style: AppText.medium16.copyWith(color: c.textPrimary),
              ),
            ),
            // Balances the back button so the title stays optically centered.
            SizedBox(width: 32.w),
          ],
        ),
      );

  /// Pay CTA pinned above the home indicator on an opaque bar, as in the design.
  Widget? _bottomBar(AppColorScheme c) {
    if (RemoteConfigService.instance.isInReview) return null;
    // The home-indicator inset is padded in directly rather than wrapped in a
    // SafeArea, so the bar's fill runs to the bottom edge with no dead gap.
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      color: c.scaffoldBg,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h + bottomInset),
      child: GradientButton(
        text: _isFree
            ? 'book_free_cta'.tr()
            : 'book_pay_cta'.tr(args: [_payableTotal.toRawUzsPrice()]),
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

  // "Цены на билеты" — one frosted pill row per tariff, each with a stepper.
  Widget _ticketSection(AppColorScheme c) {
    final rows = <Widget>[];

    void addRow({
      required int ageFrom,
      required int? ageTo,
      required String label,
      required String? durationLabel,
      required num price,
      required int count,
      required VoidCallback onMinus,
      required VoidCallback onPlus,
      bool locked = false,
    }) {
      if (rows.isNotEmpty) rows.add(8.kh);
      rows.add(_TariffRow(
        locked: locked,
        // Adult tiers get the "users" glyph, children the "baby" one — the same
        // split the order summary uses.
        icon: ageFrom >= 6 || ageTo == null
            ? Assets.icons.detail.iconsaxAiUsers
            : Assets.icons.detail.babyGirl,
        label: label,
        durationLabel: durationLabel,
        price: price,
        discountedPrice: _hasCoupon ? _applyDiscount(price) : null,
        count: count,
        onMinus: onMinus,
        onPlus: onPlus,
      ));
    }

    // A trial is ONE lesson for ONE child — the ladder sells them singly, and
    // the backend refuses more than one date per order. So it gets a single
    // fixed row at the trial's own price, instead of the class's age-tier list
    // whose steppers moved a total they never fed into.
    if (_isTrial) {
      // Who the lesson is for, said the way an activity says it — the age range
      // is the one fact a parent checks before paying, and a bare "Trial
      // lesson" left them to go back and look it up.
      final tier = widget.clazz.ageTiers.firstOrNull;
      final range = tier?.rangeLabel ??
          widget.clazz.pricesSummary.firstOrNull?.rangeLabel;
      addRow(
        ageFrom: tier?.ageFrom ?? 0,
        ageTo: tier?.ageTo,
        label: range == null || range.isEmpty
            ? 'course_trial_lesson_one'.tr()
            : '${'course_trial_lesson_one'.tr()} · $range',
        durationLabel: null,
        price: _total,
        count: 1,
        locked: true,
        onMinus: () {},
        onPlus: () {},
      );
    } else if (_hasAgeTiers) {
      for (var t = 0; t < widget.clazz.ageTiers.length; t++) {
        final tier = widget.clazz.ageTiers[t];
        for (var d = 0; d < tier.durations.length; d++) {
          final dur = tier.durations[d];
          addRow(
            ageFrom: tier.ageFrom,
            ageTo: tier.ageTo,
            label: tier.rangeLabel,
            durationLabel: dur.durationLabel,
            price: dur.price,
            count: _tierCounts[t][d],
            onMinus: () => _bumpTier(t, d, -1),
            onPlus: () => _bumpTier(t, d, 1),
          );
        }
      }
    } else {
      for (var i = 0; i < widget.clazz.pricesSummary.length; i++) {
        final r = widget.clazz.pricesSummary[i];
        addRow(
          ageFrom: r.ageFrom,
          ageTo: r.ageTo,
          label: r.rangeLabel,
          durationLabel: null,
          price: r.price,
          count: _flatCounts[i],
          onMinus: () => _bumpFlat(i, -1),
          onPlus: () => _bumpFlat(i, 1),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(c, 'detail_prices'.tr()),
        ...rows,
      ],
    );
  }

  // "Доступное время" — slot chips for the day picked in the header strip.
  Widget _slotsSection(AppColorScheme c) => _SlotPicker(
        selected: _selectedDate,
        selectedSlot: _selectedSlot,
        loadingSlots: _loadingSlots,
        slotsLoaded: _slotsLoaded,
        header: _sectionHeader(c, 'book_available_times'.tr()),
        onPickSlot: (s) => setState(() {
          _selectedSlot = s;
          _error = null;
        }),
      );

  Widget _customWindowsSection(AppColorScheme c) => _CustomTimeWindowSection(
        selected: _selectedDate,
        tickets: _ticketDescriptors(),
        windows: _customWindows,
        loadingSlots: _loadingSlots,
        slotsLoaded: _slotsLoaded,
        header: _sectionHeader(c, 'book_pick_slot'.tr()),
        onPickStart: (i) => _pickTimeFor(i, start: true),
        onPickEnd: (i) => _pickTimeFor(i, start: false),
        fmt: _fmtTime,
      );

  // "Оплата" — payment method row. Opens the chooser; it never charges.
  /// What is being bought, for a course: the course and where it runs. Stands
  /// in for the ticket rows, which a package has none of.
  Widget _courseSection(AppColorScheme c) {
    final branch = widget.clazz.branch?.title?.trim() ?? '';
    // A subcourse is the product being bought, so it takes the title and the
    // course it belongs to drops beside the centre. A flat course has no
    // subcourse and titles itself.
    final levelName = widget.level?.name?.trim() ?? '';
    final title = levelName.isNotEmpty ? levelName : _courseTitle;
    final caption = [
      if (levelName.isNotEmpty) _courseTitle,
      if (branch.isNotEmpty) branch,
    ].where((s) => s.isNotEmpty).join(' · ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          c,
          _isTrial ? 'course_trial_book_title'.tr() : 'course_full_title'.tr(),
        ),
        PillCard(
          leading: PillIconBadge(
            child: Assets.icons.detail.iconsaxAiCalendar.svg(
              width: 20.w,
              height: 20.w,
              colorFilter: ColorFilter.mode(c.textPrimary, BlendMode.srcIn),
            ),
          ),
          trailing: PillActionChip(label: _total.toRawUzsPrice()),
          child: PillCaption(
            title: title,
            subtitle: caption.isEmpty ? 'course_full_title'.tr() : caption,
            captionFirst: true,
          ),
        ),
      ],
    );
  }

  /// The lessons a whole-course purchase actually buys: everything on the
  /// subcourse's own calendar from the picked start date, for one month.
  ///
  /// One month because that is what the price is — a subcourse is sold by the
  /// month — so the list and the figure beside it describe the same thing. The
  /// start date moves the window, which is the point of picking it.
  List<CourseLesson> get _courseMonthLessons {
    final lessons = widget.level?.courseLessons ?? const <CourseLesson>[];
    final start = _selectedDate?.date;
    if (lessons.isEmpty || start == null) return const [];
    final end = DateTime(start.year, start.month + 1, start.day);
    final out = <CourseLesson>[];
    for (final lesson in lessons) {
      final d = DateTime.tryParse(lesson.date);
      if (d == null) continue;
      final day = DateTime(d.year, d.month, d.day);
      if (day.isBefore(start) || !day.isBefore(end)) continue;
      out.add(lesson);
    }
    out.sort((a, b) => a.date.compareTo(b.date));
    return out;
  }

  /// The days of [_courseMonthLessons], for lighting them up in the calendar.
  Set<String> get _courseMonthKeys {
    if (!_isCourse || _isTrial) return const {};
    return _courseMonthLessons.map((l) => l.date).toSet();
  }

  /// What the lit-up month adds up to: the window it spans, how many lessons
  /// that is, and the time they run at.
  ///
  /// A line rather than the list of dates it used to be — the calendar above
  /// already shows every one of those days, and printing them again underneath
  /// said the same thing twice at ten times the height.
  Widget _courseMonthSection(AppColorScheme c) {
    final lessons = _courseMonthLessons;
    if (lessons.isEmpty) return const SizedBox.shrink();

    final first = DateTime.tryParse(lessons.first.date);
    final last = DateTime.tryParse(lessons.last.date);
    String day(DateTime d) => '${d.day} ${'month_short_${d.month}'.tr()}';
    final range =
        first == null || last == null ? '' : '${day(first)} – ${day(last)}';

    final start = lessons.first.startTime?.trim() ?? '';
    final end = lessons.first.endTime?.trim() ?? '';
    final time = start.isEmpty ? '' : (end.isEmpty ? start : '$start – $end');

    // Which weekdays it runs on, in week order rather than the order the dates
    // happen to arrive in — "Mon, Tue, Thu" is how a parent holds a timetable,
    // and it is the one fact the range and the clock don't tell them.
    final weekdayNums = lessons
        .map((l) => DateTime.tryParse(l.date)?.weekday)
        .whereType<int>()
        .toSet()
        .toList()
      ..sort();
    final weekdays =
        weekdayNums.map((w) => 'weekday_short_$w'.tr()).join(', ');
    final caption =
        [weekdays, time].where((s) => s.isNotEmpty).join('  ·  ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          c,
          'course_month_schedule'.tr(
            namedArgs: {'count': '${lessons.length}'},
          ),
        ),
        PillCard(
          leading: PillIconBadge(
            child: Assets.icons.detail.icCalendar.svg(
              width: 20.w,
              height: 20.w,
              colorFilter: ColorFilter.mode(c.textPrimary, BlendMode.srcIn),
            ),
          ),
          child: PillCaption(
            title: range,
            subtitle: caption.isEmpty ? 'course_full_title'.tr() : caption,
            captionFirst: true,
          ),
        ),
      ],
    );
  }

  /// The class name in the current language, with the same fallback chain the
  /// API models use.
  String get _courseTitle {
    final name = widget.clazz.name;
    for (final key in [context.locale.languageCode, 'ru', 'en', 'uz']) {
      final v = name[key];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    return '';
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
            // Nothing picked yet: the row itself is the prompt to pick.
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

  Widget _promoSection(AppColorScheme c) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(c, 'promo_code_title'.tr()),
          _buildPromoSection(),
        ],
      );

  // "Оплата" — the frosted price-breakdown card.
  Widget _breakdownSection(AppColorScheme c) {
    return FrostedCard(
      borderWidth: 2,
      borderRadius: BorderRadius.circular(12.r),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card title with the gradient receipt badge.
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
          for (final l in _summaryLines()) ...[
            16.kh,
            Row(
              children: [
                l.icon.svg(
                  width: 20.w,
                  height: 20.w,
                  colorFilter:
                      ColorFilter.mode(c.textSecondary, BlendMode.srcIn),
                ),
                8.kw,
                Expanded(
                  child: Text(l.label,
                      style:
                          AppText.regular14.copyWith(color: c.textSecondary)),
                ),
                Text(
                  l.value,
                  style: AppText.semibold14.copyWith(
                    color: l.negative ? AppColors.error : c.textPrimary,
                  ),
                ),
              ],
            ),
          ],
          16.kh,
          Row(
            children: [
              Expanded(
                child: Text('book_grand_total'.tr(),
                    style: AppText.bold18.copyWith(color: c.textSecondary)),
              ),
              Text(_payableTotal.toRawUzsPrice(),
                  style: AppText.bold18.copyWith(color: c.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }

  /// The glyph inside the white [PillIconBadge]: the chosen card's brand
  /// artwork, the rail's brand mark, or a neutral card icon when nothing is
  /// picked.
  Widget _paymentLeading(PaymentSelection? payment) {
    final card = payment?.card;
    if (card != null) {
      return CardArtwork(brand: card.brand, width: 30, height: 20);
    }
    switch (payment?.rail) {
      // The round badge is far too narrow for the full wordmarks, so this row
      // uses the square brand marks; the sheet still shows the wordmarks.
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

  /// Charges a card typed into the chooser sheet, without closing it first.
  ///
  /// This is the same path the pay CTA takes — `checkout(payment_provider:
  /// card)` then the OTP sheet — run from inside the chooser, because entering
  /// a card there is the buyer saying "charge this", not "remember this".
  ///
  /// Returns null once it's done with (paid, or the buyer dismissed the OTP);
  /// a message otherwise, which the sheet shows above the card form.
  Future<String?> _payWithEnteredCard(PaymentCard card) async {
    // Same guards as the CTA — a missing slot or date must not create an order.
    // The messages land on the booking page under the sheet, so repeat the
    // reason here where the buyer is actually looking.
    if (!_validateForPayment()) {
      return _error ?? 'book_pick_slot'.tr();
    }
    try {
      // A bound card is charged server-side by its token — no PAN, no OTP.
      // Anything else is a card typed this session, charged through the Paylov
      // card checkout with an OTP.
      if (card.savedCardId != null) {
        final order = await _runCheckout(savedCardId: card.savedCardId);
        if (!mounted) return null;
        final paid = await getIt<OrdersApi>().payOrderWithSavedCard(
          orderId: order.orderId,
          cardId: card.savedCardId!,
        );
        if (!mounted) return null;
        if (paid.success) {
          _completeCardPaid(order);
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
        if (paid == true && mounted) _completeCardPaid(result);
        return null;
      }
      // The gateway chose to redirect this card instead of an OTP — hand off
      // exactly like the other rails.
      if (result.checkoutUrl.isNotEmpty) {
        await _completeRedirect(result);
        return null;
      }
      // Neither a transaction nor a URL: Paylov's own message if it sent one.
      return result.paylovMessage ?? 'pay_generic_error'.tr();
    } on CheckoutFriendlyError catch (e) {
      return e.message;
    } catch (e) {
      // Never surface a raw Dio/stack string to a buyer.
      return PaymentError.fromDio(e) ?? 'pay_generic_error'.tr();
    }
  }

  /// Opens the chooser sheet. Picking a rail returns a selection to pay with
  /// from the CTA; typing a card charges it inside the sheet
  /// ([_payWithEnteredCard]).
  Future<void> _openChooser() async {
    final picked = await showPaymentChooser(
      context,
      initial: _payment,
      cards: _cards,
      // Paying by card isn't live yet — the rail shows, but inert. With the
      // rail disabled the card form is unreachable, so no charge handler.
      cardsComingSoon: !kCardPaymentsEnabled,
      onCardSubmitted: kCardPaymentsEnabled ? _payWithEnteredCard : null,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _payment = picked;
      // Remember a card added inside the sheet for the rest of the session.
      final card = picked.card;
      if (card != null && !_cards.contains(card)) _cards.add(card);
      _error = null;
    });
    _persistPaymentMethod(picked);
  }

  /// Restores the buyer's last-used payment method. Redirect rails are restored
  /// immediately; the card rail re-selects the same bound card if it's still
  /// saved.
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
    // A card was the last method used before the rail went dark. Restoring it
    // would pre-select a rail the chooser no longer offers, so leave the buyer
    // with no selection and let them pick again.
    if (!kCardPaymentsEnabled) return;
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

  /// Persists the chosen method so the next checkout pre-selects it.
  void _persistPaymentMethod(PaymentSelection sel) {
    final storage = getIt<Storage>();
    storage.lastPaymentRail.set(sel.rail.name);
    storage.lastSavedCardId.set(sel.card?.savedCardId);
  }

  /// Pay CTA: create the order and charge it on the chosen rail. Card payments
  /// confirm an OTP in a sheet; the other rails hand off to the checkout page.
  Future<void> _pay() async {
    if (_submitting) return;
    if (!_validateForPayment()) return;

    // 100%-off (coupon plan or promocode): the order is still created, but with
    // nothing to charge there's no payment method to pick and no gateway to hand
    // off to. Create it, then go straight to the success screen.
    if (_isFree) {
      setState(() {
        _submitting = true;
        _error = null;
      });
      try {
        // A course settles through its OWN endpoint — `_runCheckout` writes an
        // activity order, which is the wrong kind of thing entirely. Same deal
        // either way: no provider, because there is nothing to charge; the
        // server marks it paid and fulfils it, and there is no URL to open.
        if (_isCourse) {
          final result = await getIt<CoursesApi>().checkout(
            activityId: widget.clazz.id!,
            option: widget.courseOption ?? CoursePurchaseOption.full,
            subcourseId: widget.level?.id,
            trialDates: _isTrial && _selectedDate != null
                ? [_selectedDate!.isoKey]
                : null,
            startsAt: !_isTrial ? _selectedDate?.isoKey : null,
          );
          if (!mounted) return;
          setState(() => _submitting = false);
          // The server has already settled and fulfilled it, so this lands on
          // the same success screen a 100%-promocode booking does — a free
          // purchase that just closed the page looked like it had failed.
          _completeCardPaid(result);
          return;
        }
        final order = await _runCheckout();
        if (!mounted) return;
        setState(() => _submitting = false);
        _completeCardPaid(order);
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _submitting = false;
          _error = e is CheckoutFriendlyError ? e.message : e.toString();
        });
      }
      return;
    }

    // No method chosen yet → open the chooser; proceed only once one is picked.
    if (_payment == null) {
      await _openChooser();
      if (!mounted || _payment == null) return;
    }
    final payment = _payment!;
    final card = payment.card;

    // A course buys its package through its own endpoint, then lands on the
    // same checkout page an activity does. With no subcourse named the backend
    // picks the cheapest one with seats.
    if (_isCourse) {
      setState(() {
        _submitting = true;
        _error = null;
      });
      try {
        final result = await getIt<CoursesApi>().checkout(
          activityId: widget.clazz.id!,
          option: widget.courseOption ?? CoursePurchaseOption.full,
          subcourseId: widget.level?.id,
          // Trials are sold one at a time, by date: the day picked in the
          // calendar above IS the lesson being bought.
          trialDates: _isTrial && _selectedDate != null
              ? [_selectedDate!.isoKey]
              : null,
          // Whole course: the day picked above is when the enrolment starts.
          startsAt: !_isTrial ? _selectedDate?.isoKey : null,
          paymentProvider: payment.rail.providerKey,
          returnUrl: '${RuntimeEnv.baseUrl}paylov/return',
        );
        if (!mounted) return;
        setState(() => _submitting = false);
        if (result.checkoutUrl.isEmpty) {
          setState(() => _error = 'pay_generic_error'.tr());
          return;
        }
        await _completeRedirect(result);
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _submitting = false;
          _error = e is CheckoutFriendlyError
              ? e.message
              : (PaymentError.fromDio(e) ?? 'pay_generic_error'.tr());
        });
      }
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      // Bound (saved) card → token pay: create the PENDING order, then charge
      // the token server-side (no OTP). No redirect, no card entry.
      if (card != null && card.isSaved) {
        final order = await _runCheckout(savedCardId: card.savedCardId);
        final paid = await getIt<OrdersApi>().payOrderWithSavedCard(
          orderId: order.orderId,
          cardId: card.savedCardId!,
        );
        if (!mounted) return;
        setState(() => _submitting = false);
        if (paid.success) {
          _completeCardPaid(order);
        } else {
          setState(() => _error = paid.message ?? 'pay_generic_error'.tr());
        }
        return;
      }

      final result = await _runCheckout(
        provider: payment.rail.providerKey,
        cardNumber: card?.pan,
        // The field is entered MM/YY; WLCM wants YYMM. Their checkout example
        // is "3003", which can only be YY=30 MM=03 — there is no month 30 —
        // and their Subscribe API documents YYMM outright.
        expireDate: _toYyMm(card?.expiry),
      );
      if (!mounted) return;
      setState(() => _submitting = false);

      // A card charge comes back as a transaction to confirm via OTP; anything
      // else (including a card checkout the gateway chose to redirect) goes to
      // the checkout page.
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
        if (paid == true && mounted) _completeCardPaid(result);
      } else if (result.checkoutUrl.isNotEmpty) {
        await _completeRedirect(result);
      } else {
        setState(() => _error = 'pay_generic_error'.tr());
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e is CheckoutFriendlyError ? e.message : e.toString();
      });
    }
  }
}

/// One row of the order breakdown. See [_BookingPageState._summaryLines].
class _SummaryLine {
  const _SummaryLine({
    required this.icon,
    required this.label,
    required this.value,
    this.negative = false,
  });

  final SvgGenImage icon;
  final String label;
  final String value;

  /// Renders the value in [AppColors.error] — used by the coupon discount.
  final bool negative;
}

// ─── _AvailableDate ───────────────────────────────────────────────────────────

class _AvailableDate {
  final DateTime date;
  final String isoKey; // YYYY-MM-DD; matches the backend's date param
  final List<ScheduleSlotInfo> slots;

  const _AvailableDate({
    required this.date,
    required this.isoKey,
    required this.slots,
  });

  _AvailableDate withSlots(List<ScheduleSlotInfo> next) =>
      _AvailableDate(date: date, isoKey: isoKey, slots: next);
}

// ─── _DateStrip ───────────────────────────────────────────────────────────────

/// Horizontal day picker pinned under the header (Figma 60:6144).
///
/// Unselected days are bare text straight on the canvas; only the selected day
/// gets the frosted pill. Shared by both booking modes.
class _DateStrip extends StatefulWidget {
  const _DateStrip({
    required this.dates,
    required this.selected,
    required this.onPickDate,
    this.unavailableDates,
    this.inRangeDates = const {},
  });

  final List<_AvailableDate> dates;
  final _AvailableDate? selected;

  /// ISO days that *have* a schedule. When non-null, days outside this set are
  /// dimmed — but stay tappable, so the user can tap one and read why it is
  /// empty instead of wondering why it does nothing.
  final Set<String>? unavailableDates;

  /// ISO days a whole-course purchase covers, so the strip shows the month it
  /// buys rather than making the buyer read a list underneath it.
  final Set<String> inRangeDates;

  final ValueChanged<_AvailableDate> onPickDate;

  @override
  State<_DateStrip> createState() => _DateStripState();
}

class _DateStripState extends State<_DateStrip> {
  final ScrollController _scrollCtrl = ScrollController();

  /// Chip width + separator. Kept in sync with [_DateChip] so the auto-scroll
  /// lands on the right day.
  static const double _chipExtent = _DateChip.width + 4;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void didUpdateWidget(_DateStrip old) {
    super.didUpdateWidget(old);
    if (old.selected?.isoKey != widget.selected?.isoKey) _scrollToSelected();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToSelected() {
    if (!_scrollCtrl.hasClients) return;
    final idx =
        widget.dates.indexWhere((d) => d.isoKey == widget.selected?.isoKey);
    if (idx <= 0) return;
    // Centre the selected chip instead of left-aligning it, so the neighbouring
    // days stay visible and the strip reads as a calendar.
    final extent = _chipExtent.w;
    final target =
        idx * extent - (_scrollCtrl.position.viewportDimension - extent) / 2;
    _scrollCtrl.animateTo(
      target.clamp(0.0, _scrollCtrl.position.maxScrollExtent),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  /// Whether a day should read as OFF: nothing runs on it.
  ///
  /// Deliberately the ONLY reason a chip dims. A course day outside the month
  /// being bought is not dimmed — it is a real session the buyer can start
  /// from, and collapsing it into the same grey as "the course doesn't run that
  /// day" was what made the strip unreadable. That distinction is carried by
  /// the tint instead: [_DateChip.isInRange] marks the days this purchase
  /// covers, leaving three legible states — off, on, and included.
  bool _isDimmed(_AvailableDate date, Set<String>? unavailable) {
    return unavailable != null &&
        unavailable.isNotEmpty &&
        !unavailable.contains(date.isoKey);
  }

  @override
  Widget build(BuildContext context) {
    final unavailable = widget.unavailableDates;
    // A horizontal scroller sized by its children rather than a fixed-height
    // ListView: the chip is three lines of text whose height moves with the
    // user's text-scale factor, and any fixed height overflows once it does.
    return SingleChildScrollView(
      controller: _scrollCtrl,
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        children: [
          for (var i = 0; i < widget.dates.length; i++) ...[
            if (i > 0) 4.kw,
            _DateChip(
              date: widget.dates[i],
              isSelected: widget.selected?.isoKey == widget.dates[i].isoKey,
              isUnavailable: _isDimmed(widget.dates[i], unavailable),
              isInRange: widget.inRangeDates.contains(widget.dates[i].isoKey),
              onTap: () => widget.onPickDate(widget.dates[i]),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── _SlotPicker ──────────────────────────────────────────────────────────────

/// "Available times" — the slot chips for the day picked in the [_DateStrip].
class _SlotPicker extends StatelessWidget {
  const _SlotPicker({
    required this.selected,
    required this.selectedSlot,
    required this.loadingSlots,
    required this.slotsLoaded,
    required this.header,
    required this.onPickSlot,
  });

  final _AvailableDate? selected;
  final ScheduleSlotInfo? selectedSlot;
  final bool loadingSlots;
  final bool slotsLoaded;
  final Widget header;
  final ValueChanged<ScheduleSlotInfo> onPickSlot;

  /// Slots the user can still act on: on today, everything that has already
  /// ended is dropped so a past time can't be booked.
  List<ScheduleSlotInfo> _bookableSlots(_AvailableDate date) {
    final all = date.slots;
    final now = DateTime.now();
    if (date.isoKey != _isoDateStatic(now)) return all;
    final nowMins = now.hour * 60 + now.minute;
    return all.where((s) {
      final parts = s.endTime.split(':');
      if (parts.length < 2) return true;
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      return h * 60 + m > nowMins;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final date = selected;

    Widget body;
    if (date == null) {
      body = _AvailabilityNote(
        icon: Icons.event_rounded,
        text: 'book_pick_date'.tr(),
      );
    } else if (loadingSlots) {
      body = _AvailabilityNote(
        icon: Icons.schedule_rounded,
        text: 'book_loading_slots'.tr(),
      );
    } else {
      final slots = _bookableSlots(date);
      if (slotsLoaded && slots.isEmpty) {
        body = _AvailabilityNote(
          icon: Icons.event_busy_rounded,
          text: 'book_no_slots_for_day'.tr(),
          isError: true,
        );
      } else {
        body = Wrap(
          spacing: 6.w,
          runSpacing: 6.h,
          children: [
            for (final s in slots)
              _SlotChip(
                slot: s,
                isSelected: selectedSlot?.startTime == s.startTime &&
                    selectedSlot?.endTime == s.endTime,
                onTap: () => onPickSlot(s),
              ),
          ],
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [header, body],
    );
  }
}

// ─── _SlotChip ────────────────────────────────────────────────────────────────

/// A single bookable time, as the window it actually covers — "10:00 – 22:00".
/// The selected one takes the brand gradient; a full one is dimmed and inert
/// (Figma 60:6229).
class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.slot,
    required this.isSelected,
    required this.onTap,
  });

  final ScheduleSlotInfo slot;
  final bool isSelected;
  final VoidCallback onTap;

  /// The start alone left the buyer guessing how long they were booking for.
  /// The end is optional on the wire, so fall back to the start when it's
  /// missing rather than rendering a dangling dash.
  String get _label {
    final end = slot.endTime;
    if (end.isEmpty) return slot.startTime;
    return '${slot.startTime} – $end';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isFull = slot.isFull;

    // Unselected chips sit bare on the canvas, which goes dark — so they take
    // the theme's surface and text roles. The selected one is painted by the
    // brand gradient, which is theme-invariant, so its label stays fixed.
    final label = Text(
      _label,
      style: AppText.semibold12.copyWith(
        color: isSelected ? AppColors.onBrand : c.textPrimary,
      ),
    );

    return Opacity(
      opacity: isFull ? 0.3 : 1,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isFull ? null : onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: isSelected ? null : c.surface,
            gradient: isSelected ? AppGradients.brand : null,
            borderRadius: BorderRadius.circular(40.r),
            border: isSelected ? null : Border.all(color: c.controlBorder),
          ),
          child: label,
        ),
      ),
    );
  }
}

// ─── _DateChip ────────────────────────────────────────────────────────────────

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.date,
    required this.isSelected,
    required this.onTap,
    this.isUnavailable = false,
    this.isInRange = false,
  });

  /// Fixed so every chip is the same width whether or not it is selected —
  /// otherwise the strip would jitter as the frosted pill moves between days.
  static const double width = 48;

  final _AvailableDate date;
  final bool isSelected;
  final bool isUnavailable;

  /// One of the days a whole-course purchase covers, without being the start
  /// date itself. Tinted rather than pilled: the buyer picks ONE day (the
  /// start), and the rest are the consequence of that pick, not further
  /// choices.
  final bool isInRange;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final d = date.date;
    // Both the selected frosted pill and the bare canvas use theme colours.
    final dayColor = c.textPrimary;
    final mutedColor = c.textSecondary;

    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('weekday_short_${d.weekday}'.tr(),
            style: AppText.regular12.copyWith(color: mutedColor)),
        4.kh,
        Text('${d.day}',
            style: AppText.bold18.copyWith(color: dayColor, height: 1.0)),
        4.kh,
        Text('month_short_${d.month}'.tr(),
            style: AppText.regular12.copyWith(color: mutedColor)),
      ],
    );

    final padding = EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w);

    return Opacity(
      opacity: isUnavailable ? 0.4 : 1,
      child: SizedBox(
        width: width.w,
        child: isSelected
            ? FrostedCard(
                onTap: onTap,
                padding: padding,
                borderRadius: BorderRadius.circular(56.r),
                child: content,
              )
            : GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap,
                child: isInRange
                    ? Container(
                        padding: padding,
                        decoration: BoxDecoration(
                          color: AppColors.brandPurple.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(56.r),
                        ),
                        child: content,
                      )
                    : Padding(padding: padding, child: content),
              ),
      ),
    );
  }
}

// ─── _TariffRow ──────────────────────────────────────────────────────────────

/// One ticket tariff: age tier, its price, and the stepper that adds tickets.
class _TariffRow extends StatelessWidget {
  const _TariffRow({
    required this.icon,
    required this.label,
    required this.durationLabel,
    required this.price,
    required this.count,
    required this.onMinus,
    required this.onPlus,
    this.discountedPrice,
    this.locked = false,
  });

  final SvgGenImage icon;
  final String label;

  /// e.g. "40 min" — only age-tier pricing carries a duration.
  final String? durationLabel;
  final num price;

  /// When non-null the original [price] is struck through and this is shown
  /// next to it — an active coupon plan.
  final num? discountedPrice;

  final int count;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  /// Quantity is fixed — render the number, not a stepper. A trial is one
  /// lesson for one child; there is nothing to count up.
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final priceText = price > 0 ? price.toRawUzsPrice() : '—';
    final discounted = discountedPrice;

    return PillCard(
      leading: PillIconBadge(
        child: icon.svg(
          width: 20.w,
          height: 20.w,
          colorFilter:
              ColorFilter.mode(context.colors.textPrimary, BlendMode.srcIn),
        ),
      ),
      trailing: locked
          // A fixed quantity gets the number alone. Showing +/- that refuse to
          // move reads as a broken control; showing none says "this is one, and
          // one is all it can be".
          ? PillActionChip(label: '$count')
          : _Stepper(count: count, onMinus: onMinus, onPlus: onPlus),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: AppText.semibold14
                  .copyWith(color: context.colors.textPrimary)),
          4.kh,
          // Wrap, not Row: a long duration + price pair wraps instead of
          // overflowing on narrow screens.
          Wrap(
            spacing: 4.w,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (durationLabel != null)
                Text('$durationLabel ·',
                    style: AppText.regular12
                        .copyWith(color: context.colors.textSecondary)),
              Text(
                priceText,
                style: AppText.regular12.copyWith(
                  color: context.colors.textSecondary,
                  decoration:
                      discounted != null ? TextDecoration.lineThrough : null,
                ),
              ),
              if (discounted != null)
                Text(
                  discounted > 0 ? discounted.toRawUzsPrice() : '—',
                  style: AppText.semibold12.copyWith(color: AppColors.tagGreen),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── _Stepper ────────────────────────────────────────────────────────────────

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.count,
    required this.onMinus,
    required this.onPlus,
  });

  final int count;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepperButton(
          icon: Icons.remove,
          onTap: count > 0 ? onMinus : null,
        ),
        SizedBox(
          width: 27.w,
          child: Center(
            child: Text('$count',
                style:
                    AppText.bold18.copyWith(color: context.colors.textPrimary)),
          ),
        ),
        _StepperButton(icon: Icons.add, onTap: onPlus),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, this.onTap});

  final IconData icon;

  /// `null` disables the button — the minus at zero.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 26.w,
        height: 26.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.colors.control,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 14.w,
          color:
              disabled ? context.colors.textMuted : context.colors.textPrimary,
        ),
      ),
    );
  }
}

/// Per-ticket from/to time picker shown for required-booking classes. Each
/// ticket the user added gets its own row so different attendees can show up at
/// different times within the activity's open window for the day.
///
/// The day itself is picked in the shared [_DateStrip] under the header.
class _CustomTimeWindowSection extends StatelessWidget {
  const _CustomTimeWindowSection({
    required this.selected,
    required this.tickets,
    required this.windows,
    required this.loadingSlots,
    required this.slotsLoaded,
    required this.header,
    required this.onPickStart,
    required this.onPickEnd,
    required this.fmt,
  });

  final _AvailableDate? selected;
  final List<_TicketDescriptor> tickets;
  final List<_TicketWindow> windows;
  final bool loadingSlots;
  final bool slotsLoaded;
  final Widget header;
  final ValueChanged<int> onPickStart;
  final ValueChanged<int> onPickEnd;
  final String Function(TimeOfDay) fmt;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final selectedSlots = selected?.slots ?? const <ScheduleSlotInfo>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        // Show the partner's open window(s) for the selected day so the user
        // knows the valid range to pick within. Hidden until the slots
        // response lands so we don't render a confusing empty placeholder.
        if (loadingSlots)
          _AvailabilityNote(
            icon: Icons.schedule_rounded,
            text: 'book_loading_slots'.tr(),
          )
        else if (slotsLoaded && selectedSlots.isEmpty)
          _AvailabilityNote(
            icon: Icons.event_busy_rounded,
            text: 'book_no_slots_for_day'.tr(),
            isError: true,
          )
        else if (selectedSlots.isNotEmpty)
          _AvailabilityNote(
            icon: Icons.access_time_filled_rounded,
            text: 'book_available_window'.tr(args: [
              selectedSlots
                  .map((s) => '${s.startTime}–${s.endTime}')
                  .join(', '),
            ]),
          ),
        if (selectedSlots.isNotEmpty) ...[
          if (tickets.isEmpty) ...[
            10.kh,
            Text(
              'book_add_ticket'.tr(),
              style: AppText.regular12.copyWith(color: c.textSecondary),
            ),
          ] else
            for (var i = 0; i < tickets.length; i++) ...[
              12.kh,
              _PerTicketWindowCard(
                index: i,
                descriptor: tickets[i],
                window: i < windows.length ? windows[i] : const _TicketWindow(),
                onPickStart: () => onPickStart(i),
                onPickEnd: () => onPickEnd(i),
                fmt: fmt,
              ),
            ],
        ],
      ],
    );
  }
}

class _PerTicketWindowCard extends StatelessWidget {
  const _PerTicketWindowCard({
    required this.index,
    required this.descriptor,
    required this.window,
    required this.onPickStart,
    required this.onPickEnd,
    required this.fmt,
  });

  final int index;
  final _TicketDescriptor descriptor;
  final _TicketWindow window;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final String Function(TimeOfDay) fmt;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      descriptor.ageLabel,
      if (descriptor.durationLabel != null) descriptor.durationLabel!,
    ].join(' · ');
    return FrostedCard(
      borderWidth: 2,
      borderRadius: BorderRadius.circular(12.r),
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Ticket number — the brand gradient makes each ticket scannable
              // when several windows are stacked.
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  gradient: AppGradients.brand,
                  borderRadius: BorderRadius.circular(40.r),
                ),
                child: Text(
                  'book_ticket_index'.tr(args: ['${index + 1}']),
                  style: AppText.semibold12.copyWith(color: AppColors.onBrand),
                ),
              ),
              8.kw,
              Expanded(
                child: Text(
                  subtitle,
                  style: AppText.regular12
                      .copyWith(color: context.colors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          12.kh,
          Row(
            children: [
              Expanded(
                child: _TimeBox(
                  label: 'time_from'.tr(),
                  value: window.start == null ? '--:--' : fmt(window.start!),
                  onTap: onPickStart,
                ),
              ),
              8.kw,
              Expanded(
                child: _TimeBox(
                  label: 'time_to'.tr(),
                  value: window.end == null ? '--:--' : fmt(window.end!),
                  onTap: onPickEnd,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TicketDescriptor {
  final int ageFrom;
  final int? ageTo;
  final String ageLabel;
  final int? duration;
  final String? durationLabel;

  const _TicketDescriptor({
    required this.ageFrom,
    required this.ageTo,
    required this.ageLabel,
    this.duration,
    this.durationLabel,
  });
}

class _TicketWindow {
  final TimeOfDay? start;
  final TimeOfDay? end;
  const _TicketWindow({this.start, this.end});

  _TicketWindow copyWith({TimeOfDay? start, TimeOfDay? end}) =>
      _TicketWindow(start: start ?? this.start, end: end ?? this.end);
}

class _AvailabilityNote extends StatelessWidget {
  const _AvailabilityNote({
    required this.icon,
    required this.text,
    this.isError = false,
  });

  final IconData icon;
  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    // Sits on the canvas, so it takes the frosted-card treatment like every
    // other surface on this screen; only the accent tells errors apart.
    final color = isError ? AppColors.error : AppColors.brandPink;
    return FrostedCard(
      width: double.infinity,
      borderWidth: 2,
      borderRadius: BorderRadius.circular(12.r),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: color),
          8.kw,
          Expanded(
            child: Text(
              text,
              style: AppText.semibold12.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeBox extends StatelessWidget {
  const _TimeBox({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unset = value == '--:--';
    // Nested inside a frosted card, so it uses the inset-chip fill — the same
    // relationship the steppers have to a tariff row.
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: context.colors.control,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: AppText.regular12
                    .copyWith(color: context.colors.textSecondary)),
            4.kh,
            Row(
              children: [
                Icon(Icons.access_time_rounded,
                    size: 16.sp, color: AppColors.brandPink),
                6.kw,
                Text(
                  value,
                  style: AppText.semibold16.copyWith(
                    // An unfilled slot reads as a placeholder, not a value.
                    color: unset
                        ? context.colors.textMuted
                        : context.colors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Booking Requested (pending-approval) screen ─────────────────────────────
//
// Shown after a `required_booking` checkout completes. The centre must approve
// the request before the user proceeds to payment, so we never route to Paycom.

class _BookingRequestedPage extends StatelessWidget {
  const _BookingRequestedPage();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Animated check illustration
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.6, end: 1.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.elasticOut,
                builder: (_, scale, child) =>
                    Transform.scale(scale: scale, child: child),
                child: Container(
                  width: 110.w,
                  height: 110.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.brandPurple.withValues(alpha: 0.15),
                        AppColors.brandPurple.withValues(alpha: 0.04),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.brandPurple.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 72.w,
                      height: 72.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.brandPurple,
                            const Color(0xFF9C7EF8)
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brandPurple.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        CupertinoIcons.checkmark_alt,
                        color: Colors.white,
                        size: 34.sp,
                      ),
                    ),
                  ),
                ),
              ),
              32.kh,
              Text(
                'book_pending_title'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: c.textPrimary,
                  height: 1.25,
                  letterSpacing: -0.4,
                ),
              ),
              14.kh,
              Text(
                'book_pending_subtitle'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: c.textSecondary,
                  height: 1.55,
                ),
              ),
              28.kh,
              // Notification note card
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: c.control,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: c.controlBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: AppColors.brandPurple.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        CupertinoIcons.bell_fill,
                        color: AppColors.brandPurple,
                        size: 18.sp,
                      ),
                    ),
                    12.kw,
                    Expanded(
                      child: Text(
                        'book_pending_note'.tr(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.brandPink,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 3),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  height: 52.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.brandPink, AppColors.brandPurple],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brandPurple.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'book_pending_done'.tr(),
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              24.kh,
            ],
          ),
        ),
      ),
    );
  }
}
