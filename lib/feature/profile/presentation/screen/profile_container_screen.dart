import 'package:auto_route/auto_route.dart';
import 'package:founders_academy/di/get_it.dart';
import 'package:founders_academy/feature/profile/presentation/cubit/profile_cubit/profile_cubit.dart';
import 'package:founders_academy/feature/profile/presentation/cubit/version_cubit/version_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class ProfileContainerScreen extends StatefulWidget {
  const ProfileContainerScreen({super.key});

  @override
  State<ProfileContainerScreen> createState() => _ProfileContainerScreenState();
}

class _ProfileContainerScreenState extends State<ProfileContainerScreen>
    with AutoRouteAwareStateMixin<ProfileContainerScreen> {
  late ProfileCubit _cubit;

  @override
  void initState() {
    _cubit = getIt<ProfileCubit>()..init();
    super.initState();
  }

  @override
  void didChangeTabRoute(TabPageRoute previousRoute) {
    _cubit.getProfile();
    super.didChangeTabRoute(previousRoute);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => _cubit),
        BlocProvider(create: (context) => getIt<VersionCubit>()..init()),
      ],
      child: const Material(
        child: AutoRouter(),
      ),
    );
  }
}
