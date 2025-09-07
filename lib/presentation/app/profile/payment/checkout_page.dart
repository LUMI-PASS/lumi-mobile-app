import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:lumi_pass/common/widget/common_text_filed.dart';
import 'package:lumi_pass/presentation/app/widgets/bottom_box.dart';
import 'package:lumi_pass/presentation/app/widgets/card_widget.dart';

@RoutePage()
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController couponController = TextEditingController();

  @override
  void dispose() {
    couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BaseAppBar(
        title: "Check Out",
      ),
      body: Column(
        children: [
          const CardWidget(),
          100.kh,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              spacing: 10,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: CommonTextField(
                      controller: couponController,
                      prefixIcon: Assets.icons.coupon.svg(width: 15.w, height: 15.w),
                      hint: "Apply Coupon",
                    ),
                  ),
                ),
                SizedBox(
                  width: 90.w,
                  child: CommonButton.elevated(
                    text: "Apply",
                  ),
                ),
              ],
            ),
          ),
          46.kh,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    "Subtotal".s(17).w(400).c(const Color(0xFF3C3E56)),
                    "\$58.96".s(17).w(400).c(const Color(0xFF3C3E56)),
                  ],
                ),
                10.kh,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    "Delivery".s(17).w(400).c(const Color(0xFF3C3E56)),
                    "\$3.59".s(17).w(400).c(const Color(0xFF3C3E56)),
                  ],
                ),
                20.kh,
                Divider(
                  color: Theme.of(context).primaryColor,
                ),
                20.kh,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    "Total".s(22).w(500).c(context.colors.black),
                    "\$62.55".s(22).w(500).c(context.colors.black),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          BottomBox(
            child: CommonButton.elevated(
              onPressed: () {},
              text: "Check Out",
              textColor: Theme.of(context).cardColor,
            ),
          ),
        ],
      ),
    );
  }
}
