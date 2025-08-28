import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flexobo/common/extensions/sizedbox_extensions.dart';
import 'package:flexobo/common/extensions/text_extensions.dart';
import 'package:flexobo/common/extensions/theme_extensions.dart';
import 'package:flexobo/common/gen/assets.gen.dart';
import 'package:flexobo/common/gen/strings.dart';
import 'package:flexobo/common/router/app_router.dart';
import 'package:flexobo/common/widget/custom_dialog.dart';
import 'package:flexobo/presentation/app/main/subscreens/search/provider/search_provider.dart';
import 'package:flexobo/presentation/app/widgets/base_box.dart';
import 'package:flexobo/presentation/profile/language/lang/language_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  StreamSubscription<Locale>? _localeSubscription;

  @override
  void initState() {
    _localeSubscription = LanguageService().localeStream.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _localeSubscription?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ProfilePage oldWidget) {
    setState(() {});
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.read<SearchProvider>();
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).padding.top, horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 16.kh,
            Strings.profileTitle.s(28).w(600),
            16.kh,
            BaseBox(
                child: Row(
              children: [
                Assets.images.defacultAvatar.image(width: 56.w, height: 56.h),
                16.kw,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      (profileProvider.profileModel?.fio ?? "")
                          .s(20)
                          .w(500)
                          .m(1),
                      (profileProvider.profileModel?.phoneNumber ??
                              (profileProvider.profileModel?.email ?? ""))
                          .s(16)
                          .w(500)
                          .c(context.colors.title)
                          .m(1)
                          .o(TextOverflow.ellipsis)
                    ],
                  ),
                ),
                Assets.icons.arrowRightExpand.svg(),
              ],
            )),
            16.kh,
            BaseBox(
                child: Column(
              children: [
                _buildProfileCatalog(
                    Assets.icons.garage.svg(), Strings.myGarage, false,
                    onTap: () => context.router.push(const MyGarageRoute())),
                _buildProfileCatalog(
                    Assets.icons.routing.svg(), Strings.myUpdates, false,
                    onTap: () => context.router.push(DocumentRoute())),
                _buildProfileCatalog(
                    Assets.icons.language.svg(), Strings.language, false,
                    onTap: () => context.router.push(const LanguagesRoute())),
                // _buildProfileCatalog(Assets.icons.language.svg(),
                //     Strings.incomingRequests, false,
                //     onTap: () =>
                //         context.router.push(IncomingRequestsRoute(postId: ""))),
                _buildProfileCatalog(
                    Assets.icons.support.svg(), Strings.contactCenter, false,
                    onTap: () =>
                        context.router.push(const ContactCentreRoute())),
                _buildProfileCatalog(
                    const Icon(Icons.logout), Strings.logoutTitle, true,
                    onTap: () {
                  CommonDialogView.show(
                      barrierDismissible: true,
                      loading: profileProvider.isLoading,
                      context: context,
                      title: "${Strings.logoutTitle}!",
                      description: Strings.logoutConfirmation,
                      primaryButtonText: Strings.noTitle,
                      secondaryButtonText: Strings.logoutTitle,
                      onSecondaryButtonPressed: () async {
                        await profileProvider.logout();
                        profileProvider.disposeFields();
                        // Future.delayed(const Duration(seconds: 2))
                        //     .then((value) {
                        context.router.replaceAll([LoginRoute()]);
                        // });
                      });
                }),
              ],
            ))
          ],
        ),
      ),
    );
  }
}

Widget _buildProfileCatalog(Widget icon, String title, bool isLast,
    {Function? onTap, bool? isLoading}) {
  return InkWell(
    overlayColor: const WidgetStatePropertyAll(Colors.transparent),
    onTap: () => onTap?.call(),
    child: Column(
      children: [
        Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: const Color(0xFFCAD9E2).withOpacity(0.4),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: icon,
              ),
            ),
            8.kw,
            title.s(14).w(500),
            4.kh,
            const Spacer(),
            4.kh,
            isLoading ?? false
                ? const CircularProgressIndicator()
                : Assets.icons.arrowRightExpand.svg(),
          ],
        ),
        if (!isLast)
           Padding(
             padding: EdgeInsets.only(left: 49.w),
             child: const Divider(
              color: Color(0xFFEAF0F3),
                       ),
           )
      ],
    ),
  );
}
