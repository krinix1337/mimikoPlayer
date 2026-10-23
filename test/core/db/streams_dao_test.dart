import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:phoneyandex/core/db/daos/library_dao.dart';
import 'package:phoneyandex/core/db/database.dart';

void main() {
  late AppDatabase db;
  late Directory dir;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dir = await Directory.systemTemp.createTemp('mimiko_downloads_');
    await db
        .into(db.tracks)
        .insert(
          TracksCompanion.insert(
            id: 't_1',
            title: 'Трек',
            titleNorm: 'трек',
            durationSec: 180,
            fingerprint: 'fp',
            metadataSource: 'yandex',
          ),
        );
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<void> addDownload(File file, {required int size}) => db
      .into(db.downloadedFiles)
      .insert(
        DownloadedFilesCompanion.insert(
          localTrackId: 't_1',
          filePath: file.path,
          sizeBytes: Value(size),
          source: 'yandex',
          state: const Value('complete'),
        ),
      );

  test('целый скачанный файл имеет приоритет', () async {
    final file = File(p.join(dir.path, 't_1.mp3'));
    await file.writeAsBytes(List.filled(70 * 1024, 1));
    await addDownload(file, size: await file.length());

    expect(await db.streamsDao.downloadedFilePath('t_1'), file.path);
  });

  test('битый или отсутствующий файл не отдаётся и чистится из БД', () async {
    final file = File(p.join(dir.path, 't_1.mp3'));
    await file.writeAsBytes([1, 2, 3]);
    await addDownload(file, size: 3);

    expect(await db.streamsDao.downloadedFilePath('t_1'), isNull);
    expect(await db.select(db.downloadedFiles).get(), isEmpty);

    await file.delete();
    await addDownload(file, size: 70 * 1024);
    expect(await db.streamsDao.downloadedFilePath('t_1'), isNull);
    expect(await db.select(db.downloadedFiles).get(), isEmpty);
  });

  test('бэкфилл находит скачанные треки без обложки', () async {
    final file = File(p.join(dir.path, 't_1.mp3'));
    await file.writeAsBytes(List.filled(70 * 1024, 1));
    await addDownload(file, size: await file.length());
    await db
        .into(db.tracks)
        .insert(
          TracksCompanion.insert(
            id: 't_2',
            title: 'Второй',
            titleNorm: 'второй',
            durationSec: 200,
            fingerprint: 'fp2',
            metadataSource: 'yandex',
          ),
        );
    await db
        .into(db.downloadedFiles)
        .insert(
          DownloadedFilesCompanion.insert(
            localTrackId: 't_2',
            filePath: '/tmp/t_2.mp3',
            source: 'yandex',
            state: const Value('downloading'),
          ),
        );

    final missing = await db.streamsDao.completeWithoutCover();
    expect(missing.map((row) => row.localTrackId), ['t_1']);

    await db.streamsDao.setCoverPath('t_1', '/tmp/t_1.jpg');
    expect(await db.streamsDao.completeWithoutCover(), isEmpty);
    final row = await db.streamsDao.downloadedFile('t_1');
    expect(row?.coverPath, '/tmp/t_1.jpg');
  });

  test('коллекция отдаёт локальную обложку скачанного трека', () async {
    final file = File(p.join(dir.path, 't_1.mp3'));
    await file.writeAsBytes(List.filled(70 * 1024, 1));
    await db
        .into(db.downloadedFiles)
        .insert(
          DownloadedFilesCompanion.insert(
            localTrackId: 't_1',
            filePath: file.path,
            sizeBytes: Value(await file.length()),
            source: 'yandex',
            state: const Value('complete'),
            coverPath: const Value('/tmp/t_1.jpg'),
          ),
        );

    final rows = await db.libraryDao.collectionRows(CollectionKind.downloaded);
    expect(rows.single.coverPath, '/tmp/t_1.jpg');
  });
}
