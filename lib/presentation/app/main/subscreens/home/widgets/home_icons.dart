import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Iconsax icons pulled from the Figma redesign (`assets/icons/home/`),
/// rendered monochrome so they can be tinted per state.
class HomeIcon extends StatelessWidget {
  const HomeIcon(
    this.name, {
    super.key,
    required this.size,
    this.color,
    this.dir = 'home',
  });

  final String name;
  final double size;

  /// Tint applied via `srcIn`. Pass `null` to render the SVG's own colours
  /// (for multicolour icons like the detail info-tile glyphs).
  final Color? color;

  /// Sub-folder under `assets/icons/` (e.g. `home`, `detail`).
  final String dir;

  static const String home = 'home';
  static const String video = 'video';
  static const String calendar = 'calendar';
  static const String building = 'building';
  static const String profile = 'profile';
  static const String notification = 'notification';
  static const String search = 'search';
  static const String user = 'user';
  static const String book = 'book';
  static const String flash = 'flash';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/$dir/$name.svg',
      width: size.w,
      height: size.w,
      colorFilter:
          color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}
