import 'dart:async';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/common/router/deep_link_log.dart';
import 'package:lumi_pass/data/api_model/socials/centre_socials.dart';
import 'package:lumi_pass/data/service/interest_source.dart';
import 'package:lumi_pass/data/storage/install_id.dart';
import 'package:lumi_pass/data/storage/storage.dart';

/// Header the backend counts a GUEST once by, on the course and class detail
/// requests (`X-Lumi-Device`). Per call, like the referral endpoints' own
/// device header — only those two requests want it.
const kListingDeviceHeader = 'X-Lumi-Device';

/// The install id as that header, for `getClassFull` and `CoursesApi.detail`.
Map<String, String> listingDeviceHeader(Storage storage) =>
    {kListingDeviceHeader: installIdOf(storage)};

/// A tap on a course or activity that leaves the app. Must match the backend's
/// `CLIENT_LISTING_ACTIONS`; opens and booking sheets are counted server-side.
enum ListingAction {
  socialClick('social_click'),
  callClick('call_click'),
  shareClick('share_click'),
  routeClick('route_click');

  const ListingAction(this.key);

  /// The wire value.
  final String key;
}

/// Reports taps that leave the app — the centre's Instagram or Telegram, the
/// dialler, the share sheet, the route — to `POST /api/listing-events`, for
/// the centre's statistics in the partner panel.
///
/// Fire-and-forget, like [BannerClickReporter]: [report] returns at once and
/// swallows every error. The tap's real job is to open the link, and counting
/// it must never delay that, fail it, or stop it when the network is down.
/// Unlike [InterestReporter] there is no queue: a guest's tap counts as well
/// (by install id), so nothing has to wait for a sign-in.
@lazySingleton
class ListingEventReporter {
  ListingEventReporter(this._dio, this._storage);

  final Dio _dio;
  final Storage _storage;

  /// Records one tap on [activityId]. Never awaited by callers; never throws.
  void report(
    String? activityId,
    ListingAction action, {
    SocialNetwork? network,
  }) {
    final id = (activityId ?? '').trim();
    if (id.isEmpty) return;
    unawaited(_send(id, action, network));
  }

  Future<void> _send(
    String id,
    ListingAction action,
    SocialNetwork? network,
  ) async {
    try {
      final source = InterestSourceTracker.instance.current;
      await _dio.post(
        'listing-events',
        data: {
          'device_id': installIdOf(_storage),
          'events': [
            {
              'action': action.key,
              'activity_id': id,
              if (network != null) 'network': network.key,
              if (source != null) 'source': source,
            },
          ],
        },
      );
      dlog('listing: ${action.key} recorded for $id');
    } catch (e) {
      // Includes the throttle's 429. A dropped tap is a rounding error in a
      // centre's report; a crashed tap is a broken app.
      dlog('listing: ${action.key} NOT recorded for $id: $e');
    }
  }
}
