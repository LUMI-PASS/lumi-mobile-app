import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'display.dart';
import 'display_type.dart';

class DisplayWidget extends StatelessWidget {
  const DisplayWidget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Stack(
        children: [
          child,
          Builder(
            builder: (context) {
              _initDisplay(context);
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  _initDisplay(BuildContext context) {
    final display = getIt<Display>();

    display.setOnDisplayListener(
      (message) {
        CustomNotificationManager.show(
          context: context,
          message: message.description,
          type: message.type,
          animationDuration: const Duration(milliseconds: 500),
          displayDuration: const Duration(seconds: 4),
        );
      },
    );
  }
}

class CustomNotification extends StatefulWidget {
  final String message;
  final DisplayType type;
  final Duration animationDuration;
  final Duration displayDuration;
  final VoidCallback? onDismiss;

  const CustomNotification({
    Key? key,
    required this.message,
    required this.type,
    this.animationDuration = const Duration(milliseconds: 500),
    this.displayDuration = const Duration(seconds: 4),
    this.onDismiss,
  }) : super(key: key);

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
              margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: context.colors.onPrimary,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0A0D12).withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
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
                  16.kw,
                  Expanded(
                    child: widget.message.c(style.textColor).s(16).w(500),
                  ),
                  GestureDetector(
                    onTap: _dismiss,
                    child: Icon(
                      Icons.close,
                      color: style.textColor.withOpacity(0.6),
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
          backgroundColor: Colors.white,
          iconBackground: Colors.green.withOpacity(0.2),
          textColor: Colors.black87,
          icon: Assets.icons.sucess.svg(),
        );
      case DisplayType.error:
        return NotificationStyle(
          backgroundColor: Colors.white,
          iconBackground: Colors.red.withOpacity(0.2),
          textColor: Colors.black87,
          icon: Assets.icons.errorSvg.svg(),
        );
      case DisplayType.warning:
        return NotificationStyle(
          backgroundColor: Colors.white,
          iconBackground: Colors.orange.withOpacity(0.2),
          textColor: Colors.black87,
          icon: Assets.icons.infoDis.svg(),
        );
      case DisplayType.info:
        return NotificationStyle(
          backgroundColor: Colors.white,
          iconBackground: Colors.blue.withOpacity(0.2),
          textColor: Colors.black87,
          icon: Assets.icons.infoDis.svg(),
        );
    }
  }
}

class NotificationStyle {
  final Color backgroundColor;
  final Color iconBackground;
  final Color textColor;
  final Widget icon;

  NotificationStyle({
    required this.backgroundColor,
    required this.iconBackground,
    required this.textColor,
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
