import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:lumi_pass/common/widget/container_3d.dart';
import 'package:lumi_pass/data/api_model/eligibility/eligibility_model.dart';
import 'package:lumi_pass/data/api_model/schedule_class/schedule_class_model.dart';
import 'package:lumi_pass/presentation/app/profile/children/cubit/children_cubit.dart';
import 'package:lumi_pass/presentation/app/profile/children/cubit/children_state.dart';

class GetTicketBottomsheet
    extends BasePage<ChildrenCubit, ChildrenBuildable, ChildrenListenable> {
  final String? childId;
  final String? classId;
  final ClassEligibilityData? eligibilityData;

  GetTicketBottomsheet({
    super.key,
    this.childId,
    this.classId,
    this.eligibilityData,
  });

  @override
  void init(BuildContext context) {
    super.init(context);
    context.read<ChildrenCubit>().selectDate(DateTime.now());
    _fetchSchedules(context, DateTime.now());
  }

  void _fetchSchedules(BuildContext context, DateTime aroundDate) {
    if (childId == null || classId == null) return;
    final from = aroundDate.subtract(const Duration(days: 15));
    final to = aroundDate.add(const Duration(days: 15));
    final fromDate =
        "${from.year}-${from.month.toString().padLeft(2, '0')}-${from.day.toString().padLeft(2, '0')}";
    final toDate =
        "${to.year}-${to.month.toString().padLeft(2, '0')}-${to.day.toString().padLeft(2, '0')}";

    context.read<ChildrenCubit>().getClassScheduleList(
          childId!,
          fromDate,
          toDate,
          classId!,
        );
  }

  @override
  void listener(BuildContext context, ChildrenListenable state) {
    if (state.effect == ChildrenEffect.bookingSuccess) {
      Navigator.pop(context);
      context.router.push(const BookingCompleteRoute());
    }
    super.listener(context, state);
  }

  List<TimeSlot> _getSlotsForDate(DateTime date, List<TimeSlot> timeSlots) {
    final dateString =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    return timeSlots.where((slot) => slot.forDate == dateString).toList();
  }

  String _formatTime(String? time) {
    if (time == null) return '';
    try {
      final parts = time.split(':');
      return '${parts[0]}:${parts[1]}';
    } catch (e) {
      return time;
    }
  }

  num _resolveExpectedCharge() {
    if (eligibilityData == null) return 0;
    final child = eligibilityData!.children
        .where((c) => c.id == childId)
        .firstOrNull;
    if (child == null) return eligibilityData!.classPrice ?? 0;
    if (child.effectiveClassPrice != null) return child.effectiveClassPrice!;
    if (child.willUseTrial == true &&
        eligibilityData!.classTrialPrice != null) {
      return eligibilityData!.classTrialPrice!;
    }
    return eligibilityData!.classPrice ?? 0;
  }

  bool _willUseTrial() {
    final child = eligibilityData?.children
        .where((c) => c.id == childId)
        .firstOrNull;
    return child?.willUseTrial == true;
  }

  @override
  Widget builder(context, state) {
    final timeSlots = state.timeSlots;
    final selectedDate = state.selectedDate ?? DateTime.now();
    final selectedTimeIndex = state.selectedTimeIndex;
    final selectedScheduleId = state.selectedScheduleId;
    final isBooking = state.bookingLoading;

    final slotsForSelectedDate = _getSlotsForDate(selectedDate, timeSlots);

    final expectedCharge = _resolveExpectedCharge();
    final willUseTrial = _willUseTrial();
    final canAfford = eligibilityData != null
        ? eligibilityData!.walletBalance >= expectedCharge
        : true;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: context.colors.window,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: context.colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ],
          ),

          // Header
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: context.colors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(CupertinoIcons.left_chevron,
                      size: 18.w, color: context.colors.primary),
                ),
              ),
              12.kw,
              'get_a_ticket'.tr().s(20).w(700),
            ],
          ),

          16.kh,

          // Expected Charge Card
          if (eligibilityData != null)
            Container3d(
              padding: EdgeInsets.all(12.w),
              depth: 2,
              borderRadius: BorderRadius.circular(14.r),
              backgroundColor: context.colors.onPrimary,
              borderColor: context.colors.primary.withOpacity(0.15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      'expected_charge'.tr()
                          .s(12)
                          .w(600)
                          .c(context.colors.grey),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3CD),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            "$expectedCharge"
                                .s(14)
                                .w(700)
                                .c(const Color(0xFFB8860B)),
                            4.kw,
                            Assets.icons.coinLumi
                                .image(width: 16.w, height: 16.h),
                          ],
                        ),
                      ),
                    ],
                  ),
                  4.kh,
                  (willUseTrial ? 'uses_trial'.tr() : 'uses_full'.tr())
                      .s(11)
                      .w(500)
                      .c(context.colors.primary),
                  if (!canAfford) ...[
                    6.kh,
                    'insufficient'.tr()
                        .s(11)
                        .w(600)
                        .c(const Color(0xFFEF4444)),
                  ],
                ],
              ),
            ),

          16.kh,

          // Date Slider (month-based, matching webapp)
          _DateSlider(
            selectedDate: selectedDate,
            onDateSelect: (date) {
              context.read<ChildrenCubit>().selectDate(date);
              _fetchSchedules(context, date);
            },
          ),

          12.kh,

          // Time slots area - Expanded so it always fills remaining space
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: state.isLoading
                  ? Center(
                      key: const ValueKey('loading'),
                      child: CircularProgressIndicator(
                          color: context.colors.primary),
                    )
                  : slotsForSelectedDate.isNotEmpty
                      ? GridView.builder(
                          key: ValueKey('slots-${selectedDate.toIso8601String()}'),
                          padding: EdgeInsets.zero,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12.w,
                            mainAxisSpacing: 12.h,
                            childAspectRatio: 2.2,
                          ),
                          itemCount: slotsForSelectedDate.length,
                          itemBuilder: (context, index) {
                            final slot = slotsForSelectedDate[index];
                            final isSelected = selectedTimeIndex == index;
                            final isAvailable = slot.isAvailable ?? true;
                            final emptySeats = slot.emptySeats ?? 0;
                            final hasConflict =
                                slot.isBookingConflict ?? false;
                            final isDisabled = !isAvailable ||
                                hasConflict ||
                                emptySeats <= 0;

                            final startTime = _formatTime(slot.startTime);
                            final endTime = _formatTime(slot.endTime);

                            return Container3d(
                              onTap: isDisabled
                                  ? null
                                  : () {
                                      context
                                          .read<ChildrenCubit>()
                                          .selectTimeSlot(
                                              index,
                                              slot.scheduleId ?? '');
                                    },
                              padding: EdgeInsets.zero,
                              depth:
                                  isDisabled ? 0 : (isSelected ? 0 : 3),
                              backgroundColor: isDisabled
                                  ? context.colors.grey.withOpacity(0.08)
                                  : isSelected
                                      ? context.colors.primary
                                      : context.colors.onPrimary,
                              borderColor: isDisabled
                                  ? context.colors.grey.withOpacity(0.2)
                                  : isSelected
                                      ? context.colors.primary
                                      : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(14.r),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        "$startTime - $endTime"
                                            .s(13)
                                            .w(600)
                                            .c(isDisabled
                                                ? context.colors.grey
                                                : isSelected
                                                    ? Colors.white
                                                    : context.colors.title),
                                        4.kh,
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.event_seat_rounded,
                                              size: 13.w,
                                              color: isDisabled
                                                  ? context.colors.grey
                                                  : isSelected
                                                      ? Colors.white
                                                          .withOpacity(0.7)
                                                      : emptySeats <= 3
                                                          ? const Color(
                                                              0xFFEF603D)
                                                          : context
                                                              .colors.grey,
                                            ),
                                            4.kw,
                                            'seats_left'.tr(args: ['$emptySeats'])
                                                .s(10)
                                                .w(500)
                                                .c(isDisabled
                                                    ? context.colors.grey
                                                    : isSelected
                                                        ? Colors.white
                                                            .withOpacity(
                                                                0.7)
                                                        : emptySeats <= 3
                                                            ? const Color(
                                                                0xFFEF603D)
                                                            : context
                                                                .colors
                                                                .grey),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isDisabled)
                                    Positioned(
                                      top: 6.h,
                                      right: 6.w,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 6.w,
                                            vertical: 3.h),
                                        decoration: BoxDecoration(
                                          color: hasConflict
                                              ? Colors.orange
                                              : emptySeats <= 0
                                                  ? const Color(0xFFEF603D)
                                                  : context.colors.grey,
                                          borderRadius:
                                              BorderRadius.circular(6.r),
                                        ),
                                        child: (hasConflict
                                                ? 'booked'.tr()
                                                : emptySeats <= 0
                                                    ? 'full'.tr()
                                                    : 'na'.tr())
                                            .s(8)
                                            .w(600)
                                            .c(Colors.white),
                                      ),
                                    ),
                                  if (isSelected)
                                    Positioned(
                                      top: 6.h,
                                      right: 6.w,
                                      child: Container(
                                        width: 20.w,
                                        height: 20.h,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.check,
                                            color: context.colors.primary,
                                            size: 14.w),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        )
                      : Center(
                          key: const ValueKey('empty'),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.event_busy,
                                  size: 48.w, color: context.colors.grey),
                              12.kh,
                              'no_slots_for_date'.tr()
                                  .s(14)
                                  .w(500)
                                  .c(context.colors.grey),
                            ],
                          ),
                        ),
            ),
          ),

          16.kh,

          // Book button - always pinned at bottom
          SafeArea(
            top: false,
            child: CommonButton.elevated(
              text: isBooking ? 'booking_loading'.tr() : 'book'.tr(),
              loading: isBooking,
              enabled: selectedScheduleId != null &&
                  selectedScheduleId.isNotEmpty &&
                  !state.isLoading &&
                  canAfford &&
                  !isBooking,
              onPressed: () {
                if (selectedScheduleId != null && childId != null) {
                  context.read<ChildrenCubit>().createBooking(
                        selectedScheduleId,
                        childId!,
                        childId!,
                      );
                }
              },
            ),
          ),

          8.kh,
        ],
      ),
    );
  }
}

