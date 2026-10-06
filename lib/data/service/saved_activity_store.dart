import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/storage/storage.dart';

/// The activities the user saved — "Saqlanganlar".
///
/// Local only. The backend has no favourites endpoint, so this device IS the
/// store; nothing is synced and nothing is sent anywhere. That also decides
/// what gets written: the whole `HomClass` JSON rather than its id, the same
/// way [RecentSearchStore] does it, so the shelf renders (and opens) with no
/// round trip and keeps working offline. An id alone would need a fetch per
/// card, and a saved activity the server later stops returning would simply
/// vanish from the list the user built.
///
/// Newest first, deduped by id, and NOT capped: recents are a convenience the
/// app maintains for you and can forget, saving is a deliberate act and must
/// not silently drop the first thing you saved.
///
/// [savedIds] is the live view every heart listens to, so saving on the detail
/// screen re-tints the heart on a card behind it and moves the shelf's count,
/// without either of them being told to reload.
@lazySingleton
class SavedActivityStore {
  SavedActivityStore(this._storage) {
    savedIds = ValueNotifier(_idsFromDisk());
  }

  final Storage _storage;

  /// The ids currently saved. Replaced (never mutated in place) on every write,
  /// so [ValueNotifier] actually notifies.
  late final ValueNotifier<Set<String>> savedIds;

  /// Everything saved, newest first.
  ///
  /// Anything unreadable — a model whose shape changed between releases — is
  /// skipped rather than thrown. This is the user's own shelf; one bad entry
  /// must not be the reason it fails to open.
  List<HomClass> load() {
    final out = <HomClass>[];
    for (final entry in _raw()) {
      try {
        out.add(HomClass.fromJson(entry));
      } catch (_) {}
    }
    return out;
  }

  bool contains(String? id) =>
      id != null && id.isNotEmpty && savedIds.value.contains(id);

  int get count => savedIds.value.length;

  /// Saves [model] if it isn't saved, unsaves it if it is. Returns what the
  /// heart should now show.
  ///
  /// An activity with no id can be neither deduped nor reopened, so it is not
  /// saved at all and the heart stays off — the same rule recents use.
  Future<bool> toggle(HomClass? model) async {
    final id = model?.id;
    if (model == null || id == null || id.isEmpty) return false;
    if (savedIds.value.contains(id)) {
      await remove(id);
      return false;
    }
    // Re-saving an activity already on the shelf would otherwise duplicate the
    // card; the id is filtered out first and the fresh copy goes to the front,
    // which also refreshes a stale snapshot for free.
    final kept = _raw().where((e) => e['id'] != id);
    await _write([model.toJson(), ...kept]);
    return true;
  }

  Future<void> remove(String id) async {
    if (id.isEmpty) return;
    await _write(_raw().where((e) => e['id'] != id).toList());
  }

  Future<void> clear() => _write(const []);

  // ── disk ───────────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> _raw() {
    final raw = _storage.savedActivities.call() ?? const [];
    return [
      for (final entry in raw)
        if (entry is Map) Map<String, dynamic>.from(entry),
    ];
  }

  Future<void> _write(Iterable<Map<String, dynamic>> entries) async {
    await _storage.savedActivities.set(entries.toList());
    savedIds.value = _idsFromDisk();
  }

  Set<String> _idsFromDisk() {
    return {
      for (final entry in _raw())
        if (entry['id'] is String && (entry['id'] as String).isNotEmpty)
          entry['id'] as String,
    };
  }
}
