import 'dart:async';
import 'dart:math' as math;

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_providers.dart';
import 'core/links/yandex_playlist_link.dart';
import 'core/prefs/prefs.dart';
import 'core/sources/source_dto.dart';
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

  Future<void> _afterSignIn() async {
    try {
      await ref.read(librarySyncProvider.future);
    } on Object {
      // Без сети синхронизация повторится при следующем запуске.
    }
    if (!mounted) return;
    ref.invalidate(collectionProvider);
    ref.invalidate(playlistsProvider);
    ref.invalidate(topArtistsProvider);
    unawaited(ref.read(playlistSyncProvider.notifier).refresh());
    unawaited(
      ref.read(collectionWarmupProvider.future).catchError((Object _) {}),
    );
    await ref.read(downloadControllerProvider.notifier).kickAutoDownloads();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(ref.read(playlistSyncProvider.notifier).refresh());
      unawaited(_retrySignIn());
    }
  }

  /// Запуск без сети оставлял аккаунт «не вошёл» до перезапуска. При
  /// возврате в приложение пробуем ещё раз и догоняем синхронизацию.
  Future<void> _retrySignIn() async {
    final auth = ref.read(appServicesProvider).yandexAuth;
    if (auth == null || auth.state is! AuthFailed) return;
    await auth.retryIfFailed();
    if (!mounted || auth.state is! AuthReady) return;
    ref.invalidate(librarySyncProvider);
    try {
      await ref.read(librarySyncProvider.future);
    } on Object {
      // Повторим при следующем возврате.
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
    // Первый вход в аккаунт (или повторный после выхода): коллекцию,
    // плейлисты и автозагрузку запускаем сразу, а не после перезапуска.
    ref.listen<bool>(yandexReadyProvider, (previous, ready) {
      if (!ready || previous == true) return;
      unawaited(_afterSignIn());
    });

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
      // Смена акцента и темы — мягкий перелив цветов, без резких скачков.
      themeAnimationDuration: const Duration(milliseconds: 450),
      themeAnimationCurve: Curves.easeInOutCubic,
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
              _AppReveal(
                delayed: prefs.animations != AnimationsSpeed.off,
                // Стеклянные панели делят один снимок подложки: раньше каждая
                // снимала экран отдельно, и GPU не укладывался в кадр на 120 Гц.
                child: BackdropGroup(child: child ?? const SizedBox()),
              ),
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

/// Длина заставки запуска; интерфейс начинает проявляться на её спаде.
const _kSplashMs = 1150;
const _kRevealDelayMs = 640;

/// Вход в интерфейс по M3: из-под уходящей заставки экран мягко поднимается,
/// проявляется и дорастает до полного размера (emphasized decelerate).
class _AppReveal extends StatefulWidget {
  const _AppReveal({required this.child, required this.delayed});

  final Widget child;
  final bool delayed;

  @override
  State<_AppReveal> createState() => _AppRevealState();
}

class _AppRevealState extends State<_AppReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 560),
  );

  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _controller,
    curve: Easing.emphasizedDecelerate,
  );

  Timer? _start;

  @override
  void initState() {
    super.initState();
    if (widget.delayed) {
      _start = Timer(
        const Duration(milliseconds: _kRevealDelayMs),
        _controller.forward,
      );
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _start?.cancel();
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduceMotion) return widget.child;
    return AnimatedBuilder(
      animation: _curve,
      child: widget.child,
      builder: (context, child) {
        final t = _curve.value;
        if (t >= 1) return child!;
        return Opacity(
          opacity: (t * 1.6).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 28 * (1 - t)),
            child: Transform.scale(scale: 0.94 + 0.06 * t, child: child),
          ),
        );
      },
    );
  }
}

/// Заставка запуска в духе M3 Expressive: значок появляется «печеньем»,
/// которое докручивается и разглаживается в круг, затем
/// значок чуть вырастает и растворяется вместе с фоном, открывая интерфейс.
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
    duration: const Duration(milliseconds: _kSplashMs),
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

  static double _seg(double t, double from, double to) =>
      ((t - from) / (to - from)).clamp(0.0, 1.0);

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
        // 0–45%: появление и морф; 45–55%: пауза; 55–100%: уход.
        final enter = Easing.emphasizedDecelerate.transform(_seg(t, 0, 0.45));
        final pop = Curves.easeOutBack.transform(_seg(t, 0, 0.45));
        final leave = Easing.emphasizedAccelerate.transform(_seg(t, 0.55, 1));
        final morph = Curves.easeInOutCubic.transform(_seg(t, 0.05, 0.5));
        final scale = (0.6 + 0.4 * pop) * (1 + 0.18 * leave);
        return IgnorePointer(
          child: Opacity(
            opacity: 1 - leave,
            child: ColoredBox(
              color: scheme.surface,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.rotate(
                      angle: -0.6 * (1 - morph),
                      child: Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: enter,
                          child: ClipPath(
                            clipper: _SplashShapeClipper(morph),
                            child: Image.asset(
                              widget.iconAsset,
                              width: 112,
                              height: 112,
                              cacheWidth: 336,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Opacity(
                      opacity: enter * (1 - leave),
                      child: Transform.translate(
                        offset: Offset(0, 12 * (1 - enter)),
                        child: Text(
                          'mimikoPlayer',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: scheme.onSurfaceVariant,
                                letterSpacing: 0.4,
                              ),
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

/// Морф «печенье → круг»: при [t] = 0 девятилепестковое
/// печенье, при 1 — круг, как сама иконка приложения.
class _SplashShapeClipper extends CustomClipper<Path> {
  const _SplashShapeClipper(this.t);

  final double t;

  @override
  Path getClip(Size size) {
    final c = size.center(Offset.zero);
    final half = size.shortestSide / 2;
    const n = 9;
    const depth = 0.07;
    const corner = 1.0;
    final path = Path();
    const samples = 180;
    for (var i = 0; i <= samples; i++) {
      final a = i / samples * 2 * math.pi;
      final dir = Offset(math.cos(a), math.sin(a));
      final cookie = half * (1 - depth + depth * math.cos(n * a));
      final square = _roundedSquareRadius(a, half, corner * half);
      final r = cookie + (square - cookie) * t;
      final p = c + dir * r;
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }

  /// Расстояние от центра до края скруглённого квадрата по направлению [a].
  static double _roundedSquareRadius(double a, double half, double rc) {
    final dx = math.cos(a).abs();
    final dy = math.sin(a).abs();
    final inner = half - rc;
    // Луч из центра пересекает прямую сторону или дугу угла.
    final tSide = half / math.max(dx, dy);
    final hx = dx * tSide;
    final hy = dy * tSide;
    if (hx <= inner || hy <= inner) return tSide;
    // Пересечение с окружностью угла: |t·d − (inner, inner)| = rc.
    final b = dx * inner + dy * inner;
    final cc = 2 * inner * inner - rc * rc;
    return b + math.sqrt(math.max(0, b * b - cc));
  }

  @override
  bool shouldReclip(_SplashShapeClipper old) => old.t != t;
}
