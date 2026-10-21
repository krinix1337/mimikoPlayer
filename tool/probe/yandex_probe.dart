// Зонд живых эндпоинтов Я.Музыки: `dart run tool/probe/yandex_probe.dart <команда>`.
// Всё, что здесь помечено как непроверенное, после запуска переносится в
// docs/API_PROBE.md. Команды только читают аккаунт, ничего не меняют.
library;

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

const apiBase = 'https://api.music.yandex.net';
const oauthDeviceCodeUrl = 'https://oauth.yandex.ru/device/code';
const oauthTokenUrl = 'https://oauth.yandex.ru/token';

// Публичные реквизиты клиента Я.Музыки, которыми пользуется открытая
// реализация device flow.
const clientId = String.fromEnvironment(
  'YM_CLIENT_ID',
  defaultValue: '23cabbbdc6cd418abb4b39c32c41195d',
);
const clientSecret = String.fromEnvironment(
  'YM_CLIENT_SECRET',
  defaultValue: '53bc75238f0c4d08a118e51fe9203300',
);
const deviceName = 'phoneyandex-probe';

final tokenFile = File('C:/project/musor/yandex_token.txt');

Future<void> main(List<String> args) async {
  final command = args.isEmpty ? 'help' : args.first;
  final rest = args.skip(1).toList();

  switch (command) {
    case 'login':
      await login();
    case 'status':
      await getJson('/account/status');
    case 'search':
      await search(rest.isEmpty ? 'ария' : rest.join(' '));
    case 'tracks':
      await tracksProbe(rest);
    case 'likes':
      await likes();
    case 'playlists':
      await playlists();
    case 'wave':
      await wave();
    case 'postvariants':
      final token = await _token();
      final id = rest.isEmpty ? '147872699-40512013' : rest.first;
      final attempts = <List<String>>[
        ['form', 'track-ids=$id'],
        ['form-camel', 'trackIds=$id'],
        ['form-json-field', 'track-ids=$id&format=json'],
        ['json', '{"trackIds":["$id"]}'],
        ['json-kebab', '{"track-ids":["$id"]}'],
        ['json-obj', '{"trackIds":{"$id":"$id"}}'],
      ];
      for (final attempt in attempts) {
        final r = await _postRaw('$apiBase/tracks', attempt[0], attempt[1], token);
        stdout.writeln('${r.statusCode} ${attempt[0]} -> ${_trim(r.body, 150)}');
      }
    case 'gettracks':
      final token = await _token();
      for (final uri in [
        Uri.parse('$apiBase/tracks?track-ids=${rest.first}'),
        Uri.parse('$apiBase/tracks?track-ids=${rest.first}&format=json'),
      ]) {
        final r = await _getRaw(uri, token);
        stdout.writeln('${r.statusCode} GET $uri');
        stdout.writeln('  ${_trim(r.body, 260)}');
      }
      final post = await _postFormQuery('$apiBase/tracks?track-ids=${rest.first}');
      stdout.writeln('${post.statusCode} POST /tracks?track-ids=...');
      stdout.writeln('  ${_trim(post.body, 260)}');
    case 'raw':
      if (rest.isEmpty) {
        stderr.writeln('нужен путь, например: raw /search?text=ария');
        exit(2);
      }
      await raw(rest.join(' '));
    case 'signprobe':
      await signProbe(rest.isEmpty ? '147872699' : rest.first);
    case 'xml':
      await xmlDump(rest.isEmpty ? '147872699' : rest.first);
    case 'downloadinfo':
      await downloadInfo(rest.isEmpty ? '147872699' : rest.first);
    case 'stream':
      if (rest.isEmpty) {
        stderr.writeln('нужен trackId, например: stream 42151373');
        exit(2);
      }
      await streamProbe(rest.first);
    default:
      stdout.writeln('''
команды: login | status | search <текст> | likes | playlists | wave | stream <trackId>''');
  }
}

