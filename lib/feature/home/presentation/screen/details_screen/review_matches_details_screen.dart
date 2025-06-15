import 'package:auto_route/auto_route.dart';
import 'package:founders_academy/di/get_it.dart';
import 'package:founders_academy/feature/home/data/model/review_matches/review_matches_data.dart';
import 'package:founders_academy/feature/home/presentation/cubit/review_match_cubit/review_match_cubit.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';

@RoutePage()
class ReviewMatchDetailsScreen extends StatelessWidget {
  final String id;

  const ReviewMatchDetailsScreen({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ReviewMatchCubit>()..init(id),
      child: BlocBuilder<ReviewMatchCubit, ReviewMatchState>(
        builder: (context, state) {
          return ItemsListScreen(
            title: state is ReviewMatchLoadedState
                ? state.reviewMatch.title
                : "Yuklanmoqda...",
            body: switch (state) {
              ReviewMatchLoadingState() =>
                const ChessCircularProgressIndicator(),
              ReviewMatchLoadedState() => _BodyContent(
                  reviewMatch: state.reviewMatch,
                ),
              ReviewMatchErrorState() => const SizedBox.expand(),
            },
          );
        },
      ),
    );
  }
}

class _BodyContent extends StatefulWidget {
  final ReviewMatchData reviewMatch;

  const _BodyContent({
    required this.reviewMatch,
  });

  @override
  State<_BodyContent> createState() => _BodyContentState();
}

class _BodyContentState extends State<_BodyContent> {
  bool _isFullScreen = false;

  @override
  void dispose() {
    if (_isFullScreen) {
      _exitFullScreenMode();
    }
    super.dispose();
  }

  void _toggleFullScreen(bool isFullScreen) {
    setState(() {
      _isFullScreen = isFullScreen;
      if (_isFullScreen) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        _exitFullScreenMode();
      }
    });
  }

  void _exitFullScreenMode() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    setState(() {
      _isFullScreen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Render content based on full-screen state
    return _isFullScreen
        ? _buildFullScreenVideoPlayer()
        : _buildNormalScreenContent();
  }

  Widget _buildFullScreenVideoPlayer() {
    // Render only the video player in full-screen mode
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: ChessYoutubePlayer.lesson(
            key: ChessYoutubePlayer.globalKey,
            videoUrl: widget.reviewMatch.youtubeLink,
            onFullScreenToggle: _toggleFullScreen,
          ),
        ),
      ),
    );
  }

  Widget _buildNormalScreenContent() {
    // Render normal content when not in full-screen mode
    return Scaffold(
      appBar: _buildAppBar(context), // Show AppBar only in normal mode
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  ChessYoutubePlayer.lesson(
                    key: ChessYoutubePlayer.globalKey,
                    videoUrl: widget.reviewMatch.youtubeLink,
                    onFullScreenToggle: _toggleFullScreen,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    child: Html(
                      data: widget.reviewMatch.description,
                      style: context.textTheme.htmlStyle.map(
                        (key, value) =>
                            MapEntry(key, Style.fromTextStyle(value)),
                      ),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    // AppBar for normal mode
    return AppBar(
      scrolledUnderElevation: 0.0,
      automaticallyImplyLeading: false,
      leading: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: context.router.pop,
        child: ChessUiKitAssets.icons.general.arrowNarrowLeft.svg(
          height: 24,
          width: 24,
          fit: BoxFit.none,
          color: ChessColors.white,
        ),
      ),
      centerTitle: true,
      title: Text(
        widget.reviewMatch.title,
        style: context.textTheme.bodyMedium.copyWith(
          color: ChessColors.white,
        ),
      ),
    );
  }
}

class ItemsListScreen extends StatelessWidget {
  final String title;
  final Widget body;

  const ItemsListScreen({
    required this.title,
    required this.body,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
    );
  }
}
