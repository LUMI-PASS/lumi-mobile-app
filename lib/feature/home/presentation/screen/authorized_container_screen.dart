import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/di/get_it.dart';
import 'package:lumi_pass/feature/shared/presentation/cubit/push_notification_cubit/push_notification_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class AuthorizedContainerScreen extends StatelessWidget {
  const AuthorizedContainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<PushNotificationCubit>(),
      child: const AutoRouter(),
    );
  }
}
