import 'player_snapshot.dart';

/// Очередь принадлежит приложению, а не just_audio: на каждый переход нужен
/// свежий резолв и fallback по источникам, а `ConcatenatingAudioSource`
/// переключает треки сам, минуя нашу цепочку.
class QueueManager {
  List<String> _items = const [];

  /// Перестановка `_items`, когда shuffle включён.
  List<int> _order = const [];

  int _position = -1;
  PlaybackRepeat _repeat = PlaybackRepeat.none;
  PlaybackShuffle _shuffle = PlaybackShuffle.ordered;

  List<String> get items => _items;
  PlaybackRepeat get repeat => _repeat;
  PlaybackShuffle get shuffle => _shuffle;

  bool get isEmpty => _position < 0 || _position >= _order.length;

  String? get currentId => isEmpty ? null : _items[_order[_position]];

  /// Позиция в том порядке, который показывается пользователю.
  int get displayPosition => isEmpty ? -1 : _position;

  /// Индекс в исходном (не перемешанном) списке — его пишем в снапшот очереди.
  int get currentBaseIndex => isEmpty ? -1 : _order[_position];

  /// localTrackId'и в том порядке, в котором их показывать.
  List<String> get displayOrder => [
    for (final i in _order) _items[i],
  ];

  void setQueue(List<String> localTrackIds, {int startIndex = 0}) {
    _items = List.of(localTrackIds);
    _order = List.generate(_items.length, (i) => i);
    if (_shuffle == PlaybackShuffle.shuffled) _reshuffle();
    _position = (_items.isEmpty || startIndex < 0 || startIndex >= _items.length)
        ? -1
        : _order.indexOf(startIndex);
    if (_position < 0 && _items.isNotEmpty) _position = 0;
  }

  /// Вставить сразу после текущего трека — действие «играть следующим».
  void insertNext(String localTrackId) {
    _items = [..._items, localTrackId];
    final base = _items.length - 1;
    final orderAt = _position < 0 ? _order.length : _position + 1;
    _order = [
      ..._order.take(orderAt),
      base,
      ..._order.skip(orderAt),
    ];
    if (_position < 0) _position = 0;
  }

  /// Дописать пачку (подкачка волны) и встать на первый новый трек.
  /// Уже стоящие в очереди id пропускаем — иначе волна крутит одно и то же.
  bool appendBatch(List<String> localTrackIds) {
    final fresh = [
      for (final id in localTrackIds)
        if (!_items.contains(id)) id,
    ];
    if (fresh.isEmpty) return false;

    final firstBase = _items.length;
    _items = [..._items, ...fresh];
    _order = [
      ..._order,
      for (var i = 0; i < fresh.length; i++) firstBase + i,
    ];
    _position = _order.length - fresh.length;
    return true;
  }

  void append(String localTrackId) {
    _items = [..._items, localTrackId];
    _order = [..._order, _items.length - 1];
    if (_position < 0) _position = _order.length - 1;
  }

  void remove(String localTrackId) {
    final index = _items.indexOf(localTrackId);
    if (index < 0) return;
    final wasCurrent = currentId == localTrackId;
    _items = [
      for (var i = 0; i < _items.length; i++)
        if (i != index) _items[i],
    ];
    _order = [for (final i in _order) if (i != index) _remap(i, index)];
    if (wasCurrent) _position = _position.clamp(0, _order.length - 1);
    if (_order.isEmpty) _position = -1;
  }

  static int _remap(int oldIndex, int removedIndex) =>
      oldIndex < removedIndex ? oldIndex : oldIndex - 1;

  /// Следующий трек. `manual` — переключение пользователем, тогда repeat=one
  /// тоже идёт вперёд; автопродолжение после окончания трека зовёт с false.
  String? advance({bool manual = true}) {
    if (_order.isEmpty) return null;
    if (_repeat == PlaybackRepeat.one && !manual) return currentId;
    if (_position + 1 < _order.length) {
      _position++;
      return currentId;
    }
    if (_repeat == PlaybackRepeat.all) {
      _position = 0;
      return currentId;
    }
    return null;
  }

  String? rewind() {
    if (_order.isEmpty) return null;
    if (_position - 1 >= 0) {
      _position--;
      return currentId;
    }
    if (_repeat == PlaybackRepeat.all) {
      _position = _order.length - 1;
      return currentId;
    }
    _position = 0;
    return currentId;
  }

  String? jumpTo(String localTrackId) {
    final orderIndex = _order.indexOf(_items.indexOf(localTrackId));
    if (orderIndex < 0) return null;
    _position = orderIndex;
    return currentId;
  }

  void setRepeat(PlaybackRepeat mode) => _repeat = mode;

  PlaybackShuffle setShuffle(PlaybackShuffle mode) {
    if (_shuffle == mode) return _shuffle;
    _shuffle = mode;
    final current = currentId;
    if (mode == PlaybackShuffle.shuffled) {
      _reshuffle(keepFirst: current);
    } else {
      _order = List.generate(_items.length, (i) => i);
      _position = current == null ? -1 : _items.indexOf(current);
    }
    return _shuffle;
  }

  void _reshuffle({String? keepFirst}) {
    final indices = [for (var i = 0; i < _items.length; i++) i]..shuffle();
    if (keepFirst != null) {
      final base = _items.indexOf(keepFirst);
      if (base >= 0) {
        indices.remove(base);
        indices.insert(0, base);
      }
    }
    _order = indices;
    _position = indices.isEmpty ? -1 : 0;
  }
}
