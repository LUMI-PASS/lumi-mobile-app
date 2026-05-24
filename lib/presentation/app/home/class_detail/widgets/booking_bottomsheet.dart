import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/data/api_model/class_full/class_full_model.dart';
import 'package:lumi_pass/data/api_model/order/order_model.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/data/service/remote_config_service.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/widgets/paycom_checkout_page.dart';

const _kLookaheadDays = 30;

String _isoDateStatic(DateTime d) {
  String two(int v) => v < 10 ? '0$v' : '$v';
  return '${d.year}-${two(d.month)}-${two(d.day)}';
}

// ─── Design tokens ───────────────────────────────────────────────────────────
const _brand = Color(0xFF6C4EF2);
const _brandDark = Color(0xFF4A2FD4);
const _brandLight = Color(0xFFEDE8FF);
const _navy = Color(0xFF0E0C2B);
const _textColor = Color(0xFF1A1535);
const _muted = Color(0xFF6B6899);
const _border = Color(0xFFE8E4F6);

class BookingBottomsheet extends StatefulWidget {
  const BookingBottomsheet({super.key, required this.clazz});

  final ClassFullModel clazz;

  @override
  State<BookingBottomsheet> createState() => _BookingBottomsheetState();
}

class _BookingBottomsheetState extends State<BookingBottomsheet> {
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
  String? _error;
  int _step = 0;

  // ─── Coupon discount ──────────────────────────────────────────────────────
  int get _couponPct {
    final s = getIt<Storage>();
    return s.hasPremium() == true ? (s.planDiscountPercentage() ?? 0) : 0;
  }
  bool get _hasCoupon => _couponPct > 0;
  num _applyDiscount(num price) =>
      _hasCoupon ? (price * (100 - _couponPct) / 100).round() : price;
  num get _discountedTotal => _applyDiscount(_total);

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

  bool _isWindowValid(TimeOfDay start, TimeOfDay end) {
    final s = start.hour * 60 + start.minute;
    final e = end.hour * 60 + end.minute;
    if (e <= s) return false;
    final bounds = _slotBounds();
    if (bounds != null) {
      final bMin = bounds.min.hour * 60 + bounds.min.minute;
      final bMax = bounds.max.hour * 60 + bounds.max.minute;
      if (s < bMin || e > bMax) return false;
    }
    return true;
  }

