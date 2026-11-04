import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app_providers.dart';
import '../core/db/daos/library_dao.dart';
import '../core/links/yandex_playlist_link.dart';
import '../core/logging/log_screen.dart';
import '../core/prefs/prefs.dart';
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
import '../theme/blur_settings.dart';
import '../theme/keyboard_theme.dart';
import '../theme/scroll_activity.dart';
import '../theme/surface.dart';
import 'routes.dart';
import 'slide_up_route.dart';

final _rootKey = GlobalKey<NavigatorState>();

/// Вложенный навигатор оболочки: на нём лежат страницы настроек.
final _shellKey = GlobalKey<NavigatorState>();

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
  // Внешняя ссылка music.yandex.* приходит как platform default location
  // (или route information при горячем старте). Переводим её в наш маршрут
  // плейлиста; остальные внешние адреса не показываем как ошибку.
  redirect: (context, state) {
    final link =
        YandexPlaylistLink.fromUri(state.uri) ??
        YandexPlaylistLink.tryParse(state.uri.toString());
    if (link != null) {
      return Routes.playlist('yandex:${link.remotePlaylistId}');
    }
    return state.uri.hasScheme ? Routes.home : null;
  },
  routes: [
    ShellRoute(
      navigatorKey: _shellKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: Routes.home,
          pageBuilder: (context, state) =>
              slideUpPage(state, const HomeScreen()),
        ),
        GoRoute(
          path: Routes.discover,
          pageBuilder: (context, state) =>
              slideUpPage(state, const DiscoverScreen()),
        ),
        GoRoute(
          path: Routes.library,
          pageBuilder: (context, state) =>
              slideUpPage(state, const CollectionScreen()),
          routes: [
            GoRoute(
              path: 'liked',
              parentNavigatorKey: _rootKey,
              pageBuilder: (context, state) => slideUpPage(
                state,
                const CollectionKindScreen(kind: CollectionKind.liked),
              ),
            ),
            GoRoute(
              path: 'disliked',
              parentNavigatorKey: _rootKey,
              pageBuilder: (context, state) => slideUpPage(
                state,
                const CollectionKindScreen(kind: CollectionKind.disliked),
              ),
            ),
            GoRoute(
              path: 'files',
              parentNavigatorKey: _rootKey,
              pageBuilder: (context, state) => slideUpPage(
                state,
                const CollectionKindScreen(kind: CollectionKind.files),
              ),
            ),
            GoRoute(
              path: 'recent',
              parentNavigatorKey: _rootKey,
              pageBuilder: (context, state) => slideUpPage(
                state,
                const CollectionKindScreen(kind: CollectionKind.recent),
              ),
            ),
            GoRoute(
              path: 'downloaded',
              parentNavigatorKey: _rootKey,
              pageBuilder: (context, state) => slideUpPage(
                state,
                const CollectionKindScreen(kind: CollectionKind.downloaded),
              ),
            ),
            GoRoute(
              path: 'playlists',
              parentNavigatorKey: _rootKey,
              pageBuilder: (context, state) =>
                  slideUpPage(state, const PlaylistsScreen()),
              routes: [
                GoRoute(
                  path: ':id',
                  parentNavigatorKey: _rootKey,
                  pageBuilder: (context, state) => slideUpPage(
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
              slideUpPage(state, const SettingsScreen()),
        ),
        GoRoute(
          path: Routes.chart,
          pageBuilder: (context, state) =>
              slideUpPage(state, const ChartScreen()),
        ),
        GoRoute(
          path: Routes.artist,
          pageBuilder: (context, state) => slideUpPage(
            state,
            ArtistScreen(artistId: state.uri.queryParameters['id'] ?? ''),
          ),
        ),
        GoRoute(
          path: Routes.artistTracks,
          pageBuilder: (context, state) => slideUpPage(
            state,
            ArtistTracksScreen(artistId: state.uri.queryParameters['id'] ?? ''),
          ),
        ),
        GoRoute(
          path: Routes.artistAlbums,
          pageBuilder: (context, state) => slideUpPage(
            state,
            ArtistAlbumsScreen(artistId: state.uri.queryParameters['id'] ?? ''),
          ),
        ),
        GoRoute(
          path: Routes.album,
          pageBuilder: (context, state) => slideUpPage(
            state,
            AlbumScreen(albumId: state.uri.queryParameters['id'] ?? ''),
          ),
        ),
        // Поиск и новинки — внутри оболочки: исполнитель или альбом,
        // открытые отсюда, ложатся в тот же стек, и «назад» возвращает
        // к поиску. Поверх вкладок стрелка на карточке не срабатывала.
        GoRoute(
          path: Routes.search,
          pageBuilder: (context, state) =>
              slideUpPage(state, const SearchScreen()),
        ),
        GoRoute(
          path: Routes.newReleases,
          pageBuilder: (context, state) =>
              slideUpPage(state, const NewReleasesScreen()),
        ),
      ],
    ),
    // Плеер и караоке — корневые маршруты, открываются через push():
    // оболочка остаётся внизу стека, поэтому панель исчезает, а свайп
    // «назад» возвращает к списку, а не закрывает приложение.
    GoRoute(
      path: Routes.player,
      parentNavigatorKey: _rootKey,
      pageBuilder: (context, state) =>
          playerSheetPage(state, const PlayerScreen()),
    ),
    GoRoute(
      path: Routes.karaoke,
      parentNavigatorKey: _rootKey,
      pageBuilder: (context, state) => slideUpPage(
        state,
        KaraokeScreen(trackId: state.uri.queryParameters['track'] ?? ''),
      ),
    ),
    GoRoute(
      path: Routes.logs,
      parentNavigatorKey: _rootKey,
      pageBuilder: (context, state) => slideUpPage(state, const LogScreen()),
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
    // Состояние самой оболочки после push() остаётся первым экраном стека:
    // открытый поверх волны альбом считался главной, и мини-плеер прятался.
    // Берём верхний маршрут роутера.
    // GoRouterState.of — только чтобы оболочка пересобиралась на переходах.
    GoRouterState.of(context);
    final location = GoRouter.of(context).state.matchedLocation;
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

    // Жест «назад» всегда обрабатывает Flutter, а не система: без этого на
    // Android 16 свайп на вложенной странице (импорт, обновления) мог закрыть
    // всё приложение. Есть что закрыть внутри оболочки — закрываем, иначе выход.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final nested = _shellKey.currentState;
        if (nested != null && nested.canPop()) {
          nested.pop();
        } else {
          SystemNavigator.pop();
        }
      },
      child: _shell(
        context,
        ref,
        l,
        prefs,
        compact,
        withLabels,
        barHeight,
        isHome,
        index,
        labels,
      ),
    );
  }

  Widget _shell(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l,
    Prefs prefs,
    bool compact,
    bool withLabels,
    double barHeight,
    bool isHome,
    int index,
    List<String> labels,
  ) {
    return Scaffold(
      // На волне фон должен уходить под плавающую навигацию. На остальных
      // вкладках тело заканчивается ровно у мини-плеера (или панели, если
      // плеера нет) — без пустого хвоста под списком.
      extendBody: true,
      backgroundColor: isHome
          ? Colors.transparent
          : Theme.of(context).scaffoldBackgroundColor,
      // Верх не съедаем SafeArea: фон главной должен уходить под статус-бар,
      // а каждая страница сама разбирается со своим отступом сверху.
      body: SafeArea(
        top: false,
        bottom: false,
        child: ScrollActivityTracker(child: child),
      ),
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
                radius: kKeyboardTestTheme
                    ? 28
                    : currentMotion.prefs.corner.radius,
                color: kKeyboardTestTheme
                    ? Theme.of(context).colorScheme.surfaceContainerHigh
                    : Theme.of(context).colorScheme.surfaceContainerHigh
                          .withValues(
                            alpha: currentBlur.hasBottom ? 0.66 : 0.96,
                          ),
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
    final selectedIconColor = kKeyboardTestTheme
        ? scheme.onSecondaryContainer
        : scheme.primary;
    final selectedLabelColor = kKeyboardTestTheme
        ? scheme.onSurface
        : scheme.primary;

    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / destinations.length;
          final top = (height - contentHeight) / 2;

          return Stack(
            children: [
              // Индикатор едет пружиной и по дороге вытягивается каплей —
              // движение M3 Expressive вместо простого сдвига.
              TweenAnimationBuilder<double>(
                tween: Tween(end: selected.toDouble()),
                duration: motion.micro(520),
                curve: Curves.elasticOut,
                builder: (context, pos, child) {
                  final travel = (pos - pos.roundToDouble()).abs();
                  final stretch = (travel * itemWidth * 0.9).clamp(
                    0.0,
                    itemWidth * 0.6,
                  );
                  final width = indicatorWidth + stretch;
                  return Positioned(
                    left: itemWidth * pos + (itemWidth - width) / 2,
                    top: top,
                    width: width,
                    height: indicatorHeight,
                    child: child!,
                  );
                },
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
                                            ? selectedIconColor
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
                                          ? selectedLabelColor
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
    final radius = BorderRadius.circular(kKeyboardTestTheme ? 16 : 18);
    if (kKeyboardTestTheme) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.secondaryContainer,
          borderRadius: radius,
        ),
      );
    }
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
      // Без своего BackdropFilter: панель навигации уже размывает подложку,
      // а отдельный фильтр на индикаторе 56×32 только тратил GPU.
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
    );
  }
}
