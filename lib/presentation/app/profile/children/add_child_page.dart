import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/common/widget/common_text_filed.dart';

@RoutePage()
class AddChildPage extends StatefulWidget {
  const AddChildPage({super.key});

  @override
  State<AddChildPage> createState() => _AddChildPageState();
}

class _AddChildPageState extends State<AddChildPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        title: "Add child",
      ),
      body: Padding(

        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            "Full Name".s(15).w(500),
            12.kh,
            CommonTextField(
              hint: "Joseph Ren",
              onChanged: (value) {},
            ),
            "Phone number".s(15).w(500),
            12.kh,
            CommonTextField(
              hint: "+998900000909",
              onChanged: (value) {},
            ),
            "Gender".s(15).w(500),
            12.kh,
            CommonTextField(
              hint: "Helicopter",
              onChanged: (value) {},
            ),
            "Location".s(15).w(500),
            12.kh,
            CommonTextField(
              hint: "Yakkasaroy st., Tashkent city",
              onChanged: (value) {},
            ),

          ],
        ),
      ),
    );
  }
}
