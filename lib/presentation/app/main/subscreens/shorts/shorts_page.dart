import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/utils/coupon_discount.dart';
import 'package:lumi_pass/data/api_model/class_full/class_full_model.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/service/photo_service.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';
import 'package:lumi_pass/presentation/app/cubit/app_cubit.dart';
import 'package:lumi_pass/presentation/app/cubit/app_state.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'shorts_feed.dart';

// Autoplay immediately (with sound) and loop — the plugin's WebView is
// configured to not require a user gesture, so the first short plays without a
// tap. Controls are hidden for a clean Reels-style surface.
const YoutubePlayerFlags _kPlayerFlags = YoutubePlayerFlags(
  autoPlay: true,
  mute: false,
  loop: true,
  hideControls: true,
  hideThumbnail: true,
  enableCaption: false,
  disableDragSeek: true,
);

@RoutePage()
class ShortsPage extends StatefulWidget {
  const ShortsPage({super.key});

  @override
  State<ShortsPage> createState() => _ShortsPageState();
}

class _ShortsPageState extends State<ShortsPage> {
  // Created lazily once the first video arrives, with that video as the
  // initial id + autoPlay — so it starts playing the moment the player mounts
  // instead of showing a static placeholder until the user interacts.
  YoutubePlayerController? _yt;
  final HomeRepository _repo = getIt<HomeRepository>();
  PageController? _pageController;
  List<HomClass> _classes = [];
  int _currentIndex = 0;
  bool _showSwipeHint = true;
  bool _isLoadingDefault = false;

  @override
  void initState() {
    super.initState();
    if (ShortsFeed.hasPending) {
      _applyPending();
    } else {
      _loadDefaultFeed();
    }
  }

  static String? _extractVideoId(HomClass hc) {
    final url = hc.videoUrl;
    if (url == null || url.isEmpty) return null;
    final id = YoutubePlayer.convertUrlToId(url);
    return (id != null && id.isNotEmpty) ? id : null;
  }

  // Spins up the player on the given slide's video. Call inside setState so the
  // feed rebuilds with a ready-to-autoplay controller.
  void _createControllerFor(int index) {
    if (index < 0 || index >= _classes.length) return;
    final videoId = _extractVideoId(_classes[index]);
    if (videoId == null) return;
    _yt?.dispose();
    _yt = YoutubePlayerController(
      initialVideoId: videoId,
      flags: _kPlayerFlags,
    );
  }

  // Switches the existing player to the slide's video (on swipe). Creates the
  // controller if it doesn't exist yet.
  void _showVideoAt(int index) {
    if (index < 0 || index >= _classes.length) return;
    final videoId = _extractVideoId(_classes[index]);
    if (videoId == null) return;
    final controller = _yt;
    if (controller == null) {
      setState(() => _createControllerFor(index));
    } else if (controller.metadata.videoId == videoId) {
      controller.seekTo(Duration.zero);
      controller.play();
    } else {
      controller.load(videoId);
    }
  }

  void _applyPending() {
    if (!ShortsFeed.hasPending) return;
    final allClasses = List<HomClass>.from(ShortsFeed.pendingClasses!);
    final requestedIndex = ShortsFeed.pendingIndex;
    ShortsFeed.clear();

    final classes = allClasses.where((c) => _extractVideoId(c) != null).toList();
    if (classes.isEmpty) {
      _loadDefaultFeed();
      return;
    }

    // Prefer starting at the originally requested class if it has a video,
    // otherwise fall back to the first class that does.
    final requestedId = requestedIndex < allClasses.length
        ? allClasses[requestedIndex].id
        : null;
    int index = requestedId != null
        ? classes.indexWhere((c) => c.id == requestedId)
        : -1;
    if (index < 0) index = 0;

    _pageController?.dispose();
    setState(() {
      _classes = classes;
      _currentIndex = index;
      _showSwipeHint = index == 0 && classes.length > 1;
      _pageController = PageController(initialPage: index);
      _createControllerFor(index);
    });
  }

