import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/subwidgets/pocket_widget.dart';

import '../../../../../common/gen/assets.gen.dart';

@RoutePage()
class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).viewPadding.top + 16,
            left: 16,
            right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            "Wallet".s(32).w(600),
            24.kh,
            Row(
              children: [
                "Your Balance".s(24).w(600),
                Spacer(),
                "50".s(24).w(600),
                8.kw,
                Assets.icons.coinLumi.image(
                  width: 35,
                  height: 35,
                )
              ],
            ),
            24.kh,
            "Choose to top up".s(24).w(600),
            24.kh,
            Expanded(
              child: GridView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: 4,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8),
                  itemBuilder: (context, index) {
                    return const PocketWidget();
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
