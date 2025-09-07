import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:lumi_pass/presentation/app/widgets/bottom_box.dart';

@RoutePage()
class PaymentCardsPage extends StatefulWidget {
  const PaymentCardsPage({super.key});

  @override
  State<PaymentCardsPage> createState() => _PaymentCardsPageState();
}

class _PaymentCardsPageState extends State<PaymentCardsPage> {
  int currentCardIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BaseAppBar(
        title: "Payment",
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          54.kh,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: "Choose Card".s(25).w(600),
          ),
          54.kh,
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: SizedBox(
              height: 140.h,
              child: Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 50.h,
                    margin: const EdgeInsets.only(right: 25),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        width: 2,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                    child: Icon(
                      Icons.add,
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      separatorBuilder: (context, index) => 22.kw,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              currentCardIndex = index;
                            });
                          },
                          child: Container(
                            width: 195.w,
                            height: 140.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color(0xFF3C3E56),
                              border: Border.all(
                                width: 3,
                                color:
                                    currentCardIndex == index ? const Color(0xFF176FF3) : Theme.of(context).cardColor,
                              ),
                            ),
                            child: Column(
                              children: [
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                    ),
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Assets.icons.card.svg(),
                                        "**** 0411".s(11).w(400).c(Theme.of(context).cardColor),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20.0, right: 15, top: 15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          "Mastercard".s(12).w(600).c(Theme.of(context).cardColor),
                                          "Platinum".s(10).w(400).c(Theme.of(context).cardColor),
                                        ],
                                      ),
                                      "10/26".s(10).w(400).c(Theme.of(context).cardColor),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20.0, right: 15, top: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      "560 000, soum".s(12).w(600).c(Theme.of(context).cardColor),
                                      Assets.icons.mastercard.svg(),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
          const Spacer(),
          BottomBox(
            child: CommonButton.elevated(
              onPressed: () => context.router.push(
                const AddNewCardRoute(),
              ),
              text: "Use This Card",
              textColor: Theme.of(context).cardColor,
            ),
          ),
        ],
      ),
    );
  }
}
