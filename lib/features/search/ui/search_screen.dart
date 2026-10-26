import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app_providers.dart';
import '../../../core/content/ai_filter.dart';
import '../../../core/sources/source_dto.dart';
import '../../../features/auth/ui/yandex_login.dart';
import '../../../l10n/app_localizations.dart';
import '../../../router/routes.dart';
import '../../../widgets/remote_track_actions.dart';
import '../../../widgets/track_badges.dart';
import '../../../widgets/track_cover.dart';
import '../../../widgets/track_tile.dart';

/// Поиск сразу по всем готовым источникам: локальные файлы и, после входа,
/// Я.Музыка. Пустой результат — это пустой результат, а не заглушка.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Запрос уходит через 400 м после последнего нажатия: иначе на каждый
  /// символ летит пакет запросов во все источники.
  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  void _submit(String value) {
    _debounce?.cancel();
    final query = value.trim();
    if (query.isEmpty) return;
    setState(() => _query = query);
    ref.read(prefsProvider.notifier).rememberSearch(query);
  }

  void _applyQuery(String query) {
    _debounce?.cancel();
    _controller.text = query;
    _controller.selection = TextSelection.collapsed(offset: query.length);
    setState(() => _query = query);
    ref.read(prefsProvider.notifier).rememberSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final hits = _query.isEmpty
        ? const AsyncValue<List<SourceSearchHit>>.data([])
        : ref.watch(combinedSearchProvider(_query));
    final auth =
        ref.watch(yandexAuthStateProvider).value ?? const AuthUnknown();
    final history = ref.watch(prefsProvider.select((p) => p.searchHistory));

    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: l.playerBack,
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: SearchBar(
                      controller: _controller,
                      autoFocus: true,
                      textInputAction: TextInputAction.search,
                      hintText: l.searchHint,
                      onChanged: _onChanged,
                      onSubmitted: _submit,
                      elevation: const WidgetStatePropertyAll(0),
                      backgroundColor: WidgetStatePropertyAll(
                        scheme.surfaceContainerHigh,
                      ),
                      leading: const Icon(Icons.search_rounded),
                      trailing: [
                        if (_query.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              _controller.clear();
                              _onChanged('');
                              setState(() => _query = '');
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!auth.isReady)
            MaterialBanner(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
              leading: const Icon(Icons.account_circle_outlined),
              content: Text(l.authNotSignedIn),
              actions: [
                TextButton(
                  onPressed: () => showYandexLogin(context, ref),
                  child: Text(l.waveSignIn),
                ),
              ],
            ),
          Expanded(
            child: _query.isEmpty
                ? history.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(28),
                            child: Text(
                              l.searchEmpty,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        )
                      : _SearchHistory(
                          items: history,
                          onPick: _applyQuery,
                          onClear: () => ref
                              .read(prefsProvider.notifier)
                              .clearSearchHistory(),
                        )
                : hits.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Center(child: Text(l.searchFailed)),
                    data: (list) => list.isEmpty
                        ? Center(child: Text(l.searchNoResults))
                        : ListView.builder(
                            itemCount: list.length,
                            itemBuilder: (context, index) => _HitTile(
                              hit: list[index],
                              all: list,
                              index: index,
                              query: _query,
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _HitTile extends ConsumerWidget {
  const _HitTile({
    required this.hit,
    required this.all,
    required this.index,
    required this.query,
  });

  final SourceSearchHit hit;
  final List<SourceSearchHit> all;
  final int index;
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final track = hit.track;
    final aiReady = ref.watch(aiBadgeReadyProvider).hasValue;
    final isAi = aiReady && AiFilter.instance.isAiTrack(track);
    return ListTile(
      onTap: () => _play(context, ref),
      leading: Hero(
        tag: coverHeroTag('${track.ref.source.wire}:${track.ref.remoteId}'),
        child: TrackCover(url: track.coverUrl, size: 52),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              track.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (track.explicitFlag || isAi) ...[
            const SizedBox(width: 6),
            TrackBadges(explicit: track.explicitFlag, ai: isAi),
          ],
        ],
      ),
      subtitle: Text(
        track.artists.isEmpty
            ? track.ref.source.wire
            : '${track.artists.join(', ')} · ${track.ref.source.wire}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: track.available
          ? RemoteTrackActions(track: track)
          : Icon(
              Icons.block_rounded,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
    );
  }

  Future<void> _play(BuildContext context, WidgetRef ref) async {
    // Роутер берём до await: лист перестраивается во время импорта, и к
    // моменту старта к этому элементу уже нельзя обращаться.
    final router = GoRouter.of(context);
    final services = ref.read(appServicesProvider);
    final prefs = ref.read(prefsProvider.notifier);
    final controller = ref.read(playbackControllerProvider);
    final searchLabel = AppLocalizations.of(context).navSearch;
    await prefs.rememberSearch(query);
    final ids = await services.db.tracksDao.ingestAll([
      for (final hit in all) hit.track,
    ]);
    await controller.playQueue(
      ids,
      startIndex: index,
      sourceHint: {
        'kind': 'search',
        'query': hit.track.title,
        'title': searchLabel,
      },
    );
    router.push(Routes.player);
  }
}

class _SearchHistory extends StatelessWidget {
  const _SearchHistory({
    required this.items,
    required this.onPick,
    required this.onClear,
  });

  final List<String> items;
  final ValueChanged<String> onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l.searchHistoryTitle,
                style: theme.textTheme.titleMedium,
              ),
            ),
            TextButton(onPressed: onClear, child: Text(l.searchHistoryClear)),
          ],
        ),
        for (final item in items)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.history_rounded),
            title: Text(item, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: const Icon(Icons.north_west_rounded, size: 18),
            onTap: () => onPick(item),
          ),
      ],
    );
  }
}
