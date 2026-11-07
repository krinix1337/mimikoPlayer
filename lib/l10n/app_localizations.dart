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

  /// No description provided for @commonTrackCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} трек} few{{count} трека} many{{count} треков} other{{count} трека}}'**
  String commonTrackCount(int count);

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

  /// No description provided for @feedbackDislike.
  ///
  /// In ru, this message translates to:
  /// **'Не нравится'**
  String get feedbackDislike;

  /// No description provided for @feedbackUndislike.
  ///
  /// In ru, this message translates to:
  /// **'Убрать из «Нелюбимого»'**
  String get feedbackUndislike;

  /// No description provided for @feedbackDislikeAdded.
  ///
  /// In ru, this message translates to:
  /// **'Добавлено в «Нелюбимое»'**
  String get feedbackDislikeAdded;

  /// No description provided for @feedbackCleared.
  ///
  /// In ru, this message translates to:
  /// **'Отметка снята'**
  String get feedbackCleared;

  /// No description provided for @feedbackLocalOnly.
  ///
  /// In ru, this message translates to:
  /// **'только на устройстве'**
  String get feedbackLocalOnly;

  /// No description provided for @playlistCreate.
  ///
  /// In ru, this message translates to:
  /// **'Новый плейлист'**
  String get playlistCreate;

  /// No description provided for @playlistName.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get playlistName;

  /// No description provided for @playlistNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Например, для дороги'**
  String get playlistNameHint;

  /// No description provided for @playlistVisibility.
  ///
  /// In ru, this message translates to:
  /// **'Кто увидит'**
  String get playlistVisibility;

  /// No description provided for @playlistPublic.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get playlistPublic;

  /// No description provided for @playlistPrivate.
  ///
  /// In ru, this message translates to:
  /// **'Только я'**
  String get playlistPrivate;

  /// No description provided for @playlistCreateAction.
  ///
  /// In ru, this message translates to:
  /// **'Создать плейлист'**
  String get playlistCreateAction;

  /// No description provided for @playlistCreated.
  ///
  /// In ru, this message translates to:
  /// **'Плейлист «{title}» создан'**
  String playlistCreated(String title);

  /// No description provided for @playlistCreateFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось создать плейлист'**
  String get playlistCreateFailed;

  /// No description provided for @importTitle.
  ///
  /// In ru, this message translates to:
  /// **'Импорт'**
  String get importTitle;

  /// No description provided for @importTileSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Списки треков и другие площадки'**
  String get importTileSubtitle;

  /// No description provided for @importHeroTitle.
  ///
  /// In ru, this message translates to:
  /// **'Перенос музыки'**
  String get importHeroTitle;

  /// No description provided for @importHeroNote.
  ///
  /// In ru, this message translates to:
  /// **'Вставьте список «Исполнитель - Название» — треки найдутся в Яндексе и сохранятся в локальный плейлист.'**
  String get importHeroNote;

  /// No description provided for @importHeroStatus.
  ///
  /// In ru, this message translates to:
  /// **'Доступен импорт из списка'**
  String get importHeroStatus;

  /// No description provided for @importMatched.
  ///
  /// In ru, this message translates to:
  /// **'{matched} найдено, {skipped} пропущено'**
  String importMatched(int matched, int skipped);

  /// No description provided for @importDone.
  ///
  /// In ru, this message translates to:
  /// **'Готово. Треков: {matched}, пропущено: {skipped}, плейлистов: {playlists}'**
  String importDone(int matched, int skipped, int playlists);

  /// No description provided for @importYandexRequired.
  ///
  /// In ru, this message translates to:
  /// **'Сначала войдите в Яндекс Музыку'**
  String get importYandexRequired;

  /// No description provided for @importFailed.
  ///
  /// In ru, this message translates to:
  /// **'Импорт прервался'**
  String get importFailed;

  /// No description provided for @importOther.
  ///
  /// In ru, this message translates to:
  /// **'Другие площадки'**
  String get importOther;

  /// No description provided for @importList.
  ///
  /// In ru, this message translates to:
  /// **'Импорт из списка'**
  String get importList;

  /// No description provided for @importListTitle.
  ///
  /// In ru, this message translates to:
  /// **'Название плейлиста'**
  String get importListTitle;

  /// No description provided for @importListLines.
  ///
  /// In ru, this message translates to:
  /// **'Треки'**
  String get importListLines;

  /// No description provided for @importListHint.
  ///
  /// In ru, this message translates to:
  /// **'Исполнитель - Название\nИсполнитель - Название'**
  String get importListHint;

  /// No description provided for @importLinkLabel.
  ///
  /// In ru, this message translates to:
  /// **'Ссылка на открытый плейлист'**
  String get importLinkLabel;

  /// No description provided for @importLinkHint.
  ///
  /// In ru, this message translates to:
  /// **'Spotify, SoundCloud или Яндекс Музыка'**
  String get importLinkHint;

  /// No description provided for @importLinkFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось прочитать плейлист по ссылке'**
  String get importLinkFailed;

  /// No description provided for @importLinkTitle.
  ///
  /// In ru, this message translates to:
  /// **'Импорт по ссылке'**
  String get importLinkTitle;

  /// No description provided for @importLinkNote.
  ///
  /// In ru, this message translates to:
  /// **'Треки найдутся в Яндексе и сложатся в новый плейлист. Плейлист Яндекса просто откроется.'**
  String get importLinkNote;

  /// No description provided for @importListFormat.
  ///
  /// In ru, this message translates to:
  /// **'Одна строка — один трек, формат «Исполнитель - Название». Первые 300 строк.'**
  String get importListFormat;

  /// No description provided for @importListAction.
  ///
  /// In ru, this message translates to:
  /// **'Перенести в плейлист'**
  String get importListAction;

  /// No description provided for @importListEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Вставьте хотя бы одну строку'**
  String get importListEmpty;

  /// No description provided for @importOtherYandex.
  ///
  /// In ru, this message translates to:
  /// **'Плейлист по ссылке откроется в приложении'**
  String get importOtherYandex;

  /// No description provided for @importOtherSoundCloud.
  ///
  /// In ru, this message translates to:
  /// **'Поиск и поток без переноса'**
  String get importOtherSoundCloud;

  /// No description provided for @waveSettingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Настройки волны'**
  String get waveSettingsTitle;

  /// No description provided for @waveClose.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get waveClose;

  /// No description provided for @waveModeSoundCloud.
  ///
  /// In ru, this message translates to:
  /// **'SoundCloud'**
  String get waveModeSoundCloud;

  /// No description provided for @waveRejectedNote.
  ///
  /// In ru, this message translates to:
  /// **'Яндекс не принял настройки — смотри лог'**
  String get waveRejectedNote;

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

  /// No description provided for @chartSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Популярное в России прямо сейчас'**
  String get chartSubtitle;

  /// No description provided for @artistOpen.
  ///
  /// In ru, this message translates to:
  /// **'К исполнителю'**
  String get artistOpen;

  /// No description provided for @artistAllTracks.
  ///
  /// In ru, this message translates to:
  /// **'Все треки'**
  String get artistAllTracks;

  /// No description provided for @artistPopularTracks.
  ///
  /// In ru, this message translates to:
  /// **'Популярные треки'**
  String get artistPopularTracks;

  /// No description provided for @artistAllAlbums.
  ///
  /// In ru, this message translates to:
  /// **'Все альбомы'**
  String get artistAllAlbums;

  /// No description provided for @artistPhoto.
  ///
  /// In ru, this message translates to:
  /// **'Фото артиста'**
  String get artistPhoto;

  /// No description provided for @trackDownloaded.
  ///
  /// In ru, this message translates to:
  /// **'Скачано'**
  String get trackDownloaded;

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

  /// No description provided for @collectionDownloadAllLikes.
  ///
  /// In ru, this message translates to:
  /// **'Скачать все треки'**
  String get collectionDownloadAllLikes;

  /// No description provided for @collectionShare.
  ///
  /// In ru, this message translates to:
  /// **'Поделиться'**
  String get collectionShare;

  /// No description provided for @playlistNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось открыть плейлист. Проверьте ссылку.'**
  String get playlistNotFound;

  /// No description provided for @menuAddToPlaylist.
  ///
  /// In ru, this message translates to:
  /// **'Добавить в плейлист'**
  String get menuAddToPlaylist;

  /// No description provided for @addToPlaylistDone.
  ///
  /// In ru, this message translates to:
  /// **'Добавлено в «{title}»'**
  String addToPlaylistDone(String title);

  /// No description provided for @addToPlaylistFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось добавить трек в плейлист'**
  String get addToPlaylistFailed;

  /// No description provided for @addToPlaylistEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Своих плейлистов пока нет'**
  String get addToPlaylistEmpty;

  /// No description provided for @collectionDownloadQueued.
  ///
  /// In ru, this message translates to:
  /// **'В очереди на загрузку: {count}'**
  String collectionDownloadQueued(int count);

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

  /// No description provided for @settingsCrossfade.
  ///
  /// In ru, this message translates to:
  /// **'Кроссфейд'**
  String get settingsCrossfade;

  /// No description provided for @settingsCrossfadeNote.
  ///
  /// In ru, this message translates to:
  /// **'Следующий трек начинается ещё до конца текущего и плавно сводится с ним. Не действует при ручном переключении и повторе одного трека.'**
  String get settingsCrossfadeNote;

  /// No description provided for @crossfadeOff.
  ///
  /// In ru, this message translates to:
  /// **'Выкл'**
  String get crossfadeOff;

  /// No description provided for @crossfadeSecondsValue.
  ///
  /// In ru, this message translates to:
  /// **'{seconds} с'**
  String crossfadeSecondsValue(int seconds);

  /// No description provided for @playlistTarget.
  ///
  /// In ru, this message translates to:
  /// **'Где создать'**
  String get playlistTarget;

  /// No description provided for @playlistTargetYandex.
  ///
  /// In ru, this message translates to:
  /// **'Яндекс Музыка'**
  String get playlistTargetYandex;

  /// No description provided for @playlistTargetDevice.
  ///
  /// In ru, this message translates to:
  /// **'На устройстве'**
  String get playlistTargetDevice;

  /// No description provided for @playlistDeviceNote.
  ///
  /// In ru, this message translates to:
  /// **'Плейлист останется на этом телефоне — в него можно добавлять и файлы из памяти.'**
  String get playlistDeviceNote;

  /// No description provided for @playlistCoverRemove.
  ///
  /// In ru, this message translates to:
  /// **'Убрать обложку'**
  String get playlistCoverRemove;

  /// No description provided for @playlistCoverChange.
  ///
  /// In ru, this message translates to:
  /// **'Изменить обложку'**
  String get playlistCoverChange;

  /// No description provided for @playlistDeleteLocal.
  ///
  /// In ru, this message translates to:
  /// **'Удалить плейлист'**
  String get playlistDeleteLocal;

  /// No description provided for @playlistDeleteConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Удалить «{title}»? Сами треки в приложении останутся.'**
  String playlistDeleteConfirm(String title);

  /// No description provided for @playlistDeleted.
  ///
  /// In ru, this message translates to:
  /// **'Плейлист удалён'**
  String get playlistDeleted;

  /// No description provided for @commonDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get commonDelete;

  /// No description provided for @artistBlock.
  ///
  /// In ru, this message translates to:
  /// **'Не рекомендовать исполнителя'**
  String get artistBlock;

  /// No description provided for @artistUnblock.
  ///
  /// In ru, this message translates to:
  /// **'Снова рекомендовать исполнителя'**
  String get artistUnblock;

  /// No description provided for @artistBlockedDone.
  ///
  /// In ru, this message translates to:
  /// **'«{name}» больше не будет попадаться'**
  String artistBlockedDone(String name);

  /// No description provided for @artistUnblockedDone.
  ///
  /// In ru, this message translates to:
  /// **'«{name}» снова в рекомендациях'**
  String artistUnblockedDone(String name);

  /// No description provided for @settingsBlockedArtists.
  ///
  /// In ru, this message translates to:
  /// **'Заблокированные исполнители'**
  String get settingsBlockedArtists;

  /// No description provided for @settingsBlockedArtistsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Список пуст. Заблокировать исполнителя можно на его странице или в меню трека.'**
  String get settingsBlockedArtistsEmpty;

  /// No description provided for @settingsBlockedArtistsCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} исполнитель} few{{count} исполнителя} many{{count} исполнителей} other{{count} исполнителя}}'**
  String settingsBlockedArtistsCount(int count);

  /// No description provided for @artistListeners.
  ///
  /// In ru, this message translates to:
  /// **'{count} слушателей'**
  String artistListeners(String count);

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

  /// No description provided for @searchTracks.
  ///
  /// In ru, this message translates to:
  /// **'Треки'**
  String get searchTracks;

  /// No description provided for @searchArtists.
  ///
  /// In ru, this message translates to:
  /// **'Исполнители'**
  String get searchArtists;

  /// No description provided for @searchAlbums.
  ///
  /// In ru, this message translates to:
  /// **'Альбомы'**
  String get searchAlbums;

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

  /// No description provided for @appearanceThemeLanguage.
  ///
  /// In ru, this message translates to:
  /// **'Тема и язык'**
  String get appearanceThemeLanguage;

  /// No description provided for @appearanceShapeMotion.
  ///
  /// In ru, this message translates to:
  /// **'Форма и движение'**
  String get appearanceShapeMotion;

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

  /// No description provided for @paletteAmoled.
  ///
  /// In ru, this message translates to:
  /// **'AMOLED'**
  String get paletteAmoled;

  /// No description provided for @paletteDynamicNote.
  ///
  /// In ru, this message translates to:
  /// **'Material You доступно на Android 12 и новее'**
  String get paletteDynamicNote;

  /// No description provided for @paletteAmoledNote.
  ///
  /// In ru, this message translates to:
  /// **'Чистый чёрный фон: на OLED пиксели гаснут, батарея держит дольше'**
  String get paletteAmoledNote;

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

  /// No description provided for @accentOrchid.
  ///
  /// In ru, this message translates to:
  /// **'Орхидея'**
  String get accentOrchid;

  /// No description provided for @launcherForest.
  ///
  /// In ru, this message translates to:
  /// **'Лес'**
  String get launcherForest;

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

  /// No description provided for @settingsBlur.
  ///
  /// In ru, this message translates to:
  /// **'Размытие'**
  String get settingsBlur;

  /// No description provided for @blurBottom.
  ///
  /// In ru, this message translates to:
  /// **'Нижняя панель и мини-плеер'**
  String get blurBottom;

  /// No description provided for @blurTop.
  ///
  /// In ru, this message translates to:
  /// **'Верхние панели'**
  String get blurTop;

  /// No description provided for @blurCovers.
  ///
  /// In ru, this message translates to:
  /// **'Фоновые обложки'**
  String get blurCovers;

  /// No description provided for @blurOff.
  ///
  /// In ru, this message translates to:
  /// **'Выкл'**
  String get blurOff;

  /// No description provided for @blurSoft.
  ///
  /// In ru, this message translates to:
  /// **'Мягкое'**
  String get blurSoft;

  /// No description provided for @blurMedium.
  ///
  /// In ru, this message translates to:
  /// **'Среднее'**
  String get blurMedium;

  /// No description provided for @blurStrong.
  ///
  /// In ru, this message translates to:
  /// **'Сильное'**
  String get blurStrong;

  /// No description provided for @blurBottomNote.
  ///
  /// In ru, this message translates to:
  /// **'Стекло под пилюлями: видно, что список продолжается'**
  String get blurBottomNote;

  /// No description provided for @blurTopNote.
  ///
  /// In ru, this message translates to:
  /// **'Панели с кнопками «назад» на страницах с обложкой'**
  String get blurTopNote;

  /// No description provided for @blurCoversNote.
  ///
  /// In ru, this message translates to:
  /// **'Сила размытия фоновых обложек на всех экранах'**
  String get blurCoversNote;

  /// No description provided for @blurPerformanceNote.
  ///
  /// In ru, this message translates to:
  /// **'Во время прокрутки стекло становится плотнее и не размывает фон заново, а фоновые обложки размываются в уменьшенном размере. Так плавнее на бюджетных телефонах.'**
  String get blurPerformanceNote;

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

  /// No description provided for @settingsEqualizer.
  ///
  /// In ru, this message translates to:
  /// **'Эквалайзер'**
  String get settingsEqualizer;

  /// No description provided for @equalizerEnabled.
  ///
  /// In ru, this message translates to:
  /// **'Включить эквалайзер'**
  String get equalizerEnabled;

  /// No description provided for @equalizerNote.
  ///
  /// In ru, this message translates to:
  /// **'Пресет применяется к текущему воспроизведению сразу.'**
  String get equalizerNote;

  /// No description provided for @equalizerPreset.
  ///
  /// In ru, this message translates to:
  /// **'Пресет'**
  String get equalizerPreset;

  /// No description provided for @equalizerTune.
  ///
  /// In ru, this message translates to:
  /// **'Настроить'**
  String get equalizerTune;

  /// No description provided for @equalizerCustom.
  ///
  /// In ru, this message translates to:
  /// **'Своя настройка'**
  String get equalizerCustom;

  /// No description provided for @equalizerLevel.
  ///
  /// In ru, this message translates to:
  /// **'ур.'**
  String get equalizerLevel;

  /// No description provided for @eqPresetFlat.
  ///
  /// In ru, this message translates to:
  /// **'Ровный'**
  String get eqPresetFlat;

  /// No description provided for @eqPresetBass.
  ///
  /// In ru, this message translates to:
  /// **'Бас'**
  String get eqPresetBass;

  /// No description provided for @eqPresetTreble.
  ///
  /// In ru, this message translates to:
  /// **'Верх'**
  String get eqPresetTreble;

  /// No description provided for @eqPresetRock.
  ///
  /// In ru, this message translates to:
  /// **'Рок'**
  String get eqPresetRock;

  /// No description provided for @eqPresetElectronic.
  ///
  /// In ru, this message translates to:
  /// **'Электро'**
  String get eqPresetElectronic;

  /// No description provided for @eqPresetPop.
  ///
  /// In ru, this message translates to:
  /// **'Поп'**
  String get eqPresetPop;

  /// No description provided for @eqPresetVocal.
  ///
  /// In ru, this message translates to:
  /// **'Вокал'**
  String get eqPresetVocal;

  /// No description provided for @eqPresetAcoustic.
  ///
  /// In ru, this message translates to:
  /// **'Акустика'**
  String get eqPresetAcoustic;

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
  /// **'Тексты: LRCLIB, Musixmatch, NetEase'**
  String get settingsLyricsSource;

  /// No description provided for @settingsLyricsSourceNote.
  ///
  /// In ru, this message translates to:
  /// **'Тайминги строк ищутся по очереди в LRCLIB, Musixmatch и NetEase; если их нет — официальный текст Яндекса.'**
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

  /// No description provided for @updatesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Обновления'**
  String get updatesTitle;

  /// No description provided for @updatesTileSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Приватные релизы GitHub'**
  String get updatesTileSubtitle;

  /// No description provided for @updatesCheckShort.
  ///
  /// In ru, this message translates to:
  /// **'Проверить'**
  String get updatesCheckShort;

  /// No description provided for @updatesChecking.
  ///
  /// In ru, this message translates to:
  /// **'Проверяю релизы…'**
  String get updatesChecking;

  /// No description provided for @updatesUpToDate.
  ///
  /// In ru, this message translates to:
  /// **'Установлена последняя версия'**
  String get updatesUpToDate;

  /// No description provided for @updatesNotChecked.
  ///
  /// In ru, this message translates to:
  /// **'Обновления ещё не проверялись'**
  String get updatesNotChecked;

  /// No description provided for @updatesReleases.
  ///
  /// In ru, this message translates to:
  /// **'Релизы'**
  String get updatesReleases;

  /// No description provided for @updatesLatestRelease.
  ///
  /// In ru, this message translates to:
  /// **'Последний релиз на GitHub: {version}'**
  String updatesLatestRelease(String version);

  /// No description provided for @updatesWhatsNew.
  ///
  /// In ru, this message translates to:
  /// **'Что нового в {version}'**
  String updatesWhatsNew(String version);

  /// No description provided for @updatesOpenGithub.
  ///
  /// In ru, this message translates to:
  /// **'Открыть релиз на GitHub'**
  String get updatesOpenGithub;

  /// No description provided for @updatesAvailable.
  ///
  /// In ru, this message translates to:
  /// **'Доступна версия {version}'**
  String updatesAvailable(String version);

  /// No description provided for @updatesSize.
  ///
  /// In ru, this message translates to:
  /// **'{size} МБ'**
  String updatesSize(String size);

  /// No description provided for @updatesDownload.
  ///
  /// In ru, this message translates to:
  /// **'Скачать и установить'**
  String get updatesDownload;

  /// No description provided for @updatesDownloading.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка: {percent}%'**
  String updatesDownloading(int percent);

  /// No description provided for @updatesCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отменить'**
  String get updatesCancel;

  /// No description provided for @updatesOpeningInstaller.
  ///
  /// In ru, this message translates to:
  /// **'Открываю установщик…'**
  String get updatesOpeningInstaller;

  /// No description provided for @updatesInstallPermission.
  ///
  /// In ru, this message translates to:
  /// **'Разреши установку из этого приложения и нажми ещё раз'**
  String get updatesInstallPermission;

  /// No description provided for @updatesErrorUnauthorized.
  ///
  /// In ru, this message translates to:
  /// **'GitHub временно ограничил запросы, попробуй позже'**
  String get updatesErrorUnauthorized;

  /// No description provided for @updatesErrorNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Релизы пока недоступны'**
  String get updatesErrorNotFound;

  /// No description provided for @updatesErrorNoAsset.
  ///
  /// In ru, this message translates to:
  /// **'В последнем релизе нет APK'**
  String get updatesErrorNoAsset;

  /// No description provided for @updatesErrorNoDigest.
  ///
  /// In ru, this message translates to:
  /// **'У релиза нет SHA-256, скачивание отменено'**
  String get updatesErrorNoDigest;

  /// No description provided for @updatesErrorChecksum.
  ///
  /// In ru, this message translates to:
  /// **'Контрольная сумма не совпала, файл удалён'**
  String get updatesErrorChecksum;

  /// No description provided for @updatesErrorNetwork.
  ///
  /// In ru, this message translates to:
  /// **'Нет связи с GitHub'**
  String get updatesErrorNetwork;

  /// No description provided for @updatesErrorUnknown.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось проверить обновления'**
  String get updatesErrorUnknown;

  /// No description provided for @updatesReady.
  ///
  /// In ru, this message translates to:
  /// **'Файл скачан и проверен'**
  String get updatesReady;

  /// No description provided for @updatesInstall.
  ///
  /// In ru, this message translates to:
  /// **'Установить'**
  String get updatesInstall;

  /// No description provided for @settingsAboutNote.
  ///
  /// In ru, this message translates to:
  /// **'Локальный плеер: Яндекс Музыка, SoundCloud и свои файлы в одном интерфейсе.'**
  String get settingsAboutNote;

  /// No description provided for @aboutSources.
  ///
  /// In ru, this message translates to:
  /// **'Источники'**
  String get aboutSources;

  /// No description provided for @aboutSourcesNote.
  ///
  /// In ru, this message translates to:
  /// **'Яндекс Музыка — каталог, поток и волна; SoundCloud — поиск и поток; локальные файлы из папки Music. Тексты: LRCLIB, Musixmatch, NetEase, официальный текст Яндекса и lyrics.ovh.'**
  String get aboutSourcesNote;

  /// No description provided for @settingsAiFilter.
  ///
  /// In ru, this message translates to:
  /// **'ИИ-фильтр'**
  String get settingsAiFilter;

  /// No description provided for @accountConnected.
  ///
  /// In ru, this message translates to:
  /// **'Подключено'**
  String get accountConnected;

  /// No description provided for @accountSignOut.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get accountSignOut;

  /// No description provided for @accountServices.
  ///
  /// In ru, this message translates to:
  /// **'Сервисы'**
  String get accountServices;

  /// No description provided for @accountSoundCloudNote.
  ///
  /// In ru, this message translates to:
  /// **'Поиск и поток без входа'**
  String get accountSoundCloudNote;

  /// No description provided for @aboutYandexNote.
  ///
  /// In ru, this message translates to:
  /// **'Каталог, поток, волна и рекомендации'**
  String get aboutYandexNote;

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

  /// No description provided for @navDiscover.
  ///
  /// In ru, this message translates to:
  /// **'Обзор'**
  String get navDiscover;

  /// No description provided for @discoverTitle.
  ///
  /// In ru, this message translates to:
  /// **'Что послушать'**
  String get discoverTitle;

  /// No description provided for @discoverChart.
  ///
  /// In ru, this message translates to:
  /// **'Чарт'**
  String get discoverChart;

  /// No description provided for @discoverNewReleases.
  ///
  /// In ru, this message translates to:
  /// **'Новые релизы'**
  String get discoverNewReleases;

  /// No description provided for @discoverStations.
  ///
  /// In ru, this message translates to:
  /// **'Жанры и настроения'**
  String get discoverStations;

  /// No description provided for @discoverArtists.
  ///
  /// In ru, this message translates to:
  /// **'Твои артисты'**
  String get discoverArtists;

  /// No description provided for @discoverAll.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get discoverAll;

  /// No description provided for @searchHistoryTitle.
  ///
  /// In ru, this message translates to:
  /// **'История поиска'**
  String get searchHistoryTitle;

  /// No description provided for @searchHistoryClear.
  ///
  /// In ru, this message translates to:
  /// **'Очистить'**
  String get searchHistoryClear;

  /// No description provided for @waveListen.
  ///
  /// In ru, this message translates to:
  /// **'Слушать'**
  String get waveListen;

  /// No description provided for @waveWheelHint.
  ///
  /// In ru, this message translates to:
  /// **'Крути и выбирай режим'**
  String get waveWheelHint;

  /// No description provided for @waveBackToUsual.
  ///
  /// In ru, this message translates to:
  /// **'Обычная волна'**
  String get waveBackToUsual;

  /// No description provided for @moodEnergyActive.
  ///
  /// In ru, this message translates to:
  /// **'Бодрое'**
  String get moodEnergyActive;

  /// No description provided for @moodEnergyFun.
  ///
  /// In ru, this message translates to:
  /// **'Весёлое'**
  String get moodEnergyFun;

  /// No description provided for @moodEnergyCalm.
  ///
  /// In ru, this message translates to:
  /// **'Спокойное'**
  String get moodEnergyCalm;

  /// No description provided for @moodEnergySad.
  ///
  /// In ru, this message translates to:
  /// **'Грустное'**
  String get moodEnergySad;

  /// No description provided for @diversityFavorite.
  ///
  /// In ru, this message translates to:
  /// **'Любимое'**
  String get diversityFavorite;

  /// No description provided for @diversityDiscover.
  ///
  /// In ru, this message translates to:
  /// **'Незнакомое'**
  String get diversityDiscover;

  /// No description provided for @diversityPopular.
  ///
  /// In ru, this message translates to:
  /// **'Популярное'**
  String get diversityPopular;

  /// No description provided for @languageRussian.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get languageRussian;

  /// No description provided for @languageForeign.
  ///
  /// In ru, this message translates to:
  /// **'Иностранный'**
  String get languageForeign;

  /// No description provided for @languageInstrumental.
  ///
  /// In ru, this message translates to:
  /// **'Без слов'**
  String get languageInstrumental;

  /// No description provided for @homeCoverTone.
  ///
  /// In ru, this message translates to:
  /// **'Тон обложки'**
  String get homeCoverTone;

  /// No description provided for @homeCoverDarker.
  ///
  /// In ru, this message translates to:
  /// **'Темнее'**
  String get homeCoverDarker;

  /// No description provided for @homeCoverNormal.
  ///
  /// In ru, this message translates to:
  /// **'Обычная'**
  String get homeCoverNormal;

  /// No description provided for @homeCoverLighter.
  ///
  /// In ru, this message translates to:
  /// **'Светлее'**
  String get homeCoverLighter;

  /// No description provided for @settingsOpenPlayer.
  ///
  /// In ru, this message translates to:
  /// **'Открывать плеер при запуске'**
  String get settingsOpenPlayer;

  /// No description provided for @settingsOpenPlayerNote.
  ///
  /// In ru, this message translates to:
  /// **'Выключено — трек играет в мини-плеере, полный плеер открывается тапом по нему'**
  String get settingsOpenPlayerNote;

  /// No description provided for @trackUnknownArtist.
  ///
  /// In ru, this message translates to:
  /// **'Неизвестный исполнитель'**
  String get trackUnknownArtist;

  /// No description provided for @badgeExplicit.
  ///
  /// In ru, this message translates to:
  /// **'18+'**
  String get badgeExplicit;

  /// No description provided for @badgeAi.
  ///
  /// In ru, this message translates to:
  /// **'ИИ'**
  String get badgeAi;

  /// No description provided for @badgeUncensored.
  ///
  /// In ru, this message translates to:
  /// **'Без цензуры'**
  String get badgeUncensored;

  /// No description provided for @sourceYandex.
  ///
  /// In ru, this message translates to:
  /// **'Яндекс Музыка'**
  String get sourceYandex;

  /// No description provided for @sourceRemoved.
  ///
  /// In ru, this message translates to:
  /// **'Источник удалён'**
  String get sourceRemoved;

  /// No description provided for @sourceLocalFile.
  ///
  /// In ru, this message translates to:
  /// **'Файл'**
  String get sourceLocalFile;

  /// No description provided for @detailsSource.
  ///
  /// In ru, this message translates to:
  /// **'Источник'**
  String get detailsSource;

  /// No description provided for @detailsSources.
  ///
  /// In ru, this message translates to:
  /// **'Источники'**
  String get detailsSources;

  /// No description provided for @detailsAlbum.
  ///
  /// In ru, this message translates to:
  /// **'Альбом'**
  String get detailsAlbum;

  /// No description provided for @detailsYear.
  ///
  /// In ru, this message translates to:
  /// **'Год'**
  String get detailsYear;

  /// No description provided for @detailsDuration.
  ///
  /// In ru, this message translates to:
  /// **'Длительность'**
  String get detailsDuration;

  /// No description provided for @detailsIsrc.
  ///
  /// In ru, this message translates to:
  /// **'ISRC'**
  String get detailsIsrc;

  /// No description provided for @detailsQuality.
  ///
  /// In ru, this message translates to:
  /// **'Качество'**
  String get detailsQuality;

  /// No description provided for @detailsCodec.
  ///
  /// In ru, this message translates to:
  /// **'Кодек'**
  String get detailsCodec;

  /// No description provided for @detailsSize.
  ///
  /// In ru, this message translates to:
  /// **'Размер'**
  String get detailsSize;

  /// No description provided for @detailsFile.
  ///
  /// In ru, this message translates to:
  /// **'Файл'**
  String get detailsFile;

  /// No description provided for @detailsRemoteId.
  ///
  /// In ru, this message translates to:
  /// **'ID источника'**
  String get detailsRemoteId;

  /// No description provided for @detailsLocalId.
  ///
  /// In ru, this message translates to:
  /// **'Локальный ID'**
  String get detailsLocalId;

  /// No description provided for @downloadsPaused.
  ///
  /// In ru, this message translates to:
  /// **'На паузе'**
  String get downloadsPaused;

  /// No description provided for @downloadsPause.
  ///
  /// In ru, this message translates to:
  /// **'Пауза'**
  String get downloadsPause;

  /// No description provided for @downloadsResume.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get downloadsResume;

  /// No description provided for @settingsDownloads.
  ///
  /// In ru, this message translates to:
  /// **'Загрузки'**
  String get settingsDownloads;

  /// No description provided for @downloadsSummary.
  ///
  /// In ru, this message translates to:
  /// **'Скачано: {count} · {size}'**
  String downloadsSummary(int count, String size);

  /// No description provided for @downloadsQueueSummary.
  ///
  /// In ru, this message translates to:
  /// **'В очереди: {queued} · на паузе: {paused}'**
  String downloadsQueueSummary(int queued, int paused);

  /// No description provided for @downloadsSkipped.
  ///
  /// In ru, this message translates to:
  /// **'Пропущено как недоступное офлайн: {count}'**
  String downloadsSkipped(int count);

  /// No description provided for @downloadsAutoLikes.
  ///
  /// In ru, this message translates to:
  /// **'Качать любимое автоматически'**
  String get downloadsAutoLikes;

  /// No description provided for @downloadsAutoLikesNote.
  ///
  /// In ru, this message translates to:
  /// **'По умолчанию выключено. Сначала пробные 20 треков, потом все.'**
  String get downloadsAutoLikesNote;

  /// No description provided for @downloadsDownloadAll.
  ///
  /// In ru, this message translates to:
  /// **'Скачать все лайки'**
  String get downloadsDownloadAll;

  /// No description provided for @downloadsDownloadAllNote.
  ///
  /// In ru, this message translates to:
  /// **'Поставит в очередь все лайки. Пауза и лимит продолжают работать.'**
  String get downloadsDownloadAllNote;

  /// No description provided for @downloadsWifiOnly.
  ///
  /// In ru, this message translates to:
  /// **'Только Wi-Fi'**
  String get downloadsWifiOnly;

  /// No description provided for @downloadsWifiOnlyNote.
  ///
  /// In ru, this message translates to:
  /// **'Автозагрузка ждёт Wi-Fi; ручные загрузки разрешены в любой сети.'**
  String get downloadsWifiOnlyNote;

  /// No description provided for @downloadsLimit.
  ///
  /// In ru, this message translates to:
  /// **'Лимит места'**
  String get downloadsLimit;

  /// No description provided for @downloadsLimitNote.
  ///
  /// In ru, this message translates to:
  /// **'При достижении очередь останавливается, файлы не удаляются.'**
  String get downloadsLimitNote;

  /// No description provided for @downloadsUnlimited.
  ///
  /// In ru, this message translates to:
  /// **'Без лимита'**
  String get downloadsUnlimited;

  /// No description provided for @sizeBytes.
  ///
  /// In ru, this message translates to:
  /// **'{value} Б'**
  String sizeBytes(String value);

  /// No description provided for @sizeKb.
  ///
  /// In ru, this message translates to:
  /// **'{value} КБ'**
  String sizeKb(String value);

  /// No description provided for @sizeMb.
  ///
  /// In ru, this message translates to:
  /// **'{value} МБ'**
  String sizeMb(String value);

  /// No description provided for @sizeGb.
  ///
  /// In ru, this message translates to:
  /// **'{value} ГБ'**
  String sizeGb(String value);

  /// No description provided for @downloadsGb.
  ///
  /// In ru, this message translates to:
  /// **'{value} ГБ'**
  String downloadsGb(int value);

  /// No description provided for @downloadsQuality.
  ///
  /// In ru, this message translates to:
  /// **'Качество автозагрузки'**
  String get downloadsQuality;

  /// No description provided for @downloadsQualityNote.
  ///
  /// In ru, this message translates to:
  /// **'Не меняет уже скачанные файлы.'**
  String get downloadsQualityNote;

  /// No description provided for @downloadsDeleteAll.
  ///
  /// In ru, this message translates to:
  /// **'Удалить все загрузки'**
  String get downloadsDeleteAll;

  /// No description provided for @downloadsDeleteAllQuestion.
  ///
  /// In ru, this message translates to:
  /// **'Удалить все скачанные треки?'**
  String get downloadsDeleteAllQuestion;

  /// No description provided for @downloadsDeletedAll.
  ///
  /// In ru, this message translates to:
  /// **'Все загрузки удалены'**
  String get downloadsDeletedAll;

  /// No description provided for @downloadsFreeSpace.
  ///
  /// In ru, this message translates to:
  /// **'Свободно: {size}'**
  String downloadsFreeSpace(String size);

  /// No description provided for @settingsGroupAppearance.
  ///
  /// In ru, this message translates to:
  /// **'Внешний вид'**
  String get settingsGroupAppearance;

  /// No description provided for @settingsGroupMusic.
  ///
  /// In ru, this message translates to:
  /// **'Музыка'**
  String get settingsGroupMusic;

  /// No description provided for @settingsGroupData.
  ///
  /// In ru, this message translates to:
  /// **'Данные'**
  String get settingsGroupData;

  /// No description provided for @settingsGroupAccount.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт'**
  String get settingsGroupAccount;

  /// No description provided for @spinCookies.
  ///
  /// In ru, this message translates to:
  /// **'Вращение фигур'**
  String get spinCookies;

  /// No description provided for @spinCookiesNote.
  ///
  /// In ru, this message translates to:
  /// **'Фигуры у иконок на главной настроек медленно крутятся'**
  String get spinCookiesNote;

  /// No description provided for @statsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Статистика'**
  String get statsTitle;

  /// No description provided for @statsTileSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Время, топ треков и артистов'**
  String get statsTileSubtitle;

  /// No description provided for @statsCollect.
  ///
  /// In ru, this message translates to:
  /// **'Собирать статистику'**
  String get statsCollect;

  /// No description provided for @statsCollectNote.
  ///
  /// In ru, this message translates to:
  /// **'Хранится только на телефоне. Трек засчитывается после 30 секунд'**
  String get statsCollectNote;

  /// No description provided for @stats7d.
  ///
  /// In ru, this message translates to:
  /// **'7 дней'**
  String get stats7d;

  /// No description provided for @stats30d.
  ///
  /// In ru, this message translates to:
  /// **'30 дней'**
  String get stats30d;

  /// No description provided for @statsYear.
  ///
  /// In ru, this message translates to:
  /// **'Год'**
  String get statsYear;

  /// No description provided for @statsAll.
  ///
  /// In ru, this message translates to:
  /// **'Всё'**
  String get statsAll;

  /// No description provided for @statsTime.
  ///
  /// In ru, this message translates to:
  /// **'Время'**
  String get statsTime;

  /// No description provided for @statsPlays.
  ///
  /// In ru, this message translates to:
  /// **'Прослушано'**
  String get statsPlays;

  /// No description provided for @statsTracks.
  ///
  /// In ru, this message translates to:
  /// **'Треков'**
  String get statsTracks;

  /// No description provided for @statsByDay.
  ///
  /// In ru, this message translates to:
  /// **'По дням'**
  String get statsByDay;

  /// No description provided for @statsTopTracks.
  ///
  /// In ru, this message translates to:
  /// **'Топ треков'**
  String get statsTopTracks;

  /// No description provided for @statsTopArtists.
  ///
  /// In ru, this message translates to:
  /// **'Топ артистов'**
  String get statsTopArtists;

  /// No description provided for @statsExport.
  ///
  /// In ru, this message translates to:
  /// **'Экспорт JSON'**
  String get statsExport;

  /// No description provided for @statsClear.
  ///
  /// In ru, this message translates to:
  /// **'Очистить'**
  String get statsClear;

  /// No description provided for @statsClearConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Очистить статистику? История для волны останется.'**
  String get statsClearConfirm;

  /// No description provided for @statsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Пока пусто. Послушай что-нибудь дольше 30 секунд'**
  String get statsEmpty;

  /// No description provided for @statsHours.
  ///
  /// In ru, this message translates to:
  /// **'{h} ч {m} мин'**
  String statsHours(int h, int m);

  /// No description provided for @statsMinutes.
  ///
  /// In ru, this message translates to:
  /// **'{m} мин'**
  String statsMinutes(int m);

  /// No description provided for @statsPlaysCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} прослушивание} few{{count} прослушивания} many{{count} прослушиваний} other{{count} прослушивания}}'**
  String statsPlaysCount(int count);

  /// No description provided for @statsCleared.
  ///
  /// In ru, this message translates to:
  /// **'Статистика очищена'**
  String get statsCleared;

  /// No description provided for @aboutRepository.
  ///
  /// In ru, this message translates to:
  /// **'Репозиторий'**
  String get aboutRepository;

  /// No description provided for @updatesReinstall.
  ///
  /// In ru, this message translates to:
  /// **'Переустановить'**
  String get updatesReinstall;

  /// No description provided for @updatesReinstallTitle.
  ///
  /// In ru, this message translates to:
  /// **'Переустановить {version}'**
  String updatesReinstallTitle(String version);

  /// No description provided for @updatesReinstallNote.
  ///
  /// In ru, this message translates to:
  /// **'Скачать APK этой версии заново'**
  String get updatesReinstallNote;

  /// No description provided for @updatesReinstallConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Приложение скачает последний релиз и откроет установщик. Аккаунт, коллекция, статистика и настройки сохранятся.'**
  String get updatesReinstallConfirm;

  /// No description provided for @playerSleepLeft.
  ///
  /// In ru, this message translates to:
  /// **'Сработает через {count} мин'**
  String playerSleepLeft(int count);

  /// No description provided for @downloadRemoveQuestion.
  ///
  /// In ru, this message translates to:
  /// **'Удалить скачанный файл этого трека? Слушать его можно будет только с сетью.'**
  String get downloadRemoveQuestion;

  /// No description provided for @settingsResetQuestion.
  ///
  /// In ru, this message translates to:
  /// **'Вернуть все настройки к значениям по умолчанию? Значок приложения останется прежним.'**
  String get settingsResetQuestion;

  /// No description provided for @settingsStorageSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Кэш, загрузки и база'**
  String get settingsStorageSubtitle;
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
