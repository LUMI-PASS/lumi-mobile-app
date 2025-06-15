import 'package:auto_route/auto_route.dart';
import 'package:founders_academy/di/get_it.dart';
import 'package:founders_academy/feature/auth/presentation/cubit/profile_creation/profile_creation_cubit.dart';
import 'package:founders_academy/feature/auth/presentation/cubit/registration/registration_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class RegistrationContainerScreen extends StatelessWidget {
  const RegistrationContainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<RegistrationCubit>()),
        BlocProvider(create: (context) => getIt<ProfileCreationCubit>()),
      ],
      child: const Material(
        child: AutoRouter(),
      ),
    );
  }
}
