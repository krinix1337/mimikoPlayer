import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/features/updates/github_updater.dart';

void main() {
  test('числовые версии сравниваются по сегментам', () {
    expect(compareVersions('1.3.1', '1.3.0'), 1);
    expect(compareVersions('v1.3.1', '1.3.0+6'), 1);
    expect(compareVersions('1.3.0', '1.3.0+6'), 0);
    expect(compareVersions('1.3.0-beta', '1.3.0'), -1);
    expect(compareVersions('1.4', '1.3.9'), 1);
    expect(compareVersions('1.10.0', '1.9.9'), 1);
  });

  test('из релиза выбирается APK и digest', () {
    final release = UpdateRelease.fromReleaseJson({
      'tag_name': 'v1.3.1',
      'html_url':
          'https://github.com/krinix1337/mimikoPlayer/releases/tag/v1.3.1',
      'body': 'Исправления',
      'assets': [
        {
          'id': 10,
          'name': 'checksums.txt',
          'size': 12,
          'url': 'https://api.github.com/assets/10',
        },
        {
          'id': 11,
          'name': 'mimikoPlayer-1.3.1.apk',
          'size': 76000000,
          'url': 'https://api.github.com/assets/11',
          'digest': 'sha256:abc',
        },
      ],
    });

    expect(release, isNotNull);
    expect(release!.version, '1.3.1');
    expect(release.assetId, 11);
    expect(release.assetName, 'mimikoPlayer-1.3.1.apk');
    expect(release.assetApiUrl, 'https://api.github.com/assets/11');
    expect(release.digest, 'sha256:abc');
    expect(release.webUrl, contains('/releases/tag/v1.3.1'));
    expect(release.notes, 'Исправления');
    expect(release.isNewerThan('1.3.0'), isTrue);
    expect(release.isNewerThan('1.3.1'), isFalse);
  });

  test('релиз без APK не принимается', () {
    final release = UpdateRelease.fromReleaseJson({
      'tag_name': 'v1.3.1',
      'assets': [
        {
          'id': 10,
          'name': 'notes.txt',
          'url': 'https://api.github.com/assets/10',
        },
      ],
    });
    expect(release, isNull);
  });

  test('digest скачанного файла сверяется с SHA-256', () async {
    final file = File(
      '${Directory.systemTemp.path}/mimiko_update_${DateTime.now().microsecondsSinceEpoch}.bin',
    );
    await file.writeAsBytes([1, 2, 3, 4]);
    final digest = sha256.convert([1, 2, 3, 4]).toString();

    expect(await GithubUpdater.verifyDigest(file, 'sha256:$digest'), isTrue);
    expect(
      await GithubUpdater.verifyDigest(file, digest.toUpperCase()),
      isTrue,
    );
    expect(await GithubUpdater.verifyDigest(file, 'sha256:deadbeef'), isFalse);
    await file.delete();
  });
}