Future<void> login() async {
  final deviceId = _deviceId();
  final code = await _postForm(
    oauthDeviceCodeUrl,
    {
      'client_id': clientId,
      'device_id': deviceId,
      'device_name': deviceName,
    },
  );

  if (code['error'] != null) {
    stderr.writeln('device/code отказал: ${jsonEncode(code)}');
    exit(1);
  }

  stdout.writeln('Открой ${(code['verification_url'] ?? 'https://music.yandex.ru/activate2')}');
  stdout.writeln('и введи код: ${code['user_code']}   (истекает через ${code['expires_in']} c)');

  final interval = (code['interval'] as num?)?.toInt() ?? 5;
  final deadline = DateTime.now().add(
    Duration(seconds: (code['expires_in'] as num?)?.toInt() ?? 300),
  );

  while (DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(Duration(seconds: interval));
    final token = await _postForm(oauthTokenUrl, {
      'grant_type': 'device_code',
      'code': code['device_code'],
      'client_id': clientId,
      'client_secret': clientSecret,
    });

    if (token['access_token'] != null) {
      await tokenFile.writeAsString('${token['access_token']}\n');
      stdout.writeln('токен получен (${(token['access_token'] as String).length} симв.) '
          'и сохранён в ${tokenFile.path}');
      stdout.writeln('expires_in=${token['expires_in']} '
          'refresh_token=${token['refresh_token'] != null ? 'есть' : 'нет'}');
      return;
    }
    if (token['error'] == 'authorization_pending') {
      stdout.writeln('ждём подтверждения…');
      continue;
    }
    stderr.writeln('token отказал: ${jsonEncode(token)}');
    exit(1);
  }
  stderr.writeln('истёк срок подтверждения');
  exit(1);
}

Future<void> raw(String path) async {
  final token = await _token();
  final uri = Uri.parse('$apiBase$path');
  final result = await _getRaw(uri, token);
  stdout.writeln('${result.statusCode} $uri');
  stdout.writeln(result.body);
}

Future<void> search(String query) async {
  final json = await getJson(
    '/search?text=${Uri.encodeQueryComponent(query)}&type=track&page=0',
  );
  final tracks = (json?['tracks'] as Map?)?['results'] as List? ?? const [];
  stdout.writeln('найдено треков: ${tracks.length}');
  if (tracks.isNotEmpty) {
    final first = tracks.first as Map;
    stdout.writeln('первый: ${_compact(first)}');
    stdout.writeln('isrc в выдаче поиска: ${(first['isrc'] ?? '').toString().isNotEmpty}');
    stdout.writeln('coverUri: ${first['coverUri']}');
  }
}

Future<void> tracksProbe(List<String> ids) async {
  final token = await _token();
  final joined = ids.isEmpty ? '40512013' : ids.join(',');
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  final request = await client.postUrl(Uri.parse('$apiBase/tracks'))
    ..headers.set(HttpHeaders.contentTypeHeader, 'application/x-www-form-urlencoded')
    ..headers.set('Authorization', 'OAuth $token')
    ..headers.set('Accept-Language', 'ru')
    ..write('track-ids=$joined');
  final response = await request.close();
  final body = await response.transform(utf8.decoder).join();
  stdout.writeln('${response.statusCode} POST /tracks track-ids=$joined');
  final decoded = jsonDecode(body);
  final list = decoded is Map ? decoded['result'] : decoded;
  if (list is List && list.isNotEmpty) {
    final first = Map<String, dynamic>.from(list.first as Map);
    stdout.writeln('вернули ${list.length}; поля: ${first.keys.toList()..sort()}');
    stdout.writeln('isrc: ${first['isrc']} · realId: ${first['id']}/${first['albumId']}');
  } else {
    stdout.writeln(body.substring(0, body.length > 500 ? 500 : body.length));
  }
}

Future<void> likes() async {
  final uid = await _uid();
  final json = await getJson('/users/$uid/likes/tracks?no-hq=true');
  final items = (json?['library'] as Map?)?['tracks'] as List? ?? const [];
  stdout.writeln('лайков: ${items.length}');
  if (items.isNotEmpty) {
    stdout.writeln('формат первой записи: ${jsonEncode(items.first)}');
  }
}

Future<void> playlists() async {
  final uid = await _uid();
  final json = await getJson('/users/$uid/playlists?kinds=');
  final list = json?['list'] as List? ?? const [];
  stdout.writeln('плейлистов: ${list.length}');
  for (final playlist in list.take(6)) {
    final map = playlist as Map;
    stdout.writeln('  ${map['kind']} · ${map['title']} · tracks=${(map['tracks'] as List?)?.length}');
  }
}

Future<void> wave() async {
  final json = await getJson('/rotor/station/user:onyourwave/tracks?queue=1');
  final sequence = json?['sequence'] as List? ?? const [];
  stdout.writeln('волна отдала треков: ${sequence.length}');
  if (sequence.isNotEmpty) {
    stdout.writeln('первый: ${_compact((sequence.first as Map)['track'])}');
  }
}

/// download-info -> get-mp3 -> реальный адрес: проверяем, чем именно
/// нужно авторизовать запрос к хранилищу, и живёт ли ссылка по времени.
Future<void> xmlDump(String trackId) async {
  final token = await _token();
  final info = await _getRaw(Uri.parse('$apiBase/tracks/$trackId/download-info'), token);
  final list = (jsonDecode(info.body)['result'] as List?) ?? const [];
  if (list.isEmpty) {
    stdout.writeln('пусто');
    return;
  }
  final url = (list.first as Map)['downloadInfoUrl'] as String;
  final xml = await _getRaw(Uri.parse(url), token);
  stdout.writeln('${xml.statusCode} content-type=${_contentTypeOf(xml.body)} длина=${xml.body.length}');
  stdout.writeln('структура: ${_shape(xml.body)}');
  for (final match in RegExp(r'<(\w+)>([^<]*)</>').allMatches(xml.body)) {
    final name = match.group(1)!;
    final value = match.group(2)!;
    final hide = name != 'host' && name != 'code';
    stdout.writeln('  $name = ${hide ? '${value.substring(0, value.length > 6 ? 6 : value.length)}…(${value.length})' : value}');
  }
}

/// Собирает адрес хранилища из XML и перебирает соли/алгоритмы/шаблоны,
/// пока не получит 200/206 с аудио.
Future<void> signProbe(String trackId) async {
  final token = await _token();
  final info = await _getRaw(Uri.parse('$apiBase/tracks/$trackId/download-info'), token);
  final entries = (jsonDecode(info.body)['result'] as List?) ?? const [];
  if (entries.isEmpty) {
    stdout.writeln('download-info пуст');
    return;
  }
  final infoUrl = (entries.first as Map)['downloadInfoUrl'] as String;
  final xml = (await _getRaw(Uri.parse(infoUrl), token)).body;

  String field(String name) =>
      RegExp('<$name>([^<]*)</$name>').firstMatch(xml)?.group(1) ?? '';
  final host = field('host');
  final path = field('path');
  final ts = field('ts');
  final sValue = field('s');
  final region = field('region');
  stdout.writeln('host=$host region=$region path=<${path.length}> ts=$ts s=<${sValue.length}>');

  final body = path.substring(1);
  const salts = [
    'XGRvlVRHweBcSULG',
    'XGRSTTXRwyKgnhHQBEZkg',
    'kzqU4XhfCaY6B6JTHODeq5',
    '7tvSmFbyf5hJnIHhCimDDD',
    '',
  ];
  final message = '$body$sValue';

  for (final salt in salts) {
    final md5hex = md5.convert(utf8.encode('$salt$message')).toString();
    final variants = <String, String>{
      'md5hex': md5hex,
      'md5b64': base64.encode(md5.convert(utf8.encode('$salt$message')).bytes),
      'sha256hex32': sha256
          .convert(utf8.encode('$salt$message'))
          .toString()
          .substring(0, 32),
    };
    for (final entry in variants.entries) {
      final templates = <String>[
        'https://$host/get-mp3/${entry.value}/$ts$path',
        'https://$host$path?ts=$ts&s=$sValue&sign=${entry.value}',
      ];
      for (var i = 0; i < templates.length; i++) {
        final result = await _rangeGet(templates[i], token);
        stdout.writeln('  salt=${salt.isEmpty ? '(пусто)' : salt.substring(0, 6)}… '
            '${entry.key} шаблон$i -> ${result.statusCode} ${result.contentType ?? ''} '
            '${result.range ?? ''} ${result.detail}');
        if (result.statusCode == 200 || result.statusCode == 206) {
          stdout.writeln('  >>> ЖИВОЙ ВАРИАНТ: salt=$salt alg=${entry.key} шаблон=$i');
          final noAuth = await _rangeGet(templates[i], '');
          stdout.writeln('  без Authorization -> ${noAuth.statusCode} ${noAuth.contentType} ${noAuth.range ?? noAuth.detail}');
          final wrongTs = await _rangeGet(
            'https://$host/get-mp3/${entry.value}/0$path',
            token,
          );
          stdout.writeln('  с неверным ts -> ${wrongTs.statusCode} ${wrongTs.range ?? wrongTs.detail}');
          return;
        }
      }
    }
  }
  stdout.writeln('ни одна комбинация не дала аудио');
}

Future<({int statusCode, String? contentType, String? range, String detail})> _rangeGet(
  String url,
  String token,
) async {
  try {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10)
      ..autoUncompress = false;
    final request = await client.openUrl('GET', Uri.parse(url))
      ..headers.set(HttpHeaders.rangeHeader, 'bytes=0-2047')
      ..headers.set('Authorization', 'OAuth $token')
      ..headers.set('Accept-Language', 'ru')
      ..headers.set('User-Agent', 'YandexMusic/26.0.0 (Android)');
    final response = await request.close();
    final bytes = <int>[];
    await for (final chunk in response) {
      bytes.addAll(chunk);
      if (bytes.length > 4096) break;
    }
    client.close(force: true);
    final isAudio = (response.headers.contentType?.mimeType ?? '').contains('audio') ||
        bytes.length > 2 && bytes[0] != 0x3c; // не '<' — не xml/html
    return (
      statusCode: response.statusCode,
      contentType: response.headers.contentType?.mimeType,
      range: response.headers.value(HttpHeaders.contentRangeHeader),
      detail: isAudio
          ? 'байт=${bytes.length} magic=${bytes.take(3).map((b) => b.toRadixString(16).padLeft(2, '0')).join()}'
          : _trim(utf8.decode(bytes, allowMalformed: true), 90),
    );
  } on Object catch (e) {
    return (statusCode: -1, contentType: null, range: null, detail: '$e');
  }
}

