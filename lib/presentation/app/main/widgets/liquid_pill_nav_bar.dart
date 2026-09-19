import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// One destination of the [LiquidPillNavBar].
class LiquidNavDestination {
  const LiquidNavDestination({required this.asset, required this.label});

  /// SVG asset path for the glyph.
  final String asset;
  final String label;
}

/// Renders the glyph. [progress] is 0 when the item is idle and 1 when the
/// blob fully covers its slot — crossfade the selected/unselected treatments
/// with it rather than switching on a bool, so the icon lights up *with* the
/// liquid instead of a beat behind it.
typedef LiquidNavIconBuilder = Widget Function(
  BuildContext context,
  LiquidNavDestination item,
  double progress,
  double size,
);

/// Renders the label. Same [progress] contract as [LiquidNavIconBuilder].
typedef LiquidNavLabelBuilder = Widget Function(
  BuildContext context,
  LiquidNavDestination item,
  double progress,
);

/// The frosted pill bar, with the selection highlight driven by two springs
/// instead of a curve.
///
/// Ported from `github.com/Mirxomitov/liquid-glass-flutter` (the spring model
/// and the drag behaviour are that repo's); the surface — blur, rim gradient,
/// shadows, pill fill, icon/label treatment — stays the Figma "Бар" component
/// this app already shipped, so only the *motion* changes.
///
/// How it moves: no duration, no curve. Two springs run on a [Ticker] and the
/// blob's shape is whatever they disagree about.
///
///   • **The head** ([_kLead], `ζ = 1.0`) is critically damped. It runs to the
///     tab you picked and stops dead — it never travels past it.
///   • **The tail** ([_kTrail], `ζ = 0.40`) chases *the head*, not the
///     destination, so it is behind by construction while the head is running.
///     Once the head parks, the tail catches up, runs past the middle and
///     swings back — twice. That ringing is the whole wobble, and because the
///     head is pinned it reads as the body squashing and stretching in place
///     rather than as an overshoot.
///
/// Volume is roughly conserved: drawn out the pill flattens, compressed it
/// rises. The ticker stops itself once everything settles, so an idle bar
/// costs nothing.
///
/// Press anywhere on the bar and drag and the blob follows your finger through
/// the same springs. **The route changes once, on release** — dragging from
/// the first tab to the last does not push every page in between; on release
/// the throw velocity is projected forward to pick the landing slot.
class LiquidPillNavBar extends StatefulWidget {
  const LiquidPillNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
    required this.iconBuilder,
    required this.labelBuilder,
    // Apple's tab-bar metric: a 25pt glyph over a 10pt label.
    this.height = 60,
    this.horizontalPadding = 16,
    this.bottomPadding = 20,
    this.borderRadius = 56,
    this.borderWidth = 1,
    this.borderGradient,
    this.backgroundColor,
    this.blurSigma = 24,
    this.shadows = const <BoxShadow>[],
    this.pillColor = const Color(0xFFE5E7EA),
    this.pillHeightFactor = 0.9,
    this.pillHorizontalInset = 4,
    this.iconSize = 25,
    this.labelGap = 3,
    this.enableDrag = true,
  }) : assert(items.length > 1);

  final List<LiquidNavDestination> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final LiquidNavIconBuilder iconBuilder;
  final LiquidNavLabelBuilder labelBuilder;

  final double height;
  final double horizontalPadding;

  /// Gap below the bar. Taken literally — the caller folds in whatever system
  /// inset it wants (see `CustomBottomBar`), this widget adds none of its own.
  final double bottomPadding;

  final double borderRadius;
  final double borderWidth;

  /// Faint ring painted outside the blur, so the bar keeps a defined edge over
  /// plain-white pages. Null draws no rim.
  final Gradient? borderGradient;

  final Color? backgroundColor;
  final double blurSigma;
  final List<BoxShadow> shadows;

  final Color pillColor;
  final double pillHeightFactor;
  final double pillHorizontalInset;

  final double iconSize;
  final double labelGap;

  /// Whether dragging the blob along the bar selects a tab on release.
  final bool enableDrag;

  @override
  State<LiquidPillNavBar> createState() => _LiquidPillNavBarState();
}

