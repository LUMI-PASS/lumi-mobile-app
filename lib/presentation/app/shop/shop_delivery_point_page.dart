import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/user_location.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/common/widget/app_text_field.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

/// Where a delivery is going, as a pin plus a written address.
///
/// The pin is picked by moving the MAP under a fixed marker rather than by
/// tapping a spot: one thumb, no mis-taps, and the target is always dead centre
/// where the finger is not covering it. Every delivery app in the region does
/// it this way, so it needs no explaining.
///
/// The written address is required alongside the pin and is not optional
/// politeness: a pin is not something a courier can ring the doorbell of. The
/// flat number was never on the map.
class DeliveryPointResult {
  const DeliveryPointResult({
    required this.lat,
    required this.lng,
    required this.address,
  });

  final double lat;
  final double lng;
  final String address;
}

@RoutePage()
class ShopDeliveryPointPage extends StatefulWidget {
  const ShopDeliveryPointPage({
    super.key,
    this.initialLat,
    this.initialLng,
    this.initialAddress,
  });

  /// Where to open the map. Absent on a first delivery — the map then starts
  /// on the device's position, falling back to the centre of Tashkent.
  final double? initialLat;
  final double? initialLng;
  final String? initialAddress;

  @override
  State<ShopDeliveryPointPage> createState() => _ShopDeliveryPointPageState();
}

class _ShopDeliveryPointPageState extends State<ShopDeliveryPointPage> {
  YandexMapController? _controller;

  /// The "ask once" bookkeeping is the resolver's caller's job — it lives in
  /// storage, shared with the home feed, so granting or refusing on one screen
  /// is remembered by the other.
  late final _location = UserLocationResolver(
    hasAsked: () async => getIt<Storage>().locationAsked() == true,
    markAsked: () => getIt<Storage>().locationAsked.set(true),
  );
  late final TextEditingController _address =
      TextEditingController(text: widget.initialAddress ?? '');

  late double _lat = widget.initialLat ?? kTashkentCentre.lat;
  late double _lng = widget.initialLng ?? kTashkentCentre.lng;

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  Future<void> _onMapCreated(YandexMapController controller) async {
    _controller = controller;
    // Only hunt for the device when the caller has no pin to restore. Moving
    // the camera off a saved address would quietly lose the buyer's choice.
    if (widget.initialLat == null || widget.initialLng == null) {
      final location = await _location.resolve(prompt: true);
      if (!mounted) return;
      _lat = location.lat;
      _lng = location.lng;
    }
    await controller.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(latitude: _lat, longitude: _lng),
          zoom: 16,
        ),
      ),
    );
  }

  /// Tracks the centre as the map moves. Only the settled position is kept —
  /// storing every intermediate frame would be noise, and the pin is only
  /// meaningful once the buyer stops dragging.
  void _onCameraChanged(
    CameraPosition position,
    CameraUpdateReason reason,
    bool finished,
  ) {
    if (!finished) return;
    setState(() {
      _lat = position.target.latitude;
      _lng = position.target.longitude;
    });
  }

  Future<void> _goToMe() async {
    final location = await _location.resolve(prompt: true);
    await _controller?.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(latitude: location.lat, longitude: location.lng),
          zoom: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final canSave = _address.text.trim().length >= 5;

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: BaseAppBar(title: 'shop_delivery_point'.tr()),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                YandexMap(
                  onMapCreated: _onMapCreated,
                  onCameraPositionChanged: _onCameraChanged,
                ),
                // The fixed marker. Nudged up by half its height so its POINT
                // sits on the centre of the map rather than its middle.
                Padding(
                  padding: EdgeInsets.only(bottom: 36.h),
                  child: Icon(
                    Icons.location_on,
                    size: 40.w,
                    color: AppColors.brandPurple,
                  ),
                ),
                Positioned(
                  right: 16.w,
                  bottom: 16.h,
                  child: FloatingActionButton.small(
                    heroTag: 'shop_my_location',
                    backgroundColor: c.surface,
                    onPressed: _goToMe,
                    child: Icon(Icons.my_location, color: c.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
            color: c.surface,
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'shop_address_label'.tr(),
                    style:
                        AppText.semibold14.copyWith(color: c.textPrimary),
                  ),
                  4.kh,
                  Text(
                    'shop_address_hint'.tr(),
                    style: AppText.regular12
                        .copyWith(color: c.textSecondary),
                  ),
                  12.kh,
                  AppTextField(
                    controller: _address,
                    placeholder: 'shop_address_placeholder'.tr(),
                    maxLines: 3,
                    minLines: 1,
                    onChanged: (_) => setState(() {}),
                  ),
                  16.kh,
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: canSave
                          ? () => context.router.maybePop(
                                DeliveryPointResult(
                                  lat: _lat,
                                  lng: _lng,
                                  address: _address.text.trim(),
                                ),
                              )
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandPurple,
                        disabledBackgroundColor: c.disabled,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        'shop_save_address'.tr(),
                        style: AppText.semibold16
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                  12.kh,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
