import 'source_errors.dart';
import 'source_id.dart';

/// Куда плееру реально смотреть. Игровой код не знает про конкретный источник.
sealed class StreamTarget {
  const StreamTarget();
}

final class StreamUrl extends StreamTarget {
  const StreamUrl({
    required this.url,
    required this.expiresAt,
    this.headers = const {},
    this.cacheKey,
  });

  final Uri url;

  /// Заголовки держим отдельно от URL: just_audio принимает `httpHeaders`,
  /// а запись их в query ломает кэш и лог запросов.
  final Map<String, String> headers;

  final DateTime expiresAt;

  /// Ключ для прогрессивного кэша (этап «офлайн»).
  final String? cacheKey;

  bool isExpiredAt(DateTime now) => !now.isBefore(expiresAt);
}

final class StreamFile extends StreamTarget {
  const StreamFile(this.path);

  final String path;
}

/// Что удалось получить и чем это подкреплёно.
sealed class StreamResult {
  const StreamResult();
}

final class StreamReady extends StreamResult {
  const StreamReady({
    required this.target,
    required this.source,
    required this.quality,
    this.codec,
    this.bitrateKbps,
    this.ttlHint,
  });

  final StreamTarget target;
  final SourceId source;
  final Quality quality;
  final String? codec;
  final int? bitrateKbps;

  /// Оценка источника, сколько живёт ссылка. Резолвер ей ограничивает TTL.
  final Duration? ttlHint;
}

final class StreamFailed extends StreamResult {
  const StreamFailed(this.failure);

  final SourceFailure failure;
}

enum Quality {
  auto('auto'),
  low('low'),
  normal('normal'),
  high('high'),
  lossless('lossless');

  const Quality(this.wire);

  final String wire;

  static Quality fromWire(String wire) => values.firstWhere(
    (e) => e.wire == wire,
    orElse: () => Quality.auto,
  );
}
