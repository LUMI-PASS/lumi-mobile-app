import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// YouTube's own still for a clip — the tile's poster.
///
/// `hqdefault` and not `maxresdefault`: the latter 404s on plenty of uploads,
/// and the tile is about 100 logical pixels wide, so the bigger file would buy
/// nothing.
String _youtubeThumb(String id) => 'https://i.ytimg.com/vi/$id/hqdefault.jpg';

/// The centre's "how to find us" clip, as a narrow tile pinned beside the map
/// strip on branch detail. Tapping it plays the clip full-screen.
///
/// Next to the map and not under it on purpose: the map says *where* the centre
/// is, the clip says *how you walk in* — which door off the courtyard, which
/// floor, which of the three identical entrances. A parent standing outside the
/// building needs the second one, and it has to be in the same glance as the
/// first or it will not be found.
///
/// Renders nothing without a link. Any link is accepted: a YouTube id gets the
/// native player, everything else (Vimeo, a direct file, a centre's own page)
/// falls through to a WebView, which plays all three.
class RouteVideoTile extends StatelessWidget {
  const RouteVideoTile({
    super.key,
    required this.url,
    this.height,
    this.width,
  });

  final String? url;

  /// Matches the map strip it stands next to.
  final double? height;
  final double? width;

  /// Whether a branch's `video_url` is worth drawing a tile for.
  static bool canPlay(String? url) => url != null && url.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final link = url?.trim();
    if (link == null || link.isEmpty) return const SizedBox.shrink();

    final videoId = YoutubePlayer.convertUrlToId(link);
    final label = 'branch_route_video'.tr();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _RouteVideoPage(url: link, videoId: videoId),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: SizedBox(
          height: height ?? 140.h,
          width: width ?? 104.w,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (videoId != null && videoId.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: _youtubeThumb(videoId),
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      ColoredBox(color: context.colors.control),
                  errorWidget: (_, __, ___) => const _BrandPoster(),
                )
              else
                // No provider still to lean on (Vimeo needs a request of its
                // own, a raw file has none) — the brand gradient keeps the tile
                // from reading as a failed image.
                const _BrandPoster(),

              // Dark towards the bottom: the label sits on the poster, and a
              // still can be any colour underneath it.
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x1A000000), Color(0xBF000000)],
                  ),
                ),
              ),

              // Sits a little above centre so it does not collide with the
              // two-line label.
              Align(
                alignment: const Alignment(0, -0.22),
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xE6FFFFFF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    size: 24.w,
                    color: AppColors.brandPurple,
                  ),
                ),
              ),

              Positioned(
                left: 8.w,
                right: 8.w,
                bottom: 8.h,
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  // White, not a role colour: it sits on the scrim over a
                  // photo, which is the same in both themes.
                  style: AppText.semibold12.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandPoster extends StatelessWidget {
  const _BrandPoster();

  @override
  Widget build(BuildContext context) => const DecoratedBox(
        decoration: BoxDecoration(gradient: AppGradients.brand),
      );
}

/// The clip, full-screen on black.
///
/// The app is portrait-locked (see `main.dart`), which is the wrong shape for a
/// landscape clip — so this page lifts the lock while it is open and puts it
/// back on the way out. Nothing else in the app may rotate.
class _RouteVideoPage extends StatefulWidget {
  const _RouteVideoPage({required this.url, required this.videoId});

  final String url;

  /// Non-null when the link is a YouTube one, which gets the native player
  /// instead of the WebView.
  final String? videoId;

  @override
  State<_RouteVideoPage> createState() => _RouteVideoPageState();
}

class _RouteVideoPageState extends State<_RouteVideoPage> {
  YoutubePlayerController? _yt;
  WebViewController? _web;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);

    final id = widget.videoId;
    if (id != null && id.isNotEmpty) {
      _yt = YoutubePlayerController(
        initialVideoId: id,
        // Opened by a deliberate tap, so it plays at once and with sound —
        // half of a "how to get here" clip is the narration. Controls stay on:
        // this is a player someone chose to open, not a feed slide.
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: false,
        ),
      );
    } else {
      // `tryParse`, because this string came from an admin typing into a form —
      // a malformed one must leave a black page with a close button, not throw
      // out of initState.
      final uri = Uri.tryParse(widget.url);
      if (uri != null && uri.hasScheme) {
        _web = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.black)
          ..loadRequest(uri);
      }
    }
  }

  @override
  void dispose() {
    _yt?.dispose();
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Widget _closeButton() => Positioned(
        top: 8.h,
        right: 8.w,
        child: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 40.w,
              height: 40.w,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0x33FFFFFF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                size: 22.w,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final yt = _yt;
    final web = _web;

    if (yt != null) {
      // The builder, not a bare `YoutubePlayer`: it is what makes the player's
      // own full-screen toggle rotate and restore instead of leaving the page
      // in a half-rotated state.
      return YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: yt,
          showVideoProgressIndicator: true,
          progressIndicatorColor: AppColors.brandPurple,
        ),
        builder: (context, player) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(child: player),
              _closeButton(),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (web != null)
            Positioned.fill(child: WebViewWidget(controller: web)),
          _closeButton(),
        ],
      ),
    );
  }
}
