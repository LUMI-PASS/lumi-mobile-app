import 'package:injectable/injectable.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/storage/storage.dart';

/// The activities the user last opened from the search screen.
///
/// Search opened from Home used to fire an unfiltered catalog query before the
/// user had typed a character — a page of results nobody asked for, which cost
/// a request and told them nothing. It now opens on this list instead: what
/// THEY looked for last time, ready to be tapped again.
///
/// Stored as the raw `HomClass` JSON so a card can be rebuilt (and opened)
/// offline, without a round trip. The list is capped at [_max] and deduped by
/// id, newest first.
@lazySingleton
class RecentSearchStore {
  RecentSearchStore(this._storage);

  final Storage _storage;

  /// Two rows of the two-column grid. Long enough to be worth showing, short
  /// enough that it still reads as "the last few", not a history screen.
  static const int _max = 10;

  /// Newest first. Anything unreadable (a model that changed shape between
  /// releases) is skipped rather than thrown — this is a convenience list, and
  /// it must never be the reason the search screen fails to open.
  List<HomClass> load() {
    final raw = _storage.recentSearchClasses.call() ?? const [];
    final out = <HomClass>[];
    for (final entry in raw) {
      if (entry is! Map) continue;
      try {
        out.add(HomClass.fromJson(Map<String, dynamic>.from(entry)));
      } catch (_) {}
    }
    return out;
  }

  /// Moves [model] to the front of the list, or adds it there.
  ///
  /// An activity with no id can't be deduped and can't be reopened reliably,
  /// so it is not remembered at all.
  Future<void> remember(HomClass? model) async {
    final id = model?.id;
    if (model == null || id == null || id.isEmpty) return;

    final raw = _storage.recentSearchClasses.call() ?? const [];
    final kept = <Map<String, dynamic>>[];
    for (final entry in raw) {
      if (entry is! Map) continue;
      final map = Map<String, dynamic>.from(entry);
      if (map['id'] == id) continue;
      kept.add(map);
    }
    final next = [model.toJson(), ...kept].take(_max).toList();
    await _storage.recentSearchClasses.set(next);
  }

  Future<void> clear() => _storage.recentSearchClasses.set(const []);
}
