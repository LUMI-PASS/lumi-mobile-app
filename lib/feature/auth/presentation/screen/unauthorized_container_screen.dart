import 'package:auto_route/auto_route.dart';
import 'package:founders_academy/di/get_it.dart';
import 'package:founders_academy/feature/auth/presentation/cubit/auth/auth_cubit.dart';
import 'package:founders_academy/feature/auth/presentation/cubit/otp/otp_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class UnauthorizedContainerScreen extends StatelessWidget {
  const UnauthorizedContainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<AuthCubit>()),
        BlocProvider(create: (context) => getIt<OtpCubit>()..init()),
      ],
      child: Material(
        child: AutoRouter(
          navigatorObservers: () => [
            HeroController(),
          ],
        ),
      ),
    );
  }
}
