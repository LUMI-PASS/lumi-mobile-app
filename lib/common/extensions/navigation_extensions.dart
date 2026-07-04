import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Fast fade for web, native slide for mobile.
PageRouteBuilder<T> _buildRoute<T>(Widget page) {
  if (kIsWeb) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 120),
      reverseTransitionDuration: const Duration(milliseconds: 100),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }
  return PageRouteBuilder<T>(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (_, animation, __, child) {
      final tween = Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
          .chain(CurveTween(curve: Curves.ease));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

extension NavigationExtensions on BuildContext {
  Future<T?> push<T extends Object?>(Widget page) =>
      Navigator.of(this).push(_buildRoute<T>(page));

  Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    Widget page, {
    TO? result,
  }) =>
      Navigator.of(this).pushReplacement(_buildRoute<T>(page), result: result);

  Future<T?> pushAndRemoveUntil<T extends Object?>(
    Widget newPage,
    RoutePredicate predicate,
  ) =>
      Navigator.of(this)
          .pushAndRemoveUntil(_buildRoute<T>(newPage), predicate);

  Future<T?> pushAndRemoveAll<T>(Widget newPage) =>
      Navigator.of(this).pushAndRemoveUntil<T>(
        _buildRoute<T>(newPage),
        (route) => false,
      );

  void pop<T extends Object?>([T? result]) => Navigator.of(this).pop(result);

  Future<T?> pushForResult<T extends Object?>(Widget page) =>
      Navigator.of(this)
          .push<T>(MaterialPageRoute(builder: (_) => page));

  void popToFirst() =>
      Navigator.of(this).popUntil((route) => route.isFirst);

  bool canPop() => Navigator.of(this).canPop();
}
