import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/user_avatar.dart';
import 'package:lumi_pass/data/api_model/class_full/class_full_model.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/widgets/rating_widgets.dart';

/// One public review: who wrote it, their stars, when, and the comment.
///
/// Shared by the detail page's reviews card and [ReviewsSheet], so a review
/// reads the same in the three-line preview as in the full list.
class ReviewTile extends StatelessWidget {
  const ReviewTile({super.key, required this.review});
  final ActivityReview review;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final name = review.authorName?.trim() ?? '';
    final date = review.date;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            UserAvatar(imageUrl: review.authorAvatar, size: 36),
            10.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // A customer who never filled in a name is still a
                    // customer — they get a neutral label, not a blank line.
                    name.isEmpty ? 'review_anonymous'.tr() : name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.semibold14.copyWith(color: c.textPrimary),
                  ),
                  2.verticalSpace,
                  RatingStars(filled: review.rating, size: 12),
                ],
              ),
            ),
            if (date != null)
              Text(
                DateFormat('dd.MM.yyyy').format(date),
                style: AppText.regular12.copyWith(color: c.textSecondary),
              ),
          ],
        ),
        8.verticalSpace,
        Text(
          review.comment,
          style: AppText.regular14.copyWith(color: c.textPrimary),
        ),
      ],
    );
  }
}

/// A review as a card in the detail page's horizontal strip — stars, date and
/// name on one line, then the comment cut to a few lines. The full text is in
/// [ReviewsSheet], which tapping the card opens.
class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.review, this.onTap});
  final ActivityReview review;
  final VoidCallback? onTap;

  /// Card size for the strip. The height is fixed so every card in the row
  /// lines up whatever the length of its comment.
  static double get width => 270.w;
  static double get height => 124.h;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final name = review.authorName?.trim() ?? '';
    final date = review.date;
    final meta = [
      if (date != null) DateFormat('dd.MM.yyyy').format(date),
      name.isEmpty ? 'review_anonymous'.tr() : name,
    ].join(' · ');

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: c.control,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                RatingStars(filled: review.rating, size: 13),
                8.horizontalSpace,
                Expanded(
                  child: Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.regular12.copyWith(color: c.textSecondary),
                  ),
                ),
              ],
            ),
            8.verticalSpace,
            Expanded(
              child: Text(
                review.comment,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: AppText.regular13.copyWith(color: c.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Every review of a class, newest first — opened from the detail page's
/// reviews card when there are more than it previews.
class ReviewsSheet extends StatefulWidget {
  const ReviewsSheet({super.key, required this.activityId});

  final String activityId;

  static Future<void> show(BuildContext context, {required String activityId}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.colors.surface,
      barrierColor: AppColors.ink.withValues(alpha: 0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => ReviewsSheet(activityId: activityId),
    );
  }

  @override
  State<ReviewsSheet> createState() => _ReviewsSheetState();
}

class _ReviewsSheetState extends State<ReviewsSheet> {
  static const _pageSize = 20;

  final _scroll = ScrollController();
  final _reviews = <ActivityReview>[];
  int _total = 0;
  int _page = 0;
  bool _loading = false;
  bool _failed = false;

  bool get _hasMore => _page == 0 || _reviews.length < _total;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _loadMore();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.extentAfter < 200) _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final next = await getIt<OrdersApi>().getClassReviews(
        widget.activityId,
        page: _page + 1,
        limit: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _page += 1;
        _reviews.addAll(next.reviews);
        // An empty page ends the list even if the total says otherwise — a
        // review hidden between two requests must not leave this spinning.
        _total = next.reviews.isEmpty ? _reviews.length : next.total;
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

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final showFooter = _loading || _failed;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            child: Text(
              'reviews_title'.tr(),
              style: AppText.heading20.copyWith(color: c.textPrimary),
            ),
          ),
          Expanded(
            child: ListView.separated(
              controller: _scroll,
              padding: EdgeInsets.fromLTRB(
                16.w,
                8.h,
                16.w,
                16.h + MediaQuery.of(context).padding.bottom,
              ),
              itemCount: _reviews.length + (showFooter ? 1 : 0),
              separatorBuilder: (_, __) => Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Divider(height: 1, color: c.border),
              ),
              itemBuilder: (_, index) {
                if (index < _reviews.length) {
                  return ReviewTile(review: _reviews[index]);
                }
                if (_failed) {
                  return Center(
                    child: TextButton(
                      onPressed: _loadMore,
                      child: Text(
                        'reviews_retry'.tr(),
                        style: AppText.semibold14
                            .copyWith(color: AppColors.brandPurple),
                      ),
                    ),
                  );
                }
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: const Center(child: CupertinoActivityIndicator()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
