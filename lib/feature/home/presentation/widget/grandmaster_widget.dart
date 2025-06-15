import 'package:auto_route/auto_route.dart';
import 'package:founders_academy/core/logging/logger.dart';
import 'package:founders_academy/feature/base_url/app_base_url_cubit.dart';
import 'package:founders_academy/feature/base_url/app_base_url_state.dart';
import 'package:founders_academy/feature/home/data/model/grandmaster/grandmaster_data.dart';
import 'package:founders_academy/routing/app_router.gr.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GrandmasterWidget extends StatelessWidget {
  final GrandmasterData grandmaster;
  final VoidCallback? onTap;

  const GrandmasterWidget({
    required this.grandmaster,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBaseUrlCubit, AppBaseUrlState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            onTap?.call();
            context.router.push(
              GrandmasterDetailsRoute(id: grandmaster.id),
            );
            FirebaseAnalytics.instance.logEvent(
              name: 'qisqa_videolar_event',
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
          child: SizedBox(
            width: 141,
            child: ClipRRect(
              borderRadius: ChessRadius.radiusSm,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ChessNetworkImage(
                    imageUrl: grandmaster.image,
                    fit: BoxFit.cover,
                    baseUrl: state.baseUrl,
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    alignment: Alignment.bottomLeft,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          ChessColors.black.withOpacity(0.4),
                          ChessColors.transparent,
                        ],
                      ),
                    ),
                    child: Text(
                      grandmaster.fullName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.subheadlineSemibold.copyWith(
                        color: ChessColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
