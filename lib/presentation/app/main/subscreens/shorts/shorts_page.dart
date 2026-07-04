import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/service/photo_service.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';
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

class _ShortSlide extends StatelessWidget {
  const _ShortSlide({
    required this.hc,
    required this.isActive,
    required this.player,
    required this.showSwipeHint,
    required this.bottomInset,
  });

  final HomClass hc;
  final bool isActive;
  final Widget player;
  final bool showSwipeHint;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    final imageUrl = hc.hasPhoto == true && hc.id != null
        ? PhotoService.getImageUrl(hc.id!)
        : null;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (isActive)
          Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Center(
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: player,
              ),
            ),
          )
        else if (imageUrl != null)
          Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) =>
                  Container(color: Colors.grey.shade900),
            ),
          )
        else
          Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Container(color: Colors.grey.shade900),
          ),
        Positioned.fill(
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
        if (hc.price != null)
          Positioned(
            right: 12.w,
            bottom: 32.h + bottomInset,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Text(
                hc.price!.toUzsPrice(),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2E3D5D),
                ),
              ),
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
