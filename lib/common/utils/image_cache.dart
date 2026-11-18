import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// How long a picture may take to start arriving.
///
/// Generous, because the alternative to waiting is an error: on a slow
/// connection a first byte can legitimately be seconds away. The backend
/// answers `/uploads/...` with a 504 of its own after 8s, so anything past this
/// is a network or a server that has stopped talking altogether.
const Duration _kResponseTimeout = Duration(seconds: 15);

/// How long the bytes may go quiet mid-download before the fetch is abandoned.
///
/// Per gap between chunks, not for the whole body — a big photo on a slow link
/// keeps arriving slowly and is fine; a connection that stalls completely is
/// not, and before this it stalled forever.
const Duration _kStallTimeout = Duration(seconds: 15);

/// The cache manager every `CachedNetworkImage` in the app fetches through.
///
/// ## Why this exists
///
/// `CachedNetworkImage` has no timeout. Its placeholder is shown while a fetch
/// is in flight and `errorWidget` only when one FAILS, so a request that never
/// answers never reaches the fallback — the card simply stays empty, forever,
/// with no error anywhere to see.
///
/// That is not hypothetical. In November 2026 the backend's `/uploads/...`
/// route began hanging (the upload bucket accepted connections and never
/// replied, and the AWS SDK had no timeouts either): `/api/*` was healthy, the
/// catalogue loaded, every card drew its name and price — and every photo and
/// category icon in the app was blank. Not a broken-image glyph, not the
/// gradient-letter fallback these widgets are all given: nothing. The server is
/// fixed and bounded now, but an app that cannot tell "slow" from "never
/// coming" will show the same blank screen for the next stalled network.
///
/// So the fetch gets a deadline, which is all the widgets needed: a timeout is
/// an error, an error draws `errorWidget`, and the fallback artwork the call
/// sites already pass finally appears.
///
/// Shares `DefaultCacheManager`'s store on purpose — it IS the same on-device
/// cache, so swapping the manager in does not throw away the images users
/// already have. Nothing else constructs `DefaultCacheManager`, so there is
/// still exactly one instance over that store.
class AppImageCacheManager extends CacheManager with ImageCacheManager {
  AppImageCacheManager._()
      : super(
          Config(
            storeName,
            fileService: TimeoutFileService(),
          ),
        );

  /// `DefaultCacheManager`'s own store name — see the note above on sharing it.
  static const String storeName = 'libCachedImageData';

  static final AppImageCacheManager instance = AppImageCacheManager._();
}

/// Makes [AppImageCacheManager] the manager for every cached network image.
///
/// Call once, before the first frame and after the Flutter binding — building
/// the manager opens its store, which goes through path_provider.
/// `CachedNetworkImageProvider` resolves its manager from a static that is only
/// initialised on first read, so assigning it this early covers every call site
/// in the app, including the ones that pass no `cacheManager` of their own,
/// which is all of them.
///
/// [manager] is a test seam: the default is the one the app runs with.
void installImageFetchTimeout({BaseCacheManager? manager}) {
  CachedNetworkImageProvider.defaultCacheManager =
      manager ?? AppImageCacheManager.instance;
}

/// The ordinary HTTP file service with a deadline on each stage.
///
/// Delegates rather than reimplements: header parsing, `validTill`, the eTag
/// and the file extension all stay the package's business, and only the two
/// waits that could run forever are bounded.
class TimeoutFileService extends FileService {
  TimeoutFileService({
    FileService? inner,
    this.responseTimeout = _kResponseTimeout,
    this.stallTimeout = _kStallTimeout,
  }) : _inner = inner ?? HttpFileService();

  final FileService _inner;

  /// Deadline for the response to start.
  final Duration responseTimeout;

  /// Deadline for each further chunk of the body.
  final Duration stallTimeout;

  @override
  Future<FileServiceResponse> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    final response =
        await _inner.get(url, headers: headers).timeout(responseTimeout);
    return _TimedFileServiceResponse(response, stallTimeout);
  }
}

/// A [FileServiceResponse] whose body cannot stall indefinitely.
class _TimedFileServiceResponse implements FileServiceResponse {
  _TimedFileServiceResponse(this._inner, this._stallTimeout);

  final FileServiceResponse _inner;
  final Duration _stallTimeout;

  /// `Stream.timeout` fires on the GAP between events, so a slow-but-moving
  /// download is left alone and only a dead one is cut off. The error is what
  /// the widget turns into its `errorWidget`.
  @override
  Stream<List<int>> get content => _inner.content.timeout(
        _stallTimeout,
        onTimeout: (sink) => sink.addError(
          TimeoutException('Image download stalled', _stallTimeout),
        ),
      );

  @override
  int? get contentLength => _inner.contentLength;

  @override
  int get statusCode => _inner.statusCode;

  @override
  DateTime get validTill => _inner.validTill;

  @override
  String? get eTag => _inner.eTag;

  @override
  String get fileExtension => _inner.fileExtension;
}