  Future<void> _loadDefaultFeed() async {
    if (_isLoadingDefault) return;
    setState(() => _isLoadingDefault = true);
    try {
      // Dedicated backend feed: already scoped to activities that have a video,
      // so a single request is enough — no client-side paging of the catalogue.
      final result = await _repo.getDiscoveryShorts(page: 1, limit: 30);
      if (!mounted) return;
      // Keep only what this player can actually play (YouTube ids). Vimeo/other
      // providers are filtered here until the player supports them.
      final classes =
          result.classes.where((c) => _extractVideoId(c) != null).toList();
      _pageController?.dispose();
      setState(() {
        _classes = classes;
        _currentIndex = 0;
        _showSwipeHint = classes.length > 1;
        _pageController =
            classes.isNotEmpty ? PageController(initialPage: 0) : null;
        if (classes.isNotEmpty) _createControllerFor(0);
      });
    } catch (_) {
      // Swallow — empty state stays visible.
    } finally {
      if (mounted) setState(() => _isLoadingDefault = false);
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    _yt?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusDetector(
      onFocusGained: () {
        if (ShortsFeed.hasPending) {
          _applyPending();
        } else {
          if (_classes.isEmpty && !_isLoadingDefault) {
            _loadDefaultFeed();
          } else {
            _yt?.play();
          }
        }
      },
      onFocusLost: () => _yt?.pause(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _classes.isEmpty
            ? (_isLoadingDefault
                ? _buildLoadingState()
                : _buildEmptyState(context))
            : _buildFeed(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A0B2E), Color(0xFF0A0A0F)],
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A0B2E), Color(0xFF0A0A0F)],
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96.w,
                  height: 96.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.12),
                    ),
                  ),
                  child: Icon(
                    Icons.play_circle_outline_rounded,
                    color: Colors.white,
                    size: 52.sp,
                  ),
                ),
                24.kh,
                Text(
                  'shorts_empty_title'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                12.kh,
                Text(
                  'shorts_empty_subtitle'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 14.sp,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeed() {
    // Bottom nav bar floats over content (Scaffold.extendBody: true).
    // Reserve its height + a little breathing room so the video and
    // overlays sit fully above the bar.
    final bottomInset =
        MediaQuery.of(context).viewPadding.bottom + 56 + 4 + 12;
    final controller = _yt;
    if (controller == null) return _buildLoadingState();
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: controller,
        showVideoProgressIndicator: false,
      ),
      builder: (context, playerWidget) {
        return Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: _classes.length,
              onPageChanged: (i) {
                setState(() {
                  _currentIndex = i;
                  if (i > 0) _showSwipeHint = false;
                });
                _showVideoAt(i);
              },
              itemBuilder: (context, index) {
                return _ShortSlide(
                  hc: _classes[index],
                  isActive: index == _currentIndex,
                  player: playerWidget,
                  controller: controller,
                  showSwipeHint:
                      index == 0 && _showSwipeHint && _classes.length > 1,
                  bottomInset: bottomInset,
                );
              },
            ),
          ],
        );
      },
    );
  }
}

/// The YouTube player, cropped to fill the slide edge to edge.
///
/// The player is a fixed 9:16 box; a phone is taller than that, so laying it
/// out inside the slide leaves bars. Instead it is sized to *cover* — height
/// pinned to the slide, width derived from it — and the overflow is clipped,
/// which is what "fullscreen" means for a Shorts feed.
class _CoverPlayer extends StatelessWidget {
  const _CoverPlayer({required this.player});

  final Widget player;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        // Cover: never narrower than the slide, never shorter than it.
        final coverW = math.max(w, h * 9 / 16);
        final coverH = coverW * 16 / 9;

        return ClipRect(
          child: OverflowBox(
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            child: SizedBox(
              width: coverW,
              height: coverH,
              // Zoom in slightly: YouTube's channel header (top) and
              // "Shorts"/share badge (bottom) sit at the video edges and can't
              // be removed from the cross-origin iframe, so crop them off.
              child: Transform.scale(scale: 1.22, child: player),
            ),
          ),
        );
      },
    );
  }
}

class _ShortSlide extends StatelessWidget {
  const _ShortSlide({
    required this.hc,
    required this.isActive,
    required this.player,
    required this.controller,
    required this.showSwipeHint,
    required this.bottomInset,
  });

  final HomClass hc;
  final bool isActive;
  final Widget player;
  final YoutubePlayerController controller;
  final bool showSwipeHint;
  final double bottomInset;

