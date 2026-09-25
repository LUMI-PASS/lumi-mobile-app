import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/data/storage/install_id.dart';
import 'package:lumi_pass/data/storage/storage.dart';

/// Header the referral endpoints read as a fraud signal (stored hashed).
const kDeviceIdHeader = 'X-Device-Id';

/// `mobile-api.lumipass.uz/api/referrals/*` — the customer referral programme.
///
/// Every call carries `X-Device-Id` (the install id). Per call rather than an
/// interceptor, because no other endpoint wants it and a path-scoped
/// interceptor would be one more place for a rename to silently break it.
@injectable
class ReferralsApi {
  ReferralsApi(this._dio, this._storage);

  final Dio _dio;
  final Storage _storage;

  Options get _options =>
      Options(headers: {kDeviceIdHeader: installIdOf(_storage)});

  /// The signed-in user's code, share text, stats, invitees and vouchers.
  Future<Response> getMe() => _dio.get('referrals/me', options: _options);

  /// Whether [code] exists, and whose it is. The server normalises case,
  /// spaces, dashes and a missing `LUMI` prefix.
  ///
  /// Needs the Bearer token (401 without — which AuthInterceptor turns into a
  /// sign-out), so call it only with a session.
  Future<Response> lookup(String code) => _dio.get(
        'referrals/lookup/${Uri.encodeComponent(code)}',
        options: _options,
      );

  /// Attach this account to a referrer. [source] is `LINK` or `MANUAL`.
  Future<Response> apply({required String code, required String source}) =>
      _dio.post(
        'referrals/apply',
        data: {'code': code, 'source': source},
        options: _options,
      );

  /// Unspent vouchers. With [subtotal], each carries `applicable`, `reason`
  /// and `preview_discount` for that order.
  Future<Response> getVouchers({num? subtotal, String? activityId}) =>
      _dio.get(
        'referrals/vouchers',
        queryParameters: {
          if (subtotal != null) 'subtotal': subtotal.round(),
          if (activityId != null && activityId.isNotEmpty)
            'activity_id': activityId,
        },
        options: _options,
      );

  /// Fire-and-forget analytics: `shared` or `link_opened`.
  Future<Response> logEvent({
    required String type,
    String? channel,
    String? code,
  }) =>
      _dio.post(
        'referrals/events',
        data: {
          'type': type,
          if (channel != null && channel.isNotEmpty) 'channel': channel,
          if (code != null && code.isNotEmpty) 'code': code,
        },
        options: _options,
      );
}
