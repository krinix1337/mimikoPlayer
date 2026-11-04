import 'dart:async';

import 'core/db/database.dart';
import 'core/content/ai_filter.dart';
import 'core/content/artist_blocklist.dart';
import 'core/content/censor_base.dart';
import 'core/prefs/prefs_store.dart';
import 'core/sources/registry.dart';
import 'core/sources/stream_resolver.dart';
import 'core/sources/stream_target.dart';
import 'sources/local/local_source.dart';
import 'sources/soundcloud/soundcloud_source.dart';
import 'sources/yandex/yandex_api.dart';
import 'sources/yandex/yandex_auth.dart';
import 'sources/yandex/yandex_source.dart';

/// Единая точка сборки зависимостей. Нужна потому, что audio_service после
/// смерти процесса поднимает `main()` headless: состояние приходится
/// восстанавливать из БД, а не из того, что было в UI.
class AppServices {
  AppServices._() {
    db = AppDatabase();
    yandexApi = YandexApi();
    yandexAuth = YandexAuth(db.authDao, yandexApi!);
    yandex = YandexSource(api: yandexApi)..attachAuth(yandexAuth!);
    registry = SourceRegistry([yandex!, SoundCloudSource(), LocalSource()]);
    resolver = StreamResolver(registry: registry, store: db.streamsDao);
  }

  YandexApi? yandexApi;
  YandexAuth? yandexAuth;
  YandexSource? yandex;

  late final AppDatabase db;
  late final SourceRegistry registry;
  late final StreamResolver resolver;

  /// Качество, выбранное в настройках; applyPreferences перечитывает его
  /// после каждой правки, плеер берёт его изсюда при разборе потока.
  Quality defaultQuality = Quality.auto;

  /// Плавное затухание громкости; читается из настроек вместе с качеством.
  bool fadeEnabled = true;

  /// Длина кроссфейда между треками, секунды. 0 — выключен.
  int crossfadeSeconds = 6;

  /// Учитывать ли прослушивания в статистике (история для волны пишется всегда).
  bool collectStats = true;

  /// Фильтр явно помеченных ИИ-треков; нужен и фоновой докачке волны.
  bool hideAiTracks = false;

  /// Эквалайзер: пресет и включённость читает фоновый плеер, а не UI.
  bool eqEnabled = false;
  String eqPreset = 'flat';
  List<double> eqCustomGains = const [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  double eqCustomLevel = 0;

  /// Плеер подписывается сюда, чтобы применить настройки без Riverpod.
  void Function()? onEqualizerChanged;

  static AppServices? _instance;

  static AppServices ensure() => _instance ??= AppServices._();

  Future<void> applyPreferences() async {
    registry.setPlaybackPriority(await db.settingsDao.playbackPriority());
    final prefs = await loadPrefs(db);
    defaultQuality = Quality.fromWire(prefs.quality);
    fadeEnabled = prefs.fade;
    crossfadeSeconds = prefs.crossfadeSeconds;
    collectStats = prefs.collectStats;
    hideAiTracks = prefs.hideAiTracks;
    eqEnabled = prefs.eqEnabled;
    eqPreset = prefs.eqPreset;
    eqCustomGains = prefs.eqCustomGains;
    eqCustomLevel = prefs.eqCustomLevel;
    onEqualizerChanged?.call();
    CensorBase.instance.enabled = prefs.censorBypass;
    await ArtistBlocklist.instance.load(db);
    if (hideAiTracks) {
      // Список большой и ходит в сеть; грузим после первого кадра.
      unawaited(AiFilter.instance.ensureLoaded());
    }
    if (prefs.censorBypass) {
      // Один раз после обновления сбрасываем старые ссылки: в них мог быть
      // заголовок, из-за которого just_audio шёл через запрещённый локальный
      // HTTP-прокси.
      final marker = await db.settingsDao.value('censor_cache_v2');
      if (marker == null) {
        await db.streamsDao.clearResolutions();
        await db.settingsDao.setValue('censor_cache_v2', '1');
      }
      unawaited(CensorBase.instance.ensureLoaded());
    }
  }

  /// Восстановление аккаунта ходит в сеть, поэтому запускается уже после
  /// первого кадра: на холодном старте этот запрос добавлял секунды к запуску.
  Future<void> restoreAccount() async => yandexAuth?.restore();

  Future<void> dispose() async {
    await registry.dispose();
    await db.close();
    _instance = null;
  }
}
