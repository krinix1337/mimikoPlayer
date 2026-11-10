import 'package:drift/drift.dart';

import '../database.dart';

/// Сводка за период: всё время, засчитанные прослушивания, разные треки.
class StatsSummary {
  const StatsSummary({
    required this.listened,
    required this.plays,
    required this.tracks,
  });

  final Duration listened;
  final int plays;
  final int tracks;
}

class StatsEntry {
  const StatsEntry({
    required this.id,
    required this.title,
    required this.listened,
    required this.plays,
    this.subtitle,
    this.coverUrl,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String? coverUrl;
  final Duration listened;
  final int plays;
}

/// Статистика прослушиваний поверх истории. Трек засчитывается после 30 с
/// или если доигран до конца; время считается по всем прослушиваниям.
class StatsDao {
  StatsDao(this._db);

  final AppDatabase _db;

  static const _counted = '(h.played_ms >= 30000 OR h.completed = 1)';

  /// Drift хранит даты в секундах эпохи.
  static int _sec(DateTime t) => t.millisecondsSinceEpoch ~/ 1000;

  Future<StatsSummary> summary(DateTime? since) async {
    final row = await _db
        .customSelect(
          'SELECT COALESCE(SUM(h.played_ms), 0) AS ms, '
          'COALESCE(SUM(CASE WHEN $_counted THEN 1 ELSE 0 END), 0) AS plays, '
          'COUNT(DISTINCT CASE WHEN $_counted THEN h.local_track_id END) AS tracks '
          'FROM history h WHERE h.in_stats = 1 AND h.played_at >= ?',
          variables: [Variable.withInt(since == null ? 0 : _sec(since))],
          readsFrom: {_db.history},
        )
        .getSingle();
    return StatsSummary(
      listened: Duration(milliseconds: row.read<int>('ms')),
      plays: row.read<int>('plays'),
      tracks: row.read<int>('tracks'),
    );
  }

  /// Минуты прослушивания по локальным дням, начиная с [since].
  Future<Map<DateTime, Duration>> daily(DateTime since) async {
    final rows = await _db
        .customSelect(
          'SELECT h.played_at AS at, h.played_ms AS ms FROM history h '
          'WHERE h.in_stats = 1 AND h.played_at >= ?',
          variables: [Variable.withInt(_sec(since))],
          readsFrom: {_db.history},
        )
        .get();
    final out = <DateTime, Duration>{};
    for (final r in rows) {
      final at = DateTime.fromMillisecondsSinceEpoch(r.read<int>('at') * 1000);
      final day = DateTime(at.year, at.month, at.day);
      out[day] =
          (out[day] ?? Duration.zero) +
          Duration(milliseconds: r.read<int>('ms'));
    }
    return out;
  }

  /// Минуты прослушивания по часам (0–23) начиная с [since].
  Future<List<Duration>> hourly(DateTime since) async {
    final rows = await _db
        .customSelect(
          'SELECT h.played_at AS at, h.played_ms AS ms FROM history h '
          'WHERE h.in_stats = 1 AND h.played_at >= ?',
          variables: [Variable.withInt(_sec(since))],
          readsFrom: {_db.history},
        )
        .get();
    final out = List<Duration>.filled(24, Duration.zero);
    for (final r in rows) {
      final at = DateTime.fromMillisecondsSinceEpoch(r.read<int>('at') * 1000);
      out[at.hour] += Duration(milliseconds: r.read<int>('ms'));
    }
    return out;
  }

  Future<List<StatsEntry>> topTracks(DateTime? since, {int limit = 5}) async {
    final rows = await _db
        .customSelect(
          'SELECT t.id AS id, t.title AS title, t.cover_url AS cover, '
          'a.name AS artist, SUM(h.played_ms) AS ms, COUNT(*) AS n FROM history h '
          'JOIN tracks t ON t.id = h.local_track_id '
          'LEFT JOIN artists a ON a.id = t.main_artist_id '
          'WHERE h.in_stats = 1 AND $_counted AND h.played_at >= ? '
          'GROUP BY t.id ORDER BY ms DESC LIMIT ?',
          variables: [
            Variable.withInt(since == null ? 0 : _sec(since)),
            Variable.withInt(limit),
          ],
          readsFrom: {_db.history, _db.tracks, _db.artists},
        )
        .get();
    return [
      for (final r in rows)
        StatsEntry(
          id: r.read<String>('id'),
          title: r.read<String>('title'),
          subtitle: r.readNullable<String>('artist'),
          coverUrl: r.readNullable<String>('cover'),
          listened: Duration(milliseconds: r.read<int>('ms')),
          plays: r.read<int>('n'),
        ),
    ];
  }

  Future<List<StatsEntry>> topArtists(DateTime? since, {int limit = 5}) async {
    final rows = await _db
        .customSelect(
          'SELECT a.id AS id, a.name AS name, a.cover_url AS cover, '
          'SUM(h.played_ms) AS ms, COUNT(*) AS n FROM history h '
          'JOIN tracks t ON t.id = h.local_track_id '
          'JOIN artists a ON a.id = t.main_artist_id '
          'WHERE h.in_stats = 1 AND $_counted AND h.played_at >= ? '
          'GROUP BY a.id ORDER BY ms DESC LIMIT ?',
          variables: [
            Variable.withInt(since == null ? 0 : _sec(since)),
            Variable.withInt(limit),
          ],
          readsFrom: {_db.history, _db.tracks, _db.artists},
        )
        .get();
    return [
      for (final r in rows)
        StatsEntry(
          id: '${r.read<int>('id')}',
          title: r.read<String>('name'),
          coverUrl: r.readNullable<String>('cover'),
          listened: Duration(milliseconds: r.read<int>('ms')),
          plays: r.read<int>('n'),
        ),
    ];
  }

  /// Все засчитываемые записи для экспорта в JSON.
  Future<List<Map<String, Object?>>> exportRows() async {
    final rows = await _db
        .customSelect(
          'SELECT h.played_at AS at, h.played_ms AS ms, h.completed AS done, '
          't.title AS title, a.name AS artist FROM history h '
          'JOIN tracks t ON t.id = h.local_track_id '
          'LEFT JOIN artists a ON a.id = t.main_artist_id '
          'WHERE h.in_stats = 1 ORDER BY h.played_at',
          readsFrom: {_db.history, _db.tracks, _db.artists},
        )
        .get();
    return [
      for (final r in rows)
        {
          'playedAt': DateTime.fromMillisecondsSinceEpoch(
            r.read<int>('at') * 1000,
          ).toIso8601String(),
          'playedMs': r.read<int>('ms'),
          'completed': r.read<int>('done') == 1,
          'title': r.read<String>('title'),
          'artist': r.readNullable<String>('artist'),
        },
    ];
  }

  /// Убирает всё из статистики, оставляя историю волне.
  Future<void> clear() =>
      (_db.update(_db.history))
          .write(const HistoryCompanion(inStats: Value(false)));
}
