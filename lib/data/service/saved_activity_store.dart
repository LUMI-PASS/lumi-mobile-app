import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/common/base/base_storage.dart';
import 'package:lumi_pass/data/api_model/class_full/class_full_model.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/domain/repo/favorites/favorites_api.dart';

// ignore: avoid_print
void _log(String msg) => print('[Saved] $msg');

/// What a tap on a heart came to.
enum SaveOutcome {
  /// Now on the shelf.
  saved,

  /// Now off the shelf.
  removed,

  /// Nobody is signed in, so there is no shelf to put it on. The caller sends
  /// the user to sign in; nothing was changed.
  needsSignIn,

  /// The request failed (or the thing has no id). The heart is back where it
  /// was.
  failed,
}

/// What the user saved — "Saqlanganlar": activities (courses are activities)
/// and centres.
///
/// The shelf lives on the server, one per account (`/favorites`), so it
/// follows the user to another phone and survives a reinstall. What is kept on
/// this device is only the sets of saved IDS, as a cache: it lets every heart
/// tint on the first frame of a cold start instead of after a round trip.
/// The cards themselves are always read from the server, so the shelf shows
/// the price and photo the centre has NOW.
///
/// [savedIds] and [savedBranchIds] are the live views every heart listens to,
/// so saving on a detail screen re-tints the heart on a card behind it and
/// moves the shelf's count, without either of them being told to reload.
@lazySingleton
class SavedActivityStore {
  SavedActivityStore(this._api, this._storage)
      : _activities = _IdShelf(_storage.savedActivityIds),
        _branches = _IdShelf(_storage.savedBranchIds);

  final FavoritesApi _api;
  final Storage _storage;

  final _IdShelf _activities;
  final _IdShelf _branches;

  /// Server page size. The backend caps a page at 50.
  static const int _pageSize = 50;

  /// How many pages a load will walk. Nobody's shelf is expected to come near
  /// this; it only bounds a runaway account.
  static const int _maxPages = 10;

  /// The activity ids currently saved. Replaced (never mutated in place) on
  /// every change, so [ValueNotifier] actually notifies.
  ValueNotifier<Set<String>> get savedIds => _activities.ids;

  /// The centre ids currently saved. Same contract as [savedIds].
  ValueNotifier<Set<String>> get savedBranchIds => _branches.ids;

  /// Fires when either half of the shelf changes — for a screen showing both.
  late final Listenable changes = Listenable.merge([savedIds, savedBranchIds]);

  bool get _isSignedIn => _storage.tokens.call()?.access != null;

  bool contains(String? id) => _activities.contains(id);

  bool containsBranch(String? id) => _branches.contains(id);

  /// Everything on the shelf, activities and centres together.
  int get count => savedIds.value.length + savedBranchIds.value.length;

  /// Pulls the saved ids from the server. Call on app start and after sign-in.
  ///
  /// Best-effort and never throws: a failed sync leaves the cached ids, which
  /// is the better of the two things to show.
  Future<void> sync() async {
    if (!_isSignedIn) return;
    try {
      final response = await _api.ids();
      final raw = response.data;
      if (raw is! Map) return;
      await _activities.adopt(raw['data']);
      // Absent on a server that predates saved centres — leave the cache.
      await _branches.adopt(raw['branches']);
    } catch (e) {
      _log('sync failed (ignored): $e');
    }
  }

  /// Saves [model] if it isn't saved, un-saves it if it is.
  ///
  /// Optimistic: the heart flips on the tap and flips back only if the server
  /// refuses, because a heart that waits on the network feels broken.
  Future<SaveOutcome> toggle(HomClass? model) =>
      _toggle(_activities, model?.id, add: _api.add, remove: _api.remove);

  /// The same for a centre.
  Future<SaveOutcome> toggleBranch(HomBranch? branch) => _toggle(
        _branches,
        branch?.id,
        add: _api.addBranch,
        remove: _api.removeBranch,
      );

