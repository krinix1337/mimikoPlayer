import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'mimikoPlayer'**
  String get appTitle;

  /// No description provided for @navWave.
  ///
  /// In ru, this message translates to:
  /// **'Волна'**
  String get navWave;

  /// No description provided for @navSearch.
  ///
  /// In ru, this message translates to:
  /// **'Поиск'**
  String get navSearch;

  /// No description provided for @navCollection.
  ///
  /// In ru, this message translates to:
  /// **'Коллекция'**
  String get navCollection;

  /// No description provided for @navSettings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get navSettings;

  /// No description provided for @commonPlay.
  ///
  /// In ru, this message translates to:
  /// **'Играть'**
  String get commonPlay;

  /// No description provided for @commonPause.
  ///
  /// In ru, this message translates to:
  /// **'Пауза'**
  String get commonPause;

  /// No description provided for @commonNext.
  ///
  /// In ru, this message translates to:
  /// **'Следующий'**
  String get commonNext;

  /// No description provided for @commonPrevious.
  ///
  /// In ru, this message translates to:
  /// **'Предыдущий'**
  String get commonPrevious;

  /// No description provided for @commonCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get commonSave;

  /// No description provided for @commonRetry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get commonRetry;

  /// No description provided for @commonTracks.
  ///
  /// In ru, this message translates to:
  /// **'треков'**
  String get commonTracks;

  /// No description provided for @commonLoading.
  ///
  /// In ru, this message translates to:
  /// **'Загружается…'**
  String get commonLoading;

  /// No description provided for @commonLike.
  ///
  /// In ru, this message translates to:
  /// **'В любимое'**
  String get commonLike;

  /// No description provided for @commonUnlike.
  ///
  /// In ru, this message translates to:
  /// **'Убрать из любимого'**
  String get commonUnlike;

  /// No description provided for @commonDislike.
  ///
  /// In ru, this message translates to:
  /// **'Нелюбимое'**
  String get commonDislike;

  /// No description provided for @waveTitle.
  ///
  /// In ru, this message translates to:
  /// **'Моя волна'**
  String get waveTitle;

  /// No description provided for @waveTune.
  ///
  /// In ru, this message translates to:
  /// **'Настроить волну'**
  String get waveTune;

  /// No description provided for @waveStart.
  ///
  /// In ru, this message translates to:
  /// **'Запустить волну'**
  String get waveStart;

  /// No description provided for @waveMood.
  ///
  /// In ru, this message translates to:
  /// **'Настроение'**
  String get waveMood;

  /// No description provided for @waveEnergy.
  ///
  /// In ru, this message translates to:
  /// **'Энергия'**
  String get waveEnergy;

  /// No description provided for @waveDiversity.
  ///
  /// In ru, this message translates to:
  /// **'Разнообразие'**
  String get waveDiversity;

  /// No description provided for @waveStation.
  ///
  /// In ru, this message translates to:
  /// **'Станция'**
  String get waveStation;

  /// No description provided for @wavePresets.
  ///
  /// In ru, this message translates to:
  /// **'Пресеты'**
  String get wavePresets;

  /// No description provided for @waveLanguage.
  ///
  /// In ru, this message translates to:
  /// **'Язык музыки'**
  String get waveLanguage;

  /// No description provided for @waveSaved.
  ///
  /// In ru, this message translates to:
  /// **'Настройки волны сохранены'**
  String get waveSaved;

  /// No description provided for @waveSaveFailed.
  ///
  /// In ru, this message translates to:
  /// **'Яндекс не принял настройки волны'**
  String get waveSaveFailed;

  /// No description provided for @waveNeedsLogin.
  ///
  /// In ru, this message translates to:
  /// **'Войдите в Яндекс, чтобы включить волну'**
  String get waveNeedsLogin;

  /// No description provided for @waveSignIn.
  ///
  /// In ru, this message translates to:
  /// **'Войти в Яндекс'**
  String get waveSignIn;

  /// No description provided for @waveSignedInAs.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт: {account}'**
  String waveSignedInAs(String account);

  /// No description provided for @waveQueueFailed.
  ///
  /// In ru, this message translates to:
  /// **'Волна не отдала треки'**
  String get waveQueueFailed;

  /// No description provided for @waveStationMore.
  ///
  /// In ru, this message translates to:
  /// **'Ещё волны'**
  String get waveStationMore;

  /// No description provided for @waveNotStarted.
  ///
  /// In ru, this message translates to:
  /// **'Волна не запущена'**
  String get waveNotStarted;

  /// No description provided for @sourceLibrary.
  ///
  /// In ru, this message translates to:
  /// **'Моя коллекция'**
  String get sourceLibrary;

  /// No description provided for @sourcePlaylist.
  ///
  /// In ru, this message translates to:
  /// **'Плейлист'**
  String get sourcePlaylist;

  /// No description provided for @sourceSearch.
  ///
  /// In ru, this message translates to:
  /// **'Поиск'**
  String get sourceSearch;

  /// No description provided for @sourceChart.
  ///
  /// In ru, this message translates to:
  /// **'Чарт'**
  String get sourceChart;

  /// No description provided for @sourceAlbum.
  ///
  /// In ru, this message translates to:
  /// **'Альбом'**
  String get sourceAlbum;

  /// No description provided for @sourceArtist.
  ///
  /// In ru, this message translates to:
  /// **'Артист'**
  String get sourceArtist;

  /// No description provided for @switchToWave.
  ///
  /// In ru, this message translates to:
  /// **'Включить мою волну'**
  String get switchToWave;

  /// No description provided for @waveStationsFailed.
  ///
  /// In ru, this message translates to:
  /// **'Станции не загрузились: {error}'**
  String waveStationsFailed(String error);

  /// No description provided for @waveLikeAdded.
  ///
  /// In ru, this message translates to:
  /// **'Добавлено в любимое'**
  String get waveLikeAdded;

  /// No description provided for @waveLikeRemoved.
  ///
  /// In ru, this message translates to:
  /// **'Убрано из любимого'**
  String get waveLikeRemoved;

  /// No description provided for @waveSettingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Настройки волны'**
  String get waveSettingsTitle;

  /// No description provided for @waveApply.
  ///
  /// In ru, this message translates to:
  /// **'Применить'**
  String get waveApply;

  /// No description provided for @waveClose.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get waveClose;

  /// No description provided for @waveSavedNote.
  ///
  /// In ru, this message translates to:
  /// **'Настройки волны сохранены'**
  String get waveSavedNote;

  /// No description provided for @waveRejectedNote.
  ///
  /// In ru, this message translates to:
  /// **'Яндекс не принял настройки — смотри лог'**
  String get waveRejectedNote;

  /// No description provided for @moodCalm.
  ///
  /// In ru, this message translates to:
  /// **'спокойное'**
  String get moodCalm;

  /// No description provided for @moodEven.
  ///
  /// In ru, this message translates to:
  /// **'ровное'**
  String get moodEven;

  /// No description provided for @moodActive.
  ///
  /// In ru, this message translates to:
  /// **'активное'**
  String get moodActive;

  /// No description provided for @energyLow.
  ///
  /// In ru, this message translates to:
  /// **'низкая'**
  String get energyLow;

  /// No description provided for @energyMid.
  ///
  /// In ru, this message translates to:
  /// **'средняя'**
  String get energyMid;

  /// No description provided for @energyHigh.
  ///
  /// In ru, this message translates to:
  /// **'высокая'**
  String get energyHigh;

  /// No description provided for @diversityMore.
  ///
  /// In ru, this message translates to:
  /// **'побольше нового'**
  String get diversityMore;

  /// No description provided for @diversityLess.
  ///
  /// In ru, this message translates to:
  /// **'побольше знакомого'**
  String get diversityLess;

  /// No description provided for @diversityUsual.
  ///
  /// In ru, this message translates to:
  /// **'как обычно'**
  String get diversityUsual;

  /// No description provided for @langRu.
  ///
  /// In ru, this message translates to:
  /// **'русское'**
  String get langRu;

  /// No description provided for @langEn.
  ///
  /// In ru, this message translates to:
  /// **'английское'**
  String get langEn;

  /// No description provided for @langNonrank.
  ///
  /// In ru, this message translates to:
  /// **'без приоритета'**
  String get langNonrank;

  /// No description provided for @langAny.
  ///
  /// In ru, this message translates to:
  /// **'любое'**
  String get langAny;

  /// No description provided for @collectionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Коллекция'**
  String get collectionTitle;

  /// No description provided for @collectionLiked.
  ///
  /// In ru, this message translates to:
  /// **'Любимое'**
  String get collectionLiked;

  /// No description provided for @collectionDisliked.
  ///
  /// In ru, this message translates to:
  /// **'Нелюбимое'**
  String get collectionDisliked;

  /// No description provided for @collectionPlaylists.
  ///
  /// In ru, this message translates to:
  /// **'Плейлисты'**
  String get collectionPlaylists;

  /// No description provided for @collectionFiles.
  ///
  /// In ru, this message translates to:
  /// **'Файлы'**
  String get collectionFiles;

  /// No description provided for @collectionRecent.
  ///
  /// In ru, this message translates to:
  /// **'Недавние'**
  String get collectionRecent;

  /// No description provided for @collectionDownloaded.
  ///
  /// In ru, this message translates to:
  /// **'Скачанное'**
  String get collectionDownloaded;

  /// No description provided for @collectionEmptyDownloaded.
  ///
  /// In ru, this message translates to:
  /// **'Скачанных треков нет.\nСкачайте трек из меню или с экрана плеера — он заиграет без сети.'**
  String get collectionEmptyDownloaded;

  /// No description provided for @collectionArtists.
  ///
  /// In ru, this message translates to:
  /// **'Артисты'**
  String get collectionArtists;

  /// No description provided for @albumsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Альбомы'**
  String get albumsTitle;

  /// No description provided for @chartTitle.
  ///
  /// In ru, this message translates to:
  /// **'Чарт'**
  String get chartTitle;

  /// No description provided for @artistOpen.
  ///
  /// In ru, this message translates to:
  /// **'К исполнителю'**
  String get artistOpen;

  /// No description provided for @albumOpen.
  ///
  /// In ru, this message translates to:
  /// **'К альбому'**
  String get albumOpen;

  /// No description provided for @trackMenu.
  ///
  /// In ru, this message translates to:
  /// **'Меню трека'**
  String get trackMenu;

  /// No description provided for @menuLike.
  ///
  /// In ru, this message translates to:
  /// **'Нравится'**
  String get menuLike;

  /// No description provided for @menuDislike.
  ///
  /// In ru, this message translates to:
  /// **'Не нравится'**
  String get menuDislike;

  /// No description provided for @menuKaraoke.
  ///
  /// In ru, this message translates to:
  /// **'Караоке'**
  String get menuKaraoke;

  /// No description provided for @menuPlayNext.
  ///
  /// In ru, this message translates to:
  /// **'Играть следующим'**
  String get menuPlayNext;

  /// No description provided for @menuAddQueue.
  ///
  /// In ru, this message translates to:
  /// **'В очередь'**
  String get menuAddQueue;

  /// No description provided for @menuDetails.
  ///
  /// In ru, this message translates to:
  /// **'Сведения о треке'**
  String get menuDetails;

  /// No description provided for @menuDetailsBody.
  ///
  /// In ru, this message translates to:
  /// **'Источник: {source}\nКачество: {quality}\nФормат: {codec}'**
  String menuDetailsBody(String source, String quality, String codec);

  /// No description provided for @chartOpen.
  ///
  /// In ru, this message translates to:
  /// **'Чарт Яндекса'**
  String get chartOpen;

  /// No description provided for @collectionAlsoIn.
  ///
  /// In ru, this message translates to:
  /// **'Ещё в коллекции'**
  String get collectionAlsoIn;

  /// No description provided for @listenedMinutes.
  ///
  /// In ru, this message translates to:
  /// **'{count} мин'**
  String listenedMinutes(int count);

  /// No description provided for @listenedHours.
  ///
  /// In ru, this message translates to:
  /// **'{count} ч'**
  String listenedHours(int count);

  /// No description provided for @artistPlays.
  ///
  /// In ru, this message translates to:
  /// **'прослушиваний: {count}'**
  String artistPlays(int count);

  /// No description provided for @collectionCount.
  ///
  /// In ru, this message translates to:
  /// **'Всего: {count}'**
  String collectionCount(int count);

  /// No description provided for @collectionSort.
  ///
  /// In ru, this message translates to:
  /// **'Сортировка'**
  String get collectionSort;

  /// No description provided for @sortAdded.
  ///
  /// In ru, this message translates to:
  /// **'Недавно добавленные'**
  String get sortAdded;

  /// No description provided for @sortTitle.
  ///
  /// In ru, this message translates to:
  /// **'По названию'**
  String get sortTitle;

  /// No description provided for @sortArtist.
  ///
  /// In ru, this message translates to:
  /// **'По исполнителю'**
  String get sortArtist;

  /// No description provided for @sortDuration.
  ///
  /// In ru, this message translates to:
  /// **'По длительности'**
  String get sortDuration;

  /// No description provided for @collectionEmptyLiked.
  ///
  /// In ru, this message translates to:
  /// **'Любимого пока нет.\nСтавьте сердечко в волне или в списке треков.'**
  String get collectionEmptyLiked;

  /// No description provided for @collectionEmptyDisliked.
  ///
  /// In ru, this message translates to:
  /// **'Нелюбимых треков нет.'**
  String get collectionEmptyDisliked;

  /// No description provided for @collectionEmptyPlaylists.
  ///
  /// In ru, this message translates to:
  /// **'Плейлистов ещё нет — заберите их из Яндекса.'**
  String get collectionEmptyPlaylists;

  /// No description provided for @collectionEmptyFiles.
  ///
  /// In ru, this message translates to:
  /// **'В папке Music нет аудиофайлов.'**
  String get collectionEmptyFiles;

  /// No description provided for @collectionEmptyRecent.
  ///
  /// In ru, this message translates to:
  /// **'История прослушивания пуста.'**
  String get collectionEmptyRecent;

  /// No description provided for @collectionImportLikes.
  ///
  /// In ru, this message translates to:
  /// **'Подтянуть лайки из Яндекса'**
  String get collectionImportLikes;

  /// No description provided for @collectionImportPlaylists.
  ///
  /// In ru, this message translates to:
  /// **'Импортировать плейлисты из Яндекса'**
  String get collectionImportPlaylists;

  /// No description provided for @collectionImportedLikes.
  ///
  /// In ru, this message translates to:
  /// **'Лайков в коллекции: {count}'**
  String collectionImportedLikes(int count);

  /// No description provided for @collectionImportedPlaylists.
  ///
  /// In ru, this message translates to:
  /// **'Плейлистов сохранено: {count}'**
  String collectionImportedPlaylists(int count);

  /// No description provided for @collectionImportFailed.
  ///
  /// In ru, this message translates to:
  /// **'Яндекс не отдал коллекцию: {error}'**
  String collectionImportFailed(String error);

  /// No description provided for @collectionPlayAll.
  ///
  /// In ru, this message translates to:
  /// **'Играть всё'**
  String get collectionPlayAll;

  /// No description provided for @collectionShuffleAll.
  ///
  /// In ru, this message translates to:
  /// **'Перемешать'**
  String get collectionShuffleAll;

  /// No description provided for @collectionLocalTag.
  ///
  /// In ru, this message translates to:
  /// **'Локальный файл'**
  String get collectionLocalTag;

  /// No description provided for @agoNow.
  ///
  /// In ru, this message translates to:
  /// **'только что'**
  String get agoNow;

  /// No description provided for @agoMinutes.
  ///
  /// In ru, this message translates to:
  /// **'{count} мин назад'**
  String agoMinutes(int count);

  /// No description provided for @agoHours.
  ///
  /// In ru, this message translates to:
  /// **'{count} ч назад'**
  String agoHours(int count);

  /// No description provided for @agoDays.
  ///
  /// In ru, this message translates to:
  /// **'{count} дн назад'**
  String agoDays(int count);

  /// No description provided for @playerTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сейчас играет'**
  String get playerTitle;

  /// No description provided for @playerBack.
  ///
  /// In ru, this message translates to:
  /// **'Назад'**
  String get playerBack;

  /// No description provided for @playerQueue.
  ///
  /// In ru, this message translates to:
  /// **'Очередь'**
  String get playerQueue;

  /// No description provided for @playerRepeat.
  ///
  /// In ru, this message translates to:
  /// **'Повтор'**
  String get playerRepeat;

  /// No description provided for @playerQueueEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Очередь пуста'**
  String get playerQueueEmpty;

  /// No description provided for @playerSourceChip.
  ///
  /// In ru, this message translates to:
  /// **'{source} · {quality}'**
  String playerSourceChip(String source, String quality);

  /// No description provided for @playerLocal.
  ///
  /// In ru, this message translates to:
  /// **'Локальный файл'**
  String get playerLocal;

  /// No description provided for @playerRadio.
  ///
  /// In ru, this message translates to:
  /// **'Волна'**
  String get playerRadio;

  /// No description provided for @playerSleep.
  ///
  /// In ru, this message translates to:
  /// **'Таймер сна'**
  String get playerSleep;

  /// No description provided for @playerSleepOff.
  ///
  /// In ru, this message translates to:
  /// **'Выключен'**
  String get playerSleepOff;

  /// No description provided for @playerSleepMinutes.
  ///
  /// In ru, this message translates to:
  /// **'{count} мин'**
  String playerSleepMinutes(int count);

  /// No description provided for @playerSleepUntilEnd.
  ///
  /// In ru, this message translates to:
  /// **'До конца трека'**
  String get playerSleepUntilEnd;

  /// No description provided for @playerSleepNote.
  ///
  /// In ru, this message translates to:
  /// **'Пауза по таймеру ставится после текущего трека.'**
  String get playerSleepNote;

  /// No description provided for @playerLyrics.
  ///
  /// In ru, this message translates to:
  /// **'Текст'**
  String get playerLyrics;

  /// No description provided for @playerLyricsMissing.
  ///
  /// In ru, this message translates to:
  /// **'Текста пока нет'**
  String get playerLyricsMissing;

  /// No description provided for @playerDownload.
  ///
  /// In ru, this message translates to:
  /// **'Скачать'**
  String get playerDownload;

  /// No description provided for @playerDownloadSoon.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка офлайн появится на этапе офлайна'**
  String get playerDownloadSoon;

  /// No description provided for @menuDownloaded.
  ///
  /// In ru, this message translates to:
  /// **'Удалить скачанное'**
  String get menuDownloaded;

  /// No description provided for @menuDownloading.
  ///
  /// In ru, this message translates to:
  /// **'Скачивается…'**
  String get menuDownloading;

  /// No description provided for @menuDownloadRetry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить скачивание'**
  String get menuDownloadRetry;

  /// No description provided for @downloadProgress.
  ///
  /// In ru, this message translates to:
  /// **'Скачивается: {percent}%'**
  String downloadProgress(int percent);

  /// No description provided for @downloadRemoved.
  ///
  /// In ru, this message translates to:
  /// **'Скачанное удалено'**
  String get downloadRemoved;

  /// No description provided for @downloadFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось скачать: {error}'**
  String downloadFailed(String error);

  /// No description provided for @playerSleepFired.
  ///
  /// In ru, this message translates to:
  /// **'Таймер сна: пауза'**
  String get playerSleepFired;

  /// No description provided for @searchHint.
  ///
  /// In ru, this message translates to:
  /// **'Артист, трек или альбом'**
  String get searchHint;

  /// No description provided for @searchEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Начните вводить — ищем по всем подключённым источникам'**
  String get searchEmpty;

  /// No description provided for @searchNoResults.
  ///
  /// In ru, this message translates to:
  /// **'Ничего не нашлось'**
  String get searchNoResults;

  /// No description provided for @searchResults.
  ///
  /// In ru, this message translates to:
  /// **'Найдено: {count}'**
  String searchResults(int count);

  /// No description provided for @searchSourceLabel.
  ///
  /// In ru, this message translates to:
  /// **'Источник: {source}'**
  String searchSourceLabel(String source);

  /// No description provided for @searchFailed.
  ///
  /// In ru, this message translates to:
  /// **'Источник не ответил'**
  String get searchFailed;

  /// No description provided for @searchPlayFromSearch.
  ///
  /// In ru, this message translates to:
  /// **'Играть из поиска'**
  String get searchPlayFromSearch;

  /// No description provided for @settingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settingsTitle;

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In ru, this message translates to:
  /// **'Оформление и язык'**
  String get settingsSectionAppearance;

  /// No description provided for @settingsSectionSound.
  ///
  /// In ru, this message translates to:
  /// **'Звук и воспроизведение'**
  String get settingsSectionSound;

  /// No description provided for @settingsSectionKaraoke.
  ///
  /// In ru, this message translates to:
  /// **'Караоке'**
  String get settingsSectionKaraoke;

  /// No description provided for @settingsSectionStorage.
  ///
  /// In ru, this message translates to:
  /// **'Хранилище и данные'**
  String get settingsSectionStorage;

  /// No description provided for @settingsSectionAccount.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт и сервисы'**
  String get settingsSectionAccount;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In ru, this message translates to:
  /// **'О приложении'**
  String get settingsSectionAbout;

  /// No description provided for @settingsOpenSection.
  ///
  /// In ru, this message translates to:
  /// **'Открыть'**
  String get settingsOpenSection;

  /// No description provided for @lyricsSize.
  ///
  /// In ru, this message translates to:
  /// **'Размер текста'**
  String get lyricsSize;

  /// No description provided for @lyricsSizeSmall.
  ///
  /// In ru, this message translates to:
  /// **'Мелкий'**
  String get lyricsSizeSmall;

  /// No description provided for @lyricsSizeNormal.
  ///
  /// In ru, this message translates to:
  /// **'Обычный'**
  String get lyricsSizeNormal;

  /// No description provided for @lyricsSizeLarge.
  ///
  /// In ru, this message translates to:
  /// **'Крупный'**
  String get lyricsSizeLarge;

  /// No description provided for @lyricsDim.
  ///
  /// In ru, this message translates to:
  /// **'Приглушать остальные строки'**
  String get lyricsDim;

  /// No description provided for @settingsAppearance.
  ///
  /// In ru, this message translates to:
  /// **'Оформление'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In ru, this message translates to:
  /// **'Тема'**
  String get settingsTheme;

  /// No description provided for @themeSystem.
  ///
  /// In ru, this message translates to:
  /// **'Как в системе'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In ru, this message translates to:
  /// **'Светлая'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ru, this message translates to:
  /// **'Тёмная'**
  String get themeDark;

  /// No description provided for @settingsPalette.
  ///
  /// In ru, this message translates to:
  /// **'Палитра'**
  String get settingsPalette;

  /// No description provided for @paletteBrand.
  ///
  /// In ru, this message translates to:
  /// **'Фирменная'**
  String get paletteBrand;

  /// No description provided for @paletteDynamic.
  ///
  /// In ru, this message translates to:
  /// **'Material You'**
  String get paletteDynamic;

  /// No description provided for @paletteMono.
  ///
  /// In ru, this message translates to:
  /// **'Монохром'**
  String get paletteMono;

  /// No description provided for @paletteDynamicNote.
  ///
  /// In ru, this message translates to:
  /// **'Material You доступно на Android 12 и новее'**
  String get paletteDynamicNote;

  /// No description provided for @settingsAccent.
  ///
  /// In ru, this message translates to:
  /// **'Акцент'**
  String get settingsAccent;

  /// No description provided for @accentAcid.
  ///
  /// In ru, this message translates to:
  /// **'Кислота'**
  String get accentAcid;

  /// No description provided for @accentViolet.
  ///
  /// In ru, this message translates to:
  /// **'Фиалка'**
  String get accentViolet;

  /// No description provided for @accentCoral.
  ///
  /// In ru, this message translates to:
  /// **'Коралл'**
  String get accentCoral;

  /// No description provided for @accentTeal.
  ///
  /// In ru, this message translates to:
  /// **'Мята'**
  String get accentTeal;

  /// No description provided for @accentAmber.
  ///
  /// In ru, this message translates to:
  /// **'Янтарь'**
  String get accentAmber;

  /// No description provided for @accentIce.
  ///
  /// In ru, this message translates to:
  /// **'Лёд'**
  String get accentIce;

  /// No description provided for @accentSky.
  ///
  /// In ru, this message translates to:
  /// **'Небо'**
  String get accentSky;

  /// No description provided for @accentRose.
  ///
  /// In ru, this message translates to:
  /// **'Роза'**
  String get accentRose;

  /// No description provided for @accentLeaf.
  ///
  /// In ru, this message translates to:
  /// **'Лист'**
  String get accentLeaf;

  /// No description provided for @launcherForest.
  ///
  /// In ru, this message translates to:
  /// **'Лес'**
  String get launcherForest;

  /// No description provided for @launcherCrimson.
  ///
  /// In ru, this message translates to:
  /// **'Багровый'**
  String get launcherCrimson;

  /// No description provided for @settingsContrast.
  ///
  /// In ru, this message translates to:
  /// **'Контраст'**
  String get settingsContrast;

  /// No description provided for @contrastNormal.
  ///
  /// In ru, this message translates to:
  /// **'Обычный'**
  String get contrastNormal;

  /// No description provided for @contrastHigh.
  ///
  /// In ru, this message translates to:
  /// **'Высокий'**
  String get contrastHigh;

  /// No description provided for @settingsCorners.
  ///
  /// In ru, this message translates to:
  /// **'Скругление'**
  String get settingsCorners;

  /// No description provided for @cornerSoft.
  ///
  /// In ru, this message translates to:
  /// **'Мягкое'**
  String get cornerSoft;

  /// No description provided for @cornerRound.
  ///
  /// In ru, this message translates to:
  /// **'Округлое'**
  String get cornerRound;

  /// No description provided for @cornerPill.
  ///
  /// In ru, this message translates to:
  /// **'Пилюля'**
  String get cornerPill;

  /// No description provided for @settingsMotion.
  ///
  /// In ru, this message translates to:
  /// **'Анимации'**
  String get settingsMotion;

  /// No description provided for @uiSection.
  ///
  /// In ru, this message translates to:
  /// **'Интерфейс'**
  String get uiSection;

  /// No description provided for @compactUi.
  ///
  /// In ru, this message translates to:
  /// **'Компактная панель'**
  String get compactUi;

  /// No description provided for @compactUiNote.
  ///
  /// In ru, this message translates to:
  /// **'Нижняя навигация и мини-плеер ниже и плотнее.'**
  String get compactUiNote;

  /// No description provided for @showMiniPlayer.
  ///
  /// In ru, this message translates to:
  /// **'Мини-плеер'**
  String get showMiniPlayer;

  /// No description provided for @showNavLabels.
  ///
  /// In ru, this message translates to:
  /// **'Подписи в навигации'**
  String get showNavLabels;

  /// No description provided for @showNavLabelsNote.
  ///
  /// In ru, this message translates to:
  /// **'Без подписей панель ниже, а иконки крупнее.'**
  String get showNavLabelsNote;

  /// No description provided for @hideAi.
  ///
  /// In ru, this message translates to:
  /// **'Скрывать ИИ-треки'**
  String get hideAi;

  /// No description provided for @hideAiNote.
  ///
  /// In ru, this message translates to:
  /// **'Список ИИ-исполнителей — Slopless (GitHub), плюс явные пометки в названии и исполнителе. Список скачивается по сети; официальной метки в API Яндекса пока нет.'**
  String get hideAiNote;

  /// No description provided for @artworkShape.
  ///
  /// In ru, this message translates to:
  /// **'Обложка плеера'**
  String get artworkShape;

  /// No description provided for @artworkRounded.
  ///
  /// In ru, this message translates to:
  /// **'Как в теме'**
  String get artworkRounded;

  /// No description provided for @artworkSoft.
  ///
  /// In ru, this message translates to:
  /// **'Мягкая'**
  String get artworkSoft;

  /// No description provided for @artworkCircle.
  ///
  /// In ru, this message translates to:
  /// **'Круглая'**
  String get artworkCircle;

  /// No description provided for @showMiniPlayerNote.
  ///
  /// In ru, this message translates to:
  /// **'Показывать полоску плеера над навигацией.'**
  String get showMiniPlayerNote;

  /// No description provided for @homeBackground.
  ///
  /// In ru, this message translates to:
  /// **'Фон главной'**
  String get homeBackground;

  /// No description provided for @bgCover.
  ///
  /// In ru, this message translates to:
  /// **'Обложка'**
  String get bgCover;

  /// No description provided for @bgBlobs.
  ///
  /// In ru, this message translates to:
  /// **'Пятна'**
  String get bgBlobs;

  /// No description provided for @bgBoth.
  ///
  /// In ru, this message translates to:
  /// **'Обложка и пятна'**
  String get bgBoth;

  /// No description provided for @settingsFade.
  ///
  /// In ru, this message translates to:
  /// **'Плавное затухание'**
  String get settingsFade;

  /// No description provided for @settingsFadeNote.
  ///
  /// In ru, this message translates to:
  /// **'Громкость плавно поднимается при старте и опускается при паузе, перемотке и смене трека.'**
  String get settingsFadeNote;

  /// No description provided for @censorBypass.
  ///
  /// In ru, this message translates to:
  /// **'Версия без цензуры'**
  String get censorBypass;

  /// No description provided for @censorBypassNote.
  ///
  /// In ru, this message translates to:
  /// **'Подменять треки из базы FckCensorData (GitHub) на незацензуренную версию. База загружается по сети; если файла нет, играет версия Яндекса.'**
  String get censorBypassNote;

  /// No description provided for @settingsReset.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить настройки'**
  String get settingsReset;

  /// No description provided for @settingsResetDone.
  ///
  /// In ru, this message translates to:
  /// **'Настройки вернулись к значениям по умолчанию'**
  String get settingsResetDone;

  /// No description provided for @settingsLyricsSource.
  ///
  /// In ru, this message translates to:
  /// **'Тексты: LRCLIB + Яндекс'**
  String get settingsLyricsSource;

  /// No description provided for @settingsLyricsSourceNote.
  ///
  /// In ru, this message translates to:
  /// **'Тайминги строк приходят из LRCLIB; пословной подсветки в источнике нет.'**
  String get settingsLyricsSourceNote;

  /// No description provided for @motionOff.
  ///
  /// In ru, this message translates to:
  /// **'Выключены'**
  String get motionOff;

  /// No description provided for @motionFast.
  ///
  /// In ru, this message translates to:
  /// **'Быстрые'**
  String get motionFast;

  /// No description provided for @motionNormal.
  ///
  /// In ru, this message translates to:
  /// **'Обычные'**
  String get motionNormal;

  /// No description provided for @motionSlow.
  ///
  /// In ru, this message translates to:
  /// **'Плавные'**
  String get motionSlow;

  /// No description provided for @settingsLauncherIcon.
  ///
  /// In ru, this message translates to:
  /// **'Значок в лаунчере'**
  String get settingsLauncherIcon;

  /// No description provided for @launcherIconApplied.
  ///
  /// In ru, this message translates to:
  /// **'Значок обновлён: лаунер может перезагрузиться'**
  String get launcherIconApplied;

  /// No description provided for @launcherIconFailed.
  ///
  /// In ru, this message translates to:
  /// **'Сменить значок не вышло: {error}'**
  String launcherIconFailed(String error);

  /// No description provided for @settingsLanguage.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get settingsLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In ru, this message translates to:
  /// **'Как в системе'**
  String get languageSystem;

  /// No description provided for @settingsPlayback.
  ///
  /// In ru, this message translates to:
  /// **'Воспроизведение'**
  String get settingsPlayback;

  /// No description provided for @settingsQuality.
  ///
  /// In ru, this message translates to:
  /// **'Качество потока'**
  String get settingsQuality;

  /// No description provided for @qualityAuto.
  ///
  /// In ru, this message translates to:
  /// **'Авто (лучшее доступное)'**
  String get qualityAuto;

  /// No description provided for @qualityLow.
  ///
  /// In ru, this message translates to:
  /// **'Экономное'**
  String get qualityLow;

  /// No description provided for @qualityNormal.
  ///
  /// In ru, this message translates to:
  /// **'Среднее'**
  String get qualityNormal;

  /// No description provided for @qualityHigh.
  ///
  /// In ru, this message translates to:
  /// **'Высокое'**
  String get qualityHigh;

  /// No description provided for @qualityLossless.
  ///
  /// In ru, this message translates to:
  /// **'Без потерь'**
  String get qualityLossless;

  /// No description provided for @settingsPriority.
  ///
  /// In ru, this message translates to:
  /// **'Приоритет источников'**
  String get settingsPriority;

  /// No description provided for @settingsPriorityNote.
  ///
  /// In ru, this message translates to:
  /// **'Если трек не игрится, плеер идёт к следующему по списку'**
  String get settingsPriorityNote;

  /// No description provided for @roleStream.
  ///
  /// In ru, this message translates to:
  /// **'воспроизводит'**
  String get roleStream;

  /// No description provided for @roleCatalog.
  ///
  /// In ru, this message translates to:
  /// **'только каталог'**
  String get roleCatalog;

  /// No description provided for @roleAbsent.
  ///
  /// In ru, this message translates to:
  /// **'не подключён'**
  String get roleAbsent;

  /// No description provided for @settingsFrame.
  ///
  /// In ru, this message translates to:
  /// **'Частота кадров'**
  String get settingsFrame;

  /// No description provided for @frameSystem.
  ///
  /// In ru, this message translates to:
  /// **'Как в системе'**
  String get frameSystem;

  /// No description provided for @frame120.
  ///
  /// In ru, this message translates to:
  /// **'120 Гц'**
  String get frame120;

  /// No description provided for @frame90.
  ///
  /// In ru, this message translates to:
  /// **'90 Гц'**
  String get frame90;

  /// No description provided for @frame60.
  ///
  /// In ru, this message translates to:
  /// **'60 Гц'**
  String get frame60;

  /// No description provided for @settingsStorage.
  ///
  /// In ru, this message translates to:
  /// **'Хранилище'**
  String get settingsStorage;

  /// No description provided for @settingsCache.
  ///
  /// In ru, this message translates to:
  /// **'Кэш обложек'**
  String get settingsCache;

  /// No description provided for @settingsCacheClear.
  ///
  /// In ru, this message translates to:
  /// **'Очистить кэш'**
  String get settingsCacheClear;

  /// No description provided for @settingsCacheCleared.
  ///
  /// In ru, this message translates to:
  /// **'Кэш обложек очищен'**
  String get settingsCacheCleared;

  /// No description provided for @settingsData.
  ///
  /// In ru, this message translates to:
  /// **'Данные'**
  String get settingsData;

  /// No description provided for @settingsRows.
  ///
  /// In ru, this message translates to:
  /// **'Строк в базе: {count}'**
  String settingsRows(int count);

  /// No description provided for @settingsSchema.
  ///
  /// In ru, this message translates to:
  /// **'Схема БД: v{version}'**
  String settingsSchema(int version);

  /// No description provided for @settingsLogs.
  ///
  /// In ru, this message translates to:
  /// **'Журнал событий'**
  String get settingsLogs;

  /// No description provided for @settingsAccount.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт'**
  String get settingsAccount;

  /// No description provided for @settingsSignOut.
  ///
  /// In ru, this message translates to:
  /// **'Выйти из Яндекса'**
  String get settingsSignOut;

  /// No description provided for @accountPlus.
  ///
  /// In ru, this message translates to:
  /// **'Подписка активна'**
  String get accountPlus;

  /// No description provided for @accountFree.
  ///
  /// In ru, this message translates to:
  /// **'Без подписки'**
  String get accountFree;

  /// No description provided for @settingsSignedOut.
  ///
  /// In ru, this message translates to:
  /// **'Вышли из Яндекса'**
  String get settingsSignedOut;

  /// No description provided for @settingsAbout.
  ///
  /// In ru, this message translates to:
  /// **'О приложении'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In ru, this message translates to:
  /// **'Версия {version}'**
  String settingsVersion(String version);

  /// No description provided for @settingsAboutNote.
  ///
  /// In ru, this message translates to:
  /// **'Локальный плеер: Яндекс, YouTube и свои файлы в одном интерфейсе.'**
  String get settingsAboutNote;

  /// No description provided for @aboutSources.
  ///
  /// In ru, this message translates to:
  /// **'Источники'**
  String get aboutSources;

  /// No description provided for @aboutSourcesNote.
  ///
  /// In ru, this message translates to:
  /// **'Яндекс Музыка — каталог, поток и волна; YouTube — поиск и поток; локальные файлы из папки Music. Тексты: LRCLIB, официальный текст Яндекса и lyrics.ovh.'**
  String get aboutSourcesNote;

  /// No description provided for @settingsAiFilterSource.
  ///
  /// In ru, this message translates to:
  /// **'ИИ-фильтр: Slopless'**
  String get settingsAiFilterSource;

  /// No description provided for @settingsCensorSource.
  ///
  /// In ru, this message translates to:
  /// **'Версии без цензуры: FckCensorData'**
  String get settingsCensorSource;

  /// No description provided for @authTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вход в Яндекс'**
  String get authTitle;

  /// No description provided for @authCodeHint.
  ///
  /// In ru, this message translates to:
  /// **'Код подтверждения'**
  String get authCodeHint;

  /// No description provided for @authCopyCode.
  ///
  /// In ru, this message translates to:
  /// **'Копировать код'**
  String get authCopyCode;

  /// No description provided for @authCopied.
  ///
  /// In ru, this message translates to:
  /// **'Код скопирован'**
  String get authCopied;

  /// No description provided for @authOpenLink.
  ///
  /// In ru, this message translates to:
  /// **'Перейти'**
  String get authOpenLink;

  /// No description provided for @authWaiting.
  ///
  /// In ru, this message translates to:
  /// **'Ждём подтверждения в браузере…'**
  String get authWaiting;

  /// No description provided for @authDone.
  ///
  /// In ru, this message translates to:
  /// **'Вы вошли как {name}'**
  String authDone(String name);

  /// No description provided for @authFailed.
  ///
  /// In ru, this message translates to:
  /// **'Вход не завершился: {error}'**
  String authFailed(String error);

  /// No description provided for @authExpired.
  ///
  /// In ru, this message translates to:
  /// **'Код истёк, начните вход заново'**
  String get authExpired;

  /// No description provided for @authNotSignedIn.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт Яндекс не подключён'**
  String get authNotSignedIn;

  /// No description provided for @authNotBuilt.
  ///
  /// In ru, this message translates to:
  /// **'Яндекс не собран в этом приложении'**
  String get authNotBuilt;

  /// No description provided for @authRequestingCode.
  ///
  /// In ru, this message translates to:
  /// **'Запрашиваем код…'**
  String get authRequestingCode;

  /// No description provided for @authCodeIntro.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердите вход на странице Яндекса. Код уже подставлен в ссылку, осталось нажать «Разрешить».'**
  String get authCodeIntro;

  /// No description provided for @authOpenPage.
  ///
  /// In ru, this message translates to:
  /// **'Перейти на страницу Яндекса'**
  String get authOpenPage;

  /// No description provided for @authWaitingCode.
  ///
  /// In ru, this message translates to:
  /// **'Ждём подтверждения. Код живёт ~5 минут.'**
  String get authWaitingCode;

  /// No description provided for @authNotConfirmed.
  ///
  /// In ru, this message translates to:
  /// **'Вход не подтверждён — нажми «Начать заново»'**
  String get authNotConfirmed;

  /// No description provided for @authBrowserFailed.
  ///
  /// In ru, this message translates to:
  /// **'Браузер не открылся: {url}'**
  String authBrowserFailed(String url);

  /// No description provided for @authRetry.
  ///
  /// In ru, this message translates to:
  /// **'Начать заново'**
  String get authRetry;

  /// No description provided for @authSignOut.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get authSignOut;

  /// No description provided for @authCodeCopied.
  ///
  /// In ru, this message translates to:
  /// **'Код {code} скопирован'**
  String authCodeCopied(String code);

  /// No description provided for @issueHeadline.
  ///
  /// In ru, this message translates to:
  /// **'Трек не игрится'**
  String get issueHeadline;

  /// No description provided for @issueNeedsLogin.
  ///
  /// In ru, this message translates to:
  /// **'Нужен вход в источник'**
  String get issueNeedsLogin;

  /// No description provided for @issueNeedsPlus.
  ///
  /// In ru, this message translates to:
  /// **'Нужна подписка источника'**
  String get issueNeedsPlus;

  /// No description provided for @issueGeo.
  ///
  /// In ru, this message translates to:
  /// **'Трек недоступен в вашем регионе'**
  String get issueGeo;

  /// No description provided for @issueUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Трека нет в каталоге'**
  String get issueUnavailable;

  /// No description provided for @issueNetwork.
  ///
  /// In ru, this message translates to:
  /// **'Проблема с сетью'**
  String get issueNetwork;

  /// No description provided for @issueThrottled.
  ///
  /// In ru, this message translates to:
  /// **'Источник ограничил частоту запросов'**
  String get issueThrottled;

  /// No description provided for @issueSignature.
  ///
  /// In ru, this message translates to:
  /// **'Подпись потока не прошла'**
  String get issueSignature;

  /// No description provided for @issueExhausted.
  ///
  /// In ru, this message translates to:
  /// **'Все источники отказали'**
  String get issueExhausted;

  /// No description provided for @issueUnknown.
  ///
  /// In ru, this message translates to:
  /// **'Неизвестная ошибка'**
  String get issueUnknown;

  /// No description provided for @toastQueueStarted.
  ///
  /// In ru, this message translates to:
  /// **'Играет: {title}'**
  String toastQueueStarted(String title);

  /// No description provided for @dbError.
  ///
  /// In ru, this message translates to:
  /// **'База не ответила: {error}'**
  String dbError(String error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
