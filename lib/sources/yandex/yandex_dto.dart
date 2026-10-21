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
      album: album['title'] as String?,
      albumRemoteId: album['id'] == null ? null : '${album['id']}',
      duration: Duration(milliseconds: (json['durationMs'] as num?)?.toInt() ?? 0),
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
  static String? coverUrl(Object? coverUri) {
    final raw = coverUri?.toString();
    if (raw == null || raw.isEmpty) return null;
    final withSize = raw.replaceFirst('%%', '400x400');
    return withSize.startsWith('http') ? withSize : 'https://$withSize';
  }

  static List<Map<String, dynamic>> _maps(Object? value) => value is List
      ? [
          for (final item in value)
            if (item is Map) Map<String, dynamic>.from(item),
        ]
      : const [];
}
