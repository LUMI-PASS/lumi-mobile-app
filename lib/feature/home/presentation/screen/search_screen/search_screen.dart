import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/di/get_it.dart';
import 'package:lumi_pass/feature/base_url/app_base_url_cubit.dart';
import 'package:lumi_pass/feature/home/data/model/afisha/afisha_data.dart';
import 'package:lumi_pass/feature/home/data/model/book/book_data.dart';
import 'package:lumi_pass/feature/home/data/model/grandmaster/grandmaster_data.dart';
import 'package:lumi_pass/feature/home/data/model/news/news_data.dart';
import 'package:lumi_pass/feature/home/data/model/review_matches/review_matches_data.dart';
import 'package:lumi_pass/feature/home/data/model/search_item/search_item.dart';
import 'package:lumi_pass/feature/home/data/model/search_list/search_list_data.dart';
import 'package:lumi_pass/feature/home/presentation/cubit/search_cubit/search_cubit.dart';
import 'package:lumi_pass/feature/home/presentation/widget/afisha_widget.dart';
import 'package:lumi_pass/feature/home/presentation/widget/book_widget.dart';
import 'package:lumi_pass/feature/home/presentation/widget/grandmaster_widget.dart';
import 'package:lumi_pass/feature/home/presentation/widget/news_widget.dart';
import 'package:lumi_pass/feature/home/presentation/widget/review_matches_widget.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchCountroller = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _showSearchHistory = true;

  @override
  void initState() {
    _searchListener();
    super.initState();
  }

  @override
  void dispose() {
    _searchCountroller.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _searchListener() {
    _searchCountroller.addListener(() {
      setState(() {
        if (_searchCountroller.text.isEmpty) {
          _showSearchHistory = true;
        } else {
          _showSearchHistory = false;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<SearchCubit>()..initSearchIsarDatabase(),
        ),
        BlocProvider(
          create: (context) => getIt<AppBaseUrlCubit>()..init(),
        ),
      ],
      child: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          return ColoredBox(
            color: ChessColors.greyG900,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16).copyWith(bottom: 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ChessTextField(
                          height: 48,
                          focusNode: _searchFocusNode,
                          onSubmitted: (query) {
                            if (query.isNotEmpty) {
                              context.read<SearchCubit>().addHistory(query);
                            }
                          },
                          controller: _searchCountroller,
                          onChanged: (query) {
                            if (query.length > 3) {
                              context.read<SearchCubit>().search(query);
                            }
                          },
                          showClearButton: true,
                          placeholder: "Qidiruv",
                          prefixIcon:
                              ChessUiKitAssets.icons.general.searchMd.svg(
                            fit: BoxFit.none,
                            colorFilter: const ColorFilter.mode(
                              ChessColors.greyG100,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IntrinsicWidth(
                        child: ChessButton.text(
                          onPressed: context.router.pop,
                          contentPadding: EdgeInsets.zero,
                          label: "Bekor qilish",
                          textStyle: context.textTheme.subheadlineSemibold,
                        ),
                      )
                    ],
                  ),
                ),
                if (state is SearchLoadingState)
                  const Expanded(child: ChessCircularProgressIndicator()),
                if (state is SearchLoadedState) ...[
                  const SizedBox(height: 16),
                  if (!_showSearchHistory)
                    _BodyContent(searchList: state.searchList),
                  if (_showSearchHistory)
                    _SearchHistoryList(
                      state: state,
                      onItemTap: (item) {
                        _searchCountroller.setText(item.title);
                        context.read<SearchCubit>().search(item.title);
                      },
                    ),
                ]
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BodyContent extends StatelessWidget {
  final SearchListData searchList;
  const _BodyContent({required this.searchList});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: searchList.isEmpty
          ? const _EmptyView()
          : ListView(
              children: [
                if (searchList.afisha.isNotEmpty) ...[
                  _AfishaData(afisha: searchList.afisha),
                ],
                if (searchList.books.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _BookData(books: searchList.books),
                ],
                if (searchList.grandmasters.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _GrandmasterData(grandmasters: searchList.grandmasters)
                ],
                if (searchList.news.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _NewsData(news: searchList.news)
                ],
                if (searchList.reviewMatches.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _ReviewMatchesData(reviewMatches: searchList.reviewMatches)
                ],
              ],
            ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return ChessResultScreen(
      image: ChessUiKitAssets.icons.general.file.svg(),
      title: "Natija topilmadi",
      subtitle: "Sizning so'rovingiz bo'yicha natija topilmadi",
    );
  }
}

class _AfishaData extends StatelessWidget {
  final List<AfishaData> afisha;
  const _AfishaData({required this.afisha});

  @override
  Widget build(BuildContext context) {
    return _SearchListItemBuilder(
      itemCount: afisha.length,
      title: "Afisha",
      itemBuilder: (context, index) => AfishaWidget(
        afishaData: afisha.elementAt(index),
        onTap: context.router.pop,
      ),
    );
  }
}

class _BookData extends StatelessWidget {
  final List<BookData> books;
  const _BookData({required this.books});

  @override
  Widget build(BuildContext context) {
    return _SearchListItemBuilder.horizontal(
      height: 218,
      itemCount: books.length,
      title: "Kitoblar",
      itemBuilder: (context, index) => EnhancedBookWidget(
        width: 108,
        book: books.elementAt(index),
        onTap: context.router.pop,
      ),
    );
  }
}

class _GrandmasterData extends StatelessWidget {
  final List<GrandmasterData> grandmasters;
  const _GrandmasterData({required this.grandmasters});

  @override
  Widget build(BuildContext context) {
    return _SearchListItemBuilder.horizontal(
      height: 200,
      itemCount: grandmasters.length,
      title: "Shorts",
      itemBuilder: (context, index) => GrandmasterWidget(
        grandmaster: grandmasters.elementAt(index),
        onTap: context.router.pop,
      ),
    );
  }
}

class _ReviewMatchesData extends StatelessWidget {
  final List<ReviewMatchData> reviewMatches;
  const _ReviewMatchesData({required this.reviewMatches});

  @override
  Widget build(BuildContext context) {
    return _SearchListItemBuilder.horizontal(
      height: 144,
      itemCount: reviewMatches.length,
      title: "Tahlillar",
      itemBuilder: (context, index) {
        final ReviewMatchData reviewMatch = reviewMatches.elementAt(index);
        return ReviewMatchWidget(
          reviewMatch: reviewMatch,
          onTap: context.router.pop,
        );
      },
    );
  }
}

class _NewsData extends StatelessWidget {
  final List<NewsData> news;
  const _NewsData({required this.news});

  @override
  Widget build(BuildContext context) {
    return _SearchListItemBuilder(
      itemCount: news.length,
      title: "Yangiliklar",
      itemBuilder: (context, index) => EnhancedNewsWidget(
        newsData: news.elementAt(index),
        onTap: context.router.pop,
      ),
    );
  }
}

class _SearchHistoryList extends StatelessWidget {
  final SearchState state;
  final Function(SearchItem) onItemTap;

  const _SearchHistoryList({
    required this.state,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final currentStata = state;
    if (currentStata is! SearchLoadedState) return Container();

    return Expanded(
      child: currentStata.searchHistory.isEmpty
          ? Container()
          : _SearchListItemBuilder(
              itemCount: currentStata.searchHistory.length,
              title: "Qidiruv tarixi",
              addSeparator: false,
              itemBuilder: (context, index) => ListTile(
                contentPadding: const EdgeInsets.only(left: 24, right: 8),
                onTap: () => onItemTap(currentStata.searchHistory[index]),
                title: Text(
                  currentStata.searchHistory.elementAt(index).title,
                  style: context.textTheme.calloutRegular,
                ),
                leading: ChessUiKitAssets.icons.general.searchMd.svg(
                  colorFilter: const ColorFilter.mode(
                    ChessColors.primaryDefault,
                    BlendMode.srcIn,
                  ),
                ),
                trailing: IconButton(
                  onPressed: () {
                    context.read<SearchCubit>().delete(
                          currentStata.searchHistory[index].id,
                        );
                  },
                  icon: ChessUiKitAssets.icons.general.xClose.svg(
                    fit: BoxFit.none,
                    colorFilter: const ColorFilter.mode(
                      ChessColors.greyG80,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class _SearchListItemBuilder extends StatelessWidget {
  final int itemCount;
  final String title;
  final Axis? scrollDirection;
  final double? height;
  final Widget Function(BuildContext, int) itemBuilder;
  final bool addSeparator;
  final EdgeInsets padding;
  final EdgeInsets contentPadding;

  const _SearchListItemBuilder({
    required this.itemCount,
    required this.itemBuilder,
    required this.title,
    this.addSeparator = true,
  })  : height = null,
        padding = const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection = Axis.vertical,
        contentPadding = EdgeInsets.zero;

  const _SearchListItemBuilder.horizontal({
    required this.itemCount,
    required this.itemBuilder,
    required this.title,
    required this.height,
  })  : addSeparator = true,
        padding = const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection = Axis.horizontal,
        contentPadding = const EdgeInsets.symmetric(horizontal: 24);

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      primary: false,
      children: [
        Padding(
          padding: padding,
          child: Text(title, style: context.textTheme.bodyMedium),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: height,
          child: ListView.separated(
            primary: false,
            padding: contentPadding,
            scrollDirection: scrollDirection ?? Axis.horizontal,
            itemCount: itemCount,
            shrinkWrap: true,
            itemBuilder: itemBuilder,
            separatorBuilder: (_, __) => !addSeparator
                ? Container()
                : scrollDirection == Axis.vertical
                    ? const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                        child: Divider(color: ChessColors.greyG30),
                      )
                    : const SizedBox(width: 8),
          ),
        ),
      ],
    );
  }
}
