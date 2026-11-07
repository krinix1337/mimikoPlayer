// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'mimikoPlayer';

  @override
  String get navWave => 'Wave';

  @override
  String get navSearch => 'Search';

  @override
  String get navCollection => 'Collection';

  @override
  String get navSettings => 'Settings';

  @override
  String get commonPlay => 'Play';

  @override
  String get commonPause => 'Pause';

  @override
  String get commonNext => 'Next';

  @override
  String get commonPrevious => 'Previous';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonRetry => 'Retry';

  @override
  String commonTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tracks',
      one: '$count track',
    );
    return '$_temp0';
  }

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonLike => 'Like';

  @override
  String get commonUnlike => 'Remove from liked';

  @override
  String get commonDislike => 'Dislike';

  @override
  String get waveTitle => 'My Wave';

  @override
  String get waveTune => 'Tune the wave';

  @override
  String get waveStart => 'Start the wave';

  @override
  String get waveSaved => 'Wave settings saved';

  @override
  String get waveSaveFailed => 'Yandex did not accept the wave settings';

  @override
  String get waveNeedsLogin => 'Sign in to Yandex to start the wave';

  @override
  String get waveSignIn => 'Sign in to Yandex';

  @override
  String waveSignedInAs(String account) {
    return 'Account: $account';
  }

  @override
  String get waveQueueFailed => 'The wave returned no tracks';

  @override
  String get waveStationMore => 'More waves';

  @override
  String get waveNotStarted => 'The wave is not running';

  @override
  String get sourceLibrary => 'My collection';

  @override
  String get sourcePlaylist => 'Playlist';

  @override
  String get sourceSearch => 'Search';

  @override
  String get sourceChart => 'Chart';

  @override
  String get sourceAlbum => 'Album';

  @override
  String get sourceArtist => 'Artist';

  @override
  String waveStationsFailed(String error) {
    return 'Stations did not load: $error';
  }

  @override
  String get waveLikeAdded => 'Added to liked';

  @override
  String get waveLikeRemoved => 'Removed from liked';

  @override
  String get feedbackDislike => 'Not for me';

  @override
  String get feedbackUndislike => 'Remove from disliked';

  @override
  String get feedbackDislikeAdded => 'Added to disliked';

  @override
  String get feedbackCleared => 'Mark removed';

  @override
  String get feedbackLocalOnly => 'device only';

  @override
  String get playlistCreate => 'New playlist';

  @override
  String get playlistName => 'Name';

  @override
  String get playlistNameHint => 'For example, for the road';

  @override
  String get playlistVisibility => 'Who can see it';

  @override
  String get playlistPublic => 'Everyone';

  @override
  String get playlistPrivate => 'Only me';

  @override
  String get playlistCreateAction => 'Create playlist';

  @override
  String playlistCreated(String title) {
    return 'Playlist “$title” created';
  }

  @override
  String get playlistCreateFailed => 'Could not create the playlist';

  @override
  String get importTitle => 'Import';

  @override
  String get importTileSubtitle => 'Track lists and other platforms';

  @override
  String get importHeroTitle => 'Move your music';

  @override
  String get importHeroNote =>
      'Paste an “Artist - Title” list — tracks are matched on Yandex and saved to a local playlist.';

  @override
  String get importHeroStatus => 'List import is available';

  @override
  String importMatched(int matched, int skipped) {
    return '$matched found, $skipped skipped';
  }

  @override
  String importDone(int matched, int skipped, int playlists) {
    return 'Done: $matched tracks, $skipped skipped, $playlists playlists';
  }

  @override
  String get importYandexRequired => 'Sign in to Yandex Music first';

  @override
  String get importFailed => 'The import stopped';

  @override
  String get importOther => 'Other platforms';

  @override
  String get importList => 'Import from a list';

  @override
  String get importListTitle => 'Playlist name';

  @override
  String get importListLines => 'Tracks';

  @override
  String get importListHint => 'Artist - Title\nArtist - Title';

  @override
  String get importLinkLabel => 'Link to a public playlist';

  @override
  String get importLinkHint => 'Spotify, SoundCloud or Yandex Music';

  @override
  String get importLinkFailed => 'Could not read the playlist from this link';

  @override
  String get importLinkTitle => 'Import by link';

  @override
  String get importLinkNote =>
      'Tracks are matched on Yandex and saved to a new playlist. A Yandex playlist simply opens.';

  @override
  String get importListFormat =>
      'One line per track, “Artist - Title”. First 300 lines.';

  @override
  String get importListAction => 'Move into a playlist';

  @override
  String get importListEmpty => 'Paste at least one line';

  @override
  String get importOtherYandex => 'A playlist link opens in the app';

  @override
  String get importOtherSoundCloud => 'Search and streaming without moving';

  @override
  String get waveSettingsTitle => 'Wave settings';

  @override
  String get waveClose => 'Close';

  @override
  String get waveModeSoundCloud => 'SoundCloud';

  @override
  String get waveRejectedNote => 'Yandex rejected the settings — see the log';

  @override
  String get collectionTitle => 'Collection';

  @override
  String get collectionLiked => 'Liked';

  @override
  String get collectionDisliked => 'Disliked';

  @override
  String get collectionPlaylists => 'Playlists';

  @override
  String get collectionFiles => 'Files';

  @override
  String get collectionRecent => 'Recent';

  @override
  String get collectionDownloaded => 'Downloaded';

  @override
  String get collectionEmptyDownloaded =>
      'No downloaded tracks yet.\nDownload a track from its menu or the player — it will play offline.';

  @override
  String get collectionArtists => 'Artists';

  @override
  String get albumsTitle => 'Albums';

  @override
  String get chartTitle => 'Chart';

  @override
  String get chartSubtitle => 'Popular in Russia right now';

  @override
  String get artistOpen => 'Go to artist';

  @override
  String get artistAllTracks => 'All tracks';

  @override
  String get artistPopularTracks => 'Popular tracks';

  @override
  String get artistAllAlbums => 'All albums';

  @override
  String get artistPhoto => 'Artist photo';

  @override
  String get trackDownloaded => 'Downloaded';

  @override
  String get albumOpen => 'Go to album';

  @override
  String get trackMenu => 'Track menu';

  @override
  String get menuLike => 'Like';

  @override
  String get menuDislike => 'Dislike';

  @override
  String get menuKaraoke => 'Karaoke';

  @override
  String get menuPlayNext => 'Play next';

  @override
  String get menuAddQueue => 'Add to queue';

  @override
  String get menuDetails => 'Track details';

  @override
  String get chartOpen => 'Yandex chart';

  @override
  String get collectionAlsoIn => 'Also in your collection';

  @override
  String listenedMinutes(int count) {
    return '$count min';
  }

  @override
  String listenedHours(int count) {
    return '$count h';
  }

  @override
  String artistPlays(int count) {
    return '$count plays';
  }

  @override
  String collectionCount(int count) {
    return 'Total: $count';
  }

  @override
  String get collectionSort => 'Sort';

  @override
  String get collectionDownloadAllLikes => 'Download all tracks';

  @override
  String get collectionShare => 'Share';

  @override
  String get playlistNotFound => 'Couldn\'t open the playlist. Check the link.';

  @override
  String get menuAddToPlaylist => 'Add to playlist';

  @override
  String addToPlaylistDone(String title) {
    return 'Added to \"$title\"';
  }

  @override
  String get addToPlaylistFailed => 'Couldn\'t add the track to the playlist';

  @override
  String get addToPlaylistEmpty => 'You don\'t have your own playlists yet';

  @override
  String collectionDownloadQueued(int count) {
    return 'Queued for download: $count';
  }

  @override
  String get sortAdded => 'Recently added';

  @override
  String get sortTitle => 'By title';

  @override
  String get sortArtist => 'By artist';

  @override
  String get sortDuration => 'By duration';

  @override
  String get collectionEmptyLiked =>
      'Nothing liked yet.\nTap the heart in the wave or in a track list.';

  @override
  String get collectionEmptyDisliked => 'No disliked tracks.';

  @override
  String get collectionEmptyPlaylists =>
      'No playlists yet — pull them from Yandex.';

  @override
  String get collectionEmptyFiles => 'No audio files in the Music folder.';

  @override
  String get collectionEmptyRecent => 'Playback history is empty.';

  @override
  String get collectionImportLikes => 'Pull likes from Yandex';

  @override
  String get collectionImportPlaylists => 'Import playlists from Yandex';

  @override
  String collectionImportedLikes(int count) {
    return 'Liked tracks in collection: $count';
  }

  @override
  String collectionImportedPlaylists(int count) {
    return 'Playlists saved: $count';
  }

  @override
  String collectionImportFailed(String error) {
    return 'Yandex did not return the collection: $error';
  }

  @override
  String get collectionPlayAll => 'Play all';

  @override
  String get collectionShuffleAll => 'Shuffle';

  @override
  String get collectionLocalTag => 'Local file';

  @override
  String get agoNow => 'just now';

  @override
  String agoMinutes(int count) {
    return '$count min ago';
  }

  @override
  String agoHours(int count) {
    return '$count h ago';
  }

  @override
  String agoDays(int count) {
    return '$count d ago';
  }

  @override
  String get playerTitle => 'Now playing';

  @override
  String get settingsCrossfade => 'Crossfade';

  @override
  String get settingsCrossfadeNote =>
      'The next track starts before the current one ends and blends with it. Does not apply to manual skips or repeating one track.';

  @override
  String get crossfadeOff => 'Off';

  @override
  String crossfadeSecondsValue(int seconds) {
    return '$seconds s';
  }

  @override
  String get playlistTarget => 'Where to create';

  @override
  String get playlistTargetYandex => 'Yandex Music';

  @override
  String get playlistTargetDevice => 'On this device';

  @override
  String get playlistDeviceNote =>
      'The playlist stays on this phone — you can add files from storage too.';

  @override
  String get playlistCoverRemove => 'Remove cover';

  @override
  String get playlistCoverChange => 'Change cover';

  @override
  String get playlistDeleteLocal => 'Delete playlist';

  @override
  String playlistDeleteConfirm(String title) {
    return 'Delete \"$title\"? The tracks themselves stay in the app.';
  }

  @override
  String get playlistDeleted => 'Playlist deleted';

  @override
  String get commonDelete => 'Delete';

  @override
  String get artistBlock => 'Never recommend this artist';

  @override
  String get artistUnblock => 'Recommend this artist again';

  @override
  String artistBlockedDone(String name) {
    return '\"$name\" will no longer show up';
  }

  @override
  String artistUnblockedDone(String name) {
    return '\"$name\" is back in recommendations';
  }

  @override
  String get settingsBlockedArtists => 'Blocked artists';

  @override
  String get settingsBlockedArtistsEmpty =>
      'The list is empty. Block an artist from their page or the track menu.';

  @override
  String settingsBlockedArtistsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artists',
      one: '$count artist',
    );
    return '$_temp0';
  }

  @override
  String artistListeners(String count) {
    return '$count listeners';
  }

  @override
  String get playerBack => 'Back';

  @override
  String get playerQueue => 'Queue';

  @override
  String get playerRepeat => 'Repeat';

  @override
  String get playerQueueEmpty => 'Queue is empty';

  @override
  String playerSourceChip(String source, String quality) {
    return '$source · $quality';
  }

  @override
  String get playerLocal => 'Local file';

  @override
  String get playerRadio => 'Wave';

  @override
  String get playerSleep => 'Sleep timer';

  @override
  String get playerSleepOff => 'Off';

  @override
  String playerSleepMinutes(int count) {
    return '$count min';
  }

  @override
  String get playerSleepUntilEnd => 'Until the track ends';

  @override
  String get playerSleepNote =>
      'The timer pauses playback after the current track.';

  @override
  String get playerLyrics => 'Lyrics';

  @override
  String get playerLyricsMissing => 'No lyrics yet';

  @override
  String get playerDownload => 'Download';

  @override
  String get playerDownloadSoon =>
      'Offline downloads arrive with the offline stage';

  @override
  String get menuDownloaded => 'Remove download';

  @override
  String get menuDownloading => 'Downloading…';

  @override
  String get menuDownloadRetry => 'Retry download';

  @override
  String downloadProgress(int percent) {
    return 'Downloading: $percent%';
  }

  @override
  String get downloadRemoved => 'Download removed';

  @override
  String downloadFailed(String error) {
    return 'Download failed: $error';
  }

  @override
  String get playerSleepFired => 'Sleep timer: paused';

  @override
  String get searchHint => 'Artist, track or album';

  @override
  String get searchEmpty => 'Start typing — we search every connected source';

  @override
  String get searchNoResults => 'Nothing found';

  @override
  String get searchTracks => 'Tracks';

  @override
  String get searchArtists => 'Artists';

  @override
  String get searchAlbums => 'Albums';

  @override
  String searchResults(int count) {
    return 'Found: $count';
  }

  @override
  String searchSourceLabel(String source) {
    return 'Source: $source';
  }

  @override
  String get searchFailed => 'The source did not answer';

  @override
  String get searchPlayFromSearch => 'Play from search';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionAppearance => 'Appearance & language';

  @override
  String get settingsSectionSound => 'Sound & playback';

  @override
  String get settingsSectionKaraoke => 'Karaoke';

  @override
  String get settingsSectionStorage => 'Storage & data';

  @override
  String get settingsSectionAccount => 'Account & services';

  @override
  String get settingsSectionAbout => 'About';

  @override
  String get settingsOpenSection => 'Open';

  @override
  String get lyricsSize => 'Text size';

  @override
  String get lyricsSizeSmall => 'Small';

  @override
  String get lyricsSizeNormal => 'Normal';

  @override
  String get lyricsSizeLarge => 'Large';

  @override
  String get lyricsDim => 'Dim the other lines';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get appearanceThemeLanguage => 'Theme and language';

  @override
  String get appearanceShapeMotion => 'Shape and motion';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'Match system';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsPalette => 'Palette';

  @override
  String get paletteBrand => 'Brand';

  @override
  String get paletteDynamic => 'Material You';

  @override
  String get paletteMono => 'Monochrome';

  @override
  String get paletteAmoled => 'AMOLED';

  @override
  String get paletteDynamicNote => 'Material You needs Android 12 or newer';

  @override
  String get paletteAmoledNote =>
      'True black background: OLED pixels turn off and the battery lasts longer';

  @override
  String get settingsAccent => 'Accent';

  @override
  String get accentAcid => 'Acid';

  @override
  String get accentViolet => 'Violet';

  @override
  String get accentCoral => 'Coral';

  @override
  String get accentTeal => 'Mint';

  @override
  String get accentAmber => 'Amber';

  @override
  String get accentIce => 'Ice';

  @override
  String get accentSky => 'Sky';

  @override
  String get accentRose => 'Rose';

  @override
  String get accentLeaf => 'Leaf';

  @override
  String get accentOrchid => 'Orchid';

  @override
  String get launcherForest => 'Forest';

  @override
  String get settingsContrast => 'Contrast';

  @override
  String get contrastNormal => 'Normal';

  @override
  String get contrastHigh => 'High';

  @override
  String get settingsCorners => 'Corners';

  @override
  String get cornerSoft => 'Soft';

  @override
  String get cornerRound => 'Round';

  @override
  String get cornerPill => 'Pill';

  @override
  String get settingsMotion => 'Motion';

  @override
  String get uiSection => 'Interface';

  @override
  String get settingsBlur => 'Blur';

  @override
  String get blurBottom => 'Bottom bar and mini player';

  @override
  String get blurTop => 'Top bars';

  @override
  String get blurCovers => 'Backdrop covers';

  @override
  String get blurOff => 'Off';

  @override
  String get blurSoft => 'Soft';

  @override
  String get blurMedium => 'Medium';

  @override
  String get blurStrong => 'Strong';

  @override
  String get blurBottomNote =>
      'Glass under the pills: content keeps showing through';

  @override
  String get blurTopNote => 'Back bars on screens with artwork';

  @override
  String get blurCoversNote =>
      'Blur strength for backdrop covers across screens';

  @override
  String get blurPerformanceNote =>
      'While scrolling, glass becomes denser and stops re-blurring the backdrop, and background covers are blurred at a reduced size. Smoother on budget phones.';

  @override
  String get compactUi => 'Compact panel';

  @override
  String get compactUiNote =>
      'Smaller and denser bottom navigation and mini player.';

  @override
  String get showMiniPlayer => 'Mini player';

  @override
  String get showNavLabels => 'Navigation labels';

  @override
  String get showNavLabelsNote =>
      'Without labels the bar is lower and icons are larger.';

  @override
  String get hideAi => 'Hide AI tracks';

  @override
  String get hideAiNote =>
      'Uses the Slopless artist list (GitHub) plus explicit AI marks in titles and artists. The list is downloaded over the network; the Yandex API has no official label.';

  @override
  String get artworkShape => 'Player artwork';

  @override
  String get artworkRounded => 'Theme default';

  @override
  String get artworkSoft => 'Soft';

  @override
  String get artworkCircle => 'Circle';

  @override
  String get showMiniPlayerNote =>
      'Show the player strip above the navigation.';

  @override
  String get homeBackground => 'Home background';

  @override
  String get bgCover => 'Cover';

  @override
  String get bgBlobs => 'Blobs';

  @override
  String get bgBoth => 'Cover and blobs';

  @override
  String get settingsFade => 'Fade in / out';

  @override
  String get settingsFadeNote =>
      'Volume ramps up on start and down on pause, seek and track change.';

  @override
  String get settingsEqualizer => 'Equalizer';

  @override
  String get equalizerEnabled => 'Enable equalizer';

  @override
  String get equalizerNote =>
      'The preset applies to current playback immediately.';

  @override
  String get equalizerPreset => 'Preset';

  @override
  String get equalizerTune => 'Customize';

  @override
  String get equalizerCustom => 'Custom';

  @override
  String get equalizerLevel => 'lvl';

  @override
  String get eqPresetFlat => 'Flat';

  @override
  String get eqPresetBass => 'Bass';

  @override
  String get eqPresetTreble => 'Treble';

  @override
  String get eqPresetRock => 'Rock';

  @override
  String get eqPresetElectronic => 'Electronic';

  @override
  String get eqPresetPop => 'Pop';

  @override
  String get eqPresetVocal => 'Vocal';

  @override
  String get eqPresetAcoustic => 'Acoustic';

  @override
  String get censorBypass => 'Uncensored version';

  @override
  String get censorBypassNote =>
      'Replace tracks from the FckCensorData base (GitHub) with their uncensored version. The base is downloaded over the network; if a file is missing, the Yandex version plays.';

  @override
  String get settingsReset => 'Reset settings';

  @override
  String get settingsResetDone => 'Settings are back to defaults';

  @override
  String get settingsLyricsSource => 'Lyrics: LRCLIB, Musixmatch, NetEase';

  @override
  String get settingsLyricsSourceNote =>
      'Line timings are looked up in LRCLIB, Musixmatch and NetEase in turn; otherwise the official Yandex text is shown.';

  @override
  String get motionOff => 'Off';

  @override
  String get motionFast => 'Fast';

  @override
  String get motionNormal => 'Normal';

  @override
  String get motionSlow => 'Slow';

  @override
  String get settingsLauncherIcon => 'Launcher icon';

  @override
  String get launcherIconApplied => 'Icon updated — the launcher may reload';

  @override
  String launcherIconFailed(String error) {
    return 'Could not change the icon: $error';
  }

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'Match system';

  @override
  String get settingsPlayback => 'Playback';

  @override
  String get settingsQuality => 'Stream quality';

  @override
  String get qualityAuto => 'Auto (best available)';

  @override
  String get qualityLow => 'Data saver';

  @override
  String get qualityNormal => 'Medium';

  @override
  String get qualityHigh => 'High';

  @override
  String get qualityLossless => 'Lossless';

  @override
  String get settingsPriority => 'Source priority';

  @override
  String get settingsPriorityNote =>
      'If a track fails, the player moves to the next source in the list';

  @override
  String get roleStream => 'plays audio';

  @override
  String get roleCatalog => 'catalog only';

  @override
  String get roleAbsent => 'not connected';

  @override
  String get settingsStorage => 'Storage';

  @override
  String get settingsCache => 'Artwork cache';

  @override
  String get settingsCacheClear => 'Clear cache';

  @override
  String get settingsCacheCleared => 'Artwork cache cleared';

  @override
  String get settingsData => 'Data';

  @override
  String settingsRows(int count) {
    return 'Database rows: $count';
  }

  @override
  String settingsSchema(int version) {
    return 'Database schema: v$version';
  }

  @override
  String get settingsLogs => 'Event log';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsSignOut => 'Sign out of Yandex';

  @override
  String get accountPlus => 'Subscription active';

  @override
  String get accountFree => 'No subscription';

  @override
  String get settingsSignedOut => 'Signed out of Yandex';

  @override
  String get settingsAbout => 'About';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get updatesTitle => 'Updates';

  @override
  String get updatesTileSubtitle => 'Private GitHub releases';

  @override
  String get updatesCheckShort => 'Check';

  @override
  String get updatesChecking => 'Checking releases…';

  @override
  String get updatesUpToDate => 'You\'re on the latest version';

  @override
  String get updatesNotChecked => 'Updates haven\'t been checked yet';

  @override
  String get updatesReleases => 'Releases';

  @override
  String updatesLatestRelease(String version) {
    return 'Latest GitHub release: $version';
  }

  @override
  String updatesWhatsNew(String version) {
    return 'What\'s new in $version';
  }

  @override
  String get updatesOpenGithub => 'Open release on GitHub';

  @override
  String updatesAvailable(String version) {
    return 'Version $version is available';
  }

  @override
  String updatesSize(String size) {
    return '$size MB';
  }

  @override
  String get updatesDownload => 'Download and install';

  @override
  String updatesDownloading(int percent) {
    return 'Downloading: $percent%';
  }

  @override
  String get updatesCancel => 'Cancel';

  @override
  String get updatesOpeningInstaller => 'Opening the installer…';

  @override
  String get updatesInstallPermission =>
      'Allow installs from this app, then try again';

  @override
  String get updatesErrorUnauthorized =>
      'GitHub is rate limiting requests, try again later';

  @override
  String get updatesErrorNotFound => 'Releases are not available yet';

  @override
  String get updatesErrorNoAsset => 'The latest release has no APK';

  @override
  String get updatesErrorNoDigest =>
      'The release has no SHA-256; download cancelled';

  @override
  String get updatesErrorChecksum => 'Checksum mismatch; the file was deleted';

  @override
  String get updatesErrorNetwork => 'Cannot reach GitHub';

  @override
  String get updatesErrorUnknown => 'Could not check for updates';

  @override
  String get updatesReady => 'Downloaded and verified';

  @override
  String get updatesInstall => 'Install';

  @override
  String get settingsAboutNote =>
      'A local player: Yandex Music, SoundCloud and your own files behind one interface.';

  @override
  String get aboutSources => 'Sources';

  @override
  String get aboutSourcesNote =>
      'Yandex Music for catalog, streams and the wave; SoundCloud for search and streams; local files from the Music folder. Lyrics: LRCLIB, Musixmatch, NetEase, official Yandex text and lyrics.ovh.';

  @override
  String get settingsAiFilter => 'AI filter';

  @override
  String get accountConnected => 'Connected';

  @override
  String get accountSignOut => 'Sign out';

  @override
  String get accountServices => 'Services';

  @override
  String get accountSoundCloudNote => 'Search and streaming without signing in';

  @override
  String get aboutYandexNote =>
      'Catalog, streaming, the wave and recommendations';

  @override
  String get settingsAiFilterSource => 'AI filter: Slopless';

  @override
  String get settingsCensorSource => 'Uncensored versions: FckCensorData';

  @override
  String get authTitle => 'Sign in to Yandex';

  @override
  String get authCodeHint => 'Confirmation code';

  @override
  String get authCopyCode => 'Copy code';

  @override
  String get authCopied => 'Code copied';

  @override
  String get authOpenLink => 'Open';

  @override
  String get authWaiting => 'Waiting for confirmation in the browser…';

  @override
  String authDone(String name) {
    return 'Signed in as $name';
  }

  @override
  String authFailed(String error) {
    return 'Sign-in did not finish: $error';
  }

  @override
  String get authExpired => 'The code expired, start again';

  @override
  String get authNotSignedIn => 'No Yandex account connected';

  @override
  String get authNotBuilt => 'Yandex is not built into this app';

  @override
  String get authRequestingCode => 'Requesting the code…';

  @override
  String get authCodeIntro =>
      'Confirm the sign-in on the Yandex page. The code is already in the link — just press Allow.';

  @override
  String get authOpenPage => 'Open the Yandex page';

  @override
  String get authWaitingCode =>
      'Waiting for confirmation. The code lives about 5 minutes.';

  @override
  String get authNotConfirmed => 'Sign-in not confirmed — press Start again';

  @override
  String authBrowserFailed(String url) {
    return 'The browser did not open: $url';
  }

  @override
  String get authRetry => 'Start again';

  @override
  String get authSignOut => 'Sign out';

  @override
  String authCodeCopied(String code) {
    return 'Code $code copied';
  }

  @override
  String get issueHeadline => 'The track would not play';

  @override
  String get issueNeedsLogin => 'The source needs a sign-in';

  @override
  String get issueNeedsPlus => 'The source needs a subscription';

  @override
  String get issueGeo => 'Unavailable in your region';

  @override
  String get issueUnavailable => 'Not in the catalog';

  @override
  String get issueNetwork => 'Network problem';

  @override
  String get issueThrottled => 'The source rate-limited us';

  @override
  String get issueSignature => 'Stream signature rejected';

  @override
  String get issueExhausted => 'Every source refused';

  @override
  String get issueUnknown => 'Unknown error';

  @override
  String toastQueueStarted(String title) {
    return 'Playing: $title';
  }

  @override
  String dbError(String error) {
    return 'Database error: $error';
  }

  @override
  String get navDiscover => 'Discover';

  @override
  String get discoverTitle => 'What to listen to';

  @override
  String get discoverChart => 'Chart';

  @override
  String get discoverNewReleases => 'New releases';

  @override
  String get discoverStations => 'Genres and moods';

  @override
  String get discoverArtists => 'Your artists';

  @override
  String get discoverAll => 'All';

  @override
  String get searchHistoryTitle => 'Search history';

  @override
  String get searchHistoryClear => 'Clear';

  @override
  String get waveListen => 'Listen';

  @override
  String get waveWheelHint => 'Spin and choose a mode';

  @override
  String get waveBackToUsual => 'Back to usual';

  @override
  String get moodEnergyActive => 'Active';

  @override
  String get moodEnergyFun => 'Fun';

  @override
  String get moodEnergyCalm => 'Calm';

  @override
  String get moodEnergySad => 'Sad';

  @override
  String get diversityFavorite => 'Familiar';

  @override
  String get diversityDiscover => 'Unfamiliar';

  @override
  String get diversityPopular => 'Popular';

  @override
  String get languageRussian => 'Russian';

  @override
  String get languageForeign => 'Foreign';

  @override
  String get languageInstrumental => 'Instrumental';

  @override
  String get homeCoverTone => 'Cover tone';

  @override
  String get homeCoverDarker => 'Darker';

  @override
  String get homeCoverNormal => 'Normal';

  @override
  String get homeCoverLighter => 'Lighter';

  @override
  String get settingsOpenPlayer => 'Open player on play';

  @override
  String get settingsOpenPlayerNote =>
      'When off, the track plays in the mini player; tap it to open the full player';

  @override
  String get trackUnknownArtist => 'Unknown artist';

  @override
  String get badgeExplicit => '18+';

  @override
  String get badgeAi => 'AI';

  @override
  String get badgeUncensored => 'Uncensored';

  @override
  String get sourceYandex => 'Yandex Music';

  @override
  String get sourceRemoved => 'Source removed';

  @override
  String get sourceLocalFile => 'File';

  @override
  String get detailsSource => 'Source';

  @override
  String get detailsSources => 'Sources';

  @override
  String get detailsAlbum => 'Album';

  @override
  String get detailsYear => 'Year';

  @override
  String get detailsDuration => 'Duration';

  @override
  String get detailsIsrc => 'ISRC';

  @override
  String get detailsQuality => 'Quality';

  @override
  String get detailsCodec => 'Codec';

  @override
  String get detailsSize => 'Size';

  @override
  String get detailsFile => 'File';

  @override
  String get detailsRemoteId => 'Source ID';

  @override
  String get detailsLocalId => 'Local ID';

  @override
  String get downloadsPaused => 'Paused';

  @override
  String get downloadsPause => 'Pause';

  @override
  String get downloadsResume => 'Resume';

  @override
  String get settingsDownloads => 'Downloads';

  @override
  String downloadsSummary(int count, String size) {
    return 'Downloaded: $count · $size';
  }

  @override
  String downloadsQueueSummary(int queued, int paused) {
    return 'Queued: $queued · paused: $paused';
  }

  @override
  String downloadsSkipped(int count) {
    return 'Skipped as unavailable offline: $count';
  }

  @override
  String get downloadsAutoLikes => 'Download likes automatically';

  @override
  String get downloadsAutoLikesNote =>
      'Off by default. A trial of 20 tracks runs first, then everything.';

  @override
  String get downloadsDownloadAll => 'Download all likes';

  @override
  String get downloadsDownloadAllNote =>
      'Queues all likes. Pause and the storage limit still apply.';

  @override
  String get downloadsWifiOnly => 'Wi-Fi only';

  @override
  String get downloadsWifiOnlyNote =>
      'Auto-download waits for Wi-Fi; manual downloads are allowed on any network.';

  @override
  String get downloadsLimit => 'Storage limit';

  @override
  String get downloadsLimitNote =>
      'The queue stops at the limit; existing files are not deleted.';

  @override
  String get downloadsUnlimited => 'No limit';

  @override
  String sizeBytes(String value) {
    return '$value B';
  }

  @override
  String sizeKb(String value) {
    return '$value KB';
  }

  @override
  String sizeMb(String value) {
    return '$value MB';
  }

  @override
  String sizeGb(String value) {
    return '$value GB';
  }

  @override
  String downloadsGb(int value) {
    return '$value GB';
  }

  @override
  String get downloadsQuality => 'Auto-download quality';

  @override
  String get downloadsQualityNote =>
      'Does not change already downloaded files.';

  @override
  String get downloadsDeleteAll => 'Delete all downloads';

  @override
  String get downloadsDeleteAllQuestion => 'Delete all downloaded tracks?';

  @override
  String get downloadsDeletedAll => 'All downloads deleted';

  @override
  String downloadsFreeSpace(String size) {
    return 'Free: $size';
  }

  @override
  String get settingsGroupAppearance => 'Appearance';

  @override
  String get settingsGroupMusic => 'Music';

  @override
  String get settingsGroupData => 'Data';

  @override
  String get settingsGroupAccount => 'Account';

  @override
  String get spinCookies => 'Spinning shapes';

  @override
  String get spinCookiesNote =>
      'Icon shapes on the settings home slowly rotate';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get statsTileSubtitle => 'Time, top tracks and artists';

  @override
  String get statsCollect => 'Collect statistics';

  @override
  String get statsCollectNote =>
      'Stored only on this phone. A track counts after 30 seconds';

  @override
  String get stats7d => '7 days';

  @override
  String get stats30d => '30 days';

  @override
  String get statsYear => 'Year';

  @override
  String get statsAll => 'All';

  @override
  String get statsTime => 'Time';

  @override
  String get statsPlays => 'Plays';

  @override
  String get statsTracks => 'Tracks';

  @override
  String get statsByDay => 'By day';

  @override
  String get statsTopTracks => 'Top tracks';

  @override
  String get statsTopArtists => 'Top artists';

  @override
  String get statsExport => 'Export JSON';

  @override
  String get statsClear => 'Clear';

  @override
  String get statsClearConfirm => 'Clear statistics? Wave history stays.';

  @override
  String get statsEmpty =>
      'Nothing yet. Listen to something for over 30 seconds';

  @override
  String statsHours(int h, int m) {
    return '$h h $m min';
  }

  @override
  String statsMinutes(int m) {
    return '$m min';
  }

  @override
  String statsPlaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plays',
      one: '$count play',
    );
    return '$_temp0';
  }

  @override
  String get statsCleared => 'Statistics cleared';

  @override
  String get aboutRepository => 'Repository';

  @override
  String get updatesReinstall => 'Reinstall';

  @override
  String updatesReinstallTitle(String version) {
    return 'Reinstall $version';
  }

  @override
  String get updatesReinstallNote => 'Download this version’s APK again';

  @override
  String get updatesReinstallConfirm =>
      'The app will download the latest release and open the installer. Your account, collection, statistics and settings stay.';

  @override
  String playerSleepLeft(int count) {
    return 'Fires in $count min';
  }

  @override
  String get downloadRemoveQuestion =>
      'Remove the downloaded file of this track? It will only play with a connection.';

  @override
  String get settingsResetQuestion =>
      'Reset all settings to defaults? The app icon stays as it is.';

  @override
  String get settingsStorageSubtitle => 'Cache, downloads and database';
}
