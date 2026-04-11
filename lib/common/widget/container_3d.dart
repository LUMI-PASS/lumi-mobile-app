import 'package:flutter/material.dart';

class Container3d extends StatefulWidget {
  final Widget? child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final List<BoxShadow>? boxShadow;
  final double? borderWidth;
  final Gradient? gradient;
  final double depth;
  final BorderRadiusGeometry borderRadius;
  final bool isLight;

  const Container3d({
    super.key,
    this.child,
    this.margin = EdgeInsets.zero,
    this.padding = const EdgeInsets.all(10),
    this.alignment = Alignment.center,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.width,
    this.height,
    this.boxShadow,
    this.borderWidth,
    this.gradient,
    this.depth = 3.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.isLight = false,
  });

  @override
  State<Container3d> createState() => _Container3dState();
}

class _Container3dState extends State<Container3d>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final defaultBackgroundColor = widget.isLight
        ? colorScheme.surface
        : colorScheme.surfaceContainerHigh;

    final backgroundColor = widget.gradient == null
        ? (widget.backgroundColor ?? defaultBackgroundColor)
        : null;

    final borderColor = widget.borderColor ??
        (widget.isLight ? colorScheme.outlineVariant : colorScheme.outline);

    /// ---------------- NON-INTERACTIVE ----------------
    if (widget.onTap == null) {
      return Container(
        margin: widget.margin,
        padding: widget.padding,
        alignment: widget.alignment,
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          gradient: widget.gradient,
          color: backgroundColor,
          borderRadius: widget.borderRadius,
          border: Border.all(
            color: borderColor,
            width: widget.borderWidth ?? 1,
          ),
          boxShadow: widget.boxShadow ??
              [
                BoxShadow(
                  color: borderColor,
                  blurRadius: 0,
                  offset: const Offset(0, 3),
                ),
              ],
        ),
        child: widget.child,
      );
    }

    /// ---------------- INTERACTIVE ----------------
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (_, __) {
          final offset = widget.depth * _animation.value;
          final shadowOffset = Offset(0, widget.depth - offset);

          return Container(
            margin: widget.margin,
            child: Transform.translate(
              offset: Offset(0, offset),
              child: Container(
                padding: widget.padding,
                alignment: widget.alignment,
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  gradient: widget.gradient,
                  color: backgroundColor,
                  borderRadius: widget.borderRadius,
                  border: Border.all(
                    color: borderColor,
                    width: widget.borderWidth ?? 1,
                  ),
                  boxShadow: widget.boxShadow ??
                      [
                        BoxShadow(
                          color: borderColor,
                          blurRadius: 0,
                          offset: shadowOffset,
                        ),
                      ],
                ),
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}
