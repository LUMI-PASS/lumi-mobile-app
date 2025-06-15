import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/core/logging/logger.dart';
import 'package:lumi_pass/feature/base_url/app_base_url_cubit.dart';
import 'package:lumi_pass/feature/base_url/app_base_url_state.dart';
import 'package:lumi_pass/feature/profile/presentation/cubit/profile_cubit/profile_cubit.dart';
import 'package:lumi_pass/feature/profile/presentation/cubit/profile_cubit/profile_state.dart';
import 'package:lumi_pass/feature/profile/presentation/cubit/version_cubit/version_cubit.dart';
import 'package:lumi_pass/feature/profile/presentation/widget/profile_item.dart';
import 'package:lumi_pass/routing/app_router.gr.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const double expandedHeight = 150;

    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoggedOutState) {
          context.router.replaceAll([const UnauthorizedContainerRoute()]);
        }
      },
      child: Scaffold(

        body: Builder(builder: (context) {
          return const CustomScrollView(
            slivers: [
              SliverAppBar(
                surfaceTintColor: ChessColors.greyG800,
                backgroundColor: ChessColors.greyG900,
                expandedHeight: 100,
                pinned: true,
                flexibleSpace: _SliverAppBar(
                  courseTitle: 'Profil',
                  courseScore: "24",
                  height: expandedHeight,
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: _BodyContent(),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: _VersionWidget(),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _BodyContent extends StatelessWidget {
  const _BodyContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ProfileHeader(),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: ChessColors.greyG800,
            borderRadius: ChessRadius.radiusMd,
          ),
          child: Column(
            children: [
              ProfileItem(
                image: ChessUiKitAssets.icons.course.certificate.svg(
                  fit: BoxFit.none,
                  colorFilter: const ColorFilter.mode(
                    ChessColors.primaryDefault,
                    BlendMode.srcIn,
                  ),
                ),
                labelText: 'Sertifikatlarim',
                onTap: () {
                  context.router.push(const MyCertificateRoute());
                },
              ),
              Builder(builder: (dialogContext) {
                return ProfileItem(
                  image: ChessUiKitAssets.icons.profile.messageChatSquare
                      .svg(fit: BoxFit.none, color: ChessColors.primaryDefault),
                  labelText: 'Yordam',
                  onTap: () {
                    showModalBottomSheet(
                      useRootNavigator: true,
                      context: context,
                      builder: (_) => const ChessComingSoonBottomSheet(),
                    );
                  },
                );
              }),
              ProfileItem(
                image: ChessUiKitAssets.icons.profile.document
                    .svg(fit: BoxFit.none, color: ChessColors.primaryDefault),
                labelText: 'Foydalanish shartlari',
                onTap: () {
                  ChessMarkdownSheet.showPolicySheet(
                    context,
                    asset: ChessUiKitAssets.markdown.policy,
                    sheetTitle: "Foydalanuvchi shartlari",
                  );
                },
              ),
              ProfileItem(
                image: ChessUiKitAssets.icons.profile.logOut03.svg(
                  colorFilter: const ColorFilter.mode(
                    ChessColors.primaryDefault,
                    BlendMode.srcIn,
                  ),
                  fit: BoxFit.none,
                ),
                labelText: 'Ilovadan chiqish',
                onTap: () {
                  ChessNativeDialog.showConfirmationDialog(
                    context: context,
                    title: "Ilovadan chiqish",
                    message: "Haqiqatan ham ilovadan chiqmoqchimisiz?",
                    onConfirm: () {
                      context.router.pop();
                      context.read<ProfileCubit>().logout();
                    },
                    onBackTap: () => context.router.pop(),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _VersionWidget extends StatelessWidget {
  const _VersionWidget();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VersionCubit, VersionState>(
      builder: (context, state) {
        if (state is! VersionLoadedState) return const SizedBox.shrink();

        return Column(
          children: [
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: RichText(
                text: TextSpan(
                  text: "Powered by ",
                  style: context.textTheme.bodyMedium.copyWith(
                    color: ChessColors.greyG20,
                  ),
                  children: [
                    TextSpan(
                      text: "GLMS",
                      style: const TextStyle(
                        color:
                            ChessColors.primaryDefault, // Link color for GLMS
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          FirebaseAnalytics.instance.logEvent(
                            name: 'powerd_by_event',
                            parameters: {
                              'param1': 'value1',
                              'param2': 123,
                            },
                          ).then((value) {
                            logger.e('Event successfully logged');
                          }).catchError((error) {
                            logger.e('Failed to log event: $error');
                          });
                          const url = 'https://lms.glmv.dev/';
                          if (await canLaunch(url)) {
                            await launch(url);
                          }
                        },
                    ),
                    const TextSpan(
                      text: " by ",
                    ),
                    TextSpan(
                      text: "Global Move",
                      style: const TextStyle(
                        color: ChessColors
                            .primaryDefault, // Link color for Global Move
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          FirebaseAnalytics.instance.logEvent(
                            name: 'powerd_by_event',
                            parameters: {
                              'param1': 'value1',
                              'param2': 123,
                            },
                          ).then((value) {
                            logger.e('Event successfully logged');
                          }).catchError((error) {
                            logger.e('Failed to log event: $error');
                          });
                          const url = 'https://globalmove.uz/';
                          if (await canLaunch(url)) {
                            await launch(url);
                          }
                        },
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is! ProfileLoadedState) {
          return const Padding(
            padding: EdgeInsets.all(2),
            child: ChessCircularProgressIndicator(),
          );
        }
        return GestureDetector(
          onTap: () {
            context.router.push(const ProfileDetailRoute());
            FirebaseAnalytics.instance.logEvent(
              name: 'profil_event',
              parameters: {
                'param1': 'value1',
                'param2': 123,
              },
            ).then((value) {
              logger.e('Event successfully logged');
            }).catchError((error) {
              logger.e('Failed to log event: $error');
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: ChessColors.greyG800,
              borderRadius: ChessRadius.radiusMd,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  state.profileData.image == null
                      ? Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: ChessColors.greyG900,
                            borderRadius: ChessRadius.radiusSm,
                          ),
                          child: ChessUiKitAssets.icons.profile.user.svg(
                            fit: BoxFit.none,
                            color: ChessColors.greyG20,
                          ),
                        )
                      : BlocBuilder<AppBaseUrlCubit, AppBaseUrlState>(
                          builder: (context, baseUrlState) {
                            return Container(
                              height: 60,
                              width: 60,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: ChessColors.greyG900,
                              ),
                              child: ClipOval(
                                child: ChessNetworkImage(
                                  imageUrl: state.profileData.image ?? '',
                                  fit: BoxFit.cover,
                                  baseUrl: baseUrlState.baseUrl,
                                ),
                              ),
                            );
                          },
                        ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${state.profileData.firstName ?? ''} ${state.profileData.lastName ?? ''}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.headlineSemibold.copyWith(
                            color: ChessColors.greyG40,
                          ),
                        ),
                        Text(
                          state.profileData.phoneNumber?.getMaskedFormat ?? "",
                          style: context.textTheme.footnoteRegular.copyWith(
                            color: ChessColors.greyG20,
                          ),
                        )
                      ],
                    ),
                  ),
                  ChessUiKitAssets.icons.general.chevronRight.svg(
                    colorFilter: const ColorFilter.mode(
                      ChessColors.greyG20,
                      BlendMode.srcIn,
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SliverAppBar extends StatelessWidget {
  final String courseTitle;
  final String courseScore;
  final double height;

  const _SliverAppBar({
    required this.courseTitle,
    required this.courseScore,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return switch (state) {
          ProfileLoadedState() || ProfileInitState() => LayoutBuilder(
              builder: (context, constraints) {
                final dynamicSize = ChessDynamicSize(
                  context,
                  constraints: constraints,
                  expandedHeight: height,
                );

                return FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 24),
                  centerTitle: false,
                  title: Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      Positioned(
                        bottom: 16,
                        child: Text(
                          courseTitle,
                          style: context.textTheme.title3Bold.copyWith(
                            fontSize: dynamicSize.fontSize(),
                          ),
                        ),
                      ),
                      // Positioned(
                      //   bottom: 16,
                      //   right: 12,
                      //   child: Row(
                      //     children: [
                      //       ChessUiKitAssets.icons.general.queenIcon.svg(
                      //         fit: BoxFit.none,
                      //       ),
                      //       const SizedBox(width: 4),
                      //       Text(
                      //         (state is! ProfileLoadedState)
                      //             ? '0'
                      //             : state.profileData.points != null
                      //                 ? state.profileData.points.toString()
                      //                 : '',
                      //         style: context.textTheme.title3Bold.copyWith(
                      //           color: ChessColors.greyG900,
                      //           fontSize: 20,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                );
              },
            ),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }
}

// class _ChessPlatFormContainer extends StatelessWidget {
//   final Image image;
//
//   const _ChessPlatFormContainer({required this.image});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
//       decoration: BoxDecoration(
//         color: ChessColors.white,
//         borderRadius: ChessRadius.radiusMd,
//       ),
//       child: image,
//     );
//   }
// }
