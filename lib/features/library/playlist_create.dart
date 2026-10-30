import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';
import '../../core/sources/source_id.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/track_cover.dart';
import 'playlist_cover.dart';

final class PlaylistDraft {
  const PlaylistDraft({
    required this.id,
    required this.kind,
    required this.title,
    this.local = false,
  });

  final String id;
  final String kind;
  final String title;

  /// true — плейлист только на устройстве (`pl_…`), без записи в Яндекс.
  final bool local;
}

/// Создание плейлиста: в Яндексе (сразу на сервере) или только на устройстве.
/// В локальную базу кладётся пустая оболочка, чтобы список обновился без
/// ожидания полного импорта.
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
  late final bool _yandexReady = _checkYandex();
  late bool _local = !_yandexReady;
  bool _public = true;
  bool _busy = false;
  String? _error;
  String? _cover;

  bool _checkYandex() {
    final source = ref.read(yandexSourceProvider);
    return source != null && source.auth.isReady;
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickCover() async {
    final picked = await pickPlaylistCoverFile();
    if (picked != null && mounted) setState(() => _cover = picked);
  }

  Future<void> _create() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final title = _title.text.trim();
    if (title.isEmpty || _busy) return;
    final db = ref.read(appServicesProvider).db;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      late final String id;
      late final String kind;
      if (_local) {
        id = await db.libraryDao.createLocalPlaylist(title);
        kind = id;
      } else {
        final source = ref.read(yandexSourceProvider);
        if (source == null || !source.auth.isReady) {
          setState(() {
            _busy = false;
            _error = l.authNotSignedIn;
          });
          return;
        }
        final created = await source.createPlaylist(
          title: title,
          visibility: _public ? 'public' : 'private',
        );
        if (created == null) {
          if (mounted) {
            setState(() {
              _busy = false;
              _error = l.playlistCreateFailed;
            });
          }
          return;
        }
        kind = created;
        id = 'yandex:$kind';
        await db.libraryDao.ensurePlaylistShell(
          id: id,
          source: SourceId.yandex,
          remotePlaylistId: kind,
          title: title,
          totalTracks: 0,
        );
      }
      if (_cover != null) {
        await db.libraryDao.setPlaylistCover(id, _cover);
      }
      ref.invalidate(playlistsProvider);
      if (!mounted) return;
      Navigator.of(context)
          .pop(PlaylistDraft(id: id, kind: kind, title: title, local: _local));
      messenger.showSnackBar(SnackBar(content: Text(l.playlistCreated(title))));
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
    return SingleChildScrollView(
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
          Text(l.playlistCreate, style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(
            children: [
              // Обложка: тап выбирает картинку из галереи.
              GestureDetector(
                onTap: _busy ? null : _pickCover,
                child: _cover == null
                    ? Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          Icons.add_photo_alternate_outlined,
                          color: scheme.onSurfaceVariant,
                        ),
                      )
                    : TrackCover(url: _cover, size: 84, radius: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextField(
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
              ),
            ],
          ),
          if (_cover != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _busy ? null : () => setState(() => _cover = null),
                child: Text(l.playlistCoverRemove),
              ),
            ),
          const SizedBox(height: 10),
          if (_yandexReady) ...[
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                  value: false,
                  icon: const Icon(Icons.music_note_rounded, size: 18),
                  label: Text(l.playlistTargetYandex),
                ),
                ButtonSegment(
                  value: true,
                  icon: const Icon(Icons.smartphone_rounded, size: 18),
                  label: Text(l.playlistTargetDevice),
                ),
              ],
              selected: {_local},
              showSelectedIcon: false,
              onSelectionChanged: (value) =>
                  setState(() => _local = value.first),
            ),
            const SizedBox(height: 12),
          ],
          if (!_local)
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
            )
          else
            Text(
              l.playlistDeviceNote,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
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
