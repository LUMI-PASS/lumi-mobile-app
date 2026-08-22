import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/data/service/interest_source.dart';

/// Header the backend reads to know where a catalog request came from.
const kInterestSourceHeader = 'X-Lumi-Source';

/// Stamps every catalog READ with the screen it was made from.
///
/// The backend records interest from the requests it already serves — a class
/// opened is `GET /classes/:id`, a search is `GET /discovery/classes?search=` —
/// which is why nothing here posts an event. All this adds is the one thing the
/// server cannot work out for itself: which screen the user was on.
///
/// GETs only. The header means nothing on a checkout or a profile write, and
/// attaching it there would suggest it did.
@injectable
class InterestSourceInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (options.method.toUpperCase() == 'GET') {
      final source = InterestSourceTracker.instance.current;
      if (source != null) options.headers[kInterestSourceHeader] = source;
    }
    handler.next(options);
  }
}
