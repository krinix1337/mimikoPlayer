import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app_providers.dart';
import 'routes.dart';

DateTime? _lastOpen;

/// Один вход в плеер на все списки: маршрут не должен оказаться в стеке
/// дважды из-за повторного тапа или двух обработчиков одного жеста.
void openPlayer(BuildContext context) => _open(GoRouter.of(context));

/// Вариант для роутера, захваченного до await.
void openPlayerRouter(GoRouter router) => _open(router);

/// После старта трека из списка: полный плеер открывается, только если это
/// включено в настройках. Иначе его приходилось закрывать после каждого тапа.
void openPlayerAfterPlay(GoRouter router) {
  final context = router.routerDelegate.navigatorKey.currentContext;
  if (context == null) return;
  final prefs = ProviderScope.containerOf(
    context,
    listen: false,
  ).read(prefsProvider);
  if (prefs.openPlayerOnPlay) _open(router);
}

void _open(GoRouter router) {
  final now = DateTime.now();
  if (router.routerDelegate.currentConfiguration.uri.path == Routes.player) {
    return;
  }
  if (_lastOpen != null &&
      now.difference(_lastOpen!) < const Duration(milliseconds: 450)) {
    return;
  }
  _lastOpen = now;
  router.push(Routes.player);
}
