import 'package:lumi_pass/common/env/runtime_env.dart';

/// Normalizes a stored asset URL into one we know mobile-api can serve.
///
/// Older banner/branch rows persisted absolute URLs against a host that no
/// longer hosts the files (e.g. `https://app.lumipass.uz/uploads/...`). The
/// mobile-backend rewrites these on the way out, but cached or
/// not-yet-deployed responses can still surface them — strip the host on the
/// client too so images don't 404 in the meantime.
String? sanitizeImageUrl(String? url) {
  final assetHost = RuntimeEnv.assetsUrl;
  if (url == null) return null;
  final trimmed = url.replaceAll(RegExp(r'\s+'), '').trim();
  if (trimmed.isEmpty) return null;
  final match = RegExp(r'^https?://[^/]+(/.*)$').firstMatch(trimmed);
  if (match != null) {
    final path = match.group(1)!;
    if (path.startsWith('/uploads/')) {
      return '$assetHost$path';
    }
    return trimmed;
  }
  if (trimmed.startsWith('/')) return '$assetHost$trimmed';
  return trimmed;
}
