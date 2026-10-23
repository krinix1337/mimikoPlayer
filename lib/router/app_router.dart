import 'dart:ui' as ui;

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app_providers.dart';
import '../core/db/daos/library_dao.dart';
import '../core/logging/log_screen.dart';
import '../features/catalog/ui/catalog_screens.dart';
import '../features/discover/ui/discover_screen.dart';
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
import '../theme/surface.dart';
import 'routes.dart';

final _rootKey = GlobalKey<NavigatorState>();

/// Вкладки: маршрут и иконка. Подписи локализуются в сборке навигации.
const _tabs = <({String path, IconData icon})>[
  (path: Routes.home, icon: Icons.auto_awesome_rounded),
  (path: Routes.discover, icon: Icons.explore_rounded),
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
          pageBuilder: (context, state) => _tabPage(state, const HomeScreen()),
        ),
        GoRoute(
          path: Routes.discover,
          pageBuilder: (context, state) =>
              _tabPage(state, const DiscoverScreen()),
        ),
        GoRoute(
          path: Routes.library,
          pageBuilder: (context, state) =>
              _tabPage(state, const CollectionScreen()),
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
              path: 'downloaded',
              parentNavigatorKey: _rootKey,
              pageBuilder: (context, state) => _slideUp(
                state,
                const CollectionKindScreen(kind: CollectionKind.downloaded),
              ),
            ),
            GoRoute(
              path: 'playlists',
              parentNavigatorKey: _rootKey,
              pageBuilder: (context, state) =>
                  _slideUp(state, const PlaylistsScreen()),
              routes: [
                GoRoute(
                  path: ':id',
                  parentNavigatorKey: _rootKey,
                  pageBuilder: (context, state) => _slideUp(
                    state,
                    PlaylistScreen(
                      playlistId: Uri.decodeComponent(
                        state.pathParameters['id']!,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: Routes.settings,
          pageBuilder: (context, state) =>
              _tabPage(state, const SettingsScreen()),
        ),
        GoRoute(
          path: Routes.chart,
          pageBuilder: (context, state) => _slideUp(state, const ChartScreen()),
        ),
        GoRoute(
          path: Routes.artist,
          pageBuilder: (context, state) => _slideUp(
            state,
            ArtistScreen(artistId: state.uri.queryParameters['id'] ?? ''),
          ),
        ),
        GoRoute(
          path: Routes.artistTracks,
          pageBuilder: (context, state) => _slideUp(
            state,
            ArtistTracksScreen(artistId: state.uri.queryParameters['id'] ?? ''),
          ),
        ),
        GoRoute(
          path: Routes.artistAlbums,
          pageBuilder: (context, state) => _slideUp(
            state,
            ArtistAlbumsScreen(artistId: state.uri.queryParameters['id'] ?? ''),
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
    // Поиск — поверх вкладок: в Яндексе он тоже открывается отдельным
    // экраном со стрелкой назад, а не живёт пятой вкладкой.
    GoRoute(
      path: Routes.search,
      parentNavigatorKey: _rootKey,
      pageBuilder: (context, state) => _slideUp(state, const SearchScreen()),
    ),
    GoRoute(
      path: Routes.newReleases,
      parentNavigatorKey: _rootKey,
      pageBuilder: (context, state) =>
          _slideUp(state, const NewReleasesScreen()),
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

    final labels = [l.navWave, l.navDiscover, l.navCollection, l.navSettings];
    final prefs = ref.watch(prefsProvider);
    // Компактная панель — то же, что просил владелец: «чуть меньше».
    final compact = prefs.compactUi;
    final withLabels = prefs.showNavLabels;
    final barHeight = withLabels
        ? (compact ? 60.0 : 72.0)
        : (compact ? 52.0 : 60.0);
    // На волне обложка, название и пауза уже на самом экране, поэтому
    // мини-плеер там всегда лишний — независимо от того, откуда играет трек.
    final isHome = location == Routes.home;

    return Scaffold(
      extendBody: isHome,
      backgroundColor: isHome
          ? Colors.transparent
          : Theme.of(context).scaffoldBackgroundColor,
      // Верх не съедаем SafeArea: фон главной должен уходить под статус-бар,
      // а каждая страница сама разбирается со своим отступом сверху.
      body: SafeArea(top: false, bottom: false, child: child),
      // SafeArea снаружи, а внутренний нижний отступ навбара убираем:
      // иначе он добавлял пустоту под подписями и пилюля выглядела
      // «тяжёлой снизу».
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: EdgeInsets.only(bottom: compact ? 6 : 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (prefs.showMiniPlayer) MiniPlayer(hidden: isHome),
            Padding(
              padding: EdgeInsets.fromLTRB(
                compact ? 16 : 12,
                4,
                compact ? 16 : 12,
                0,
              ),
              child: AppSurface(
                radius: currentMotion.prefs.corner.radius,
                color: Theme.of(context).colorScheme.surfaceContainerHigh
                    .withValues(alpha: 0.92),
                shadow: false,
                child: _PillNavBar(
                  height: barHeight,
                  selected: index,
                  showLabels: withLabels,
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

/// Вкладки: короткий fade-through с непрозрачной подложкой. Направленная
/// ось раньше показывала белый кадр, а полный fade без фона — просвет окна.
Page<void> _tabPage(GoRouterState state, Widget child) {
  final duration = currentMotion.micro(220);
  if (duration == Duration.zero) {
    return NoTransitionPage<void>(key: state.pageKey, child: child);
  }
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (context, animation, secondary, page) => ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: FadeThroughTransition(
        animation: animation,
        secondaryAnimation: secondary,
        fillColor: Colors.transparent,
        child: page,
      ),
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
    this.showLabels = true,
  });

  final double height;
  final int selected;
  final ValueChanged<int> onSelected;
  final List<({IconData icon, String label})> destinations;
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final motion = currentMotion;
    final indicatorWidth = 56.0;
    final indicatorHeight = showLabels ? 32.0 : 36.0;
    final contentHeight = indicatorHeight + (showLabels ? 14.0 : 0.0);

    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / destinations.length;
          final left = itemWidth * selected + (itemWidth - indicatorWidth) / 2;
          final top = (height - contentHeight) / 2;

          return Stack(
            children: [
              AnimatedPositioned(
                duration: motion.micro(420),
                curve: Curves.easeOutBack,
                left: left,
                top: top,
                width: indicatorWidth,
                height: indicatorHeight,
                child: const _GlassIndicator(),
              ),
              Positioned.fill(
                child: Row(
                  children: [
                    for (var i = 0; i < destinations.length; i++)
                      Expanded(
                        child: Tooltip(
                          message: destinations[i].label,
                          child: InkWell(
                            onTap: () => onSelected(i),
                            splashFactory: NoSplash.splashFactory,
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            overlayColor: const WidgetStatePropertyAll(
                              Colors.transparent,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: indicatorWidth,
                                  height: indicatorHeight,
                                  child: Center(
                                    child: AnimatedScale(
                                      scale: i == selected ? 1.12 : 1.0,
                                      duration: motion.micro(320),
                                      curve: Curves.easeOutBack,
                                      child: Icon(
                                        destinations[i].icon,
                                        size: showLabels ? 22 : 24,
                                        color: i == selected
                                            ? scheme.primary
                                            : scheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                                if (showLabels) ...[
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
                                          ? scheme.primary
                                          : scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ],
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
    );
  }
}

/// Стеклянная капсула, которая переезжает между вкладками. Тонировка
/// акцентом и блик сверху дают «liquid glass» без тяжёлого блюра на весь
/// экран: размывается только маленький прямоугольник.
class _GlassIndicator extends StatelessWidget {
  const _GlassIndicator();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(18);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.primary.withValues(alpha: 0.30),
                  scheme.primary.withValues(alpha: 0.06),
                ],
              ),
              border: Border.all(color: scheme.primary.withValues(alpha: 0.35)),
            ),
          ),
        ),
      ),
    );
  }
}
