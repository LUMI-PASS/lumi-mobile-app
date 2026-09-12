import 'package:lumi_pass/common/router/deep_link_log.dart';
import 'package:lumi_pass/common/router/deep_link_routes.dart';
import 'package:lumi_pass/data/service/deeplink_service.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens a link handed to us by the backend or the adminka — a banner's tap
/// target, a push payload, a share URL — and decides where it belongs.
///
/// This is the ONE entry point for "something outside the app gave us a link,
/// open it", so every channel behaves identically and a destination added to
/// [DeepLinkRoutes] works everywhere at once.
///
/// Routing, in order:
///
///   1. Anything [DeepLinkRoutes.resolve] recognises opens IN the app. That
///      covers `lumi://class/<id>` AND `https://mobile-api.lumipass.uz/share/
///      class/<id>` — the whole point of accepting both shapes is that a
///      marketing team can paste either one and get the same screen.
///   2. Any other `http(s)` link opens in the device browser.
///   3. Anything else is dropped with a log.
///
/// Note this deliberately differs from the naive "all https goes to the
/// browser" rule: our own share links are https, and bouncing them out to
/// Safari — which would then try to bounce them back in — is the bug that rule
/// produces.
abstract final class AppLinkOpener {
  const AppLinkOpener._();

  /// [source] names the surface the tap came from (see [InterestSource]) so the
  /// interest the destination screen records is attributed to it — a banner tap
  /// is `banner`, not `deeplink`.
  static Future<void> open(String link, {String? source}) async {
    final trimmed = link.trim();
    dlog('=== OPEN FROM APP: "$trimmed" (source=${source ?? "none"})');
    if (trimmed.isEmpty) {
      dlog('opener: empty link, nothing to do');
      return;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null) {
      dlog('opener: STOP — unparseable link');
      return;
    }

    // 1. Ours, and it names a screen we know.
    if (DeepLinkRoutes.resolve(uri) != null) {
      dlog('opener: handled in-app');
      await getIt<DeeplinkService>().openFromApp(uri, source: source);
      return;
    }

    // 2. Everything else on the web goes out to the browser — including a link
    //    on one of our own hosts that is a real web page (a landing page, a
    //    blog post) rather than a deep link.
    if (uri.scheme == 'http' || uri.scheme == 'https') {
      dlog('opener: not ours, opening the browser');
      try {
        final launched =
            await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched) dlog('opener: browser refused the URL');
      } catch (e) {
        dlog('opener: launch error: $e');
      }
      return;
    }

    // 3. A `lumi://` link naming a screen this build does not have — a banner
    //    written against a newer release. Nothing to do but say so.
    dlog('opener: STOP — nothing in this build handles "$trimmed". '
        'A banner written against a newer release looks exactly like this.');
  }
}
