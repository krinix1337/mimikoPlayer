import 'dart:async';

import 'package:flutter/foundation.dart';

/// Кольцевой буфер логов + экран в приложении. На телефоне без USB-лога
/// это единственный способ увидеть, почему цепочка источников отказала.
class AppLogger {
  AppLogger._();

  static final AppLogger instance = AppLogger._();

  static const int _capacity = 500;

  final List<String> _lines = [];
  final StreamController<void> _changes = StreamController<void>.broadcast();

  /// Сигнал «буфер изменился»: содержимое читают через [lines].
  Stream<void> get changes => _changes.stream;

  List<String> get lines => List.unmodifiable(_lines);

  void info(String message) => _add('I', message);

  void warn(String message) => _add('W', message);

  void error(String message, [Object? error]) =>
      _add('E', error == null ? message : '$message: $error');

  void _add(String level, String message) {
    final stamp = DateTime.now().toIso8601String().substring(11, 23);
    _lines.add('$stamp $level $message');
    if (_lines.length > _capacity) _lines.removeRange(0, _lines.length - _capacity);
    // Заодно в logcat: на телефоне без подключения к IDE это единственный
    // способ увидеть, что решило делать плеер.
    debugPrint('phoneyandex $level $stamp $message');
    if (!_changes.isClosed) _changes.add(null);
  }

  void clear() {
    _lines.clear();
    if (!_changes.isClosed) _changes.add(null);
  }
}
