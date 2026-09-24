import 'package:lumi_pass/common/router/deep_link_routes.dart';
import 'package:lumi_pass/common/router/referral_link.dart';

/// Turns an AppsFlyer UDL click event (`DeepLink.clickEvent`) into a URI the
/// app's own deep-link handling understands.
///
/// Pure — no SDK types — so every OneLink shape can be pinned in a unit test.
/// Handles:
///   * `deep_link_value: referral` + the code in `deep_link_sub1` / `af_sub1`
///     → `lumi://referral?code=<CODE>` (an invite, never a destination —
///     see [classifyLink]);
///   * `deep_link_value` holding a whole URI — `lumi://class/<id>` or the
///     `https://mobile-api.lumipass.uz/share/class/<id>` share link;
///   * `deep_link_value: class` plus the id in `deep_link_sub1` / `class_id`,
///     which is how the OneLink UI nudges you to model it.
Uri? appsFlyerClickEventToUri(Map<String, dynamic> clickEvent) {
  String? param(String name) {
    final v = clickEvent[name];
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  final value = param('deep_link_value') ?? param('af_dp');

  // An invite. Checked before the registry: `referral` is ALSO a registered
  // destination (the referral screen), and the generic branch below would turn
  // the code into a path id.
  if (value != null && value.toLowerCase() == ReferralLinks.deepLinkValue) {
    return ReferralLinks.uri(ReferralLinks.codeFromParams(param));
  }

  if (value != null && value.contains('://')) return Uri.tryParse(value);

  // A bare destination key plus its id in a sub-param. Checked against the
  // registry rather than a hardcoded pair, so a OneLink campaign pointing at
  // any registered screen — `branch`, `plans`, `category` — works without
  // touching this file.
  if (value != null && DeepLinkRoutes.lookup(value) != null) {
    final id =
        param('deep_link_sub1') ?? param('class_id') ?? param('af_sub1');
    return Uri.parse(
      id == null || id.isEmpty ? 'lumi://$value' : 'lumi://$value/$id',
    );
  }

  // Last resort: the raw link that was clicked. Carries the /share/class/
  // path when the OneLink simply wraps our own share URL.
  final raw = param('link');
  return raw == null ? null : Uri.tryParse(raw);
}
