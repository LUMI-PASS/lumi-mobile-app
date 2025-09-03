import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/profile/cubit/profile_cubit.dart';
import 'package:lumi_pass/presentation/app/widgets/base_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../common/router/app_router.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  StreamSubscription<Locale>? _localeSubscription;
  final Storage storage = getIt<Storage>();

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
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              32.kh,
              "My Account".s(32).w(700).c(context.colors.black ?? Colors.black),
              32.kh,
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildProfileCatalog(
                        Assets.icons.profile.svg(),
                        "Account Information",
                        "Change your Account information",
                        false,
                        context,
                        onTap: () => context.router.push(ProfileDetailRoute()),
                      ),
                      16.kh,
                      _buildProfileCatalog(
                        Assets.icons.group.svg(),
                        "Your children",
                        "Change your children information",
                        false,
                        context,
                        onTap: () => context.router.push(const ChildrenRoute()),
                      ),
                      16.kh,

                      // Wallets
                      _buildProfileCatalog(
                        Assets.icons.walletUnselected
                            .svg(color: context.colors.primary),
                        "Wallets",
                        "Buy more coins for your child",
                        false,
                        context,
                        onTap: () {
                          // Navigate to wallets page
                        },
                      ),
                      16.kh,

                      // Attendance history
                      _buildProfileCatalog(
                        Assets.icons.attendence.svg(),
                        "Attendance history",
                        "View your attendance",
                        false,
                        context,
                        onTap: () {
                          // Navigate to attendance history
                        },
                      ),
                      16.kh,

                      // Payment Methods
                      _buildProfileCatalog(
                        Assets.icons.cards.svg(),
                        "Payment Methods",
                        "Add Your Credit / Credit Cards",
                        false,
                        context,
                        onTap: () {
                          // Navigate to payment methods
                        },
                      ),
                      16.kh,

                      _buildProfileCatalog(
                        Icon(Icons.help_outline,
                            color: context.colors.primary, size: 24.w),
                        "FAQ",
                        "Find an answer to all your questions",
                        false,
                        context,
                        onTap: () {
                          // Navigate to FAQ
                        },
                      ),
                      16.kh,

                      // Log out
                      _buildProfileCatalog(
                        Icon(Icons.logout,
                            color: context.colors.primary, size: 24.w),
                        "Log out",
                        "Log out from your account",
                        true,
                        context,
                        onTap: () async {
                          await storage.logout();
                          context.router.replaceAll([LoginRoute()]);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildProfileCatalog(Widget icon, String title, String subtitle,
    bool isLast, BuildContext context,
    {Function? onTap, bool? isLoading}) {
  return BaseBox(
    padding: EdgeInsets.all(16.w),
    child: InkWell(
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      onTap: () => onTap?.call(),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: (context.colors.primary ?? Colors.purple).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: icon,
            ),
          ),
          16.kw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title.s(16).w(600).c(context.colors.black ?? Colors.black),
                4.kh,
                subtitle
                    .s(14)
                    .w(400)
                    .c(context.colors.title.withOpacity(0.6) ?? Colors.grey),
              ],
            ),
          ),
          8.kw,
          isLoading ?? false
              ? SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.colors.primary,
                  ),
                )
              : Icon(
                  Icons.arrow_forward_ios,
                  size: 16.w,
                  color: context.colors.black.withOpacity(0.4) ?? Colors.grey,
                ),
        ],
      ),
    ),
  );
}