  String _fmtTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Deduplicated summary of custom windows for the confirmation step.
  /// Identical windows are merged with a ×N suffix so they don't repeat.
  String _windowSummary() {
    final counts = <String, int>{};
    for (final w in _customWindows) {
      if (w.start == null || w.end == null) continue;
      final key = '${_fmtTime(w.start!)} – ${_fmtTime(w.end!)}';
      counts[key] = (counts[key] ?? 0) + 1;
    }
    if (counts.isEmpty) return '';
    return counts.entries
        .map((e) => e.value > 1 ? '${e.key} ×${e.value}' : e.key)
        .join('  ·  ');
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

    final picked = await _showCupertinoTimePicker(
      clamped,
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

  /// iOS-style wheel time picker, constrained to [minTime]..[maxTime] when
  /// provided (used for required-booking classes to stay within the slot window).
  Future<TimeOfDay?> _showCupertinoTimePicker(
    TimeOfDay initial, {
    TimeOfDay? minTime,
    TimeOfDay? maxTime,
  }) async {
    final today = DateTime.now();
    var temp = DateTime(
      today.year,
      today.month,
      today.day,
      initial.hour,
      initial.minute,
    );
    final minDate = minTime != null
        ? DateTime(today.year, today.month, today.day, minTime.hour, minTime.minute)
        : null;
    final maxDate = maxTime != null
        ? DateTime(today.year, today.month, today.day, maxTime.hour, maxTime.minute)
        : null;

    return showModalBottomSheet<TimeOfDay>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: 280.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  child: Row(
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(
                          'book_go_back'.tr(),
                          style: TextStyle(color: _muted, fontSize: 14.sp),
                        ),
                      ),
                      if (minTime != null || maxTime != null)
                        Expanded(
                          child: Text(
                            [
                              if (minTime != null) _fmtTime(minTime),
                              if (maxTime != null) _fmtTime(maxTime),
                            ].join(' – '),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: _muted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      else
                        const Spacer(),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(ctx).pop(
                          TimeOfDay(hour: temp.hour, minute: temp.minute),
                        ),
                        child: Text(
                          'book_continue'.tr(),
                          style: TextStyle(
                            color: _brandDark,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: _border),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: temp,
                    minimumDate: minDate,
                    maximumDate: maxDate,
                    use24hFormat: true,
                    minuteInterval: 5,
                    onDateTimeChanged: (d) => temp = d,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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

  String _className() {
    final m = widget.clazz.name;
    if (m.isEmpty) return '';
    final lang = context.locale.languageCode;
    final v = m[lang] ?? m['uz'] ?? m['ru'] ?? m['en'] ?? m.values.first;
    return v is String ? v : '';
  }

  String _formatSelectedDate(_AvailableDate? d) {
    if (d == null) return '';
    final monthFull = 'month_full_${d.date.month}'.tr();
    final weekdayFull = 'weekday_full_${d.date.weekday}'.tr();
    return '${d.date.day} $monthFull, $weekdayFull';
  }

  Future<void> _submit() async {
    if (_totalTickets == 0) {
      setState(() => _error = 'book_at_least_one'.tr());
      return;
    }
    if (_selectedDate == null) {
      setState(() => _error = 'book_pick_date'.tr());
      return;
    }
    final id = widget.clazz.id;
    if (id == null) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final api = getIt<OrdersApi>();
      final items = <CheckoutItem>[];

      if (_requiresBookingSlot) {
        // Each ticket has its own time window — emit one CheckoutItem per
        // ticket (count = 1) so the backend can record the window per
        // booking row.
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

      final result = await api.checkout(
        activityId: id,
        items: items,
        ticketDate: _selectedDate!.isoKey,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      if (!RemoteConfigService.instance.isInReview) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PaycomCheckoutPage(result: result),
          ),
        );
      }
      if (_requiresBookingSlot && mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const _BookingRequestedPage(),
          ),
        );
      }
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response?.data['message']?.toString() ??
              e.response?.statusMessage ??
              e.message)
          : (e.message ?? 'book_network_error'.tr());
      setState(() => _error = msg);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: _step == 0 ? _buildStep0() : _buildStep1(),
    );
  }

  // ─── Step 0: ticket selection ──────────────────────────────────────────────

  Widget _buildStep0() {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    // For required-booking: day must have slots loaded AND non-empty so we
    // know the valid window. For regular classes, a specific slot is required.
    final dayBookable = _requiresBookingSlot
        ? (_slotsLoaded && (_selectedDate?.slots.isNotEmpty ?? false))
        : (_selectedDate?.slots.isNotEmpty ?? false);
    final hasCustomWindow = _requiresBookingSlot &&
        _customWindows.isNotEmpty &&
        _customWindows.every((w) =>
            w.start != null &&
            w.end != null &&
            _isWindowValid(w.start!, w.end!));
    final canProceed = _totalTickets > 0 &&
        dayBookable &&
        (_requiresBookingSlot ? hasCustomWindow : _selectedSlot != null) &&
        !_submitting;

    final String ctaText;
    if (_totalTickets == 0) {
      ctaText = 'book_add_ticket'.tr();
    } else if (_selectedDate == null) {
      ctaText = 'book_pick_date'.tr();
    } else if (_requiresBookingSlot && _loadingSlots) {
      ctaText = 'book_loading_slots'.tr();
    } else if (!dayBookable) {
      ctaText = 'book_day_unavailable'.tr();
    } else if (_requiresBookingSlot && !hasCustomWindow) {
      ctaText = 'book_pick_slot'.tr();
    } else if (!_requiresBookingSlot && _selectedSlot == null) {
      ctaText = 'book_pick_slot'.tr();
    } else {
      ctaText = 'book_continue'.tr();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 16.h,
        bottom: 20.h + viewInsets,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: _border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            16.kh,

            Text(
              'book_select_tickets'.tr(),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: _navy,
              ),
            ),
            6.kh,
            Text(
              _hasAgeTiers
                  ? 'book_age_tier_subtitle'.tr()
                  : 'book_flat_subtitle'.tr(),
              style: TextStyle(fontSize: 12.sp, color: _muted),
            ),
            16.kh,

            if (_hasAgeTiers)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: _border),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(widget.clazz.ageTiers.length, (t) {
                    final tier = widget.clazz.ageTiers[t];
                    final durs = tier.durations;
                    if (durs.isEmpty) return const SizedBox.shrink();
                    final isLastTier = t == widget.clazz.ageTiers.length - 1;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 5.h),
                            decoration: BoxDecoration(
                              color: _brandLight,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              tier.rangeLabel,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w800,
                                color: _brandDark,
                              ),
                            ),
                          ),
                        ),
                        ...List.generate(durs.length, (d) {
                          final dur = durs[d];
                          final isLastDur = d == durs.length - 1;
                          return Column(
                            children: [
                              _DurationRow(
                                label: dur.durationLabel,
                                price: dur.price,
                                discountedPrice: _hasCoupon
                                    ? _applyDiscount(dur.price)
                                    : null,
                                count: _tierCounts[t][d],
                                onMinus: () => _bumpTier(t, d, -1),
                                onPlus: () => _bumpTier(t, d, 1),
                              ),
                              if (!isLastDur)
                                Divider(height: 1, color: _border),
                            ],
                          );
                        }),
                        if (!isLastTier)
                          Divider(height: 1, color: _border, thickness: 1),
                      ],
                    );
                  }),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: _border),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      List.generate(widget.clazz.pricesSummary.length, (i) {
                    final r = widget.clazz.pricesSummary[i];
                    final isLast = i == widget.clazz.pricesSummary.length - 1;
                    return Column(
                      children: [
                        _DurationRow(
                          label: r.rangeLabel,
                          price: r.price,
                          discountedPrice:
                              _hasCoupon ? _applyDiscount(r.price) : null,
                          count: _flatCounts[i],
                          onMinus: () => _bumpFlat(i, -1),
                          onPlus: () => _bumpFlat(i, 1),
                        ),
                        if (!isLast) Divider(height: 1, color: _border),
                      ],
                    );
                  }),
                ),
              ),

            16.kh,

            if (_requiresBookingSlot)
              _CustomTimeWindowSection(
                dates: _availableDates,
                selected: _selectedDate,
                tickets: _ticketDescriptors(),
                windows: _customWindows,
                loadingSlots: _loadingSlots,
                slotsLoaded: _slotsLoaded,
                scheduledDates: _scheduledDates,
                prefetchingDays: _prefetchingDays,
                onPickDate: _onDateTapped,
                onPickStart: (i) => _pickTimeFor(i, start: true),
                onPickEnd: (i) => _pickTimeFor(i, start: false),
                fmt: _fmtTime,
              )
            else
              _DateSection(
                dates: _availableDates,
                selected: _selectedDate,
                selectedSlot: _selectedSlot,
                loadingSlots: _loadingSlots,
                slotsLoaded: _slotsLoaded,
                onPickDate: _onDateTapped,
                onPickSlot: (s) => setState(() {
                  _selectedSlot = s;
                  _error = null;
                }),
              ),

            16.kh,
            Divider(height: 1, color: _border),
            16.kh,

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'book_tickets_count'.tr(args: ['$_totalTickets']),
                  style: TextStyle(fontSize: 13.sp, color: _muted),
                ),
                if (_hasCoupon && _totalTickets > 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _total.toRawUzsPrice(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: _muted,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      Text(
                        _discountedTotal.toRawUzsPrice(),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    _total.toRawUzsPrice(),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: _navy,
                    ),
                  ),
              ],
            ),

            if (_error != null) ...[
              10.kh,
              Text(
                _error!,
                style: TextStyle(
                    fontSize: 12.sp, color: const Color(0xFFDC2626)),
              ),
            ],

            16.kh,

            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: canProceed
                  ? GestureDetector(
                      onTap: () => setState(() {
                        _step = 1;
                        _error = null;
                      }),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_brandDark, _brand],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: [
                            BoxShadow(
                              color: _brand.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            ctaText,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        disabledBackgroundColor: const Color(0xFFCBD5E1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        ctaText,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  // ─── Step 1: confirmation ─────────────────────────────────────────────────

  Widget _buildStep1() {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final clazz = widget.clazz;
    final selectedDate = _selectedDate;
    final selectedSlot = _selectedSlot;

    final timeLabel = _requiresBookingSlot
        ? _windowSummary()
        : (selectedSlot != null
            ? '${selectedSlot.startTime} – ${selectedSlot.endTime}'
            : '');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 16.h,
        bottom: 20.h + viewInsets,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: _border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            12.kh,

            GestureDetector(
              onTap: () => setState(() => _step = 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_ios_new_rounded,
                      size: 13.sp, color: _brand),
                  4.kw,
                  Text(
                    'book_go_back'.tr(),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: _brand,
                    ),
                  ),
                ],
              ),
            ),
            12.kh,

            Text(
              'book_confirm_order'.tr(),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: _navy,
              ),
            ),
            16.kh,

            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: _border),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: clazz.imageUrl != null &&
                            clazz.imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: clazz.imageUrl!,
                            width: 64.w,
                            height: 64.h,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                _ThumbnailFallback(),
                          )
                        : _ThumbnailFallback(),
                  ),
                  12.kw,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _className(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: _textColor,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (clazz.branch?.title != null) ...[
                          4.kh,
                          Text(
                            clazz.branch!.title!,
                            style:
                                TextStyle(fontSize: 12.sp, color: _muted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            14.kh,

            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: _border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.h,
                    decoration: BoxDecoration(
                      color: _brandLight,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: const Icon(Icons.calendar_today_rounded,
                        color: _brand, size: 16),
                  ),
                  12.kw,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatSelectedDate(selectedDate),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: _textColor,
                          ),
                        ),
                        if (timeLabel.isNotEmpty) ...[
                          3.kh,
                          Text(
                            timeLabel,
                            style: TextStyle(
                                fontSize: 12.sp, color: _muted),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            14.kh,

            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: _border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'book_tickets'.tr(),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: _textColor,
                    ),
                  ),
                  10.kh,

                  if (_hasAgeTiers)
                    ...widget.clazz.ageTiers.asMap().entries.expand((tEntry) {
                      final t = tEntry.key;
                      final tier = tEntry.value;
                      return tier.durations.asMap().entries
                          .where((dEntry) =>
                              _tierCounts[t][dEntry.key] > 0)
                          .map((dEntry) {
                        final d = dEntry.key;
                        final dur = tier.durations[d];
                        final count = _tierCounts[t][d];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${tier.rangeLabel} · ${dur.durationLabel} × $count',
                                  style: TextStyle(
                                      fontSize: 12.sp, color: _muted),
                                ),
                              ),
                              _hasCoupon
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          (dur.price * count)
                                              .toRawUzsPrice(),
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            color: _muted,
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                        Text(
                                          _applyDiscount(dur.price * count)
                                              .toRawUzsPrice(),
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF16A34A),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      (dur.price * count).toRawUzsPrice(),
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                        color: _textColor,
                                      ),
                                    ),
                            ],
                          ),
                        );
                      });
                    })
                  else
                    ...List.generate(_flatCounts.length, (i) {
                      if (_flatCounts[i] == 0) {
                        return const SizedBox.shrink();
                      }
                      final r = widget.clazz.pricesSummary[i];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${r.rangeLabel} × ${_flatCounts[i]}',
                              style: TextStyle(
                                  fontSize: 13.sp, color: _muted),
                            ),
                            _hasCoupon
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        (r.price * _flatCounts[i])
                                            .toRawUzsPrice(),
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: _muted,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                      Text(
                                        _applyDiscount(
                                                r.price * _flatCounts[i])
                                            .toRawUzsPrice(),
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF16A34A),
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    (r.price * _flatCounts[i])
                                        .toRawUzsPrice(),
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: _textColor,
                                    ),
                                  ),
                          ],
                        ),
                      );
                    }),

                  Divider(height: 16.h, color: _border),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'book_grand_total'.tr(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: _textColor,
                        ),
                      ),
                      _hasCoupon
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _total.toRawUzsPrice(),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: _muted,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                Text(
                                  _discountedTotal.toRawUzsPrice(),
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF16A34A),
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              _total.toRawUzsPrice(),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                color: _brandDark,
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),
            16.kh,

            if (_error != null) ...[
              Text(
                _error!,
                style: TextStyle(
                    fontSize: 12.sp, color: const Color(0xFFDC2626)),
              ),
              10.kh,
            ],

            if (!RemoteConfigService.instance.isInReview) ...[
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: GestureDetector(
                  onTap: _submitting ? null : _submit,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_brandDark, _brand],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: _brand.withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _submitting
                          ? SizedBox(
                              width: 22.w,
                              height: 22.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            )
                          : Text(
                              'book_pay_cta'
                                  .tr(args: [_discountedTotal.toRawUzsPrice()]),
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              10.kh,

              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline_rounded,
                        size: 12.sp, color: _muted),
                    4.kw,
                    Text(
                      'book_secure_paycom'.tr(),
                      style: TextStyle(fontSize: 11.sp, color: _muted),
                    ),
                  ],
                ),
              ),
            ],
          ],
          ),
        ),
      ),
    );
  }
}

