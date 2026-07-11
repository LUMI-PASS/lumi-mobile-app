import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/image_url.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/service/photo_service.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/cubit/search_cubit.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/cubit/search_state.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/search_widgets.dart';

/// "На карте" — the centres of the current search plotted on a map (Figma
/// `На карте`).
///
/// Each centre is a labelled pill; tapping one drops a pin and raises its card
/// at the bottom. The category chips along the bottom re-query, which is why
/// this screen carries its own [SearchCubit] rather than a frozen list.
@RoutePage()
class BranchesMapPage
    extends BasePage<SearchCubit, SearchBuildable, SearchListenable> {
  const BranchesMapPage({
    super.key,
    this.branches = const [],
    this.categories = const [],
    this.selectedCategory,
  });

  /// Results already loaded by the search screen — shown immediately so the
  /// map isn't empty while the branches tab loads.
  final List<HomBranch> branches;
  final List<HomCategory> categories;
  final HomCategory? selectedCategory;

  @override
  void init(BuildContext context) {
    context.read<SearchCubit>().init(tab: 1, category: selectedCategory);
    super.init(context);
  }

  @override
  Widget builder(BuildContext context, SearchBuildable state) {
    final categories =
        state.categories.isEmpty ? this.categories : state.categories;

    return _BranchesMapView(
      branches: state.branches,
      branchesLoaded: state.branchesLoaded,
      isLoading: state.isLoading,
      seed: branches,
      categories: categories,
      selectedCategory: state.selectedCategory,
    );
  }
}

class _BranchesMapView extends StatefulWidget {
  const _BranchesMapView({
    required this.branches,
    required this.branchesLoaded,
    required this.isLoading,
    required this.seed,
    required this.categories,
    required this.selectedCategory,
  });

  final List<HomBranch> branches;
  final bool branchesLoaded;
  final bool isLoading;

  /// What the search screen already had loaded. It stands in only until this
  /// screen's own first fetch lands — after that it is stale (it predates any
  /// category the user picks here), so it must never be shown again.
  final List<HomBranch> seed;

  final List<HomCategory> categories;
  final HomCategory? selectedCategory;

  @override
  State<_BranchesMapView> createState() => _BranchesMapViewState();
}

class _BranchesMapViewState extends State<_BranchesMapView> {
  final _mapController = MapController();

  HomBranch? _selected;
  bool _mapReady = false;

  /// Flips once this screen's own fetch has landed. Until then the seed from
  /// the search screen stands in; after it, the seed is stale and the cubit is
  /// the only source — otherwise picking a category would flash the original
  /// unfiltered centres back onto the map mid-refresh.
  bool _everLoaded = false;

  /// Tashkent — where the app operates. Used as the fallback camera and to
  /// drop branches the backend gave bad coordinates for.
  static const _defaultCenter = LatLng(41.3111, 69.2797);
  static const _minLat = 41.15;
  static const _maxLat = 41.45;
  static const _minLng = 69.05;
  static const _maxLng = 69.50;

  /// CartoDB raster basemaps — the same provider the app already used, in the
  /// variant that matches the active theme.
  static const _darkTiles =
      'https://cartodb-basemaps-a.global.ssl.fastly.net/dark_all/{z}/{x}/{y}@2x.png';
  static const _lightTiles =
      'https://cartodb-basemaps-a.global.ssl.fastly.net/rastertiles/voyager/{z}/{x}/{y}@2x.png';

  /// The centres this screen should be showing right now.
  List<HomBranch> get _source {
    if (widget.branchesLoaded) return widget.branches;
    return _everLoaded ? widget.branches : widget.seed;
  }

  List<HomBranch> get _plottable => _source.where((b) {
        final lat = b.latitude;
        final lng = b.longitude;
        if (lat == null || lng == null) return false;
        return lat >= _minLat &&
            lat <= _maxLat &&
            lng >= _minLng &&
            lng <= _maxLng;
      }).toList();

