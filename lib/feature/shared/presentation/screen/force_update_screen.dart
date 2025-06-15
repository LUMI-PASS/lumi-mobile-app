import 'package:auto_route/auto_route.dart';
import 'package:founders_academy/di/get_it.dart';
import 'package:founders_academy/feature/shared/presentation/cubit/force_update_cubit/force_update_cubit.dart';
import 'package:founders_academy/feature/shared/presentation/cubit/force_update_cubit/force_update_state.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ForceUpdateCubit>(),
      child: BlocBuilder<ForceUpdateCubit, ForceUpdateState>(
        builder: (context, state) {
          return ChessResultScreen(
            image: ChessUiKitAssets.icons.general.forceUpdate.svg(),
            title: "Yangi versiya mavjud",
            subtitle:
                "Ilovaning hozirgi versiyasi endi qo'llab-quvvatlanmaydi. Sizga yetkazgan noqulayliklar uchun uzr so‘raymiz.",
            primaryButtonLabel: "Yangi versiyaga yangilash",
            onPrimaryButtonTap: context.read<ForceUpdateCubit>().onUpdateTap,
          );
        },
      ),
    );
  }
}
