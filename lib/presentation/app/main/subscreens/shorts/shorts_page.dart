import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/utils/coupon_discount.dart';
import 'package:lumi_pass/data/api_model/class_full/class_full_model.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/service/photo_service.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';
import 'package:lumi_pass/common/widget/promo_included_label.dart';
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

// The neighbour being warmed up. It *does* autoplay, muted and off-screen,
// and is parked after [_kWarmupLead] — see [_Slot]. Building the player
// without playing it (which is what this used to do) only warms the WebView
// and YouTube's JS; the iframe will not fetch a single byte of video until
// something calls play, so the swipe still paid for the download.
const YoutubePlayerFlags _kWarmupFlags = YoutubePlayerFlags(
  autoPlay: true,
  mute: true,
  loop: true,
  hideControls: true,
  hideThumbnail: true,
  enableCaption: false,
  disableDragSeek: true,
);

// How far a warmed-up neighbour is allowed to run before it is parked. Long
// enough to have decoded a first frame and buffered the opening; short enough
// that a short the user never reaches costs very little data — which matters
// on the mobile networks most of these users are on.
const Duration _kWarmupLead = Duration(milliseconds: 600);

const int _kPageSize = 30;

// Start pulling the next page once the user is this close to the end. Far
// enough ahead that the request finishes before they arrive, so the feed never
// visibly stops.
const int _kPrefetchWithin = 5;

// A page can be filtered away to nothing (Vimeo links, URLs the player cannot
// parse), so one fetch may have to walk a few pages. Bounded so a feed that is
// entirely unplayable cannot spin through the whole catalogue in one go.
const int _kMaxPagesPerFetch = 3;

/// Where a slide's player is, from the feed's point of view.
///
/// Drives the poster overlay. The package draws nothing at all while a video
/// is loading, so without this the user was left looking at the previous
/// video's last frame — which is what read as the player "freezing".
enum _PlayerPhase { loading, playing, error }

/// One live YouTube player.
///
/// The feed keeps at most three of these — the slide on screen, the one before
/// it and the one after — because each is a WebView with its own renderer
/// process.
///
/// A slot created with `warmup: true` autoplays muted and off-screen, then
/// pauses itself at [_kWarmupLead]. By the time the user swipes onto it the
/// WebView is up, YouTube's JS is loaded, the opening is buffered and a frame
/// is decoded, so activating it is just an unmute and a play.
class _Slot {
  _Slot({required this.videoId, required bool warmup})
      : _warming = warmup,
        _muted = warmup,
        _neverShown = warmup,
        controller = YoutubePlayerController(
          initialVideoId: videoId,
          flags: warmup ? _kWarmupFlags : _kPlayerFlags,
        ) {
    controller.addListener(_onValue);
  }

  final String videoId;
  final YoutubePlayerController controller;
  final ValueNotifier<_PlayerPhase> phase =
      ValueNotifier<_PlayerPhase>(_PlayerPhase.loading);

  /// Fired once this player has decoded its first frames, whether it is the
  /// slide on screen or a neighbour warming up. The feed uses it to start
  /// warming the *next* slide only once this one is genuinely under way.
  VoidCallback? onFirstFrame;

  // Still running muted off-screen to build a buffer.
  bool _warming;
  // Created as a warm-up and not yet handed to the user. Covers both the
  // parked case and the one where the user swipes on while it is still
  // warming: either way it is some way into the video and has to rewind.
  bool _neverShown;
  bool _muted;
  // A play/pause asked for before the iframe was ready. The package silently
  // throws those away — `YoutubePlayerController._callMethod` only logs when
  // `isReady` is false — so a swipe that landed mid-load used to vanish and
  // leave the previous video running. Parking the intent and replaying it on
  // ready is the fix.
  bool? _pendingIntent;
  bool _hasPlayed = false;

  /// Whether this player already has frames on the glass.
  bool get hasFrames => _hasPlayed;

