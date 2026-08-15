import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:vimeo_video_player/vimeo_video_player.dart';

/// A Vimeo link split into the parts the player needs, per
/// [VimeoShortPlayer.parseLink].
typedef VimeoLink = ({String id, String? privacyHash});

/// Drives a [VimeoShortPlayer] from outside the widget.
///
/// Vimeo has no Dart-side player: the video runs in a WebView inside a
/// cross-origin iframe. So commands go out as JavaScript against the `player`
/// object the plugin's page declares, and playback state comes back through
/// the plugin's play/pause events. Being a [ChangeNotifier] lets the slide's
/// tap layer rebuild off [isPlaying] the same way it does for YouTube.
///
/// One controller is owned by the Shorts page and reused across slides —
/// only ever one Vimeo player is mounted at a time.
class VimeoShortController extends ChangeNotifier {
  InAppWebViewController? _webView;
  bool _isPlaying = false;
  bool _disposed = false;

  /// True while the video is playing. Only meaningful once a player has
  /// attached; false before that and after it unmounts.
  bool get isPlaying => _isPlaying;

  void play() => _run('play');

  void pause() => _run('pause');

  void toggle() => _isPlaying ? pause() : play();

  void _run(String command) {
    final webView = _webView;
    if (webView == null) return;
    // `player` is the global the plugin's HTML declares for the iframe. The
    // fallback covers the window before that inline script has run.
    webView.evaluateJavascript(source: '''
      try {
        (typeof player !== 'undefined'
          ? player
          : new Vimeo.Player(document.getElementById('vimeoPlayer'))
        ).$command();
      } catch (e) {}
    ''');
  }

  void _attach(InAppWebViewController webView) {
    _webView = webView;
  }

  /// Detaches [webView], but only if it is still the attached one.
  ///
  /// Slides swap by mounting the incoming player and disposing the outgoing
  /// one, and Flutter gives no ordering guarantee between the two — an
  /// unconditional detach could wipe the connection the new slide just made.
  void _detach(InAppWebViewController webView) {
    if (!identical(_webView, webView)) return;
    _webView = null;
    _setPlaying(false);
  }

  void _setPlaying(bool playing) {
    if (_disposed || playing == _isPlaying) return;
    _isPlaying = playing;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _webView = null;
    super.dispose();
  }
}

/// A single Vimeo video rendered for the Shorts feed: no controls, no title,
/// no byline, no badge — just the frame, looping, autoplaying on mount.
///
/// Mounted only for the active slide, so "mounted" means "playing"; pausing
/// and resuming go through [controller].
class VimeoShortPlayer extends StatefulWidget {
  const VimeoShortPlayer({
    super.key,
    required this.videoId,
    required this.controller,
    this.privacyHash,
  });

  /// The numeric Vimeo id, as returned by [parseLink].
  final String videoId;

  /// Unlisted-video token, when the link carried one. See [parseLink].
  final String? privacyHash;

  final VimeoShortController controller;

  /// Splits a Vimeo link into the id and (for unlisted videos) the privacy
  /// hash, or returns null when [link] isn't one this player can open.
  ///
  /// The hash is not optional decoration: an unlisted video is only reachable
  /// with it, and Vimeo answers 404 for the bare id. It reaches us either as
  /// the path segment after the id (`vimeo.com/123/abc`, which is what the
  /// Vimeo share dialog copies) or as the `h` query parameter
  /// (`player.vimeo.com/video/123?h=abc`).
  ///
  /// Also accepts a bare numeric id and the plain `vimeo.com/123` form.
  static VimeoLink? parseLink(String? link) {
    final url = link?.trim() ?? '';
    if (url.isEmpty) return null;
    if (RegExp(r'^\d+$').hasMatch(url)) return (id: url, privacyHash: null);

    final match = RegExp(
      r'vimeo\.com/(?:video/)?(\d+)(?:/([0-9a-zA-Z]+))?',
      caseSensitive: false,
    ).firstMatch(url);
    if (match == null) return null;

    final hash = match.group(2) ?? Uri.tryParse(url)?.queryParameters['h'];
    return (
      id: match.group(1)!,
      privacyHash: (hash != null && hash.isNotEmpty) ? hash : null,
    );
  }

  @override
  State<VimeoShortPlayer> createState() => _VimeoShortPlayerState();
}

class _VimeoShortPlayerState extends State<VimeoShortPlayer> {
  InAppWebViewController? _webView;
  bool _isLoading = true;

  @override
  void dispose() {
    final webView = _webView;
    if (webView != null) widget.controller._detach(webView);
    super.dispose();
  }

  void _stopLoading() {
    if (mounted && _isLoading) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          VimeoVideoPlayer(
            videoId: widget.videoId,
            // Appended to the iframe URL as `&h=…`; an unlisted video won't
            // load without it.
            privacyHash: widget.privacyHash,
            isAutoPlay: true,
            // Matches the YouTube slides, which run with `loop: true`: a short
            // repeats until the user swipes on.
            isLooping: true,
            showControls: false,
            showByline: false,
            portrait: false,
            // The plugin inverts this one when building the iframe URL
            // (`badge=${!badge}`), so `true` is what actually hides the badge.
            badge: true,
            onInAppWebViewCreated: (controller) {
              _webView = controller;
              widget.controller._attach(controller);
            },
            onReady: _stopLoading,
            // Don't leave a spinner over a frame that will never arrive.
            onInAppWebViewReceivedError: (_, __, ___) => _stopLoading(),
            onPlay: () => widget.controller._setPlaying(true),
            onPause: () => widget.controller._setPlaying(false),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}
