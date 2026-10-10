import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_shadows.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/service/saved_activity_store.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_class_card.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_icons.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/search_widgets.dart';

/// "Saqlanganlar" — the activities and centres the user hearted.
///
/// The shelf is the account's and lives on the server, so this screen loads
/// its cards from [SavedActivityStore] and can fail — hence the loading and
/// retry states. It is also the only place something saved can be un-saved in
/// bulk, hence the heart on every card — making the user open each detail page
/// to undo a tap they made by accident would be the long way round.
///
/// One grid, centres first and told apart by their tag — the arrangement the
/// search results use, so a saved centre looks here the way it looked where
/// it was found.
///
/// What is DRAWN is the loaded cards filtered by the store's live id sets, so
/// un-saving a card removes it from under the finger without a reload, and a
/// save made on a detail page opened from here fetches the shelf again.
@RoutePage()
class SavedActivitiesPage extends StatefulWidget {
  const SavedActivitiesPage({super.key});

  @override
  State<SavedActivitiesPage> createState() => _SavedActivitiesPageState();
}

class _SavedActivitiesPageState extends State<SavedActivitiesPage> {
  final _store = getIt<SavedActivityStore>();

  List<HomClass> _cards = const [];
  List<HomBranch> _centres = const [];
  bool _loading = true;
  bool _failed = false;

  /// Saved ids the last load came back WITHOUT — something its centre has
  /// since deleted or hidden. Remembered so their absence is not mistaken for
  /// "something new was saved" and answered with a reload every time.
  Set<String> _unlisted = const {};

  /// How long a card takes to shrink and fade once un-saved, and how long its
  /// neighbours take to slide into the gap. The slide is the longer of the
  /// two so the card is gone before anything arrives where it was.
  static const _leaveDuration = Duration(milliseconds: 240);
  static const _moveDuration = Duration(milliseconds: 360);

  /// Cards un-saved a moment ago and still on their way out, by entry key.
  final Set<String> _leaving = {};

  /// The grid slot each card was last laid out in, by entry key — where a
  /// leaving card stays while it fades.
  final Map<String, int> _slots = {};

  @override
  void initState() {
    super.initState();
    _store.changes.addListener(_onIdsChanged);
    _load();
  }

  @override
  void dispose() {
    _store.changes.removeListener(_onIdsChanged);
    super.dispose();
  }

  /// Every id on the shelf, of either kind. Activity and centre ids are both
  /// ObjectIds, so one set holds them without collision.
  Set<String> get _allIds =>
      {..._store.savedIds.value, ..._store.savedBranchIds.value};

  Set<String?> get _listedIds => {
        for (final card in _cards) card.id,
        for (final centre in _centres) centre.id,
      };

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final (cards, centres) =
          await (_store.load(), _store.loadBranches()).wait;
      if (!mounted) return;
      setState(() {
        _cards = cards;
        _centres = centres;
        _unlisted = _allIds.difference(_listedIds);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  /// An id this screen has no card for means something was saved elsewhere
  /// while it was open; an id going away needs nothing, the filter in [build]
  /// already dropped its card.
  void _onIdsChanged() {
    if (_loading) return;
    final known = {..._listedIds, ..._unlisted};
    if (_allIds.any((id) => !known.contains(id))) _load();
  }

  /// Un-saves a card with a goodbye instead of a cut.
  ///
  /// The request goes out on the tap — the animation never delays the save
  /// itself — but the card is held in [_leaving] while it shrinks and fades,
  /// and the cards after it slide up into the gap at the same time. If the
  /// server refuses, the store puts the id back and the card simply returns.
  void _unsave(_Entry entry) {
    if (_leaving.contains(entry.key)) return;
    HapticFeedback.selectionClick();
    setState(() => _leaving.add(entry.key));
    switch (entry) {
      case _CentreEntry(:final centre):
        _store.toggleBranch(centre);
      case _ActivityEntry(:final model):
        _store.toggle(model);
    }
    Future.delayed(_leaveDuration, () {
      if (!mounted) return;
      setState(() => _leaving.remove(entry.key));
    });
  }

  /// The grid, laid out by hand so its cards can MOVE.
  ///
  /// A `GridView` re-lays its children out in one frame: take a card away and
  /// every card after it teleports. Here each card is an [AnimatedPositioned]
  /// keyed by what it shows, so when the slot it belongs in changes it travels
  /// there. The geometry is the search grid's — two columns, an 8pt gutter,
  /// the same card height — only computed rather than delegated.
  ///
  /// Not lazy, unlike a `GridView`: every saved card is built. A shelf is a
  /// few dozen cards at most, and that is the price of the cards knowing where
  /// they were.
  Widget _buildGrid(List<_Entry> entries, double width) {
    final gutter = 8.w;
    final rowGap = 14.h;
    final cardWidth = (width - gutter) / 2;
    final cardHeight = _cardExtent.h;

    // A leaving card keeps the slot it had; everything else is numbered as
    // though it were already gone, which is what closes the gap.
    var next = 0;
    for (final entry in entries) {
      if (!_leaving.contains(entry.key)) _slots[entry.key] = next++;
    }
    final rows = (next / 2).ceil();

    return SizedBox(
      width: width,
      height: rows == 0 ? cardHeight : rows * cardHeight + (rows - 1) * rowGap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (final entry in entries)
            _slotted(
              entry,
              slot: _slots[entry.key] ?? 0,
              cardWidth: cardWidth,
              cardHeight: cardHeight,
              gutter: gutter,
              rowGap: rowGap,
            ),
        ],
      ),
    );
  }