  /// Become the slide the user is watching.
  void activate() {
    final rewind = _neverShown;
    _warming = false;
    _neverShown = false;
    // Rewind whatever the warm-up consumed. It is inside the buffer already,
    // so this is instant — and without it the user misses the opening, which
    // on a short is most of the hook.
    if (rewind && controller.value.isReady) {
      controller.seekTo(Duration.zero);
    }
    _send(true);
  }

  /// Step back to being a neighbour. A slot still warming up is left alone —
  /// that is the whole point of it.
  void park() {
    if (_warming) return;
    _send(false);
  }

  /// Hard stop, used when the tab loses focus: even a warm-up has to yield.
  void suspend() {
    _warming = false;
    _send(false);
  }

  void toggle() => _send(!controller.value.isPlaying);

  void _send(bool play) {
    if (!controller.value.isReady) {
      _pendingIntent = play;
      return;
    }
    _pendingIntent = null;
    if (!play) {
      controller.pause();
      return;
    }
    // Warm-ups run muted; handing one to the user is where the sound comes on.
    if (_muted) {
      _muted = false;
      controller.unMute();
    }
    controller.play();
  }

  void _onValue() {
    final v = controller.value;
    if (v.errorCode != 0) {
      phase.value = _PlayerPhase.error;
      return;
    }
    if (!v.isReady) return;

    final pending = _pendingIntent;
    if (pending != null) {
      _pendingIntent = null;
      _send(pending);
      return;
    }

    // Latched: the poster only has to lift once. Following `isPlaying` here
    // would bring it back every time the user taps to pause.
    if (!_hasPlayed && v.isPlaying && v.position > Duration.zero) {
      _hasPlayed = true;
      phase.value = _PlayerPhase.playing;
      onFirstFrame?.call();
    }

    // Enough buffer — stop spending the user's data on a video they may never
    // reach, and keep the decoded frame ready for when they do.
    if (_warming && v.isPlaying && v.position >= _kWarmupLead) {
      _warming = false;
      controller.pause();
    }
  }

  void dispose() {
    onFirstFrame = null;
    controller.removeListener(_onValue);
    controller.dispose();
    phase.dispose();
  }
}

@RoutePage()
class ShortsPage extends StatefulWidget {
  const ShortsPage({super.key});

  @override
  State<ShortsPage> createState() => _ShortsPageState();
}

class _ShortsPageState extends State<ShortsPage> {
  final HomeRepository _repo = getIt<HomeRepository>();
  PageController? _pageController;
  List<HomClass> _classes = [];
  int _currentIndex = 0;
  bool _isLoadingDefault = false;

  // Paging cursor for the discovery feed. The feed used to be a single
  // 30-item request and simply dead-ended on the last slide.
  int _nextPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  // Whether what we are showing came from discovery. A feed handed over from
  // the home screen must not be written back into the shared cache.
  bool _feedIsDefault = false;

  // Live players keyed by feed index. At most three entries — see [_syncSlots].
  final Map<int, _Slot> _slots = {};

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

  // Aligns the player pool with the page on screen. The active slide plays;
  // the slide after it is warmed up in the background so swiping onto it is
  // instant; the slide before it is kept alive so swiping back is instant too.
  //
  // The previous slot is never *created* here, only kept — after a forward
  // swipe the slide you came from is already a fully warm player, so backwards
  // costs nothing extra. That caps the pool at three WebViews.
  //
  // This is what the old design couldn't do at all. One shared controller
  // meant one video at a time, so every swipe called `load()` into a cold
  // iframe and paid the whole start-up cost in front of the user.
  //
  // Call inside setState: adding or dropping a slot changes which slides mount
  // a player.
  void _syncSlots() {
    final keep = <int>{_currentIndex};
    for (final neighbour in [_currentIndex - 1, _currentIndex + 1]) {
      if (_slots.containsKey(neighbour)) keep.add(neighbour);
    }
    for (final index in _slots.keys.toList()) {
      if (!keep.contains(index)) _retire(_slots.remove(index)!);
    }

    _ensureSlot(_currentIndex, warmup: false);
    for (final entry in _slots.entries) {
      if (entry.key == _currentIndex) {
        entry.value.activate();
      } else {
        entry.value.park();
      }
    }

    // Warm the next slide only once this one is actually playing. Two iframes
    // competing for the connection made the video the user is watching slower
    // to start, and hanging this off real playback rather than a fixed delay
    // means it adapts to the network instead of guessing at it.
    final current = _slots[_currentIndex];
    if (current == null) return;
    if (current.hasFrames) {
      _ensureSlot(_currentIndex + 1, warmup: true);
    } else {
      current.onFirstFrame = _warmNext;
    }
  }

