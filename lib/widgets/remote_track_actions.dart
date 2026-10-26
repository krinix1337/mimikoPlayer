import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_providers.dart';
import '../core/sources/source_dto.dart';
import '../features/catalog/ui/track_menu.dart';
import '../features/downloads/download_service.dart';
import '../l10n/app_localizations.dart';

/// Скачивание и меню для трека, которого может ещё не быть в локальной базе:
/// перед действием трек один раз сводится в БД, дальше статус берётся по id.
class RemoteTrackActions extends ConsumerStatefulWidget {
  const RemoteTrackActions({
    super.key,
    required this.track,
    this.showDownload = true,
  });

  final SourceTrack track;

  /// Чарт не должен предлагать скачивание: там только меню.
  final bool showDownload;

  @override
  ConsumerState<RemoteTrackActions> createState() => _RemoteTrackActionsState();
}

class _RemoteTrackActionsState extends ConsumerState<RemoteTrackActions> {
  String? _localId;
  bool _ingesting = false;

  @override
  void initState() {
    super.initState();
    // Трек уже может быть в базе (например, скачан): находим строку без
    // ingest, иначе кнопка показывала «скачать» вместо офлайн-пина.
    unawaited(_resolveExisting());
  }

  Future<void> _resolveExisting() async {
    final id = await ref
        .read(appServicesProvider)
        .db
        .tracksDao
        .localIdForRemote(widget.track.ref);
    if (id != null && mounted) setState(() => _localId = id);
  }

  Future<String?> _ensureLocal() async {
    if (_localId != null) return _localId;
    if (_ingesting) return null;
    setState(() => _ingesting = true);
    try {
      final ingested = await ref
          .read(appServicesProvider)
          .db
          .tracksDao
          .ingest(widget.track);
      _localId = ingested.localTrackId;
      return _localId;
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).dbError('$error')),
          ),
        );
      }
      return null;
    } finally {
      _ingesting = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> _openMenu() async {
    final id = await _ensureLocal();
    if (id == null || !mounted) return;
    showTrackMenu(
      context,
      ref,
      id,
      title: widget.track.title,
      artistName: widget.track.artists.join(', '),
      coverUrl: widget.track.coverUrl,
      durationSec: widget.track.duration.inSeconds,
    );
  }

  Future<void> _download() async {
    final id = await _ensureLocal();
    if (id == null) return;
    try {
      await ref.read(downloadControllerProvider.notifier).start(id);
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).downloadFailed('$error'),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final id = _localId;

    Widget download;
    if (_ingesting) {
      download = const SizedBox(
        width: 36,
        height: 40,
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2.2),
          ),
        ),
      );
    } else if (id == null) {
      download = IconButton(
        tooltip: l.playerDownload,
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints.tightFor(width: 36, height: 40),
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.download_rounded, size: 20),
        onPressed: _download,
      );
    } else {
      download = Consumer(
        builder: (context, ref, _) {
          final status = ref.watch(downloadStatusProvider(id));
          final stored = ref.watch(isDownloadedProvider(id)).value ?? false;
          final downloading = status?.phase == DownloadPhase.downloading;
          final paused = status?.phase == DownloadPhase.paused;
          final complete =
              status?.phase == DownloadPhase.complete ||
              (status?.phase == null && stored);
          if (downloading) {
            return SizedBox(
              width: 36,
              height: 40,
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    value: status?.progress,
                    strokeWidth: 2.2,
                  ),
                ),
              ),
            );
          }
          if (complete) {
            return Tooltip(
              message: l.trackDownloaded,
              child: SizedBox(
                width: 36,
                height: 40,
                child: Center(
                  child: Icon(
                    Icons.offline_pin_rounded,
                    size: 20,
                    color: scheme.primary,
                  ),
                ),
              ),
            );
          }
          final failed =
              status?.phase == DownloadPhase.failed ||
              status?.phase == DownloadPhase.skipped;
          return IconButton(
            tooltip: paused
                ? l.downloadsResume
                : failed
                ? l.menuDownloadRetry
                : l.playerDownload,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints.tightFor(width: 36, height: 40),
            padding: EdgeInsets.zero,
            icon: Icon(
              paused
                  ? Icons.play_arrow_rounded
                  : failed
                  ? Icons.refresh_rounded
                  : Icons.download_rounded,
              size: 20,
            ),
            onPressed: _download,
          );
        },
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showDownload) download,
        IconButton(
          tooltip: l.trackMenu,
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints.tightFor(width: 36, height: 40),
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.more_vert_rounded, size: 20),
          onPressed: _ingesting ? null : _openMenu,
        ),
      ],
    );
  }
}
