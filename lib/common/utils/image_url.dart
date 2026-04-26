String? sanitizeImageUrl(String? url) {
  if (url == null) return null;
  final trimmed = url.replaceAll(RegExp(r'\s+'), '').trim();
  if (trimmed.isEmpty) return null;
  return trimmed;
}
