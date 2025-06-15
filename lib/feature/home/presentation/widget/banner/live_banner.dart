import 'package:lumi_pass/feature/base_url/app_base_url_cubit.dart';
import 'package:lumi_pass/feature/base_url/app_base_url_state.dart';
import 'package:lumi_pass/feature/home/data/model/live_stream/live_stream_data.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LiveBanner extends StatelessWidget {
  final LiveStreamData liveStream;

  const LiveBanner({super.key, required this.liveStream});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBaseUrlCubit, AppBaseUrlState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Jonli efir", style: context.textTheme.bodyMedium),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.circle,
                    size: 8,
                    color: ChessColors.errorDefault,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 128,
                      decoration: BoxDecoration(
                        borderRadius: ChessRadius.radiusXs,
                        color: ChessColors.greyG60,
                        image: DecorationImage(
                          image: NetworkImage(
                            state.baseUrl + liveStream.thumbnail,
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        liveStream.title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: context.textTheme.calloutMedium.copyWith(
                          color: ChessColors.greyG900,
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
