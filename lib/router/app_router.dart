import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app_providers.dart';
import '../core/db/daos/library_dao.dart';
import '../core/logging/log_screen.dart';
import '../features/catalog/ui/catalog_screens.dart';
import '../features/home/ui/home_screen.dart';
import '../features/karaoke/ui/karaoke_screen.dart';
import '../features/library/ui/collection_detail.dart';
import '../features/library/ui/collection_screen.dart';
import '../features/player/ui/mini_player.dart';
import '../features/player/ui/player_screen.dart';
import '../features/search/ui/search_screen.dart';
import '../features/settings/ui/settings_screen.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_motion.dart';
import 'routes.dart';

final _rootKey = GlobalKey<NavigatorState>();

/// Вкладки: маршрут и иконка. Подписи локализуются в сборке навигации.
const _tabs = <({String path, IconData icon})>[
  (path: Routes.home, icon: Icons.auto_awesome_rounded),
  (path: Routes.search, icon: Icons.search_rounded),
  (path: Routes.library, icon: Icons.library_music_rounded),
  (path: Routes.settings, icon: Icons.tune_rounded),
];

/// Индекс последней вкладки: на `/player` и в разделах коллекции подсветка
/// навигации должна оставаться там, откуда пользователь пришёл.
class ShellTabController extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) => state = index;
}

final shellTabProvider = NotifierProvider<ShellTabController, int>(
  ShellTabController.new,
);

