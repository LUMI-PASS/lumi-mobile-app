/// What the source filed a centre under. The server's vocabulary, resolved
/// through [fromKey] so a kind added later lands in [unknown], never throws.
enum UnclaimedKind {
  center('center'),
  sports('sports'),
  playground('playground'),
  unknown('');

  const UnclaimedKind(this.key);

  final String key;

  static UnclaimedKind fromKey(String? key) => values.firstWhere(
        (kind) => kind.key == key,
        orElse: () => UnclaimedKind.unknown,
      );
}

/// What a centre's own starting price buys.
enum UnclaimedPricePeriod {
  month('month'),
  year('year'),
  visit('visit'),
  unknown('');

  const UnclaimedPricePeriod(this.key);

  final String key;

  static UnclaimedPricePeriod fromKey(String? key) => values.firstWhere(
        (period) => period.key == key,
        orElse: () => UnclaimedPricePeriod.unknown,
      );
}

/// One thing an unclaimed centre offers.
class UnclaimedActivity {
  const UnclaimedActivity({required this.name, this.isVerified = false});

  final String name;

  /// False when the activity was read out of the centre's description rather
  /// than stated by the source: our judgement, not the centre's word.
  final bool isVerified;

  factory UnclaimedActivity.fromJson(Map<String, dynamic> json) =>
      UnclaimedActivity(
        name: (json['name'] ?? '').toString(),
        isVerified: json['is_verified'] == true,
      );
}

/// One day's opening hours. [day] is `mon`…`sun`.
class UnclaimedWorkHours {
  const UnclaimedWorkHours({
    required this.day,
    required this.start,
    required this.end,
  });

  final String day;
  final String start;
  final String end;

  /// 1 (Monday) … 7 (Sunday), or 0 for a day this build does not know.
  int get weekday => const ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun']
          .indexOf(day) +
      1;

  factory UnclaimedWorkHours.fromJson(Map<String, dynamic> json) =>
      UnclaimedWorkHours(
        day: (json['day'] ?? '').toString(),
        start: (json['start_time'] ?? '').toString(),
        end: (json['end_time'] ?? '').toString(),
      );
}

/// A centre Lumi listed itself, from open sources, before the centre has
/// signed anything. A place to look at and to call — there is nothing to book
/// here and no price of ours, which is why it is not a [HomBranch] and has a
/// details page of its own.
///
/// One class for both payloads: the home shelf's card fills the first half,
/// `GET unclaimed-centres/:id` fills the rest. Opening the page from a card
/// therefore has a title and a photo to draw before the request lands.
class UnclaimedCentre {
  const UnclaimedCentre({
    required this.id,
    required this.name,
    this.kind,
    this.logo,
    this.image,
    this.address = '',
    this.district,
    this.latitude,
    this.longitude,
    this.ageFrom,
    this.ageTo,
    this.priceFrom,
    this.pricePeriod,
    this.activityNames = const [],
    this.activitiesCount = 0,
    this.isClaimed = false,
    this.networkName,
    this.description = '',
    this.images = const [],
    this.phones = const [],
    this.socials = const {},
    this.workHours = const [],
    this.hoursText,
    this.languages = const [],
    this.studiedLanguages = const [],
    this.facilities = const [],
    this.programmes = const [],
    this.foundedYear,
    this.activities = const [],
  });

  final String id;
  final String name;

  /// The wire value; read [centreKind].
  final String? kind;

  UnclaimedKind get centreKind => UnclaimedKind.fromKey(kind);
  final String? logo;
  final String? image;
  final String address;
  final String? district;
  final double? latitude;
  final double? longitude;
  final int? ageFrom;
  final int? ageTo;

  /// The centre's own starting price in so'm, where it publishes one.
  final num? priceFrom;

  /// What [priceFrom] buys, as sent; read [period].
  final String? pricePeriod;

  UnclaimedPricePeriod get period => UnclaimedPricePeriod.fromKey(pricePeriod);

