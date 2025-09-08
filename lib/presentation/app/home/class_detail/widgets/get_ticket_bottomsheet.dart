import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:lumi_pass/presentation/app/profile/children/cubit/children_cubit.dart';
import 'package:lumi_pass/presentation/app/profile/children/cubit/children_state.dart';
import 'package:lumi_pass/data/api_model/schedule_class/schedule_class_model.dart';

class GetTicketBottomsheet
    extends BasePage<ChildrenCubit, ChildrenBuildable, ChildrenListenable> {
  final String? childId;
  final String? classId;

  GetTicketBottomsheet({
    super.key,
    this.childId,
    this.classId,
  });

  @override
  void init(BuildContext context) {
    super.init(context);

    // Initialize selected date to today
    context.read<ChildrenCubit>().selectDate(DateTime.now());

    if (childId != null && classId != null) {
      final now = DateTime.now();
      final fromDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final toDate = "${now.add(Duration(days: 30)).year}-${now.add(Duration(days: 30)).month.toString().padLeft(2, '0')}-${now.add(Duration(days: 30)).day.toString().padLeft(2, '0')}";

      context.read<ChildrenCubit>().getClassScheduleList(
        childId!,
        fromDate,
        toDate,
        classId!,
      );
    }
  }

  // Extract available dates from the TimeSlot list
  List<DateTime> _getAvailableDates(List<TimeSlot> timeSlots) {
    Set<DateTime> uniqueDates = {};

    for (var slot in timeSlots) {
      if (slot.forDate != null) {
        try {
          final date = DateTime.parse(slot.forDate!);
          uniqueDates.add(DateTime(date.year, date.month, date.day));
        } catch (e) {
          print('Error parsing date: $e');
        }
      }
    }

    List<DateTime> sortedDates = uniqueDates.toList();
    sortedDates.sort();
    return sortedDates;
  }

  // Get slots for a specific date
  List<TimeSlot> _getSlotsForDate(DateTime date, List<TimeSlot> timeSlots) {
    final dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    return timeSlots.where((slot) {
      return slot.forDate == dateString;
    }).toList();
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  String _formatTime(String? time) {
    if (time == null) return '';

    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts[1];

      // Convert to 12-hour format if needed
      if (hour == 0) {
        return '12:$minute AM';
      } else if (hour < 12) {
        return '$hour:$minute AM';
      } else if (hour == 12) {
        return '12:$minute PM';
      } else {
        return '${hour - 12}:$minute PM';
      }
    } catch (e) {
      return time;
    }
  }

  // Get slot availability info using TimeSlot model
  bool _isSlotAvailable(TimeSlot slot) {
    return slot.isAvailable ?? true;
  }

  int _getEmptySeats(TimeSlot slot) {
    return slot.emptySeats ?? 0;
  }

  bool _hasConflict(TimeSlot slot) {
    return slot.isBookingConflict ?? false;
  }

  String _getSlotId(TimeSlot slot) {
    return slot.scheduleId ?? '';
  }

  @override
  Widget builder(context, state) {
    final timeSlots = state.timeSlots;
    final selectedDate = state.selectedDate ?? DateTime.now();
    final selectedTimeIndex = state.selectedTimeIndex;
    final selectedScheduleId = state.selectedScheduleId;

    final availableDates = _getAvailableDates(timeSlots);
    final slotsForSelectedDate = _getSlotsForDate(selectedDate, timeSlots);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        color: context.colors.window,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88.w,
                height: 2.h,
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: context.colors.grey,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ],
          ),

          // Header with back button and title
          Row(
            children: [
              IconButton(
                icon: const Icon(CupertinoIcons.left_chevron),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              "Get a Ticket".s(18).w(700),
            ],
          ),

          16.kh,

          // Show loading state
          if (state.isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.all(32.h),
                child: CircularProgressIndicator(
                  color: context.colors.primary,
                ),
              ),
            )
          else ...[
            // Horizontal Calendar
            if (availableDates.isNotEmpty) ...[
              SizedBox(
                height: 70.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: availableDates.length,
                  itemBuilder: (context, index) {
                    final date = availableDates[index];
                    final isSelected = selectedDate.day == date.day &&
                        selectedDate.month == date.month &&
                        selectedDate.year == date.year;

                    return GestureDetector(
                      onTap: () {
                        context.read<ChildrenCubit>().selectDate(date);
                      },
                      child: Container(
                        width: 60.w,
                        margin: EdgeInsets.only(right: 12.w),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? context.colors.primary
                              : context.colors.onPrimary,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: isSelected
                                ? context.colors.primary
                                : context.colors.grey.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            date.day.toString().s(18).w(700).c(
                                isSelected ? Colors.white : context.colors.title),
                            4.kh,
                            _getMonthName(date.month).s(12).w(400).c(isSelected
                                ? Colors.white.withOpacity(0.8)
                                : context.colors.grey),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              24.kh,
            ],

            // Time slots grid
            if (slotsForSelectedDate.isNotEmpty) ...[
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: slotsForSelectedDate.length,
                  itemBuilder: (context, index) {
                    final timeSlot = slotsForSelectedDate[index];
                    final isSelected = selectedTimeIndex == index;
                    final isAvailable = _isSlotAvailable(timeSlot);
                    final emptySeats = _getEmptySeats(timeSlot);
                    final hasConflict = _hasConflict(timeSlot);
                    final slotId = _getSlotId(timeSlot);

                    final startTime = _formatTime(timeSlot.startTime);
                    final endTime = _formatTime(timeSlot.endTime);

                    final isDisabled = !isAvailable || hasConflict || emptySeats <= 0;

                    return GestureDetector(
                      onTap: isDisabled ? null : () {
                        context.read<ChildrenCubit>().selectTimeSlot(index, slotId);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDisabled
                              ? context.colors.grey.withOpacity(0.3)
                              : isSelected
                              ? context.colors.primary
                              : context.colors.onPrimary,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isDisabled
                                ? context.colors.grey.withOpacity(0.3)
                                : isSelected
                                ? context.colors.primary
                                : context.colors.grey.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  "$startTime - $endTime"
                                      .s(14)
                                      .w(600)
                                      .c(isDisabled
                                      ? context.colors.grey
                                      : isSelected
                                      ? Colors.white
                                      : context.colors.title),
                                  4.kh,
                                  "$emptySeats seats left"
                                      .s(11)
                                      .w(400)
                                      .c(isDisabled
                                      ? context.colors.grey
                                      : isSelected
                                      ? Colors.white.withOpacity(0.8)
                                      : context.colors.grey),
                                ],
                              ),
                            ),
                            if (isDisabled)
                              Positioned(
                                top: 4.h,
                                right: 4.w,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: hasConflict
                                        ? Colors.orange
                                        : context.colors.primary.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: (hasConflict
                                      ? "Conflict"
                                      : emptySeats <= 0
                                      ? "Full"
                                      : "Unavailable")
                                      .s(9)
                                      .w(500)
                                      .c(Colors.white),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else if (!state.isLoading) ...[
              // No slots available for selected date
              Center(
                child: Padding(
                  padding: EdgeInsets.all(32.h),
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 48.w,
                        color: context.colors.grey,
                      ),
                      16.kh,
                      "No available slots for this date"
                          .s(16)
                          .w(500)
                          .c(context.colors.grey),
                    ],
                  ),
                ),
              ),
            ],

            if (availableDates.isEmpty && !state.isLoading) ...[
              // No slots available at all
              Center(
                child: Padding(
                  padding: EdgeInsets.all(32.h),
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 48.w,
                        color: context.colors.grey,
                      ),
                      16.kh,
                      "No available schedules"
                          .s(16)
                          .w(500)
                          .c(context.colors.grey),
                    ],
                  ),
                ),
              ),
            ],

            24.kh,

            // Book button
            CommonButton.elevated(
              text: "BOOK",
              onPressed: (selectedScheduleId == null ||
                  selectedScheduleId!.isEmpty ||
                  state.isLoading)
                  ? null
                  : () {
                Navigator.pop(context);
                context.router.push(const BookingCompleteRoute());
              },
            ),
          ],

          12.kh,
        ],
      ),
    );
  }
}