  Widget _slotted(
    _Entry entry, {
    required int slot,
    required double cardWidth,
    required double cardHeight,
    required double gutter,
    required double rowGap,
  }) {
    final leaving = _leaving.contains(entry.key);
    return AnimatedPositioned(
      key: ValueKey(entry.key),
      duration: _moveDuration,
      curve: Curves.easeOutCubic,
      left: (slot % 2) * (cardWidth + gutter),
      top: (slot ~/ 2) * (cardHeight + rowGap),
      width: cardWidth,
      height: cardHeight,
      child: IgnorePointer(
        ignoring: leaving,
        child: AnimatedOpacity(
          opacity: leaving ? 0 : 1,
          duration: _leaveDuration,
          curve: Curves.easeOut,
          child: AnimatedScale(
            scale: leaving ? 0.85 : 1,
            duration: _leaveDuration,
            curve: Curves.easeOutCubic,
            child: _SavedCard(
              onUnsave: () => _unsave(entry),
              child: switch (entry) {
                _CentreEntry(:final centre) => SearchBranchCard(
                    branch: centre,
                    width: double.infinity,
                    tag: 'search_centre_tag'.tr(),
                  ),
                _ActivityEntry(:final model) => HomeCourseCard(
                    homClass: model,
                    width: double.infinity,
                    margin: EdgeInsets.zero,
                  ),
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: BaseAppBar(title: 'saved_title'.tr()),
      body: ListenableBuilder(
        listenable: _store.changes,
        builder: (context, _) {
          // A card being un-saved is off the store's list at once, but stays
          // in the grid for the moment it takes to leave — see [_unsave].
          final entries = <_Entry>[
            for (final centre in _centres)
              if (_store.containsBranch(centre.id) ||
                  _leaving.contains('centre-${centre.id}'))
                _Entry.centre(centre),
            for (final card in _cards)
              if (_store.contains(card.id) ||
                  _leaving.contains('activity-${card.id}'))
                _Entry.activity(card),
          ];
          if (entries.isEmpty) {
            // What to draw before the cards arrive is decided by the ids,
            // which are already on the device. None saved means the answer is
            // known — the empty state, at once, with no loader in front of it
            // to blink away. Some saved means cards ARE coming, so their
            // places are held by skeletons, one per saved thing, and the grid
            // fills in without the layout jumping.
            if (_store.count == 0) return const _SavedEmptyView();
            if (_loading) return _SavedSkeletonGrid(count: _store.count);
            if (_failed) return _SavedErrorView(onRetry: _load);
            // Saved, loaded, and nothing to list: everything saved has since
            // been taken down by its centre.
            return const _SavedEmptyView();
          }

          return RefreshIndicator(
            onRefresh: _load,
            child: SingleChildScrollView(
              padding: _gridPadding(context),
              physics: const AlwaysScrollableScrollPhysics(),
              child: LayoutBuilder(
                builder: (context, constraints) => _buildGrid(
                  entries,
                  constraints.maxWidth,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// One card on the shelf. Sealed, so the two kinds are switched on
/// exhaustively wherever the grid needs to tell them apart.
sealed class _Entry {
  const _Entry();

  factory _Entry.centre(HomBranch centre) = _CentreEntry;
  factory _Entry.activity(HomClass model) = _ActivityEntry;

  /// Stable across rebuilds and unique across both kinds — the card's
  /// identity for the animation.
  String get key;
}

class _CentreEntry extends _Entry {
  const _CentreEntry(this.centre);

  final HomBranch centre;

  @override
  String get key => 'centre-${centre.id}';
}

class _ActivityEntry extends _Entry {
  const _ActivityEntry(this.model);

  final HomClass model;

  @override
  String get key => 'activity-${model.id}';
}

/// Two columns on the page's 16pt margin with an 8pt gutter, and the card
/// height the search grid uses — this is the same shelf, filtered to what the
/// user kept. Spelled out the way `SearchView` spells it (artwork, gap, text
/// block) so the two stay the same height if the card changes.
const double _cardExtent = 126.0 + 14.0 + 118.0;

EdgeInsets _gridPadding(BuildContext context) => EdgeInsets.fromLTRB(
      16.w,
      12.h,
      16.w,
      MediaQuery.of(context).padding.bottom + 24.h,
    );

SliverGridDelegate _gridDelegate() => SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 8.w,
      mainAxisSpacing: 14.h,
      mainAxisExtent: _cardExtent.h,
    );

/// The shelf while its cards are on the way: one placeholder per saved
/// activity, in the grid the cards will land in. The same flat block the
/// search grid loads behind.
class _SavedSkeletonGrid extends StatelessWidget {
  const _SavedSkeletonGrid({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GridView.builder(
      padding: _gridPadding(context),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: _gridDelegate(),
      // More than a screenful of placeholders is nothing anyone sees.
      itemCount: count.clamp(1, 6),
      itemBuilder: (_, __) => DecoratedBox(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }
}

/// The shelf could not be fetched. Says so and offers the one useful thing.
class _SavedErrorView extends StatelessWidget {
  const _SavedErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'something_went_wrong'.tr(),
              textAlign: TextAlign.center,
              style: AppText.bold18.copyWith(color: c.textPrimary),
            ),
            12.verticalSpace,
            TextButton(
              onPressed: onRetry,
              child: Text(
                'retry'.tr(),
                style: AppText.semibold14.copyWith(color: c.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A result card with an un-save heart over its artwork.
///
/// A [Stack] rather than a new parameter on the cards: the heart belongs to
/// this screen, not to them, and every other shelf in the app draws the same
/// cards without one.
class _SavedCard extends StatelessWidget {
  const _SavedCard({required this.child, required this.onUnsave});

  final Widget child;
  final VoidCallback onUnsave;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: child),
        Positioned(
          top: 8.w,
          right: 8.w,
          // The app's own frosted control chip — the surface the back, share
          // and heart buttons on the detail pages are made of — a size down,
          // because here it sits on a card's artwork rather than a hero. The
          // heart is the one that page shows for something saved.
          //
          // The same toggle that heart makes. Here the card is always saved,
          // so it un-saves; a failure puts it back.
          child: FrostedCard(
            onTap: onUnsave,
            padding: EdgeInsets.all(6.w),
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: AppShadows.control,
            child: HomeIcon(
              Assets.icons.home.heart,
              size: 14,
              color: AppColors.error,
            ),
          ),
        ),
      ],
    );
  }
}

/// Nothing saved yet — says what the heart does rather than that the list is
/// empty, because the list being empty is not the useful half.
class _SavedEmptyView extends StatelessWidget {
  const _SavedEmptyView();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.images.mascot.mascotCategories.image(
              width: 140.w,
              height: 140.w,
              fit: BoxFit.contain,
            ),
            20.verticalSpace,
            Text(
              'saved_empty_title'.tr(),
              textAlign: TextAlign.center,
              style: AppText.bold18.copyWith(color: c.textPrimary),
            ),
            8.verticalSpace,
            Text(
              'saved_empty_desc'.tr(),
              textAlign: TextAlign.center,
              style: AppText.regular14.copyWith(color: c.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
