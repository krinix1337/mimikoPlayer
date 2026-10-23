import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_providers.dart';
import 'core/prefs/prefs.dart';
import 'core/platform/mimiko_platform.dart';
import 'features/downloads/download_service.dart';
import 'features/player/playback_controller.dart';
import 'l10n/app_localizations.dart';
import 'router/app_router.dart';
import 'theme/app_motion.dart';
import 'theme/app_theme.dart';

class MimikoApp extends ConsumerStatefulWidget {
  const MimikoApp({super.key});

  @override
  ConsumerState<MimikoApp> createState() => _MimikoAppState();
}

class _MimikoAppState extends ConsumerState<MimikoApp> {
  @override
  void initState() {
    super.initState();
    // Окно ещё не создано во время main(), поэтому частоту просим после
    // первого кадра — дальше её меняет только экран настроек.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MimikoPlatform.requestFrameRate(ref.read(prefsProvider).frameHz);
      // Коллекцию догоняем через паузу: сразу после кадра сеть и запись в
      // базу конкурируют с анимацией входа и дают просадку.
      Future<void>.delayed(const Duration(seconds: 3), () async {
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
  Widget build(BuildContext context) {
    final prefs = ref.watch(prefsProvider);
    // Роутер строит анимации вне дерева виджетов — ему нужен текущий Motion.
    currentMotion = Motion(prefs: prefs);

    if (prefs.palette != AppPalette.dynamic) {
      return _app(prefs, null, null);
    }

    // Material You: палитру системы можно прочитать только виджетом,
    // поэтому оборачиваем всё приложение.
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
            children: [_AppReveal(child: child ?? const SizedBox())],
          ),
        );
      },
      themeMode: prefs.themeMode,
      theme: AppTheme.build(
        Brightness.light,
        prefs,
        platformScheme: lightDynamic,
      ),
      darkTheme: AppTheme.build(
        Brightness.dark,
        prefs,
        platformScheme: darkDynamic,
      ),
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
