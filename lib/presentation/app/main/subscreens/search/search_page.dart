import 'package:auto_route/annotations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/subwidgets/pocket_widget.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/catgory_item_widget.dart';
import 'package:lumi_pass/presentation/app/widgets/base_box.dart';

@RoutePage()
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
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
            "Explore".s(32).w(600),
            24.kh,
            Row(
              children: [
                Flexible(
                    child: SizedBox(
                  height: 64.h,
                  child: TextField(
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 24),
                          hintText: "Search",
                          fillColor: context.colors.onPrimary,
                          filled: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18.r),
                              borderSide: BorderSide.none),
                          prefixIcon: Icon(
                            CupertinoIcons.search,
                            color: Colors.grey,
                          ),
                          hintStyle: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: context.colors.grey))),
                )),
                8.kw,
                BaseBox(
                  padding: EdgeInsets.zero,
                  child: Icon(
                    CupertinoIcons.sort_down,
                    color: context.colors.onPrimary,
                  ),
                  backgroundColor: context.colors.primary,
                  width: 62.w,
                  height: 62.h,
                  radius: 14.r,
                ),
              ],
            ),
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
                    return CategoryItemWidget(homeCategoryModel: HomCategory());
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