/// Каркас ответа: длинные токены заменяем их длиной, чтобы не светить ключ.
String _shape(String body) {
  final masked = body.replaceAllMapped(
    RegExp(r'[A-Za-z0-9_\-]{9,}'),
    (m) => '<${m.group(0)!.length}>',
  );
  return masked.length > 700 ? '${masked.substring(0, 700)}…' : masked;
}

String _contentTypeOf(String body) =>
    body.trimLeft().startsWith('<') ? 'xml/текст' : 'не xml';

Future<void> downloadInfo(String trackId) async {
  final token = await _token();
  final info = await _getRaw(Uri.parse('$apiBase/tracks/$trackId/download-info'), token);
  stdout.writeln('${info.statusCode} /tracks/$trackId/download-info');
  final list = (jsonDecode(info.body)['result'] as List?) ?? const [];
  for (final entry in list) {
    final map = Map<String, dynamic>.from(entry as Map);
    stdout.writeln('  codec=${map['codec']} bitrate=${map['bitrateInKbps']} '
        'literal=${map['literal']} hasUrl=${map['downloadInfoUrl'] != null}');
  }
  if (list.isEmpty) return;

  final first = Map<String, dynamic>.from(list.first as Map);
  final url = first['downloadInfoUrl'] as String;

  for (final mode in ['oauth', 'none']) {
    final result = await _follow(url, mode == 'oauth' ? token : null);
    stdout.writeln('  [$mode] -> ${result.statusCode} final=${_mask(result.finalUrl)} '
        'type=${result.contentType} len=${result.length} '
        'authHdr=${result.wwwAuthenticate == null ? 'нет' : 'да'}');
  }
}