  /// The first few activity names — what the card has room for.
  final List<String> activityNames;
  final int activitiesCount;

  /// Whether the centre itself confirmed this page. False on every row today.
  final bool isClaimed;

  // ── details only ─────────────────────────────────────────────────────────
  final String? networkName;
  final String description;
  final List<String> images;
  final List<String> phones;

  /// `instagram`, `telegram`, `website`, … → link. Only the ones that exist.
  final Map<String, String> socials;
  final List<UnclaimedWorkHours> workHours;

  /// The hours as the source prints them, for when [workHours] is empty.
  final String? hoursText;
  final List<String> languages;
  final List<String> studiedLanguages;
  final List<String> facilities;
  final List<String> programmes;
  final int? foundedYear;
  final List<UnclaimedActivity> activities;

  /// The gallery, or the single card photo when there is no list yet.
  List<String> get gallery {
    if (images.isNotEmpty) return images;
    final single = image;
    return (single != null && single.isNotEmpty) ? [single] : const [];
  }

  static List<String> _strings(dynamic value) => value is List
      ? value
          .map((e) => (e ?? '').toString().trim())
          .where((e) => e.isNotEmpty)
          .toList()
      : const [];

  static String? _string(dynamic value) {
    final s = (value ?? '').toString().trim();
    return s.isEmpty ? null : s;
  }

  factory UnclaimedCentre.fromJson(Map<String, dynamic> json) {
    final socials = json['socials'];
    final activities = json['activities'];
    final hours = json['work_hours'];
    return UnclaimedCentre(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      kind: _string(json['kind']),
      logo: _string(json['logo']),
      image: _string(json['image']),
      address: (json['address'] ?? '').toString().trim(),
      district: _string(json['district']),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      ageFrom: (json['age_from'] as num?)?.toInt(),
      ageTo: (json['age_to'] as num?)?.toInt(),
      priceFrom: json['price_from'] as num?,
      pricePeriod: _string(json['price_period']),
      activityNames: _strings(json['activity_names']),
      activitiesCount: (json['activities_count'] as num?)?.toInt() ?? 0,
      isClaimed: json['is_claimed'] == true,
      networkName: _string(json['network_name']),
      description: (json['description'] ?? '').toString().trim(),
      images: _strings(json['images']),
      phones: _strings(json['phones']),
      socials: socials is Map
          ? {
              for (final entry in socials.entries)
                if (_string(entry.value) != null)
                  entry.key.toString(): _string(entry.value)!,
            }
          : const {},
      workHours: hours is List
          ? hours
              .whereType<Map>()
              .map((e) =>
                  UnclaimedWorkHours.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      hoursText: _string(json['hours_text']),
      languages: _strings(json['languages']),
      studiedLanguages: _strings(json['studied_languages']),
      facilities: _strings(json['facilities']),
      programmes: _strings(json['programmes']),
      foundedYear: (json['founded_year'] as num?)?.toInt(),
      activities: activities is List
          ? activities
              .whereType<Map>()
              .map((e) =>
                  UnclaimedActivity.fromJson(Map<String, dynamic>.from(e)))
              .where((a) => a.name.isNotEmpty)
              .toList()
          : const [],
    );
  }
}

/// One titled row of unclaimed centres on the home feed.
///
/// The rows are written in the adminka — their titles, their order and which
/// centres each holds — so the app draws whatever it is sent and a new row
/// needs no release. [title] arrives already in the user's language.
class UnclaimedShelf {
  const UnclaimedShelf({
    required this.id,
    required this.title,
    required this.centres,
  });

  final String id;
  final String title;
  final List<UnclaimedCentre> centres;

  factory UnclaimedShelf.fromJson(Map<String, dynamic> json) {
    final centres = json['centres'];
    return UnclaimedShelf(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      centres: centres is List
          ? centres
              .whereType<Map>()
              .map((e) => UnclaimedCentre.fromJson(Map<String, dynamic>.from(e)))
              .where((centre) => centre.id.isNotEmpty)
              .toList()
          : const [],
    );
  }
}
