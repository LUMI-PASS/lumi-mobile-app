import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:lumi_pass/presentation/app/widgets/bottom_box.dart';

@RoutePage()
class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final List<Map<String, dynamic>> cards = [
    {"image": Assets.icons.mastercard.svg(), "title": "Credit Card"},
    {"image": Assets.icons.paypal.svg(), "title": "PayPal"},
    {"image": Assets.icons.google.svg(), "title": "Google Pay"},
  ];

  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BaseAppBar(title: "Payment Method"),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          40.kh,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: "Payment Via".s(25).w(600),
          ),
          28.kh,
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: cards.length,
              separatorBuilder: (_, __) => 25.kh,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedIndex;
                return Material(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _selectedIndex = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).cardColor,
                        border: Border.all(
                          width: 1,
                          color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          cards[index]['image'] as Widget,
                          24.kw,
                          "${cards[index]['title']}".s(18).w(500),
                          const Spacer(),
                          Radio<int>(
                            value: index,
                            groupValue: _selectedIndex,
                            onChanged: (i) {
                              if (i == null) return;
                              setState(() => _selectedIndex = i);
                            },
                            activeColor: Theme.of(context).primaryColor,
                            toggleable: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          BottomBox(
            child: CommonButton.elevated(
              onPressed: () {
                context.router.push(const PaymentCardsRoute());
              },
              text: "Payment",
              textColor: Theme.of(context).cardColor,
            ),
          ),
        ],
      ),
    );
  }
}
