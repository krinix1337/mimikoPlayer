import 'package:flutter/material.dart';

import 'app_logger.dart';

/// Экран логов: что реально произошло в процессе, без пересъёмки logcat.
class LogScreen extends StatelessWidget {
  const LogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Логи'),
        actions: [
          IconButton(
            onPressed: () => AppLogger.instance.clear(),
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Очистить',
          ),
        ],
      ),
      body: StreamBuilder<void>(
        stream: AppLogger.instance.changes,
        builder: (context, _) {
          final lines = AppLogger.instance.lines;
          if (lines.isEmpty) return const Center(child: Text('Пока пусто'));
          return ListView.builder(
            reverse: true,
            itemCount: lines.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: SelectableText(
                lines[lines.length - 1 - index],
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          );
        },
      ),
    );
  }
}
