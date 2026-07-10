import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/data/service/remote_config_service.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';

class InitialGuard extends AutoRouteGuard {
  final Storage storage = getIt<Storage>();

  InitialGuard();

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    try {
      final showOnboard = storage.showOnboard.call();
      final token = storage.tokens.call();
      final inReview = RemoteConfigService.instance.isInReview;

      if (showOnboard != false) {
        resolver.redirect(const WelcomeRoute());
      } else if (token != null || inReview) {
        resolver.redirect(const MainRoute());
      } else {
        resolver.redirect(LoginRoute());
      }
    } catch (_) {
      resolver.redirect(LoginRoute());
    }
  }
}
