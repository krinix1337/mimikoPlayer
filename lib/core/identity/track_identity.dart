import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../sources/source_dto.dart';
import 'normalizer.dart';

/// Насколько уверенно удалённый трек сведён с локальной строкой.
enum MatchTier {
  /// Совпал `(source, remoteId)` — самый частый путь.
  exactRemote,

  /// Совпал ISRC: надёжно, но поле есть не у всех источников.
  isrc,

  /// Совпал отпечаток из нормализованных имени, артиста и длительности.
  fingerprint,

  /// Нечёткое совпадение. Крепит только mapping, строки не сливает.
  fuzzy,

  none,
}

String normalizeIsrc(String? isrc) {
  if (isrc == null) return '';
  final cleaned = isrc.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  return cleaned.length == 12 ? cleaned : '';
}

/// Отпечаток: нормализованное имя | первый артист | длительность в секундах.
String trackFingerprint(SourceTrack track) {
  final seconds = (track.duration.inMilliseconds / 1000).round();
  final key = '${normalizeTitle(track.title)}|'
      '${mainArtistOf(track.artists)}|$seconds';
  return sha1.convert(utf8.encode(key)).toString();
}

/// Локальный идентификатор трека. Never удалённый id: одна песня живёт в
/// четырёх каталогах и в файлах пользователя.
String localTrackIdFor(SourceTrack track) =>
    't_${trackFingerprint(track).substring(0, 24)}';

/// Нечёткое совпадение: та же нормализованная длина и имя, артист либо
/// полностью содержит другой, либо правки в имени минимум две.
bool isFuzzyMatch(
  SourceTrack a,
  SourceTrack b, {
  int durationToleranceSec = 3,
  double minArtistOverlap = 0.85,
}) {
  final secondsA = (a.duration.inMilliseconds / 1000).round();
  final secondsB = (b.duration.inMilliseconds / 1000).round();
  if ((secondsA - secondsB).abs() > durationToleranceSec) return false;

  final titleA = normalizeTitle(a.title);
  final titleB = normalizeTitle(b.title);
  if (titleA != titleB && _editDistance(titleA, titleB) > 2) return false;

  final artistsA = a.artists.expand(tokenize).toSet();
  final artistsB = b.artists.expand(tokenize).toSet();
  return tokenOverlap(artistsA, artistsB) >= minArtistOverlap;
}

int _editDistance(String a, String b) {
  if (a == b) return 0;
  var previous = List<int>.generate(b.length + 1, (i) => i);
  for (var i = 1; i <= a.length; i++) {
    final current = [i];
    for (var j = 1; j <= b.length; j++) {
      final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
      current.add([
        previous[j] + 1,
        current[j - 1] + 1,
        previous[j - 1] + cost,
      ].reduce((x, y) => x < y ? x : y));
    }
    previous = current;
  }
  return previous.last;
}
