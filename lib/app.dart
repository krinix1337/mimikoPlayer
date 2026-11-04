import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_providers.dart';
import 'core/links/yandex_playlist_link.dart';
import 'core/prefs/prefs.dart';
import 'core/platform/mimiko_platform.dart';
import 'features/downloads/download_service.dart';
import 'features/player/playback_controller.dart';
import 'l10n/app_localizations.dart';
import 'router/app_router.dart';
import 'router/routes.dart';
import 'theme/app_motion.dart';
import 'theme/blur_settings.dart';
import 'theme/app_theme.dart';
import 'theme/keyboard_theme.dart';
import 'widgets/theme_reveal.dart';

class MimikoApp extends ConsumerStatefulWidget {
  const MimikoApp({super.key});

  @override
  ConsumerState<MimikoApp> createState() => _MimikoAppState();
}

class _MimikoAppState extends ConsumerState<MimikoApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Ссылка, которой поделились: холодный старт забираем один раз, горячий
    // приходит колбэком из уже открытой активности.
    MimikoPlatform.onSharedLink(_openSharedLink);
    unawaited(
      MimikoPlatform.takeInitialSharedLink().then((text) {
        if (text != null) _openSharedLink(text);
      }),
    );
    // Окно ещё не создано во время main(), поэтому частоту просим после
    // первого кадра. Выбор из настроек убран: всегда просим максимум, а
    // HyperOS на бюджетных устройствах всё равно вправе оставить 60.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MimikoPlatform.requestFrameRate(120);
      // Коллекцию догоняем через паузу: сразу после кадра сеть и запись в
      // базу конкурируют с анимацией входа и дают просадку.
      Future<void>.delayed(const Duration(seconds: 3), () async {
        // Обложки для коллекции кладём в дисковый кэш заранее: при открытии
        // вкладки не должно быть серых квадратов и второй прогрузки.
        unawaited(
          ref.read(collectionWarmupProvider.future).catchError((Object _) {}),
        );
        try {
          await ref.read(librarySyncProvider.future);
        } on Object {
          // Без сети автозагрузка всё равно может продолжить локальную очередь.
        }
        if (!mounted) return;
        // Обложки у треков, скачанных до локальных картинок: подтягиваем фоном,
        // чтобы «Скачанное» не пустело офлайн.
        unawaited(
          ref
              .read(downloadControllerProvider.notifier)
              .backfillCovers()
              .catchError((Object _) => 0),
        );
        unawaited(reimportPlaylistsOnce(ref));
        final downloads = ref.read(downloadControllerProvider.notifier);
        await downloads.recoverQueue();
        await downloads.kickAutoDownloads();
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(ref.read(playlistSyncProvider.notifier).refresh());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _openSharedLink(String text) {
    final link = YandexPlaylistLink.tryParse(text);
    if (link == null) return;
    final location = Routes.playlist('yandex:${link.remotePlaylistId}');
    // На холодном старте роутер ещё не смонтирован в дерево.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      appRouterProvider.push(location);
    });
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(prefsProvider);
    // Роутер строит анимации вне дерева виджетов — ему нужен текущий Motion.
    currentMotion = Motion(prefs: prefs);
    currentBlur = BlurSettings.fromPrefs(prefs);
    // Прогрев обзора: подписка нужна, чтобы провайдер перезапустился, когда
    // восстановится аккаунт. Без неё новинки грузятся только при открытии.
    ref.watch(discoverWarmupProvider);

    if (!kKeyboardTestTheme && prefs.palette != AppPalette.dynamic) {
      return _app(prefs, null, null);
    }

    // Material You: палитру системы можно прочитать только виджетом,
    // поэтому оборачиваем всё приложение. В тестовой теме dynamic нужен
    // всегда, даже если в настройках выбран брендовый акцент.
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) =>
          _app(prefs, lightDynamic, darkDynamic),
    );
  }

  Widget _app(
    Prefs prefs,
    ColorScheme? lightDynamic,
    ColorScheme? darkDynamic,
  ) => MotionScope(
    motion: Motion(prefs: prefs),
    child: MaterialApp.router(
      title: 'mimikoPlayer',
      debugShowCheckedModeBanner: false,
      locale: prefs.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: appRouterProvider,
      // Мягкое появление интерфейса на старте: окно уже показано, а контент
      // подъезжает за полсекунды — вход не выглядит «щелчком».
      builder: (context, child) {
        final dark = Theme.of(context).brightness == Brightness.dark;
        final style = SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
          statusBarBrightness: dark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: dark
              ? Brightness.light
              : Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
          systemStatusBarContrastEnforced: false,
          systemNavigationBarContrastEnforced: false,
        );
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: style,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ThemeReveal(child: _AppReveal(child: child ?? const SizedBox())),
              _LaunchSplash(
                enabled: prefs.animations != AnimationsSpeed.off,
                iconAsset: prefs.launcherIcon.asset,
              ),
            ],
          ),
        );
      },
      themeMode: prefs.themeMode,
      theme: kKeyboardTestTheme
          ? KeyboardTheme.build(Brightness.light, prefs, lightDynamic)
          : AppTheme.build(
              Brightness.light,
              prefs,
              platformScheme: lightDynamic,
            ),
      darkTheme: kKeyboardTestTheme
          ? KeyboardTheme.build(Brightness.dark, prefs, darkDynamic)
          : AppTheme.build(Brightness.dark, prefs, platformScheme: darkDynamic),
    ),
  );
}

