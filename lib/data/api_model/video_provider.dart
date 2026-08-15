/// Where an activity's promo video is hosted (`video_provider` on the wire).
///
/// The backend derives it from whichever link the centre filled in
/// (`youtube_link` / `vimeo_link`), so it is a fixed vocabulary that can still
/// grow. [unknown] is the safe fallback for a provider this build has no
/// player for — such an item is simply skipped by the Shorts feed instead of
/// crashing it. Resolve with [fromKey] (raw field) or [resolve] (field plus
/// URL sniffing); switch exhaustively so a newly added provider surfaces as a
/// compile-time warning.
enum VideoProvider {
  youtube('youtube'),
  vimeo('vimeo'),
  unknown('');

  const VideoProvider(this.key);

  /// The raw `video_provider` string as sent by the backend.
  final String key;

  /// Maps a backend string to a [VideoProvider], returning [unknown] for null
  /// or unrecognised values. Never throws.
  static VideoProvider fromKey(String? key) {
    for (final provider in values) {
      if (provider != unknown && provider.key == key) return provider;
    }
    return unknown;
  }

  /// Resolves the provider for a video, preferring the backend's own
  /// [provider] field and falling back to sniffing the [url].
  ///
  /// The fallback matters for older activities: the backend only synthesises
  /// `video_provider` from `youtube_link` / `vimeo_link`, so a row that
  /// carries a bare `video_url` comes through with a null provider and a
  /// perfectly playable link.
  static VideoProvider resolve({String? provider, String? url}) {
    final declared = fromKey(provider?.trim().toLowerCase());
    if (declared != unknown) return declared;

    final link = url?.toLowerCase() ?? '';
    if (link.isEmpty) return unknown;
    if (link.contains('vimeo.com')) return vimeo;
    if (link.contains('youtube.com') || link.contains('youtu.be')) {
      return youtube;
    }
    return unknown;
  }
}
