import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/image_url.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';

/// A static promo for one of the app's own features, drawn as a coupon: copy
/// on the left, a perforated tear line, artwork on the stub.
///
/// Static on purpose — the copy and the art ship with the app and the tap
/// opens a screen that already exists, so the banner costs the feed no
/// request and can never be empty.
///
/// The fill is one of the fixed brand inks rather than a role: the ticket is
/// the same saturated block in both themes, like the packet slide in the
/// carousel.
///
/// **Its layout cannot clip**, for the reason spelled out on
/// `HomeAksiyaBanner`: the height is fixed, so both lines are capped and the
/// subtitle is the flexible child.
class HomeTicketBanner extends StatelessWidget {
  const HomeTicketBanner({
    super.key,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.art,
    required this.onTap,
    this.onColor = Colors.white,
  });

  final Color color;

  /// Ink for the copy. White on the purple and pink tickets; the gold one
  /// passes [AppColors.ink], because white on gold cannot be read.
  final Color onColor;
  final String title;
  final String subtitle;
  final AssetGenImage art;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final stub = 116.w;
    final notch = 9.r;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: 132.h,
          child: ClipPath(
            clipper: _TicketClipper(
              stub: stub,
              notch: notch,
              radius: 20.r,
            ),
            child: CustomPaint(
              foregroundPainter: _PerforationPainter(
                stub: stub,
                inset: notch + 6.h,
                color: onColor.withValues(alpha: 0.55),
              ),
              child: ColoredBox(
                color: color,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 14.h, 12.w, 14.h),
                        // No button and no chevron: the whole ticket is
                        // the tap target, and in a block this short a button
                        // took the room the subtitle needs — it was being cut
                        // to nothing under the title.
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.bold18.copyWith(color: onColor),
                            ),
                            6.verticalSpace,
                            Flexible(
                              child: Text(
                                subtitle,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.regular14.copyWith(
                                  color: onColor.withValues(alpha: 0.9),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: stub,
                      child: Padding(
                        padding: EdgeInsets.all(12.r),
                        // Decoration beside copy that already says it.
                        child: art.image(
                          fit: BoxFit.contain,
                          excludeFromSemantics: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A rounded rectangle with a half-circle bitten out of the top and bottom
/// edge where the stub begins — the tear a paper coupon has.
class _TicketClipper extends CustomClipper<Path> {
  const _TicketClipper({
    required this.stub,
    required this.notch,
    required this.radius,
  });

  final double stub;
  final double notch;
  final double radius;

  @override
  Path getClip(Size size) {
    final body = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(radius),
      ));
    final x = size.width - stub;
    final bites = Path()
      ..addOval(Rect.fromCircle(center: Offset(x, 0), radius: notch))
      ..addOval(
          Rect.fromCircle(center: Offset(x, size.height), radius: notch));
    return Path.combine(PathOperation.difference, body, bites);
  }

  @override
  bool shouldReclip(_TicketClipper old) =>
      old.stub != stub || old.notch != notch || old.radius != radius;
}

/// The dotted line between the two bites.
class _PerforationPainter extends CustomPainter {
  const _PerforationPainter({
    required this.stub,
    required this.inset,
    required this.color,
  });

  final double stub;
  final double inset;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final x = size.width - stub;
    const dot = 1.6;
    const gap = 7.0;
    for (var y = inset; y <= size.height - inset; y += gap) {
      canvas.drawCircle(Offset(x, y), dot, paint);
    }
  }

  @override
  bool shouldRepaint(_PerforationPainter old) =>
      old.stub != stub || old.inset != inset || old.color != color;
}

/// Four categories as large tiles, two by two.
///
/// The categories row at the top of the feed is a strip of small icons to
/// pick from; this is the same destination said loudly, far enough down that
/// the strip has long scrolled away. It takes the first four the server sent
/// and expects exactly four — the caller leaves the block out below that,
/// because three tiles in a two-column grid leave a hole.
class HomeCategoryTiles extends StatelessWidget {
  const HomeCategoryTiles({
    super.key,
    required this.categories,
    required this.onTap,
  });

  final List<HomCategory> categories;
  final ValueChanged<HomCategory> onTap;

  @override
  Widget build(BuildContext context) {
    final gap = 8.w;
    Widget tile(int i) => Expanded(
          child: _CategoryTile(
            category: categories[i],
            // Alternated on the diagonal, so the grid reads as four tiles
            // rather than as one purple slab.
            gradient: (i == 0 || i == 3)
                ? AppGradients.brand
                : AppGradients.indigo,
            onTap: () => onTap(categories[i]),
          ),
        );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          Row(children: [tile(0), SizedBox(width: gap), tile(1)]),
          SizedBox(height: gap),
          Row(children: [tile(2), SizedBox(width: gap), tile(3)]),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.gradient,
    required this.onTap,
  });

  final HomCategory category;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final url = sanitizeImageUrl(category.image);
    // Larger than the corner holds: the tile's own edge crops it, which is
    // what makes the picture part of the tile rather than an icon on it.
    final art = 84.w;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 108.h,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Stack(
          children: [
            // The artwork is a cut-out with no background of its own, so it
            // goes straight onto the gradient, in the bottom-right corner and
            // running off it. (It used to need a white plate under it.)
            if (url != null)
              Positioned(
                right: -8.w,
                bottom: -10.w,
                width: art,
                height: art,
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.contain,
                  fadeInDuration: Duration.zero,
                  fadeOutDuration: Duration.zero,
                  errorWidget: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            // The name, top-left. Its column stops short of the artwork, so a
            // two-line name wraps beside the picture and never over it.
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 12.h, 64.w, 12.h),
              child: Text(
                category.title ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppText.bold16.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Centres near the user, as a row of round photos with a name under each.
///
/// Every other shelf on the feed sells an activity; this one sells the place,
/// and the round frame is what says so before the header is read.
class HomeCentresShelf extends StatelessWidget {
  const HomeCentresShelf({super.key, required this.branches});

  final List<HomBranch> branches;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final photo = 64.w;
    return SizedBox(
      height: photo + 8.h + 34.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 8.w, right: 16.w),
        itemCount: branches.length,
        itemBuilder: (context, index) {
          final branch = branches[index];
          final url = sanitizeImageUrl(branch.image);
          return GestureDetector(
            key: ValueKey('centre-${branch.id ?? index}'),
            behavior: HitTestBehavior.opaque,
            onTap: () =>
                context.router.push(BranchDetailRoute(branch: branch)),
            child: Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: SizedBox(
                width: 76.w,
                child: Column(
                  children: [
                    Container(
                      width: photo,
                      height: photo,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: c.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: c.controlBorder),
                      ),
                      child: url == null
                          ? _initial(branch)
                          : CachedNetworkImage(
                              imageUrl: url,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => _initial(branch),
                            ),
                    ),
                    8.verticalSpace,
                    Text(
                      branch.title ?? '',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.medium12.copyWith(color: c.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _initial(HomBranch branch) {
    final title = branch.title ?? '';
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppGradients.brand),
      child: Center(
        child: Text(
          title.isNotEmpty ? title.characters.first.toUpperCase() : '?',
          style: AppText.bold18.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
