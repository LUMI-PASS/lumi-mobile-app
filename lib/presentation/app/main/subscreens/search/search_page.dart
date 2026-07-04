import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/widget/common_text_filed.dart';
import 'package:lumi_pass/common/widget/container_3d.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/common/utils/image_url.dart';
import 'package:lumi_pass/data/service/photo_service.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/cubit/search_cubit.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/cubit/search_state.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/shorts/shorts_feed.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/class_item_widget.dart';
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
    final cubit = context.read<SearchCubit>();
    cubit.applyPendingCategory();
    cubit.refreshIfLanguageChanged();
    super.onFocusGained(context);
  }

  @override
  Widget builder(context, state) {
    final cubit = context.read<SearchCubit>();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              bottom: -40,
              right: -50,
              child: Opacity(
                opacity: 0.15,
                child: Assets.icons.background.misc3.svg(
                  width: 260.w,
                  height: 260.w,
                  colorFilter: ColorFilter.mode(
                      context.colors.primary, BlendMode.srcIn),
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
                                if (result != null) cubit.applyFilter(result);
                              },
                            ),
                          ),
                        ],
                      ),
                      if (state.filter != null) ...[
                        4.kh,
                        _FilterBadges(
                          filter: state.filter!,
                          onClearFilter: () => cubit.clearFilter(),
                        ),
                        8.kh,
                      ],
                      if (state.selectedCategory != null) ...[
                        _TagChip(
                          text: state.selectedCategory!.title ?? '',
                          onClear: () => cubit.selectCategory(null),
                        ),
                        12.kh,
                      ],
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
                      // "Open in map" button — visible on both tabs
                      if (state.categories.isNotEmpty &&
                          state.selectedCategory == null)
                        Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: GestureDetector(
                            onTap: () async {
                              final cat = await _ExploreMapSheet.show(
                                context,
                                categories: state.categories,
                              );
                              if (cat != null) cubit.selectCategory(cat);
                            },
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
                                  Icon(Icons.map_rounded,
                                      size: 16.w,
                                      color: context.colors.primary),
                                  6.kw,
                                  'open_in_map'
                                      .tr()
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
                Expanded(
                  child: state.isLoading
                      ? _SearchResultShimmer()
                      : state.activeTab == 0
                          ? _ClassesList(
                              classes: state.classes,
                              isLoadingMore: state.isLoadingMore,
                              onLoadMore: () => cubit.loadMore(),
                            )
                          : _BranchesWithMap(
                              branches: state.branches,
                              categories: state.categories,
                              isLoadingMore: state.isLoadingMore,
                              onLoadMore: () => cubit.loadMore(),
                              onOpenMap: () async {
                                final cat = await _ExploreMapSheet.show(
                                  context,
                                  categories: state.categories,
                                );
                                if (cat != null) cubit.selectCategory(cat);
                              },
                            ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Full-screen map sheet — map on top, category filter chips at bottom.
// Category selection filters map markers; sheet only closes via close/back.
// Returns a HomCategory if the user wants to apply it to the search list.
// ─────────────────────────────────────────────────────────────────────────────

class _ExploreMapSheet extends StatefulWidget {
  const _ExploreMapSheet({required this.categories});

  final List<HomCategory> categories;

  static Future<HomCategory?> show(
    BuildContext context, {
    required List<HomCategory> categories,
  }) {
    return showModalBottomSheet<HomCategory>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExploreMapSheet(categories: categories),
    );
  }

  @override
  State<_ExploreMapSheet> createState() => _ExploreMapSheetState();
}

class _ExploreMapSheetState extends State<_ExploreMapSheet> {
  final _repo = getIt<HomeRepository>();
  final _mapCtrl = MapController();

  LatLng? _userLocation;
  String? _focusedBranchId;
  bool _mapReady = false;
  bool _isBranchesLoading = true;

  HomCategory? _selectedCategory;
  bool _isFilterLoading = false;
  bool _showCatOverlay = false;

  // All branches that have valid GPS coordinates
  List<HomBranch> _validBranches = [];
  // Subset shown on the map (changes when a category is active)
  List<HomBranch> _mapBranches = [];
  // Own categories list — fetched fresh so titles are always resolved
  List<HomCategory> _categories = [];

  static const _defaultCenter = LatLng(41.3111, 69.2797);

  @override
  void initState() {
    super.initState();
    // Seed from caller so the list is ready immediately if available
    _categories = widget.categories
        .where((c) => (c.title ?? '').isNotEmpty)
        .toList();
    _fetchBranches();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final cats = await _repo.getAllCategories();
      final valid = cats.where((c) => (c.title ?? '').isNotEmpty).toList();
      if (mounted && valid.isNotEmpty) {
        setState(() => _categories = valid);
        // Update the shared cache too
        SearchCubit.cachedCategories = valid;
      }
    } catch (_) {}
  }

  bool _hasValidCoords(HomBranch b) {
    return b.latitude != null &&
        b.longitude != null &&
        b.latitude! != 0 &&
        b.longitude! != 0;
  }

  Future<void> _fetchBranches() async {
    try {
      final result =
          await _repo.getDiscoveryBranches(page: 1, limit: 100);
      if (!mounted) return;
      final valid =
          result.branches.where(_hasValidCoords).toList();
      setState(() {
        _validBranches = valid;
        _mapBranches = valid;
        _isBranchesLoading = false;
      });
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _fitToMarkers());
    } catch (_) {
      if (mounted) setState(() => _isBranchesLoading = false);
    }
  }


  void _onMapReady() {
    _mapReady = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _fitToMarkers());
  }

  void _fitToMarkers() {
    if (!_mapReady) return;
    final pts = _mapBranches
        .map((b) => LatLng(b.latitude!, b.longitude!))
        .toList();
    if (pts.isEmpty) {
      _mapCtrl.move(_defaultCenter, 12);
    } else if (pts.length == 1) {
      _mapCtrl.move(pts.first, 14);
    } else {
      _mapCtrl.fitCamera(CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(pts),
        padding: EdgeInsets.all(52.w),
        maxZoom: 14,
      ));
    }
  }

  Future<void> _selectCategory(HomCategory cat) async {
    // Tapping the active category clears the filter
    if (_selectedCategory != null && cat.id != null && _selectedCategory!.id == cat.id) {
      setState(() {
        _selectedCategory = null;
        _mapBranches = _validBranches;
        _focusedBranchId = null;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitToMarkers());
      return;
    }

    setState(() {
      _selectedCategory = cat;
      _isFilterLoading = true;
      _focusedBranchId = null;
    });

    try {
      // Fetch classes in this category to find which branches have them
      final result = await _repo.getDiscoveryClasses(
        page: 1,
        limit: 100,
        categoryId: cat.id,
      );
      final branchIds = result.classes
          .where((c) => c.branch?.id != null)
          .map((c) => c.branch!.id!)
          .toSet();

      if (!mounted) return;
      setState(() {
        _mapBranches = _validBranches
            .where((b) => b.id != null && branchIds.contains(b.id))
            .toList();
        _isFilterLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitToMarkers());
    } catch (_) {
      if (mounted) setState(() => _isFilterLoading = false);
    }
  }

  void _toggleCatOverlay() {
    setState(() => _showCatOverlay = !_showCatOverlay);
  }

  void _pickCategory(HomCategory? cat) {
    setState(() => _showCatOverlay = false);
    if (cat == null) {
      setState(() {
        _selectedCategory = null;
        _mapBranches = _validBranches;
        _focusedBranchId = null;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitToMarkers());
    } else {
      _selectCategory(cat);
    }
  }

  void _tapMarker(HomBranch branch) {
    setState(() => _focusedBranchId = branch.id);
    final z = _mapCtrl.camera.zoom;
    _mapCtrl.move(
      LatLng(branch.latitude!, branch.longitude!),
      z < 14 ? 14 : z,
    );
  }

  void _zoom(double delta) {
    if (!_mapReady) return;
    final z = _mapCtrl.camera.zoom;
    _mapCtrl.move(_mapCtrl.camera.center, (z + delta).clamp(3, 18));
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final primary = context.colors.primary;

    return Container(
      height: screenH * 0.92,
      decoration: BoxDecoration(
        color: context.colors.window,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Stack(
        children: [
          Column(
        children: [
          // ── Handle
          Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // ── Header
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 8.h),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 34.w,
                    height: 34.w,
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(Icons.close_rounded, size: 18.w, color: primary),
                  ),
                ),
                12.kw,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      'centers_on_map'.tr().s(16).w(700),
                      if (_selectedCategory != null)
                        Text(
                          _selectedCategory!.title ?? '',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                if (_validBranches.isNotEmpty)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on_rounded,
                            size: 13.w, color: primary),
                        4.kw,
                        '${_mapBranches.length}/${_validBranches.length}'
                            .s(12)
                            .w(700)
                            .c(primary),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // ── Map
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: FlutterMap(
                      mapController: _mapCtrl,
                      options: MapOptions(
                        initialCenter: _defaultCenter,
                        initialZoom: 12,
                        onMapReady: _onMapReady,
                        onTap: (_, __) =>
                            setState(() => _focusedBranchId = null),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.lumi.pass',
                          maxZoom: 19,
                        ),
                        MarkerLayer(
                          markers: _mapBranches.map((branch) {
                            final focused = _focusedBranchId == branch.id;
                            return Marker(
                              point: LatLng(
                                  branch.latitude!, branch.longitude!),
                              width: focused ? 46 : 36,
                              height: focused ? 46 : 36,
                              child: GestureDetector(
                                onTap: () => _tapMarker(branch),
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: focused ? primary : Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: primary,
                                        width: focused ? 3 : 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: primary.withOpacity(
                                            focused ? 0.45 : 0.18),
                                        blurRadius: focused ? 12 : 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.location_on_rounded,
                                    size: focused ? 22 : 17,
                                    color:
                                        focused ? Colors.white : primary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        if (_userLocation != null)
                          MarkerLayer(markers: [
                            Marker(
                              point: _userLocation!,
                              width: 20,
                              height: 20,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.3),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ]),
                      ],
                    ),
                  ),
                ),

                // Zoom controls
                Positioned(
                  right: 22.w,
                  top: 12.h,
                  child: Column(
                    children: [
                      _ZoomBtn(
                          icon: Icons.add,
                          onTap: () => _zoom(1),
                          color: primary),
                      4.kh,
                      _ZoomBtn(
                          icon: Icons.remove,
                          onTap: () => _zoom(-1),
                          color: primary),
                    ],
                  ),
                ),

                // Branches loading overlay
                if (_isBranchesLoading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: primary,
                        ),
                      ),
                    ),
                  ),

                // Category filter loading overlay
                if (!_isBranchesLoading && _isFilterLoading)
                  Positioned(
                    top: 12.h,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 14.w,
                              height: 14.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: primary,
                              ),
                            ),
                            8.kw,
                            Text(
                              'filter_filtering'.tr(),
                              style: TextStyle(
                                  fontSize: 12.sp, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Focused branch callout
                if (_focusedBranchId != null)
                  Positioned(
                    left: 22.w,
                    right: 22.w,
                    bottom: 12.h,
                    child: _BranchCallout(
                      branch: _mapBranches.firstWhere(
                        (b) => b.id == _focusedBranchId,
                        orElse: () => _mapBranches.first,
                      ),
                      onTap: () {
                        final branch = _mapBranches.firstWhere(
                          (b) => b.id == _focusedBranchId,
                          orElse: () => _mapBranches.first,
                        );
                        Navigator.pop(context);
                        context.router
                            .push(BranchDetailRoute(branch: branch));
                      },
                      primary: primary,
                    ),
                  ),
              ],
            ),
          ),

          // ── Categories button row
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _toggleCatOverlay,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: _selectedCategory != null
                            ? primary.withOpacity(0.08)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: _selectedCategory != null
                              ? primary.withOpacity(0.25)
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.category_rounded,
                              size: 16.w, color: primary),
                          8.kw,
                          Expanded(
                            child: Text(
                              _selectedCategory?.title ??
                                  'filter_by_category'.tr(),
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: _selectedCategory != null
                                    ? primary
                                    : const Color(0xFF1E293B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_down_rounded,
                              size: 18.w, color: primary),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_selectedCategory != null) ...[
                  8.kw,
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = null;
                        _mapBranches = _validBranches;
                        _focusedBranchId = null;
                      });
                      WidgetsBinding.instance
                          .addPostFrameCallback((_) => _fitToMarkers());
                    },
                    child: Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(Icons.close_rounded,
                          size: 16.w, color: primary),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 14.h),
          ],
        ),

          // ── Category overlay (tap-outside-to-dismiss scrim + list panel)
          if (_showCatOverlay) ...[
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _showCatOverlay = false),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20.r)),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: screenH * 0.55,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20.r)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle
                    Padding(
                      padding: EdgeInsets.only(top: 10.h, bottom: 4.h),
                      child: Center(
                        child: Container(
                          width: 40.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    // Title row
                    Padding(
                      padding:
                          EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
                      child: Row(
                        children: [
                          'filter_by_category'
                              .tr()
                              .s(16)
                              .w(700)
                              .c(const Color(0xFF1E293B)),
                          const Spacer(),
                          if (_selectedCategory != null)
                            GestureDetector(
                              onTap: () => _pickCategory(null),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: primary.withOpacity(0.08),
                                  borderRadius:
                                      BorderRadius.circular(10.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.close_rounded,
                                        size: 12.w, color: primary),
                                    4.kw,
                                    'clear'.tr().s(12).w(600).c(primary),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey.shade100),
                    // Category list
                    Flexible(
                      child: _categories.isEmpty
                          ? Padding(
                              padding: EdgeInsets.all(24.h),
                              child: Center(
                                child: Text(
                                  'no_data'.tr(),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              padding:
                                  EdgeInsets.symmetric(vertical: 8.h),
                              itemCount: _categories.length,
                              separatorBuilder: (_, __) => Divider(
                                  height: 1,
                                  color: Colors.grey.shade100),
                              itemBuilder: (context, i) {
                                final cat = _categories[i];
                                final isActive =
                                    _selectedCategory != null &&
                                        cat.id != null &&
                                        _selectedCategory!.id == cat.id;
                                return GestureDetector(
                                  onTap: () => _pickCategory(
                                      isActive ? null : cat),
                                  behavior: HitTestBehavior.opaque,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 13.h),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            cat.title ?? '',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: isActive
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                              color: isActive
                                                  ? primary
                                                  : const Color(
                                                      0xFF1E293B),
                                            ),
                                          ),
                                        ),
                                        if (isActive)
                                          Icon(Icons.check_rounded,
                                              size: 18.w, color: primary),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    SizedBox(
                        height:
                            MediaQuery.of(context).viewPadding.bottom +
                                8.h),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Branch callout shown when a map marker is tapped
class _BranchCallout extends StatelessWidget {
  const _BranchCallout({
    required this.branch,
    required this.onTap,
    required this.primary,
  });

  final HomBranch branch;
  final VoidCallback onTap;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final imageUrl = sanitizeImageUrl(branch.image);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.13),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Photo
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                bottomLeft: Radius.circular(16.r),
              ),
              child: SizedBox(
                width: 70.w,
                height: 70.w,
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            _fallbackBox(branch.title),
                      )
                    : _fallbackBox(branch.title),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      branch.title ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    if ((branch.address ?? '').isNotEmpty) ...[
                      4.kh,
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 12.w,
                              color: Colors.grey.shade500),
                          3.kw,
                          Expanded(
                            child: Text(
                              branch.address!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Arrow
            Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.arrow_forward_rounded,
                    size: 16.w, color: primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackBox(String? title) {
    const gradients = [
      [Color(0xFFA652C7), Color(0xFFFF7093)],
      [Color(0xFF307CE0), Color(0xFF24AE74)],
      [Color(0xFFF6B53D), Color(0xFFE6465A)],
      [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    ];
    final i = ((title?.isNotEmpty == true ? title!.codeUnitAt(0) : 65) +
            (title?.length ?? 0)) %
        gradients.length;
    return Container(
      decoration: BoxDecoration(
        gradient:
            LinearGradient(colors: gradients[i], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Icon(Icons.business_rounded,
          size: 28, color: Colors.white.withOpacity(0.7)),
    );
  }
}

class _ZoomBtn extends StatelessWidget {
  const _ZoomBtn(
      {required this.icon, required this.onTap, required this.color});
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18.w, color: color),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Classes list
// ─────────────────────────────────────────────────────────────────────────────

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
      onNotification: (n) {
        if (n is ScrollEndNotification && n.metrics.extentAfter < 300) {
          onLoadMore();
        }
        return false;
      },
      child: ListView.separated(
        padding: EdgeInsets.only(top: 8.h, bottom: 8.h + 64.0 + MediaQuery.of(context).viewPadding.bottom),
        physics: kIsWeb ? const ClampingScrollPhysics() : const BouncingScrollPhysics(),
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
            onViewAsReels: () {
              ShortsFeed.set(classes, index);
              context.tabsRouter.setActiveIndex(1);
            },
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Branches list with map header for Centres tab
// ─────────────────────────────────────────────────────────────────────────────

class _BranchesWithMap extends StatelessWidget {
  const _BranchesWithMap({
    required this.branches,
    required this.categories,
    required this.isLoadingMore,
    required this.onLoadMore,
    required this.onOpenMap,
  });

  final List<HomBranch> branches;
  final List<HomCategory> categories;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;
  final VoidCallback onOpenMap;

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n is ScrollEndNotification && n.metrics.extentAfter < 300) {
          onLoadMore();
        }
        return false;
      },
      child: CustomScrollView(
        physics: kIsWeb ? const ClampingScrollPhysics() : const BouncingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          // Map preview header
          // SliverToBoxAdapter(
          //   child: Padding(
          //     padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
          //     child: GestureDetector(
          //       onTap: onOpenMap,
          //       child: Container(
          //         height: 160.h,
          //         decoration: BoxDecoration(
          //           borderRadius: BorderRadius.circular(16.r),
          //           color: const Color(0xFFE8EFF9),
          //           boxShadow: [
          //             BoxShadow(
          //               color: primary.withOpacity(0.08),
          //               blurRadius: 12,
          //               offset: const Offset(0, 4),
          //             ),
          //           ],
          //         ),
          //         child: ClipRRect(
          //           borderRadius: BorderRadius.circular(16.r),
          //           child: Stack(
          //             children: [
          //               // Static map background image
          //               Positioned.fill(
          //                 child: Image.network(
          //                   'https://a.basemaps.cartocdn.com/rastertiles/voyager/12/2494/1423.png',
          //                   fit: BoxFit.cover,
          //                   errorBuilder: (_, __, ___) => Container(
          //                     color: const Color(0xFFE8EFF9),
          //                   ),
          //                 ),
          //               ),
          //               // Overlay
          //               Positioned.fill(
          //                 child: Container(
          //                   decoration: BoxDecoration(
          //                     gradient: LinearGradient(
          //                       begin: Alignment.topCenter,
          //                       end: Alignment.bottomCenter,
          //                       colors: [
          //                         Colors.black.withOpacity(0.1),
          //                         Colors.black.withOpacity(0.35),
          //                       ],
          //                     ),
          //                   ),
          //                 ),
          //               ),
          //               // Tap to open label
          //               Center(
          //                 child: Container(
          //                   padding: EdgeInsets.symmetric(
          //                       horizontal: 18.w, vertical: 10.h),
          //                   decoration: BoxDecoration(
          //                     color: Colors.white,
          //                     borderRadius: BorderRadius.circular(24.r),
          //                     boxShadow: [
          //                       BoxShadow(
          //                         color: Colors.black.withOpacity(0.12),
          //                         blurRadius: 8,
          //                         offset: const Offset(0, 2),
          //                       ),
          //                     ],
          //                   ),
          //                   child: Row(
          //                     mainAxisSize: MainAxisSize.min,
          //                     children: [
          //                       Icon(Icons.map_rounded,
          //                           size: 16.w, color: primary),
          //                       6.kw,
          //                       'open_in_map'
          //                           .tr()
          //                           .s(13)
          //                           .w(700)
          //                           .c(primary),
          //                     ],
          //                   ),
          //                 ),
          //               ),
          //               // Branch count badge
          //               if (branches.isNotEmpty)
          //                 Positioned(
          //                   top: 10.h,
          //                   right: 10.w,
          //                   child: Container(
          //                     padding: EdgeInsets.symmetric(
          //                         horizontal: 8.w, vertical: 4.h),
          //                     decoration: BoxDecoration(
          //                       color: Colors.white,
          //                       borderRadius: BorderRadius.circular(10.r),
          //                     ),
          //                     child: Row(
          //                       mainAxisSize: MainAxisSize.min,
          //                       children: [
          //                         Icon(Icons.location_on_rounded,
          //                             size: 12.w, color: primary),
          //                         4.kw,
          //                         '${branches.length}'
          //                             .s(11)
          //                             .w(700)
          //                             .c(primary),
          //                       ],
          //                     ),
          //                   ),
          //                 ),
          //             ],
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),

          // Branches list
          if (branches.isEmpty)
            const SliverFillRemaining(child: EmptyView())
          else
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == branches.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return Padding(
                      padding: EdgeInsets.only(bottom: 14.h),
                      child: _BranchResultCard(branch: branches[index]),
                    );
                  },
                  childCount: branches.length + (isLoadingMore ? 1 : 0),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: SizedBox(height: 64.0 + MediaQuery.of(context).viewPadding.bottom),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Branch card for the Centers list
// ─────────────────────────────────────────────────────────────────────────────

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
    final i = ((title.isNotEmpty ? title.codeUnitAt(0) : 65) + title.length) %
        _gradients.length;
    return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: _gradients[i]);
  }

  @override
  void initState() {
    super.initState();
    _resolveImage();
  }

  Future<void> _resolveImage() async {
    // Prefer the direct image URL returned by the API
    final direct = sanitizeImageUrl(widget.branch.image);
    if (direct != null && mounted) {
      setState(() => _imageUrl = direct);
      return;
    }
    // Fallback: derive URL from branch ID when image field is absent
    final id = widget.branch.id;
    if (id != null && widget.branch.hasPhoto == true && mounted) {
      setState(() => _imageUrl = PhotoService.getImageUrl(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final branch = widget.branch;
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
                            decoration: BoxDecoration(
                                gradient: _fallbackGradient()));
                      },
                    )
                  : Container(
                      decoration:
                          BoxDecoration(gradient: _fallbackGradient()),
                      child: Center(
                        child: Icon(Icons.business_rounded,
                            size: 40.w,
                            color: Colors.white.withOpacity(0.5)),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(6.w, 10.h, 6.w, 4.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                (branch.title ?? '')
                    .s(16)
                    .w(700)
                    .c(const Color(0xFF1E293B)),
                if ((branch.description ?? '').isNotEmpty) ...[
                  4.kh,
                  Text(
                    branch.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 11.sp,
                        color: const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w400),
                  ),
                ],
                8.kh,
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 14.w,
                              color: const Color(0xFF312E81)
                                  .withOpacity(0.9)),
                          4.kw,
                          Expanded(
                            child: Text(
                              branch.address ??
                                  'location_not_specified'.tr(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF312E81)
                                    .withOpacity(0.9),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if ((branch.distance ?? 0) > 0) ...[
                      12.kw,
                      _distanceChip(branch.distance!),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _distanceChip(double meters) {
    final label = meters < 1000
        ? '${meters.round()} m'
        : '${(meters / 1000).round()} km';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.navigation_outlined,
            size: 12.w,
            color: const Color(0xFF312E81).withOpacity(0.9)),
        4.kw,
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF312E81).withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared UI helpers
// ─────────────────────────────────────────────────────────────────────────────

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
          padding:  EdgeInsets.all(12).copyWith(top: 8, bottom: 8),
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
                child: Text('$count',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.black)),
              ),
            ),
          ),
      ],
    );
  }
}

class _FilterBadges extends StatelessWidget {
  const _FilterBadges({required this.filter, required this.onClearFilter});
  final FilterResult filter;
  final VoidCallback onClearFilter;

  @override
  Widget build(BuildContext context) {
    final badges = <Widget>[];

    if (filter.datePreset != DatePreset.none) {
      String label;
      if (filter.datePreset == DatePreset.custom && filter.fromDate != null) {
        final from = '${filter.fromDate!.day}.${filter.fromDate!.month}';
        final to = filter.toDate != null
            ? ' → ${filter.toDate!.day}.${filter.toDate!.month}'
            : '';
        label = 'Date: $from$to';
      } else {
        label = {
          DatePreset.none: '',
          DatePreset.today: 'today'.tr(),
          DatePreset.tomorrow: 'tomorrow'.tr(),
          DatePreset.thisWeek: 'this_week'.tr(),
          DatePreset.custom: 'custom'.tr(),
        }[filter.datePreset]!;
      }
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
      final fmtPrice = (int v) => v
          .toString()
          .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ' ');
      badges.add(_BadgeChip(
          text:
              '${fmtPrice(filter.priceRange.start.toInt())}–${fmtPrice(filter.priceRange.end.toInt())} so\'m',
          color: const Color(0xFFF97316),
          onRemove: onClearFilter));
    }

    if (badges.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 8, runSpacing: 6, children: badges);
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip(
      {required this.text, required this.color, required this.onRemove});
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
              child: Icon(Icons.close, size: 14, color: color)),
        ],
      ),
    );
  }
}

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

class _SegmentedButton extends StatelessWidget {
  const _SegmentedButton(
      {required this.text, required this.selected, required this.onTap});
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
                        borderRadius: BorderRadius.circular(12.r))),
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
