import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';

/// A rasterised map marker: the PNG bytes MapKit draws, plus the anchor and
/// scale it has to be given for them to land in the right place at the right
/// size.
class MarkerBitmap {
  const MarkerBitmap({
    required this.bytes,
    required this.anchor,
    required this.scale,
  });

  final Uint8List bytes;

  /// Normalised point of the bitmap that sits on the branch's coordinate —
  /// (0,0) is its top-left, (1,1) its bottom-right.
  final Offset anchor;

  /// What to pass as `PlacemarkIconStyle.scale` — see
  /// [BranchMarkerPainter._iconScale] for why it is 1 on every platform.
  final double scale;
}

/// Paints the branch pill that used to be the `_BranchLabel` widget.
///
/// `flutter_map` took an arbitrary widget per marker. Yandex placemarks take a
/// **bitmap**, so the pill is painted onto a canvas and handed to MapKit as PNG
/// bytes. This is therefore the only place the marker's appearance lives — if
/// the Figma `Tag` styling changes, it changes here.
///
/// Every colour is one of the theme-invariant statics (`chipGrey`,
/// `brandPurple`, `link`, `white`) exactly as the widget used, which is why the
/// bitmaps don't need re-rendering when the app theme flips.
class BranchMarkerPainter {
  BranchMarkerPainter._();

  // Pill geometry in Figma units, scaled through ScreenUtil at paint time the
  // same way the widget's `.w` / `.h` / `.r` did.
  static const _padLeft = 2.0;
  static const _padRight = 10.0;
  static const _padY = 2.0;
  static const _iconBox = 24.0;
  static const _iconGlyph = 16.0;
  static const _gap = 4.0;
  static const _pillRadius = 8.0;
  static const _iconRadius = 6.0;
  static const _selectedBorder = 1.5;

  /// The old `Marker(width: 160.w)` — the pill ellipsises rather than grow past
  /// this.
  static const _maxWidth = 160.0;

  /// `BoxShadow(blurRadius: 11.5, offset: Offset(0, 10))`, converted to the
  /// sigma `BoxShadow.toPaint` would have used.
  static const _shadowBlur = 11.5;
  static const _shadowDy = 10.0;
  static const _shadowSigma = _shadowBlur * 0.57735 + 0.5;

  /// Slack around the pill so the blurred shadow isn't clipped at the bitmap
  /// edge. Covers the blur plus its downward offset.
  static const _bleed = 24.0;

  /// Bitmaps are a few KB each and a search can plot hundreds of centres, so
  /// the cache is bounded rather than unbounded.
  static const _maxCacheEntries = 400;

  static final Map<String, MarkerBitmap> _cache = {};

  static ui.Picture? _iconPicture;
  static Size? _iconSize;

  /// Drops every cached bitmap.
  static void clearCache() => _cache.clear();

  /// What to hand MapKit as `PlacemarkIconStyle.scale`: **1 on both platforms**.
  ///
  /// The bitmap is painted at `devicePixelRatio`, so it is (logical size × dpr)
  /// **pixels**, and MapKit maps one bitmap pixel to one *physical* screen pixel
  /// on Android and iOS alike — so scale 1 already yields the intended logical
  /// size everywhere.
  ///
  /// This used to divide by dpr on iOS, on the theory that `UIImage(data:)`
  /// (which is what the plugin does, defaulting to `scale = 1.0`) makes UIKit
  /// read every pixel as a **point**. It does not: MapKit never sizes the icon
  /// in UIKit points, so the correction only shrank every pill and cluster
  /// bubble to a third of its size on a 3× phone.
  static const double _iconScale = 1.0;

  /// Rasterises the pill for [title], memoised.
  static Future<MarkerBitmap> build({
    required String title,
    required bool isSelected,
    required double devicePixelRatio,
  }) async {
    // ScreenUtil's scale factor is part of the geometry, so it belongs in the
    // key — a tablet/phone split or an orientation change changes the output.
    final key = '$title|$isSelected|$devicePixelRatio|${1.0.w}';
    final cached = _cache[key];
    if (cached != null) return cached;

    await _ensureIconLoaded();
    final bitmap = await _paint(
      title: title,
      isSelected: isSelected,
      dpr: devicePixelRatio,
    );

    if (_cache.length >= _maxCacheEntries) _cache.clear();
    _cache[key] = bitmap;
    return bitmap;
  }

  /// Rasterises the cluster bubble that stands in for [count] collapsed pills,
  /// memoised the same way [build] is.
  ///
  /// MapKit's default cluster appearance is a placemark with **no icon** (and
  /// the usual 0.5 opacity), i.e. invisible — supplying this is not optional
  /// once a [ClusterizedPlacemarkCollection] is in play.
  static Future<MarkerBitmap> buildCluster({
    required int count,
    required double devicePixelRatio,
  }) async {
    final key = 'cluster|$count|$devicePixelRatio|${1.0.w}';
    final cached = _cache[key];
    if (cached != null) return cached;

    final bitmap = await _paintCluster(count: count, dpr: devicePixelRatio);

    if (_cache.length >= _maxCacheEntries) _cache.clear();
    _cache[key] = bitmap;
    return bitmap;
  }

  /// Bubbles grow with the order of magnitude of the count so a three-digit
  /// cluster doesn't overflow a circle sized for two.
  static double _clusterDiameter(int count) {
    if (count < 10) return 36;
    if (count < 100) return 44;
    return 54;
  }

