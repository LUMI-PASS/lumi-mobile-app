import 'package:auto_route/auto_route.dart';
import 'package:founders_academy/di/get_it.dart';
import 'package:founders_academy/feature/home/data/model/news/news_data.dart';
import 'package:founders_academy/feature/home/presentation/cubit/news_cubit/news_cubit.dart';
import 'package:founders_academy/feature/home/presentation/screen/list_screen/items_list_screen.dart';
import 'package:founders_academy/feature/home/presentation/widget/news_widget.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class NewsListScreen extends StatelessWidget {
  const NewsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<NewsCubit>()..init(),
      child: BlocBuilder<NewsCubit, NewsState>(
        builder: (context, state) {
          return ItemsListScreen(
            title: 'Yangiliklar',
            body: switch (state) {
              NewsLoadingState() => const ChessCircularProgressIndicator(),
              NewsLoadedState() => _NewsListBody(
                  newsList: state.newsList,
                  cubit: context.read(),
                  isNextPageLoading: state.isNextPageLoading,
                ),
              NewsErrorState() => const SizedBox.expand()
            },
          );
        },
      ),
    );
  }
}

class _NewsListBody extends StatefulWidget {
  final List<NewsData> newsList;
  final NewsCubit cubit;
  final bool isNextPageLoading;

  const _NewsListBody({
    required this.newsList,
    required this.cubit,
    required this.isNextPageLoading,
  });

  @override
  State<_NewsListBody> createState() => _NewsListBodyState();
}

class _NewsListBodyState extends State<_NewsListBody> {
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

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      widget.cubit.loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      controller: _scrollController,
      padding: const EdgeInsets.only(
        top: 8,
        bottom: 48,
      ),
      separatorBuilder: (_, __) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Divider(color: ChessColors.greyG30),
      ),
      itemCount: widget.newsList.length + (widget.isNextPageLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == widget.newsList.length) {
          return const Padding(
            padding: EdgeInsets.all(8),
            child: ChessCircularProgressIndicator(),
          );
        }
        return EnhancedNewsWidget(
          newsData: widget.newsList[index],
        );
      },
    );
  }
}
