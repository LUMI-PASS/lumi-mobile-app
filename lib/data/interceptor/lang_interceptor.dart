import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/common/utils/app_locale.dart';

/// Header the backend reads to resolve the request's language, ahead of the
/// legacy `?lang=` query param individual endpoints still accept.
const kLanguageHeader = 'X-Language';

/// Stamps every request with the app's current language, so call sites stop
/// repeating `queryParameters: {'lang': currentLang}` by hand.
@injectable
class LangInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    options.headers[kLanguageHeader] = currentLang;
    handler.next(options);
  }
}
