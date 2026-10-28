import 'dart:async';

import 'package:flutter/widgets.dart';

/// Глобальный флаг «экран в движении»: прокрутка или переход между
/// страницами. Пока он true, стеклянные панели не запускают BackdropFilter
/// каждый кадр, а показывают плотную подложку: на бюджетном железе именно
/// повторный blur подложки даёт просадки. После остановки стекло возвращается.
final ValueNotifier<bool> appScrollActive = ValueNotifier<bool>(false);

bool _scrolling = false;
int _transitions = 0;

void _sync() => appScrollActive.value = _scrolling || _transitions > 0;

final Expando<bool> _trackedRoutes = Expando<bool>();

/// Подписать анимацию перехода на флаг: пока страница едет, стекло плотное.
/// Повторные вызовы с той же анимацией (каждая перестройка перехода)
/// ничего не добавляют.
void trackRouteAnimation(Animation<double> animation) {
  if (_trackedRoutes[animation] == true) return;
  _trackedRoutes[animation] = true;
  var moving = false;
  animation.addStatusListener((status) {
    final now =
        status == AnimationStatus.forward || status == AnimationStatus.reverse;
    if (now == moving) return;
    moving = now;
    _transitions = (_transitions + (now ? 1 : -1)).clamp(0, 1 << 20);
    _sync();
    // Маршрут могут убрать прямо посреди анимации, и статус «закончилась»
    // тогда не придёт: без сброса стекло так и осталось бы плотным.
    _stuckReset?.cancel();
    if (_transitions > 0) {
      _stuckReset = Timer(const Duration(milliseconds: 1500), () {
        _transitions = 0;
        _sync();
      });
    }
  });
}

Timer? _stuckReset;

class ScrollActivityTracker extends StatefulWidget {
  const ScrollActivityTracker({super.key, required this.child});

  final Widget child;

  @override
  State<ScrollActivityTracker> createState() => _ScrollActivityTrackerState();
}

class _ScrollActivityTrackerState extends State<ScrollActivityTracker> {
  Timer? _idle;

  void _markActive() {
    _scrolling = true;
    _sync();
    _idle?.cancel();
    _idle = Timer(const Duration(milliseconds: 140), _markIdle);
  }

  void _markIdle() {
    _scrolling = false;
    _sync();
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification is ScrollStartNotification ||
        notification is ScrollUpdateNotification ||
        notification is OverscrollNotification) {
      _markActive();
    } else if (notification is ScrollEndNotification) {
      _idle?.cancel();
      _idle = Timer(const Duration(milliseconds: 140), _markIdle);
    }
    return false;
  }

  @override
  void dispose() {
    _idle?.cancel();
    _scrolling = false;
    _sync();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: widget.child,
      );
}
