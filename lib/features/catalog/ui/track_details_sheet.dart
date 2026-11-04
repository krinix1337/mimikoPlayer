import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app_providers.dart';
import '../../../core/db/database.dart';
import '../../../core/sources/source_dto.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_motion.dart';
import '../../../widgets/track_cover.dart';
import '../../../widgets/human_bytes.dart';
import '../../../widgets/expressive_loader.dart';

Future<void> showTrackDetails(
  BuildContext context,
  WidgetRef ref,
  String localTrackId,
) => showModalBottomSheet<void>(
  useRootNavigator: true,
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
    return _DetailsData(
      track: track,
      artists: artists,
      album: album,
      year: year,
      file: file,
      variants: variants,
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
              child: Center(child: ExpressiveLoader()),
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
                // Список вариантов нужен, только когда он что-то добавляет к
                // строке выше: «Источник: Яндекс» и «Источники: Яндекс» дублировались.
                if (sources.isNotEmpty && sources != source)
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
                  _InfoRow(
                    label: l.detailsSize,
                    value: humanBytes(l, file.sizeBytes),
                  ),
                  _InfoRow(label: l.detailsFile, value: file.filePath),
                ],
                _InfoRow(
                  label: l.detailsRemoteId,
                  value: data.variants.isEmpty
                      ? '—'
                      : data.variants.first.ref.remoteId,
                ),
                _InfoRow(label: l.detailsLocalId, value: track.id),
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
}

class _DetailsData {
  const _DetailsData({
    required this.track,
    required this.artists,
    required this.album,
    required this.year,
    required this.file,
    required this.variants,
  });

  final Track track;
  final List<String> artists;
  final String? album;
  final int? year;
  final DownloadedFile? file;
  final List<SourceTrack> variants;
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
