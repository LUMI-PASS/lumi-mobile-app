import 'package:auto_route/auto_route.dart';
import 'package:founders_academy/di/get_it.dart';
import 'package:founders_academy/feature/base_url/app_base_url_cubit.dart';
import 'package:founders_academy/feature/base_url/app_base_url_state.dart';
import 'package:founders_academy/feature/home/data/model/afisha/afisha_data.dart';
import 'package:founders_academy/feature/home/presentation/cubit/afisha_item_cubit/afisha_item_cubit.dart';
import 'package:founders_academy/feature/home/presentation/cubit/afisha_item_cubit/afisha_item_state.dart';
import 'package:founders_academy/feature/profile/presentation/cubit/profile_cubit/profile_cubit.dart';
import 'package:founders_academy/feature/profile/presentation/cubit/profile_cubit/profile_state.dart';
import 'package:founders_academy/routing/app_router.gr.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

@RoutePage()
class AfishaDetailsScreen extends StatelessWidget {
  final String id;

  const AfishaDetailsScreen({required this.id, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<AfishaItemCubit>()..init(id),
        ),
        BlocProvider(
          create: (context) => getIt<ProfileCubit>()..init(),
        ),
      ],
      child: BlocBuilder<AfishaItemCubit, AfishaItemState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: ChessColors.greyG20,
            appBar: AppBar(
              backgroundColor: ChessColors.greyG20,
              automaticallyImplyLeading: false,
              leading: Padding(
                padding: const EdgeInsets.only(left: 24),
                child: GestureDetector(
                  onTap: () => context.router.pop(),
                  child: ChessUiKitAssets.icons.general.arrowNarrowLeft.svg(
                    height: 24,
                    width: 24,
                  ),
                ),
              ),
            ),
            body: BlocConsumer<ProfileCubit, ProfileState>(
              listener: (context, profileState) {
                if (profileState is ProfileLoadedState) {}
              },
              builder: (context, profileState) {
                return switch (state) {
                  AfishaItemLoadingState() =>
                    const ChessCircularProgressIndicator(),
                  AfishaItemErrorState() => const SizedBox.expand(),
                  AfishaItemLoadedState() => _BodyContent(
                      afishaData: state.afishaData,
                      userId: profileState is ProfileLoadedState
                          ? profileState.profileData.userId ??
                              '' // Ensure this is populated correctly
                          : '', // Provide a fallback if profileState is not loaded
                    ),
                };
              },
            ),
          );
        },
      ),
    );
  }
}

class _BodyContent extends StatelessWidget {
  final AfishaData afishaData;
  final String userId;

  const _BodyContent({
    required this.afishaData,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBaseUrlCubit, AppBaseUrlState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        afishaData.name ??
                            "No name available", // Provide a fallback value
                        style: context.textTheme.title3Bold.copyWith(
                          color: ChessColors.greyG900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ChessNetworkImage(
                          height: 180,
                          imageUrl: afishaData.photoUrl ??
                              "", // Provide a fallback value
                          width: double.infinity,
                          fit: BoxFit.cover,
                          baseUrl: state.baseUrl,
                        ),
                      ),
                      _AfishaInfo(
                        image: ChessUiKitAssets.icons.general.calendar.svg(),
                        title: "Musobaqa kuni:",
                        info: formatDate(afishaData.tournamentDate ??
                            ""), // Provide a fallback value
                      ),
                      _AfishaInfo(
                        image: ChessUiKitAssets.icons.general.fast.svg(),
                        title: "Musobaqa turi:",
                        info: afishaData.tournamentType?.join(',') ??
                            "No types available", // Provide a fallback value
                      ),
                      _AfishaInfo(
                        image: ChessUiKitAssets.icons.general.valume.svg(),
                        title: "Musobaqa shakli:",
                        info: afishaData.format ??
                            "No format available", // Provide a fallback value
                      ),
                      _AfishaInfo(
                          image: ChessUiKitAssets.icons.general.time.svg(),
                          title: "Ro'yxatdan o'tish oxirgi kuni:",
                          info: formatDate(afishaData.registrationDate ??
                              "")), // Provide a fallback value
                      _AfishaInfo(
                        image: ChessUiKitAssets.icons.general.location.svg(),
                        title: "Manzil:",
                        info: afishaData.location?.name ??
                            "No location available", // Provide a fallback value
                      ),
                      _AfishaInfo(
                        image: ChessUiKitAssets.icons.general.money.svg(
                          colorFilter: const ColorFilter.mode(
                            ChessColors.primaryDefault,
                            BlendMode.srcIn,
                          ),
                        ),
                        title: "To'lov turi:",
                        info: afishaData.price != 0
                            ? "Pullik"
                            : "Bepul", // Provide a fallback value
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              afishaData.isRegistered == true
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Container(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ChessUiKitAssets.icons.puzzle.correct.svg(),
                            const SizedBox(width: 10),
                            Text(
                              "Siz  ro'yhatdan o'tgansiz",
                              style: context.textTheme.headlineSemibold,
                            )
                          ],
                        ),
                      ))
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: ChessButton.primary(
                        onPressed: () {
                          context.replaceRoute(
                            AfishaRegistrationRoute(
                                afishaData: afishaData, uerId: userId),
                          );
                        },
                        label: 'Ro’yxatdan o’tish',
                        background: ChessColors.primaryDefault,
                        borderRadius: 16,
                        textStyle: context.textTheme.bodyMedium.copyWith(
                          color: ChessColors.white,
                        ),
                      ),
                    )
            ],
          ),
        );
      },
    );
  }
}

class _AfishaInfo extends StatelessWidget {
  final SvgPicture image;
  final String title;
  final String info;
  const _AfishaInfo({
    required this.image,
    required this.title,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          image,
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textTheme.subheadlineRegular.copyWith(
                  color: ChessColors.black,
                ),
              ),
              Text(
                info,
                style: context.textTheme.headlineSemibold.copyWith(
                  color: ChessColors.black,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

String formatDate(String dateString) {
  DateTime dateTime = DateTime.parse(dateString);
  // Define the month names in Uzbek
  List<String> months = [
    'yanvar',
    'fevral',
    'mart',
    'aprel',
    'may',
    'iyun',
    'iyul',
    'avgust',
    'sentabr',
    'oktabr',
    'noyabr',
    'dekabr'
  ];

  int day = dateTime.day;
  String month = months[dateTime.month - 1];

  return '$day $month';
}