Future<({int statusCode, String finalUrl, String? contentType, String? length, String? wwwAuthenticate})>
    _follow(String url, String? token) async {
  var current = url;
  for (var hop = 0; hop < 5; hop++) {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10)
      ..autoUncompress = false;
    final request = await client.openUrl('GET', Uri.parse(current))
      ..followRedirects = false
      ..headers.set(HttpHeaders.rangeHeader, 'bytes=0-2047');
    if (token != null) {
      request.headers.set('Authorization', 'OAuth $token');
      request.headers.set('Accept-Language', 'ru');
    }
    final response = await request.close();
    if (response.statusCode >= 300 && response.statusCode < 400) {
      final location = response.headers.value(HttpHeaders.locationHeader);
      client.close(force: true);
      if (location == null) {
        return (
          statusCode: response.statusCode,
          finalUrl: '(нет Location)',
          contentType: null,
          length: null,
          wwwAuthenticate: null,
        );
      }
      current = Uri.parse(current).resolve(location).toString();
      continue;
    }
    final result = (
      statusCode: response.statusCode,
      finalUrl: current,
      contentType: response.headers.contentType?.mimeType,
      length: response.headers.value(HttpHeaders.contentRangeHeader) ??
          response.headers.value(HttpHeaders.contentLengthHeader),
      wwwAuthenticate: response.headers.value(HttpHeaders.wwwAuthenticateHeader),
    );
    client.close(force: true);
    return result;
  }
  throw StateError('слишком много редиректов');
}