  @override
  void didUpdateWidget(covariant _BranchesMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.branchesLoaded) _everLoaded = true;
    if (oldWidget.branches != widget.branches) {
      // A new result set (category changed) invalidates the selection.
      _selected = null;
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitToBranches());
    }
  }

  void _onMapReady() {
    _mapReady = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _fitToBranches());
  }

  void _fitToBranches() {
    if (!_mapReady || !mounted) return;
    final points =
        _plottable.map((b) => LatLng(b.latitude!, b.longitude!)).toList();

    if (points.isEmpty) {
      _mapController.move(_defaultCenter, 12);
      return;
    }
    if (points.length == 1) {
      _mapController.move(points.first, 15);
      return;
    }
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: EdgeInsets.all(56.w),
        maxZoom: 15,
      ),
    );
  }

  void _select(HomBranch branch) {
    setState(() => _selected = branch);
    final zoom = _mapController.camera.zoom;
    _mapController.move(
      LatLng(branch.latitude!, branch.longitude!),
      zoom < 15 ? 15 : zoom,
    );
  }

  void _selectCategory(int index) {
    final category = widget.categories[index];
    final cubit = context.read<SearchCubit>();
    // Tapping the active chip clears the filter.
    final isActive = widget.selectedCategory?.id == category.id;
    cubit.selectCategory(isActive ? null : category);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final branches = _plottable;
    final selected = _selected;
    final activeIndex = widget.categories
        .indexWhere((cat) => cat.id == widget.selectedCategory?.id);

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            8.verticalSpace,
            SearchTopBar(
              title: 'map_title'.tr(),
              onBack: () => context.router.maybePop(),
            ),
            12.verticalSpace,
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _defaultCenter,
                          initialZoom: 12,
                          onMapReady: _onMapReady,
                          onTap: (_, __) => setState(() => _selected = null),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: c.isDark ? _darkTiles : _lightTiles,
                            userAgentPackageName: 'com.lumi.pass',
                            maxZoom: 19,
                            retinaMode: true,
                          ),
                          MarkerLayer(
                            markers: [
                              for (final branch in branches)
                                if (branch.id == selected?.id)
                                  Marker(
                                    point: LatLng(
                                        branch.latitude!, branch.longitude!),
                                    width: 40.w,
                                    height: 40.w,
                                    alignment: Alignment.topCenter,
                                    child: const _SelectedPin(),
                                  )
                                else
                                  Marker(
                                    point: LatLng(
                                        branch.latitude!, branch.longitude!),
                                    width: 160.w,
                                    height: 28.h,
                                    alignment: Alignment.centerLeft,
                                    child: _BranchLabel(
                                      title: branch.title ?? '',
                                      onTap: () => _select(branch),
                                    ),
                                  ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (widget.isLoading && branches.isEmpty)
                    const Center(child: CircularProgressIndicator()),
                  // Category chips float over the bottom of the map.
                  if (widget.categories.isNotEmpty && selected == null)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: MediaQuery.of(context).padding.bottom + 16.h,
                      child: SearchChips(
                        labels: [
                          for (final cat in widget.categories) cat.title ?? '',
                        ],
                        activeIndex: activeIndex,
                        onSelect: _selectCategory,
                      ),
                    ),
                  if (selected != null)
                    Positioned(
                      left: 8.w,
                      right: 8.w,
                      bottom: MediaQuery.of(context).padding.bottom + 16.h,
                      child: _BranchCard(branch: selected),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Unselected marker — a labelled pill (Figma `Tag`). The grey pill and its
/// white label are theme-invariant by design: they sit on the map, not on the
/// page.
class _BranchLabel extends StatelessWidget {
  const _BranchLabel({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.fromLTRB(2.w, 2.h, 10.w, 2.h),
          decoration: BoxDecoration(
            color: AppColors.chipGrey,
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 11.5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24.w,
                height: 24.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.link,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Assets.icons.home.building.svg(
                  width: 16.w,
                  height: 16.w,
                  colorFilter: const ColorFilter.mode(
                    AppColors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              4.horizontalSpace,
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.semibold12.copyWith(color: AppColors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Selected marker — the purple pin (Figma `iconsax-location-mark`).
class _SelectedPin extends StatelessWidget {
  const _SelectedPin();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.link,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.link.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Assets.icons.location.svg(
        width: 22.w,
        height: 22.w,
        colorFilter: const ColorFilter.mode(
          AppColors.white,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

/// The raised card for the selected centre (Figma `Avatar` at the bottom).
class _BranchCard extends StatelessWidget {
  const _BranchCard({required this.branch});

  final HomBranch branch;

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
    final address = branch.address ?? '';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.router.push(BranchDetailRoute(branch: branch)),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: c.controlBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: SizedBox(
                width: 45.w,
                height: 45.w,
                child: imageUrl == null
                    ? Container(
                        color: c.control,
                        child: Icon(Icons.business_rounded,
                            size: 20.w, color: c.textPlaceholder),
                      )
                    : CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          color: c.control,
                          child: Icon(Icons.business_rounded,
                              size: 20.w, color: c.textPlaceholder),
                        ),
                      ),
              ),
            ),
            12.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    branch.title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.semibold16.copyWith(color: c.textPrimary),
                  ),
                  if (address.isNotEmpty) ...[
                    6.verticalSpace,
                    Text(
                      address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          AppText.regular12.copyWith(color: c.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