// ─── _ThumbnailFallback ───────────────────────────────────────────────────────

class _ThumbnailFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      color: const Color(0xFFEDE8FF),
      child: const Icon(Icons.image_not_supported_rounded,
          color: Color(0xFF6C4EF2), size: 28),
    );
  }
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

// ─── _DateSection ─────────────────────────────────────────────────────────────

class _DateSection extends StatefulWidget {
  const _DateSection({
    required this.dates,
    required this.selected,
    required this.selectedSlot,
    required this.loadingSlots,
    required this.slotsLoaded,
    required this.onPickDate,
    required this.onPickSlot,
  });

  final List<_AvailableDate> dates;
  final _AvailableDate? selected;
  final ScheduleSlotInfo? selectedSlot;
  final bool loadingSlots;
  final bool slotsLoaded;
  final ValueChanged<_AvailableDate> onPickDate;
  final ValueChanged<ScheduleSlotInfo> onPickSlot;

  @override
  State<_DateSection> createState() => _DateSectionState();
}

class _DateSectionState extends State<_DateSection> {
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void didUpdateWidget(_DateSection old) {
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
    final idx = widget.dates
        .indexWhere((d) => d.isoKey == widget.selected?.isoKey);
    if (idx <= 0) return;
    final offset = (idx * (66.w + 8.w))
        .clamp(0.0, _scrollCtrl.position.maxScrollExtent);
    _scrollCtrl.animateTo(offset,
        duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dates.isEmpty) {
      return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          'book_no_schedule'.tr(),
          style: TextStyle(
              fontSize: 12.sp, color: const Color(0xFF92400E)),
        ),
      );
    }
    final selected = widget.selected;
    // Filter out past slots when today is selected so users can't book times
    // that have already passed.
    final now = DateTime.now();
    final todayKey = _isoDateStatic(now);
    List<ScheduleSlotInfo> selectedSlots = selected?.slots ?? const <ScheduleSlotInfo>[];
    if (selected?.isoKey == todayKey) {
      final nowMins = now.hour * 60 + now.minute;
      selectedSlots = selectedSlots.where((s) {
        final parts = s.endTime.split(':');
        if (parts.length < 2) return true;
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1]) ?? 0;
        return h * 60 + m > nowMins;
      }).toList();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'book_select_date'.tr(),
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: _textColor,
          ),
        ),
        8.kh,
        SizedBox(
          height: 78.h,
          child: ListView.separated(
            controller: _scrollCtrl,
            scrollDirection: Axis.horizontal,
            itemCount: widget.dates.length,
            separatorBuilder: (_, __) => 8.kw,
            itemBuilder: (context, i) {
              final d = widget.dates[i];
              return _DateChip(
                date: d,
                isSelected: widget.selected?.isoKey == d.isoKey,
                onTap: () => widget.onPickDate(d),
              );
            },
          ),
        ),
        10.kh,
        if (selected == null)
          Text(
            'book_pick_date'.tr(),
            style: TextStyle(fontSize: 12.sp, color: _muted),
          )
        else if (widget.loadingSlots)
          Row(
            children: [
              SizedBox(
                width: 14.w,
                height: 14.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _brand,
                ),
              ),
              8.kw,
              Text(
                'book_loading_slots'.tr(),
                style: TextStyle(fontSize: 12.sp, color: _muted),
              ),
            ],
          )
        else if (widget.slotsLoaded && selectedSlots.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                Icon(Icons.event_busy_rounded,
                    size: 16.sp, color: const Color(0xFF92400E)),
                8.kw,
                Expanded(
                  child: Text(
                    'book_no_slots_for_day'.tr(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF92400E),
                    ),
                  ),
                ),
              ],
            ),
          )
        else if (selectedSlots.isNotEmpty) ...[
          Text(
            'book_available_times'.tr(),
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: _muted,
            ),
          ),
          6.kh,
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: selectedSlots.map((s) {
              final isActive = identical(widget.selectedSlot, s) ||
                  (widget.selectedSlot?.startTime == s.startTime &&
                      widget.selectedSlot?.endTime == s.endTime);
              final isFull = s.isFull;
              final chipColor = isFull
                  ? const Color(0xFFE2E8F0)
                  : isActive
                      ? _brand
                      : _brandLight;
              final textColor = isFull
                  ? _muted
                  : isActive
                      ? Colors.white
                      : _brandDark;
              return GestureDetector(
                onTap: isFull ? null : () => widget.onPickSlot(s),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 12.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    color: chipColor,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: isFull
                          ? const Color(0xFFCBD5E1)
                          : isActive
                              ? _brand
                              : _border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 13.sp,
                        color: textColor,
                      ),
                      5.kw,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${s.startTime} – ${s.endTime}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          if (s.availableSlots != null)
                            Text(
                              isFull
                                  ? 'book_slot_full'.tr()
                                  : 'book_slots_left'.tr(
                                      args: ['${s.availableSlots}']),
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                                color: isFull
                                    ? const Color(0xFFDC2626)
                                    : isActive
                                        ? Colors.white.withValues(alpha: 0.85)
                                        : _muted,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
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

  final _AvailableDate date;
  final bool isSelected;
  final bool isUnavailable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final d = date.date;
    final monthShort = 'month_short_${d.month}'.tr();
    final weekdayShort = 'weekday_short_${d.weekday}'.tr();
    final fg = isSelected ? Colors.white : _textColor.withValues(alpha: isUnavailable ? 0.45 : 1.0);
    final mutedColor = isSelected
        ? Colors.white.withValues(alpha: 0.85)
        : _muted.withValues(alpha: isUnavailable ? 0.45 : 1.0);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 66.w,
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 6.w),
        decoration: BoxDecoration(
          color: isSelected ? _brand : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: isSelected ? _brand : _border),
          boxShadow: isSelected && !isUnavailable
              ? [
                  BoxShadow(
                    color: _brand.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              weekdayShort,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: mutedColor,
                letterSpacing: 0.6,
              ),
            ),
            2.kh,
            Text(
              '${d.day}',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: fg,
                height: 1.0,
              ),
            ),
            2.kh,
            Text(
              monthShort,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: mutedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── _DurationRow ────────────────────────────────────────────────────────────

class _DurationRow extends StatelessWidget {
  const _DurationRow({
    required this.label,
    required this.price,
    required this.count,
    required this.onMinus,
    required this.onPlus,
    this.discountedPrice,
  });

  final String label;
  final num price;
  /// When non-null, the original price is shown struck-through and this value
  /// is shown below it in green.
  final num? discountedPrice;
  final int count;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    final active = count > 0;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(Icons.timelapse_rounded, size: 14.sp, color: _muted),
          6.kw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: _textColor,
                  ),
                ),
                2.kh,
                if (discountedPrice != null) ...[
                  Text(
                    price > 0 ? price.toRawUzsPrice() : '—',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: _muted,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  Text(
                    discountedPrice! > 0
                        ? discountedPrice!.toRawUzsPrice()
                        : '—',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF16A34A),
                    ),
                  ),
                ] else
                  Text(
                    price > 0 ? price.toRawUzsPrice() : '—',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                      color: _brandDark,
                    ),
                  ),
              ],
            ),
          ),
          _StepperButton(
            icon: Icons.remove,
            onTap: count > 0 ? onMinus : null,
          ),
          SizedBox(
            width: 32.w,
            child: Center(
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: active ? _brandDark : _textColor,
                ),
              ),
            ),
          ),
          _StepperButton(icon: Icons.add, onTap: onPlus),
        ],
      ),
    );
  }
}

