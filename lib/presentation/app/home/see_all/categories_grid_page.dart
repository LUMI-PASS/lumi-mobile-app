import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/catgory_item_widget.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/search_widgets.dart';

/// "View all" grid for the home categories row. Categories arrive in one
/// unpaginated call, so this is a plain grid of everything we already have.
@RoutePage()
class CategoriesGridPage extends StatelessWidget {
  const CategoriesGridPage({super.key, required this.categories});

  final List<HomCategory> categories;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SearchTopBar(
              title: 'all_categories'.tr(),
              onBack: () => context.router.maybePop(),
            ),
            12.verticalSpace,
            Expanded(
              child: categories.isEmpty
                  ? const SearchEmptyView()
                  : GridView.builder(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 20.h,
                        mainAxisExtent: 104.h,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) => CategoryItemWidget(
                        key: ValueKey(categories[index].id ?? index),
                        homeCategoryModel: categories[index],
                        padding: EdgeInsets.zero,
                        onTap: () =>
                            context.router.push(const SearchComingSoonRoute()),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
