import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';
import '../../l10n/app_localizations.dart';
import 'track_list_importer.dart';

Future<TrackListImportResult?> showTrackListImportSheet(
  BuildContext context,
) => showModalBottomSheet<TrackListImportResult>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  useRootNavigator: true,
  showDragHandle: true,
  builder: (_) => const _TrackListSheet(),
);

class _TrackListSheet extends ConsumerStatefulWidget {
  const _TrackListSheet();

  @override
  ConsumerState<_TrackListSheet> createState() => _TrackListSheetState();
}

class _TrackListSheetState extends ConsumerState<_TrackListSheet> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _lines = TextEditingController();
  bool _busy = false;
  String? _error;
  int _done = 0;
  int _total = 0;

  @override
  void dispose() {
    _title.dispose();
    _lines.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (_busy) return;
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
      final result = await TrackListImporter(
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
          content: Text(
            l.importDone(result.matched, result.skipped, 1),
          ),
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
    return FractionallySizedBox(
      heightFactor: 0.92,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
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
                    Icons.format_list_bulleted_rounded,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l.importList,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _title,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l.importListTitle,
                filled: true,
                fillColor: scheme.surfaceContainerHigh,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
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
                decoration: InputDecoration(
                  labelText: l.importListLines,
                  hintText: l.importListHint,
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: scheme.surfaceContainerHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.importListFormat,
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
              const SizedBox(height: 6),
              Text(
                l.importMatched(_done, (_total - _done).clamp(0, _total)),
                style: theme.textTheme.bodySmall,
              ),
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
        ),
      ),
    );
  }
}
