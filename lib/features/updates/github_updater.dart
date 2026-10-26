import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

/// Что именно пошло не так при проверке или скачивании. UI переводит код
/// в понятную строку, чтобы сервис не зависел от локализации.
enum UpdateFailure {
  unauthorized,
  notFound,
  noAsset,
  noDigest,
  checksum,
  network,
  unknown,
}

class UpdateException implements Exception {
  const UpdateException(this.kind, [this.details]);

  final UpdateFailure kind;
  final String? details;

  @override
  String toString() =>
      'UpdateException($kind${details == null ? '' : ': $details'})';
}

/// Релиз приватного репозитория с готовым APK.
class UpdateRelease {
  const UpdateRelease({
    required this.version,
    required this.tag,
    required this.assetId,
    required this.assetName,
    required this.assetApiUrl,
    required this.size,
    required this.digest,
    this.webUrl,
    this.notes,
  });

  final String version;
  final String tag;
  final int assetId;
  final String assetName;
  final String assetApiUrl;
  final int size;
  final String? digest;
  final String? webUrl;
  final String? notes;

  bool isNewerThan(String currentVersion) =>
      compareVersions(version, currentVersion) > 0;

  static UpdateRelease? fromReleaseJson(Map<String, Object?> json) {
    final tag = json['tag_name'];
    if (tag is! String || tag.trim().isEmpty) return null;
    final assets = json['assets'];
    if (assets is! List) return null;
    Map<Object?, Object?>? apk;
    for (final asset in assets) {
      if (asset is Map &&
          asset['name'] is String &&
          (asset['name']! as String).toLowerCase().endsWith('.apk')) {
        apk = asset;
        break;
      }
    }
    if (apk == null) return null;
    final url = apk['url'];
    final id = apk['id'];
    if (url is! String || url.isEmpty || id is! num) return null;
    final notes = json['body'];
    return UpdateRelease(
      version: tag.trim().replaceFirst(RegExp(r'^v', caseSensitive: false), ''),
      tag: tag.trim(),
      assetId: id.toInt(),
      assetName: apk['name']! as String,
      assetApiUrl: url,
      size: (apk['size'] as num?)?.toInt() ?? 0,
      digest: apk['digest'] is String ? apk['digest']! as String : null,
      webUrl: json['html_url'] is String ? json['html_url']! as String : null,
      notes: notes is String && notes.trim().isNotEmpty ? notes.trim() : null,
    );
  }
}

/// Сравнение версий по числовым сегментам. `1.3.0+6` и `v1.3.0` равны;
/// `1.3.1-beta` считается старше `1.3.0`, но младше `1.3.1`.
int compareVersions(String a, String b) {
  List<int> numbers(String value) {
    final core = value
        .trim()
        .replaceFirst(RegExp(r'^v', caseSensitive: false), '')
        .split('+')
        .first
        .split('-')
        .first;
    return [for (final part in core.split('.')) int.tryParse(part) ?? 0];
  }

  final left = numbers(a);
  final right = numbers(b);
  final length = left.length > right.length ? left.length : right.length;
  for (var index = 0; index < length; index++) {
    final first = index < left.length ? left[index] : 0;
    final second = index < right.length ? right[index] : 0;
    if (first != second) return first.compareTo(second);
  }
  final leftPre = a.contains('-');
  final rightPre = b.contains('-');
  if (leftPre != rightPre) return leftPre ? -1 : 1;
  return 0;
}

/// Проверка обновлений в приватных релизах GitHub.
///
/// Токен нужен только для чтения: fine-grained PAT с доступом
/// Contents: Read-only к [repository].
class GithubUpdater {
  GithubUpdater({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(minutes: 10),
              headers: {
                'Accept': 'application/vnd.github+json',
                'X-GitHub-Api-Version': '2022-11-28',
              },
            ),
          );

  static const repository = 'krinix1337/mimikoPlayer';
  final Dio _dio;

  /// Последний опубликованный релиз независимо от того, новее он или нет.
  /// Сравнение с установленной версией делает UI: так можно показать
  /// описание последнего релиза, даже когда обновляться не нужно.
  Future<UpdateRelease?> latest({required String token}) async {
    final data = await _latestRelease(token);
    final release = UpdateRelease.fromReleaseJson(data);
    if (release == null) throw const UpdateException(UpdateFailure.noAsset);
    return release;
  }

  Future<File> download({
    required UpdateRelease release,
    required String token,
    required void Function(int received, int total) onProgress,
    CancelToken? cancelToken,
  }) async {
    final digest = release.digest;
    if (digest == null || digest.trim().isEmpty) {
      throw const UpdateException(UpdateFailure.noDigest);
    }
    final root = await getTemporaryDirectory();
    final dir = Directory('${root.path}/updates');
    await dir.create(recursive: true);
    await for (final entity in dir.list()) {
      if (entity is File && entity.path.toLowerCase().endsWith('.apk')) {
        await entity.delete();
      }
    }
    final file = File('${dir.path}/${release.assetName}');
    try {
      await _dio.download(
        release.assetApiUrl,
        file.path,
        cancelToken: cancelToken,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/octet-stream',
          },
        ),
        onReceiveProgress: onProgress,
      );
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) rethrow;
      final status = error.response?.statusCode;
      if (status == 401 || status == 403) {
        throw const UpdateException(UpdateFailure.unauthorized);
      }
      if (status == 404) {
        throw const UpdateException(UpdateFailure.notFound);
      }
      throw UpdateException(UpdateFailure.network, error.message);
    }
    if (!await verifyDigest(file, digest)) {
      await file.delete();
      throw const UpdateException(UpdateFailure.checksum);
    }
    return file;
  }

  Future<Map<String, Object?>> _latestRelease(String token) async {
    try {
      final response = await _dio.get<Object?>(
        'https://api.github.com/repos/$repository/releases/latest',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = response.data;
      if (data is Map<String, Object?>) return data;
      if (data is Map) {
        return {
          for (final entry in data.entries) entry.key.toString(): entry.value,
        };
      }
      throw const UpdateException(UpdateFailure.unknown);
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status == 401 || status == 403) {
        throw const UpdateException(UpdateFailure.unauthorized);
      }
      if (status == 404) {
        throw const UpdateException(UpdateFailure.notFound);
      }
      throw UpdateException(UpdateFailure.network, error.message);
    }
  }

  /// SHA-256 из поля digest GitHub API. Читает файл потоком, не поднимая
  /// 70-мегабайтный APK в память целиком.
  static Future<bool> verifyDigest(File file, String expected) async {
    final normalized = expected.trim().toLowerCase().replaceFirst(
      'sha256:',
      '',
    );
    if (normalized.isEmpty) return false;
    final actual = (await sha256.bind(file.openRead()).first).toString();
    return actual == normalized;
  }

  static String formatMb(int bytes) =>
      (bytes / (1024 * 1024)).toStringAsFixed(1);
}
