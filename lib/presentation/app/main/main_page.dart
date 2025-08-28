import 'package:auto_route/auto_route.dart';
import 'package:flexobo/common/base/base_page.dart';
import 'package:flexobo/common/extensions/sizedbox_extensions.dart';
import 'package:flexobo/common/extensions/theme_extensions.dart';
import 'package:flexobo/common/gen/assets.gen.dart';
import 'package:flexobo/common/router/app_router.dart';
import 'package:flexobo/data/api_model/load_general/load_general_model.dart';
import 'package:flexobo/data/api_model/trip_general/trip_general_model.dart';
import 'package:flexobo/presentation/app/main/subscreens/document/cubit/document_cubit.dart';
import 'package:flexobo/presentation/app/main/subscreens/document/cubit/document_state.dart';
import 'package:flexobo/presentation/app/main/subscreens/document/document_page.dart';
import 'package:flexobo/presentation/app/main/subscreens/search/provider/search_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

@RoutePage()
class MainPage
    extends BasePage<DocumentCubit, DocumentBuildable, DocumentListenable> {
  const MainPage({super.key});

  @override
  Widget builder(context, state) {
    return AutoTabsRouter(
      routes: [
        const SearchRoute(),
        DocumentRoute(),
        const ChatRoute(),
        const ProfileRoute(),
      ],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        return Scaffold(
          body: child,
          bottomNavigationBar: BottomAppBar(
            color: context.colors.primary,

            child: Container(
              padding: EdgeInsets.only(bottom: 8.h),
              height: 75.h,
              decoration: BoxDecoration(
                color: context.colors.primary,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    context,
                    index: 0,
                    currentIndex: tabsRouter.activeIndex,
                    onPressed: () => tabsRouter.setActiveIndex(0),
                    activeIcon: Assets.icons.homeSelected.svg(
                      width: 24.w,
                      height: 24.h,
                    ),
                    inactiveIcon: Assets.icons.unselectHome.svg(
                      width: 24.w,
                      height: 24.h,
                    ),
                  ),
                  _buildNavItem(
                    context,
                    index: 1,
                    currentIndex: tabsRouter.activeIndex,
                    onPressed: () => tabsRouter.setActiveIndex(1),
                    activeIcon: Assets.icons.truckSelected.svg(
                      width: 24.w,
                      height: 24.h,
                    ),
                    inactiveIcon: Assets.icons.truckUnselected.svg(
                      width: 24.w,
                      height: 24.h,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    width: 46.w,
                    height: 46.h,
                    decoration: BoxDecoration(
                        color: context.colors.primary2, shape: BoxShape.circle),
                    child: Center(
                      child: InkWell(
                          onTap: () =>
                              context.router.push(AddPostRoute()).then((value) {
                                print("value in main Page :: $value");
                                state.index == 1
                                    ? context.read<DocumentCubit>().updateList(
                                    tripModel: value as TripGeneralModel?,
                                    isEditing: false)
                                    : context.read<DocumentCubit>().updateList(
                                    loadModel: value as LoadGeneralModel?,
                                    isEditing: false);
                              }),
                          child: Assets.icons.add.svg(width: 20.w, height: 20.h)),
                    ),
                  ),
                  _buildNavItem(
                    context,
                    index: 2,
                    currentIndex: tabsRouter.activeIndex,
                    onPressed: () => tabsRouter.setActiveIndex(2),
                    activeIcon: Assets.icons.selectedChat.svg(
                      width: 24.w,
                      height: 24.h,
                    ),
                    inactiveIcon: Assets.icons.unselectComment.svg(
                      width: 24.w,
                      height: 24.h,
                    ),
                  ),
                  _buildNavItem(
                    context,
                    index: 3,
                    currentIndex: tabsRouter.activeIndex,
                    onPressed: () => tabsRouter.setActiveIndex(3),
                    activeIcon: Assets.icons.selectedProfile.svg(
                      width: 24.w,
                      height: 24.h,
                    ),
                    inactiveIcon: Assets.icons.unselecProfile.svg(
                      width: 24.w,
                      height: 24.h,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
      BuildContext context, {
        required int index,
        required int currentIndex,
        required VoidCallback onPressed,
        required Widget activeIcon,
        required Widget inactiveIcon,
      }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onPressed.call(),
      child: isSelected ? activeIcon : inactiveIcon,
    );
  }
}