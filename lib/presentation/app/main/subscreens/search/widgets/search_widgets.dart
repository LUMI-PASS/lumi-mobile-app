import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/image_url.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/service/photo_service.dart';
import 'package:shimmer/shimmer.dart';

/// Iconsax glyphs used by the search screen, tinted per theme via [BlendMode].
class _SearchIcon extends StatelessWidget {
  const _SearchIcon(this.asset, {required this.size, required this.color});

  final SvgGenImage asset;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => asset.svg(
        width: size.w,
        height: size.w,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
}

/// Top bar — back button on the left, centered title (Figma `Header`).
class SearchTopBar extends StatelessWidget {
  const SearchTopBar({super.key, this.title, this.onBack});

  /// Omit on a screen there is nothing to go back to — a root bottom-nav tab.
  /// The bar then shows the title alone, with no back affordance.
  final VoidCallback? onBack;

  /// Omit to show the back button alone. A pushed screen carries the title of
  /// whatever the user was doing, not the tab's name.
  final String? title;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final onBack = this.onBack;
    final title = this.title;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: SizedBox(
        height: 32.w,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (onBack != null)
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onBack,
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: c.control,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: c.controlBorder),
                    ),
                    child: _SearchIcon(Assets.icons.arrowLeft,
                        size: 16, color: c.textPrimary),
                  ),
                ),
              ),
            if (title != null)
              Text(
                title,
                style: AppText.semibold16.copyWith(color: c.textPrimary),
              ),
          ],
        ),
      ),
    );
  }
}

/// Search field + sort/filter button row (Figma `Search bar`).
class SearchBarRow extends StatefulWidget {
  const SearchBarRow({
    super.key,
    required this.initialTerm,
    required this.onChanged,
    this.onFilterTap,
    this.filterCount = 0,
    this.autofocus = false,
  });

  final String initialTerm;
  final ValueChanged<String> onChanged;

  /// Opens the keyboard as soon as the field is mounted. Set when the screen
  /// was reached by tapping a search field elsewhere (Home's header), where the
  /// user has already declared they want to type.
  final bool autofocus;

  /// Omit to render the field alone, without the trailing filter button.
  final VoidCallback? onFilterTap;
  final int filterCount;

  @override
  State<SearchBarRow> createState() => _SearchBarRowState();
}

