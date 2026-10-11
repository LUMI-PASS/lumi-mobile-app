/// Where a centre can be found OUTSIDE the app — its Instagram, Telegram,
/// website and the rest.
///
/// Only ever sent for a CATALOGUE row (`is_catalog`): a venue Lumi listed
/// itself from a public directory, with no contract behind it and nothing on
/// it to book. Its own accounts are then the only thing a parent can act on,
/// which is why the detail pages show them in place of the Book button. A real
/// partner's accounts are deliberately not published — see the backend's
/// `catalogSocials`.
///
/// The values are FREE TEXT, not URLs: a centre gives its Instagram as
/// `@lumipass` as readily as `instagram.com/lumipass`, and the console stores
/// whichever was typed. Resolving that to something tappable is this file's
/// job — see [SocialNetwork.urlFor].
library;

/// A network a centre can have an account on.
///
/// The keys are the backend's (`PartnerSocials`). A key we have never heard of
/// resolves to [unknown] rather than throwing: the console can grow a field at
/// any time, and an unmodelled network still renders — as a plain link, under
/// the generic globe.
enum SocialNetwork {
  instagram('instagram', 'instagram.com', ['instagram.com', 'instagr.am']),
  telegram('telegram', 't.me', ['t.me', 'telegram.me', 'telegram.org']),
  facebook('facebook', 'facebook.com', ['facebook.com', 'fb.com', 'fb.me']),
  youtube('youtube', 'youtube.com', ['youtube.com', 'youtu.be']),
  tiktok('tiktok', 'tiktok.com', ['tiktok.com']),

  /// The centre's own site. Unlike the others this has no handle form — the
  /// value is always a domain — so it is never prefixed with a host.
  website('website', null, []),

  /// A key this build does not model. Rendered only if its value is already a
  /// URL; there is no handle convention to guess at.
  unknown('unknown', null, []);

  const SocialNetwork(this.key, this._host, this._knownHosts);

  /// The wire key, as the backend spells it.
  final String key;

  /// Where a bare handle lives, e.g. `instagram.com`. Null for the networks
  /// that have no handle form.
  final String? _host;

  /// Hosts whose appearance in an unprefixed value means it is a URL and not
  /// a handle — `instagram.com/lumipass` typed without the scheme.
  final List<String> _knownHosts;

  /// Never throws — an unmodelled key degrades to [unknown].
  static SocialNetwork fromKey(String? key) {
    final normalized = key?.trim().toLowerCase();
    for (final value in values) {
      if (value.key == normalized) return value;
    }
    return unknown;
  }

  /// Whether a handle on this network is PRINTED with a leading `@` —
  /// `@lumipass` is how a parent recognises an Instagram or Telegram name.
  bool get _usesAtHandle =>
      this == instagram || this == telegram || this == tiktok || this == youtube;

  /// Whether the `@` belongs in the URL too. TikTok and YouTube put it in the
  /// path (`tiktok.com/@lumipass`); Instagram and Telegram do not
  /// (`instagram.com/lumipass`), and leaving it in 404s.
  bool get _atInPath => this == tiktok || this == youtube;