/// Month-based date slider matching webapp's DateSlider component
class _DateSlider extends StatefulWidget {
  const _DateSlider({
    required this.selectedDate,
    required this.onDateSelect,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelect;

  @override
  State<_DateSlider> createState() => _DateSliderState();
}

class _DateSliderState extends State<_DateSlider> {
  late DateTime _currentMonth;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(
        widget.selectedDate.year, widget.selectedDate.month);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void didUpdateWidget(_DateSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate.month != _currentMonth.month ||
        widget.selectedDate.year != _currentMonth.year) {
      setState(() {
        _currentMonth = DateTime(
            widget.selectedDate.year, widget.selectedDate.month);
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  void _scrollToSelected() {
    if (!_scrollController.hasClients) return;
    final today = DateTime.now();
    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final selectedDay = widget.selectedDate.month == _currentMonth.month &&
            widget.selectedDate.year == _currentMonth.year
        ? widget.selectedDate.day
        : today.day;

    final itemWidth = 56.w + 8.w; // card width + gap
    final offset = (selectedDay - 1) * itemWidth -
        MediaQuery.of(context).size.width / 2 +
        itemWidth / 2;
    _scrollController.animateTo(
      offset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  bool _canGoPrev() {
    final prev = DateTime(_currentMonth.year, _currentMonth.month - 1);
    final today = DateTime.now();
    final endOfPrev = DateTime(prev.year, prev.month + 1, 0);
    return !endOfPrev.isBefore(DateTime(today.year, today.month, today.day));
  }

  void _goPrev() {
    if (!_canGoPrev()) return;
    final prevMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final firstDay = DateTime(prevMonth.year, prevMonth.month, 1);
    final selectDate = firstDay.isBefore(todayDate) ? todayDate : firstDay;
    setState(() {
      _currentMonth = prevMonth;
    });
    widget.onDateSelect(selectDate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _goNext() {
    final nextMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    // Select the first available (non-past) day of next month
    final firstDay = DateTime(nextMonth.year, nextMonth.month, 1);
    final selectDate = firstDay.isBefore(todayDate) ? todayDate : firstDay;
    setState(() {
      _currentMonth = nextMonth;
    });
    widget.onDateSelect(selectDate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  static const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;

    return Column(
      children: [
        // Month navigation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: _canGoPrev() ? _goPrev : null,
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Icon(
                  Icons.chevron_left_rounded,
                  size: 24.w,
                  color: _canGoPrev()
                      ? context.colors.primary
                      : Colors.grey.shade300,
                ),
              ),
            ),
            "${_monthNames[_currentMonth.month - 1]} ${_currentMonth.year}"
                .s(15)
                .w(600)
                .c(Colors.grey.shade700),
            GestureDetector(
              onTap: _goNext,
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 24.w,
                  color: context.colors.primary,
                ),
              ),
            ),
          ],
        ),
        8.kh,
        // Scrollable day cards
        SizedBox(
          height: 72.h,
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: daysInMonth,
            separatorBuilder: (_, __) => SizedBox(width: 8.w),
            itemBuilder: (context, index) {
              final day = index + 1;
              final date = DateTime(
                  _currentMonth.year, _currentMonth.month, day);
              final dateOnly =
                  DateTime(date.year, date.month, date.day);
              final isPast = dateOnly.isBefore(todayDate);
              final isToday = dateOnly == todayDate;
              final isSelected = widget.selectedDate.year == date.year &&
                  widget.selectedDate.month == date.month &&
                  widget.selectedDate.day == date.day;
              final weekday = date.weekday; // 1=Mon, 7=Sun

              return GestureDetector(
                onTap: isPast ? null : () => widget.onDateSelect(date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 56.w,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.colors.primary
                        : isToday
                            ? context.colors.primary.withOpacity(0.1)
                            : isPast
                                ? Colors.grey.shade100
                                : Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: isSelected
                          ? context.colors.primary
                          : isToday
                              ? context.colors.primary.withOpacity(0.4)
                              : Colors.transparent,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: context.colors.primary.withOpacity(0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      "$day"
                          .s(18)
                          .w(700)
                          .c(isSelected
                              ? Colors.white
                              : isPast
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade800),
                      2.kh,
                      _dayNames[weekday - 1]
                          .s(10)
                          .w(500)
                          .c(isSelected
                              ? Colors.white.withOpacity(0.7)
                              : isPast
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade500),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
