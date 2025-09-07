import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/widgets/choose_child_bottomsheet.dart';
import 'package:lumi_pass/presentation/app/widgets/base_box.dart';

@RoutePage()
class ClassDetailPage extends StatefulWidget {
  const ClassDetailPage({super.key, required this.classModel});

  final HomClass classModel;

  @override
  State<ClassDetailPage> createState() => _ClassDetailPageState();
}

class _ClassDetailPageState extends State<ClassDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            width: 1.sw,
            height: 250.h,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.only(bottomLeft: Radius.circular(16.r), bottomRight: Radius.circular(16.r)),
                    child: Assets.images.defaultImage.image(
                      width: 1.sw,
                      height: 250.h,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Positioned(
                    top: (MediaQuery.of(context).viewPadding.top + 16.h),
                    right: 16.w,
                    child: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          size: 28.h,
                          CupertinoIcons.heart,
                          color: context.colors.onPrimary,
                        ))),
                Positioned(
                  top: (MediaQuery.of(context).viewPadding.top + 16.h),
                  left: 16.w,
                  child: BaseBox(
                    onTap: () => context.router.pop(),
                    padding: EdgeInsets.zero,
                    radius: 8.r,
                    width: 32.w,
                    height: 32.h,
                    child: Center(
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    16.kh,
                    (widget.classModel.title ?? "").s(20).w(600),
                    16.kh,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            BaseBox(
                              backgroundColor: context.colors.primary.withOpacity(0.2),
                              width: 51.w,
                              height: 51.h,
                              child: Center(child: Assets.icons.locationPrimary.svg()),
                            ),
                            16.kw,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                (widget.classModel.branch?.title ?? "").s(14).w(500),
                                8.kh,
                                "36 Guild Street London, UK ".s(12).w(400).c(context.colors.primary)
                              ],
                            )
                          ],
                        ),
                        16.kh,
                        Row(
                          children: [
                            BaseBox(
                              backgroundColor: context.colors.primary.withOpacity(0.2),
                              width: 51.w,
                              height: 51.h,
                              child: Center(child: Assets.icons.time.svg()),
                            ),
                            16.kw,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                "Duration".s(12).w(500).c(context.colors.grey),
                                8.kh,
                                ("${((widget.classModel.duration ?? 0) / 60).toInt()} hours")
                                    .s(12)
                                    .w(400)
                                    .c(context.colors.primary)
                              ],
                            )
                          ],
                        ),
                        16.kh,
                        Row(
                          children: [
                            BaseBox(
                              backgroundColor: context.colors.primary.withOpacity(0.2),
                              width: 51.w,
                              height: 51.h,
                              child: Center(child: Assets.icons.availablitiy.svg()),
                            ),
                            16.kw,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                "Gender and Age".s(15).w(500),
                                8.kh,
                                "Only for boys, ${widget.classModel.minAge ?? 0}-${widget.classModel.maxAge ?? 0} y.o"
                                    .s(12)
                                    .w(400)
                                    .c(const Color(0xFFEF603D))
                              ],
                            )
                          ],
                        ),
                        24.kh,
                        "About Event".s(18).w(600),
                        16.kh,
                        (widget.classModel.description ?? "").s(16).w(400).c(context.colors.title),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
            child: CommonButton.elevated(
              text: "Book for ${widget.classModel.price ?? 0}",
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) {
                      return  ChooseChildBottomsheet();
                    });
              },
              icon: Assets.icons.coinLumi.image(width: 24.w, height: 24.h),
            ),
          )
        ],
      ),
    );
  }
}
