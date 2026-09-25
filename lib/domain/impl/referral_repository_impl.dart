import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/common/router/deep_link_log.dart';
import 'package:lumi_pass/data/api_model/referral/referral_enums.dart';
import 'package:lumi_pass/data/api_model/referral/referral_models.dart';
import 'package:lumi_pass/domain/repo/referrals/referral_repository.dart';
import 'package:lumi_pass/domain/repo/referrals/referrals_api.dart';

@Injectable(as: ReferralRepository)
class ReferralRepositoryImpl extends ReferralRepository {
  ReferralRepositoryImpl(this._api);

  final ReferralsApi _api;

  /// Every referral response is `{ data: ... }`, but unwrap defensively like
  /// the rest of the app does.
  static dynamic _payload(dynamic raw) =>
      raw is Map && raw.containsKey('data') ? raw['data'] : raw;

  static Map<String, dynamic> _object(dynamic raw) {
    final p = _payload(raw);
    return p is Map ? Map<String, dynamic>.from(p) : <String, dynamic>{};
  }

  @override
  Future<ReferralMe> getMe() async {
    final res = await _api.getMe();
    return ReferralMe.fromJson(_object(res.data));
  }

  @override
  Future<ReferralLookup?> lookup(String code) async {
    try {
      final res = await _api.lookup(code);
      return ReferralLookup.fromJson(_object(res.data));
    } on DioException catch (e) {
      // A 404/400 is an answer ("no such code"); anything else is not.
      final status = e.response?.statusCode;
      if (status == 404 || status == 400) {
        return const ReferralLookup(valid: false);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<ReferralApplyOutcome> apply(
    String code, {
    required ReferralApplySource source,
  }) async {
    try {
      final res = await _api.apply(code: code, source: source.key);
      return ReferralApplyOutcome.success(
        ReferralApplyResult.fromJson(_object(res.data)),
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      final status = e.response?.statusCode;
      var error = ReferralErrorCode.fromKey(
        data is Map ? data['error_code']?.toString() : null,
      );
      // A throttled request without a tagged body is still a throttle.
      if (error == ReferralErrorCode.unknown && status == 429) {
        error = ReferralErrorCode.tooManyAttempts;
      }
      final message = data is Map ? data['message']?.toString() : null;
      dlog('referral: apply($code, ${source.key}) refused: '
          '${error.key.isEmpty ? status : error.key}');
      return ReferralApplyOutcome.failure(error, message: message);
    } catch (e) {
      dlog('referral: apply($code) failed: $e');
      return const ReferralApplyOutcome.failure(ReferralErrorCode.unknown);
    }
  }

  @override
  Future<List<ReferralVoucher>> getVouchers({
    num? subtotal,
    String? activityId,
  }) async {
    try {
      final res =
          await _api.getVouchers(subtotal: subtotal, activityId: activityId);
      final list = _payload(res.data);
      if (list is! List) return const [];
      return list
          .whereType<Map>()
          .map((e) => ReferralVoucher.fromJson(Map<String, dynamic>.from(e)))
          .where((v) => v.code.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> logEvent(
    ReferralEventType type, {
    String? channel,
    String? code,
  }) async {
    try {
      await _api.logEvent(type: type.key, channel: channel, code: code);
    } catch (_) {
      // Analytics only — a lost event is a rounding error.
    }
  }
}
