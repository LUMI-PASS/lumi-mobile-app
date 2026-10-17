import 'package:flutter/material.dart';

/// Track shapes that draw a slider's line as separate rounded pieces — four
/// quarters of the day on the time filter, one piece per radius step on the
/// map's distance filter — so the labels under it have a mark to sit under.
///
/// Every piece is its own rounded pill, so the ends at each gap are round
/// too. Cutting gaps out of one long track left square ends there.
///
/// Both pieces keep the stock shapes' [getPreferredRect], so the thumbs, the
/// insets and the hit area are exactly what they were.
class SegmentedRangeSliderTrackShape extends RoundedRectRangeSliderTrackShape {
  const SegmentedRangeSliderTrackShape({required this.segments, this.gap = 4});

  final int segments;

  /// Space between two pieces, in logical pixels.
  final double gap;

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset startThumbCenter,
    required Offset endThumbCenter,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
    double additionalActiveTrackHeight = 2,
  }) {
    final track = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    final left = startThumbCenter.dx < endThumbCenter.dx
        ? startThumbCenter.dx
        : endThumbCenter.dx;
    final right = startThumbCenter.dx < endThumbCenter.dx
        ? endThumbCenter.dx
        : startThumbCenter.dx;
    _paintSegments(
      context.canvas,
      track: track,
      segments: segments,
      gap: gap,
      activeFrom: left,
      activeTo: right,
      sliderTheme: sliderTheme,
    );
  }
}

/// [SegmentedRangeSliderTrackShape] for a one-thumb [Slider]: active from the
/// start of the line to the thumb.
class SegmentedSliderTrackShape extends RoundedRectSliderTrackShape {
  const SegmentedSliderTrackShape({required this.segments, this.gap = 4});

  final int segments;
  final double gap;

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    final track = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    final rtl = textDirection == TextDirection.rtl;
    _paintSegments(
      context.canvas,
      track: track,
      segments: segments,
      gap: gap,
      activeFrom: rtl ? thumbCenter.dx : track.left,
      activeTo: rtl ? track.right : thumbCenter.dx,
      sliderTheme: sliderTheme,
    );
  }
}

/// Each piece in the inactive colour, then the part of it between
/// [activeFrom] and [activeTo] over it in the active colour. The active part
/// is clipped to the piece's own rounded outline, so it keeps the round ends
/// at the gaps and stops square only under a thumb, which covers it.
void _paintSegments(
  Canvas canvas, {
  required Rect track,
  required int segments,
  required double gap,
  required double activeFrom,
  required double activeTo,
  required SliderThemeData sliderTheme,
}) {
  final inactive = Paint()
    ..color = sliderTheme.inactiveTrackColor ?? Colors.grey;
  final active = Paint()..color = sliderTheme.activeTrackColor ?? Colors.blue;
  final radius = Radius.circular(track.height / 2);
  final width = track.width / segments;
  for (var i = 0; i < segments; i++) {
    final piece = RRect.fromLTRBR(
      track.left + width * i + (i == 0 ? 0 : gap / 2),
      track.top,
      track.left + width * (i + 1) - (i == segments - 1 ? 0 : gap / 2),
      track.bottom,
      radius,
    );
    canvas.drawRRect(piece, inactive);
    final from = activeFrom.clamp(piece.left, piece.right);
    final to = activeTo.clamp(piece.left, piece.right);
    if (to <= from) continue;
    canvas
      ..save()
      ..clipRRect(piece)
      ..drawRect(Rect.fromLTRB(from, track.top, to, track.bottom), active)
      ..restore();
  }
}

/// The thumb for a segmented line: the fill colour inside a white ring, with a
/// soft shadow under it.
///
/// The ring is what keeps the pieces apart. A thumb resting on a stop sits on
/// a gap and is wider than it, so a plain disc touched the grey piece after it
/// and the filled line read as running on into the empty one.
void _paintRingedThumb(Canvas canvas, Offset center, Color fill) {
  const radius = 10.0;
  const ring = 3.0;
  canvas
    ..drawShadow(
      Path()..addOval(Rect.fromCircle(center: center, radius: radius + ring)),
      const Color(0x55000000),
      2,
      false,
    )
    ..drawCircle(center, radius + ring, Paint()..color = Colors.white)
    ..drawCircle(center, radius, Paint()..color = fill);
}

/// [SegmentedSliderTrackShape]'s thumb, for a one-thumb [Slider].
class RingedSliderThumb extends SliderComponentShape {
  const RingedSliderThumb({required this.color});

  final Color color;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(26, 26);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) =>
      _paintRingedThumb(context.canvas, center, color);
}

/// [SegmentedRangeSliderTrackShape]'s thumbs, for a [RangeSlider].
class RingedRangeSliderThumb extends RangeSliderThumbShape {
  const RingedRangeSliderThumb({required this.color});

  final Color color;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(26, 26);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = true,
    bool isOnTop = false,
    bool isPressed = false,
    required SliderThemeData sliderTheme,
    TextDirection textDirection = TextDirection.ltr,
    Thumb thumb = Thumb.start,
    double? textScaleFactor,
    Size? sizeWithOverflow,
  }) =>
      _paintRingedThumb(context.canvas, center, color);
}
