import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/features/player/player_snapshot.dart';
import 'package:phoneyandex/features/player/queue_manager.dart';

void main() {
  List<String> ids(int n) => [for (var i = 0; i < n; i++) 't_$i'];

  group('QueueManager', () {
    test('очередь стартует с указанной позиции', () {
      final q = QueueManager()..setQueue(ids(3), startIndex: 1);
      expect(q.currentId, 't_1');
      expect(q.displayPosition, 1);
      expect(q.currentBaseIndex, 1);
      expect(q.displayOrder, ['t_0', 't_1', 't_2']);
    });

    test('индекс вне списка не роняет очередь', () {
      final q = QueueManager()..setQueue(ids(2), startIndex: 7);
      expect(q.currentId, 't_0');
    });

    test('advance на конце без повтора возвращает null', () {
      final q = QueueManager()..setQueue(ids(2));
      expect(q.advance(), 't_1');
      expect(q.advance(), isNull);
    });

    test('repeat=all заворачивает, repeat=one на автопродолжении повторяет', () {
      final all = QueueManager()..setQueue(ids(2), startIndex: 1);
      all.setRepeat(PlaybackRepeat.all);
      expect(all.advance(), 't_0');

      final one = QueueManager()..setQueue(ids(2));
      one.setRepeat(PlaybackRepeat.one);
      expect(one.advance(manual: false), 't_0');
      // Ручное переключение всё равно идёт вперёд.
      expect(one.advance(), 't_1');
    });

    test('rewind в начале списка остаётся на первом', () {
      final q = QueueManager()..setQueue(ids(2), startIndex: 0);
      expect(q.rewind(), 't_0');
    });

    test('shuffle переставляет порядок, но не состав', () {
      final q = QueueManager()..setQueue(ids(20));
      q.setShuffle(PlaybackShuffle.shuffled);
      expect(q.displayOrder.length, 20);
      expect(q.displayOrder.toSet(), ids(20).toSet());
      expect(q.currentId, isNotNull);

      q.setShuffle(PlaybackShuffle.ordered);
      expect(q.displayOrder, ids(20));
    });

    test('shuffle сохраняет текущий трек первым', () {
      final q = QueueManager()..setQueue(ids(12), startIndex: 5);
      final current = q.currentId;
      q.setShuffle(PlaybackShuffle.shuffled);
      expect(q.currentId, current);
      expect(q.displayOrder.first, current);
    });

    test('remove сдвигает порядок и не ломает индексы', () {
      final q = QueueManager()..setQueue(ids(4));
      q.setShuffle(PlaybackShuffle.shuffled);
      q.remove('t_2');
      expect(q.displayOrder.contains('t_2'), isFalse);
      expect(q.displayOrder.length, 3);
      expect(q.currentId, isNotNull);
    });

    test('jumpTo ищет по base-индексу, а не по позиции в перемешанном списке', () {
      final q = QueueManager()..setQueue(ids(6));
      q.setShuffle(PlaybackShuffle.shuffled);
      expect(q.jumpTo('t_4'), 't_4');
      expect(q.currentBaseIndex, 4);
      expect(q.displayOrder[q.displayPosition], 't_4');
    });

    test('пустая очередь не продвигается', () {
      final q = QueueManager()..setQueue(const []);
      expect(q.currentId, isNull);
      expect(q.advance(), isNull);
      q.append('t_0');
      expect(q.currentId, 't_0');
    });

    test('фоновая докачка волны не переключает текущий трек', () {
      final q = QueueManager()..setQueue(ids(5), startIndex: 4);
      expect(q.currentId, 't_4');
      expect(q.appendBatch(['t_5', 't_6', 't_4']), isTrue);
      expect(q.currentId, 't_4');
      expect(q.remainingAfterCurrent, 2);
      expect(q.displayOrder, [for (var i = 0; i < 7; i++) 't_$i']);
    });

    test('докачка в конце очереди встаёт на первый новый трек', () {
      final q = QueueManager()..setQueue(ids(2), startIndex: 1);
      expect(q.remainingAfterCurrent, 0);
      q.appendBatch(['t_2', 't_3'], moveToFirstNew: true);
      expect(q.currentId, 't_2');
    });
  });
}
