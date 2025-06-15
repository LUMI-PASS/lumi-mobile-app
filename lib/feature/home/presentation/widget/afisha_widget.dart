import 'package:auto_route/auto_route.dart';
import 'package:founders_academy/core/logging/logger.dart';
import 'package:founders_academy/feature/base_url/app_base_url_cubit.dart';
import 'package:founders_academy/feature/base_url/app_base_url_state.dart';
import 'package:founders_academy/feature/home/data/model/afisha/afisha_data.dart';
import 'package:founders_academy/routing/app_router.gr.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AfishaWidget extends StatelessWidget {
  final AfishaData afishaData;
  final VoidCallback? onTap;

  const AfishaWidget({
    required this.afishaData,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBaseUrlCubit, AppBaseUrlState>(
      builder: (context, state) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            onTap?.call();
            context.router.push(AfishaDetailsRoute(id: afishaData.id));
            FirebaseAnalytics.instance.logEvent(
              name: 'afisha_detail_event',
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ChessNetworkImage(
                    imageUrl: afishaData.photoUrl ?? "",
                    height: 64,
                    width: 64,
                    fit: BoxFit.cover,
                    baseUrl: state.baseUrl,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        afishaData.name ?? "",
                        style: context.textTheme.calloutMedium.copyWith(
                          color: ChessColors.white,
                          fontFamily: FontFamily.nunito,
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        afishaData.date?.formattedDate ?? "",
                        style: context.textTheme.footnoteRegular.copyWith(
                          color: ChessColors.white,
                          fontFamily: FontFamily.nunito,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