  // The callback path — fires from the player's listener, outside any build.
  void _warmNext() {
    if (!mounted) return;
    final next = _currentIndex + 1;
    if (next >= _classes.length || _slots.containsKey(next)) return;
    setState(() => _ensureSlot(next, warmup: true));
  }

  // Extends the feed before the user reaches the end of it.
  Future<void> _loadMoreIfNeeded() async {
    if (_isLoadingMore || !_hasMore) return;
    if (_classes.length - _currentIndex > _kPrefetchWithin) return;
    _isLoadingMore = true;
    try {
      for (var attempt = 0; _hasMore && attempt < _kMaxPagesPerFetch; attempt++) {
        final result =
            await _repo.getDiscoveryShorts(page: _nextPage, limit: _kPageSize);
        if (!mounted) return;
        _hasMore = _nextPage < result.totalPages;
        _nextPage++;
        // Dedupe: the home hand-off overlaps discovery page 1, and a feed
        // sorted by created_at can shift an item across a page boundary while
        // the user is reading it.
        final seen = _classes.map((c) => c.id).toSet();
        final fresh = result.classes
            .where((c) => _extractVideoId(c) != null && !seen.contains(c.id))
            .toList();
        if (fresh.isEmpty) continue;
        setState(() {
          _classes = [..._classes, ...fresh];
          // The slide after the current one exists now where it did not a
          // moment ago — without this it would be the one cold start left in
          // an otherwise warmed feed.
          _syncSlots();
        });
        if (_feedIsDefault) {
          ShortsFeed.cache(_classes, nextPage: _nextPage, hasMore: _hasMore);
        }
        return;
      }
    } catch (_) {
      // Leave _hasMore alone — a dropped request should not permanently end
      // the feed. The next swipe retries.
    } finally {
      _isLoadingMore = false;
    }
  }

  void _ensureSlot(int index, {required bool warmup}) {
    if (index < 0 || index >= _classes.length) return;
    if (_slots.containsKey(index)) return;
    final videoId = _extractVideoId(_classes[index]);
    if (videoId == null) return;
    _slots[index] = _Slot(videoId: videoId, warmup: warmup);
  }

  // The PageView still has the retired slide's player in the tree for the rest
  // of this frame, so the WebView can't be torn out from under it here.
  void _retire(_Slot slot) {
    WidgetsBinding.instance.addPostFrameCallback((_) => slot.dispose());
  }

  void _resetSlots() {
    for (final slot in _slots.values) {
      _retire(slot);
    }
    _slots.clear();
  }

