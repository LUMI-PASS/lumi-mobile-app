import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/di/get_it.dart';
import 'package:lumi_pass/feature/app_init/cubit/app_init_cubit.dart';
import 'package:lumi_pass/feature/app_init/cubit/app_init_state.dart';
import 'package:lumi_pass/feature/base_url/app_base_url_cubit.dart';
import 'package:lumi_pass/feature/base_url/app_base_url_state.dart';
import 'package:lumi_pass/routing/app_router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class AppContainerScreen extends StatelessWidget {
  const AppContainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<AppInitCubit>()..checkAuth(),
        ),
        BlocProvider(
          create: (context) => getIt<AppBaseUrlCubit>()..init(),
        ),
      ],
      child: AutoRouter(
        builder: (context, content) {
          return MultiBlocListener(
            listeners: [
              BlocListener<AppInitCubit, AppInitState>(
                listener: _onAuthStateChanged,
              ),
              BlocListener<AppBaseUrlCubit, AppBaseUrlState>(
                listener: (context, state) {},
              ),
            ],
            child: content,
          );
        },
      ),
    );
  }

  void _onAuthStateChanged(BuildContext context, AppInitState state) {
    final router = context.router;
    // if (state is NeedForceUpdateState) {
    //   router.replaceAll([
    //     const ForceUpdateRoute(),
    //   ]);
    // }

    if (state is AppInitLoadingState || state is NeedForceUpdateState) {
      router.replaceAll([
        const SplashRoute(),
      ]);
    }

    if (state is AuthorizedState) {
      router.replaceAll([
        const AuthorizedContainerRoute(),
      ]);
    }

    if (state is UnauthorizedState) {
      router.replaceAll([
        const UnauthorizedContainerRoute(),
      ]);
    }
  }
}