class _SearchBarRowState extends State<SearchBarRow> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialTerm);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: c.controlBorder),
              ),
              child: Row(
                children: [
                  _SearchIcon(Assets.icons.home.search,
                      size: 16, color: c.textPlaceholder),
                  8.horizontalSpace,
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: widget.autofocus,
                      textInputAction: TextInputAction.search,
                      onChanged: widget.onChanged,
                      cursorColor: AppColors.brandPurple,
                      style: AppText.regular14.copyWith(color: c.textPrimary),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: 'search_hint'.tr(),
                        hintStyle: AppText.regular14
                            .copyWith(color: c.textPlaceholder),
                      ),
                    ),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _controller,
                    builder: (_, value, __) {
                      if (value.text.isEmpty) return const SizedBox.shrink();
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          _controller.clear();
                          widget.onChanged('');
                        },
                        child: Padding(
                          padding: EdgeInsets.only(left: 8.w),
                          child: Icon(Icons.close_rounded,
                              size: 18.sp, color: c.textSecondary),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          if (widget.onFilterTap != null) ...[
            8.horizontalSpace,
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onFilterTap,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 40.h,
                    height: 40.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: c.control,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: c.controlBorder),
                    ),
                    child: _SearchIcon(Assets.icons.icFilter,
                        size: 20, color: c.textPrimary),
                  ),
                  if (widget.filterCount > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: EdgeInsets.all(2.r),
                        constraints:
                            BoxConstraints(minWidth: 16.w, minHeight: 16.w),
                        decoration: BoxDecoration(
                          color: AppColors.brandPurple,
                          shape: BoxShape.circle,
                          border: Border.all(color: c.scaffoldBg, width: 1.5),
                        ),
                        child: Text(
                          '${widget.filterCount}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8.sp,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Horizontal tab chips (Figma `Category options`).
class SearchChips extends StatelessWidget {
  const SearchChips({
    super.key,
    required this.labels,
    required this.activeIndex,
    required this.onSelect,
  });

  final List<String> labels;

  /// Null when no chip is picked — the unfiltered state, where none is lit.
  final int? activeIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      height: 32.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: labels.length,
        separatorBuilder: (_, __) => 8.horizontalSpace,
        itemBuilder: (context, i) {
          final selected = i == activeIndex;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSelect(i),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                gradient: selected ? AppGradients.indigo : null,
                color: selected ? null : c.control,
                borderRadius: BorderRadius.circular(48.r),
                border: selected ? null : Border.all(color: c.controlBorder),
              ),
              child: Text(
                labels[i],
                style: AppText.medium13.copyWith(
                  color: selected ? Colors.white : c.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// "Посмотреть на карте" card (Figma `Container` with map icon + chevron).
class SearchMapCard extends StatelessWidget {
  const SearchMapCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: c.controlBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                alignment: Alignment.center,
                child: _SearchIcon(Assets.icons.map,
                    size: 24, color: c.textSecondary),
              ),
              8.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'branch_view_on_maps'.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          AppText.semibold14.copyWith(color: c.textPrimary),
                    ),
                    2.verticalSpace,
                    Text(
                      'view_on_map_subtitle'.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          AppText.regular12.copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
              ),
              8.horizontalSpace,
              _SearchIcon(Assets.icons.arrowRight,
                  size: 24, color: c.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

/// The category the results are currently narrowed to, shown as a removable
/// chip above the map row.
///
/// Arriving from a category on Home, the list is filtered before the user has
/// touched anything — without this they just see a short list and no reason for
/// it. The chip names the filter and its × takes it off, turning an invisible
/// constraint into one they can see and undo.
class SearchCategoryChip extends StatelessWidget {
  const SearchCategoryChip({
    super.key,
    required this.label,
    required this.onRemove,
  });

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onRemove,
          child: Container(
            padding: EdgeInsets.fromLTRB(12.w, 6.h, 8.w, 6.h),
            decoration: BoxDecoration(
              gradient: AppGradients.indigo,
              borderRadius: BorderRadius.circular(40.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.semibold12.copyWith(color: Colors.white),
                  ),
                ),
                6.horizontalSpace,
                Icon(Icons.close_rounded, size: 14.sp, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Result count row — "Все • 15 751" (Figma `Brand section`).
class SearchCountRow extends StatelessWidget {
  const SearchCountRow({super.key, required this.count});

  final int count;

  static String _grouped(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Text(
        'all_count'.tr(args: [_grouped(count)]),
        style: AppText.medium14.copyWith(color: c.textSecondary),
      ),
    );
  }
}

/// Empty state — box-search glyph + title + description
/// (Figma `Error Message` / "Результаты не найдены").
class SearchEmptyView extends StatelessWidget {
  const SearchEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SearchIcon(Assets.icons.home.boxSearch,
                size: 36, color: c.textSecondary),
            12.verticalSpace,
            Text(
              'results_not_found'.tr(),
              textAlign: TextAlign.center,
              style: AppText.heading20.copyWith(color: c.textPrimary),
            ),
            4.verticalSpace,
            Text(
              'results_not_found_desc'.tr(),
              textAlign: TextAlign.center,
              style: AppText.regular14.copyWith(color: c.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid card for a branch/center result (Figma `Popular item container`).
class SearchBranchCard extends StatelessWidget {
  const SearchBranchCard({
    super.key,
    required this.branch,
    required this.width,
  });

  final HomBranch branch;
  final double width;

  String? get _imageUrl {
    final direct = sanitizeImageUrl(branch.image);
    if (direct != null) return direct;
    final id = branch.id;
    if (id != null && branch.hasPhoto == true) {
      return PhotoService.getImageUrl(id);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final imageUrl = _imageUrl;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.router.push(BranchDetailRoute(branch: branch)),
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: SizedBox(
                width: double.infinity,
                height: 126.h,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Shimmer.fromColors(
                      baseColor: c.surface,
                      highlightColor:
                          c.isDark ? const Color(0xFF2E2E35) : Colors.white,
                      child: Container(color: c.surface),
                    ),
                    if (imageUrl != null)
                      CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        fadeInDuration: const Duration(milliseconds: 200),
                        errorWidget: (_, __, ___) => Center(
                          child: Icon(Icons.business_rounded,
                              size: 32.w, color: c.textPlaceholder),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            10.verticalSpace,
            Text(
              branch.title ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.semibold16.copyWith(color: c.textPrimary),
            ),
            if ((branch.address ?? '').isNotEmpty) ...[
              6.verticalSpace,
              Text(
                branch.address!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.regular12.copyWith(color: c.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
