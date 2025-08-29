import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/widget/common_button.dart';

class GetTicketBottomsheet extends StatefulWidget {
  const GetTicketBottomsheet({super.key});

  @override
  State<GetTicketBottomsheet> createState() => _GetTicketBottomsheetState();
}

class _GetTicketBottomsheetState extends State<GetTicketBottomsheet> {
  DateTime selectedDate = DateTime.now();
  int selectedTimeIndex = 0;

  List<DateTime> _generateDates() {
    List<DateTime> dates = [];
    DateTime startDate = DateTime.now();
    for (int i = 0; i < 30; i++) {
      // Show next 30 days
      dates.add(startDate.add(Duration(days: i)));
    }
    return dates;
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  final List<Map<String, dynamic>> timeSlots = [
    {'time': '11:00 - 13:00', 'slots': 16, 'isBooked': false},
    {'time': '11:00 - 13:00', 'slots': 16, 'isBooked': true},
    {'time': '11:00 - 13:00', 'slots': 16, 'isBooked': false},
    {'time': '11:00 - 13:00', 'slots': 16, 'isBooked': false},
    {'time': '11:00 - 13:00', 'slots': 16, 'isBooked': false},
    {'time': '11:00 - 13:00', 'slots': 16, 'isBooked': false},
    {'time': '11:00 - 13:00', 'slots': 16, 'isBooked': false},
    {'time': '11:00 - 13:00', 'slots': 16, 'isBooked': false},
  ];

  @override
  Widget build(BuildContext context) {
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

          // Horizontal Calendar
          SizedBox(
            height: 70.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _generateDates().length,
              itemBuilder: (context, index) {
                final dates = _generateDates();
                final date = dates[index];
                final isSelected = selectedDate.day == date.day &&
                    selectedDate.month == date.month &&
                    selectedDate.year == date.year;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate = date;
                    });
                  },
                  child: Container(
                    width: 60.w,
                    margin: EdgeInsets.only(right: 12.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.colors.primary
                          : context.colors.onPrimary,
                      borderRadius: BorderRadius.circular(16.r),
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

          // Time slots grid
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
              itemCount: timeSlots.length,
              itemBuilder: (context, index) {
                final timeSlot = timeSlots[index];
                final isSelected = selectedTimeIndex == index;
                final isBooked = timeSlot['isBooked'] as bool;

                return GestureDetector(
                  onTap: isBooked
                      ? null
                      : () {
                          setState(() {
                            selectedTimeIndex = index;
                          });
                        },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isBooked
                          ? context.colors.grey.withOpacity(0.4)
                          : isSelected
                              ? context.colors.primary
                              : context.colors.onPrimary,
                      borderRadius: BorderRadius.circular(12.r),
                      border: isBooked
                          ? null
                          : Border.all(
                              color: isSelected
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
                              timeSlot['time']
                                  .toString()
                                  .s(16)
                                  .w(600)
                                  .c(isBooked
                                      ? context.colors.title
                                      : isSelected
                                          ? Colors.white
                                          : context.colors.title),
                              4.kh,
                              "${timeSlot['slots']} slots left"
                                  .s(12)
                                  .w(400)
                                  .c(isBooked
                                      ? context.colors.title
                                      : isSelected
                                          ? Colors.white.withOpacity(0.8)
                                          : context.colors.grey),
                            ],
                          ),
                        ),
                        if (isBooked)
                          Positioned(
                            top: 8.h,
                            right: 8.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: context.colors.primary,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: "booked"
                                  .s(10)
                                  .w(500)
                                  .c(context.colors.onPrimary),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          24.kh,

          CommonButton.elevated(
            text: "BOOK",
            onPressed: () {
              Navigator.pop(context);
              context.router.push(const BookingCompleteRoute());
            },
          ),

          12.kh,
        ],
      ),
    );
  }
}