/// Скрытые токены не печатаем: оставляем только хост и длину пути.
String _mask(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return '(разбор не удался)';
  return '${uri.scheme}://${uri.host}${uri.path.length > 24 ? '${uri.path.substring(0, 12)}…(${uri.path.length})' : uri.path}';
}

/// Перебирает известные варианты подписи get-file-info и говорит, какой живой.
Future<void> streamProbe(String trackId) async {
  final token = await _token();
  final ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  const keys = [
    '7tvSmFbyf5hJnIHhCimDDD',
    'kzqU4XhfCaY6B6JTHODeq5',
    'XGRSTTXRwyKgnhHQBEZkg',
  ];
  const codecs = 'mp3,aac,flac';
  const qualities = ['mp3-128', 'lossless'];

  for (final quality in qualities) {
    for (final key in keys) {
      final dataToSign = '$ts$trackId$quality${codecs.split(',').join()}raw';
      final sign = base64
          .encode(Hmac(sha256, utf8.encode(key)).convert(utf8.encode(dataToSign)).bytes);
      final paths = [
        '/v2.0/track/$trackId/get-file-info',
        '/get-file-info',
      ];
      for (final path in paths) {
        final uri = Uri.parse('$apiBase$path').replace(queryParameters: {
          'ts': '$ts',
          'trackId': trackId,
          if (path == '/get-file-info') 'track-id': trackId,
          'quality': quality,
          'codecs': codecs,
          'transport': 'raw',
          'transports': 'raw',
          'sign': sign,
        });
        final result = await _getRaw(uri, token);
        stdout.writeln('${result.statusCode} $quality ${path.substring(0, 6)}… '
            '${path.split('/').reversed.first} '
            '${_trim(result.body)}');
        if (result.statusCode == 200) {
          stdout.writeln('  >>> живой вариант: path=$path quality=$quality key=$key');
          stdout.writeln('  >>> dataToSign=$dataToSign');
          final decoded = jsonDecode(result.body);
          if (decoded is List && decoded.isNotEmpty) {
            stdout.writeln('  запись: ${jsonEncode(decoded.first)}');
            final first = Map<String, dynamic>.from(decoded.first as Map);
            final url = first['downloadInfoUrl'] ?? first['url'] ?? first['result'];
            stdout.writeln('  ключи записи: ${first.keys.join(', ')}');
            if (url is String && url.startsWith('http')) {
              stdout.writeln('  проверка доступа: ${await _head(url)}');
            }
          }
          return;
        }
      }
    }
  }
  stdout.writeln('ни один вариант подписи не сработал — правим docs/API_PROBE.md');
}

Future<String> _uid() async {
  final json = await getJson('/account/status', quiet: true);
  final uid = (json?['account'] as Map?)?['uid'];
  if (uid == null) {
    stderr.writeln('нет uid — статус: ${jsonEncode(json)}');
    exit(1);
  }
  stdout.writeln('uid=$uid login=${(json?['account'] as Map)['login']} '
      'plus=${(json?['plus'] as Map?)?['hasPlus']}');
  return '$uid';
}

