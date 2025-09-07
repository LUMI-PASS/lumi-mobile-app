import 'package:auto_route/annotations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/constants/constants.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/widget/loading_view.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/cubit/home_cubit.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/cubit/home_state.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/banner_lesson_widgets.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/catgory_item_widget.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/class_item_widget.dart';
import 'package:lumi_pass/presentation/app/widgets/base_box.dart';

@RoutePage()
class HomePage extends BasePage<HomeCubit, HomeBuildable, HomeListenable> {
  const HomePage({super.key});

  @override
  void init(BuildContext context) {
    context.read<HomeCubit>().getHome();
    super.init(context);
  }

  @override
  Widget builder(context, state) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).viewPadding.top + 16.h,
            right: 16.w,
            left: 16.w),
        child: state.isLoading
            ? LoadingView()
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Assets.images.defacultAvatar.image(
                          width: 40.w,
                          height: 40.h,
                        ),
                        8.kw,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            "Hello, ".s(14),
                            (state.homeModel?.data?.forUser?.firstName ??
                                    "User")
                                .s(14)
                                .c(context.colors.primary),
                          ],
                        ),
                        const Spacer(),
                        Assets.icons.notification
                            .svg(width: 24.w, height: 24.h),
                      ],
                    ),
                    16.kh,
                    "Home".s(24).w(600),
                    Row(
                      children: [
                        "1 class today".s(12).w(400).c(context.colors.primary),
                        const Spacer(),
                        InkWell(
                          onTap: () {},
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              "See all".s(12).w(400).c(context.colors.primary),
                              Assets.icons.arrowRight.svg()
                            ],
                          ),
                        )
                      ],
                    ),
                    16.kh,
                    if (state.homeModel?.data?.upcomingClass != null)
                      BannerLessonWidgets(
                        homBanner: (state.homeModel!.data!.upcomingClass!),
                      ),
                    if ((state.homeModel?.data?.banners ?? []).isNotEmpty) ...[
                      16.kh,
                      CarouselSlider(
                        options: CarouselOptions(height: 180.h, autoPlay: true),
                        items: (state.homeModel?.data?.banners ?? []).map((i) {
                          return Builder(
                            builder: (BuildContext context) {
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12.r)),
                                  child: CachedNetworkImage(
                                    width: 1.sw * 0.7,
                                    fit: BoxFit.cover,
                                    imageUrl:
                                        ("${Constants.assetsUrl}${i.url ?? " "}"),
                                    errorWidget: (context, error, state) =>
                                        Assets.images.defaultImage.image(),
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ],
                    16.kh,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        "Popular Categories".s(14).w(600),
                        InkWell(
                          onTap: () {},
                          child: "See all".s(10).w(400).c(context.colors.grey),
                        )
                      ],
                    ),
                    8.kh,
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                          children: List.generate(
                              (state.homeModel?.data?.categories?.data ?? [])
                                  .length,
                              (index) => CategoryItemWidget(
                                    homeCategoryModel: ((state.homeModel?.data
                                            ?.categories?.data ??
                                        [])[index]),
                                  ))),
                    ),
                    16.kh,
                    if ((state.homeModel?.data?.newClasses?.data ?? [])
                        .isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          "Newly Added Classes".s(14).w(600),
                          InkWell(
                            onTap: () {},
                            child:
                                "See all".s(10).w(400).c(context.colors.grey),
                          )
                        ],
                      ),
                      8.kh,
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                            children: List.generate(
                                (state.homeModel?.data?.newClasses?.data ?? [])
                                    .length,
                                (index) => ClassItemWidget(
                                      homClass: (state.homeModel?.data
                                              ?.nearClasses?.data ??
                                          [])[index],
                                    ))),
                      ),
                      16.kh,
                    ],
                    "Near you".s(14).w(600),
                    8.kh,
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                          children: List.generate(
                              (state.homeModel?.data?.nearClasses?.data ?? [])
                                  .length,
                              (index) => Padding(
                                    padding: EdgeInsets.only(bottom: 8.h),
                                    child: ClassItemWidget(
                                      width: 1.sw - 32.w,
                                      homClass: (state.homeModel?.data
                                              ?.nearClasses?.data ??
                                          [])[index],
                                    ),
                                  ))),
                    ),
                    16.kh,
                  ],
                ),
              ),
      ),
    );
  }
}
