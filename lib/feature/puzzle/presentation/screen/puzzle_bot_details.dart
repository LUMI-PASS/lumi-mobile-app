import 'package:auto_route/auto_route.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

@RoutePage()
class PuzzleWithBotScreen extends StatefulWidget {
  final String url;
  const PuzzleWithBotScreen({required this.url, super.key});

  @override
  PuzzleWithBotScreenState createState() => PuzzleWithBotScreenState();
}

class PuzzleWithBotScreenState extends State<PuzzleWithBotScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChessColors.greyG20,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: ChessColors.greyG20,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: GestureDetector(
            onTap: context.router.pop,
            child: ChessUiKitAssets.icons.general.arrowNarrowLeft.svg(
              height: 24,
              width: 24,
            ),
          ),
        ),
        title: const Text("Shaxmat O'yini"),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
