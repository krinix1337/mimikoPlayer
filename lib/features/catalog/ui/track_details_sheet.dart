import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../app_providers.dart';
import '../../../core/db/database.dart';
import '../../../core/sources/source_dto.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_motion.dart';
import '../../../widgets/track_cover.dart';

Future<void> showTrackDetails(
  BuildContext context,
  WidgetRef ref,
  String localTrackId,
) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (_) => _TrackDetailsSheet(localTrackId: localTrackId),
);

class _TrackDetailsSheet extends ConsumerStatefulWidget {
  const _TrackDetailsSheet({required this.localTrackId});

  final String localTrackId;

  @override
  ConsumerState<_TrackDetailsSheet> createState() => _TrackDetailsSheetState();
}

class _TrackDetailsSheetState extends ConsumerState<_TrackDetailsSheet> {
  late final Future<_DetailsData> _future = _load();

  Future<_DetailsData> _load() async {
    final services = ref.read(appServicesProvider);
    final track = await services.db.tracksDao.byId(widget.localTrackId);
    if (track == null) throw StateError('track not found');
    final artists = await services.db.tracksDao.artistNamesOf(track.id);
    final album = await services.db.tracksDao.albumTitleOf(track.id);
    final year = await services.db.tracksDao.albumYearOf(track.id);
    final file = await services.db.streamsDao.downloadedFile(track.id);
    final variants = await services.db.tracksDao.variantsOf(track.id);
    final rawKey = await services.db.settingsDao.value('dj_key_${track.id}');
    String? manualKey;
    if (rawKey != null) {
      try {
        manualKey = jsonDecode(rawKey) as String?;
      } on FormatException {
        manualKey = null;
      }
    }
    return _DetailsData(
      track: track,
      artists: artists,
      album: album,
      year: year,
      file: file,
      variants: variants,
      manualKey: manualKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final prefs = ref.watch(prefsProvider);
    return SafeArea(
      child: FutureBuilder<_DetailsData>(
        future: _future,
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l.dbError('${snapshot.error}')),
            );
          }
          if (data == null) {
            return const SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final track = data.track;
          final file = data.file;
          final source = _sourceName(l, track.metadataSource);
          final sources = {
            for (final variant in data.variants)
              _sourceName(l, variant.ref.source.wire),
          }.join(', ');
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    TrackCover(
                      url: track.coverUrl,
                      size: 64,
                      radius: Motion.of(context).prefs.corner.radius * 0.6,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge,
                          ),
                          Text(
                            data.artists.isEmpty
                                ? l.trackUnknownArtist
                                : data.artists.join(', '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _InfoRow(label: l.detailsSource, value: source),
                if (sources.isNotEmpty)
                  _InfoRow(label: l.detailsSources, value: sources),
                _InfoRow(label: l.detailsAlbum, value: data.album ?? '—'),
                if (data.year != null)
                  _InfoRow(label: l.detailsYear, value: '${data.year}'),
                _InfoRow(
                  label: l.detailsDuration,
                  value: _duration(track.durationSec),
                ),
                _InfoRow(label: l.detailsIsrc, value: track.isrc ?? '—'),
                _InfoRow(
                  label: l.detailsQuality,
                  value: _qualityName(l, file?.quality ?? prefs.quality),
                ),
                if (file != null) ...[
                  _InfoRow(label: l.detailsCodec, value: file.codec ?? '—'),
                  _InfoRow(label: l.detailsSize, value: _bytes(file.sizeBytes)),
                  _InfoRow(label: l.detailsFile, value: file.filePath),
                ],
                _InfoRow(
                  label: l.detailsRemoteId,
                  value: data.variants.isEmpty
                      ? '—'
                      : data.variants.first.ref.remoteId,
                ),
                _InfoRow(label: l.detailsLocalId, value: track.id),
                if (ref.watch(prefsProvider.select((p) => p.showDjInfo))) ...[
                  const SizedBox(height: 16),
                  Divider(color: theme.colorScheme.outlineVariant),
                  const SizedBox(height: 12),
                  _DjInfo(
                    trackId: track.id,
                    title: track.title,
                    artist: data.artists.isEmpty ? '' : data.artists.first,
                    manualKey: data.manualKey,
                  ),
                ],
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l.waveClose),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static String _sourceName(AppLocalizations l, String wire) => switch (wire) {
    'yandex' => l.sourceYandex,
    'youtube' => l.sourceYoutube,
    'local' => l.sourceLocalFile,
    'soundcloud' => 'SoundCloud',
    _ => wire,
  };

  static String _qualityName(AppLocalizations l, String wire) => switch (wire) {
    'low' => l.qualityLow,
    'normal' => l.qualityNormal,
    'high' => l.qualityHigh,
    'lossless' => l.qualityLossless,
    _ => l.qualityAuto,
  };

  static String _duration(int seconds) {
    final minutes = seconds ~/ 60;
    final rest = seconds % 60;
    return '$minutes:${rest.toString().padLeft(2, '0')}';
  }

  static String _bytes(int value) {
    if (value < 1024) return '$value B';
    if (value < 1024 * 1024) return '${(value / 1024).toStringAsFixed(0)} KB';
    return '${(value / 1024 / 1024).toStringAsFixed(1)} MB';
  }
}

class _DetailsData {
  const _DetailsData({
    required this.track,
    required this.artists,
    required this.album,
    required this.year,
    required this.file,
    required this.variants,
    required this.manualKey,
  });

  final Track track;
  final List<String> artists;
  final String? album;
  final int? year;
  final DownloadedFile? file;
  final List<SourceTrack> variants;
  final String? manualKey;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 108,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _DjInfo extends ConsumerStatefulWidget {
  const _DjInfo({
    required this.trackId,
    required this.title,
    required this.artist,
    required this.manualKey,
  });

  final String trackId;
  final String title;
  final String artist;
  final String? manualKey;

  @override
  ConsumerState<_DjInfo> createState() => _DjInfoState();
}

class _DjInfoState extends ConsumerState<_DjInfo> {
  static final _cache = <String, _DeezerDjData?>{};
  late final Future<_DeezerDjData?> _future = _load();
  String? _key;

  @override
  void initState() {
    super.initState();
    _key = widget.manualKey;
  }

  Future<_DeezerDjData?> _load() async {
    final cacheKey = '${widget.artist}|${widget.title}'.toLowerCase();
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey];
    try {
      final query = Uri.encodeQueryComponent(
        [widget.artist, widget.title].where((e) => e.isNotEmpty).join(' '),
      );
      final response = await http.get(
        Uri.parse('https://api.deezer.com/search?q=$query&limit=1'),
        headers: const {'User-Agent': 'mimikoPlayer/1.2'},
      );
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(response.body);
      final data = decoded is Map ? decoded['data'] : null;
      if (data is! List || data.isEmpty) {
        _cache[cacheKey] = null;
        return null;
      }
      final first = data.first;
      final id = first is Map ? first['id'] : null;
      if (id == null) return null;
      final trackResponse = await http.get(
        Uri.parse('https://api.deezer.com/track/$id'),
        headers: const {'User-Agent': 'mimikoPlayer/1.2'},
      );
      if (trackResponse.statusCode != 200) return null;
      final track = jsonDecode(trackResponse.body);
      if (track is! Map) return null;
      final result = _DeezerDjData(
        bpm: (track['bpm'] as num?)?.toDouble(),
        gain: (track['gain'] as num?)?.toDouble(),
      );
      _cache[cacheKey] = result;
      return result;
    } on Object {
      return null;
    }
  }

  Future<void> _setKey(String? value) async {
    final services = ref.read(appServicesProvider);
    await services.db.settingsDao.setValue('dj_key_${widget.trackId}', value);
    if (mounted) setState(() => _key = value);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.djInfo, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        FutureBuilder<_DeezerDjData?>(
          future: _future,
          builder: (context, snapshot) {
            final data = snapshot.data;
            return Column(
              children: [
                _InfoRow(
                  label: l.djBpm,
                  value: snapshot.connectionState == ConnectionState.waiting
                      ? '…'
                      : data?.bpm == null
                      ? '—'
                      : '${data!.bpm!.round()}',
                ),
                _InfoRow(
                  label: l.djGain,
                  value: data?.gain == null
                      ? '—'
                      : '${data!.gain!.toStringAsFixed(1)} dB',
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 108,
                        child: Text(
                          l.djKey,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _key ?? '',
                            isExpanded: true,
                            items: [
                              DropdownMenuItem<String>(
                                value: '',
                                child: Text(l.djNoKey),
                              ),
                              for (final key in _camelotKeys.entries)
                                DropdownMenuItem<String>(
                                  value: key.key,
                                  child: Text('${key.key} · ${key.value}'),
                                ),
                            ],
                            onChanged: (value) => _setKey(
                              value == null || value.isEmpty ? null : value,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 4),
        Text(
          l.djSourceNote,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _DeezerDjData {
  const _DeezerDjData({this.bpm, this.gain});

  final double? bpm;
  final double? gain;
}

const _camelotKeys = <String, String>{
  '1A': 'A♭ minor',
  '1B': 'B major',
  '2A': 'E♭ minor',
  '2B': 'F♯ major',
  '3A': 'B♭ minor',
  '3B': 'D♭ major',
  '4A': 'F minor',
  '4B': 'A♭ major',
  '5A': 'C minor',
  '5B': 'E♭ major',
  '6A': 'G minor',
  '6B': 'B♭ major',
  '7A': 'D minor',
  '7B': 'F major',
  '8A': 'A minor',
  '8B': 'C major',
  '9A': 'E minor',
  '9B': 'G major',
  '10A': 'B minor',
  '10B': 'D major',
  '11A': 'F♯ minor',
  '11B': 'A major',
  '12A': 'C♯ minor',
  '12B': 'E major',
};
