import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/service/saved_activity_store.dart';
import 'package:lumi_pass/data/storage/storage.dart';

/// "Saqlanganlar" is local and there is no server copy, so this box IS the
/// feature: what survives a restart, what a second tap does, and whether the
/// notifier the hearts listen to actually fires.
void main() {
  late Directory tmp;
  late Box box;
  late SavedActivityStore store;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('lumi_saved_test');
    Hive.init(tmp.path);
    box = await Hive.openBox('storage');
    store = SavedActivityStore(Storage(box));
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await Hive.close();
    await tmp.delete(recursive: true);
  });

  HomClass activity(String id, {String? title}) =>
      HomClass(id: id, title: title ?? 'Activity $id');

  test('a save survives a new store over the same box', () async {
    await store.toggle(activity('1'));

    // What a restart looks like: the box is still there, the object is not.
    final reopened = SavedActivityStore(Storage(box));
    expect(reopened.contains('1'), isTrue);
    expect(reopened.load().single.id, '1');
  });

  test('tapping the heart twice leaves nothing behind', () async {
    expect(await store.toggle(activity('1')), isTrue);
    expect(await store.toggle(activity('1')), isFalse);
    expect(store.load(), isEmpty);
    expect(store.contains('1'), isFalse);
  });

  test('newest first, and re-saving refreshes rather than duplicates',
      () async {
    await store.toggle(activity('1', title: 'old title'));
    await store.toggle(activity('2'));
    expect(store.load().map((e) => e.id), ['2', '1']);

    // Unsave then save again with a newer snapshot of the same activity.
    await store.toggle(activity('1'));
    await store.toggle(activity('1', title: 'new title'));
    final saved = store.load();
    expect(saved.map((e) => e.id), ['1', '2']);
    expect(saved.first.title, 'new title');
  });

  test('an activity with no id is not saved at all', () async {
    expect(await store.toggle(const HomClass(title: 'Nameless')), isFalse);
    expect(await store.toggle(null), isFalse);
    expect(store.load(), isEmpty);
  });

  test('the notifier fires on every write, so hearts re-tint', () async {
    final seen = <int>[];
    store.savedIds.addListener(() => seen.add(store.savedIds.value.length));

    await store.toggle(activity('1'));
    await store.toggle(activity('2'));
    await store.remove('1');
    await store.clear();

    expect(seen, [1, 2, 1, 0]);
  });

  test('a saved entry that no longer parses is skipped, not thrown', () async {
    await store.toggle(activity('1'));
    // A model that changed shape between releases: `price` arrives as a type
    // HomClass cannot read. The shelf must still open on the good entry.
    final raw = box.get('saved_activities') as List;
    await box.put('saved_activities', [
      {'id': '2', 'price': <String, dynamic>{'nested': true}},
      ...raw,
    ]);

    final reopened = SavedActivityStore(Storage(box));
    expect(reopened.load().map((e) => e.id), ['1']);
    // The id is still counted: it IS saved, it just cannot be drawn, and the
    // heart on that activity must stay filled so a second tap removes it.
    expect(reopened.contains('2'), isTrue);
  });

  test('count tracks what is on the shelf', () async {
    expect(store.count, 0);
    await store.toggle(activity('1'));
    await store.toggle(activity('2'));
    expect(store.count, 2);
    await store.clear();
    expect(store.count, 0);
  });
}
