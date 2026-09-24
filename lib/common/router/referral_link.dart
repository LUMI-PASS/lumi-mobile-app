import 'package:lumi_pass/common/router/deep_link_routes.dart';

/// Referral codes as the app handles them before the server sees them.
abstract final class ReferralCodes {
  const ReferralCodes._();

  /// Longest code we bother storing. Real codes are ~8 characters; anything
  /// much longer is a mangled link, not a code.
  static const maxLength = 32;

  static final _allowed = RegExp(r'^[A-Z0-9_-]+$');

  /// Uppercased, every space removed; null when nothing usable is left.
  ///
  /// Deliberately light: the server does the real normalisation (dashes, a
  /// missing `LUMI` prefix). This only makes " lumi 7k3q " and "LUMI7K3Q" the
  /// same string on the device, and keeps junk out of storage.
  static String? normalize(String? raw) {
    if (raw == null) return null;
    final code = raw.replaceAll(RegExp(r'\s+'), '').toUpperCase();
    if (code.isEmpty || code.length > maxLength) return null;
    if (!_allowed.hasMatch(code)) return null;
    return code;
  }
}

/// A link recognised as a referral invite. [code] is null for a bare
/// `lumi://referral`, which is a destination (the referral screen), not an
/// invite.
class ReferralLink {
  const ReferralLink(this.code);

  final String? code;

  @override
  String toString() => 'ReferralLink(${code ?? "no code"})';
}

/// Recognises every shape an invite arrives in:
///
///   lumi://referral?code=LUMI7K3Q               custom scheme
///   lumi://referral/LUMI7K3Q                    same, id-in-path form
///   https://app.lumipass.uz/r/LUMI7K3Q          web fallback (`af_web_dp`)
///   https://link.lumipass.uz/JBWe?deep_link_value=referral&deep_link_sub1=…
///                                               the OneLink itself, when the
///                                               OS hands us the raw URL
///   lumi://referral                             no code: open the screen
///
/// An invite is NOT a destination. Its code is stored (and applied when the
/// user is signed in) and nothing is pushed — see [classifyLink].
abstract final class ReferralLinks {
  const ReferralLinks._();

  /// The registry key and the scheme host.
  static const key = 'referral';

  /// The web fallback path: `https://app.lumipass.uz/r/<code>`.
  static const webPath = 'r';

  /// The OneLink's `deep_link_value` for an invite.
  static const deepLinkValue = key;

  /// The canonical in-app form of an invite (or of the bare screen).
  static Uri uri([String? code]) {
    final c = ReferralCodes.normalize(code);
    return c == null
        ? Uri.parse('lumi://$key')
        : Uri(scheme: 'lumi', host: key, queryParameters: {'code': c});
  }

  /// The code carried by the OneLink parameters, in the order AppsFlyer and
  /// our own link builder put it there.
  static String? codeFromParams(String? Function(String name) param) =>
      ReferralCodes.normalize(
        param('deep_link_sub1') ?? param('af_sub1') ?? param('code'),
      );

  /// Null when [uri] is not a referral link at all.
  static ReferralLink? parse(Uri uri) {
    final segments = [
      for (final s in uri.pathSegments)
        if (s.trim().isNotEmpty) s.trim(),
    ];
    String? q(String name) {
      final v = uri.queryParameters[name];
      return (v == null || v.trim().isEmpty) ? null : v;
    }

    if (uri.scheme != 'http' && uri.scheme != 'https') {
      // lumi://referral?code=X  /  lumi://referral/X
      if (uri.host.toLowerCase() != key) return null;
      final code = q('code') ??
          (segments.isNotEmpty ? segments.first : null) ??
          q('deep_link_sub1') ??
          q('af_sub1');
      return ReferralLink(ReferralCodes.normalize(code));
    }

    if (!DeepLinkRoutes.appHosts.contains(uri.host.toLowerCase())) return null;

    // The raw OneLink: `deep_link_value=referral` rides in the query of
    // whatever path the template uses (`/JBWe`).
    if (q('deep_link_value')?.toLowerCase() == deepLinkValue) {
      return ReferralLink(codeFromParams(q));
    }

    // https://app.lumipass.uz/r/<code>
    if (segments.isNotEmpty && segments.first.toLowerCase() == webPath) {
      final code = segments.length > 1 ? segments[1] : q('code');
      return ReferralLink(ReferralCodes.normalize(code));
    }

    // https://<our-host>[/share]/referral[/<code>] — the registry's own shape.
    final i = segments.indexOf(DeepLinkRoutes.sharePrefix);
    final after = i == -1 ? segments : segments.skip(i + 1).toList();
    if (after.isNotEmpty && after.first.toLowerCase() == key) {
      final code = after.length > 1 ? after[1] : q('code');
      return ReferralLink(ReferralCodes.normalize(code));
    }
    return null;
  }
}

/// What an incoming link asks the app to do.
sealed class LinkIntent {
  const LinkIntent();
}

/// An invite: remember the code, apply it when possible, navigate nowhere.
final class StoreReferralCode extends LinkIntent {
  const StoreReferralCode(this.code);
  final String code;

  @override
  String toString() => 'StoreReferralCode($code)';
}

/// A destination in the [DeepLinkRoutes] registry.
final class OpenDestination extends LinkIntent {
  const OpenDestination(this.target);
  final DeepLinkTarget target;

  @override
  String toString() => 'OpenDestination($target)';
}

/// Nothing this build handles.
final class IgnoreLink extends LinkIntent {
  const IgnoreLink();

  @override
  String toString() => 'IgnoreLink';
}

/// Decides between storing an invite and opening a screen.
///
/// Referral links are checked FIRST, so a code can never be mistaken for a
/// destination — `lumi://referral?code=PLANS` stores `PLANS`, it does not open
/// the plans screen. A referral link without a usable code is the referral
/// screen itself.
LinkIntent classifyLink(Uri uri) {
  final referral = ReferralLinks.parse(uri);
  if (referral != null) {
    final code = referral.code;
    if (code != null) return StoreReferralCode(code);
    return const OpenDestination(DeepLinkTarget(ReferralLinks.key, {}));
  }
  final target = DeepLinkRoutes.resolve(uri);
  return target == null ? const IgnoreLink() : OpenDestination(target);
}
