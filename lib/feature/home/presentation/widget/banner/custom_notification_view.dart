import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';

class CustomNotification extends StatefulWidget {
  final String message;
  final DisplayType type;
  final Duration animationDuration;
  final Duration displayDuration;
  final VoidCallback? onDismiss;

  const CustomNotification({
    super.key,
    required this.message,
    required this.type,
    this.animationDuration = const Duration(milliseconds: 500),
    this.displayDuration = const Duration(seconds: 4),
    this.onDismiss,
  });

  @override
  State<CustomNotification> createState() => _CustomNotificationState();
}

class _CustomNotificationState extends State<CustomNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: -100.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Auto dismiss after display duration
    Future.delayed(widget.displayDuration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() async {
    await _controller.reverse();
    if (widget.onDismiss != null) {
      widget.onDismiss!();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NotificationStyle style = _getStyleForType(widget.type);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: ChessColors.greyG800.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(child: style.icon),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: context.textTheme.bodyRegular,
                    ),
                  ),
                  GestureDetector(
                    onTap: _dismiss,
                    child: const Icon(
                      Icons.close,
                      color: ChessColors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  NotificationStyle _getStyleForType(DisplayType type) {
    switch (type) {
      case DisplayType.success:
        return NotificationStyle(
          icon: ChessUiKitAssets.icons.general.success.svg(),
        );
      case DisplayType.error:
        return NotificationStyle(
          icon: ChessUiKitAssets.icons.general.success.svg(),
        );
      case DisplayType.warning:
        return NotificationStyle(
          icon: ChessUiKitAssets.icons.general.success.svg(),
        );
      case DisplayType.info:
        return NotificationStyle(
          icon: ChessUiKitAssets.icons.general.success.svg(),
        );
    }
  }
}

class NotificationStyle {
  final Widget icon;

  NotificationStyle({
    required this.icon,
  });
}

class CustomNotificationManager {
  static OverlayEntry? _currentNotification;
  static bool _isShowing = false;

  static void show({
    required BuildContext context,
    required String message,
    required DisplayType type,
    Duration animationDuration = const Duration(milliseconds: 500),
    Duration displayDuration = const Duration(seconds: 4),
  }) {
    // Dismiss current notification if any
    if (_isShowing) {
      _currentNotification?.remove();
      _currentNotification = null;
      _isShowing = false;
    }

    final OverlayState overlayState = Overlay.of(context);

    _currentNotification = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: CustomNotification(
            message: message,
            type: type,
            animationDuration: animationDuration,
            displayDuration: displayDuration,
            onDismiss: () {
              _currentNotification?.remove();
              _currentNotification = null;
              _isShowing = false;
            },
          ),
        ),
      ),
    );

    _isShowing = true;
    overlayState.insert(_currentNotification!);
  }
}

enum DisplayType { error, warning, info, success }
