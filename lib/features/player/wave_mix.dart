import '../../core/content/artist_blocklist.dart';
import '../../core/content/remix_filter.dart';
import '../../core/sources/source_dto.dart';

/// Какие треки пачки волны стоит играть, в порядке выдачи.
///
/// Уходят: дизлайки, заблокированные исполнители, дубли и треки сверх
/// [perArtist] одного исполнителя. Недавно слушанное ([recent]) ставится в
/// хвост, а если свежего мало — добирается, чтобы волна не пустела.
List<int> pickWaveIndexes({
  required List<SourceTrack> tracks,
  required List<String> ids,
  required Set<String> recent,
  Set<String> disliked = const {},
  int perArtist = 2,
  int minFresh = 6,
}) {
  final fresh = <int>[];
  final stale = <int>[];
  final perArtistCount = <String, int>{};
  final seen = <String>{};
  for (var i = 0; i < tracks.length; i++) {
    final id = ids[i];
    if (disliked.contains(id) || !seen.add(id)) continue;
    if (ArtistBlocklist.instance.isBlocked(tracks[i].artists)) continue;
    if (RemixFilter.instance.isFiltered(tracks[i])) continue;
    final artist = tracks[i].mainArtist.toLowerCase();
    final count = perArtistCount[artist] ?? 0;
    if (count >= perArtist) continue;
    perArtistCount[artist] = count + 1;
    (recent.contains(id) ? stale : fresh).add(i);
  }
  final missing = minFresh - fresh.length;
  return [...fresh, if (missing > 0) ...stale.take(missing)];
}
