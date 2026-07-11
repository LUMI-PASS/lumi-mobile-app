import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/data/service/analytics_service.dart';
import 'package:lumi_pass/data/service/remote_config_service.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/auth/gradient_button.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:lumi_pass/presentation/app/cubit/app_cubit.dart';
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
  const BookingPage({super.key, required this.clazz});

  final ClassFullModel clazz;

  @override
  State<BookingPage> createState() => _BookingPageState();
}

/// Placeholder cards so the chooser's card list can be exercised before the
/// backend serves saved cards. The PANs are test numbers, not chargeable — the
/// gateway will reject them at payment. Delete this once a real card list
/// endpoint exists.
const List<PaymentCard> _kDemoCards = [
  PaymentCard(brand: CardBrand.uzcard, pan: '8600123456788534', expiry: '1230'),
  PaymentCard(brand: CardBrand.humo, pan: '9860123456788534', expiry: '1230'),
  PaymentCard(
      brand: CardBrand.mastercard, pan: '5555444433338534', expiry: '1230'),
];

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

  /// Cards offered in the chooser's card list: the demo ones plus anything the
  /// buyer adds during this session.
  final List<PaymentCard> _cards = [..._kDemoCards];

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
  int get _couponPct {
    final s = getIt<Storage>();
    return s.hasPremium() == true ? (s.planDiscountPercentage() ?? 0) : 0;
  }
  bool get _hasCoupon => _couponPct > 0;
  num _applyDiscount(num price) =>
      _hasCoupon ? (price * (100 - _couponPct) / 100).round() : price;
  num get _discountedTotal => _applyDiscount(_total);

  // ─── Promocode ─────────────────────────────────────────────────────────────
  // Coupon plans and promocodes never stack, so this whole block is hidden
  // (and never sent) whenever [_hasCoupon] is true. Only customers without an
  // active coupon plan can enter a promocode.
  final TextEditingController _promoCtrl = TextEditingController();
  PromocodePreview? _appliedPromo;
  bool _promoLoading = false;
  String? _promoError;

  num get _promoDiscount => _appliedPromo?.discountAmount ?? 0;

  /// The amount the user actually pays. A coupon plan and a promocode are
  /// mutually exclusive: the coupon plan auto-discounts (and hides the promo
  /// field); otherwise an applied promocode reduces the total.
  num get _payableTotal {
    if (_hasCoupon) return _discountedTotal;
    final t = _total - _promoDiscount;
    return t < 0 ? 0 : t;
  }

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
  /// Known structured errors (with an `error_code`) are localized here; anything
  /// else falls back to the server message, then a generic invalid string.
  String _promoErrorMessage(dynamic data) {
    if (data is Map) {
      final code = data['error_code'];
      if (code == 'promo_max_order') {
        final raw = data['max_order_amount'];
        final amount = raw is num ? raw : num.tryParse('$raw') ?? 0;
        return 'promo_max_order'.tr(args: [amount.toRawUzsPrice()]);
      }
      final message = data['message'];
      if (message != null) {
        return message is List ? message.join(', ') : message.toString();
      }
    }
    return 'promo_invalid'.tr();
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
              size: 18.sp, color: AppColors.inkMuted),
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
            style: AppText.semibold14.copyWith(color: AppColors.ink),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: 'promo_hint'.tr(),
              hintStyle:
                  AppText.semibold14.copyWith(color: AppColors.inkMuted),
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
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPink),
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
    final ends = slots
        .map((s) => _parseTime(s.endTime))
        .whereType<TimeOfDay>()
        .toList();
    if (starts.isEmpty || ends.isEmpty) return null;
    int toMin(TimeOfDay t) => t.hour * 60 + t.minute;
    final minT =
        starts.reduce((a, b) => toMin(a) < toMin(b) ? a : b);
    final maxT =
        ends.reduce((a, b) => toMin(a) > toMin(b) ? a : b);
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
      final days = await getIt<OrdersApi>().getScheduleDays(id, from: from, to: to);
      if (!mounted) return;
      setState(() {
        _scheduledDates = {
          for (final d in days)
            if (d.slots.isNotEmpty) d.date,
        };
        _prefetchingDays = false;
      });
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
    TimeOfDay defaultStart = bounds?.min ?? const TimeOfDay(hour: 10, minute: 0);
    TimeOfDay defaultEnd = bounds != null
        ? TimeOfDay(
            hour: (defaultStart.hour + 1).clamp(0, bounds.max.hour),
            minute: defaultStart.minute,
          )
        : const TimeOfDay(hour: 11, minute: 0);

    final initial = start
        ? (cur.start ?? defaultStart)
        : (cur.end ?? defaultEnd);

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
    // For required-booking classes, pre-fetch which days have schedules so
    // we can grey out unavailable chips before the user taps anything.
    if (_requiresBookingSlot) _prefetchScheduleDays();
    // Auto-select today so the user sees slots immediately on open.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_availableDates.isNotEmpty) _onDateTapped(_availableDates.first);
    });
  }

  @override
  void dispose() {
    _promoCtrl.dispose();
    super.dispose();
  }

  List<_AvailableDate> _buildLookaheadDates() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return List<_AvailableDate>.generate(_kLookaheadDays, (i) {
      final d = today.add(Duration(days: i));
      return _AvailableDate(date: d, isoKey: _isoDate(d), slots: const []);
    });
  }

  /// Fetches slots for [d] on demand and updates the selected day. Days are
  /// always rendered as active in the carousel — emptiness is only revealed
  /// after the user taps and the per-date response comes back.
  Future<void> _onDateTapped(_AvailableDate d) async {
    setState(() {
      _selectedDate = d;
      _selectedSlot = null;
      _slotsLoaded = false;
      _error = null;
    });
    final id = widget.clazz.id;
    if (id == null) return;

    // Pre-fetch already confirmed this date has no slots — skip the network call.
    if (_requiresBookingSlot &&
        !_prefetchingDays &&
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

  num get _total {
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
        final win =
            i < _customWindows.length ? _customWindows[i] : const _TicketWindow();
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
    if (_totalTickets == 0) {
      _flag(_ticketShake);
      return false;
    }
    if (_selectedDate == null) {
      _flag(_dateShake);
      return false;
    }
    // Required-booking classes carry a per-ticket [start, end]; the backend
    // records the window per booking, so an unset one can't be sent.
    if (_requiresBookingSlot && !_windowsComplete) {
      _flag(_timeShake);
      return false;
    }
    // Slot-based classes need one of the day's slots picked.
    if (!_requiresBookingSlot &&
        (_selectedDate?.slots.isNotEmpty ?? false) &&
        _selectedSlot == null) {
      _flag(_timeShake);
      return false;
    }
    // The buyer has to say how they're paying — nothing is preselected.
    if (_payment == null) {
      _flag(_paymentShake);
      return false;
    }
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
  }) async {
    final id = widget.clazz.id!;
    final items = _buildCheckoutItems();
    try {
      final result = await getIt<OrdersApi>().checkout(
        activityId: id,
        items: items,
        ticketDate: _selectedDate!.isoKey,
        // Coupon plan and promocode never stack — only send a code when the
        // user has no coupon plan (the promo field is hidden in that case).
        promoCode: _hasCoupon ? null : _appliedPromo?.code,
        paymentProvider: provider,
        cardNumber: cardNumber,
        expireDate: expireDate,
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
      final msg = e.response?.data is Map
          ? (e.response?.data['message']?.toString() ??
              e.response?.statusMessage ??
              e.message ??
              'book_network_error'.tr())
          : (e.message ?? 'book_network_error'.tr());
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
  Future<void> _completeRedirect(CheckoutResult result) async {
    // Snapshot before we close: was a coupon slot consumed for this order?
    final usedCoupon = _hasCoupon;
    final requiresSlot = _requiresBookingSlot;
    final id = widget.clazz.id;
    if (!mounted) return;
    Navigator.of(context).pop(); // close booking sheet
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

    if (_hasAgeTiers) {
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
      final time = slot != null ? ' ${slot.startTime}' : '';
      out.add(_SummaryLine(
        icon: Assets.icons.detail.icCalendar,
        label: 'book_date_time'.tr(),
        value:
            '${_selectedDate!.date.day} ${'month_short_${_selectedDate!.date.month}'.tr()}$time',
      ));
    }
    if (!_hasCoupon && _promoDiscount > 0) {
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
    if (!mounted) return;
    Navigator.of(context).pop(); // close booking sheet
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
                          unavailableDates:
                              _requiresBookingSlot && !_prefetchingDays
                                  ? _scheduledDates
                                  : null,
                          onPickDate: _onDateTapped,
                        ),
                      ),
                    16.kh,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Shaker(key: _ticketShake, child: _ticketSection(c)),
                          20.kh,
                          Shaker(
                            key: _timeShake,
                            child: _requiresBookingSlot
                                ? _customWindowsSection(c)
                                : _slotsSection(c),
                          ),
                          20.kh,
                          Shaker(
                            key: _paymentShake,
                            child: _paymentMethodRow(c),
                          ),
                          if (!_hasCoupon) ...[
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
                colorFilter:
                    const ColorFilter.mode(AppColors.ink, BlendMode.srcIn),
              ),
            ),
            Expanded(
              child: Text(
                'buy_tickets'.tr(),
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
        text: 'book_pay_cta'.tr(args: [_payableTotal.toRawUzsPrice()]),
        loading: _submitting,
        onPressed: _pay,
      ),
    );
  }

  Widget _sectionHeader(AppColorScheme c, String title) => Padding(
        padding: EdgeInsets.only(left: 8.w, bottom: 14.h),
        child:
            Text(title, style: AppText.semibold14.copyWith(color: c.textSecondary)),
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
    }) {
      if (rows.isNotEmpty) rows.add(8.kh);
      rows.add(_TariffRow(
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

    if (_hasAgeTiers) {
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
                  style: AppText.semibold16.copyWith(color: AppColors.ink)),
            ],
          ),
          for (final l in _summaryLines()) ...[
            16.kh,
            Row(
              children: [
                l.icon.svg(
                  width: 20.w,
                  height: 20.w,
                  colorFilter: const ColorFilter.mode(
                      AppColors.greeting, BlendMode.srcIn),
                ),
                8.kw,
                Expanded(
                  child: Text(l.label,
                      style: AppText.regular14
                          .copyWith(color: AppColors.inkMuted)),
                ),
                Text(
                  l.value,
                  style: AppText.semibold14.copyWith(
                    color: l.negative ? AppColors.error : AppColors.ink,
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
                    style: AppText.bold18.copyWith(color: AppColors.inkMuted)),
              ),
              Text(_payableTotal.toRawUzsPrice(),
                  style: AppText.bold18.copyWith(color: AppColors.ink)),
            ],
          ),
        ],
      ),
    );
  }

  /// The glyph inside the white [PillIconBadge]: the chosen card's brand
  /// artwork, the rail's brand mark, or a neutral card icon when nothing is
  /// picked. Always on a light surface, so the icon uses [AppColors.ink].
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
          colorFilter: const ColorFilter.mode(AppColors.ink, BlendMode.srcIn),
        );
    }
  }

  /// Opens the chooser sheet. It only picks a rail (and a card) — the charge
  /// happens later, from the pay CTA.
  Future<void> _openChooser() async {
    final picked = await showPaymentChooser(
      context,
      initial: _payment,
      cards: _cards,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _payment = picked;
      // Remember a card added inside the sheet for the rest of the session.
      final card = picked.card;
      if (card != null && !_cards.contains(card)) _cards.add(card);
      _error = null;
    });
  }

  /// Pay CTA: create the order and charge it on the chosen rail. Card payments
  /// confirm an OTP in a sheet; the other rails hand off to the checkout page.
  Future<void> _pay() async {
    if (_submitting) return;
    if (!_validateForPayment()) return;
    final payment = _payment!;
    final card = payment.card;

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final result = await _runCheckout(
        provider: payment.rail.providerKey,
        cardNumber: card?.pan,
        expireDate: card?.expiry,
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
  });

  final List<_AvailableDate> dates;
  final _AvailableDate? selected;

  /// ISO days that *have* a schedule. When non-null, days outside this set are
  /// dimmed — but stay tappable, so the user can tap one and read why it is
  /// empty instead of wondering why it does nothing.
  final Set<String>? unavailableDates;

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
              isUnavailable: unavailable != null &&
                  unavailable.isNotEmpty &&
                  !unavailable.contains(widget.dates[i].isoKey),
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