  static Future<MarkerBitmap> _paintCluster({
    required int count,
    required double dpr,
  }) async {
    final diameter = _clusterDiameter(count).w;
    final ring = 2.0.w;
    final bleed = _bleed.w;
    final size = diameter + bleed * 2;

    final label = TextPainter(
      text: TextSpan(
        text: '$count',
        style: AppText.semibold14.copyWith(color: AppColors.white),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      textScaler: TextScaler.noScaling,
    )..layout();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(dpr);

    final center = Offset(bleed + diameter / 2, bleed + diameter / 2);
    final radius = diameter / 2;

    // Same shadow the pills carry, so a cluster sits at the same visual height
    // as the markers it replaces.
    canvas.drawCircle(
      center.translate(0, _shadowDy.h),
      radius,
      Paint()
        ..color = AppColors.brandPurple.withValues(alpha: 0.40)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, _shadowSigma),
    );

    canvas.drawCircle(center, radius, Paint()..color = AppColors.brandPurple);
    canvas.drawCircle(
      center,
      radius - ring / 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ring
        ..color = AppColors.white,
    );

    label.paint(
      canvas,
      Offset(center.dx - label.width / 2, center.dy - label.height / 2),
    );

    final image = await recorder.endRecording().toImage(
          (size * dpr).ceil(),
          (size * dpr).ceil(),
        );
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    label.dispose();

    return MarkerBitmap(
      bytes: data!.buffer.asUint8List(),
      // A bubble is centred on the point it stands for, unlike the pills.
      anchor: const Offset(0.5, 0.5),
      scale: _iconScale,
    );
  }

  /// The building glyph, decoded once and replayed into every pill.
  static Future<void> _ensureIconLoaded() async {
    if (_iconPicture != null) return;
    try {
      final info = await vg.loadPicture(
        SvgAssetLoader(Assets.icons.home.building.path),
        null,
      );
      _iconPicture = info.picture;
      _iconSize = info.size;
    } catch (_) {
      // A missing/'unparseable asset must not take the map down — the pill just
      // renders without its glyph.
      _iconPicture = null;
      _iconSize = null;
    }
  }

  static Future<MarkerBitmap> _paint({
    required String title,
    required bool isSelected,
    required double dpr,
  }) async {
    final padLeft = _padLeft.w;
    final padRight = _padRight.w;
    final padY = _padY.h;
    final iconBox = _iconBox.w;
    final iconGlyph = _iconGlyph.w;
    final gap = _gap.w;
    final pillRadius = _pillRadius.r;
    final iconRadius = _iconRadius.r;

    final maxTextWidth =
        _maxWidth.w - padLeft - iconBox - gap - padRight;

    final label = TextPainter(
      text: TextSpan(
        text: title,
        style: AppText.semibold12.copyWith(color: AppColors.white),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
      // The marker is a fixed-size bitmap; letting the OS font setting stretch
      // it would push the label out of the pill.
      textScaler: TextScaler.noScaling,
    )..layout(maxWidth: maxTextWidth > 0 ? maxTextWidth : 0);

    final pillW = padLeft + iconBox + gap + label.width + padRight;
    final pillH = padY * 2 + iconBox;
    final bleed = _bleed.w;
    final width = pillW + bleed * 2;
    final height = pillH + bleed * 2;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(dpr);

    final pill = RRect.fromRectAndRadius(
      Rect.fromLTWH(bleed, bleed, pillW, pillH),
      Radius.circular(pillRadius),
    );

    canvas.drawRRect(
      pill.shift(Offset(0, _shadowDy.h)),
      Paint()
        ..color = isSelected
            ? AppColors.brandPurple.withValues(alpha: 0.40)
            : Colors.black.withValues(alpha: 0.10)
        ..maskFilter =
            const MaskFilter.blur(BlurStyle.normal, _shadowSigma),
    );

    canvas.drawRRect(
      pill,
      Paint()
        ..color = isSelected ? AppColors.brandPurple : AppColors.chipGrey,
    );

    if (isSelected) {
      final stroke = _selectedBorder.w;
      canvas.drawRRect(
        pill.deflate(stroke / 2),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..color = AppColors.white,
      );
    }

    final iconRect =
        Rect.fromLTWH(bleed + padLeft, bleed + padY, iconBox, iconBox);
    canvas.drawRRect(
      RRect.fromRectAndRadius(iconRect, Radius.circular(iconRadius)),
      Paint()..color = AppColors.link,
    );

    final picture = _iconPicture;
    final iconSize = _iconSize;
    if (picture != null &&
        iconSize != null &&
        iconSize.width > 0 &&
        iconSize.height > 0) {
      canvas.save();
      canvas.translate(
        iconRect.left + (iconBox - iconGlyph) / 2,
        iconRect.top + (iconBox - iconGlyph) / 2,
      );
      canvas.scale(
        iconGlyph / iconSize.width,
        iconGlyph / iconSize.height,
      );
      canvas.drawPicture(picture);
      canvas.restore();
    }

    label.paint(
      canvas,
      Offset(
        bleed + padLeft + iconBox + gap,
        bleed + (pillH - label.height) / 2,
      ),
    );

    final image = await recorder.endRecording().toImage(
          (width * dpr).ceil(),
          (height * dpr).ceil(),
        );
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    label.dispose();

    return MarkerBitmap(
      // The widget was `alignment: Alignment.centerLeft`, i.e. the coordinate
      // sat at the pill's left edge, vertically centred. The bleed is uniform,
      // so that is `bleed/width` across and dead centre down.
      bytes: data!.buffer.asUint8List(),
      anchor: Offset(bleed / width, 0.5),
      scale: _iconScale,
    );
  }
}
