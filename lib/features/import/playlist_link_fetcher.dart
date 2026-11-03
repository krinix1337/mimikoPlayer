import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/links/yandex_playlist_link.dart';
import '../../sources/soundcloud/soundcloud_source.dart';

/// Что нашлось по ссылке на открытый плейлист.
sealed class PlaylistLinkResult {
  const PlaylistLinkResult();
}

/// Плейлист Яндекса открываем как есть, без переноса.
final class PlaylistLinkYandex extends PlaylistLinkResult {
  const PlaylistLinkYandex(this.remotePlaylistId);

  final String remotePlaylistId;
}

/// Чужой сервис: строки «Исполнитель — Название» для обычного импорта списка.
final class PlaylistLinkRows extends PlaylistLinkResult {
  const PlaylistLinkRows({required this.title, required this.rows});

  final String title;
  final List<String> rows;
}

/// Достаёт список треков из публичной ссылки на плейлист: Яндекс Музыка,
/// Spotify и SoundCloud. Вход в эти сервисы не нужен — только открытые
/// плейлисты.
final class PlaylistLinkFetcher {
  PlaylistLinkFetcher({required this.soundCloud, Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 20),
              headers: {'User-Agent': 'Mozilla/5.0 (Linux; Android 14)'},
            ),
          );

  final SoundCloudSource? soundCloud;
  final Dio _dio;

  static final _url = RegExp(r'https?://[^\s<>"]+', caseSensitive: false);

  /// null — ссылка не похожа на плейлист или сервис не ответил.
  Future<PlaylistLinkResult?> fetch(String text) async {
    final yandex = YandexPlaylistLink.tryParse(text);
    if (yandex != null) return PlaylistLinkYandex(yandex.remotePlaylistId);

    final match = _url.firstMatch(text);
    final uri = match == null ? null : Uri.tryParse(match.group(0)!);
    if (uri == null) return null;
    final host = uri.host.toLowerCase();
    if (host.endsWith('spotify.com')) return _spotify(uri);
    if (host.endsWith('soundcloud.com')) {
      final rows = await soundCloud?.playlistRows(uri.toString());
      if (rows == null || rows.rows.isEmpty) return null;
      return PlaylistLinkRows(title: rows.title, rows: rows.rows);
    }
    return null;
  }

  /// Встраиваемая страница Spotify отдаёт трек-лист в `__NEXT_DATA__`
  /// без токена: название трека в `title`, исполнители в `subtitle`.
  Future<PlaylistLinkResult?> _spotify(Uri uri) async {
    final parts = uri.pathSegments.where((p) => p.isNotEmpty).toList();
    final at = parts.indexWhere((p) => p == 'playlist' || p == 'album');
    if (at < 0 || at + 1 >= parts.length) return null;
    final embed =
        'https://open.spotify.com/embed/${parts[at]}/${parts[at + 1]}';
    final response = await _dio.get<String>(
      embed,
      options: Options(responseType: ResponseType.plain),
    );
    final html = response.data ?? '';
    final script = RegExp(
      r'<script id="__NEXT_DATA__" type="application/json">(.*?)</script>',
      dotAll: true,
    ).firstMatch(html);
    if (script == null) return null;
    final entity = _find(jsonDecode(script.group(1)!), 'trackList');
    if (entity is! Map || entity['trackList'] is! List) return null;
    final rows = <String>[
      for (final track in entity['trackList'] as List)
        if (track is Map &&
            '${track['title'] ?? ''}'.trim().isNotEmpty &&
            '${track['subtitle'] ?? ''}'.trim().isNotEmpty)
          '${'${track['subtitle']}'.split(',').first.trim()} - '
              '${'${track['title']}'.trim()}',
    ];
    if (rows.isEmpty) return null;
    final title = '${entity['name'] ?? entity['title'] ?? ''}'.trim();
    return PlaylistLinkRows(title: title, rows: rows);
  }

  /// Первый объект в дереве JSON, у которого есть ключ [key].
  static Object? _find(Object? node, String key) {
    if (node is Map) {
      if (node.containsKey(key)) return node;
      for (final value in node.values) {
        final found = _find(value, key);
        if (found != null) return found;
      }
    } else if (node is List) {
      for (final value in node) {
        final found = _find(value, key);
        if (found != null) return found;
      }
    }
    return null;
  }
}
