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
  String get commonTracks => 'tracks';

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
  String get waveMood => 'Mood';

  @override
  String get waveEnergy => 'Energy';

  @override
  String get waveDiversity => 'Diversity';

  @override
  String get waveStation => 'Station';

  @override
  String get wavePresets => 'Presets';

  @override
  String get waveLanguage => 'Music language';

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
  String get switchToWave => 'Switch to My Wave';

  @override
  String waveStationsFailed(String error) {
    return 'Stations did not load: $error';
  }

  @override
  String get waveLikeAdded => 'Added to liked';

  @override
  String get waveLikeRemoved => 'Removed from liked';

  @override
  String get waveSettingsTitle => 'Wave settings';

  @override
  String get waveApply => 'Apply';

  @override
  String get waveClose => 'Close';

  @override
  String get waveSavedNote => 'Wave settings saved';

  @override
  String get waveRejectedNote => 'Yandex rejected the settings — see the log';

  @override
  String get moodCalm => 'calm';

  @override
  String get moodEven => 'even';

  @override
  String get moodActive => 'active';

  @override
  String get energyLow => 'low';

  @override
  String get energyMid => 'medium';

  @override
  String get energyHigh => 'high';

  @override
  String get diversityMore => 'more new';

  @override
  String get diversityLess => 'more familiar';

  @override
  String get diversityUsual => 'as usual';

  @override
  String get langRu => 'russian';

  @override
  String get langEn => 'english';

  @override
  String get langNonrank => 'no priority';

  @override
  String get langAny => 'any';

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
  String get artistOpen => 'Go to artist';

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
  String menuDetailsBody(String source, String quality, String codec) {
    return 'Source: $source\nQuality: $quality\nFormat: $codec';
  }

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
  String get paletteDynamicNote => 'Material You needs Android 12 or newer';

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
  String get launcherForest => 'Forest';

  @override
  String get launcherCrimson => 'Crimson';

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
  String get censorBypass => 'Uncensored version';

  @override
  String get censorBypassNote =>
      'Replace tracks from the FckCensorData base (GitHub) with their uncensored version. The base is downloaded over the network; if a file is missing, the Yandex version plays.';

  @override
  String get settingsReset => 'Reset settings';

  @override
  String get settingsResetDone => 'Settings are back to defaults';

  @override
  String get settingsLyricsSource => 'Lyrics source: LRCLIB + Yandex';

  @override
  String get settingsLyricsSourceNote =>
      'Line timings come from LRCLIB; it has no word-level data.';

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
  String get settingsFrame => 'Frame rate';

  @override
  String get frameSystem => 'Match system';

  @override
  String get frame120 => '120 Hz';

  @override
  String get frame90 => '90 Hz';

  @override
  String get frame60 => '60 Hz';

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
  String get settingsAboutNote =>
      'A local player: Yandex, YouTube and your own files behind one interface.';

  @override
  String get aboutSources => 'Sources';

  @override
  String get aboutSourcesNote =>
      'Yandex Music for catalog, streams and the wave; YouTube for search and streams; local files from the Music folder. Lyrics: LRCLIB, official Yandex text and lyrics.ovh.';

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
}
