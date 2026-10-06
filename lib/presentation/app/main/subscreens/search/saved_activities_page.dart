import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/service/saved_activity_store.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_class_card.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_icons.dart';

/// "Saqlanganlar" — the activities the user hearted, newest first.
///
/// Reads straight off [SavedActivityStore], which is local: there is no
/// favourites endpoint, so this screen never loads and never fails. It is also
/// the only place a saved activity can be un-saved in bulk, hence the heart on
/// every card — making the user open each detail page to undo a tap they made
/// by accident would be the long way round.
///
/// Rebuilt from the store's own notifier, so un-saving a card removes it from
/// under the finger without this screen tracking any state of its own.
@RoutePage()
class SavedActivitiesPage extends StatelessWidget {
  const SavedActivitiesPage({super.key});

  /// Two columns on the page's 16pt margin with an 8pt gutter, and the card
  /// height the search grid uses — this is the same shelf, filtered to what
  /// the user kept. Spelled out the way `SearchView` spells it (artwork, gap,
  /// text block) so the two stay the same height if the card changes.
  static const double _cardExtent = 126.0 + 14.0 + 118.0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final store = getIt<SavedActivityStore>();

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: BaseAppBar(title: 'saved_title'.tr()),
      body: ValueListenableBuilder<Set<String>>(
        valueListenable: store.savedIds,
        builder: (context, __, ___) {
          final saved = store.load();
          if (saved.isEmpty) return const _SavedEmptyView();

          return GridView.builder(
            padding: EdgeInsets.fromLTRB(
              16.w,
              12.h,
              16.w,
              MediaQuery.of(context).padding.bottom + 24.h,
            ),
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 14.h,
              mainAxisExtent: _cardExtent.h,
            ),
            itemCount: saved.length,
            itemBuilder: (context, index) {
              final model = saved[index];
              return _SavedCard(model: model, store: store);
            },
          );
        },
      ),
    );
  }
}

/// A result card with an un-save heart over its artwork.
///
/// A [Stack] rather than a new parameter on [HomeCourseCard]: the heart belongs
/// to this screen, not to the card, and every other shelf in the app draws the
/// same card without one.
class _SavedCard extends StatelessWidget {
  const _SavedCard({required this.model, required this.store});

  final HomClass model;
  final SavedActivityStore store;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: HomeCourseCard(
            key: ValueKey(model.id),
            homClass: model,
            width: double.infinity,
            margin: EdgeInsets.zero,
          ),
        ),
        Positioned(
          top: 8.w,
          right: 8.w,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            // Toggles rather than removes, so a mis-tap is undone by tapping
            // the same spot again — the card is gone from the grid by then, but
            // the gesture is the one the detail screen's heart makes too.
            onTap: () => store.toggle(model),
            child: Container(
              padding: EdgeInsets.all(7.w),
              decoration: BoxDecoration(
                // Fixed light chip: it sits on a photo, which is the one place
                // the palette's fixed inks are the right answer.
                color: Colors.white.withValues(alpha: 0.92),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ink.withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: HomeIcon(
                Assets.icons.home.heart,
                size: 16,
                color: AppColors.error,
              ),
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
            Container(
              width: 72.w,
              height: 72.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: HomeIcon(
                Assets.icons.home.heart,
                size: 28,
                color: AppColors.error,
              ),
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
