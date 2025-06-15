import 'package:auto_route/auto_route.dart';
import 'package:founders_academy/di/get_it.dart';
import 'package:founders_academy/feature/home/data/model/afisha/afisha_data.dart';
import 'package:founders_academy/feature/home/presentation/cubit/afisha_cubit/afisha_cubit.dart';
import 'package:founders_academy/feature/home/presentation/cubit/afisha_cubit/afisha_state.dart';
import 'package:founders_academy/feature/home/presentation/screen/list_screen/items_list_screen.dart';
import 'package:founders_academy/feature/home/presentation/widget/afisha_widget.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class AfishaListScreen extends StatelessWidget {
  const AfishaListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AfishaCubit>()..init(),
      child: BlocBuilder<AfishaCubit, AfishaState>(
        builder: (context, state) {
          return ItemsListScreen(
            title: 'Afisha',
            body: switch (state) {
              AfishaListLoadingState() =>
                const ChessCircularProgressIndicator(),
              AfishaListLoadedState() => _AfishaListBody(
                  afishaList: state.afishaList,
                  cubit: context.read(),
                  isNextPageLoading: state.isNextPageLoading,
                ),
              AfishaListErrorState() => const SizedBox.expand(),
            },
          );
        },
      ),
    );
  }
}

class _AfishaListBody extends StatefulWidget {
  final List<AfishaData> afishaList;
  final AfishaCubit cubit;
  final bool isNextPageLoading;

  const _AfishaListBody({
    required this.afishaList,
    required this.cubit,
    required this.isNextPageLoading,
  });

  @override
  State<_AfishaListBody> createState() => _AfishaListBodyState();
}

class _AfishaListBodyState extends State<_AfishaListBody> {
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
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      separatorBuilder: (_, __) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Divider(color: ChessColors.greyG30),
      ),
      itemCount: widget.afishaList.length + (widget.isNextPageLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == widget.afishaList.length) {
          return const Padding(
            padding: EdgeInsets.all(8),
            child: ChessCircularProgressIndicator(),
          );
        }
        final afisha = widget.afishaList[index];
        return AfishaWidget(
          afishaData: afisha,
        );
      },
    );
  }
}