/// A single bookable time. White pill; the selected one takes the brand
/// gradient; a full one is dimmed and inert (Figma 60:6229).
class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.slot,
    required this.isSelected,
    required this.onTap,
  });

  final ScheduleSlotInfo slot;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isFull = slot.isFull;
    final label = Text(
      slot.startTime,
      style: AppText.semibold12.copyWith(
        color: isSelected ? AppColors.onBrand : AppColors.ink,
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
            color: isSelected ? null : AppColors.onBrand,
            gradient: isSelected ? AppGradients.brand : null,
            borderRadius: BorderRadius.circular(40.r),
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
  });

  /// Fixed so every chip is the same width whether or not it is selected —
  /// otherwise the strip would jitter as the frosted pill moves between days.
  static const double width = 48;

  final _AvailableDate date;
  final bool isSelected;
  final bool isUnavailable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final d = date.date;
    // The selected chip sits on the pale frosted pill, the rest on the canvas —
    // so its muted labels need a touch more contrast.
    final mutedColor = isSelected ? AppColors.greeting : AppColors.inkMuted;

    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('weekday_short_${d.weekday}'.tr(),
            style: AppText.regular12.copyWith(color: mutedColor)),
        4.kh,
        Text('${d.day}',
            style: AppText.bold18
                .copyWith(color: AppColors.ink, height: 1.0)),
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
                child: Padding(padding: padding, child: content),
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
              const ColorFilter.mode(AppColors.ink, BlendMode.srcIn),
        ),
      ),
      trailing: _Stepper(count: count, onMinus: onMinus, onPlus: onPlus),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppText.semibold14.copyWith(color: AppColors.ink)),
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
                        .copyWith(color: AppColors.greeting)),
              Text(
                priceText,
                style: AppText.regular12.copyWith(
                  color: AppColors.greeting,
                  decoration:
                      discounted != null ? TextDecoration.lineThrough : null,
                ),
              ),
              if (discounted != null)
                Text(
                  discounted > 0 ? discounted.toRawUzsPrice() : '—',
                  style:
                      AppText.semibold12.copyWith(color: AppColors.tagGreen),
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
                style: AppText.bold18.copyWith(color: AppColors.ink)),
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
        decoration: const BoxDecoration(
          color: AppColors.inkChip,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 14.w,
          color: disabled ? AppColors.inkMuted : AppColors.ink,
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
                  style:
                      AppText.semibold12.copyWith(color: AppColors.onBrand),
                ),
              ),
              8.kw,
              Expanded(
                child: Text(
                  subtitle,
                  style:
                      AppText.regular12.copyWith(color: AppColors.greeting),
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
          color: AppColors.inkChip,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: AppText.regular12.copyWith(color: AppColors.greeting)),
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
                    color: unset ? AppColors.inkMuted : AppColors.ink,
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
                          colors: [AppColors.brandPurple, const Color(0xFF9C7EF8)],
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
                padding: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 14.h),
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
