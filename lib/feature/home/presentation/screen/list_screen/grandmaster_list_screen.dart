import 'package:auto_route/auto_route.dart';
import 'package:founders_academy/di/get_it.dart';
import 'package:founders_academy/feature/home/data/model/grandmaster/grandmaster_data.dart';
import 'package:founders_academy/feature/home/presentation/cubit/grandmaster_cubit/grandmaster_cubit.dart';
import 'package:founders_academy/feature/home/presentation/screen/list_screen/items_list_screen.dart';
import 'package:founders_academy/feature/home/presentation/widget/grandmaster_widget.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class GrandmastersListScreen extends StatelessWidget {
  const GrandmastersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<GrandmasterCubit>()..init(),
      child: BlocBuilder<GrandmasterCubit, GrandmasterState>(
        builder: (context, state) {
          return ItemsListScreen(
            title: 'Shorts',
            body: switch (state) {
              GrandmasterLoadingState() =>
                const ChessCircularProgressIndicator(),
              GrandmasterLoadedState() => _GrandmasterListBody(
                  grandmasterList: state.grandmasterList,
                  cubit: context.read(),
                  isNextPageLoading: state.isNextPageLoading,
                ),
              GrandmasterErrorState() => const SizedBox.expand(),
            },
          );
        },
      ),
    );
  }
}

class _GrandmasterListBody extends StatefulWidget {
  final List<GrandmasterData> grandmasterList;
  final GrandmasterCubit cubit;
  final bool isNextPageLoading;

  const _GrandmasterListBody({
    required this.grandmasterList,
    required this.cubit,
    required this.isNextPageLoading,
  });

  @override
  State<_GrandmasterListBody> createState() => _GrandmasterListBodyState();
}

class _GrandmasterListBodyState extends State<_GrandmasterListBody> {
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
            mainAxisSpacing: 16,
            mainAxisExtent: 230,
          ),
          itemCount: widget.grandmasterList.length,
          itemBuilder: (_, index) => GrandmasterWidget(
            grandmaster: widget.grandmasterList[index],
          ),
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
