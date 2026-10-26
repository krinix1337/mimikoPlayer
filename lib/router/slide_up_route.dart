import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_motion.dart';

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

Route<void> slideUpRoute(Widget page) => PageRouteBuilder<void>(
  pageBuilder: (context, animation, secondary) => page,
  transitionDuration: currentMotion.morph,
  reverseTransitionDuration: currentMotion.exit,
  transitionsBuilder: (context, animation, secondary, child) =>
      _slideUp(animation, child),
);

Widget _slideUp(Animation<double> animation, Widget child) {
  final curved = CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );
  return FadeTransition(
    opacity: curved,
    child: SlideTransition(
      position: Tween(
        begin: const Offset(0, 0.06),
        end: Offset.zero,
      ).animate(curved),
      child: child,
    ),
  );
}
