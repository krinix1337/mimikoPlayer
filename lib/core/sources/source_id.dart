/// Музыкальные источники. `wire` — значение, которое лежит в SQLite; новый
/// источник не должен требовать миграции, поэтому колонки `source` — TEXT.
enum SourceId {
  yandex('yandex'),
  soundcloud('soundcloud'),
  youtube('youtube'),
  local('local'),
  spotify('spotify'),
  deezer('deezer');

  const SourceId(this.wire);

  final String wire;

  static SourceId fromWire(String wire) => values.firstWhere(
    (e) => e.wire == wire,
    orElse: () => throw ArgumentError('неизвестный источник: $wire'),
  );
}
