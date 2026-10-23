import '../../core/sources/source_dto.dart';
import '../../core/sources/source_id.dart';

/// Разбор объекта трека Я.Музыки. Поля сверены с живым ответом
/// `/search` и `/tracks` (см. docs/API_PROBE.md): `isrc` там нет.
class YandexDto {
  const YandexDto._();

  static SourceTrack track(Map<String, dynamic> json) {
    final albums = _maps(json['albums']);
    final album = albums.isEmpty ? const <String, dynamic>{} : albums.first;
    final artists = _maps(json['artists']);

    return SourceTrack(
      ref: RemoteTrackRef(
        SourceId.yandex,
        '${json['id']}',
        albumId: album['id'] == null ? null : '${album['id']}',
      ),
      title: (json['title'] ?? '') as String,
      artists: [
        for (final artist in artists)
          if (artist['name'] != null) '${artist['name']}',
      ],
      artistIds: [
        for (final artist in artists)
          if (artist['id'] != null) '${artist['id']}',
      ],
      artistCovers: [
        for (final artist in artists)
          coverFrom(artist['cover'], size: '400x400'),
      ],
      album: album['title'] as String?,
      albumRemoteId: album['id'] == null ? null : '${album['id']}',
      duration: Duration(
        milliseconds: (json['durationMs'] as num?)?.toInt() ?? 0,
      ),
      coverUrl: coverUrl(json['coverUri'] ?? album['coverUri']),
      // Яндекс не отдаёт ISRC ни в поиске, ни в /tracks.
      isrc: json['isrc'] as String?,
      explicitFlag: json['explicit'] == true,
      lyricsAvailable: json['lyricsAvailable'] as bool?,
      available: json['available'] != false,
      availableForPremium: json['availableForPremiumUsers'] as bool?,
      raw: json,
    );
  }

  static List<SourceTrack> tracks(Object? value) => [
    for (final item in value is List ? value : const <Object>[])
      if (item is Map) track(Map<String, dynamic>.from(item)),
  ];

  /// `avatars.yandex.net/…/%%` → https-адрес с конкретным размером.
  static String? coverUrl(Object? coverUri, {String size = '400x400'}) {
    final raw = coverUri?.toString();
    if (raw == null || raw.isEmpty) return null;
    final withSize = raw.replaceFirst('%%', size);
    return withSize.startsWith('http') ? withSize : 'https://$withSize';
  }

  /// Обложка из любого вида, в котором её отдаёт API: строка `coverUri`,
  /// объект `cover.uri` или `ogImage`. У сломанной обложки в объекте живёт
  /// `error` и URI нет — тогда честно возвращаем null, а UI берёт запасную.
  static String? coverFrom(Object? cover, {String size = '400x400'}) {
    if (cover is String) return coverUrl(cover, size: size);
    if (cover is Map) {
      final uri = cover['uri'];
      if (uri is String && uri.isNotEmpty) return coverUrl(uri, size: size);
    }
    return null;
  }

  static List<Map<String, dynamic>> _maps(Object? value) => value is List
      ? [
          for (final item in value)
            if (item is Map) Map<String, dynamic>.from(item),
        ]
      : const [];
}