/// Контейнер зависимостей. Плеер сюда приходит тем же объектом, который
/// создал AudioService.init, — включая headless-запуск после media-кнопки.
class AppRoot extends StatelessWidget {
  const AppRoot({super.key, required this.controller});

  final PlaybackController controller;

  @override
  Widget build(BuildContext context) => ProviderScope(
    overrides: [playbackControllerProvider.overrideWithValue(controller)],
    child: const MimikoApp(),
  );
}

class _AppReveal extends StatefulWidget {
  const _AppReveal({required this.child});

  final Widget child;

  @override
  State<_AppReveal> createState() => _AppRevealState();
}

class _AppRevealState extends State<_AppReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 460),
  )..forward();

  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduceMotion) return widget.child;
    return FadeTransition(
      opacity: _curve,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.985, end: 1).animate(_curve),
        child: widget.child,
      ),
    );
  }
}

/// Анимация запуска: на тёмном экране проявляется значок, держится и
/// растворяется, открывая уже готовый интерфейс. Один раз за запуск.
class _LaunchSplash extends StatefulWidget {
  const _LaunchSplash({required this.enabled, required this.iconAsset});

  final bool enabled;
  final String iconAsset;

  @override
  State<_LaunchSplash> createState() => _LaunchSplashState();
}

class _LaunchSplashState extends State<_LaunchSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 950),
  )..forward();

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || _controller.isCompleted) {
      return const SizedBox.shrink();
    }
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final appear = Curves.easeOutCubic.transform(
          (t / 0.38).clamp(0.0, 1.0),
        );
        final fade = t < 0.62
            ? 1.0
            : 1.0 -
                  Curves.easeInCubic.transform(
                    ((t - 0.62) / 0.38).clamp(0.0, 1.0),
                  );
        final scale =
            0.84 +
            0.16 * Curves.easeOutBack.transform((t / 0.45).clamp(0.0, 1.0));
        return IgnorePointer(
          child: Opacity(
            opacity: fade,
            child: ColoredBox(
              color: scheme.surface,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: appear,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: scheme.primary.withValues(alpha: 0.22),
                                blurRadius: 38,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(26),
                            child: Image.asset(
                              widget.iconAsset,
                              width: 104,
                              height: 104,
                              cacheWidth: 312,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Opacity(
                      opacity: appear,
                      child: Text(
                        'mimikoPlayer',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: scheme.onSurfaceVariant,
                              letterSpacing: 0.4,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
