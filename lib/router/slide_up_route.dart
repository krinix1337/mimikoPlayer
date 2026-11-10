import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_motion.dart';
import '../theme/scroll_activity.dart';

/// Один переход на всё приложение — штатный M3 «fade forwards» (Android 15+):
/// новая страница въезжает справа с проявлением, прежняя уезжает влево.
CustomTransitionPage<void> slideUpPage(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: currentMotion.micro(
        _m3.transitionDuration.inMilliseconds,
      ),
      reverseTransitionDuration: currentMotion.micro(
        _m3.reverseTransitionDuration.inMilliseconds,
      ),
      transitionsBuilder: (context, animation, secondary, child) =>
          _m3Transition(context, animation, secondary, child),
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
  transitionDuration: currentMotion.micro(
    _m3.transitionDuration.inMilliseconds,
  ),
  reverseTransitionDuration: currentMotion.micro(
    _m3.reverseTransitionDuration.inMilliseconds,
  ),
  transitionsBuilder: (context, animation, secondary, child) =>
      _m3Transition(context, animation, secondary, child),
);

const _m3 = FadeForwardsPageTransitionsBuilder();

/// Длительность штатного перехода — для вкладок, которые переключаются
/// внутри одной страницы.
Duration get m3TransitionDuration =>
    currentMotion.micro(_m3.transitionDuration.inMilliseconds);

/// Тот же переход M3, что у страниц, но для вкладок: они живут на одной
/// странице навигатора и сами анимируют смену.
Widget m3TabTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondary,
  Widget child,
) => _m3Transition(context, animation, secondary, child);

Widget _m3Transition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondary,
  Widget child,
) {
  trackRouteAnimation(animation);
  final route = ModalRoute.of(context);
  if (route is! PageRoute<Object?>) return child;
  return _m3.buildTransitions(route, context, animation, secondary, child);
}