// ─── _StepperButton ──────────────────────────────────────────────────────────

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Material(
      color: disabled ? const Color(0xFFE2E8F0) : _brand,
      borderRadius: BorderRadius.circular(10.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(10.r),
        onTap: onTap,
        child: SizedBox(
          width: 32.w,
          height: 32.h,
          child: Icon(icon, size: 16.w, color: Colors.white),
        ),
      ),
    );
  }
}

/// Date picker + per-ticket from/to time picker shown for required-booking
/// classes. Each ticket the user added in the count step gets its own row so
/// different attendees can show up at different times within the activity's
/// open window for the day.
class _CustomTimeWindowSection extends StatelessWidget {
  const _CustomTimeWindowSection({
    required this.dates,
    required this.selected,
    required this.tickets,
    required this.windows,
    required this.loadingSlots,
    required this.slotsLoaded,
    required this.scheduledDates,
    required this.prefetchingDays,
    required this.onPickDate,
    required this.onPickStart,
    required this.onPickEnd,
    required this.fmt,
  });

  final List<_AvailableDate> dates;
  final _AvailableDate? selected;
  final List<_TicketDescriptor> tickets;
  final List<_TicketWindow> windows;
  final bool loadingSlots;
  final bool slotsLoaded;
  final Set<String> scheduledDates;
  final bool prefetchingDays;
  final ValueChanged<_AvailableDate> onPickDate;
  final ValueChanged<int> onPickStart;
  final ValueChanged<int> onPickEnd;
  final String Function(TimeOfDay) fmt;

