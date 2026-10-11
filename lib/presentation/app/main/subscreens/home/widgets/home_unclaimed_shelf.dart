import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_shadows.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/image_url.dart';
import 'package:lumi_pass/common/widget/distance_label.dart';
import 'package:lumi_pass/data/api_model/unclaimed_centre/unclaimed_centre.dart';

/// The label for a centre's kind — "Sport", "O‘yin maydoni".
String unclaimedKindLabel(UnclaimedKind kind) => switch (kind) {
      UnclaimedKind.sports => 'unclaimed_kind_sports'.tr(),
      UnclaimedKind.playground => 'unclaimed_kind_playground'.tr(),
      // A kind this build has not heard of is still a centre.
      UnclaimedKind.center ||
      UnclaimedKind.unknown =>
        'unclaimed_kind_center'.tr(),
    };

/// Centres Lumi listed from open sources, as a row of cards.
///
/// A card here opens a page to READ and a number to call — never a booking —
/// so it is drawn unlike an activity card on purpose: the place's photo with
/// its logo on it, what it offers as one line of words, and no price.
class HomeUnclaimedShelf extends StatelessWidget {
  const HomeUnclaimedShelf({
    super.key,
    required this.centres,
    required this.storageKey,
  });

  final List<UnclaimedCentre> centres;

  /// Names this row's scroll position — the feed holds one shelf per kind, and
  /// each keeps its own.
  final String storageKey;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _UnclaimedCard.photoHeight.h + 92.h,
      child: ListView.builder(
        key: PageStorageKey(storageKey),
        scrollDirection: Axis.horizontal,
        // The feed's own inset: 8 here plus the card's 8 is the 16pt margin.
        padding: EdgeInsets.only(left: 8.w, right: 16.w),
        itemCount: centres.length,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.only(left: 8.w, bottom: 8.h),
          child: _UnclaimedCard(
            key: ValueKey('unclaimed-${centres[index].id}'),
            centre: centres[index],
          ),
        ),
      ),
    );
  }
}

class _UnclaimedCard extends StatelessWidget {
  const _UnclaimedCard({super.key, required this.centre});

  final UnclaimedCentre centre;

  static const double photoHeight = 124;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final photo = sanitizeImageUrl(centre.image);
    final logo = sanitizeImageUrl(centre.logo);
    final where = centre.district ?? centre.address;
    final offers = centre.activityNames.join(' · ');
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.router.push(UnclaimedCentreRoute(centre: centre)),
      child: Container(
        width: 236.w,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: photoHeight.h,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (photo != null)
                    CachedNetworkImage(
                      imageUrl: photo,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _fallback(),
                    )
                  else
                    _fallback(),
                  Positioned(
                    left: 10.w,
                    top: 10.h,
                    child: _KindChip(label: unclaimedKindLabel(centre.centreKind)),
                  ),
                  if (logo != null)
                    Positioned(
                      right: 10.w,
                      bottom: 10.h,
                      child: Container(
                        width: 36.w,
                        height: 36.w,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: logo,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      centre.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.semibold14.copyWith(color: c.textPrimary),
                    ),
                    if (offers.isNotEmpty) ...[
                      4.verticalSpace,
                      Text(
                        offers,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            AppText.regular12.copyWith(color: c.textSecondary),
                      ),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            where,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.regular12
                                .copyWith(color: c.textSecondary),
                          ),
                        ),
                        8.horizontalSpace,
                        // Draws nothing without a real position to measure
                        // from — see [DistanceLabel].
                        DistanceLabel(
                          latitude: centre.latitude,
                          longitude: centre.longitude,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// A centre with no photo: its initial on the brand gradient.
  Widget _fallback() => DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.indigo),
        child: Center(
          child: Text(
            centre.name.isNotEmpty
                ? centre.name.characters.first.toUpperCase()
                : '?',
            style: AppText.title24.copyWith(color: Colors.white),
          ),
        ),
      );
}

/// A dark translucent pill over a photo — legible on any picture.
class _KindChip extends StatelessWidget {
  const _KindChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(40.r),
      ),
      child: Text(
        label,
        style: AppText.medium12.copyWith(color: Colors.white),
      ),
    );
  }
}
