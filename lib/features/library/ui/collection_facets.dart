import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app_providers.dart';
import '../../../core/db/daos/library_dao.dart';
import '../../../core/sources/source_id.dart';
import '../../../widgets/select_pill.dart';

/// Жанры и источники треков раздела коллекции — для фильтра, как в
/// «Мне нравится» Яндекс Музыки на ПК.
final trackFacetsProvider = FutureProvider.autoDispose
    .family<Map<String, TrackFacet>, CollectionKind>((ref, kind) async {
      final rows = await ref.watch(collectionProvider(kind).future);
      final db = ref.watch(appServicesProvider).db;
      return db.libraryDao.trackFacets([
        for (final row in rows) row.localTrackId,
      ]);
    });

/// Выбранный фильтр: `null` — всё, `src:<wire>` — источник, `g:<код>` — жанр.
typedef FacetKey = String?;

List<CollectionRow> applyFacet(
  List<CollectionRow> rows,
  Map<String, TrackFacet> facets,
  FacetKey key,
) {
  if (key == null) return rows;
  if (key.startsWith('src:')) {
    final source = SourceId.fromWire(key.substring(4));
    return [
      for (final row in rows)
        if (facets[row.localTrackId]?.sources.contains(source) ??
            row.source == source)
          row,
    ];
  }
  final genre = key.substring(2);
  return [
    for (final row in rows)
      if (facets[row.localTrackId]?.genre == genre) row,
  ];
}

/// Подписи жанров Яндекса. Неизвестный код показываем как есть.
String genreLabel(String code, bool russian) {
  const ru = {
    'rusrap': 'Русский рэп',
    'rap': 'Рэп и хип-хоп',
    'foreignrap': 'Зарубежный рэп',
    'pop': 'Поп',
    'ruspop': 'Русская поп-музыка',
    'rock': 'Рок',
    'rusrock': 'Русский рок',
    'alternative': 'Альтернатива',
    'indie': 'Инди',
    'local-indie': 'Местная инди',
    'rusindie': 'Русская инди',
    'electronics': 'Электроника',
    'dance': 'Танцевальная',
    'house': 'Хаус',
    'techno': 'Техно',
    'rnb': 'R&B',
    'soul': 'Соул',
    'metal': 'Метал',
    'punk': 'Панк',
    'postpunk': 'Пост-панк',
    'jazz': 'Джаз',
    'classical': 'Классика',
    'folk': 'Фолк',
    'soundtrack': 'Саундтреки',
    'films': 'Из фильмов',
    'videogame': 'Из игр',
    'phonk': 'Фонк',
    'lounge': 'Лаунж',
    'ambient': 'Эмбиент',
    'reggae': 'Регги',
    'estrada': 'Эстрада',
    'shanson': 'Шансон',
    'kpop': 'K-pop',
    'anime': 'Аниме',
    'hyperpop': 'Гиперпоп',
    'experimental': 'Экспериментальная',
  };
  const en = {
    'rusrap': 'Russian rap',
    'rap': 'Rap & hip-hop',
    'foreignrap': 'Foreign rap',
    'ruspop': 'Russian pop',
    'rusrock': 'Russian rock',
    'electronics': 'Electronic',
    'local-indie': 'Local indie',
    'soundtrack': 'Soundtracks',
  };
  final map = russian ? ru : en;
  final known = map[code];
  if (known != null) return known;
  if (code.isEmpty) return code;
  return code[0].toUpperCase() + code.substring(1).replaceAll('-', ' ');
}

/// Полоса фильтров над списком: «Все», источники (если их больше одного) и
/// самые частые жанры. Прокручивается вбок.
class FacetBar extends StatelessWidget {
  const FacetBar({
    super.key,
    required this.rows,
    required this.facets,
    required this.selected,
    required this.onSelect,
  });

  final List<CollectionRow> rows;
  final Map<String, TrackFacet> facets;
  final FacetKey selected;
  final ValueChanged<FacetKey> onSelect;

  @override
  Widget build(BuildContext context) {
    final russian = Localizations.localeOf(context).languageCode == 'ru';
    final bySource = <SourceId, int>{};
    final byGenre = <String, int>{};
    for (final row in rows) {
      final facet = facets[row.localTrackId];
      for (final source in facet?.sources ?? {row.source}) {
        bySource[source] = (bySource[source] ?? 0) + 1;
      }
      final genre = facet?.genre;
      if (genre != null && genre.isNotEmpty) {
        byGenre[genre] = (byGenre[genre] ?? 0) + 1;
      }
    }
    final genres = byGenre.entries.where((e) => e.value >= 3).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final pills = <Widget>[
      SelectPill(
        label: russian ? 'Всё' : 'All',
        selected: selected == null,
        onTap: () => onSelect(null),
      ),
      // Источник показываем, только когда их хотя бы два: иначе фильтр пустой.
      if (bySource.length > 1)
        for (final source in [SourceId.yandex, SourceId.soundcloud])
          if (bySource[source] != null)
            SelectPill(
              label: source == SourceId.yandex ? 'Яндекс Музыка' : 'SoundCloud',
              icon: source == SourceId.yandex
                  ? Icons.music_note_rounded
                  : Icons.cloud_rounded,
              count: bySource[source],
              selected: selected == 'src:${source.wire}',
              onTap: () => onSelect('src:${source.wire}'),
            ),
      for (final genre in genres.take(10))
        SelectPill(
          label: genreLabel(genre.key, russian),
          count: genre.value,
          selected: selected == 'g:${genre.key}',
          onTap: () => onSelect('g:${genre.key}'),
        ),
    ];
    if (pills.length < 2) return const SizedBox.shrink();

    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        itemCount: pills.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, index) => pills[index],
      ),
    );
  }
}
