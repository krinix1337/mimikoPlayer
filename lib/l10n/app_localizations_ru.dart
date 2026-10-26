// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'mimikoPlayer';

  @override
  String get navWave => 'Волна';

  @override
  String get navSearch => 'Поиск';

  @override
  String get navCollection => 'Коллекция';

  @override
  String get navSettings => 'Настройки';

  @override
  String get commonPlay => 'Играть';

  @override
  String get commonPause => 'Пауза';

  @override
  String get commonNext => 'Следующий';

  @override
  String get commonPrevious => 'Предыдущий';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonRetry => 'Повторить';

  @override
  String get commonTracks => 'треков';

  @override
  String get commonLoading => 'Загружается…';

  @override
  String get commonLike => 'В любимое';

  @override
  String get commonUnlike => 'Убрать из любимого';

  @override
  String get commonDislike => 'Нелюбимое';

  @override
  String get waveTitle => 'Моя волна';

  @override
  String get waveTune => 'Настроить волну';

  @override
  String get waveStart => 'Запустить волну';

  @override
  String get waveSaved => 'Настройки волны сохранены';

  @override
  String get waveSaveFailed => 'Яндекс не принял настройки волны';

  @override
  String get waveNeedsLogin => 'Войдите в Яндекс, чтобы включить волну';

  @override
  String get waveSignIn => 'Войти в Яндекс';

  @override
  String waveSignedInAs(String account) {
    return 'Аккаунт: $account';
  }

  @override
  String get waveQueueFailed => 'Волна не отдала треки';

  @override
  String get waveStationMore => 'Ещё волны';

  @override
  String get waveNotStarted => 'Волна не запущена';

  @override
  String get sourceLibrary => 'Моя коллекция';

  @override
  String get sourcePlaylist => 'Плейлист';

  @override
  String get sourceSearch => 'Поиск';

  @override
  String get sourceChart => 'Чарт';

  @override
  String get sourceAlbum => 'Альбом';

  @override
  String get sourceArtist => 'Артист';

  @override
  String waveStationsFailed(String error) {
    return 'Станции не загрузились: $error';
  }

  @override
  String get waveLikeAdded => 'Добавлено в любимое';

  @override
  String get waveLikeRemoved => 'Убрано из любимого';

  @override
  String get feedbackDislike => 'Не нравится';

  @override
  String get feedbackUndislike => 'Убрать из «Нелюбимого»';

  @override
  String get feedbackDislikeAdded => 'Добавлено в «Нелюбимое»';

  @override
  String get feedbackCleared => 'Отметка снята';

  @override
  String get feedbackLocalOnly => 'только на устройстве';

  @override
  String get playlistCreate => 'Новый плейлист';

  @override
  String get playlistName => 'Название';

  @override
  String get playlistNameHint => 'Например, для дороги';

  @override
  String get playlistVisibility => 'Кто увидит';

  @override
  String get playlistPublic => 'Все';

  @override
  String get playlistPrivate => 'Только я';

  @override
  String get playlistCreateAction => 'Создать плейлист';

  @override
  String playlistCreated(String title) {
    return 'Плейлист «$title» создан';
  }

  @override
  String get playlistCreateFailed => 'Не удалось создать плейлист';

  @override
  String get importTitle => 'Импорт';

  @override
  String get importTileSubtitle => 'Списки треков и другие площадки';

  @override
  String get importHeroTitle => 'Перенос музыки';

  @override
  String get importHeroNote =>
      'Вставьте список «Исполнитель - Название» — треки найдутся в Яндексе и сохранятся в локальный плейлист.';

  @override
  String get importHeroStatus => 'Доступен импорт из списка';

  @override
  String importMatched(int matched, int skipped) {
    return '$matched найдено, $skipped пропущено';
  }

  @override
  String importDone(int matched, int skipped, int playlists) {
    return 'Готово: $matched треков, $skipped пропущено, $playlists плейлистов';
  }

  @override
  String get importYandexRequired => 'Сначала войдите в Яндекс Музыку';

  @override
  String get importFailed => 'Импорт прервался';

  @override
  String get importOther => 'Другие площадки';

  @override
  String get importList => 'Импорт из списка';

  @override
  String get importListTitle => 'Название плейлиста';

  @override
  String get importListLines => 'Треки';

  @override
  String get importListHint => 'Исполнитель - Название\nИсполнитель - Название';

  @override
  String get importListFormat =>
      'Одна строка — один трек, формат «Исполнитель - Название». Первые 300 строк.';

  @override
  String get importListAction => 'Перенести в плейлист';

  @override
  String get importListEmpty => 'Вставьте хотя бы одну строку';

  @override
  String get importOtherYandex => 'Плейлист по ссылке откроется в приложении';

  @override
  String get importOtherSoundCloud => 'Поиск и поток без переноса';

  @override
  String get waveSettingsTitle => 'Настройки волны';

  @override
  String get waveClose => 'Закрыть';

  @override
  String get waveSoundCloudTitle => 'SoundCloud в волне';

  @override
  String get waveSoundCloudNote =>
      'Подмешивать треки из SoundCloud к рекомендациям. Работает без входа.';

  @override
  String get waveRejectedNote => 'Яндекс не принял настройки — смотри лог';

  @override
  String get collectionTitle => 'Коллекция';

  @override
  String get collectionLiked => 'Любимое';

  @override
  String get collectionDisliked => 'Нелюбимое';

  @override
  String get collectionPlaylists => 'Плейлисты';

  @override
  String get collectionFiles => 'Файлы';

  @override
  String get collectionRecent => 'Недавние';

  @override
  String get collectionDownloaded => 'Скачанное';

  @override
  String get collectionEmptyDownloaded =>
      'Скачанных треков нет.\nСкачайте трек из меню или с экрана плеера — он заиграет без сети.';

  @override
  String get collectionArtists => 'Артисты';

  @override
  String get albumsTitle => 'Альбомы';

  @override
  String get chartTitle => 'Чарт';

  @override
  String get chartSubtitle => 'Популярное в России прямо сейчас';

  @override
  String get artistOpen => 'К исполнителю';

  @override
  String get artistAllTracks => 'Все треки';

  @override
  String get artistPopularTracks => 'Популярные треки';

  @override
  String get artistAllAlbums => 'Все альбомы';

  @override
  String get artistPhoto => 'Фото артиста';

  @override
  String get trackDownloaded => 'Скачано';

  @override
  String get albumOpen => 'К альбому';

  @override
  String get trackMenu => 'Меню трека';

  @override
  String get menuLike => 'Нравится';

  @override
  String get menuDislike => 'Не нравится';

  @override
  String get menuKaraoke => 'Караоке';

  @override
  String get menuPlayNext => 'Играть следующим';

  @override
  String get menuAddQueue => 'В очередь';

  @override
  String get menuDetails => 'Сведения о треке';

  @override
  String get chartOpen => 'Чарт Яндекса';

  @override
  String get collectionAlsoIn => 'Ещё в коллекции';

  @override
  String listenedMinutes(int count) {
    return '$count мин';
  }

  @override
  String listenedHours(int count) {
    return '$count ч';
  }

  @override
  String artistPlays(int count) {
    return 'прослушиваний: $count';
  }

  @override
  String collectionCount(int count) {
    return 'Всего: $count';
  }

  @override
  String get collectionSort => 'Сортировка';

  @override
  String get collectionDownloadAllLikes => 'Скачать все треки';

  @override
  String get collectionShare => 'Поделиться';

  @override
  String get playlistNotFound =>
      'Не удалось открыть плейлист. Проверьте ссылку.';

  @override
  String get menuAddToPlaylist => 'Добавить в плейлист';

  @override
  String addToPlaylistDone(String title) {
    return 'Добавлено в «$title»';
  }

  @override
  String get addToPlaylistFailed => 'Не удалось добавить трек в плейлист';

  @override
  String get addToPlaylistEmpty => 'Своих плейлистов пока нет';

  @override
  String collectionDownloadQueued(int count) {
    return 'В очереди на загрузку: $count';
  }

  @override
  String get sortAdded => 'Недавно добавленные';

  @override
  String get sortTitle => 'По названию';

  @override
  String get sortArtist => 'По исполнителю';

  @override
  String get sortDuration => 'По длительности';

  @override
  String get collectionEmptyLiked =>
      'Любимого пока нет.\nСтавьте сердечко в волне или в списке треков.';

  @override
  String get collectionEmptyDisliked => 'Нелюбимых треков нет.';

  @override
  String get collectionEmptyPlaylists =>
      'Плейлистов ещё нет — заберите их из Яндекса.';

  @override
  String get collectionEmptyFiles => 'В папке Music нет аудиофайлов.';

  @override
  String get collectionEmptyRecent => 'История прослушивания пуста.';

  @override
  String get collectionImportLikes => 'Подтянуть лайки из Яндекса';

  @override
  String get collectionImportPlaylists => 'Импортировать плейлисты из Яндекса';

  @override
  String collectionImportedLikes(int count) {
    return 'Лайков в коллекции: $count';
  }

  @override
  String collectionImportedPlaylists(int count) {
    return 'Плейлистов сохранено: $count';
  }

  @override
  String collectionImportFailed(String error) {
    return 'Яндекс не отдал коллекцию: $error';
  }

  @override
  String get collectionPlayAll => 'Играть всё';

  @override
  String get collectionShuffleAll => 'Перемешать';

  @override
  String get collectionLocalTag => 'Локальный файл';

  @override
  String get agoNow => 'только что';

  @override
  String agoMinutes(int count) {
    return '$count мин назад';
  }

  @override
  String agoHours(int count) {
    return '$count ч назад';
  }

  @override
  String agoDays(int count) {
    return '$count дн назад';
  }

  @override
  String get playerTitle => 'Сейчас играет';

  @override
  String get playerBack => 'Назад';

  @override
  String get playerQueue => 'Очередь';

  @override
  String get playerRepeat => 'Повтор';

  @override
  String get playerQueueEmpty => 'Очередь пуста';

  @override
  String playerSourceChip(String source, String quality) {
    return '$source · $quality';
  }

  @override
  String get playerLocal => 'Локальный файл';

  @override
  String get playerRadio => 'Волна';

  @override
  String get playerSleep => 'Таймер сна';

  @override
  String get playerSleepOff => 'Выключен';

  @override
  String playerSleepMinutes(int count) {
    return '$count мин';
  }

  @override
  String get playerSleepUntilEnd => 'До конца трека';

  @override
  String get playerSleepNote =>
      'Пауза по таймеру ставится после текущего трека.';

  @override
  String get playerLyrics => 'Текст';

  @override
  String get playerLyricsMissing => 'Текста пока нет';

  @override
  String get playerDownload => 'Скачать';

  @override
  String get playerDownloadSoon => 'Загрузка офлайн появится на этапе офлайна';

  @override
  String get menuDownloaded => 'Удалить скачанное';

  @override
  String get menuDownloading => 'Скачивается…';

  @override
  String get menuDownloadRetry => 'Повторить скачивание';

  @override
  String downloadProgress(int percent) {
    return 'Скачивается: $percent%';
  }

  @override
  String get downloadRemoved => 'Скачанное удалено';

  @override
  String downloadFailed(String error) {
    return 'Не удалось скачать: $error';
  }

  @override
  String get playerSleepFired => 'Таймер сна: пауза';

  @override
  String get searchHint => 'Артист, трек или альбом';

  @override
  String get searchEmpty =>
      'Начните вводить — ищем по всем подключённым источникам';

  @override
  String get searchNoResults => 'Ничего не нашлось';

  @override
  String get searchTracks => 'Треки';

  @override
  String get searchArtists => 'Исполнители';

  @override
  String get searchAlbums => 'Альбомы';

  @override
  String searchResults(int count) {
    return 'Найдено: $count';
  }

  @override
  String searchSourceLabel(String source) {
    return 'Источник: $source';
  }

  @override
  String get searchFailed => 'Источник не ответил';

  @override
  String get searchPlayFromSearch => 'Играть из поиска';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsSectionAppearance => 'Оформление и язык';

  @override
  String get settingsSectionSound => 'Звук и воспроизведение';

  @override
  String get settingsSectionKaraoke => 'Караоке';

  @override
  String get settingsSectionStorage => 'Хранилище и данные';

  @override
  String get settingsSectionAccount => 'Аккаунт и сервисы';

  @override
  String get settingsSectionAbout => 'О приложении';

  @override
  String get settingsOpenSection => 'Открыть';

  @override
  String get lyricsSize => 'Размер текста';

  @override
  String get lyricsSizeSmall => 'Мелкий';

  @override
  String get lyricsSizeNormal => 'Обычный';

  @override
  String get lyricsSizeLarge => 'Крупный';

  @override
  String get lyricsDim => 'Приглушать остальные строки';

  @override
  String get settingsAppearance => 'Оформление';

  @override
  String get appearanceThemeLanguage => 'Тема и язык';

  @override
  String get appearanceShapeMotion => 'Форма и движение';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get themeSystem => 'Как в системе';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get settingsPalette => 'Палитра';

  @override
  String get paletteBrand => 'Фирменная';

  @override
  String get paletteDynamic => 'Material You';

  @override
  String get paletteMono => 'Монохром';

  @override
  String get paletteAmoled => 'AMOLED';

  @override
  String get paletteDynamicNote =>
      'Material You доступно на Android 12 и новее';

  @override
  String get paletteAmoledNote =>
      'Чистый чёрный фон: на OLED пиксели гаснут, батарея держит дольше';

  @override
  String get settingsAccent => 'Акцент';

  @override
  String get accentAcid => 'Кислота';

  @override
  String get accentViolet => 'Фиалка';

  @override
  String get accentCoral => 'Коралл';

  @override
  String get accentTeal => 'Мята';

  @override
  String get accentAmber => 'Янтарь';

  @override
  String get accentIce => 'Лёд';

  @override
  String get accentSky => 'Небо';

  @override
  String get accentRose => 'Роза';

  @override
  String get accentLeaf => 'Лист';

  @override
  String get accentOrchid => 'Орхидея';

  @override
  String get launcherForest => 'Лес';

  @override
  String get settingsContrast => 'Контраст';

  @override
  String get contrastNormal => 'Обычный';

  @override
  String get contrastHigh => 'Высокий';

  @override
  String get settingsCorners => 'Скругление';

  @override
  String get cornerSoft => 'Мягкое';

  @override
  String get cornerRound => 'Округлое';

  @override
  String get cornerPill => 'Пилюля';

  @override
  String get settingsMotion => 'Анимации';

  @override
  String get uiSection => 'Интерфейс';

  @override
  String get settingsBlur => 'Размытие';

  @override
  String get blurBottom => 'Нижняя панель и мини-плеер';

  @override
  String get blurTop => 'Верхние панели';

  @override
  String get blurCovers => 'Фоновые обложки';

  @override
  String get blurOff => 'Выкл';

  @override
  String get blurSoft => 'Мягкое';

  @override
  String get blurMedium => 'Среднее';

  @override
  String get blurStrong => 'Сильное';

  @override
  String get blurBottomNote =>
      'Стекло под пилюлями: видно, что список продолжается';

  @override
  String get blurTopNote => 'Панели с кнопками «назад» на страницах с обложкой';

  @override
  String get blurCoversNote => 'Сила размытия фоновых обложек на всех экранах';

  @override
  String get blurPerformanceNote =>
      'Во время прокрутки стекло становится плотнее и не размывает фон заново, а фоновые обложки размываются в уменьшенном размере. Так плавнее на бюджетных телефонах.';

  @override
  String get compactUi => 'Компактная панель';

  @override
  String get compactUiNote => 'Нижняя навигация и мини-плеер ниже и плотнее.';

  @override
  String get showMiniPlayer => 'Мини-плеер';

  @override
  String get showNavLabels => 'Подписи в навигации';

  @override
  String get showNavLabelsNote => 'Без подписей панель ниже, а иконки крупнее.';

  @override
  String get hideAi => 'Скрывать ИИ-треки';

  @override
  String get hideAiNote =>
      'Список ИИ-исполнителей — Slopless (GitHub), плюс явные пометки в названии и исполнителе. Список скачивается по сети; официальной метки в API Яндекса пока нет.';

  @override
  String get artworkShape => 'Обложка плеера';

  @override
  String get artworkRounded => 'Как в теме';

  @override
  String get artworkSoft => 'Мягкая';

  @override
  String get artworkCircle => 'Круглая';

  @override
  String get showMiniPlayerNote => 'Показывать полоску плеера над навигацией.';

  @override
  String get homeBackground => 'Фон главной';

  @override
  String get bgCover => 'Обложка';

  @override
  String get bgBlobs => 'Пятна';

  @override
  String get bgBoth => 'Обложка и пятна';

  @override
  String get settingsFade => 'Плавное затухание';

  @override
  String get settingsFadeNote =>
      'Громкость плавно поднимается при старте и опускается при паузе, перемотке и смене трека.';

  @override
  String get settingsEqualizer => 'Эквалайзер';

  @override
  String get equalizerEnabled => 'Включить эквалайзер';

  @override
  String get equalizerNote =>
      'Пресет применяется к текущему воспроизведению сразу.';

  @override
  String get equalizerPreset => 'Пресет';

  @override
  String get equalizerTune => 'Настроить';

  @override
  String get equalizerCustom => 'Своя настройка';

  @override
  String get equalizerLevel => 'ур.';

  @override
  String get eqPresetFlat => 'Ровный';

  @override
  String get eqPresetBass => 'Бас';

  @override
  String get eqPresetTreble => 'Верх';

  @override
  String get eqPresetRock => 'Рок';

  @override
  String get eqPresetElectronic => 'Электро';

  @override
  String get eqPresetPop => 'Поп';

  @override
  String get eqPresetVocal => 'Вокал';

  @override
  String get eqPresetAcoustic => 'Акустика';

  @override
  String get censorBypass => 'Версия без цензуры';

  @override
  String get censorBypassNote =>
      'Подменять треки из базы FckCensorData (GitHub) на незацензуренную версию. База загружается по сети; если файла нет, играет версия Яндекса.';

  @override
  String get settingsReset => 'Сбросить настройки';

  @override
  String get settingsResetDone =>
      'Настройки вернулись к значениям по умолчанию';

  @override
  String get settingsLyricsSource => 'Тексты: LRCLIB + Яндекс';

  @override
  String get settingsLyricsSourceNote =>
      'Тайминги строк приходят из LRCLIB; пословной подсветки в источнике нет.';

  @override
  String get motionOff => 'Выключены';

  @override
  String get motionFast => 'Быстрые';

  @override
  String get motionNormal => 'Обычные';

  @override
  String get motionSlow => 'Плавные';

  @override
  String get settingsLauncherIcon => 'Значок в лаунчере';

  @override
  String get launcherIconApplied =>
      'Значок обновлён: лаунер может перезагрузиться';

  @override
  String launcherIconFailed(String error) {
    return 'Сменить значок не вышло: $error';
  }

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get languageSystem => 'Как в системе';

  @override
  String get settingsPlayback => 'Воспроизведение';

  @override
  String get settingsQuality => 'Качество потока';

  @override
  String get qualityAuto => 'Авто (лучшее доступное)';

  @override
  String get qualityLow => 'Экономное';

  @override
  String get qualityNormal => 'Среднее';

  @override
  String get qualityHigh => 'Высокое';

  @override
  String get qualityLossless => 'Без потерь';

  @override
  String get settingsPriority => 'Приоритет источников';

  @override
  String get settingsPriorityNote =>
      'Если трек не игрится, плеер идёт к следующему по списку';

  @override
  String get roleStream => 'воспроизводит';

  @override
  String get roleCatalog => 'только каталог';

  @override
  String get roleAbsent => 'не подключён';

  @override
  String get settingsStorage => 'Хранилище';

  @override
  String get settingsCache => 'Кэш обложек';

  @override
  String get settingsCacheClear => 'Очистить кэш';

  @override
  String get settingsCacheCleared => 'Кэш обложек очищен';

  @override
  String get settingsData => 'Данные';

  @override
  String settingsRows(int count) {
    return 'Строк в базе: $count';
  }

  @override
  String settingsSchema(int version) {
    return 'Схема БД: v$version';
  }

  @override
  String get settingsLogs => 'Журнал событий';

  @override
  String get settingsAccount => 'Аккаунт';

  @override
  String get settingsSignOut => 'Выйти из Яндекса';

  @override
  String get accountPlus => 'Подписка активна';

  @override
  String get accountFree => 'Без подписки';

  @override
  String get settingsSignedOut => 'Вышли из Яндекса';

  @override
  String get settingsAbout => 'О приложении';

  @override
  String settingsVersion(String version) {
    return 'Версия $version';
  }

  @override
  String get updatesTitle => 'Обновления';

  @override
  String get updatesTileSubtitle => 'Приватные релизы GitHub';

  @override
  String get updatesCheckShort => 'Проверить';

  @override
  String get updatesChecking => 'Проверяю релизы…';

  @override
  String get updatesUpToDate => 'Установлена последняя версия';

  @override
  String get updatesNotChecked => 'Обновления ещё не проверялись';

  @override
  String get updatesReleases => 'Релизы';

  @override
  String updatesLatestRelease(String version) {
    return 'Последний релиз на GitHub: $version';
  }

  @override
  String updatesWhatsNew(String version) {
    return 'Что нового в $version';
  }

  @override
  String get updatesOpenGithub => 'Открыть релиз на GitHub';

  @override
  String updatesAvailable(String version) {
    return 'Доступна версия $version';
  }

  @override
  String updatesSize(String size) {
    return '$size МБ';
  }

  @override
  String get updatesDownload => 'Скачать и установить';

  @override
  String updatesDownloading(int percent) {
    return 'Загрузка: $percent%';
  }

  @override
  String get updatesCancel => 'Отменить';

  @override
  String get updatesOpeningInstaller => 'Открываю установщик…';

  @override
  String get updatesInstallPermission =>
      'Разреши установку из этого приложения и нажми ещё раз';

  @override
  String get updatesTokenTitle => 'Доступ к приватному репозиторию';

  @override
  String get updatesTokenLabel => 'Токен GitHub';

  @override
  String get updatesTokenHint => 'fine-grained PAT, Contents: Read-only';

  @override
  String get updatesTokenHelp =>
      'Токен хранится только на этом телефоне. Нужен fine-grained PAT с доступом Contents: Read-only к krinix1337/mimikoPlayer.';

  @override
  String get updatesTokenCheckHint => 'Вставь токен и нажми «Проверить».';

  @override
  String get updatesTokenMissing => 'Токен не задан';

  @override
  String get updatesTokenUnchecked => 'Токен введён, но не проверен';

  @override
  String get updatesTokenValid => 'Токен принят';

  @override
  String get updatesTokenInvalid => 'Токен не подошёл';

  @override
  String get updatesTokenDelete => 'Удалить токен';

  @override
  String get updatesTokenCreate => 'Создать токен';

  @override
  String get updatesTokenNeeded =>
      'Вставь токен GitHub или собери приложение с GITHUB_TOKEN.';

  @override
  String get updatesErrorUnauthorized =>
      'Токен не подошёл или нет доступа к репозиторию';

  @override
  String get updatesErrorNotFound => 'Нет доступа к репозиторию или релизам';

  @override
  String get updatesErrorNoAsset => 'В последнем релизе нет APK';

  @override
  String get updatesErrorNoDigest =>
      'У релиза нет SHA-256, скачивание отменено';

  @override
  String get updatesErrorChecksum =>
      'Контрольная сумма не совпала, файл удалён';

  @override
  String get updatesErrorNetwork => 'Нет связи с GitHub';

  @override
  String get updatesErrorUnknown => 'Не удалось проверить обновления';

  @override
  String get updatesReady => 'Файл скачан и проверен';

  @override
  String get updatesInstall => 'Установить';

  @override
  String get updatesBuildToken => 'Токен задан при сборке';

  @override
  String get settingsAboutNote =>
      'Локальный плеер: Яндекс Музыка, SoundCloud и свои файлы в одном интерфейсе.';

  @override
  String get aboutSources => 'Источники';

  @override
  String get aboutSourcesNote =>
      'Яндекс Музыка — каталог, поток и волна; SoundCloud — поиск и поток; локальные файлы из папки Music. Тексты: LRCLIB, официальный текст Яндекса и lyrics.ovh.';

  @override
  String get settingsAiFilter => 'ИИ-фильтр';

  @override
  String get accountConnected => 'Подключено';

  @override
  String get accountSignOut => 'Выйти';

  @override
  String get accountServices => 'Сервисы';

  @override
  String get accountSoundCloudNote => 'Поиск и поток без входа';

  @override
  String get aboutYandexNote => 'Каталог, поток, волна и рекомендации';

  @override
  String get settingsAiFilterSource => 'ИИ-фильтр: Slopless';

  @override
  String get settingsCensorSource => 'Версии без цензуры: FckCensorData';

  @override
  String get authTitle => 'Вход в Яндекс';

  @override
  String get authCodeHint => 'Код подтверждения';

  @override
  String get authCopyCode => 'Копировать код';

  @override
  String get authCopied => 'Код скопирован';

  @override
  String get authOpenLink => 'Перейти';

  @override
  String get authWaiting => 'Ждём подтверждения в браузере…';

  @override
  String authDone(String name) {
    return 'Вы вошли как $name';
  }

  @override
  String authFailed(String error) {
    return 'Вход не завершился: $error';
  }

  @override
  String get authExpired => 'Код истёк, начните вход заново';

  @override
  String get authNotSignedIn => 'Аккаунт Яндекс не подключён';

  @override
  String get authNotBuilt => 'Яндекс не собран в этом приложении';

  @override
  String get authRequestingCode => 'Запрашиваем код…';

  @override
  String get authCodeIntro =>
      'Подтвердите вход на странице Яндекса. Код уже подставлен в ссылку, осталось нажать «Разрешить».';

  @override
  String get authOpenPage => 'Перейти на страницу Яндекса';

  @override
  String get authWaitingCode => 'Ждём подтверждения. Код живёт ~5 минут.';

  @override
  String get authNotConfirmed => 'Вход не подтверждён — нажми «Начать заново»';

  @override
  String authBrowserFailed(String url) {
    return 'Браузер не открылся: $url';
  }

  @override
  String get authRetry => 'Начать заново';

  @override
  String get authSignOut => 'Выйти';

  @override
  String authCodeCopied(String code) {
    return 'Код $code скопирован';
  }

  @override
  String get issueHeadline => 'Трек не игрится';

  @override
  String get issueNeedsLogin => 'Нужен вход в источник';

  @override
  String get issueNeedsPlus => 'Нужна подписка источника';

  @override
  String get issueGeo => 'Трек недоступен в вашем регионе';

  @override
  String get issueUnavailable => 'Трека нет в каталоге';

  @override
  String get issueNetwork => 'Проблема с сетью';

  @override
  String get issueThrottled => 'Источник ограничил частоту запросов';

  @override
  String get issueSignature => 'Подпись потока не прошла';

  @override
  String get issueExhausted => 'Все источники отказали';

  @override
  String get issueUnknown => 'Неизвестная ошибка';

  @override
  String toastQueueStarted(String title) {
    return 'Играет: $title';
  }

  @override
  String dbError(String error) {
    return 'База не ответила: $error';
  }

  @override
  String get navDiscover => 'Обзор';

  @override
  String get discoverTitle => 'Что послушать';

  @override
  String get discoverChart => 'Чарт';

  @override
  String get discoverNewReleases => 'Новые релизы';

  @override
  String get discoverStations => 'Жанры и настроения';

  @override
  String get discoverArtists => 'Твои артисты';

  @override
  String get discoverAll => 'Все';

  @override
  String get searchHistoryTitle => 'История поиска';

  @override
  String get searchHistoryClear => 'Очистить';

  @override
  String get waveListen => 'Слушать';

  @override
  String get waveWheelHint => 'Крути и выбирай режим';

  @override
  String get waveBackToUsual => 'Обычная волна';

  @override
  String get moodEnergyActive => 'Бодрое';

  @override
  String get moodEnergyFun => 'Весёлое';

  @override
  String get moodEnergyCalm => 'Спокойное';

  @override
  String get moodEnergySad => 'Грустное';

  @override
  String get diversityFavorite => 'Любимое';

  @override
  String get diversityDiscover => 'Незнакомое';

  @override
  String get diversityPopular => 'Популярное';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageForeign => 'Иностранный';

  @override
  String get languageInstrumental => 'Без слов';

  @override
  String get homeCoverTone => 'Тон обложки';

  @override
  String get homeCoverDarker => 'Темнее';

  @override
  String get homeCoverNormal => 'Обычная';

  @override
  String get homeCoverLighter => 'Светлее';

  @override
  String get djInfo => 'DJ-сведения';

  @override
  String get djInfoNote => 'BPM и тональность в сведениях о треке';

  @override
  String get trackUnknownArtist => 'Неизвестный исполнитель';

  @override
  String get badgeExplicit => '18+';

  @override
  String get badgeAi => 'ИИ';

  @override
  String get badgeUncensored => 'Без цензуры';

  @override
  String get sourceYandex => 'Яндекс Музыка';

  @override
  String get sourceRemoved => 'Источник удалён';

  @override
  String get sourceLocalFile => 'Файл';

  @override
  String get detailsSource => 'Источник';

  @override
  String get detailsSources => 'Источники';

  @override
  String get detailsAlbum => 'Альбом';

  @override
  String get detailsYear => 'Год';

  @override
  String get detailsDuration => 'Длительность';

  @override
  String get detailsIsrc => 'ISRC';

  @override
  String get detailsQuality => 'Качество';

  @override
  String get detailsCodec => 'Кодек';

  @override
  String get detailsSize => 'Размер';

  @override
  String get detailsFile => 'Файл';

  @override
  String get detailsRemoteId => 'ID источника';

  @override
  String get detailsLocalId => 'Локальный ID';

  @override
  String get djBpm => 'BPM';

  @override
  String get djGain => 'Громкость';

  @override
  String get djKey => 'Тональность';

  @override
  String get djNoKey => 'Не указана';

  @override
  String get djSourceNote =>
      'BPM и громкость — Deezer. Тональность можно указать вручную по Camelot.';

  @override
  String get downloadsPaused => 'На паузе';

  @override
  String get downloadsPause => 'Пауза';

  @override
  String get downloadsResume => 'Продолжить';

  @override
  String get settingsDownloads => 'Загрузки';

  @override
  String downloadsSummary(int count, String size) {
    return 'Скачано: $count · $size';
  }

  @override
  String downloadsQueueSummary(int queued, int paused) {
    return 'В очереди: $queued · на паузе: $paused';
  }

  @override
  String downloadsSkipped(int count) {
    return 'Пропущено как недоступное офлайн: $count';
  }

  @override
  String get downloadsAutoLikes => 'Качать любимое автоматически';

  @override
  String get downloadsAutoLikesNote =>
      'По умолчанию выключено. Сначала пробные 20 треков, потом все.';

  @override
  String get downloadsDownloadAll => 'Скачать все лайки';

  @override
  String get downloadsDownloadAllNote =>
      'Поставит в очередь все лайки. Пауза и лимит продолжают работать.';

  @override
  String get downloadsWifiOnly => 'Только Wi-Fi';

  @override
  String get downloadsWifiOnlyNote =>
      'Автозагрузка ждёт Wi-Fi; ручные загрузки разрешены в любой сети.';

  @override
  String get downloadsLimit => 'Лимит места';

  @override
  String get downloadsLimitNote =>
      'При достижении очередь останавливается, файлы не удаляются.';

  @override
  String get downloadsUnlimited => 'Без лимита';

  @override
  String downloadsGb(int value) {
    return '$value ГБ';
  }

  @override
  String get downloadsQuality => 'Качество автозагрузки';

  @override
  String get downloadsQualityNote => 'Не меняет уже скачанные файлы.';

  @override
  String get downloadsDeleteAll => 'Удалить все загрузки';

  @override
  String get downloadsDeleteAllQuestion => 'Удалить все скачанные треки?';

  @override
  String get downloadsDeletedAll => 'Все загрузки удалены';

  @override
  String downloadsFreeSpace(String size) {
    return 'Свободно: $size';
  }
}
