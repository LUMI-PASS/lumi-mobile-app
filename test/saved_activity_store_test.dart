import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/base_model/token/tokens.dart';
import 'package:lumi_pass/data/service/saved_activity_store.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/domain/repo/favorites/favorites_api.dart';

/// A server the test can script: what it has saved, and whether it is up.
class _FakeFavoritesApi implements FavoritesApi {
  /// Server-side shelf, newest first.
  final List<String> saved = [];

  /// Full cards by id, as `GET /favorites` would return them.
  final Map<String, Map<String, dynamic>> cards = {};

  bool down = false;
  final List<String> calls = [];

  Response _ok(String path, Object? data) => Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: data,
      );

  void _guard(String call) {
    calls.add(call);
    if (down) {
      throw DioException(requestOptions: RequestOptions(path: call));
    }
  }

  @override
  Future<Response> ids() async {
    _guard('ids');
    return _ok('favorites/ids', {
      'data': [...saved],
      'branches': [...savedBranches],
    });
  }

  @override
  Future<Response> list({int page = 1, int limit = 50}) async {
    _guard('list:$page');
    final start = (page - 1) * limit;
    final slice = saved.skip(start).take(limit);
    return _ok('favorites', {
      'data': [for (final id in slice) cards[id] ?? {'id': id}],
      'total': saved.length,
      'pages': (saved.length / limit).ceil(),
    });
  }

  /// Server-side saved centres, newest first.
  final List<String> savedBranches = [];

  @override
  Future<Response> listBranches({int page = 1, int limit = 50}) async {
    _guard('listBranches:$page');
    return _ok('favorites/branches', {
      'data': [
        for (final id in savedBranches) {'id': id, 'title': 'Centre $id'}
      ],
      'total': savedBranches.length,
      'pages': 1,
    });
  }

  @override
  Future<Response> addBranch(String branchId) async {
    _guard('addBranch:$branchId');
    if (!savedBranches.contains(branchId)) savedBranches.insert(0, branchId);
    return _ok('favorites/branches/$branchId', {
      'data': {'favorited': true}
    });
  }

  @override
  Future<Response> removeBranch(String branchId) async {
    _guard('removeBranch:$branchId');
    savedBranches.remove(branchId);
    return _ok('favorites/branches/$branchId', {
      'data': {'favorited': false}
    });
  }

  @override
  Future<Response> add(String activityId) async {
    _guard('add:$activityId');
    if (!saved.contains(activityId)) saved.insert(0, activityId);
    return _ok('favorites/$activityId', {
      'data': {'favorited': true}
    });
  }

  @override
  Future<Response> remove(String activityId) async {
    _guard('remove:$activityId');
    saved.remove(activityId);
    return _ok('favorites/$activityId', {
      'data': {'favorited': false}
    });
  }
}