final appRouterProvider = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: Routes.home,
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: Routes.home,
          pageBuilder: (context, state) => _sharedAxis(state, const HomeScreen()),
        ),
        GoRoute(
          path: Routes.search,
          pageBuilder: (context, state) => _sharedAxis(state, const SearchScreen()),
        ),
        GoRoute(
          path: Routes.library,
          pageBuilder: (context, state) => _sharedAxis(state, const CollectionScreen()),
          routes: [
            GoRoute(
              path: 'liked',
              parentNavigatorKey: _rootKey,
              pageBuilder: (context, state) => _slideUp(
                state,
                const CollectionKindScreen(kind: CollectionKind.liked),
              ),
            ),
            GoRoute(
              path: 'disliked',
              parentNavigatorKey: _rootKey,
              pageBuilder: (context, state) => _slideUp(
                state,
                const CollectionKindScreen(kind: CollectionKind.disliked),
              ),
            ),
            GoRoute(
              path: 'files',
              parentNavigatorKey: _rootKey,
              pageBuilder: (context, state) => _slideUp(
                state,
                const CollectionKindScreen(kind: CollectionKind.files),
              ),
            ),
            GoRoute(
              path: 'recent',
              parentNavigatorKey: _rootKey,
              pageBuilder: (context, state) => _slideUp(
                state,
                const CollectionKindScreen(kind: CollectionKind.recent),
              ),
            ),
            GoRoute(
              path: 'playlists',
              parentNavigatorKey: _rootKey,
              pageBuilder: (context, state) => _slideUp(state, const PlaylistsScreen()),
              routes: [
                GoRoute(
                  path: ':id',
                  parentNavigatorKey: _rootKey,
                  pageBuilder: (context, state) => _slideUp(
                    state,
                    PlaylistScreen(
                      playlistId: Uri.decodeComponent(state.pathParameters['id']!),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: Routes.settings,
          pageBuilder: (context, state) => _sharedAxis(state, const SettingsScreen()),
        ),
        GoRoute(
          path: Routes.chart,
          pageBuilder: (context, state) =>
              _slideUp(state, const ChartScreen()),
        ),
        GoRoute(
          path: Routes.artist,
          pageBuilder: (context, state) => _slideUp(
            state,
            ArtistScreen(
              artistId: state.uri.queryParameters['id'] ?? '',
            ),
          ),
        ),
        GoRoute(
          path: Routes.album,
          pageBuilder: (context, state) => _slideUp(
            state,
            AlbumScreen(albumId: state.uri.queryParameters['id'] ?? ''),
          ),
        ),
      ],
    ),
    // Плеер и караоке — корневые маршруты, открываются через push():
    // оболочка остаётся внизу стека, поэтому панель исчезает, а свайп
    // «назад» возвращает к списку, а не закрывает приложение.
    GoRoute(
      path: Routes.player,
      parentNavigatorKey: _rootKey,
      pageBuilder: (context, state) => _slideUp(state, const PlayerScreen()),
    ),
    GoRoute(
      path: Routes.karaoke,
      parentNavigatorKey: _rootKey,
      pageBuilder: (context, state) => _slideUp(
        state,
        KaraokeScreen(trackId: state.uri.queryParameters['track'] ?? ''),
      ),
    ),
    GoRoute(
      path: Routes.logs,
      parentNavigatorKey: _rootKey,
      builder: (context, state) => const LogScreen(),
    ),
  ],
);

/// Нижняя навигация + всегда видимый мини-плеер над ней.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final location = GoRouterState.of(context).matchedLocation;
    final matched = _tabs.indexWhere(
      (t) => t.path != Routes.home && location.startsWith(t.path),
    );
    final index = matched >= 0
        ? matched
        : location == Routes.home
        ? 0
        : ref.watch(shellTabProvider);

    final labels = [l.navWave, l.navSearch, l.navCollection, l.navSettings];
    final prefs = ref.watch(prefsProvider);
    // Компактная панель — то же, что просил владелец: «чуть меньше».
    final compact = prefs.compactUi;

    return Scaffold(
      body: SafeArea(bottom: false, child: child),
      // SafeArea снаружи, а внутренний нижний отступ навбара убираем:
      // иначе он добавлял пустоту под подписями и пилюля выглядела
      // «тяжёлой снизу».
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: EdgeInsets.only(bottom: compact ? 6 : 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (prefs.showMiniPlayer) const MiniPlayer(),
            Padding(
              padding: EdgeInsets.fromLTRB(
                compact ? 16 : 12,
                4,
                compact ? 16 : 12,
                0,
              ),
              child: Material(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(
                  currentMotion.prefs.corner.radius,
                ),
                clipBehavior: Clip.antiAlias,
                child: _PillNavBar(
                  height: compact ? 60 : 72,
                  selected: index,
                  onSelected: (i) {
                    ref.read(shellTabProvider.notifier).select(i);
                    context.go(_tabs[i].path);
                  },
                  destinations: [
                    for (var i = 0; i < _tabs.length; i++)
                      (icon: _tabs[i].icon, label: labels[i]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Переход между вкладками — общая ось по горизонтали: движение из M3
/// Expressive вместо дефолтного fade.
CustomTransitionPage<void> _sharedAxis(GoRouterState state, Widget child) {
  // Длительности берёт из того же Motion, что и виджеты: настройка
  // «Анимации» выключает и навигацию.
  final motion = currentMotion;
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: motion.sharedAxis,
    reverseTransitionDuration: motion.exit,
    transitionsBuilder: (context, animation, secondary, child) => SharedAxisTransition(
      animation: animation,
      secondaryAnimation: secondary,
      transitionType: SharedAxisTransitionType.horizontal,
      child: child,
    ),
  );
}

/// Полноэкранные страницы (плеер, разделы) выезжают снизу с пружиной.
CustomTransitionPage<void> _slideUp(GoRouterState state, Widget child) {
  final motion = currentMotion;
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: motion.morph,
    reverseTransitionDuration: motion.exit,
    transitionsBuilder: (context, animation, secondary, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Панель навигации с точной геометрией: индикатор 56×32 по центру, подпись
/// под ним. Стандартный NavigationBar на компактной высоте прижимал контент
/// вниз и оставлял пустоту сверху.
class _PillNavBar extends StatelessWidget {
  const _PillNavBar({
    required this.height,
    required this.selected,
    required this.onSelected,
    required this.destinations,
  });

  final double height;
  final int selected;
  final ValueChanged<int> onSelected;
  final List<({IconData icon, String label})> destinations;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final motion = currentMotion;

    return SizedBox(
      height: height,
      child: Row(
        children: [
          for (var i = 0; i < destinations.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => onSelected(i),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: motion.micro(220),
                      curve: Curves.easeOutCubic,
                      width: 56,
                      height: 32,
                      decoration: BoxDecoration(
                        color: i == selected
                            ? scheme.primaryContainer
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        destinations[i].icon,
                        size: 22,
                        color: i == selected
                            ? scheme.onPrimaryContainer
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      destinations[i].label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.1,
                        fontWeight: i == selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: i == selected
                            ? scheme.onSurface
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