  Future<SaveOutcome> _toggle(
    _IdShelf shelf,
    String? id, {
    required Future<Response> Function(String id) add,
    required Future<Response> Function(String id) remove,
  }) async {
    if (id == null || id.isEmpty) return SaveOutcome.failed;
    if (!_isSignedIn) return SaveOutcome.needsSignIn;
    // A second tap while the first is on the wire waits rather than races.
    if (shelf.pending.contains(id)) {
      return shelf.contains(id) ? SaveOutcome.saved : SaveOutcome.removed;
    }

    final wasSaved = shelf.contains(id);
    shelf.pending.add(id);
    await shelf.set(id, saved: !wasSaved);
    try {
      await (wasSaved ? remove(id) : add(id));
      return wasSaved ? SaveOutcome.removed : SaveOutcome.saved;
    } catch (e) {
      _log('toggle failed, reverted: $e');
      await shelf.set(id, saved: wasSaved);
      return SaveOutcome.failed;
    } finally {
      shelf.pending.remove(id);
    }
  }

  /// The saved activities as cards, newest save first.
  ///
  /// Throws on a failed request so the screen can offer a retry — unlike
  /// [sync], somebody is looking at this. Signed out, the shelf is empty.
  ///
  /// A card that does not parse — a model whose shape moved between releases —
  /// is skipped rather than thrown. One bad entry must not be the reason the
  /// user's own shelf fails to open.
  Future<List<HomClass>> load() {
    return _loadAll(
      (page) => _api.list(page: page, limit: _pageSize),
      (json) {
        final card = HomClass.fromJson(json);
        // The detail screen reads its first price from this cache. Inside the
        // same guard as the parse: the cache parses the card too.
        ClassPricingCache.mergeFromList([json]);
        return card;
      },
    );
  }

  /// The saved centres as cards, newest save first. Same contract as [load].
  Future<List<HomBranch>> loadBranches() {
    return _loadAll(
      (page) => _api.listBranches(page: page, limit: _pageSize),
      HomBranch.fromJson,
    );
  }

  Future<List<T>> _loadAll<T>(
    Future<Response> Function(int page) fetch,
    T Function(Map<String, dynamic> json) parse,
  ) async {
    if (!_isSignedIn) return const [];
    final out = <T>[];
    for (var page = 1; page <= _maxPages; page++) {
      final raw = (await fetch(page)).data;
      final list = raw is Map ? raw['data'] : null;
      if (list is! List) break;
      for (final entry in list) {
        if (entry is! Map) continue;
        try {
          out.add(parse(Map<String, dynamic>.from(entry)));
        } catch (_) {}
      }
      final pages = raw is Map ? raw['pages'] : null;
      final totalPages = pages is int ? pages : int.tryParse('$pages') ?? 1;
      if (page >= totalPages) break;
    }
    return out;
  }

  /// Forgets the shelf on this device — sign-out. The server copy is the
  /// account's and is untouched.
  Future<void> reset() async {
    await _activities.clear();
    await _branches.clear();
  }
}

/// One half of the shelf: a set of saved ids, live in memory and cached on
/// disk.
class _IdShelf {
  _IdShelf(this._disk) : ids = ValueNotifier(_read(_disk));

  final BaseStorage<List> _disk;

  final ValueNotifier<Set<String>> ids;

  /// Ids with a save or un-save still on the wire. [adopt] does not overwrite
  /// an answer the server has not given yet.
  final Set<String> pending = {};

  bool contains(String? id) =>
      id != null && id.isNotEmpty && ids.value.contains(id);

  Future<void> set(String id, {required bool saved}) {
    return _write(saved ? {id, ...ids.value} : ({...ids.value}..remove(id)));
  }

  /// Takes the server's list as the truth — unless it is not a list at all, or
  /// a tap made while it was in flight is newer than it.
  Future<void> adopt(Object? list) async {
    if (list is! List || pending.isNotEmpty) return;
    await _write({
      for (final id in list)
        if (id is String && id.isNotEmpty) id,
    });
  }

  Future<void> clear() {
    pending.clear();
    return _write(const {});
  }

  Future<void> _write(Set<String> next) async {
    ids.value = next;
    await _disk.set(next.toList());
  }

  static Set<String> _read(BaseStorage<List> disk) {
    return {
      for (final id in disk.call() ?? const [])
        if (id is String && id.isNotEmpty) id,
    };
  }
}
