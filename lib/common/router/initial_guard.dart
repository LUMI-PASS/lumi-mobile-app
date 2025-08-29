import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';

class InitialGuard extends AutoRouteGuard {
  final Storage storage = getIt<Storage>();

  InitialGuard();

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final showOnboard = storage.showOnboard.call();
    final token = storage.tokens.call();

    if (showOnboard!=false) {
      resolver.redirect(OnboardingRoute());
    } else if (token != null) {
      resolver.redirect(const MainRoute());
    } else {
      resolver.redirect(LoginRoute());
    }
  }
}
