import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/core/db/database.dart';
import 'package:phoneyandex/core/sources/source_dto.dart';
import 'package:phoneyandex/core/sources/source_id.dart';
import 'package:phoneyandex/core/sources/stream_target.dart';

void main() {
  test('новая запись истории будит watcher «Недавних»', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final track = await db.tracksDao.ingest(
      const SourceTrack(
        ref: RemoteTrackRef(SourceId.yandex, '1'),
        title: 'Тест',
        artists: ['Артист'],
        duration: Duration(minutes: 3),
      ),
    );

    final counts = <int>[];
    final initial = Completer<void>();
    final changed = Completer<void>();
    final sub = db.select(db.history).watch().map((rows) => rows.length).listen(
      (count) {
        counts.add(count);
        if (count == 0 && !initial.isCompleted) initial.complete();
        if (count == 1 && !changed.isCompleted) changed.complete();
      },
    );
    addTearDown(sub.cancel);

    await initial.future.timeout(const Duration(seconds: 5));
    expect(counts.first, 0);

    await db.historyDao.record(
      localTrackId: track.localTrackId,
      source: SourceId.yandex,
      quality: Quality.auto,
      played: const Duration(seconds: 30),
      completed: false,
    );
    await changed.future.timeout(const Duration(seconds: 5));

    expect(counts.last, 1);
  });
}
