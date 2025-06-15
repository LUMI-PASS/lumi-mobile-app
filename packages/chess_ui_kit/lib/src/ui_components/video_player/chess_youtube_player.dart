import 'package:flutter/widgets.dart';
import 'package:pod_player/pod_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

typedef ChessVideoController = PodPlayerController;

class ChessYoutubePlayer extends StatefulWidget {
  final String videoUrl;
  final bool? completed;
  final void Function()? onCompleted;
  final void Function(bool isFullScreen)? onFullScreenToggle;

  const ChessYoutubePlayer.lesson({
    super.key,
    required this.videoUrl,
    this.onCompleted,
    this.completed = false,
    this.onFullScreenToggle,
  });

  static final globalKey = GlobalKey<_ChessYoutubePlayerState>();

  static void pause() {
    final state = globalKey.currentState;
    if (state != null) {
      state._pause();
    } else {
      debugPrint("ChessVideoPlayer state is null, cannot pause");
    }
  }

  @override
  State<ChessYoutubePlayer> createState() => _ChessYoutubePlayerState();
}

class _ChessYoutubePlayerState extends State<ChessYoutubePlayer> {
  late YoutubePlayerController _controller;
  bool _completionNotified = false;

  @override
  void initState() {
    super.initState();

    // Initialize the controller safely
    _initializeController();
  }

  void _initializeController() {
    // Extract the video ID from the URL
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl) ?? '';
    // Initialize the controller only if the video ID is not empty
    if (videoId.isNotEmpty) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          controlsVisibleAtStart: true,
          mute: false,
          enableCaption: true,
        ),
      )..addListener(_videoListener);
      _controller.addListener(_fullscreenListener);
    }
  }

  void _videoListener() {
    // Additional listener logic can go here
  }

  void _fullscreenListener() {
    // Check if the controller is initialized before using it
    if (_controller.value.isFullScreen) {
      widget.onFullScreenToggle?.call(true);
    } else {
      widget.onFullScreenToggle?.call(false);
    }
  }

  void _pause() {
    if (_controller.value.isReady) {
      _controller.pause();
    }
  }

  @override
  void dispose() {
    // Ensure listeners are removed to prevent memory leaks
    _controller.removeListener(_videoListener);
    _controller.removeListener(_fullscreenListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        onReady: () {
          debugPrint("YouTube Player is ready.");
        },
        onEnded: (metadata) {
          if (!_completionNotified && widget.onCompleted != null) {
            setState(() => _completionNotified = true);
            widget.onCompleted?.call();
          }
        },
      ),
      builder: (context, player) {
        return player;
      },
    );
  }
}
