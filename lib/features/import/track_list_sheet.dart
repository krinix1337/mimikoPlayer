import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';
import '../../l10n/app_localizations.dart';
import '../../core/sources/source_id.dart';
import '../../sources/soundcloud/soundcloud_source.dart';
import 'playlist_link_fetcher.dart';
import 'track_list_importer.dart';

/// [byLink] — отдельный перенос по ссылке на открытый плейлист: только
/// поле ссылки, без списка строк.
Future<TrackListImportResult?> showTrackListImportSheet(
  BuildContext context, {
  bool byLink = false,
}) => showModalBottomSheet<TrackListImportResult>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  useRootNavigator: true,
  showDragHandle: true,
  builder: (_) => _TrackListSheet(byLink: byLink),
);

class _TrackListSheet extends ConsumerStatefulWidget {
  const _TrackListSheet({required this.byLink});

  final bool byLink;

  @override
  ConsumerState<_TrackListSheet> createState() => _TrackListSheetState();
}

class _TrackListSheetState extends ConsumerState<_TrackListSheet> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _lines = TextEditingController();
  final TextEditingController _link = TextEditingController();
  bool _busy = false;
  String? _error;
  int _done = 0;
  int _total = 0;

  @override
  void dispose() {
    _title.dispose();
    _lines.dispose();
    _link.dispose();
    super.dispose();
  }

  /// Ссылка на плейлист: Яндекс открываем сразу, чужой сервис превращаем
  /// в строки и дальше переносим как обычный список. false — дальше не идём.
  Future<bool> _fromLink() async {
    final l = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    final registry = ref.read(appServicesProvider).registry;
    final soundCloud = registry.byId(SourceId.soundcloud);
    PlaylistLinkResult? found;
    try {
      found = await PlaylistLinkFetcher(
        soundCloud: soundCloud is SoundCloudSource ? soundCloud : null,
      ).fetch(_link.text);
    } on Object {
      found = null;
    }
    if (!mounted) return false;
    setState(() => _busy = false);
    switch (found) {
      case PlaylistLinkYandex(:final remotePlaylistId):
        Navigator.of(context).pop(
          TrackListImportResult(
            matched: 0,
            skipped: 0,
            playlistId: 'yandex:$remotePlaylistId',
          ),
        );
        return false;
      case PlaylistLinkRows(:final title, :final rows):
        if (_title.text.trim().isEmpty) _title.text = title;
        _lines.text = rows.join('\n');
        return true;
      case null:
        setState(() => _error = l.importLinkFailed);
        return false;
    }
  }

  Future<void> _run() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (_busy) return;
    if (_link.text.trim().isNotEmpty && !await _fromLink()) return;
    if (!mounted) return;
    if (_lines.text.trim().isEmpty) {
      setState(() => _error = l.importListEmpty);
      return;
    }
    final yandex = ref.read(yandexSourceProvider);
    if (yandex == null || !yandex.auth.isReady) {
      setState(() => _error = l.importYandexRequired);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _done = 0;
      _total = 0;
    });
    try {
      final result =
          await TrackListImporter(
            yandex: yandex,
            db: ref.read(appServicesProvider).db,
          ).import(
            title: _title.text,
            text: _lines.text,
            onProgress: (done, total) {
              if (mounted) {
                setState(() {
                  _done = done;
                  _total = total;
                });
              }
            },
          );
      ref.invalidate(playlistsProvider);
      if (!mounted) return;
      Navigator.of(context).pop(result);
      messenger.showSnackBar(
        SnackBar(
          content: Text(l.importDone(result.matched, result.skipped, 1)),
        ),
      );
    } on Object {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = l.importFailed;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final byLink = widget.byLink;
    InputDecoration field(String label, {String? hint, Widget? prefix}) =>
        InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefix,
          alignLabelWithHint: true,
          filled: true,
          fillColor: scheme.surfaceContainerHigh,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        );
    final content = Column(
      mainAxisSize: byLink ? MainAxisSize.min : MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                byLink
                    ? Icons.link_rounded
                    : Icons.format_list_bulleted_rounded,
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                byLink ? l.importLinkTitle : l.importList,
                style: theme.textTheme.titleLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (byLink)
          TextField(
            controller: _link,
            autofocus: true,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _run(),
            decoration: field(
              l.importLinkLabel,
              hint: l.importLinkHint,
              prefix: const Icon(Icons.link_rounded),
            ),
          )
        else ...[
          TextField(
            controller: _title,
            textInputAction: TextInputAction.next,
            decoration: field(l.importListTitle),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TextField(
              controller: _lines,
              expands: true,
              maxLines: null,
              minLines: null,
              textAlignVertical: TextAlignVertical.top,
              keyboardType: TextInputType.multiline,
              decoration: field(l.importListLines, hint: l.importListHint),
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          byLink ? l.importLinkNote : l.importListFormat,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        if (_busy) ...[
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: _total == 0 ? null : _done / _total,
            minHeight: 4,
            borderRadius: BorderRadius.circular(4),
          ),
          if (_total > 0) ...[
            const SizedBox(height: 6),
            Text(
              l.importMatched(_done, (_total - _done).clamp(0, _total)),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(
            _error!,
            style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
          ),
        ],
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: _busy ? null : _run,
          icon: const Icon(Icons.playlist_add_check_rounded),
          label: Text(l.importListAction),
        ),
      ],
    );
    final padding = EdgeInsets.fromLTRB(
      20,
      0,
      20,
      20 + MediaQuery.viewInsetsOf(context).bottom,
    );
    // По ссылке лист по высоте содержимого, список — почти на весь экран.
    return byLink
        ? Padding(padding: padding, child: content)
        : FractionallySizedBox(
            heightFactor: 0.92,
            child: Padding(padding: padding, child: content),
          );
  }
}