  // Same reason as [_retire]: the live PageView reads the old controller for
  // the rest of the frame, and disposing it inline threw "A PageController was
  // used after being disposed" when a feed swap arrived from onFocusGained.
  void _swapPageController(PageController? next) {
    final old = _pageController;
    _pageController = next;
    if (old != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
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

    // A feed handed over from home is a snapshot, so paging continues from
    // discovery page 1 and dedupes against what is already on screen —
    // otherwise entering Shorts from a home card capped you at that list.
    _adopt(classes, index, nextPage: 1, hasMore: true, isDefault: false);
  }

  // Swaps in a feed and starts the pool on [index].
  void _adopt(
    List<HomClass> classes,
    int index, {
    required int nextPage,
    required bool hasMore,
    required bool isDefault,
  }) {
    _nextPage = nextPage;
    _hasMore = hasMore;
    _feedIsDefault = isDefault;
    setState(() {
      _classes = classes;
      _currentIndex = index;
      _swapPageController(
          classes.isNotEmpty ? PageController(initialPage: index) : null);
      _resetSlots();
      if (classes.isNotEmpty) _syncSlots();
    });
    // A first page filtered down to one or two playable items leaves nothing
    // to swipe, so onPageChanged would never fire to top the feed up.
    _loadMoreIfNeeded();
  }

  Future<void> _loadDefaultFeed() async {
    if (_isLoadingDefault) return;
    // Straight to playback on a return visit — no spinner, no round trip.
    final cached = ShortsFeed.cached;
    if (cached != null && cached.isNotEmpty) {
      _adopt(
        cached,
        0,
        nextPage: ShortsFeed.cachedNextPage,
        hasMore: ShortsFeed.cachedHasMore,
        isDefault: true,
      );
      return;
    }
    setState(() => _isLoadingDefault = true);
    try {
      // Dedicated backend feed: already scoped to activities that have a video,
      // so a single request is enough — no client-side paging of the catalogue.
      final result =
          await _repo.getDiscoveryShorts(page: 1, limit: _kPageSize);
      if (!mounted) return;
      // Keep only what this player can actually play (YouTube ids). Vimeo/other
      // providers are filtered here until the player supports them.
      final classes =
          result.classes.where((c) => _extractVideoId(c) != null).toList();
      final hasMore = result.totalPages > 1;
      ShortsFeed.cache(classes, nextPage: 2, hasMore: hasMore);
      _adopt(classes, 0, nextPage: 2, hasMore: hasMore, isDefault: true);
    } catch (_) {
      // Swallow — empty state stays visible.
    } finally {
      if (mounted) setState(() => _isLoadingDefault = false);
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    for (final slot in _slots.values) {
      slot.dispose();
    }
    _slots.clear();
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
            _slots[_currentIndex]?.activate();
          }
        }
      },
      onFocusLost: () {
        for (final slot in _slots.values) {
          slot.suspend();
        }
      },
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
    // No YoutubePlayerBuilder here: it exists to support fullscreen, which this
    // surface never enters, and it pins the player under a GlobalKey — which is
    // why the one shared WebView used to be reparented from slide to slide on
    // every swipe, detaching and re-attaching the platform view mid-gesture.
    // Each slide owns its own player now.
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: _classes.length,
      // Load-bearing for the preload: PageView's cache extent is 0 by default,
      // so once a page settles it is the only one built — the warmed-up
      // neighbour's player would never mount and the whole pool would be
      // pointless. This gives the viewport one page of cache on each side.
      allowImplicitScrolling: true,
      onPageChanged: (i) {
        setState(() {
          _currentIndex = i;
          _syncSlots();
        });
        _loadMoreIfNeeded();
      },
      itemBuilder: (context, index) {
        return _ShortSlide(
          hc: _classes[index],
          isActive: index == _currentIndex,
          slot: _slots[index],
          bottomInset: bottomInset,
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
  const _CoverPlayer({required this.controller});

  final YoutubePlayerController controller;

  // Zoom past the video's own edges: YouTube's channel header (top) and the
  // "Shorts"/share badge (bottom) sit there and can't be removed from the
  // cross-origin iframe, so they get cropped off.
  static const double _zoom = 1.22;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        // Cover: never narrower than the slide, never shorter than it. The zoom
        // is folded into the size rather than applied with Transform.scale —
        // a transform over a hybrid-composition platform view forces the
        // WebView to be re-composited, and the package rebuilds this subtree
        // ten times a second off the iframe's VideoTime callback.
        final coverW = math.max(w, h * 9 / 16) * _zoom;
        final coverH = coverW * 16 / 9;

        return RepaintBoundary(
          child: ClipRect(
            child: OverflowBox(
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              child: SizedBox(
                width: coverW,
                height: coverH,
                child: YoutubePlayer(
                  controller: controller,
                  showVideoProgressIndicator: false,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A slide's base layer: the class photo, plus a spinner while the video
/// behind it is still starting up.
class _Poster extends StatelessWidget {
  const _Poster({required this.imageUrl, required this.showSpinner});

  final String? imageUrl;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (url != null)
          CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => Container(color: Colors.grey.shade900),
          )
        else
          Container(color: Colors.grey.shade900),
        if (showSpinner)
          const Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}

class _ShortSlide extends StatelessWidget {
  const _ShortSlide({
    required this.hc,
    required this.isActive,
    required this.slot,
    required this.bottomInset,
  });

  final HomClass hc;
  final bool isActive;
  // Null for slides outside the three-player window: they render the poster
  // only, with no WebView attached.
  final _Slot? slot;
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

    // A held "Lumi Start" packet replaces the figure outright — a buyer who has
    // already paid must not be quoted a price they will not be charged. This
    // overlay renders strings rather than widgets, so it says it in words where
    // the cards use the badge.
    final pass = watchPromoPass(context);
    if (pass != null &&
        pass.covers(
          activityId: hc.id,
          price: effectivePrice,
          isWholeCourse: hc.showsWholeCoursePrice,
        )) {
      return (
        label: 'promo_included_in'.tr(namedArgs: {'packet': pass.title}),
        discountedLabel: null,
      );
    }

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
    // Once per build. This reads AppCubit through context.watch, so calling it
    // again further down (as the price badge used to) doubled the work on
    // every emission.
    final price = _priceInfo(context);
    final slot = this.slot;

    return Stack(
      fit: StackFit.expand,
      children: [
        // The media is full-bleed: it runs edge to edge and under the floating
        // bottom bar. Insetting it by `bottomInset` (as this used to) letterboxed
        // the video — dead space at the top and a visible seam where the player
        // ended above the nav.
        //
        // The player is mounted for the warmed-up neighbour too, not just the
        // active slide — that is what lets its iframe finish initialising
        // before the user gets there.
        if (slot != null) _CoverPlayer(controller: slot.controller),
        // The poster sits *over* the player and only lifts once the video has
        // actually produced frames. Starting a video costs a round trip to
        // YouTube and the package draws nothing during it, so without this the
        // previous video's last frame just sat there looking frozen. The image
        // is already in CachedNetworkImage's cache from when this slide was the
        // neighbour, so the poster appears with no flicker.
        if (slot == null || !isActive)
          _Poster(imageUrl: imageUrl, showSpinner: false)
        else
          ValueListenableBuilder<_PlayerPhase>(
            valueListenable: slot.phase,
            builder: (context, phase, _) => phase == _PlayerPhase.playing
                ? const SizedBox.shrink()
                : _Poster(
                    imageUrl: imageUrl,
                    showSpinner: phase == _PlayerPhase.loading,
                  ),
          ),
        // Tap anywhere on the video to pause/resume (native controls are
        // hidden). Sits above the player but below the text/buttons so those
        // stay tappable.
        if (isActive && slot != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: bottomInset,
            child: _PlayPauseTapLayer(slot: slot),
          ),
        // Scrim. There is no UI at the top of this screen, so the heavy wash
        // that used to run down the first 40% was darkening the video for
        // nothing — all it has to do now is keep the status bar legible over a
        // bright frame, which takes a fraction of that. The bottom ramp is
        // eased over more stops so there is no visible edge where it starts.
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.16),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.28),
                    Colors.black.withOpacity(0.72),
                  ],
                  stops: const [0.0, 0.12, 0.46, 0.74, 1.0],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 16.w,
          right: 24.w,
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
              // The venue's face leads its own name, the way this format
              // usually introduces whoever posted the clip. It was floating on
              // the right before, unattached to the line it belongs to.
              if ((hc.branch?.title ?? '').isNotEmpty) ...[
                10.kh,
                Row(
                  children: [
                    _BranchAvatar(branch: hc.branch!),
                    8.kw,
                    Flexible(
                      child: Text(
                        hc.branch!.title!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              16.kh,
              _DetailsCta(hc: hc, price: price),
            ],
          ),
        ),
        // A hairline of progress along the bottom edge of the video.
        if (isActive && slot != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomInset,
            child: IgnorePointer(
              child: _ProgressBar(controller: slot.controller),
            ),
          ),
      ],
    );
  }
}

/// The one call to action, with the price folded into it.
///
/// The price used to be a solid white chip in the opposite corner — the
/// brightest thing on the screen, and not the thing you want tapped. Inside
/// the button it stops competing and starts being the reason to tap.
class _DetailsCta extends StatelessWidget {
  const _DetailsCta({required this.hc, required this.price});

  final HomClass hc;
  final ({String label, String? discountedLabel})? price;

  @override
  Widget build(BuildContext context) {
    final p = price;
    return GestureDetector(
      onTap: () => context.router.push(ClassDetailRoute(classModel: hc)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFA652C7), Color(0xFFFF7093)],
          ),
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFA652C7).withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        // A discounted "from ..." price in a long locale can outgrow the room
        // left beside the rail. Scaling down beats wrapping, ellipsising a
        // price, or overflowing.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'view_details'.tr(),
                maxLines: 1,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (p != null) ...[
                Container(
                  width: 1,
                  height: 13.h,
                  margin: EdgeInsets.symmetric(horizontal: 10.w),
                  color: Colors.white.withOpacity(0.4),
                ),
                if (p.discountedLabel != null) ...[
                  Text(
                    p.label,
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.72),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: Colors.white.withOpacity(0.72),
                    ),
                  ),
                  5.kw,
                  Text(
                    p.discountedLabel!,
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ] else
                  Text(
                    p.label,
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
              ],
              8.kw,
              Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 16.sp),
            ],
          ),
        ),
      ),
    );
  }
}

