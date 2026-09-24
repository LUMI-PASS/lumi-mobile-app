import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/data/api_model/referral/referral_enums.dart';
import 'package:lumi_pass/data/api_model/referral/referral_models.dart';
import 'package:lumi_pass/domain/repo/referrals/referral_repository.dart';
import 'package:lumi_pass/presentation/app/profile/referral/widgets/referral_code_lookup.dart';

class _FakeRepo implements ReferralRepository {
  final lookups = <String>[];

  @override
  Future<ReferralLookup?> lookup(String code) async {
    lookups.add(code);
    return ReferralLookup(valid: true, code: code, referrerFirstName: 'Aziza');
  }

  @override
  Future<ReferralMe> getMe() => throw UnimplementedError();

  @override
  Future<ReferralApplyOutcome> apply(
    String code, {
    required ReferralApplySource source,
  }) =>
      throw UnimplementedError();

  @override
  Future<List<ReferralVoucher>> getVouchers({
    num? subtotal,
    String? activityId,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> logEvent(
    ReferralEventType type, {
    String? channel,
    String? code,
  }) =>
      throw UnimplementedError();
}

/// `referrals/lookup` needs a session, and a 401 signs the user out — so the
/// "Invited by …" hint must never call it without one.
void main() {
  const settle = Duration(milliseconds: 600);

  test('signed out: never looks anything up', () async {
    final repo = _FakeRepo();
    final lookup = ReferralCodeLookup(repo: repo, isSignedIn: () => false);
    lookup.onChanged('LUMI7K3Q');
    await Future<void>.delayed(settle);
    expect(repo.lookups, isEmpty);
    expect(lookup.result, isNull);
    lookup.dispose();
  });

  test('signed in: one debounced lookup of the normalised code', () async {
    final repo = _FakeRepo();
    final lookup = ReferralCodeLookup(repo: repo, isSignedIn: () => true);
    lookup
      ..onChanged('l')
      ..onChanged('lu')
      ..onChanged('lumi 7k3q');
    await Future<void>.delayed(settle);
    expect(repo.lookups, ['LUMI7K3Q']);
    expect(lookup.result?.referrerFirstName, 'Aziza');
    lookup.dispose();
  });

  test('clearing the field clears the hint and looks nothing up', () async {
    final repo = _FakeRepo();
    final lookup = ReferralCodeLookup(repo: repo, isSignedIn: () => true);
    lookup.onChanged('   ');
    await Future<void>.delayed(settle);
    expect(repo.lookups, isEmpty);
    lookup.dispose();
  });
}