  // Mirrors the home cards: when the cheapest tier is free but paid tiers
  // exist, show the lowest paid price; show a "from" price when there are
  // multiple tiers. Falls back to the flat price. Returns null when there's
  // nothing meaningful to show.
  //
  // Also mirrors the home cards' coupon preview: when the buyer has an active
  // plan, [discountedLabel] carries the discounted price to show alongside
  // the struck-through original, capped the same way the charge will be —
  // this page was the one place still showing the raw price.
  ({String label, String? discountedLabel})? _priceInfo(BuildContext context) {
    final snap = ClassPricingCache.get(hc.id);
    final hasFreeAndPaid =
        snap != null && snap.priceMin == 0 && snap.priceMinPaid > 0;
    final effectivePrice = hasFreeAndPaid
        ? snap.priceMinPaid
        : (snap != null && snap.priceMin > 0)
            ? snap.priceMin
            : (hc.price ?? 0);
    final showFrom = hasFreeAndPaid ||
        (snap != null && (snap.hasMultiplePrices || snap.rangeCount > 1));
    if (effectivePrice < 100) {
      return (label: 'price_free'.tr(), discountedLabel: null);
    }

    String fmt(num v) =>
        showFrom ? 'price_from'.tr(args: [v.toRawUzsPrice()]) : v.toRawUzsPrice();

    final app = context.watch<AppCubit>().state.buildable ?? const AppBuildable();
    final planPct = effectiveCouponPercent(
      app.hasPremium ? app.planDiscountPercentage : 0,
      hc.discountPercentage,
      isWholeCourse: hc.showsWholeCoursePrice,
    );
    if (planPct <= 0) return (label: fmt(effectivePrice), discountedLabel: null);

    final discounted = effectivePrice * (1 - planPct / 100);
    return (label: fmt(effectivePrice), discountedLabel: fmt(discounted));
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = hc.hasPhoto == true && hc.id != null
        ? PhotoService.getImageUrl(hc.id!)
        : null;

    return Stack(
      fit: StackFit.expand,
      children: [
        // The media is full-bleed: it runs edge to edge and under the floating
        // bottom bar. Insetting it by `bottomInset` (as this used to) letterboxed
        // the video — dead space at the top and a visible seam where the player
        // ended above the nav.
        if (isActive)
          _CoverPlayer(player: player)
        else if (imageUrl != null)
          CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => Container(color: Colors.grey.shade900),
          )
        else
          Container(color: Colors.grey.shade900),
        // Tap anywhere on the video to pause/resume (native controls are
        // hidden). Sits above the player but below the text/buttons so those
        // stay tappable.
        if (isActive)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: bottomInset,
            child: _PlayPauseTapLayer(controller: controller),
          ),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.35),
                  Colors.transparent,
                  Colors.black.withOpacity(0.75),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
            ),
          ),
        ),
        Positioned(
          left: 16.w,
          right: 80.w,
          bottom: 32.h + bottomInset,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if ((hc.category ?? '').isNotEmpty)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Text(
                    hc.category!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              10.kh,
              Text(
                hc.title ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              if ((hc.branch?.title ?? '').isNotEmpty) ...[
                8.kh,
                Row(
                  children: [
                    Icon(Icons.apartment_rounded,
                        size: 14.sp, color: Colors.white70),
                    6.kw,
                    Flexible(
                      child: Text(
                        hc.branch!.title!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              14.kh,
              GestureDetector(
                onTap: () =>
                    context.router.push(ClassDetailRoute(classModel: hc)),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 18.w, vertical: 11.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFA652C7), Color(0xFFFF7093)],
                    ),
                    borderRadius: BorderRadius.circular(26.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFA652C7).withOpacity(0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'view_details'.tr(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      6.kw,
                      Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 16.sp),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_priceInfo(context) != null)
          Positioned(
            right: 12.w,
            bottom: 32.h + bottomInset,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Builder(builder: (context) {
                final info = _priceInfo(context)!;
                if (info.discountedLabel == null) {
                  return Text(
                    info.label,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2E3D5D),
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      info.label,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF9AA2B1),
                        decoration: TextDecoration.lineThrough,
                        decorationColor: const Color(0xFF9AA2B1),
                      ),
                    ),
                    Text(
                      info.discountedLabel!,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.green,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        if (showSwipeHint)
          Positioned(
            left: 0,
            right: 0,
            bottom: 130.h + bottomInset,
            child: IgnorePointer(
              child: Center(
                child: _SwipeUpHint(),
              ),
            ),
          ),
      ],
    );
  }
}

class _SwipeUpHint extends StatefulWidget {
  @override
  State<_SwipeUpHint> createState() => _SwipeUpHintState();
}

class _SwipeUpHintState extends State<_SwipeUpHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offsetAnim;
  late final Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _offsetAnim = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _opacityAnim = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Opacity(
          opacity: _opacityAnim.value,
          child: Transform.translate(
            offset: Offset(0, _offsetAnim.value),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: Colors.white.withOpacity(0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.keyboard_arrow_up_rounded,
                      color: Colors.white, size: 18.sp),
                  6.kw,
                  Text(
                    'swipe_up_for_next'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
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
}

// Transparent gesture layer over the video: tap toggles play/pause and shows a
// centred play glyph while paused. Listens to the controller so the glyph
// tracks the real playback state (e.g. buffering / focus changes).
class _PlayPauseTapLayer extends StatefulWidget {
  const _PlayPauseTapLayer({required this.controller});

  final YoutubePlayerController controller;

  @override
  State<_PlayPauseTapLayer> createState() => _PlayPauseTapLayerState();
}

class _PlayPauseTapLayerState extends State<_PlayPauseTapLayer> {
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onValue);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onValue);
    super.dispose();
  }

  void _onValue() {
    final paused = !widget.controller.value.isPlaying;
    if (paused != _paused && mounted) setState(() => _paused = paused);
  }

  void _toggle() {
    final c = widget.controller;
    c.value.isPlaying ? c.pause() : c.play();
  }

  @override
  Widget build(BuildContext context) {
    // Just a centred play glyph while paused — no full-screen scrim (the
    // zoom-crop already hides YouTube's edge chrome). Tap anywhere to toggle.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggle,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: _paused ? 1 : 0,
        child: Center(
          child: Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.play_arrow_rounded,
                color: Colors.white, size: 44.sp),
          ),
        ),
      ),
    );
  }
}
