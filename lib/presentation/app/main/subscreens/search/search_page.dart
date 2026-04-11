import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/widget/common_text_filed.dart';
import 'package:lumi_pass/common/widget/container_3d.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/service/photo_service.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/cubit/search_cubit.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/cubit/search_state.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/class_item_widget.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/explore_map_sheet.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/filter_bottom_sheet.dart';
import 'package:lumi_pass/presentation/app/widgets/empty_view.dart';
import 'package:shimmer/shimmer.dart';

@RoutePage()
class SearchPage
    extends BasePage<SearchCubit, SearchBuildable, SearchListenable> {
  @override
  void init(BuildContext context) {
    context.read<SearchCubit>().init();
    super.init(context);
  }

  @override
  void onFocusGained(BuildContext context) {
    context.read<SearchCubit>().applyPendingCategory();
    super.onFocusGained(context);
  }

  @override
  Widget builder(context, state) {
    final cubit = context.read<SearchCubit>();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background decoration
            Positioned(
              bottom: -40,
              right: -50,
              child: Opacity(
                opacity: 0.15,
                child: Assets.icons.background.misc3.svg(
                  width: 260.w,
                  height: 260.w,
                  colorFilter: ColorFilter.mode(
                    context.colors.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      'explore'.tr().s(30).w(600).c(context.colors.black),
                      20.kh,
                      // Search bar + filter button
                      Row(
                        children: [
                          Expanded(
                            child: CommonTextField(
                              background: context.colors.onPrimary,
                              enabledBorderColor: context.colors.onPrimary,
                              prefixIcon: Assets.icons.search.svg(),
                              hint: 'search'.tr(),
                              suffix: state.searchTerm.isNotEmpty
                                  ? const Icon(Icons.close, size: 20)
                                  : null,
                              suffixPressed: state.searchTerm.isNotEmpty
                                  ? () => cubit.setSearchTerm('')
                                  : null,
                              onChanged: (t) => cubit.setSearchTerm(t),
                            ),
                          ),
                          10.kw,
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: _FilterWithBadge(
                              count: cubit.activeFilterCount,
                              onTap: () async {
                                final result = await FilterBottomSheet.show(
                                  context,
                                  initial: state.filter,
                                );
                                if (result != null) {
                                  cubit.applyFilter(result);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      // Active filter badges
                      if (state.filter != null) ...[
                        4.kh,
                        _FilterBadges(
                          filter: state.filter!,
                          onClearFilter: () => cubit.clearFilter(),
                        ),
                        8.kh,
                      ],
                      // Selected category chip
                      if (state.selectedCategory != null) ...[
                        _TagChip(
                          text: state.selectedCategory!.title ?? '',
                          onClear: () => cubit.selectCategory(null),
                        ),
                        12.kh,
                      ],
                      // Tabs: Classes | Centers
                      Row(
                        children: [
                          Expanded(
                            child: _SegmentedButton(
                              text: 'classes'.tr(),
                              selected: state.activeTab == 0,
                              onTap: () => cubit.setTab(0),
                            ),
                          ),
                          12.kw,
                          Expanded(
                            child: _SegmentedButton(
                              text: 'centers'.tr(),
                              selected: state.activeTab == 1,
                              onTap: () => cubit.setTab(1),
                            ),
                          ),
                        ],
                      ),
                      12.kh,
                      // Categories button (Classes tab only)
                      if (state.activeTab == 0 &&
                          state.categories.isNotEmpty &&
                          state.selectedCategory == null)
                        Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: GestureDetector(
                            onTap: () => _showCategoriesSheet(
                                context, state.categories, cubit),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14.w, vertical: 10.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: context.colors.primary
                                      .withOpacity(0.15),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.grid_view_rounded,
                                      size: 16.w,
                                      color: context.colors.primary),
                                  6.kw,
                                  'categories'.tr()
                                      .s(13)
                                      .w(600)
                                      .c(context.colors.primary),
                                  4.kw,
                                  Icon(Icons.keyboard_arrow_down_rounded,
                                      size: 18.w,
                                      color: context.colors.primary),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Results
                Expanded(
                  child: state.isLoading
                      ? _SearchResultShimmer()
                      : state.activeTab == 0
                          ? _ClassesList(
                              classes: state.classes,
                              isLoadingMore: state.isLoadingMore,
                              onLoadMore: () => cubit.loadMore(),
                            )
                          : _BranchesList(
                              branches: state.branches,
                              isLoadingMore: state.isLoadingMore,
                              onLoadMore: () => cubit.loadMore(),
                            ),
                ),
              ],
            ),
            // Floating map button
            Positioned(
              right: 16,
              bottom: 16,
              child: Container3d(
                onTap: () => ExploreMapSheet.show(context, state.branches),
                width: 56,
                height: 56,
                depth: 4,
                padding: EdgeInsets.zero,
                backgroundColor: context.colors.primary,
                borderColor: context.colors.primary,
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Assets.icons.map.svg(
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoriesSheet(
      BuildContext context, List<HomCategory> categories, SearchCubit cubit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => _CategoriesSheet(
        categories: categories,
        selectedId: cubit.buildable.selectedCategory?.id,
        onSelect: (cat) {
          cubit.selectCategory(cat);
          Navigator.pop(context);
        },
        onClear: () {
          cubit.selectCategory(null);
          Navigator.pop(context);
        },
      ),
    );
  }
}

// --- Categories bottom sheet (webapp-style 2-col grid with images) ---

class _CategoriesSheet extends StatelessWidget {
  const _CategoriesSheet({
    required this.categories,
    required this.onSelect,
    required this.onClear,
    this.selectedId,
  });

  final List<HomCategory> categories;
  final String? selectedId;
  final ValueChanged<HomCategory> onSelect;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          12.kh,
          Container(
            width: 48, height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          16.kh,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                'pick_category'.tr().s(22).w(700),
                if (selectedId != null)
                  GestureDetector(
                    onTap: onClear,
                    child: 'clear'.tr()
                        .s(14)
                        .w(600)
                        .c(context.colors.primary),
                  ),
              ],
            ),
          ),
          16.kh,
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12.h,
                crossAxisSpacing: 12.w,
                childAspectRatio: 1.1,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = selectedId == cat.id;
                return _CategoryCard(
                  category: cat,
                  isSelected: isSelected,
                  onTap: () => onSelect(cat),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- Category card with image overlay (webapp style) ---

class _CategoryCard extends StatefulWidget {
  const _CategoryCard({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final HomCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  String? _imageUrl;
  bool _isLoading = true;

  static final List<LinearGradient> _gradients = [
    const LinearGradient(colors: [Color(0xFFA652C7), Color(0xFFFF7093)]),
    const LinearGradient(colors: [Color(0xFF307CE0), Color(0xFF24AE74)]),
    const LinearGradient(colors: [Color(0xFFF6B53D), Color(0xFFE6465A)]),
    const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
    const LinearGradient(colors: [Color(0xFF14B8A6), Color(0xFF3B82F6)]),
    const LinearGradient(colors: [Color(0xFFF43F5E), Color(0xFFF97316)]),
  ];

  @override
  void initState() {
    super.initState();
    _resolveImage();
  }

  Future<void> _resolveImage() async {
    final catId = widget.category.id;
    if (catId == null) {
      setState(() => _isLoading = false);
      return;
    }

    if (widget.category.hasPhoto == true) {
      setState(() => _imageUrl = PhotoService.getImageUrl(catId));
    }

    try {
      final photos =
          await PhotoService.instance.getCategoryPhotos(catId, limit: 1);
      if (mounted && photos.isNotEmpty) {
        setState(() {
          _imageUrl = photos.first;
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    if (mounted) setState(() => _isLoading = false);
  }

  LinearGradient _fallbackGradient() {
    final title = widget.category.title ?? '';
    final charCode = title.isNotEmpty ? title.codeUnitAt(0) : 65;
    return _gradients[(charCode + title.length) % _gradients.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container3d(
      onTap: widget.onTap,
      padding: EdgeInsets.zero,
      depth: 3,
      backgroundColor: Colors.white,
      borderColor: widget.isSelected
          ? context.colors.primary
          : Colors.grey.shade200,
      borderWidth: widget.isSelected ? 2 : 1,
      borderRadius: BorderRadius.circular(18.r),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image or gradient fallback
            if (_imageUrl != null)
              CachedNetworkImage(
                imageUrl: _imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: Colors.grey.shade200,
                  highlightColor: Colors.grey.shade50,
                  child: Container(color: Colors.white),
                ),
                errorWidget: (_, __, ___) => Container(
                  decoration:
                      BoxDecoration(gradient: _fallbackGradient()),
                ),
              )
            else if (_isLoading)
              Shimmer.fromColors(
                baseColor: Colors.grey.shade200,
                highlightColor: Colors.grey.shade50,
                child: Container(color: Colors.white),
              )
            else
              Container(
                decoration: BoxDecoration(gradient: _fallbackGradient()),
              ),

            // Gradient overlay + title at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(8.w, 28.h, 8.w, 10.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.35),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Text(
                  widget.category.title ?? '',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    shadows: const [
                      Shadow(blurRadius: 4, color: Colors.black54),
                    ],
                  ),
                ),
              ),
            ),

            // Selected indicator
            if (widget.isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 24.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: context.colors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child:
                      Icon(Icons.check, color: Colors.white, size: 14.w),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// --- Classes list with infinite scroll ---

class _ClassesList extends StatelessWidget {
  const _ClassesList({
    required this.classes,
    required this.isLoadingMore,
    required this.onLoadMore,
  });

  final List<HomClass> classes;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (classes.isEmpty) return const EmptyView();

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 300) {
          onLoadMore();
        }
        return false;
      },
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 8.h),
        physics: const BouncingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: classes.length + (isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => 14.kh,
        itemBuilder: (context, index) {
          if (index == classes.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return ClassItemWidget(
            homClass: classes[index],
            width: 1.sw - 32.w,
            wrapBranch: false,
          );
        },
      ),
    );
  }
}

// --- Branches list with infinite scroll ---

class _BranchesList extends StatelessWidget {
  const _BranchesList({
    required this.branches,
    required this.isLoadingMore,
    required this.onLoadMore,
  });

  final List<HomBranch> branches;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (branches.isEmpty) return const EmptyView();

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 300) {
          onLoadMore();
        }
        return false;
      },
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        physics: const BouncingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: branches.length + (isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => 14.kh,
        itemBuilder: (context, index) {
          if (index == branches.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _BranchResultCard(branch: branches[index]);
        },
      ),
    );
  }
}

// --- Branch result card matching webapp's BranchCard ---

class _BranchResultCard extends StatefulWidget {
  const _BranchResultCard({required this.branch});
  final HomBranch branch;

  @override
  State<_BranchResultCard> createState() => _BranchResultCardState();
}

class _BranchResultCardState extends State<_BranchResultCard> {
  String? _imageUrl;
  bool _hasImageError = false;

  static const _gradients = [
    [Color(0xFFA652C7), Color(0xFFFF7093)],
    [Color(0xFF307CE0), Color(0xFF24AE74)],
    [Color(0xFFF6B53D), Color(0xFFE6465A)],
    [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    [Color(0xFF14B8A6), Color(0xFF3B82F6)],
    [Color(0xFFF43F5E), Color(0xFFF97316)],
  ];

  LinearGradient _fallbackGradient() {
    final title = widget.branch.title ?? '';
    final i =
        ((title.isNotEmpty ? title.codeUnitAt(0) : 65) + title.length) %
            _gradients.length;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: _gradients[i],
    );
  }

  @override
  void initState() {
    super.initState();
    _resolveImage();
  }

  Future<void> _resolveImage() async {
    final branchId = widget.branch.id;
    if (branchId == null) return;

    if (widget.branch.hasPhoto == true) {
      setState(() => _imageUrl = PhotoService.getImageUrl(branchId));
    }

    try {
      final photos =
          await PhotoService.instance.getBranchPhotos(branchId, limit: 1);
      if (mounted && photos.isNotEmpty) {
        setState(() => _imageUrl = photos.first);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final branch = widget.branch;
    final distance = _formatDistance(branch.distance);
    final hasImage = _imageUrl != null && !_hasImageError;

    return Container3d(
      onTap: () => context.router.push(BranchDetailRoute(branch: branch)),
      padding: EdgeInsets.all(8.w),
      depth: 3,
      backgroundColor: Colors.white,
      borderColor: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(22.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with gradient fallback
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: hasImage
                  ? CachedNetworkImage(
                      imageUrl: _imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Shimmer.fromColors(
                        baseColor: Colors.grey.shade200,
                        highlightColor: Colors.grey.shade50,
                        child: Container(color: Colors.white),
                      ),
                      errorWidget: (_, __, ___) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) setState(() => _hasImageError = true);
                        });
                        return Container(
                          decoration:
                              BoxDecoration(gradient: _fallbackGradient()),
                        );
                      },
                    )
                  : Container(
                      decoration:
                          BoxDecoration(gradient: _fallbackGradient()),
                      child: Center(
                        child: Icon(Icons.business_rounded,
                            size: 40.w, color: Colors.white.withOpacity(0.5)),
                      ),
                    ),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(6.w, 10.h, 6.w, 4.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                (branch.title ?? '').s(16).w(700).c(const Color(0xFF1E293B)),

                // Description
                if (branch.description != null &&
                    branch.description!.isNotEmpty) ...[
                  4.kh,
                  Text(
                    branch.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],

                8.kh,

                // Address + Distance row (side by side like webapp)
                Row(
                  children: [
                    // Address
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 14.w,
                              color: const Color(0xFF312E81).withOpacity(0.9)),
                          4.kw,
                          Expanded(
                            child: Text(
                              branch.address ?? 'location_not_specified'.tr(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: const Color(0xFF312E81).withOpacity(0.9),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Distance
                    if (distance.isNotEmpty) ...[
                      12.kw,
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.navigation_outlined,
                              size: 14.w,
                              color: const Color(0xFF312E81).withOpacity(0.9)),
                          4.kw,
                          Text(
                            distance,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color:
                                  const Color(0xFF312E81).withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),

                10.kh,

                // Open Branch button
                SizedBox(
                  width: double.infinity,
                  child: Container3d(
                    onTap: () => context.router
                        .push(BranchDetailRoute(branch: branch)),
                    padding:
                        EdgeInsets.symmetric(vertical: 10.h),
                    depth: 2,
                    backgroundColor: context.colors.primary.withOpacity(0.06),
                    borderColor: context.colors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.open_in_new_rounded,
                              size: 14.w, color: context.colors.primary),
                          6.kw,
                          Text(
                            'open_branch'.tr(),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: context.colors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDistance(double? distanceMeters) {
    if (distanceMeters == null || distanceMeters <= 0) return '';
    if (distanceMeters < 1000) return '${distanceMeters.round()} m';
    return '${(distanceMeters / 1000).round()} km';
  }
}

// --- Filter button with badge ---

class _FilterWithBadge extends StatelessWidget {
  const _FilterWithBadge({required this.count, this.onTap});
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container3d(
          onTap: onTap,
          padding: const EdgeInsets.all(12),
          depth: 3,
          backgroundColor: primary,
          borderColor: primary,
          borderRadius: BorderRadius.circular(12),
          child: Assets.icons.filter.svg(
            colorFilter:
                const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
        if (count > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: primary, width: 1.5),
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// --- Filter badges row ---

class _FilterBadges extends StatelessWidget {
  const _FilterBadges({required this.filter, required this.onClearFilter});
  final FilterResult filter;
  final VoidCallback onClearFilter;

  @override
  Widget build(BuildContext context) {
    final badges = <Widget>[];

    if (filter.datePreset != DatePreset.none) {
      String dateLabel;
      if (filter.datePreset == DatePreset.custom && filter.fromDate != null) {
        final from = '${filter.fromDate!.day}.${filter.fromDate!.month}';
        final to = filter.toDate != null
            ? ' \u2192 ${filter.toDate!.day}.${filter.toDate!.month}'
            : '';
        dateLabel = 'Date: $from$to';
      } else {
        dateLabel = {
          DatePreset.none: '',
          DatePreset.today: 'today'.tr(),
          DatePreset.tomorrow: 'tomorrow'.tr(),
          DatePreset.thisWeek: 'this_week'.tr(),
          DatePreset.custom: 'custom'.tr(),
        }[filter.datePreset]!;
      }
      final label = dateLabel;
      badges.add(_BadgeChip(
          text: label,
          color: const Color(0xFF6366F1),
          onRemove: onClearFilter));
    }
    if (filter.ageYears != null) {
      badges.add(_BadgeChip(
          text: '${filter.ageYears} y.o',
          color: const Color(0xFF16A34A),
          onRemove: onClearFilter));
    }
    if (filter.gender != Gender.any) {
      badges.add(_BadgeChip(
          text: filter.gender == Gender.boy ? 'boys'.tr() : 'girls'.tr(),
          color: filter.gender == Gender.boy
              ? const Color(0xFF6366F1)
              : const Color(0xFFEC4899),
          onRemove: onClearFilter));
    }
    if (filter.pricePreset == PricePreset.custom) {
      badges.add(_BadgeChip(
          text:
              '${filter.priceRange.start.toInt()}-${filter.priceRange.end.toInt()} coins',
          color: const Color(0xFFF97316),
          onRemove: onClearFilter));
    }

    if (badges.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 8, runSpacing: 6, children: badges);
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({
    required this.text,
    required this.color,
    required this.onRemove,
  });
  final String text;
  final Color color;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          4.kw,
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 14, color: color),
          ),
        ],
      ),
    );
  }
}

// --- Tag chip ---

class _TagChip extends StatelessWidget {
  const _TagChip({required this.text, this.onClear});
  final String text;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Container3d(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      depth: 2,
      backgroundColor: Colors.white,
      borderColor: context.colors.primary.withOpacity(0.2),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          text.s(12).w(600).c(context.colors.primary),
          6.kw,
          GestureDetector(
            onTap: onClear,
            child: Icon(Icons.close_rounded,
                size: 16, color: context.colors.primary),
          ),
        ],
      ),
    );
  }
}

// --- Segmented button ---

class _SegmentedButton extends StatelessWidget {
  const _SegmentedButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Container3d(
      onTap: onTap,
      padding: EdgeInsets.zero,
      height: 44,
      depth: selected ? 3 : 2,
      backgroundColor: selected ? primary : Theme.of(context).cardColor,
      borderColor: selected ? primary : Theme.of(context).dividerColor,
      borderRadius: BorderRadius.circular(12),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}

// --- Shimmer loading ---

class _SearchResultShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        separatorBuilder: (_, __) => 14.kh,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 150.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                12.kh,
                Container(width: 100.w, height: 10.h, color: Colors.white),
                8.kh,
                Container(width: 180.w, height: 16.h, color: Colors.white),
                10.kh,
                Container(width: 140.w, height: 12.h, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
