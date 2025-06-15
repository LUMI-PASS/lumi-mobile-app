import 'dart:convert';

import 'package:chess_ui_kit/src/ui_components/progress_indicator/chess_circular_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ChessVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool? completed;
  final void Function()? onCompleted;

  const ChessVideoPlayer({
    super.key,
    required this.videoUrl,
    this.onCompleted,
  }) : completed = null;

  const ChessVideoPlayer.lesson({
    super.key,
    required this.videoUrl,
    this.onCompleted,
    this.completed = false,
  });

  static final globalKey = GlobalKey<_ChessVideoPlayerState>();

  static void pause() {
    final state = globalKey.currentState;
    if (state != null) {
      state._pause();
    } else {
      debugPrint("ChessVideoPlayer state is null, cannot pause");
    }
  }

  @override
  State<ChessVideoPlayer> createState() => _ChessVideoPlayerState();
}

class _ChessVideoPlayerState extends State<ChessVideoPlayer> {
  @override
  void initState() {
    super.initState();
  }

  void _pause() {
    debugPrint(
        "Pause functionality is not supported in the Vimeo WebView player.");
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      return VimeoPlayer(
        videoId: widget.videoUrl,
        onVideoCompleted:
            widget.onCompleted, // Pass the callback for video completion
      );
    });
  }
}

class VimeoPlayer extends StatefulWidget {
  const VimeoPlayer({
    super.key,
    required this.videoId,
    this.onVideoCompleted,
  });

  final String videoId;
  final void Function()? onVideoCompleted;

  @override
  State<VimeoPlayer> createState() => _VimeoPlayerState();
}

class _VimeoPlayerState extends State<VimeoPlayer> {
  bool _isLoaded = false;
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'VimeoVideoChannel', // JavaScriptChannel to communicate with Flutter
        onMessageReceived: (message) {
          if (message.message == 'videoEnded') {
            widget.onVideoCompleted
                ?.call(); // Call the callback when video ends
          }
        },
      )
      ..loadRequest(Uri.parse(_videoPage(widget.videoId)))
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) {
          setState(() {
            _isLoaded = true;
          });
        },
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_isLoaded)
          WebViewWidget(
            controller: _controller,
          ),
        if (!_isLoaded)
          const Center(
            child: ChessCircularProgressIndicator(),
          ),
      ],
    );
  }

  /// Web page containing iframe of the Vimeo video with video end detection
  String _videoPage(String videoId) {
    final html = '''
            <html lang="en">
              <head>
                <title>Vimeo Video Player</title> <!-- Added title element -->
                <style>
                  body {
                   background-color: white;
                   margin: 0px;
                   display: flex;
                   justify-content: center;
                   align-items: center;
                   height: 100vh;
                   }
                iframe {
                  width: 100%;
                  height: 100%;
                  border: none; /* CSS replacement for frameborder */
                }
                </style>
                <meta name="viewport" content="initial-scale=1.0, maximum-scale=1.0">
                <meta http-equiv="Content-Security-Policy" 
                content="default-src * gap:; script-src * 'unsafe-inline' 'unsafe-eval'; connect-src *; 
                img-src * data: blob: android-webview-video-poster:; style-src * 'unsafe-inline';">
             </head>
             <body>
                <iframe 
                id="vimeo_player"
                src="$videoId" 
                allow="fullscreen" allowfullscreen></iframe> <!-- Removed frameborder -->

                <script src="https://player.vimeo.com/api/player.js"></script>
                <script>
                  var iframe = document.getElementById('vimeo_player');
                  var player = new Vimeo.Player(iframe);

                  // Listen for the 'ended' event
                  player.on('ended', function() {
                    // Send message to Flutter when video ends
                    VimeoVideoChannel.postMessage('videoEnded');
                  });
                </script>
             </body>
            </html>
            ''';
    final String contentBase64 =
        base64Encode(const Utf8Encoder().convert(html));
    return 'data:text/html;base64,$contentBase64';
  }
}
