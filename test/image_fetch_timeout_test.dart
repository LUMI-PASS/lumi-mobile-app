import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/common/utils/image_cache.dart';

/// The deadline on an image fetch.
///
/// Why it is worth a test: the bug it fixes was invisible. A cached image fetch
/// with no timeout does not fail — it waits, and the widget shows its
/// placeholder for as long as it waits, which in November 2026 was forever. The
/// assertions here are therefore about one thing: that a fetch which never
/// answers becomes an ERROR, because an error is what makes the fallback
/// artwork every call site already passes actually appear.
void main() {
  group('TimeoutFileService', () {
    test('passes a prompt response straight through', () async {
      final service = TimeoutFileService(
        inner: _FakeFileService(delay: Duration.zero),
        responseTimeout: const Duration(milliseconds: 200),
        stallTimeout: const Duration(milliseconds: 200),
      );

      final response = await service.get('https://example.test/a.png');

      expect(response.statusCode, 200);
      expect(
        await response.content.expand((chunk) => chunk).toList(),
        [1, 2, 3],
      );
    });

    test('gives up when the response never starts', () async {
      final service = TimeoutFileService(
        inner: _FakeFileService(delay: const Duration(seconds: 30)),
        responseTimeout: const Duration(milliseconds: 50),
        stallTimeout: const Duration(milliseconds: 50),
      );

      await expectLater(
        service.get('https://example.test/hangs.png'),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('gives up when the body stalls halfway through', () async {
      // The nastier half of the outage: headers arrive, so the fetch looks
      // healthy, and then nothing more ever comes.
      final service = TimeoutFileService(
        inner: _FakeFileService(delay: Duration.zero, stallAfterFirstChunk: true),
        responseTimeout: const Duration(milliseconds: 200),
        stallTimeout: const Duration(milliseconds: 50),
      );

      final response = await service.get('https://example.test/stalls.png');

      await expectLater(response.content, emitsThrough(emitsError(isA<TimeoutException>())));
    });

    test('a slow but moving download is left alone', () async {
      // Each gap is under the stall timeout; the total is well over it. A photo
      // on a slow connection must not be cut off for being slow.
      final service = TimeoutFileService(
        inner: _FakeFileService(
          delay: Duration.zero,
          chunkGap: const Duration(milliseconds: 20),
          chunks: 6,
        ),
        responseTimeout: const Duration(milliseconds: 200),
        stallTimeout: const Duration(milliseconds: 60),
      );

      final response = await service.get('https://example.test/slow.png');

      expect((await response.content.toList()).length, 6);
    });

    test('delegates the cache metadata to the response it wraps', () async {
      // `validTill`, the eTag and the extension decide what gets stored and for
      // how long. The wrapper bounds the waiting and changes nothing else.
      final service = TimeoutFileService(
        inner: _FakeFileService(delay: Duration.zero),
        responseTimeout: const Duration(milliseconds: 200),
        stallTimeout: const Duration(milliseconds: 200),
      );

      final response = await service.get('https://example.test/a.png');

      expect(response.eTag, 'etag-1');
      expect(response.fileExtension, '.png');
      expect(response.contentLength, 3);
      expect(response.validTill, _FakeFileServiceResponse.validTillValue);
    });
  });

  group('installImageFetchTimeout', () {
    test('every cached network image fetches through the manager given', () {
      // The real manager opens its store as it is built, which needs
      // path_provider and sqflite — so the wiring is asserted with a stand-in
      // and the manager's own two decisions (its store and its file service)
      // are asserted directly, above and below.
      final manager = _StubCacheManager();

      installImageFetchTimeout(manager: manager);

      expect(CachedNetworkImageProvider.defaultCacheManager, same(manager));
    });

    test('shares the default manager\'s store, so cached images survive', () {
      // A new store name would silently drop every image already on the device
      // — the worst possible moment for that is an outage, when re-downloading
      // is exactly what does not work.
      expect(AppImageCacheManager.storeName, DefaultCacheManager.key);
    });
  });

  group('no raw Image.network in lib/', () {
    test('every network image goes through the cache manager', () {
      // `Image.network` does its own fetching with its own HttpClient, which
      // this timeout cannot reach: one of those is a blank frame again, with
      // nothing in the diff to show it. There were four before this change.
      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final lines = entity.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          if (lines[i].contains('Image.network(')) {
            offenders.add('${entity.path}:${i + 1}');
          }
        }
      }

      expect(
        offenders,
        isEmpty,
        reason: 'use CachedNetworkImage instead — see '
            'lib/common/utils/image_cache.dart',
      );
    });
  });
}

/// Stands in for a cache manager where only its identity is under test.
class _StubCacheManager implements BaseCacheManager {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('the stub manager is never fetched through');
}

/// A [FileService] that answers however the test needs it to.
class _FakeFileService extends FileService {
  _FakeFileService({
    required this.delay,
    this.stallAfterFirstChunk = false,
    this.chunkGap = Duration.zero,
    this.chunks = 1,
  });

  /// How long before the response starts.
  final Duration delay;

  /// Emit one chunk and then go quiet forever.
  final bool stallAfterFirstChunk;

  /// The gap between chunks of the body.
  final Duration chunkGap;

  /// How many chunks the body arrives in.
  final int chunks;

  @override
  Future<FileServiceResponse> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    return _FakeFileServiceResponse(
      stallAfterFirstChunk: stallAfterFirstChunk,
      chunkGap: chunkGap,
      chunks: chunks,
    );
  }
}

class _FakeFileServiceResponse implements FileServiceResponse {
  _FakeFileServiceResponse({
    required this.stallAfterFirstChunk,
    required this.chunkGap,
    required this.chunks,
  });

  static final DateTime validTillValue = DateTime.utc(2030);

  final bool stallAfterFirstChunk;
  final Duration chunkGap;
  final int chunks;

  @override
  Stream<List<int>> get content async* {
    if (stallAfterFirstChunk) {
      yield const [1];
      // Longer than any test waits: the point is that it never arrives.
      await Future<void>.delayed(const Duration(seconds: 30));
      yield const [2];
      return;
    }
    if (chunks > 1) {
      for (var i = 0; i < chunks; i++) {
        await Future<void>.delayed(chunkGap);
        yield [i];
      }
      return;
    }
    yield const [1, 2, 3];
  }

  @override
  int? get contentLength => 3;

  @override
  int get statusCode => 200;

  @override
  DateTime get validTill => validTillValue;

  @override
  String? get eTag => 'etag-1';

  @override
  String get fileExtension => '.png';
}
