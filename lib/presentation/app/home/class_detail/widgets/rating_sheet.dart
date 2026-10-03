import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/app_text_field.dart';
import 'package:lumi_pass/common/widget/auth/gradient_button.dart';
import 'package:lumi_pass/data/api_model/class_full/class_full_model.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';

/// "Rate this activity" — five stars, an optional comment and a submit button.
///
/// Only ever opened for a viewer who has paid for the class: the backend
/// refuses everyone else, so the detail page does not offer it to them.
/// Opening it again later starts from the stars and comment already given, and
/// submitting replaces them — one rating per customer.
class RatingSheet extends StatefulWidget {
  const RatingSheet({
    super.key,
    required this.activityId,
    this.initialRating,
    this.initialComment,
    this.title,
  });

  final String activityId;

  /// The stars this viewer gave before, if any.
  final int? initialRating;

  /// What this viewer wrote before, if anything.
  final String? initialComment;

  /// The class's name, shown under the heading.
  final String? title;

  /// Opens the sheet. Resolves to the class's new average and count once a
  /// rating has been saved, or null if the sheet was dismissed.
  static Future<RatingSummary?> show(
    BuildContext context, {
    required String activityId,
    int? initialRating,
    String? initialComment,
    String? title,
  }) {
    return showModalBottomSheet<RatingSummary>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.colors.surface,
      barrierColor: AppColors.ink.withValues(alpha: 0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => RatingSheet(
        activityId: activityId,
        initialRating: initialRating,
        initialComment: initialComment,
        title: title,
      ),
    );
  }

  @override
  State<RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<RatingSheet> {
  static const _maxStars = 5;

  /// The backend's cap (`MAX_RATING_COMMENT`).
  static const _maxComment = 500;

  late int _stars = widget.initialRating ?? 0;
  late final _comment = TextEditingController(text: widget.initialComment);
  bool _sending = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _sending = true);
    final messenger = ScaffoldMessenger.maybeOf(context);
    final navigator = Navigator.of(context);
    try {
      final summary = await getIt<OrdersApi>().rateClass(
        widget.activityId,
        _stars,
        comment: _comment.text,
      );
      messenger?.showSnackBar(
        SnackBar(content: Text('rating_saved_toast'.tr())),
      );
      navigator.pop(summary);
    } catch (_) {
      if (!mounted) return;
      setState(() => _sending = false);
      messenger?.showSnackBar(
        SnackBar(content: Text('rating_failed'.tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final title = widget.title?.trim() ?? '';

    return Padding(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 12.h,
        // Lifted clear of the keyboard, which the comment field brings up.
        bottom: 16.h +
            MediaQuery.of(context).padding.bottom +
            MediaQuery.of(context).viewInsets.bottom,
      ),
      // Scrollable so the keyboard can never push the button off a short
      // screen.
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'rating_sheet_title'.tr(),
              style: AppText.heading20.copyWith(color: c.textPrimary),
            ),
            SizedBox(height: 6.h),
            Text(
              'rating_sheet_hint'.tr(),
              textAlign: TextAlign.center,
              style: AppText.regular13.copyWith(color: c.textSecondary),
            ),
            if (title.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppText.semibold14.copyWith(color: c.textPrimary),
              ),
            ],
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var star = 1; star <= _maxStars; star++)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _sending
                        ? null
                        : () {
                            HapticFeedback.selectionClick();
                            setState(() => _stars = star);
                          },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: Icon(
                        star <= _stars
                            ? CupertinoIcons.star_fill
                            : CupertinoIcons.star,
                        size: 40.sp,
                        color: star <= _stars ? AppColors.warning : c.disabled,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 20.h),
            AppTextField(
              controller: _comment,
            // The stars were already picked by the tap that opened this sheet,
            // so the next thing to do is write — bring the keyboard up for it.
            autofocus: true,
              label: 'rating_comment_label'.tr(),
              enabled: !_sending,
              minLines: 3,
              maxLines: 5,
              maxLength: _maxComment,
            ),
            SizedBox(height: 6.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'rating_comment_public'.tr(),
                style: AppText.regular12.copyWith(color: c.textSecondary),
              ),
            ),
            SizedBox(height: 16.h),
            GradientButton(
              text: 'rating_submit'.tr(),
              // Nothing to send until a star is picked — there is no zero rating.
              enabled: _stars > 0 && !_sending,
              loading: _sending,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