/// "Saqlanganlar" lives on the server now, so what matters here is that the
/// heart is honest about it: it flips at once, flips BACK when the server
/// refuses, never calls the API for a guest (a 401 would sign them out), and
/// forgets the previous account on sign-out.
void main() {
  late Directory tmp;
  late Box box;
  late Storage storage;
  late _FakeFavoritesApi api;
  late SavedActivityStore store;

  Future<void> signIn() => storage.tokens.set(const Tokens(access: 'tok'));

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('lumi_saved_test');
    Hive.init(tmp.path);
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(TokensImplAdapter());
    box = await Hive.openBox('storage');
    storage = Storage(box);
    api = _FakeFavoritesApi();
    store = SavedActivityStore(api, storage);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await Hive.close();
    await tmp.delete(recursive: true);
  });

  // With a branch, like every real activity: the old local shelf could not
  // write one of these at all.
  HomClass activity(String id) => HomClass(
        id: id,
        title: 'Activity $id',
        branch: const HomBranch(id: 'b1', title: 'Chilonzor'),
      );

  test('a guest tap changes nothing and never reaches the server', () async {
    expect(await store.toggle(activity('1')), SaveOutcome.needsSignIn);
    expect(store.contains('1'), isFalse);
    await store.sync();
    expect(await store.load(), isEmpty);
    expect(api.calls, isEmpty);
  });

  test('a tap saves, a second tap un-saves, both on the server', () async {
    await signIn();
    expect(await store.toggle(activity('1')), SaveOutcome.saved);
    expect(store.contains('1'), isTrue);
    expect(api.saved, ['1']);

    expect(await store.toggle(activity('1')), SaveOutcome.removed);
    expect(store.contains('1'), isFalse);
    expect(api.saved, isEmpty);
  });

  test('a failed save puts the heart back', () async {
    await signIn();
    api.down = true;
    expect(await store.toggle(activity('1')), SaveOutcome.failed);
    expect(store.contains('1'), isFalse);
  });

  test('a failed un-save puts the heart back', () async {
    await signIn();
    await store.toggle(activity('1'));
    api.down = true;
    expect(await store.toggle(activity('1')), SaveOutcome.failed);
    expect(store.contains('1'), isTrue);
  });

  test('an activity with no id is not saved at all', () async {
    await signIn();
    expect(await store.toggle(const HomClass(title: 'Nameless')),
        SaveOutcome.failed);
    expect(await store.toggle(null), SaveOutcome.failed);
    expect(api.calls, isEmpty);
  });

  test('sync takes the account\'s shelf from the server', () async {
    await signIn();
    api.saved.addAll(['2', '1']);
    await store.sync();
    expect(store.savedIds.value, {'1', '2'});
    expect(store.count, 2);
  });

  test('a failed sync keeps what was cached', () async {
    await signIn();
    await store.toggle(activity('1'));
    api.down = true;
    await store.sync();
    expect(store.contains('1'), isTrue);
  });

  test('the ids survive a new store over the same box', () async {
    await signIn();
    await store.toggle(activity('1'));

    // What a restart looks like: the box is still there, the object is not.
    final reopened = SavedActivityStore(api, Storage(box));
    expect(reopened.contains('1'), isTrue);
  });

  test('the notifier fires on every change, so hearts re-tint', () async {
    await signIn();
    final seen = <int>[];
    store.savedIds.addListener(() => seen.add(store.savedIds.value.length));

    await store.toggle(activity('1'));
    await store.toggle(activity('2'));
    await store.toggle(activity('1'));
    await store.reset();

    expect(seen, [1, 2, 1, 0]);
  });

  test('load returns the server\'s cards in its order, across pages', () async {
    await signIn();
    for (var i = 60; i >= 1; i--) {
      api.saved.add('$i');
    }
    api.cards['60'] = {
      'id': '60',
      'title': 'Robotics',
      'branch': {'id': 'b1', 'title': 'Chilonzor'},
    };
    final cards = await store.load();
    expect(cards.length, 60);
    expect(cards.first.title, 'Robotics');
    expect(cards.first.branch?.id, 'b1');
    expect(cards.last.id, '1');
    expect(api.calls, ['list:1', 'list:2']);
  });

  test('a card that does not parse is skipped, not thrown', () async {
    await signIn();
    api.saved.addAll(['2', '1']);
    // A model that changed shape between releases: `price` arrives as a type
    // HomClass cannot read. The shelf must still open on the good entry.
    api.cards['2'] = {
      'id': '2',
      'price': <String, dynamic>{'nested': true},
    };
    final cards = await store.load();
    expect(cards.map((e) => e.id), ['1']);
  });

  test('load throws when the server is down, so the screen can retry',
      () async {
    await signIn();
    api.down = true;
    expect(store.load(), throwsA(isA<DioException>()));
  });

  test('a centre is saved and un-saved on its own half of the shelf', () async {
    await signIn();
    const centre = HomBranch(id: 'b1', title: 'Chilonzor');

    expect(await store.toggleBranch(centre), SaveOutcome.saved);
    expect(store.containsBranch('b1'), isTrue);
    // Not an activity: the two halves do not leak into each other.
    expect(store.contains('b1'), isFalse);
    expect(api.savedBranches, ['b1']);
    expect((await store.loadBranches()).single.title, 'Centre b1');

    expect(await store.toggleBranch(centre), SaveOutcome.removed);
    expect(store.containsBranch('b1'), isFalse);
    expect(api.savedBranches, isEmpty);
  });

  test('a failed centre save puts the heart back, and a guest never calls',
      () async {
    const centre = HomBranch(id: 'b1');
    expect(await store.toggleBranch(centre), SaveOutcome.needsSignIn);
    expect(api.calls, isEmpty);

    await signIn();
    api.down = true;
    expect(await store.toggleBranch(centre), SaveOutcome.failed);
    expect(store.containsBranch('b1'), isFalse);
  });

  test('sync fills both halves, and the count is the two together', () async {
    await signIn();
    api.saved.addAll(['2', '1']);
    api.savedBranches.add('b1');
    await store.sync();
    expect(store.savedIds.value, {'1', '2'});
    expect(store.savedBranchIds.value, {'b1'});
    expect(store.count, 3);
  });

  test('either half changing fires the merged listenable', () async {
    await signIn();
    var fired = 0;
    store.changes.addListener(() => fired++);
    await store.toggle(activity('1'));
    await store.toggleBranch(const HomBranch(id: 'b1'));
    expect(fired, 2);
  });

  test('sign-out forgets the shelf on this device, not on the server',
      () async {
    await signIn();
    await store.toggle(activity('1'));
    await store.toggleBranch(const HomBranch(id: 'b1'));
    await store.reset();
    expect(store.savedIds.value, isEmpty);
    expect(store.savedBranchIds.value, isEmpty);
    expect(SavedActivityStore(api, Storage(box)).contains('1'), isFalse);
    expect(api.saved, ['1']);
  });
}
