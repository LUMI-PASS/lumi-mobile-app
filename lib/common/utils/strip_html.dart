/// Strips HTML markup from rich-text fields stored by the adminka editor so
/// they render cleanly in plain Text widgets. Backend already does this for
/// new responses; this is a defensive client-side fallback for cached or
/// pre-deploy payloads that still contain `<p>...</p>` etc.
String stripHtml(String? input) {
  if (input == null) return '';
  return input
      .replaceAll(RegExp(r'<\s*br\s*/?\s*>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</\s*p\s*>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<[^>]+>'), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();
}
