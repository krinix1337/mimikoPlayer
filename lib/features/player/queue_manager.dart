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
  List<String> get displayOrder => [for (final i in _order) _items[i]];

  void setQueue(List<String> localTrackIds, {int startIndex = 0}) {
    _items = List.of(localTrackIds);
    _order = List.generate(_items.length, (i) => i);
    final valid = startIndex >= 0 && startIndex < _items.length;
    // При перемешивании выбранный трек встаёт первым: иначе он оказывался
    // в случайном месте, и всё, что перед ним, уже никогда не звучало.
    if (_shuffle == PlaybackShuffle.shuffled) {
      _reshuffle(keepFirst: valid ? startIndex : null);
    }
    _position = !valid ? -1 : _order.indexOf(startIndex);
    if (_position < 0 && _items.isNotEmpty) _position = 0;
  }

  /// Вставить сразу после текущего трека — действие «играть следующим».
  void insertNext(String localTrackId) {
    _items = [..._items, localTrackId];
    final base = _items.length - 1;
    final orderAt = _position < 0 ? _order.length : _position + 1;
    _order = [..._order.take(orderAt), base, ..._order.skip(orderAt)];
    if (_position < 0) _position = orderAt;
  }

  /// Сколько треков осталось после текущего.
  int get remainingAfterCurrent =>
      isEmpty ? 0 : (_order.length - _position - 1).clamp(0, _order.length);

  /// Дописать пачку (подкачка волны). Уже стоящие в очереди id пропускаем —
  /// иначе волна крутит одно и то же. [moveToFirstNew] нужен только когда
  /// текущая очередь закончилась; при фоновой докачке позиция не меняется.
  bool appendBatch(List<String> localTrackIds, {bool moveToFirstNew = false}) {
    // Дубли бывают и внутри самой пачки: сингл и альбомная версия, трек из
    // SoundCloud — разные remote id, но один локальный трек.
    final known = _items.toSet();
    final fresh = [
      for (final id in localTrackIds)
        if (known.add(id)) id,
    ];
    if (fresh.isEmpty) return false;

    final firstBase = _items.length;
    _items = [..._items, ...fresh];
    _order = [..._order, for (var i = 0; i < fresh.length; i++) firstBase + i];
    if (moveToFirstNew || _position < 0) {
      _position = _order.length - fresh.length;
    }
    return true;
  }

  void append(String localTrackId) {
    _items = [..._items, localTrackId];
    _order = [..._order, _items.length - 1];
    if (_position < 0) _position = _order.length - 1;
  }

  /// Убрать первую копию трека в отображаемом порядке. Возвращает true,
  /// если убрали именно текущий трек.
  bool remove(String localTrackId) {
    final displayIndex = displayOrder.indexOf(localTrackId);
    return displayIndex < 0 ? false : removeAt(displayIndex);
  }

  /// Убрать строку по позиции в отображаемом порядке. Трек выше текущего
  /// сдвигает позицию: иначе подсветка уезжала на следующую песню, пока
  /// плеер продолжал играть прежнюю. Возвращает true, если убрали текущий.
  bool removeAt(int displayIndex) {
    if (displayIndex < 0 || displayIndex >= _order.length) return false;
    final wasCurrent = displayIndex == _position;
    final index = _order[displayIndex];
    _items = [
      for (var i = 0; i < _items.length; i++)
        if (i != index) _items[i],
    ];
    _order = [
      for (var i = 0; i < _order.length; i++)
        if (i != displayIndex) _remap(_order[i], index),
    ];
    if (displayIndex < _position) _position--;
    if (_order.isEmpty) {
      _position = -1;
    } else if (wasCurrent) {
      _position = _position.clamp(0, _order.length - 1);
    }
    return wasCurrent;
  }

  static int _remap(int oldIndex, int removedIndex) =>
      oldIndex < removedIndex ? oldIndex : oldIndex - 1;

  /// Следующий трек. `manual` — переключение пользователем, тогда repeat=one
  /// тоже идёт вперёд; автопродолжение после окончания трека зовёт с false.
  /// Следующие [count] треков без сдвига позиции — для предзагрузки.
  List<String> peekAhead(int count) => [
    for (var i = 1; i <= count && _position + i < _order.length; i++)
      _items[_order[_position + i]],
  ];

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

  /// Перейти к позиции в отображаемом порядке. Именно позиция, а не id:
  /// в плейлисте один трек может стоять дважды, и поиск по id всегда
  /// приводил бы к первой копии.
  String? jumpToPosition(int displayIndex) {
    if (displayIndex < 0 || displayIndex >= _order.length) return null;
    _position = displayIndex;
    return currentId;
  }

  void setRepeat(PlaybackRepeat mode) => _repeat = mode;

  PlaybackShuffle setShuffle(PlaybackShuffle mode) {
    if (_shuffle == mode) return _shuffle;
    _shuffle = mode;
    // Индекс, а не id: у дублей поиск по id уводил на первую копию.
    final current = currentBaseIndex;
    if (mode == PlaybackShuffle.shuffled) {
      _reshuffle(keepFirst: current < 0 ? null : current);
    } else {
      _order = List.generate(_items.length, (i) => i);
      _position = current;
    }
    return _shuffle;
  }

  void _reshuffle({int? keepFirst}) {
    final indices = [for (var i = 0; i < _items.length; i++) i]..shuffle();
    if (keepFirst != null && indices.remove(keepFirst)) {
      indices.insert(0, keepFirst);
    }
    _order = indices;
    _position = indices.isEmpty ? -1 : 0;
  }
}
