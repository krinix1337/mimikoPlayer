import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_motion.dart';
import '../theme/scroll_activity.dart';

/// Один переход на всё приложение: страница выезжает снизу с мягким
/// проявлением. Используется и роутером, и обычными push из настроек.
CustomTransitionPage<void> slideUpPage(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: currentMotion.morph,
      reverseTransitionDuration: currentMotion.exit,
      transitionsBuilder: (context, animation, secondary, child) =>
          _slideUp(animation, child),
    );

/// Плеер — лист снизу: выезжает на всю высоту и уезжает вниз, как его и
/// сворачивают пальцем. Маршрут прозрачный: пока плеер тянут вниз, под
/// ним виден экран, а не чёрная пустота.
CustomTransitionPage<void> playerSheetPage(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      opaque: false,
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (context, animation, secondary, child) {
        trackRouteAnimation(animation);
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            ),
          ),
          child: child,
        );
      },
    );

Route<void> slideUpRoute(Widget page) => PageRouteBuilder<void>(
  pageBuilder: (context, animation, secondary) => page,
  transitionDuration: currentMotion.morph,
  reverseTransitionDuration: currentMotion.exit,
  transitionsBuilder: (context, animation, secondary, child) =>
      _slideUp(animation, child),
);

Widget _slideUp(Animation<double> animation, Widget child) {
  trackRouteAnimation(animation);
  final curved = CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );
  // Проявление только в начале пути: пока opacity < 1, вся страница рисуется
  // в отдельный слой на каждом кадре, а с размытием внутри это до 80 мс на
  // кадр. После 30% страница уже непрозрачна, и слой не нужен.
  final fade = CurvedAnimation(
    parent: animation,
    curve: const Interval(0, 0.3, curve: Curves.easeOut),
    reverseCurve: const Interval(0, 0.3, curve: Curves.easeIn),
  );
  return FadeTransition(
    opacity: fade,
    child: SlideTransition(
      position: Tween(
        begin: const Offset(0, 0.06),
        end: Offset.zero,
      ).animate(curved),
      child: child,
    ),
  );
}
