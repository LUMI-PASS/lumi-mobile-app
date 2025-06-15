import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/di/get_it.dart';
import 'package:lumi_pass/feature/home/data/model/book/book_data.dart';
import 'package:lumi_pass/feature/home/presentation/cubit/book_list_cubit/book_list_cubit.dart';
import 'package:lumi_pass/feature/home/presentation/screen/list_screen/items_list_screen.dart';
import 'package:lumi_pass/feature/home/presentation/widget/book_widget.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class BookListScreen extends StatelessWidget {
  const BookListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<BookListCubit>()..init(),
      child: BlocBuilder<BookListCubit, BookListState>(
        builder: (context, state) {
          return ItemsListScreen(
            title: 'Kitoblar',
            body: switch (state) {
              BookListLoadingState() => const ChessCircularProgressIndicator(),
              BookListLoadedState() => _BookListBody(
                  bookList: state.bookList,
                  cubit: context.read(),
                  isNextPageLoading: state.isNextPageLoading,
                ),
              BookListErrorState() => const SizedBox.expand(),
            },
          );
        },
      ),
    );
  }
}

class _BookListBody extends StatefulWidget {
  final List<BookData> bookList;
  final BookListCubit cubit;
  final bool isNextPageLoading;

  const _BookListBody({
    required this.bookList,
    required this.cubit,
    required this.isNextPageLoading,
  });

  @override
  State<_BookListBody> createState() => _BookListBodyState();
}

class _BookListBodyState extends State<_BookListBody> {
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
    return ListView(
      controller: _scrollController,
      children: [
        GridView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.all(24),
          physics: const ClampingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 24,
            mainAxisExtent: 280,
          ),
          itemCount: widget.bookList.length,
          itemBuilder: (_, index) {
            return EnhancedBookWidget(
              book: widget.bookList[index],
              height: 230,
            );
          },
        ),
        if (widget.isNextPageLoading)
          const Padding(
            padding: EdgeInsets.all(8),
            child: ChessCircularProgressIndicator(),
          ),
      ],
    );
  }
}
