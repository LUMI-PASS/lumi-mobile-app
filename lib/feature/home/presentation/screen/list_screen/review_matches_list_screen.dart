import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/di/get_it.dart';
import 'package:lumi_pass/feature/base_url/app_base_url_cubit.dart';
import 'package:lumi_pass/feature/base_url/app_base_url_state.dart';
import 'package:lumi_pass/feature/home/data/model/review_matches/review_matches_data.dart';
import 'package:lumi_pass/feature/home/presentation/cubit/review_matches_list_cubit/review_matches_list_cubit.dart';
import 'package:lumi_pass/feature/home/presentation/screen/list_screen/items_list_screen.dart';
import 'package:lumi_pass/routing/app_router.gr.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class ReviewMatchesListScreen extends StatelessWidget {
  const ReviewMatchesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ReviewMatchesListCubit>()..init(),
      child: BlocBuilder<ReviewMatchesListCubit, ReviewMatchesListState>(
        builder: (context, state) {
          return ItemsListScreen(
            title: 'Tahlillar',
            body: switch (state) {
              ReviewMatchesListLoadingState() =>
                const ChessCircularProgressIndicator(),
              ReviewMatchesListLoadedState() => _ReviewMatchesListBody(
                  reviewMatchesList: state.reviewMatchesList,
                  cubit: context.read(),
                  isNextPageLoading: state.isNextPageLoading,
                ),
              ReviewMatchesListErrorState() => const SizedBox.expand(),
            },
          );
        },
      ),
    );
  }
}

class _ReviewMatchesListBody extends StatefulWidget {
  final List<ReviewMatchData> reviewMatchesList;
  final ReviewMatchesListCubit cubit;
  final bool isNextPageLoading;

  const _ReviewMatchesListBody({
    required this.reviewMatchesList,
    required this.cubit,
    required this.isNextPageLoading,
  });

  @override
  State<_ReviewMatchesListBody> createState() => _ReviewMatchesListBodyState();
}

class _ReviewMatchesListBodyState extends State<_ReviewMatchesListBody> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 8, bottom: 48),
      itemCount:
          widget.reviewMatchesList.length + (widget.isNextPageLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == widget.reviewMatchesList.length) {
          return const Padding(
            padding: EdgeInsets.all(8),
            child: ChessCircularProgressIndicator(),
          );
        }
        return _ReviewMatchesWidget(
          reviewMatches: widget.reviewMatchesList[index],
        );
      },
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      widget.cubit.loadNextPage();
    }
  }
}

class _ReviewMatchesWidget extends StatelessWidget {
  final ReviewMatchData reviewMatches;

  const _ReviewMatchesWidget({required this.reviewMatches});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBaseUrlCubit, AppBaseUrlState>(
      builder: (context, state) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => context.router.push(
            ReviewMatchDetailsRoute(id: reviewMatches.id),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ChessNetworkImage(
                          imageUrl: reviewMatches.thumbnailUrl,
                          height: 92,
                          width: 160,
                          fit: BoxFit.cover,
                          baseUrl: state.baseUrl,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reviewMatches.title,
                            maxLines: 2,
                            style: context.textTheme.calloutMedium.copyWith(
                              color: ChessColors.greyG20,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 22),
                            child: Text(
                              reviewMatches.date.formattedDate,
                              style: context.textTheme.footnoteRegular.copyWith(
                                color: ChessColors.greyG30,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
