import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';

class ExploreMapSheet extends StatefulWidget {
  const ExploreMapSheet({super.key, required this.branches});
  final List<HomBranch> branches;

  static Future<void> show(BuildContext context, List<HomBranch> branches) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExploreMapSheet(branches: branches),
    );
  }

  @override
  State<ExploreMapSheet> createState() => _ExploreMapSheetState();
}

class _ExploreMapSheetState extends State<ExploreMapSheet> {
  final MapController _mapController = MapController();
  LatLng? _userLocation;
  String? _focusedBranchId;
  final ScrollController _listCtrl = ScrollController();
  bool _mapReady = false;

  // Tashkent bounding box — filter out any bad coordinates
  static const _tashkentMinLat = 41.15;
  static const _tashkentMaxLat = 41.45;
  static const _tashkentMinLng = 69.05;
  static const _tashkentMaxLng = 69.50;
  static const _defaultCenter = LatLng(41.3111, 69.2797);

  late final List<HomBranch> _validBranches;

  @override
  void initState() {
    super.initState();
    // Filter: must have coordinates AND be in Tashkent area
    _validBranches = widget.branches.where((b) {
      if (b.latitude == null || b.longitude == null) return false;
      return b.latitude! >= _tashkentMinLat &&
          b.latitude! <= _tashkentMaxLat &&
          b.longitude! >= _tashkentMinLng &&
          b.longitude! <= _tashkentMaxLng;
    }).toList();
    _getUserLocation();
  }

