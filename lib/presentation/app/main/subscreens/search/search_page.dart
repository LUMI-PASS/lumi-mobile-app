import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:lumi_pass/common/widget/common_text_filed.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/catgory_item_widget.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/filter_bottom_sheet.dart';
import 'package:lumi_pass/presentation/app/widgets/bottom_box.dart';

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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  "Explore".s(30).w(600).c(context.colors.black),
                  20.kh,
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.router.push(SearchUnifiedRoute()),
                          child: CommonTextField(
                            prefixIcon: GestureDetector(
                              onTap: () => context.router.push(SearchUnifiedRoute()),
                              child: Assets.icons.search.svg(),
                            ),
                            hint: "Search",
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => FilterBottomSheet.show(context),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(context).cardColor,
                          ),
                          child: Assets.icons.filter.svg(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            12.kh,
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 40,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  return const CategoryItemWidget(homeCategoryModel: null);
                },
              ),
            ),
            BottomBox(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: CommonButton.elevated(
                  onPressed: () {},
                  text: "SEARCH ON MAP",
                  icon: Assets.icons.map.svg(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
