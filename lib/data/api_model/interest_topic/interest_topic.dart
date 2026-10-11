/// Which question on the child form a topic answers.
///
/// The server's vocabulary, so it resolves through [fromKey] and never
/// throws: a kind added later lands in [unknown] and is simply not listed.
enum InterestTopicKind {
  /// "What is your child into?" — Futbol, Musiqa.
  child('child'),

  /// "What are you looking for?" — Massaj, Logoped.
  parent('parent'),
  unknown('');

  const InterestTopicKind(this.key);

  final String key;

  static InterestTopicKind fromKey(String? key) => values.firstWhere(
        (kind) => kind.key == key,
        orElse: () => InterestTopicKind.unknown,
      );
}

/// A word a parent picks for a child — "Futbol", "Musiqa", "Massaj".
///
/// The list is written in the adminka, which also decides which catalog
/// categories each word means. The app only shows the words and sends back
/// the ids that were picked; what they match is the server's business.
class InterestTopic {
  const InterestTopic({
    required this.id,
    required this.name,
    this.kind,
    this.emoji,
  });

  final String id;
  final String name;

  /// The picture in front of the word — "⚽". Optional: a topic the adminka
  /// gave none, or a server that predates the field, shows the word alone.
  final String? emoji;

  /// The raw wire value; read [topicKind].
  final String? kind;

  InterestTopicKind get topicKind => InterestTopicKind.fromKey(kind);

  /// Null for a row with no id or no name — neither can be shown or sent.
  static InterestTopic? tryFromJson(Object? json) {
    if (json is! Map) return null;
    final id = json['id']?.toString() ?? '';
    final name = json['name']?.toString().trim() ?? '';
    if (id.isEmpty || name.isEmpty) return null;
    final emoji = json['emoji']?.toString().trim() ?? '';
    return InterestTopic(
      id: id,
      name: name,
      kind: json['kind']?.toString(),
      emoji: emoji.isEmpty ? null : emoji,
    );
  }
}
