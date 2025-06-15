import 'package:auto_route/auto_route.dart';
import 'package:founders_academy/routing/app_router.gr.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
@AutoRouterConfig()
class AppRouter extends $AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          initial: true,
          page: AppContainerRoute.page,
          children: [
            AutoRoute(
              page: SplashRoute.page,
              initial: true,
            ),
            AutoRoute(
              page: ForceUpdateRoute.page,
            ),
            AutoRoute(
              page: UnauthorizedContainerRoute.page,
              children: [
                AutoRoute(
                  page: SignInRoute.page,
                  initial: true,
                ),
                AutoRoute(
                  page: OtpRoute.page,
                ),
                AutoRoute(
                  page: ConnectionErrorRoute.page,
                ),
              ],
            ),
            AutoRoute(
              page: RegistrationContainerRoute.page,
              children: [
                AutoRoute(
                  initial: true,
                  page: RegistrationPersonalInfoRoute.page,
                ),
                AutoRoute(
                  page: RegistrationSuccessRoute.page,
                ),
                AutoRoute(
                  page: RegistrationAddressRoute.page,
                ),
                AutoRoute(
                  page: RegistrationEducationRoute.page,
                ),
                AutoRoute(
                  page: ConnectionErrorRoute.page,
                ),
              ],
            ),
            AutoRoute(
              page: AuthorizedContainerRoute.page,
              children: [
                AutoRoute(
                  initial: true,
                  page: MainRoute.page,
                  children: [
                    AutoRoute(
                      page: HomeRoute.page,
                    ),
                    AutoRoute(
                      page: CoursesRoute.page,
                    ),
                    AutoRoute(
                      page: PuzzleListRoute.page,
                    ),
                    AutoRoute(
                      page: DiscussionsRoute.page,
                    ),
                    AutoRoute(
                      page: ProfileContainerRoute.page,
                      children: [
                        AutoRoute(
                          initial: true,
                          page: ProfileRoute.page,
                        ),
                        AutoRoute(
                          page: ProfileDetailRoute.page,
                        ),
                        AutoRoute(
                          page: ProfileEditDetailRoute.page,
                        ),
                      ],
                    ),
                  ],
                ),
                AutoRoute(
                  page: PuzzleDetailsRoute.page,
                ),
                AutoRoute(
                  page: GrandmasterDetailsRoute.page,
                ),
                AutoRoute(
                  page: ReviewMatchesListRoute.page,
                ),
                AutoRoute(
                  page: AfishaListRoute.page,
                ),
                AutoRoute(
                  page: AfishaDetailsRoute.page,
                ),
                AutoRoute(
                  page: NewsListRoute.page,
                ),
                AutoRoute(
                  page: NewsDetailsRoute.page,
                ),
                AutoRoute(
                  page: AddPostRoute.page,
                ),
                AutoRoute(
                  page: GrandmastersListRoute.page,
                ),
                AutoRoute(
                  page: BookListRoute.page,
                ),
                AutoRoute(
                  page: ReviewMatchDetailsRoute.page,
                ),
                AutoRoute(
                  page: BookDetailsRoute.page,
                ),
                AutoRoute(
                  page: CourseDetailsRoute.page,
                ),
                AutoRoute(
                  page: QuizDetailsRoute.page,
                ),
                AutoRoute(
                  page: LessonDetailsRoute.page,
                ),
                AutoRoute(
                  page: QuizResultRoute.page,
                ),
                AutoRoute(
                  page: BookPdfRoute.page,
                ),
                AutoRoute(
                  page: ConnectionErrorRoute.page,
                ),
                AutoRoute(
                  page: LeaderboardRoute.page,
                ),
                AutoRoute(
                  page: ProfileDeleteRoute.page,
                ),
                AutoRoute(
                  page: NotificationRoute.page,
                ),
                AutoRoute(
                  page: PuzzleQuickTypeRoute.page,
                ),
                AutoRoute(
                  page: PuzzleQuickDetailsRoute.page,
                ),
                AutoRoute(
                  page: PuzzleResultRoute.page,
                ),
                AutoRoute(
                  page: AfishaRegistrationRoute.page,
                ),
                AutoRoute(
                  page: AfishaResultRoute.page,
                ),
                AutoRoute(
                  page: PuzzleListBotRoute.page,
                ),
                AutoRoute(
                  page: PuzzleWithBotRoute.page,
                ),
                AutoRoute(
                  page: MyCertificateRoute.page,
                ),
                AutoRoute(
                  page: MyCertificatePdfRoute.page,
                ),
              ],
            ),
          ],
        ),
      ];
}
