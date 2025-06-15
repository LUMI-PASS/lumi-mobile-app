import 'package:auto_route/auto_route.dart';
import 'package:founders_academy/di/get_it.dart';
import 'package:founders_academy/feature/base_url/app_base_url_cubit.dart';
import 'package:founders_academy/feature/base_url/app_base_url_state.dart';
import 'package:founders_academy/feature/home/data/model/book/book_data.dart';
import 'package:founders_academy/feature/home/presentation/cubit/book_cubit/book_cubit.dart';
import 'package:founders_academy/routing/app_router.gr.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';

@RoutePage()
class BookDetailsScreen extends StatelessWidget {
  final String id;
  const BookDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<BookCubit>()..init(id),
      child: BlocBuilder<BookCubit, BookState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.only(left: 24),
                child: GestureDetector(
                  onTap: context.router.pop,
                  child: ChessUiKitAssets.icons.general.arrowNarrowLeft.svg(
                    height: 24,
                    width: 24,
                    color: ChessColors.white
                  ),
                ),
              ),
            ),
            body: switch (state) {
              BookLoadingState() => const ChessCircularProgressIndicator(),
              BookErrorState() => const SizedBox.expand(),
              BookLoadedState() => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ChessColors.greyG800,
                        ChessColors.greyG900,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.2, .6],
                    ),
                  ),
                  child: _Body(state.book),
                )
            },
          );
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final BookData book;
  const _Body(this.book);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              _HeaderContent(book.image),
              const SizedBox(height: 16),
              _BodyContent(book: book)
            ],
          ),
        ),
        _BookButtons(book: book),
      ],
    );
  }
}

class _BodyContent extends StatelessWidget {
  final BookData book;
  const _BodyContent({required this.book});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            book.name,
            style: context.textTheme.title3Bold,
          ),
          const SizedBox(height: 8),
          Text(
            "Mualliflar: ${book.author}",
            style: context.textTheme.footnoteRegular
                .copyWith(color: ChessColors.greyG200),
          ),
          const SizedBox(height: 16),
          Html(
            data: book.description,
            style: context.textTheme.htmlStyle.map(
              (key, value) => MapEntry(key, Style.fromTextStyle(value)),
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
        ],
      ),
    );
  }
}

class _BookButtons extends StatelessWidget {
  final BookData book;
  const _BookButtons({required this.book});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBaseUrlCubit, AppBaseUrlState>(
      builder: (context, state) {
        final baseUrl = state.baseUrl;
        return Padding(
          padding: const EdgeInsets.all(16.0).copyWith(bottom: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ChessButton.primary(
                label: "Kitob ni o'qish",
                onPressed: book.downloadData.url.isNotEmpty
                    ? () {
                        context.router.push(
                          BookPdfRoute(
                            bookName: book.name,
                            bookUrl: book.downloadData.url.formatUrl(baseUrl),
                          ),
                        );
                      }
                    : null,
              ),
              // const SizedBox(height: 16),
              // ChessButton.secondary(
              //   label: "Mutolaa ilovasida o’qish",
              //   onPressed: () {
              //     showModalBottomSheet(
              //       context: context,
              //       useRootNavigator: true,
              //       builder: (_) => const ChessComingSoonBottomSheet(),
              //     );
              //   },
              // ),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderContent extends StatelessWidget {
  final String imageUrl;
  const _HeaderContent(this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final contentHeight = MediaQuery.sizeOf(context).height * .36;
    return BlocBuilder<AppBaseUrlCubit, AppBaseUrlState>(
      builder: (context, state) {
        final baseUrl = state.baseUrl;

        return SizedBox(
          width: MediaQuery.sizeOf(context).width,
          height: contentHeight,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                top: 0,
                child: BackgroundWaveClipper.buildWave(
                  context,
                  height: contentHeight - 36,
                ),
              ),
              ClipRRect(
                borderRadius: ChessRadius.radiusSm,
                child: ChessNetworkImage(
                  imageUrl: imageUrl,
                  width: 214,
                  height: 307,
                  fit: BoxFit.cover,
                  baseUrl: baseUrl,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class BackgroundWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double cornerRadius = 40;
    final Path path = Path();

    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(0, size.height, cornerRadius, size.height);
    path.quadraticBezierTo(60, size.height, 60, size.height - 2);
    path.quadraticBezierTo(
      size.width - 45,
      size.height * 0.80,
      size.width - 40,
      size.height * 0.80,
    );
    path.quadraticBezierTo(
      size.width - 20,
      size.height * 0.80,
      size.width,
      size.height * 0.70,
    );
    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(BackgroundWaveClipper oldClipper) => oldClipper != this;

  static Widget buildWave(BuildContext context, {required double height}) =>
      ClipPath(
        clipper: BackgroundWaveClipper(),
        child: Container(
          height: height,
          width: MediaQuery.sizeOf(context).width,
          color: ChessColors.primaryDefault,
        ),
      );
}
