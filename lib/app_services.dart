import 'core/db/database.dart';
import 'core/prefs/prefs_store.dart';
import 'core/sources/registry.dart';
import 'core/sources/stream_resolver.dart';
import 'core/sources/stream_target.dart';
import 'sources/local/local_source.dart';
import 'sources/yandex/yandex_api.dart';
import 'sources/yandex/yandex_auth.dart';
import 'sources/yandex/yandex_source.dart';
import 'sources/youtube/youtube_source.dart';

/// Единая точка сборки зависимостей. Нужна потому, что audio_service после
/// смерти процесса поднимает `main()` headless: состояние приходится
/// восстанавливать из БД, а не из того, что было в UI.
class AppServices {
  AppServices._() {
    db = AppDatabase();
    yandexApi = YandexApi();
    yandexAuth = YandexAuth(db.authDao, yandexApi!);
    yandex = YandexSource(api: yandexApi)..attachAuth(yandexAuth!);
    registry = SourceRegistry([yandex!, LocalSource(), YoutubeSource()]);
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

  /// Фильтр явно помеченных ИИ-треков; нужен и фоновой докачке волны.
  bool hideAiTracks = false;

  static AppServices? _instance;

  static AppServices ensure() => _instance ??= AppServices._();

  Future<void> applyPreferences() async {
    registry.setPlaybackPriority(await db.settingsDao.playbackPriority());
    final prefs = await loadPrefs(db);
    defaultQuality = Quality.fromWire(prefs.quality);
    fadeEnabled = prefs.fade;
    hideAiTracks = prefs.hideAiTracks;
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
