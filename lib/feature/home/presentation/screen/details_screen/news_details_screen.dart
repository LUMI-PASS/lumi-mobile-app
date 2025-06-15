import 'package:auto_route/auto_route.dart';
import 'package:founders_academy/di/get_it.dart';
import 'package:founders_academy/feature/base_url/app_base_url_cubit.dart';
import 'package:founders_academy/feature/base_url/app_base_url_state.dart';
import 'package:founders_academy/feature/home/data/model/news/news_data.dart';
import 'package:founders_academy/feature/home/presentation/cubit/news_item_cubit/news_item_cubit.dart';
import 'package:founders_academy/feature/home/presentation/cubit/news_item_cubit/news_item_state.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';

@RoutePage()
class NewsDetailsScreen extends StatelessWidget {
  final String id;

  const NewsDetailsScreen({
    required this.id,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<NewsItemCubit>()..init(id),
      child: BlocBuilder<NewsItemCubit, NewsItemState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              scrolledUnderElevation: 0.0,
              automaticallyImplyLeading: false,
              leading: Padding(
                padding: const EdgeInsets.only(left: 24),
                child: GestureDetector(
                  onTap: () => context.router.pop(),
                  child: ChessUiKitAssets.icons.general.arrowNarrowLeft
                      .svg(height: 24, width: 24, color: ChessColors.white),
                ),
              ),
            ),
            body: switch (state) {
              NewsItemLoadingState() => const ChessCircularProgressIndicator(),
              NewsItemErrorState() => const SizedBox.expand(),
              NewsItemLoadedState() => _BodyContent(
                  newsData: state.newsData,
                )
            },
          );
        },
      ),
    );
  }
}

class _BodyContent extends StatelessWidget {
  final NewsData newsData;

  const _BodyContent({required this.newsData});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBaseUrlCubit, AppBaseUrlState>(
      builder: (context, state) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  newsData.title,
                  style: context.textTheme.title3Bold.copyWith(
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  child: Text(
                    newsData.date.formattedDate,
                    style: context.textTheme.footnoteRegular.copyWith(
                      color: ChessColors.greyG40,
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ChessNetworkImage(
                    imageUrl: newsData.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    baseUrl: state.baseUrl,
                  ),
                ),
                Html(
                  data: newsData.content,
                  style: context.textTheme.htmlStyle.map(
                    (key, value) => MapEntry(key, Style.fromTextStyle(value)),
                  ),
                  onLinkTap: (url, _, __) => ChessUrlLauncher.launch(
                    url: url,
                    onError: (error) {
                      CornerCaseBottomSheet.show(
                        context,
                        type: CornerCaseType.error,
                      );
                    },
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
