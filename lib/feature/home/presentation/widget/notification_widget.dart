import 'package:auto_route/auto_route.dart';
import 'package:founders_academy/feature/base_url/app_base_url_cubit.dart';
import 'package:founders_academy/feature/base_url/app_base_url_state.dart';
import 'package:founders_academy/feature/home/data/model/notification/notification_data.dart';
import 'package:founders_academy/feature/home/presentation/cubit/livestream_item_cubit/livestream_cubit.dart';
import 'package:founders_academy/feature/home/presentation/cubit/livestream_item_cubit/livestream_state.dart';
import 'package:founders_academy/feature/home/presentation/cubit/notification_cubit/notification_cubit.dart';
import 'package:founders_academy/feature/home/presentation/cubit/notification_cubit/notification_state.dart';
import 'package:founders_academy/routing/app_router.gr.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationWidget extends StatelessWidget {
  final NotificationData notification;

  const NotificationWidget({
    required this.notification,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return _NotificationCard(
      isRead: notification.read,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 72,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _NotificationImage(notificationData: notification),
                const SizedBox(width: 12),
                _NotificationContent(notificationData: notification)
              ],
            ),
          ),
          const Spacer(),
          _NotificationButton(notificationData: notification)
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final Widget child;
  final bool isRead;

  const _NotificationCard({
    required this.child,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 152,
      padding: const EdgeInsets.all(16).copyWith(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: ChessRadius.radiusMd,
        color: ChessColors.white,
        border: Border.all(
          color: isRead ? ChessColors.transparent : ChessColors.primaryDefault,
        ),
      ),
      child: child,
    );
  }
}

class _NotificationImage extends StatelessWidget {
  final NotificationData notificationData;

  const _NotificationImage({required this.notificationData});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBaseUrlCubit, AppBaseUrlState>(
      builder: (_, state) => Expanded(
        child: ClipRRect(
          borderRadius: ChessRadius.radiusXs,
          child: SizedBox(
              height: 72,
              child: notificationData.type != null
                  ? ChessNetworkImage(
                      imageUrl: notificationData.imageUrl ?? "",
                      fit: BoxFit.cover,
                      baseUrl: state.baseUrl,
                    )
                  : ChessUiKitAssets.images.logoPng.image()),
        ),
      ),
    );
  }
}

class _NotificationContent extends StatelessWidget {
  final NotificationData notificationData;

  const _NotificationContent({required this.notificationData});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            notificationData.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.subheadlineRegular.copyWith(
              color: ChessColors.greyG900,
            ),
          ),
          Text(
            notificationData.date.formattedDate,
            style: context.textTheme.footnoteRegular.copyWith(
              color: ChessColors.greyG400,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final NotificationData notificationData;

  const _NotificationButton({required this.notificationData});

  @override
  Widget build(BuildContext context) {
    final bool isLive = notificationData.type == NotificationType.live;

    final String title = isLive ? "{Jonli efirni ko'rish}" : "{Batafsil}";

    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        return Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ChessLinkedText(
              text: title,
              onLinkTap: () {
                _onNotificationTap(context, notificationData);
              },
            ),
          ),
        );
      },
    );
  }

  void _onNotificationTap(
    BuildContext context,
    NotificationData notification,
  ) {
    dynamic route;
    final type = notification.type ?? NotificationType.unknown;

    if (!(notification.read)) {
      context.read<NotificationCubit>().readNotification(notification.id);
    }

    if (type == NotificationType.live) {
      final String? entityId = notification.entityId;

      final cubit = context.read<LiveStreamItemCubit>();

      if (entityId != null) {
        cubit.init(entityId).whenComplete(() {
          if (cubit.state is LiveStreamItemLoadedState) {
            final state = cubit.state as LiveStreamItemLoadedState;
            ChessUrlLauncher.launch(
              url: state.liveStreamData.videoLink,
              onError: (_) {
                CornerCaseBottomSheet.show(
                  context,
                  type: CornerCaseType.error,
                );
              },
            );
          }
        });
      }
    }

    if (notificationData.type == null) {
      showModalBottomSheet(
        context: context,
        builder: (context) => _BottomSheetContent(
          notificationData: notificationData,
        ),
      );
    }

    switch (type) {
      case NotificationType.afisha:
        route = AfishaDetailsRoute(id: notificationData.entityId ?? "");
      case NotificationType.review:
        route = ReviewMatchDetailsRoute(id: notificationData.entityId ?? "");
      case NotificationType.news:
        route = NewsDetailsRoute(id: notificationData.entityId ?? "");
      case NotificationType.grandmaster:
        route = GrandmasterDetailsRoute(id: notificationData.entityId ?? "");
      case NotificationType.book:
        route = BookDetailsRoute(id: notificationData.entityId ?? "");
      default:
    }

    if (route != null) context.router.push(route);
  }
}

class _BottomSheetContent extends StatelessWidget {
  final NotificationData notificationData;

  const _BottomSheetContent({required this.notificationData});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: ChessRadius.radiusXl,
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(
          bottom: 50,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 24, top: 8),
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  height: 6,
                  width: 34,
                  decoration: BoxDecoration(
                    color: ChessColors.greyG30,
                    borderRadius: ChessRadius.radiusXl,
                  ),
                ),
              ),
            ),
            Text(
              notificationData.title,
              style: context.textTheme.title3Bold.copyWith(
                color: ChessColors.greyG900,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Text(
              notificationData.date.formattedDate,
              style: context.textTheme.footnoteRegular.copyWith(
                color: ChessColors.greyG200,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notificationData.body,
                      style: context.textTheme.bodyRegular.copyWith(
                        color: ChessColors.greyG900,
                      ),
                    )
                  ],
                ),
              ),
            ),
            ChessButton.primary(
              onPressed: context.router.pop,
              label: 'Yaxshi',
              background: ChessColors.primaryDefault,
              borderRadius: 16,
              textStyle: context.textTheme.bodyMedium.copyWith(
                color: ChessColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