/// The venue's face, leading its name under the title — and a way into the
/// branch without going via the class page first.
class _BranchAvatar extends StatelessWidget {
  const _BranchAvatar({required this.branch});

  final HomBranch branch;

  @override
  Widget build(BuildContext context) {
    final image = branch.image;
    final url = (image != null && image.isNotEmpty)
        ? image
        : (branch.hasPhoto == true && branch.id != null
            ? PhotoService.getImageUrl(branch.id!)
            : null);
    final title = (branch.title ?? '').trim();
    final initial = title.isEmpty ? '?' : title.characters.first.toUpperCase();

    return GestureDetector(
      onTap: () => context.router.push(BranchDetailRoute(branch: branch)),
      child: Container(
        width: 28.w,
        height: 28.w,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.9), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: url != null
            ? CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _initialFallback(initial),
              )
            : _initialFallback(initial),
      ),
    );
  }

  Widget _initialFallback(String initial) => ColoredBox(
        color: const Color(0xFF3A2A4D),
        child: Center(
          child: Text(
            initial,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
}

/// Hairline progress along the bottom of the video.
///
/// Rebuilds off the iframe's 10Hz position callback, so it is kept to its own
/// repaint layer and nothing else depends on it.
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.controller});

  final YoutubePlayerController controller;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final total = controller.metadata.duration.inMilliseconds;
          final progress = total <= 0
              ? 0.0
              : (controller.value.position.inMilliseconds / total)
                  .clamp(0.0, 1.0);
          return SizedBox(
            height: 2.5,
            width: double.infinity,
            child: ColoredBox(
              color: Colors.white.withOpacity(0.16),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: ColoredBox(color: Colors.white.withOpacity(0.85)),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Transparent gesture layer over the video: tap anywhere to pause or resume.
//
// It draws nothing on purpose. YouTube's own player already flashes a
// play/pause indicator in the middle of the frame and we cannot suppress it
// from outside a cross-origin iframe, so the glyph this used to paint landed
// directly on top of it — two overlapping indicators for one tap.
class _PlayPauseTapLayer extends StatelessWidget {
  const _PlayPauseTapLayer({required this.slot});

  final _Slot slot;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: slot.toggle,
      child: const SizedBox.expand(),
    );
  }
}
