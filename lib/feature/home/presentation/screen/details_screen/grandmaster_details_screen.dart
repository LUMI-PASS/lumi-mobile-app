import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/di/get_it.dart';
import 'package:lumi_pass/feature/base_url/app_base_url_cubit.dart';
import 'package:lumi_pass/feature/base_url/app_base_url_state.dart';
import 'package:lumi_pass/feature/home/data/model/grandmaster/grandmaster_data.dart';
import 'package:lumi_pass/feature/home/presentation/cubit/grandmaster_item_cubit/grandmaster_item_cubit.dart';
import 'package:lumi_pass/feature/home/presentation/cubit/grandmaster_item_cubit/grandmaster_item_state.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class GrandmasterDetailsScreen extends StatefulWidget {
  final String id;
  const GrandmasterDetailsScreen({super.key, required this.id});

  @override
  State<GrandmasterDetailsScreen> createState() =>
      _GrandmasterDetailsScreenState();
}

class _GrandmasterDetailsScreenState extends State<GrandmasterDetailsScreen> {
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<GrandmasterItemCubit>()..init(widget.id),
      child: BlocBuilder<GrandmasterItemCubit, GrandmasterItemState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: ChessColors.black,
            body: switch (state) {
              GrandmasterItemLoadingState() =>
                const ChessCircularProgressIndicator(),
              GrandmasterItemErrorState() => const SizedBox.expand(),
              GrandmasterItemLoadedState() => _BodyContent(
                  grandmasterData: state.grandmasterData,
                )
            },
          );
        },
      ),
    );
  }
}

class _BodyContent extends StatelessWidget {
  final GrandmasterData grandmasterData;

  const _BodyContent({
    required this.grandmasterData,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBaseUrlCubit, AppBaseUrlState>(
      builder: (context, state) {
        return ChessShortsPlayer(
          onBackTap: context.router.pop,
          description: grandmasterData.description,
          title: grandmasterData.fullName,
          thumbnailUrl: grandmasterData.image,
          videoUrl: grandmasterData.videoUrl,
          baseUrl: state.baseUrl,
        );
      },
    );
  }
}