  @override
  void dispose() {
    _listCtrl.dispose();
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
      if (mounted) {
        setState(
            () => _userLocation = LatLng(pos.latitude, pos.longitude));
      }
    } catch (_) {}
  }

  void _onMapReady() {
    _mapReady = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _fitBranches());
  }

  void _fitBranches() {
    if (!_mapReady) return;
    final pts =
        _validBranches.map((b) => LatLng(b.latitude!, b.longitude!)).toList();
    if (pts.isEmpty) {
      _mapController.move(_defaultCenter, 12);
      return;
    }
    if (pts.length == 1) {
      _mapController.move(pts.first, 14);
      return;
    }
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(pts),
        padding: EdgeInsets.all(48.w),
        maxZoom: 14,
      ),
    );
  }

  void _focusBranch(HomBranch branch) {
    if (branch.latitude == null || branch.longitude == null) return;
    setState(() => _focusedBranchId = branch.id);

    // Pan to branch; only zoom in if currently too far out
    final current = _mapController.camera.zoom;
    _mapController.move(
      LatLng(branch.latitude!, branch.longitude!),
      current < 14 ? 14 : current,
    );

    // Scroll list to center this item
    final idx = _validBranches.indexWhere((b) => b.id == branch.id);
    if (idx >= 0 && _listCtrl.hasClients) {
      // Each item is ~100h + 8 padding
      final itemExtent = 108.h;
      final viewportH = _listCtrl.position.viewportDimension;
      final target = (idx * itemExtent) - (viewportH / 2) + (itemExtent / 2);
      _listCtrl.animateTo(
        target.clamp(0, _listCtrl.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _zoomIn() {
    if (!_mapReady) return;
    final z = _mapController.camera.zoom;
    if (z < 18) _mapController.move(_mapController.camera.center, z + 1);
  }

  void _zoomOut() {
    if (!_mapReady) return;
    final z = _mapController.camera.zoom;
    if (z > 5) _mapController.move(_mapController.camera.center, z - 1);
  }

  String _formatDistance(HomBranch branch) {
    if (_userLocation != null &&
        branch.latitude != null &&
        branch.longitude != null) {
      final m = Geolocator.distanceBetween(
        _userLocation!.latitude,
        _userLocation!.longitude,
        branch.latitude!,
        branch.longitude!,
      );
      if (m <= 0) return '';
      if (m < 1000) return '${m.round()} m';
      return '${(m / 1000).round()} km';
    }
    if (branch.distance != null && branch.distance! > 0) {
      final m = branch.distance!;
      if (m < 1000) return '${m.round()} m';
      return '${(m / 1000).round()} km';
    }
    return '';
  }

  void _openBranch(HomBranch branch) {
    Navigator.pop(context);
    context.router.push(BranchDetailRoute(branch: branch));
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
      child: Column(
        children: [
          // Drag handle
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

          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 6.h),
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
                    child: Icon(Icons.close_rounded,
                        size: 18.w, color: primary),
                  ),
                ),
                10.kw,
                'centers_on_map'.tr().s(17).w(700),
                const Spacer(),
                if (_validBranches.isNotEmpty)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: '${_validBranches.length}'
                        .s(12)
                        .w(700)
                        .c(primary),
                  ),
              ],
            ),
          ),

          // Map — fixed ~40% of sheet
          SizedBox(
            height: screenH * 0.35,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: FlutterMap(
                        mapController: _mapController,
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
                                'https://cartodb-basemaps-a.global.ssl.fastly.net/rastertiles/voyager/{z}/{x}/{y}@2x.png',
                            userAgentPackageName: 'com.lumi.pass',
                            maxZoom: 19,
                            retinaMode: true,
                          ),
                          MarkerLayer(
                            markers: _validBranches.map((branch) {
                              final focused =
                                  _focusedBranchId == branch.id;
                              return Marker(
                                point: LatLng(
                                    branch.latitude!, branch.longitude!),
                                width: focused ? 42 : 34,
                                height: focused ? 42 : 34,
                                child: GestureDetector(
                                  onTap: () => _focusBranch(branch),
                                  child: AnimatedContainer(
                                    duration: const Duration(
                                        milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: focused
                                          ? primary
                                          : Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: primary,
                                        width: focused ? 3 : 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: primary.withOpacity(
                                              focused ? 0.4 : 0.15),
                                          blurRadius:
                                              focused ? 10 : 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.location_on_rounded,
                                      size: focused ? 20 : 16,
                                      color: focused
                                          ? Colors.white
                                          : primary,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          if (_userLocation != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _userLocation!,
                                  width: 18,
                                  height: 18,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 3),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              Colors.blue.withOpacity(0.3),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Zoom +/- controls
                Positioned(
                  right: 22.w,
                  bottom: 10.h,
                  child: Column(
                    children: [
                      _ZoomButton(
                          icon: Icons.add, onTap: _zoomIn, color: primary),
                      2.kh,
                      _ZoomButton(
                          icon: Icons.remove,
                          onTap: _zoomOut,
                          color: primary),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // List header
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 4.h),
            child: Row(
              children: [
                Icon(Icons.list_rounded,
                    size: 16.w, color: Colors.grey.shade500),
                6.kw,
                'Centers'.s(13).w(600).c(Colors.grey.shade600),
              ],
            ),
          ),

          // Branch list — takes remaining space
          Expanded(
            child: _validBranches.isEmpty
                ? Center(
                    child: 'no_centers_location'
                        .tr()
                        .s(14)
                        .w(500)
                        .c(Colors.grey.shade400),
                  )
                : ListView.builder(
                    controller: _listCtrl,
                    padding: EdgeInsets.fromLTRB(
                      12.w,
                      4.h,
                      12.w,
                      MediaQuery.of(context).viewPadding.bottom + 8.h,
                    ),
                    itemCount: _validBranches.length,
                    itemBuilder: (context, index) {
                      final branch = _validBranches[index];
                      final focused = _focusedBranchId == branch.id;
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: _BranchListItem(
                          branch: branch,
                          isFocused: focused,
                          distance: _formatDistance(branch),
                          onTap: () => _focusBranch(branch),
                          onOpenBranch: () => _openBranch(branch),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _BranchListItem extends StatelessWidget {
  const _BranchListItem({
    required this.branch,
    required this.isFocused,
    required this.distance,
    required this.onTap,
    required this.onOpenBranch,
  });

  final HomBranch branch;
  final bool isFocused;
  final String distance;
  final VoidCallback onTap;
  final VoidCallback onOpenBranch;

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isFocused ? primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isFocused ? primary : Colors.grey.shade200,
            width: isFocused ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.location_on_rounded,
                  size: 16.w, color: primary),
            ),
            10.kw,
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    branch.title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  if (branch.address != null &&
                      branch.address!.isNotEmpty) ...[
                    3.kh,
                    Text(
                      branch.address!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            8.kw,
            // Right column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (distance.isNotEmpty)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.navigation_rounded,
                            size: 9.w, color: const Color(0xFF4338CA)),
                        3.kw,
                        distance.s(10).w(700).c(const Color(0xFF312E81)),
                      ],
                    ),
                  ),
                6.kh,
                GestureDetector(
                  onTap: onOpenBranch,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: context.colors.primary,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: 'Open'.s(10).w(600).c(Colors.white),
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

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

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
