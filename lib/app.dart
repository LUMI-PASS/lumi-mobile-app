import 'package:auto_route/auto_route.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:founders_academy/routing/app_router.dart';

import 'core/api/http_inspector.dart';
import 'di/get_it.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _appRouter = getIt<AppRouter>();
  final _httpInspector = getIt<BaseHttpInspector>();

  @override
  void initState() {
    _httpInspector.init(_appRouter.navigatorKey);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChessThemeProvider(
      builder: (context) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: ChessColors.greyG900,

            appBarTheme: const AppBarTheme(color: ChessColors.greyG900, ),
            useMaterial3: true,
            scaffoldBackgroundColor: ChessColors.greyG900,
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: ChessColors.greyG800,
            ),
            fontFamily: FontFamily.nunito,
            textTheme: context.textTheme.theme.apply(
              displayColor: ChessColors.greyG10,
              bodyColor: ChessColors.greyG10,
            ),
          ),
          routerConfig: _appRouter.config(
            navigatorObservers: () => [AutoRouteObserver()],
          ),
          builder: (context, child) {
            return ChessButtonStyleScope(
              chessButtonStyle: ChessButtonStyle.fromTheme(
                textTheme: context.textTheme,
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
