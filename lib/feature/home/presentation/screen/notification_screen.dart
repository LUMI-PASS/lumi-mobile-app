import 'package:auto_route/auto_route.dart';
import 'package:founders_academy/di/get_it.dart';
import 'package:founders_academy/feature/home/data/model/notification/notification_data.dart';
import 'package:founders_academy/feature/home/presentation/cubit/livestream_item_cubit/livestream_cubit.dart';
import 'package:founders_academy/feature/home/presentation/cubit/notification_cubit/notification_cubit.dart';
import 'package:founders_academy/feature/home/presentation/cubit/notification_cubit/notification_state.dart';
import 'package:founders_academy/feature/home/presentation/screen/list_screen/items_list_screen.dart';
import 'package:founders_academy/feature/home/presentation/widget/notification_widget.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<NotificationCubit>()..init()),
        BlocProvider(create: (context) => getIt<LiveStreamItemCubit>()),
      ],
      child: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          return ItemsListScreen(
            title: 'Xabarnoma',
            body: switch (state) {
              NotificationInitState() => const ChessCircularProgressIndicator(),
              NotificationListLoadedState() => _NotificationListBody(
                  notificationList: state.notificationList,
                  cubit: context.read(),
                  isNextPageLoading: state.isNextPageLoading,
                ),
              NotificationListErrorState() => const SizedBox.expand(),
            },
          );
        },
      ),
    );
  }
}

class _NotificationListBody extends StatefulWidget {
  final List<NotificationData> notificationList;
  final NotificationCubit cubit;
  final bool isNextPageLoading;

  const _NotificationListBody({
    required this.notificationList,
    required this.cubit,
    required this.isNextPageLoading,
  });

  @override
  State<_NotificationListBody> createState() => _NotificationListBodyState();
}

class _NotificationListBodyState extends State<_NotificationListBody> {
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
      padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(bottom: 48),
      physics: const AlwaysScrollableScrollPhysics(),
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemCount:
          widget.notificationList.length + (widget.isNextPageLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == widget.notificationList.length) {
          return const Padding(
            padding: EdgeInsets.all(8),
            child: ChessCircularProgressIndicator(),
          );
        }

        final notification = widget.notificationList[index];

        return NotificationWidget(notification: notification);
      },
    );
  }
}
