import 'dart:convert';

import 'package:lumi_pass/feature/courses/data/model/course/course_data.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class PaymentMethodDialog {
  // Static method, now takes CourseData as an argument
  static void show(
      BuildContext context,
      Function(String) onSelectedPaymentMethod,
      CourseData courseData,
      dynamic userDataSource,
      dynamic tokenSource) {
    String selectedPaymentMethod = ''; // Local state inside the dialog
    int? index;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(24), right: Radius.circular(24)),
                color: ChessColors.greyG800,
              ),
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 20),
                      height: 6,
                      width: 34,
                      decoration: BoxDecoration(
                        borderRadius: ChessRadius.radiusXl,
                        color: ChessColors.greyG900,
                      ),
                    ),
                    const Text(
                      'To\'lov usulini tanlang',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          index = 1;
                          selectedPaymentMethod = 'Click';
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: ChessColors.greyG900,
                          border: Border.all(
                              width: 1,
                              color: index == 1
                                  ? ChessColors.black
                                  : const Color(0xffECECEC)),
                          borderRadius: ChessRadius.radiusSm,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              ChessUiKitAssets.images.clickImage
                                  .svg(fit: BoxFit.none),
                              const Spacer(),
                              Radio<String>(
                                value: 'Click',
                                groupValue: selectedPaymentMethod,
                                activeColor: const Color(0xff00A76F),
                                onChanged: (String? value) {
                                  setState(() {
                                    selectedPaymentMethod = value!;
                                    index = 1;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          index = 2;
                          selectedPaymentMethod = 'Payme';
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: ChessColors.greyG900,
                          border: Border.all(
                            width: 1,
                            color: index == 2
                                ? ChessColors.black
                                : const Color(0xffECECEC),
                          ),
                          borderRadius: ChessRadius.radiusSm,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              ChessUiKitAssets.images.paymeImage
                                  .svg(width: 40, height: 24),
                              const Spacer(),
                              Radio<String>(
                                value: 'Payme',
                                groupValue: selectedPaymentMethod,
                                activeColor: const Color(0xff00A76F),
                                onChanged: (String? value) {
                                  setState(() {
                                    selectedPaymentMethod = value!;
                                    index = 2;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: ChessButton.primary(
                        onPressed: selectedPaymentMethod.isEmpty
                            ? null
                            : () async {
                                // Capture the NavigatorState before the async operations
                                final navigator = Navigator.of(context);

                                if (selectedPaymentMethod == 'Click') {
                                  // Click payment logic
                                  final userId =
                                      await userDataSource.getUserId();
                                  final courseId = courseData.id;

                                  final url = Uri.parse(
                                      "https://my.click.uz/services/pay?service_id=36345&merchant_id=44527&amount=${courseData.price}&transaction_param=${courseId}_$userId");

                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(
                                      url,
                                      mode: LaunchMode.externalApplication,
                                    );
                                    // Close the bottom sheet after the URL is launched
                                    navigator
                                        .pop(); // Use the captured NavigatorState
                                  } else {
                                    // Handle the case where the URL cannot be launched
                                  }
                                } else if (selectedPaymentMethod == 'Payme') {
                                  // Payme payment logic
                                  final userId =
                                      await userDataSource.getUserId();
                                  final token = await tokenSource.getToken();

                                  final postData = {
                                    "user": userId,
                                    "course": courseData.id,
                                    "amount": courseData.price,
                                  };

                                  final response = await http.post(
                                    Uri.parse(
                                        "https://api.sg.glmv.dev/api/orders"),
                                    headers: {
                                      "Content-Type": "application/json",
                                      "Authorization": "Bearer $token",
                                    },
                                    body: jsonEncode(postData),
                                  );

                                  if (response.statusCode == 201) {
                                    final courseId = courseData.id;
                                    final int lastPrice =
                                        courseData.price * 100;
                                    final encodedParams = base64.encode(utf8.encode(
                                        "m=6705126bc628bf0c13f0fbb9;ac.course_id=$courseId;ac.user_id=$userId;a=$lastPrice"));
                                    final url = Uri.parse(
                                        "https://checkout.paycom.uz/$encodedParams");

                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(
                                        url,
                                        mode: LaunchMode.externalApplication,
                                      );
                                      // Close the bottom sheet after the URL is launched
                                      navigator
                                          .pop(); // Use the captured NavigatorState
                                    } else {
                                      // Handle the case where the URL cannot be launched
                                    }
                                  } else {
                                    // Handle errors from the POST request
                                  }
                                }
                              },
                        label: 'To\'lov qilish',
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
