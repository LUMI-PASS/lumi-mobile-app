import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/data/api_model/class_full/class_full_model.dart';
import 'package:lumi_pass/data/api_model/order/order_model.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/widgets/paycom_checkout_page.dart';

const _kLookaheadWeeks = 6;

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
  bool _submitting = false;
  String? _error;
  int _step = 0;

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
      _flatCounts =
          List<int>.filled(widget.clazz.pricesSummary.length, 0);
      _tierCounts = const [];
    }
    _availableDates = _buildAvailableDates(widget.clazz.schedule);
    _selectedDate =
        _availableDates.isNotEmpty ? _availableDates.first : null;
  }

  List<_AvailableDate> _buildAvailableDates(List<ScheduleSlot> schedule) {
    final slotsByDay = <String, ScheduleSlot>{};
    for (final s in schedule) {
      final key = _normalizeDay(s.day);
      if (key != null) slotsByDay.putIfAbsent(key, () => s);
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final out = <_AvailableDate>[];
    if (slotsByDay.isEmpty) {
      for (int i = 0; i < 14; i++) {
        out.add(_AvailableDate(
            date: today.add(Duration(days: i)), slot: null));
      }
      return out;
    }
    for (int i = 0; i < _kLookaheadWeeks * 7; i++) {
      final d = today.add(Duration(days: i));
      final slot = slotsByDay[_weekdayKey(d.weekday)];
      if (slot != null) out.add(_AvailableDate(date: d, slot: slot));
    }
    return out;
  }

  String? _normalizeDay(String? day) {
    if (day == null) return null;
    final t = day.trim().toUpperCase();
    return t.isEmpty ? null : t.substring(0, t.length >= 3 ? 3 : t.length);
  }

  String _weekdayKey(int dartWeekday) {
    const keys = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return keys[dartWeekday - 1];
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
      _tierCounts[t][d] = next < 0 ? 0 : next;
      _error = null;
    });
  }

  void _bumpFlat(int i, int delta) {
    setState(() {
      final next = _flatCounts[i] + delta;
      _flatCounts[i] = next < 0 ? 0 : next;
      _error = null;
    });
  }

  String _className() {
    final m = widget.clazz.name;
    if (m.isEmpty) return '';
    final v = m['uz'] ?? m['ru'] ?? m['en'] ?? m.values.first;
    return v is String ? v : '';
  }

  String _formatSelectedDate(_AvailableDate? d) {
    if (d == null) return '';
    const months = [
      'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr', 'Oktyabr', 'Noyabr', 'Dekabr'
    ];
    const days = [
      'Dushanba', 'Seshanba', 'Chorshanba', 'Payshanba',
      'Juma', 'Shanba', 'Yakshanba'
    ];
    return '${d.date.day} ${months[d.date.month - 1]}, '
        '${days[d.date.weekday - 1]}';
  }

  Future<void> _submit() async {
    if (_totalTickets == 0) {
      setState(() => _error = "Kamida bitta chipta qo'shing");
      return;
    }
    if (_selectedDate == null) {
      setState(() => _error = 'Sana tanlang');
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

      if (_hasAgeTiers) {
        final tiers = widget.clazz.ageTiers;
        for (var t = 0; t < _tierCounts.length; t++) {
          for (var d = 0; d < _tierCounts[t].length; d++) {
            if (_tierCounts[t][d] > 0) {
              items.add(CheckoutItem(
                ageFrom: tiers[t].ageFrom,
                ageTo: tiers[t].ageTo,
                count: _tierCounts[t][d],
                duration: tiers[t].durations[d].duration,
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
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PaycomCheckoutPage(result: result),
        ),
      );
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response?.data['message']?.toString() ??
              e.response?.statusMessage ??
              e.message)
          : (e.message ?? 'Tarmoq xatosi');
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
    final canProceed =
        _totalTickets > 0 && _selectedDate != null && !_submitting;

    final String ctaText;
    if (_totalTickets == 0) {
      ctaText = "Chipta qo'shish";
    } else if (_selectedDate == null) {
      ctaText = 'Sana tanlang';
    } else {
      ctaText = 'Davom etish →';
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
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
              'Chiptalarni tanlang',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: _navy,
              ),
            ),
            6.kh,
            Text(
              _hasAgeTiers
                  ? "Yosh guruhi va davomiylik bo'yicha chipta sonini tanlang."
                  : "Har yosh guruhi uchun joy sonini tanlang, so'ngra sanani belgilang.",
              style: TextStyle(fontSize: 12.sp, color: _muted),
            ),
            16.kh,

            // ── Ticket grid ───────────────────────────────────────────────
            if (_hasAgeTiers)
              ...widget.clazz.ageTiers.asMap().entries.expand((tEntry) {
                final t = tEntry.key;
                final tier = tEntry.value;
                final durs = tier.durations;
                if (durs.isEmpty) return <Widget>[];

                // Pair durations into rows of 2
                final rows = <Widget>[];
                for (int i = 0; i < durs.length; i += 2) {
                  final hasSecond = i + 1 < durs.length;
                  rows.add(Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: _GridCell(
                            tierLabel: tier.rangeLabel,
                            durLabel: durs[i].durationLabel,
                            price: durs[i].price,
                            count: _tierCounts[t][i],
                            onMinus: () => _bumpTier(t, i, -1),
                            onPlus: () => _bumpTier(t, i, 1),
                          ),
                        ),
                        8.kw,
                        Expanded(
                          child: hasSecond
                              ? _GridCell(
                                  tierLabel: tier.rangeLabel,
                                  durLabel: durs[i + 1].durationLabel,
                                  price: durs[i + 1].price,
                                  count: _tierCounts[t][i + 1],
                                  onMinus: () => _bumpTier(t, i + 1, -1),
                                  onPlus: () => _bumpTier(t, i + 1, 1),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ));
                }
                return rows;
              })
            else
              // Flat ranges: 2-column grid
              ...() {
                final ranges = widget.clazz.pricesSummary;
                final rows = <Widget>[];
                for (int i = 0; i < ranges.length; i += 2) {
                  final hasSecond = i + 1 < ranges.length;
                  rows.add(Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: _GridCell(
                            tierLabel: ranges[i].rangeLabel,
                            price: ranges[i].price,
                            count: _flatCounts[i],
                            onMinus: () => _bumpFlat(i, -1),
                            onPlus: () => _bumpFlat(i, 1),
                          ),
                        ),
                        8.kw,
                        Expanded(
                          child: hasSecond
                              ? _GridCell(
                                  tierLabel: ranges[i + 1].rangeLabel,
                                  price: ranges[i + 1].price,
                                  count: _flatCounts[i + 1],
                                  onMinus: () => _bumpFlat(i + 1, -1),
                                  onPlus: () => _bumpFlat(i + 1, 1),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ));
                }
                return rows;
              }(),

            16.kh,

            _DateSection(
              dates: _availableDates,
              selected: _selectedDate,
              onPick: (d) => setState(() {
                _selectedDate = d;
                _error = null;
              }),
            ),

            16.kh,
            Divider(height: 1, color: _border),
            16.kh,

            // Total summary row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$_totalTickets ta chipta',
                  style: TextStyle(fontSize: 13.sp, color: _muted),
                ),
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

            // CTA button
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
    );
  }

  // ─── Step 1: confirmation ─────────────────────────────────────────────────

  Widget _buildStep1() {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final clazz = widget.clazz;
    final selectedDate = _selectedDate;

    final timeLabel = selectedDate?.slot != null
        ? '${selectedDate!.slot!.startTime} – ${selectedDate.slot!.endTime}'
        : '';

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
                    'Orqaga',
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
              'Buyurtmani tasdiqlash',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: _navy,
              ),
            ),
            16.kh,

            // Class info card
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
                        if (clazz.category != null) ...[
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: _brandLight,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              clazz.category!.type ?? '',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: _brandDark,
                              ),
                            ),
                          ),
                          6.kh,
                        ],
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

            // Selected date card
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

            // Ticket breakdown
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
                    'Chiptalar',
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
                              Text(
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
                            Text(
                              (r.price * _flatCounts[i]).toRawUzsPrice(),
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
                        'Jami',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: _textColor,
                        ),
                      ),
                      Text(
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

            // Pay button
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
                            'Chipta sotib olish — ${_total.toRawUzsPrice()}',
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
                    "Xavfsiz to'lov · Paycom",
                    style: TextStyle(fontSize: 11.sp, color: _muted),
                  ),
                ],
              ),
            ),
          ],
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
  final ScheduleSlot? slot;

  _AvailableDate({required this.date, required this.slot});

  String get isoKey =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