  @override
  Widget build(BuildContext context) {
    final selectedSlots = selected?.slots ?? const <ScheduleSlotInfo>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'book_pick_date'.tr(),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: _navy,
          ),
        ),
        10.kh,
        SizedBox(
          height: 78.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            separatorBuilder: (_, __) => 8.kw,
            itemBuilder: (_, i) {
              final d = dates[i];
              final isSelected = selected?.isoKey == d.isoKey;
              // After prefetch lands, visually de-emphasise dates with no
              // schedule — but keep them tappable so the user can still tap
              // and see the "no slots" message.
              final isUnavailable = !prefetchingDays &&
                  scheduledDates.isNotEmpty &&
                  !scheduledDates.contains(d.isoKey);
              return _DateChip(
                date: d,
                isSelected: isSelected,
                isUnavailable: isUnavailable,
                onTap: () => onPickDate(d),
              );
            },
          ),
        ),
        12.kh,
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
          16.kh,
          Text(
            'book_pick_slot'.tr(),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: _navy,
            ),
          ),
          if (tickets.isEmpty) ...[
            10.kh,
            Text(
              'book_add_ticket'.tr(),
              style: TextStyle(fontSize: 12.sp, color: _muted),
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
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: _brandLight,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'book_ticket_index'.tr(args: ['${index + 1}']),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                    color: _brandDark,
                  ),
                ),
              ),
              8.kw,
              Expanded(
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: _muted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          10.kh,
          Row(
            children: [
              Expanded(
                child: _TimeBox(
                  label: 'time_from'.tr(),
                  value: window.start == null ? '--:--' : fmt(window.start!),
                  onTap: onPickStart,
                ),
              ),
              10.kw,
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
    final color = isError ? const Color(0xFFB91C1C) : _brandDark;
    final bg = isError ? const Color(0xFFFEF2F2) : _brandLight;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isError ? const Color(0xFFFECACA) : _border,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: color),
          8.kw,
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.sp,
                color: color,
                fontWeight: FontWeight.w600,
              ),
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: _brandLight,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 11.sp, color: _muted),
            ),
            4.kh,
            Row(
              children: [
                Icon(Icons.access_time_rounded,
                    size: 16.sp, color: _brandDark),
                6.kw,
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: _navy,
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
    return Scaffold(
      backgroundColor: Colors.white,
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
                        _brand.withValues(alpha: 0.15),
                        _brand.withValues(alpha: 0.04),
                      ],
                    ),
                    border: Border.all(
                      color: _brand.withValues(alpha: 0.25),
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
                          colors: [_brand, const Color(0xFF9C7EF8)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _brand.withValues(alpha: 0.4),
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
                  color: _navy,
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
                  color: _muted,
                  height: 1.55,
                ),
              ),
              28.kh,
              // Notification note card
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: _brandLight,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: _border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: _brand.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        CupertinoIcons.bell_fill,
                        color: _brand,
                        size: 18.sp,
                      ),
                    ),
                    12.kw,
                    Expanded(
                      child: Text(
                        'book_pending_note'.tr(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: _brandDark,
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
                      colors: [_brandDark, _brand],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: _brand.withValues(alpha: 0.35),
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