class _LiquidPillNavBarState extends State<LiquidPillNavBar>
    with SingleTickerProviderStateMixin {
  // Leading edge: critically damped, so the head runs to the destination and
  // stops dead. It never reaches past the tab it is travelling to.
  static const double _kLead = 400, _zLead = 1.0;
  // Trailing edge: chases the *head*, not the destination, and rings on
  // arrival. See the class doc.
  static const double _kTrail = 240, _zTrail = 0.40;

  late final Ticker _ticker = createTicker(_tick);
  Duration _last = Duration.zero;

  double _targetX = double.nan; // where the blob wants to be (bar-local px)
  double _leadX = double.nan, _leadV = 0;
  double _trailX = double.nan, _trailV = 0;

  double _slot = 0, _barWidth = 0;
  bool _dragging = false;
  double _grab = 1; // 0 -> resting, 1 -> fully grabbed
  double _selectFade = 1; // short colour fade right after the selection changes
  double _dir = 1; // travel direction: +1 rightwards, -1 leftwards
  late int _emitted = widget.selectedIndex; // last index handed to onTap
  int? _hover; // item the blob is over mid-drag, before anything is committed

  @override
  void didUpdateWidget(covariant LiquidPillNavBar old) {
    super.didUpdateWidget(old);
    if (old.selectedIndex != widget.selectedIndex) {
      _emitted = widget.selectedIndex;
      if (!_dragging) {
        _targetX = _centerOf(widget.selectedIndex);
        _aimAt(_targetX);
        _selectFade = 0;
        _ensureTicking();
      }
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  /// The ticker only runs while something is actually moving.
  void _ensureTicking() {
    if (!_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    }
  }

  bool get _atRest =>
      !_dragging &&
      (_leadX - _targetX).abs() < 0.05 &&
      _leadV.abs() < 0.5 &&
      (_trailX - _leadX).abs() < 0.05 &&
      _trailV.abs() < 0.5 &&
      _grab < 0.002 &&
      _selectFade >= 1;

  double _centerOf(int index) => _slot * (index + 0.5);

  /// Remembers which way the body is travelling, so the head stays the head.
  void _aimAt(double target) {
    if ((target - _leadX).abs() > 0.5) _dir = target > _leadX ? 1 : -1;
  }

  int _indexAt(double x) =>
      (x / _slot).floor().clamp(0, widget.items.length - 1);

  void _tick(Duration elapsed) {
    if (_slot == 0 || _targetX.isNaN) return;
    var dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    if (dt <= 0) return;
    dt = math.min(dt, 1 / 30); // survive a dropped frame without exploding

    final before = [_leadX, _trailX, _grab, _selectFade];

    _leadX = _spring(
      _leadX,
      () => _leadV,
      (v) => _leadV = v,
      _targetX,
      _kLead,
      _zLead,
      dt,
    );
    _trailX = _spring(
      _trailX,
      () => _trailV,
      (v) => _trailV = v,
      _leadX,
      _kTrail,
      _zTrail,
      dt,
    );

    final grabTarget = _dragging ? 1.0 : 0.0;
    _grab += (grabTarget - _grab) * (1 - math.exp(-dt / 0.07));
    _selectFade = math.min(1, _selectFade + dt / 0.22);

    if (_atRest) {
      _leadX = _trailX = _targetX;
      _leadV = _trailV = 0;
      _grab = 0;
      _ticker.stop();
    }

    if (before[0] != _leadX ||
        before[1] != _trailX ||
        before[2] != _grab ||
        before[3] != _selectFade) {
      setState(() {});
    }
  }

  double _spring(
    double x,
    double Function() getV,
    void Function(double) setV,
    double target,
    double k,
    double zeta,
    double dt,
  ) {
    var v = getV();
    final c = 2 * math.sqrt(k) * zeta;
    // Sub-step so a stiff spring stays stable at any frame rate.
    const steps = 4;
    final h = dt / steps;
    for (var i = 0; i < steps; i++) {
      v += (-k * (x - target) - c * v) * h;
      x += v * h;
    }
    setV(v);
    return x;
  }

  void _select(int index, {bool haptic = true}) {
    if (index != _emitted) {
      _emitted = index;
      if (haptic) HapticFeedback.lightImpact();
      _selectFade = 0;
      widget.onTap(index);
    }
    _ensureTicking();
  }

  void _onDragStart(DragStartDetails d) {
    _dragging = true;
    _targetX = d.localPosition.dx.clamp(_slot / 2, _barWidth - _slot / 2);
    _aimAt(_targetX);
    HapticFeedback.selectionClick();
    _ensureTicking();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    final x = d.localPosition.dx.clamp(_slot / 2, _barWidth - _slot / 2);
    if ((x - _trailX).abs() > 1) _dir = x > _trailX ? 1 : -1;
    setState(() => _targetX = x);
    _ensureTicking();
    // Highlight what the blob is over, but don't commit: the route only
    // changes on release, so a drag from the first tab to the last doesn't
    // push everything in between.
    final i = _indexAt(x);
    if (i != _hover) {
      _hover = i;
      HapticFeedback.selectionClick();
      _selectFade = 0;
    }
  }

  void _onDragEnd(double velocity) {
    _dragging = false;
    // Let the throw carry the blob a little further before it picks a slot.
    final projected = (_targetX + velocity * 0.06).clamp(0.0, _barWidth - 1);
    final index = _indexAt(projected);
    _hover = null;
    setState(() => _targetX = _centerOf(index));
    _aimAt(_targetX);
    _select(index, haptic: index != _emitted);
  }

  /// How "lit" an item is: how much of its slot the blob currently covers,
  /// with a short head start for the item that was just selected so the tap
  /// feels instant.
  double _progressFor(int index, Rect pill) {
    final slotRect = Rect.fromLTWH(_slot * index, 0, _slot, widget.height);
    final overlap = math.max(
      0.0,
      math.min(pill.right, slotRect.right) -
          math.max(pill.left, slotRect.left),
    );
    final coverage =
        (overlap / math.min(pill.width, _slot)).clamp(0.0, 1.0);
    final lit = Curves.easeOut.transform(coverage);
    return index == (_hover ?? _emitted)
        ? math.max(lit, Curves.easeOut.transform(_selectFade))
        : lit;
  }

  @override
  Widget build(BuildContext context) {
    final hasRim = widget.borderGradient != null;
    // With a rim the outer shape carries the border + shadow, so the blurred
    // fill clips to the inset radius and drops both.
    final innerRadius = hasRim
        ? (widget.borderRadius - widget.borderWidth)
            .clamp(0.0, widget.borderRadius)
        : widget.borderRadius;
    final bg = widget.backgroundColor ??
        Theme.of(context).colorScheme.surface.withValues(alpha: 0.78);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        widget.horizontalPadding,
        0,
        widget.horizontalPadding,
        widget.bottomPadding,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          _barWidth = constraints.maxWidth;
          _slot = _barWidth / widget.items.length;
          if (_targetX.isNaN) {
            _targetX = _leadX = _trailX = _centerOf(widget.selectedIndex);
          }

          final baseWidth = _slot - widget.pillHorizontalInset;
          final minWidth = baseWidth * 0.62;
          final pillH = widget.height * widget.pillHeightFactor;

          // The head is pinned to the leading spring and never runs past it;
          // only the tail stretches the body out behind. When the tail arrives
          // with momentum it pushes the body shorter instead of shoving the
          // head onwards, which is what makes it squash in place.
          double left, right;
          if (_dir >= 0) {
            right = _leadX + baseWidth / 2;
            left = math.min(_trailX - baseWidth / 2, right - minWidth);
          } else {
            left = _leadX - baseWidth / 2;
            right = math.max(_trailX + baseWidth / 2, left + minWidth);
          }

          // Roughly constant volume: drawn out it flattens, compressed it
          // rises. Grabbing it puffs it up a touch. Capped at the bar height
          // so a compressed blob can't grow past the slab it lives in.
          final elongation = (right - left) / baseWidth - 1;
          final squash = (1 - 0.14 * elongation.clamp(-1.0, 2.0)) *
              (1 + 0.05 * _grab);
          final h = math.min(pillH * squash, widget.height);
          final pill =
              Rect.fromLTWH(left, (widget.height - h) / 2, right - left, h);

          Widget bar = ClipRRect(
            borderRadius: BorderRadius.circular(innerRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: widget.blurSigma,
                sigmaY: widget.blurSigma,
              ),
              child: Container(
                height: widget.height,
                decoration: BoxDecoration(
                  color: bg,
                  boxShadow: hasRim ? null : widget.shadows,
                ),
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    // Clipped to the slab, so an overshoot at either end
                    // squashes against the wall instead of spilling out.
                    Positioned.fromRect(
                      rect: pill,
                      child: IgnorePointer(
                        key: const ValueKey('liquid-blob'),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            // Deepens slightly under the finger, so a grab
                            // reads as pressure.
                            color: Color.lerp(
                              widget.pillColor,
                              Color.alphaBlend(
                                const Color(0x14000000),
                                widget.pillColor,
                              ),
                              _grab,
                            ),
                            borderRadius: BorderRadius.circular(h / 2),
                          ),
                        ),
                      ),
                    ),
                    IgnorePointer(
                      child: Row(
                        children: [
                          for (var i = 0; i < widget.items.length; i++)
                            Expanded(
                              child: _LiquidNavItem(
                                item: widget.items[i],
                                progress: _progressFor(i, pill),
                                grab: i == (_hover ?? _emitted) ? _grab : 0,
                                height: widget.height,
                                iconSize: widget.iconSize,
                                labelGap: widget.labelGap,
                                iconBuilder: widget.iconBuilder,
                                labelBuilder: widget.labelBuilder,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // One gesture surface for the whole bar: taps pick an
                    // item, drags take the blob with them.
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapUp: (d) => _select(_indexAt(d.localPosition.dx)),
                        onHorizontalDragStart:
                            widget.enableDrag ? _onDragStart : null,
                        onHorizontalDragUpdate:
                            widget.enableDrag ? _onDragUpdate : null,
                        onHorizontalDragEnd: widget.enableDrag
                            ? (d) => _onDragEnd(d.velocity.pixelsPerSecond.dx)
                            : null,
                        onHorizontalDragCancel:
                            widget.enableDrag ? () => _onDragEnd(0) : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );

          if (hasRim) {
            bar = Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                gradient: widget.borderGradient,
                boxShadow: widget.shadows,
              ),
              padding: EdgeInsets.all(widget.borderWidth),
              child: bar,
            );
          }

          return bar;
        },
      ),
    );
  }
}

class _LiquidNavItem extends StatelessWidget {
  const _LiquidNavItem({
    required this.item,
    required this.progress,
    required this.grab,
    required this.height,
    required this.iconSize,
    required this.labelGap,
    required this.iconBuilder,
    required this.labelBuilder,
  });

  final LiquidNavDestination item;
  final double progress; // 0 = idle, 1 = fully under the blob
  final double grab;
  final double height;
  final double iconSize;
  final double labelGap;
  final LiquidNavIconBuilder iconBuilder;
  final LiquidNavLabelBuilder labelBuilder;

  @override
  Widget build(BuildContext context) {
    // A little lift as the blob claims the item, a little more while grabbed.
    final scale = 1 + 0.08 * progress + 0.04 * grab;

    return SizedBox(
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.scale(
            scale: scale,
            child: iconBuilder(context, item, progress, iconSize),
          ),
          SizedBox(height: labelGap),
          labelBuilder(context, item, progress),
        ],
      ),
    );
  }
}