// ─── _DateSection ─────────────────────────────────────────────────────────────

class _DateSection extends StatefulWidget {
  const _DateSection({
    required this.dates,
    required this.selected,
    required this.onPick,
  });

  final List<_AvailableDate> dates;
  final _AvailableDate? selected;
  final ValueChanged<_AvailableDate> onPick;

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
          'Bu dars uchun jadval mavjud emas.',
          style: TextStyle(
              fontSize: 12.sp, color: const Color(0xFF92400E)),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sana tanlang',
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
                onTap: () => widget.onPick(d),
              );
            },
          ),
        ),
        if (widget.selected?.slot != null) ...[
          8.kh,
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 14.sp, color: _muted),
              4.kw,
              Text(
                '${widget.selected!.slot!.startTime} – ${widget.selected!.slot!.endTime}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: _muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
  });

  final _AvailableDate date;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const monthShort = [
      'Yan', 'Fev', 'Mar', 'Apr', 'May', 'Iyn',
      'Iyl', 'Avg', 'Sen', 'Okt', 'Noy', 'Dek'
    ];
    const weekdayShort = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];
    final d = date.date;
    final fg = isSelected ? Colors.white : _textColor;
    final mutedColor =
        isSelected ? Colors.white.withValues(alpha: 0.85) : _muted;
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
          boxShadow: isSelected
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
              weekdayShort[d.weekday - 1],
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
              monthShort[d.month - 1],
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

// ─── _GridCell ────────────────────────────────────────────────────────────────

class _GridCell extends StatelessWidget {
  const _GridCell({
    required this.tierLabel,
    required this.price,
    required this.count,
    required this.onMinus,
    required this.onPlus,
    this.durLabel,
  });

  final String tierLabel;
  final String? durLabel;
  final num price;
  final int count;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    final active = count > 0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: EdgeInsets.all(11.w),
      decoration: BoxDecoration(
        color: active ? _brandLight : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: active ? _brand : _border,
          width: active ? 1.5 : 1.0,
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: _brand.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Age tier badge
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: active
                  ? _brand.withValues(alpha: 0.15)
                  : const Color(0xFFEDE8FF),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              tierLabel,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w800,
                color: _brandDark,
              ),
            ),
          ),
          if (durLabel != null) ...[
            5.kh,
            Text(
              durLabel!,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: _textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          3.kh,
          Text(
            price > 0 ? price.toRawUzsPrice() : '—',
            style: TextStyle(
              fontSize: 11.sp,
              color: active ? _brandDark : _muted,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          8.kh,
          // Stepper row
          Row(
            children: [
              _StepperButton(
                icon: Icons.remove,
                onTap: count > 0 ? onMinus : null,
              ),
              Expanded(
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
