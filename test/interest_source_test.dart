import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/data/interceptor/interest_source_interceptor.dart';
import 'package:lumi_pass/data/service/interest_source.dart';
import 'package:dio/dio.dart';

/// The app's whole half of interest tracking is this one header.
///
/// The backend records WHAT a user opened from the catalog request it already
/// serves; the request for a class tapped in the home row and one opened from a
/// push notification are byte-for-byte identical, so only the app can say which
/// it was. If this stops being right, the console still shows every view — it
/// just stops being able to say where any of them came from, which is the kind
/// of failure nothing goes red for.
Route<dynamic> _route(String name) =>
    PageRouteBuilder(
      settings: RouteSettings(name: name),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    );

void main() {
  final tracker = InterestSourceTracker.instance;
  late InterestSourceObserver observer;

  setUp(() {
    observer = InterestSourceObserver();
    // The tracker is a process-wide singleton, so each test has to state the
    // ground it starts from rather than inherit the previous one's.
    tracker.pin(InterestSource.other);
  });

  group('the screen a class was opened from', () {
    test('a push from the home tab is attributed to home', () {
      observer.didPush(_route('ClassDetailRoute'), _route('HomeRoute'));

      expect(tracker.current, InterestSource.home);
    });

    test('a push from search results is attributed to search', () {
      observer.didPush(_route('ClassDetailRoute'), _route('SearchDiscoveryRoute'));

      expect(tracker.current, InterestSource.search);
    });

    test('a push from the map is attributed to the map', () {
      observer.didPush(_route('BranchDetailRoute'), _route('BranchesMapRoute'));

      expect(tracker.current, InterestSource.map);
    });

    // Half the app's routes are sheets and dialogs pushed over the screen the
    // user still considers themselves to be on. Clearing on those would turn
    // every class opened from a filtered search into an unattributed one.
    test('an unmapped screen leaves the last known source standing', () {
      observer.didPush(_route('ClassDetailRoute'), _route('SearchRoute'));
      observer.didPush(_route('BookingRoute'), _route('FilterBottomSheet'));

      expect(tracker.current, InterestSource.search);
    });

    test('a first push with nothing underneath it changes nothing', () {
      tracker.pin(InterestSource.deeplink);

      observer.didPush(_route('ClassDetailRoute'), null);

      // A deep link pins its own source precisely because no route can express
      // it — the user was not in the app at all.
      expect(tracker.current, InterestSource.deeplink);
    });

    test('going back re-attributes to the screen underneath', () {
      observer.didPush(_route('ClassDetailRoute'), _route('HomeRoute'));
      observer.didPop(_route('ClassDetailRoute'), _route('SearchRoute'));

      expect(tracker.current, InterestSource.search);
    });
  });

  group('the header the backend reads', () {
    late Dio dio;
    late List<RequestOptions> sent;

    setUp(() {
      sent = [];
      dio = Dio(BaseOptions(baseUrl: 'https://example.test/'));
      dio.interceptors.add(InterestSourceInterceptor());
      // Answer everything locally: what is asserted is the request, not a reply.
      dio.httpClientAdapter = _RecordingAdapter(sent);
    });

    test('a catalog read carries the screen it was made from', () async {
      tracker.pin(InterestSource.search);

      await dio.get('classes/abc');

      expect(sent.single.headers[kInterestSourceHeader], InterestSource.search);
    });

    // The header means nothing on a checkout or a profile write, and putting it
    // there would suggest that it did.
    test('a write carries nothing', () async {
      tracker.pin(InterestSource.search);

      await dio.post('orders', data: const {});

      expect(sent.single.headers.containsKey(kInterestSourceHeader), isFalse);
    });
  });
}

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(this.sent);

  final List<RequestOptions> sent;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    sent.add(options);
    return ResponseBody.fromString('{}', 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}