Future<Map?> getJson(String path, {bool quiet = false}) async {
  final token = await _token();
  final result = await _getRaw(Uri.parse('$apiBase$path'), token);
  stdout.writeln('${result.statusCode} $path');
  if (result.statusCode != 200) {
    stdout.writeln('  ${_trim(result.body)}');
    return null;
  }
  final decoded = jsonDecode(result.body) as Map<String, dynamic>;
  final unwrapped = decoded['result'];
  if (!quiet) {
    stdout.writeln('  верхнеуровневые ключи: ${decoded.keys.join(', ')}');
  }
  return unwrapped is Map ? Map<String, dynamic>.from(unwrapped) : decoded;
}

Future<String> _token() async {
  if (!await tokenFile.exists()) {
    stderr.writeln('нет токена: сначала dart run tool/probe/yandex_probe.dart login');
    exit(2);
  }
  return (await tokenFile.readAsString()).trim();
}

Future<({int statusCode, String body})> _getRaw(Uri uri, String token) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  final request = await client.getUrl(uri)
    ..headers.set('Authorization', 'OAuth $token')
    ..headers.set('Accept-Language', 'ru')
    ..headers.set('User-Agent', 'YandexMusic/26.0.0 (Android)');
  final response = await request.close();
  final body = await response.transform(utf8.decoder).join();
  return (statusCode: response.statusCode, body: body);
}

Future<String> _head(String url) async {
  try {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  final request = await client.openUrl('GET', Uri.parse(url))
    ..headers.set(HttpHeaders.rangeHeader, 'bytes=0-1023');
    final response = await request.close();
    return '${response.statusCode} content-type=${response.headers.contentType} '
        'content-range=${response.headers.value(HttpHeaders.contentRangeHeader)}';
  } on Object catch (e) {
    return 'ошибка доступа: $e';
  }
}

Future<({int statusCode, String body})> _postRaw(
  String url, String kind, String payload, String token,
) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  final request = await client.postUrl(Uri.parse(url))
    ..headers.set(
      HttpHeaders.contentTypeHeader,
      kind.startsWith('json')
          ? 'application/json'
          : 'application/x-www-form-urlencoded',
    )
    ..headers.set('Authorization', 'OAuth $token')
    ..headers.set('Accept-Language', 'ru')
    ..write(payload);
  final response = await request.close();
  return (
    statusCode: response.statusCode,
    body: await response.transform(utf8.decoder).join(),
  );
}

Future<({int statusCode, String body})> _postFormQuery(String url) async {
  final token = await _token();
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  final request = await client.postUrl(Uri.parse(url))
    ..headers.set(HttpHeaders.contentTypeHeader, 'application/x-www-form-urlencoded')
    ..headers.set('Authorization', 'OAuth $token')
    ..headers.set('Accept-Language', 'ru')
    ..write('');
  final response = await request.close();
  return (statusCode: response.statusCode, body: await response.transform(utf8.decoder).join());
}

Future<Map<String, dynamic>> _postForm(String url, Map<String, String> fields) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  final request = await client.postUrl(Uri.parse(url))
    ..headers.set(HttpHeaders.contentTypeHeader, 'application/x-www-form-urlencoded')
    ..headers.set('User-Agent', 'YandexMusic/26.0.0 (Android)')
    ..write(fields.entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&'));
  final response = await request.close();
  final body = await response.transform(utf8.decoder).join();
  final decoded = body.isEmpty ? {} : jsonDecode(body);
  return decoded is Map ? Map<String, dynamic>.from(decoded) : {'raw': body};
}

String _deviceId() {
  final file = File('C:/project/musor/probe_device_id.txt');
  if (file.existsSync()) return file.readAsStringSync().trim();
  final seed = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  final id = seed + seed.split('').reversed.join();
  file.writeAsStringSync(id);
  return id;
}

String _compact(Object? track) {
  if (track is! Map) return '—';
  final artists = (track['artists'] as List?)?.map((a) => a['name']).join(', ') ?? '';
  return '${track['title']} / $artists · id=${track['id']} album=${track['albumId'] ?? (track['albums'] as List?)?.first}';
}

String _trim(String body, [int limit = 400]) =>
    body.length <= limit ? body : '${body.substring(0, limit)}… (${body.length} байт)';
