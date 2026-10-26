import '../../core/sources/source_dto.dart';
import '../../core/sources/source_id.dart';
import '../../core/sources/stream_target.dart';

/// Разбор ответов `api-v2.soundcloud.com`.
///
/// SoundCloud отдаёт треки с `policy`/`access`/`streamable`; часть из них —
/// только 30-секундные превью (`preview`-ссылка) или зашифрованный HLS,
/// поэтому пригодность к воспроизведению проверяется здесь, а не в плеере.
final class SoundCloudDto {
  const SoundCloudDto._();

  static List<SourceTrack> searchTracks(Object? json) {
    if (json is! Map) return const [];
    final collection = json['collection'];
    if (collection is! List) return const [];
    return [
      for (final item in collection)
        if (item is Map) ?track(Map<String, dynamic>.from(item)),
    ];
  }

  /// `/tracks?ids=` отдаёт массив, `/tracks/{id}` — объект.
  static List<SourceTrack> tracks(Object? json) {
    final items = json is List ? json : [json];
    return [
      for (final item in items)
        if (item is Map) ?track(Map<String, dynamic>.from(item)),
    ];
  }

  static SourceTrack? track(Map<String, dynamic> json) {
    if (json['kind'] case final kind? when kind != 'track') return null;
    final rawId = json['id'];
    if (rawId == null) return null;

    final rawTitle = (json['title'] as String? ?? '').trim();
    if (rawTitle.isEmpty) return null;

    final streamable = json['streamable'] != false;
    final policy = (json['policy'] as String? ?? '').toUpperCase();
    final access = (json['access'] as String? ?? '').toLowerCase();
    final playable =
        streamable &&
        policy != 'BLOCK' &&
        access != 'blocked' &&
        access != 'preview';

    final publisher = json['publisher_metadata'];
    final publisherArtist = publisher is Map
        ? (publisher['artist'] as String? ?? '').trim()
        : '';
    final user = json['user'];
    final userName = user is Map
        ? (user['username'] as String? ?? '').trim()
        : '';

    final split = _splitTitle(rawTitle);
    final artists = <String>[
      if (publisherArtist.isNotEmpty) publisherArtist,
      if (publisherArtist.isEmpty) ...split.artists,
      if (publisherArtist.isEmpty &&
          split.artists.isEmpty &&
          userName.isNotEmpty)
        userName,
    ];

    final rawDuration = json['duration'];
    final durationMs = rawDuration is int
        ? rawDuration
        : int.tryParse('$rawDuration') ?? 0;

    return SourceTrack(
      ref: RemoteTrackRef(SourceId.soundcloud, '$rawId'),
      title: split.title,
      artists: artists.isEmpty ? const ['SoundCloud'] : artists,
      duration: Duration(milliseconds: durationMs),
      coverUrl:
          _cover(json['artwork_url']) ??
          _cover(user is Map ? user['avatar_url'] : null),
      available: playable,
      raw: {
        'permalink_url': json['permalink_url'],
        'policy': policy,
        'genre': json['genre'],
      },
    );
  }

  /// `-large`/`-t200x200` → `-t500x500`: карточкам нужен запас по размеру.
  static String? _cover(Object? value) {
    if (value is! String || value.isEmpty || !value.startsWith('https://')) {
      return null;
    }
    return value.replaceFirstMapped(
      RegExp(r'-(?:large|small|tiny|crop|badge|t\d+x\d+)\.'),
      (_) => '-t500x500.',
    );
  }

  /// Загрузки часто называются «Artist - Title»; без publisher-метаданных
  /// разбор нужен и для матчинга, и для нормального вида строки.
  static ({String title, List<String> artists}) _splitTitle(String raw) {
    final match = RegExp(r'^(.{2,80}?)\s+[-–—]\s+(.{2,})$').firstMatch(raw);
    if (match == null) return (title: raw, artists: const []);
    final artistPart = match.group(1)!.trim();
    final title = match.group(2)!.trim();
    final artists = [
      for (final part in artistPart.split(
        RegExp(r'\s*(?:,|&|\bx\b|\bfeat\.?\b|\bft\.?\b)\s*'),
      ))
        if (part.trim().length > 1) part.trim(),
    ];
    if (artists.isEmpty) return (title: raw, artists: const []);
    return (title: title, artists: artists);
  }

  /// Транскодинг, который реально можно отдать just_audio.
  ///
  /// Приоритет: progressive MP3 (простое скачивание и seek), затем
  /// незашифрованный HLS. `cbc-encrypted-hls`/`ctr-encrypted-hls` не играются
  /// без ключей и не считаются доступными.
  static Map<String, dynamic>? pickTranscoding(
    Map<String, dynamic> track, {
    Quality preferred = Quality.auto,
  }) {
    final media = track['media'];
    if (media is! Map) return null;
    final list = media['transcodings'];
    if (list is! List) return null;
    final items = [
      for (final item in list)
        if (item is Map) Map<String, dynamic>.from(item),
    ];

    Map<String, dynamic>? formatOf(Map<String, dynamic> item) {
      final format = item['format'];
      return format is Map ? Map<String, dynamic>.from(format) : null;
    }

    final progressive = items.where((item) {
      final format = formatOf(item);
      return format?['protocol'] == 'progressive' &&
          '${format?['mime_type']}'.contains('mpeg');
    }).toList();
    final hls = items.where((item) {
      final format = formatOf(item);
      return format?['protocol'] == 'hls';
    }).toList();

    // Progressive всегда предпочтителен: не зависит от HLS-плеера и качается
    // обычным HTTP, поэтому годится и для офлайна.
    if (progressive.isNotEmpty) return progressive.first;

    const order = ['aac_160k', 'mp3_1_0', 'aac_96k', 'abr_sq'];
    if (preferred == Quality.low) {
      const lowOrder = ['aac_96k', 'mp3_1_0', 'aac_160k', 'abr_sq'];
      for (final preset in lowOrder) {
        for (final item in hls) {
          if (item['preset'] == preset) return item;
        }
      }
    }
    for (final preset in order) {
      for (final item in hls) {
        if (item['preset'] == preset) return item;
      }
    }
    return hls.isEmpty ? null : hls.first;
  }

  static int bitrateOf(Map<String, dynamic>? transcoding) {
    if (transcoding == null) return 0;
    final format = transcoding['format'];
    final mime = format is Map ? '${format['mime_type']}' : '';
    if (mime.contains('mpeg')) return 128;
    return switch (transcoding['preset']) {
      'aac_160k' => 160,
      'aac_96k' => 96,
      'mp3_1_0' => 128,
      _ => 0,
    };
  }

  static String codecOf(Map<String, dynamic>? transcoding) {
    if (transcoding == null) return 'mp3';
    final format = transcoding['format'];
    final mime = format is Map ? '${format['mime_type']}' : '';
    return mime.contains('mp4') || '${transcoding['preset']}'.startsWith('aac')
        ? 'aac'
        : 'mp3';
  }

  /// Срок жизни подписанного медиа-URL из параметра `expires`.
  static DateTime? expiresAt(Object? value) {
    if (value is! String) return null;
    final uri = Uri.tryParse(value);
    final raw = uri?.queryParameters['expires'];
    final seconds = raw == null ? null : int.tryParse(raw);
    if (seconds == null || seconds <= 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }
}
