import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/utils/catalog_revision.dart';
import 'package:lumi_pass/common/utils/user_location.dart';
import 'package:lumi_pass/common/widget/pill_filter_chip.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/api_model/interest_topic/interest_topic.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_class_card.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/search_widgets.dart';

/// "See all" for home's "Based on your interests" row.
///
/// The same matching the row is dealt from — the family's topics, each card
/// checked against the child it is for — without the row's cap of ten, paged
/// as you scroll. A chip per topic narrows it to that topic; "All" is the
/// row's own order.
///
/// Not the search screen: the matching goes by the words in an activity's
/// name and by each child's age and gender, none of which a search filter can
/// express, so search would only ever be close to what the row showed.
@RoutePage()
class InterestsGridPage extends StatefulWidget {
  const InterestsGridPage({super.key, required this.title});

  final String title;

  @override
  State<InterestsGridPage> createState() => _InterestsGridPageState();
}

class _InterestsGridPageState extends State<InterestsGridPage> {
  static const int _limit = 10;

  final _scrollController = ScrollController();
  final List<HomClass> _classes = [];

  /// Kept from the first page: the server sends the same list on every page,
  /// and a chip row that rebuilt itself mid-scroll would jump.
  List<InterestTopic> _topics = const [];

  /// Null is "All".
  String? _topicId;

  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  /// Bumped on every reset, so a page that lands after the chip changed is
  /// dropped instead of appended to a list it does not belong to.
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // A course card is priced per viewer — see [catalogRevision].
    catalogRevision.addListener(_restart);
    _loadMore();
  }

  @override
  void dispose() {
    catalogRevision.removeListener(_restart);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300.h) {
      _loadMore();
    }
  }

  void _selectTopic(String? id) {
    if (id == _topicId) return;
    _topicId = id;
    _restart();
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  void _restart() {
    if (!mounted) return;
    _requestId++;
    setState(() {
      _classes.clear();
      _page = 1;
      _hasMore = true;
      _isLoading = false;
    });
    _loadMore();
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    final requestId = _requestId;
    final page = _page;
    setState(() => _isLoading = true);

    // Measured from where home measured the row, so the two agree on order.
    final here = currentUserLocation.value;
    try {
      final result = await getIt<HomeRepository>().getForChildren(
        page: page,
        limit: _limit,
        topicId: _topicId,
        lat: here?.lat,
        lng: here?.lng,
      );
      if (!mounted || requestId != _requestId) return;

      setState(() {
        if (_topics.isEmpty) _topics = result.topics;
        final seen = _classes.map((c) => c.id).toSet();
        _classes.addAll(result.classes.where((c) => !seen.contains(c.id)));
        _page = page + 1;
        _hasMore = result.classes.isNotEmpty && _page <= result.totalPages;
        _isLoading = false;
      });
      _fillViewport();
    } catch (_) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _isLoading = false;
        _hasMore = false;
      });
    }
  }

  /// A short page leaves nothing to scroll, and [_onScroll] only fires on a
  /// real scroll — keep pulling until the grid overflows.
  void _fillViewport() {
    if (!_hasMore) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      if (_scrollController.position.maxScrollExtent <= 0) _loadMore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final showEmpty = _classes.isEmpty && !_isLoading;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SearchTopBar(
              title: widget.title,
              onBack: () => context.router.maybePop(),
            ),
            12.verticalSpace,
            // One topic needs no chips: "All" and it would be the same list.
            if (_topics.length > 1) ...[
              SizedBox(
                height: 30.h,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  children: [
                    PillFilterChip(
                      label: 'filter_all'.tr(),
                      selected: _topicId == null,
                      onTap: () => _selectTopic(null),
                    ),
                    for (final topic in _topics) ...[
                      8.horizontalSpace,
                      PillFilterChip(
                        label: [
                          if (topic.emoji != null) topic.emoji!,
                          topic.name,
                        ].join(' '),
                        selected: _topicId == topic.id,
                        onTap: () => _selectTopic(topic.id),
                      ),
                    ],
                  ],
                ),
              ),
              12.verticalSpace,
            ],
            Expanded(
              child: showEmpty
                  ? const SearchEmptyView()
                  : GridView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 20.h,
                        // image + gap + info, matching the home row's card.
                        mainAxisExtent: 126.h + 14.h + 118.h,
                      ),
                      itemCount: _classes.length + (_isLoading ? 2 : 0),
                      itemBuilder: (context, index) {
                        if (index >= _classes.length) {
                          return DecoratedBox(
                            decoration: BoxDecoration(
                              color: c.surface,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          );
                        }
                        final item = _classes[index];
                        return HomeCourseCard(
                          key: ValueKey(item.id ?? index),
                          homClass: item,
                          width: double.infinity,
                          margin: EdgeInsets.zero,
                          showDistance: false,
                          // As on home: a course is priced on its own page.
                          showPrice: !(item.isCourse ?? false),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
