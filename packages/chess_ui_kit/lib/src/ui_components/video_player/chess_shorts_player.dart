import 'dart:async';

import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ChessShortsPlayer extends StatefulWidget {
  final String videoUrl;
  final String thumbnailUrl;
  final String title;
  final String description;
  final VoidCallback onBackTap;
  final String baseUrl;

  const ChessShortsPlayer({
    super.key,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.title,
    required this.description,
    required this.onBackTap,
    required this.baseUrl,
  });

  @override
  State<ChessShortsPlayer> createState() => _ChessShortsPlayerState();
}

class _ChessShortsPlayerState extends State<ChessShortsPlayer> {
  late YoutubePlayerController _controller;
  Timer? _overlayTimer;
  bool _isOverlayVisible = true;

  // Variables to track video position and duration
  Duration _currentPosition = Duration.zero;
  Duration _videoDuration = Duration.zero;

  @override
  void initState() {
    super.initState();

    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    if (videoId == null) {
      // Handle invalid URL
      throw ArgumentError('Invalid YouTube URL');
    }

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        loop: true,
        mute: false,
        controlsVisibleAtStart: false,
        hideControls: true, // Hide default controls to implement custom ones
        disableDragSeek: true, // Disable seeking via dragging
        isLive: false,
        forceHD: true,
      ),
    )..addListener(_playerListener);
  }

  void _playerListener() {
    if (!mounted) return;

    final position = _controller.value.position;
    final duration = _controller.metadata.duration;

    setState(() {
      _currentPosition = position;
      _videoDuration = duration;
    });

    // Handle looping manually if not already looping
    if (_controller.value.playerState == PlayerState.ended &&
        _videoDuration > Duration.zero) {
      _controller.seekTo(Duration.zero);
      _controller.play();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_playerListener);
    _controller.dispose();
    _overlayTimer?.cancel();
    super.dispose();
  }

  void _toggleOverlay() {
    setState(() {
      _isOverlayVisible = true;
    });
    _overlayTimer?.cancel();
    _overlayTimer = Timer(const Duration(seconds: 2), () {
      setState(() {
        _isOverlayVisible = false;
      });
    });
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          _toggleOverlay();
          _togglePlayPause();
        },
        child: Stack(
          children: [
            // Youtube Player occupies the full screen
            YoutubePlayerBuilder(
              player: YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: false, // We'll create a custom one
                progressIndicatorColor: ChessColors.errorDefault,
                onReady: () {
                  // Player is ready
                },
                onEnded: (data) {
                  _controller.seekTo(Duration.zero);
                  _controller.play(); // Loop the video
                },
                aspectRatio: MediaQuery.of(context).size.aspectRatio > 1
                    ? MediaQuery.of(context).size.aspectRatio
                    : 16 / 9,
                bottomActions: [], // Remove default bottom actions
                topActions: [], // Remove default top actions
              ),
              builder: (context, player) {
                return SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: player,
                );
              },
            ),
            // Overlay Controls
            if (_isOverlayVisible)
              Positioned.fill(
                child: Container(
                  color: Colors.black
                      .withOpacity(0.3), // Optional: semi-transparent overlay
                  padding: MediaQuery.of(context).padding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back Button
                      IconButton(
                        onPressed: widget.onBackTap,
                        icon: ChessUiKitAssets.icons.general.arrowLeft.svg(
                          colorFilter: const ColorFilter.mode(
                            ChessColors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      // Spacer
                      Expanded(
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              _togglePlayPause();
                              _toggleOverlay();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ChessColors.white.withOpacity(0.2),
                              ),
                              child: Icon(
                                _controller.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: ChessColors.white,
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Video Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          widget.title,
                          style: context.textTheme.headlineBold.copyWith(
                            color: ChessColors.white,
                          ),
                        ),
                      ),
                      // Video Description
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Html(
                          data: widget.description,
                          style: {
                            "body": Style(
                              color: ChessColors
                                  .white, // Change this to your desired color
                              // You can also set other properties like font size, font weight, etc.
                            ),
                            "a": Style(
                              color: ChessColors
                                  .white, // Change this to your desired color
                              // You can also set other properties like font size, font weight, etc.
                            ),
                            // Add more styles for other HTML tags if needed
                          },
                          onLinkTap: (url, _, __) => ChessUrlLauncher.launch(
                            url: url,
                            onError: (error) {
                              CornerCaseBottomSheet.show(
                                context,
                                type: CornerCaseType.error,
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      // Custom Progress Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: LinearProgressIndicator(
                          color: ChessColors.errorDefault,
                          backgroundColor: ChessColors.white.withOpacity(0.3),
                          value: _videoDuration.inSeconds > 0
                              ? _currentPosition.inSeconds /
                                  _videoDuration.inSeconds
                              : 0.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            // Video Thumbnail while loading
            if (!_controller.value.isReady)
              Positioned.fill(
                child: Image.network(
                  widget.thumbnailUrl.formatUrl(widget.baseUrl),
                  fit: BoxFit.cover,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
