import 'dart:async';

import 'package:flutter/widgets.dart';

/// Глобальный флаг активной прокрутки. Пока он true, стеклянные панели не
/// запускают BackdropFilter каждый кадр, а показывают плотную подложку:
/// на бюджетном железе именно повторный blur подложки даёт просадки.
/// После остановки стекло возвращается.
final ValueNotifier<bool> appScrollActive = ValueNotifier<bool>(false);

class ScrollActivityTracker extends StatefulWidget {
  const ScrollActivityTracker({super.key, required this.child});

  final Widget child;

  @override
  State<ScrollActivityTracker> createState() => _ScrollActivityTrackerState();
}

class _ScrollActivityTrackerState extends State<ScrollActivityTracker> {
  Timer? _idle;

  void _markActive() {
    appScrollActive.value = true;
    _idle?.cancel();
    _idle = Timer(const Duration(milliseconds: 140), _markIdle);
  }

  void _markIdle() {
    appScrollActive.value = false;
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
    appScrollActive.value = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: widget.child,
      );
}
