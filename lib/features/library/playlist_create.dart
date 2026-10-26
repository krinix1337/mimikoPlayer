import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';
import '../../core/sources/source_id.dart';
import '../../l10n/app_localizations.dart';

final class PlaylistDraft {
  const PlaylistDraft({
    required this.id,
    required this.kind,
    required this.title,
  });

  final String id;
  final String kind;
  final String title;
}

/// Создание своего плейлиста: сразу на сервере, а в локальной базе —
/// пустая оболочка, чтобы список обновился без ожидания полного импорта.
Future<PlaylistDraft?> showCreatePlaylistSheet(
  BuildContext context,
  WidgetRef ref,
) => showModalBottomSheet<PlaylistDraft>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  useRootNavigator: true,
  showDragHandle: true,
  builder: (_) => const _CreatePlaylistSheet(),
);

class _CreatePlaylistSheet extends ConsumerStatefulWidget {
  const _CreatePlaylistSheet();

  @override
  ConsumerState<_CreatePlaylistSheet> createState() =>
      _CreatePlaylistSheetState();
}

class _CreatePlaylistSheetState extends ConsumerState<_CreatePlaylistSheet> {
  final TextEditingController _title = TextEditingController();
  bool _public = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final title = _title.text.trim();
    if (title.isEmpty || _busy) return;
    final source = ref.read(yandexSourceProvider);
    if (source == null || !source.auth.isReady) {
      setState(() => _error = l.authNotSignedIn);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final kind = await source.createPlaylist(
        title: title,
        visibility: _public ? 'public' : 'private',
      );
      if (kind == null) {
        if (mounted) {
          setState(() {
            _busy = false;
            _error = l.playlistCreateFailed;
          });
        }
        return;
      }
      final db = ref.read(appServicesProvider).db;
      final id = 'yandex:$kind';
      await db.libraryDao.ensurePlaylistShell(
        id: id,
        source: SourceId.yandex,
        remotePlaylistId: kind,
        title: title,
        totalTracks: 0,
      );
      ref.invalidate(playlistsProvider);
      if (!mounted) return;
      Navigator.of(context).pop(
        PlaylistDraft(id: id, kind: kind, title: title),
      );
      messenger.showSnackBar(
        SnackBar(content: Text(l.playlistCreated(title))),
      );
    } on Object {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = l.playlistCreateFailed;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
                  Icons.playlist_add_rounded,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l.playlistCreate,
                  style: theme.textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _title,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _create(),
            decoration: InputDecoration(
              labelText: l.playlistName,
              hintText: l.playlistNameHint,
              filled: true,
              fillColor: scheme.surfaceContainerHigh,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  l.playlistVisibility,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: true,
                    icon: const Icon(Icons.public_rounded, size: 18),
                    label: Text(l.playlistPublic),
                  ),
                  ButtonSegment(
                    value: false,
                    icon: const Icon(Icons.lock_outline_rounded, size: 18),
                    label: Text(l.playlistPrivate),
                  ),
                ],
                selected: {_public},
                showSelectedIcon: false,
                onSelectionChanged: (value) =>
                    setState(() => _public = value.first),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _busy ? null : _create,
            icon: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded),
            label: Text(l.playlistCreateAction),
          ),
        ],
      ),
    );
  }
}
