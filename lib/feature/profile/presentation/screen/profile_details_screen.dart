import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/feature/base_url/app_base_url_cubit.dart';
import 'package:lumi_pass/feature/base_url/app_base_url_state.dart';
import 'package:lumi_pass/feature/profile/presentation/cubit/profile_cubit/profile_cubit.dart';
import 'package:lumi_pass/feature/profile/presentation/cubit/profile_cubit/profile_state.dart';
import 'package:lumi_pass/routing/app_router.gr.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class ProfileDetailScreen extends StatelessWidget {
  const ProfileDetailScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is! ProfileLoadedState) {
          return const ChessCircularProgressIndicator();
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(
              "Mening ma'lumotlarim",
              style: context.textTheme.bodyMedium.copyWith(
                color: ChessColors.greyG10,
              ),
            ),
            automaticallyImplyLeading: false,
            leading: Padding(
              padding: const EdgeInsets.only(left: 24),
              child: GestureDetector(
                onTap: () => context.router.pop(),
                child: ChessUiKitAssets.icons.general.arrowNarrowLeft.svg(
                  height: 24,
                  width: 24,
                  color: ChessColors.white
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 25),
                child: GestureDetector(
                  onTap: () {
                    context.pushRoute(
                      ProfileEditDetailRoute(
                        firstName: state.profileData.firstName ?? "",
                        lastName: state.profileData.lastName ?? "",
                        phoneNumber: state.profileData.phoneNumber ?? "",
                        imageUrl: state.profileData.image ?? "",
                      ),
                    );
                  },
                  child: ChessUiKitAssets.icons.profile.changeIcon.svg(
                    fit: BoxFit.none,
                    color: ChessColors.primaryDefault
                  ),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(24).copyWith(bottom: 16),
            child: Column(
              children: [
                state.profileData.image == null
                    ? Container(
                        alignment: Alignment.center,
                        child: ChessUiKitAssets.icons.profile.userPhoto
                            .svg(fit: BoxFit.none),
                      )
                    : BlocBuilder<AppBaseUrlCubit, AppBaseUrlState>(
                        builder: (context, baseUrlState) {
                          return Container(
                            height: 60,
                            width: 60,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
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
                const SizedBox(height: 33),
                _UnchangedData(
                  label: "Ism",
                  description: state.profileData.firstName ?? "",
                ),
                const SizedBox(height: 16),
                _UnchangedData(
                  label: "Familya",
                  description: state.profileData.lastName ?? "",
                ),
                const SizedBox(height: 16),
                _UnchangedData(
                  label: "Telefon raqam",
                  description:
                      state.profileData.phoneNumber?.getMaskedFormat ?? "",
                ),
                const Spacer(),
                ChessButton.text(
                  label: "Akkauntni o’chirish",
                  textStyle: context.textTheme.bodyMedium.copyWith(
                    color: ChessColors.errorDefault,
                  ),
                  onPressed: () {
                    context.router.push(
                      const ProfileDeleteRoute(),
                    );
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class _UnchangedData extends StatelessWidget {
  final String label;
  final String description;

  const _UnchangedData({
    required this.label,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: ChessRadius.radiusSm,
        color: ChessColors.greyG800,
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: context.textTheme.footnoteRegular.copyWith(
                color: ChessColors.greyG10,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: context.textTheme.bodyRegular.copyWith(
                color: ChessColors.greyG10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