  /// [raw] as something [launchUrl] can open, or null when there is nothing
  /// usable in it.
  ///
  /// Four shapes arrive from the console and all four have to work:
  ///
  ///   `https://instagram.com/lumipass` — taken as it stands.
  ///   `instagram.com/lumipass`         — a URL missing its scheme.
  ///   `@lumipass`                      — a handle.
  ///   `lumi.pass`                      — ALSO a handle. A dot does not make
  ///                                      it a domain: plenty of Instagram
  ///                                      names have one, so only a slash or
  ///                                      a host we recognise does.
  String? urlFor(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    final lower = value.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return value;
    }
    // A path, or a host we know: a URL someone left the scheme off.
    final looksLikeUrl = value.contains('/') ||
        _knownHosts.any((h) => lower == h || lower.startsWith('$h/')) ||
        lower.startsWith('www.');
    if (looksLikeUrl) return 'https://$value';
    // The website field has no handle form, so whatever is left is a domain.
    if (_host == null) {
      return value.contains('.') || this == website ? 'https://$value' : null;
    }
    final handle = value.replaceFirst(RegExp(r'^@+'), '');
    if (handle.isEmpty) return null;
    return _atInPath ? 'https://$_host/@$handle' : 'https://$_host/$handle';
  }

  /// What to PRINT for [raw] — the handle for a social account, the bare
  /// domain for a website. Never the full URL: `@lumipass` is what a parent
  /// recognises and what fits on one line.
  String labelFor(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return '';
    if (this == website || this == unknown) {
      return value
          .replaceFirst(RegExp(r'^https?://', caseSensitive: false), '')
          .replaceFirst(RegExp(r'^www\.', caseSensitive: false), '')
          .replaceFirst(RegExp(r'/+$'), '');
    }
    // The handle is the last meaningful path segment, whether the value came
    // as a link or as the handle itself.
    final withoutScheme =
        value.replaceFirst(RegExp(r'^https?://', caseSensitive: false), '');
    final segments = withoutScheme
        .split('?')
        .first
        .split('/')
        .where((s) => s.trim().isNotEmpty)
        .toList();
    final last = segments.isEmpty ? null : segments.last;
    final handle = (last ?? value).replaceFirst(RegExp(r'^@+'), '');
    if (handle.isEmpty) return value;
    return _usesAtHandle ? '@$handle' : handle;
  }
}

/// One account: which network, and what the centre typed.
class SocialLink {
  const SocialLink({
    required this.network,
    required this.wireKey,
    required this.value,
  });

  final SocialNetwork network;

  /// The key as it arrived. Kept so an [SocialNetwork.unknown] link can still
  /// be serialized back unchanged.
  final String wireKey;

  /// What the console holds — a handle or a link, see [SocialNetwork.urlFor].
  final String value;

  /// Null when the value is not something that can be opened, which is only
  /// possible for an unmodelled network.
  String? get url => network.urlFor(value);

  /// The one-line form to print: `@lumipass`, `lumipass.uz`.
  String get label => network.labelFor(value);
}

/// A centre's accounts, in the order they are shown.
class CentreSocials {
  const CentreSocials(this.links);

  /// Ordered by [SocialNetwork]'s declaration order, not by the order the keys
  /// happened to arrive in, so every centre's card reads the same way.
  final List<SocialLink> links;

  static const CentreSocials empty = CentreSocials(<SocialLink>[]);

  bool get isEmpty => links.isEmpty;

  bool get isNotEmpty => links.isNotEmpty;

  /// Only the accounts that can actually be opened — what a card should
  /// render. A link whose value is neither a URL nor a handle we can place is
  /// dropped rather than shown as a dead row.
  List<SocialLink> get openable =>
      links.where((l) => (l.url ?? '').isNotEmpty).toList(growable: false);

  /// `{"instagram": "@lumipass", …}`. Blank values are dropped by the backend
  /// already; dropped again here so a hand-built payload cannot produce an
  /// empty row.
  factory CentreSocials.fromJson(Map<String, dynamic> json) {
    final raw = <String, String>{};
    json.forEach((key, value) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) raw[key.trim().toLowerCase()] = text;
    });
    if (raw.isEmpty) return empty;

    final links = <SocialLink>[];
    // The modelled networks first, in the order they are declared — that
    // order is the design's, and a centre that happens to have filled in
    // TikTok first must not get a differently ordered card.
    for (final network in SocialNetwork.values) {
      if (network == SocialNetwork.unknown) continue;
      final value = raw.remove(network.key);
      if (value == null) continue;
      links.add(SocialLink(
        network: network,
        wireKey: network.key,
        value: value,
      ));
    }
    // Anything left is a key this build predates. It still gets a row if its
    // value is a link — see [openable].
    for (final entry in raw.entries) {
      links.add(SocialLink(
        network: SocialNetwork.unknown,
        wireKey: entry.key,
        value: entry.value,
      ));
    }
    return CentreSocials(links);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        for (final link in links) link.wireKey: link.value,
      };
}
