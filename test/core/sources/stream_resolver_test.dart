import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/core/sources/music_source.dart';
import 'package:phoneyandex/core/sources/registry.dart';
import 'package:phoneyandex/core/sources/source_dto.dart';
import 'package:phoneyandex/core/sources/source_errors.dart';
import 'package:phoneyandex/core/sources/source_id.dart';
import 'package:phoneyandex/core/sources/stream_resolver.dart';
import 'package:phoneyandex/core/sources/stream_target.dart';

final farFuture = DateTime(2100);

class FakeSource implements MusicSource {
  FakeSource(this.id, {this.result, this.failures = const []});

  @override
  final SourceId id;

  StreamResult? result;

  /// Причины, которые источник отдаёт по очереди вместо [result].
  List<SourceFailure> failures;

  int resolveCalls = 0;
  int warmUpCalls = 0;
  Quality? lastPreferred;

  @override
  SourceCapabilities get capabilities =>
      const SourceCapabilities(canStream: true, canSearch: true);

  @override
  AuthState get auth => AuthReady(
    uid: '1',
    login: 'fake',
    hasPlus: true,
    accessTokenExpiresAt: farFuture,
  );

  @override
  Stream<AuthState> get authChanges => const Stream<AuthState>.empty();

  @override
  Future<void> warmUp() async => warmUpCalls++;

  @override
  Future<StreamResult> resolveStream(
    SourceTrack track, {
    Quality preferred = Quality.auto,
  }) async {
    resolveCalls++;
    lastPreferred = preferred;
    if (failures.isNotEmpty) {
      return StreamFailed(failures.removeAt(0));
    }
    return result ??
        const StreamFailed(
          SourceFailure(
            source: SourceId.local,
            reason: SourceFailReason.notInCatalog,
          ),
        );
  }

  @override
  Future<SearchResult> search(
    String query, {
    int page = 0,
    int pageSize = 50,
  }) async => const SearchResult(tracks: [], page: 0);

  @override
  Future<SourceTrack?> getTrack(RemoteTrackRef ref) async => null;

  @override
  Future<List<SourceTrack>> getTracksByIds(List<RemoteTrackRef> refs) async =>
      const [];

  @override
  Future<PlaylistSnapshot?> getPlaylist(String remotePlaylistId) async => null;

  @override
  Future<void> reportPlaybackEvent(
    SourceTrack track,
    PlaybackEventType type,
    Duration played,
  ) async {}

  @override
  Future<void> dispose() async {}
}

class FakeStore implements ResolutionStore {
  String? downloadedPath;
  final Map<String, ResolvedPlayback> cache = {};
  final Map<String, SourceFailReason> failures = {};
  final List<String> invalidations = [];
  int putCalls = 0;

  String _key(String track, String source, String quality) =>
      '$track|$source|$quality';

  @override
  Future<String?> downloadedFilePath(String localTrackId) async =>
      downloadedPath;

  @override
  Future<ResolvedPlayback?> cached(
    String localTrackId,
    SourceId source,
    Quality quality,
  ) async => cache[_key(localTrackId, source.wire, quality.wire)];

  @override
  Future<void> put(ResolvedPlayback playback) async {
    putCalls++;
    cache[_key(
          playback.localTrackId,
          playback.usedSource.wire,
          playback.quality.wire,
        )] =
        playback;
  }

  @override
  Future<void> invalidate(String localTrackId, SourceId source) async {
    invalidations.add('$localTrackId|${source.wire}');
    cache.removeWhere((k, _) => k.startsWith('$localTrackId|${source.wire}|'));
  }

  @override
  Future<SourceFailReason?> activeFailure(
    String localTrackId,
    SourceId source,
  ) async => failures['$localTrackId|${source.wire}'];

  @override
  Future<void> noteFailure(String localTrackId, SourceFailure failure) async {
    if (failure.negativeCacheTtl > Duration.zero) {
      failures['$localTrackId|${failure.source.wire}'] = failure.reason;
    }
  }
}

SourceTrack variant(SourceId source, {String remoteId = 'r'}) => SourceTrack(
  ref: RemoteTrackRef(source, remoteId),
  title: 'Test',
  artists: const ['Unit'],
  duration: const Duration(seconds: 100),
);

StreamReady readyUrl(SourceId source, {int secondsToLive = 600}) => StreamReady(
  target: StreamUrl(
    url: Uri.parse('https://example.test/${source.wire}'),
    expiresAt: DateTime.now().add(Duration(seconds: secondsToLive)),
  ),
  source: source,
  quality: Quality.high,
  ttlHint: Duration(seconds: secondsToLive),
);

void main() {
  late FakeSource yandex;
  late FakeSource youtube;
  late FakeStore store;
  late StreamResolver resolver;
  const trackId = 't_000000000000000000000001';

  setUp(() {
    yandex = FakeSource(SourceId.yandex);
    youtube = FakeSource(SourceId.youtube);
    store = FakeStore();
    resolver = StreamResolver(
      registry: SourceRegistry([yandex, youtube]),
      store: store,
    );
  });

  Future<ResolveResult> run({bool bypassCache = false}) => resolver.resolve(
    localTrackId: trackId,
    variants: [variant(SourceId.yandex), variant(SourceId.youtube)],
    bypassCache: bypassCache,
  );

  test('скачанный файл перекрывает сетевую цепочку', () async {
    store.downloadedPath = '/data/local.mp3';
    yandex.result = readyUrl(SourceId.yandex);

    final result = await run();

    expect(result.playback?.target, isA<StreamFile>());
    expect(result.playback?.usedSource, SourceId.local);
    expect(yandex.resolveCalls, 0);
  });

  test('первым спрашивается приоритетный источник', () async {
    yandex.result = readyUrl(SourceId.yandex);
    youtube.result = readyUrl(SourceId.youtube);

    final result = await run();

    expect(result.playback?.usedSource, SourceId.yandex);
    expect(youtube.resolveCalls, 0);
  });

  test('недоступный трек в первом источнике уводит во второй', () async {
    yandex.failures = [
      const SourceFailure(
        source: SourceId.yandex,
        reason: SourceFailReason.unavailable,
      ),
    ];
    youtube.result = readyUrl(SourceId.youtube);

    final result = await run();

    expect(result.playback?.usedSource, SourceId.youtube);
    expect(yandex.resolveCalls, 1);
    expect(youtube.resolveCalls, 1);
  });

  test(
    'просроченный токен останавливает цепочку, второй источник не трогается',
    () async {
      yandex.failures = [
        const SourceFailure(
          source: SourceId.yandex,
          reason: SourceFailReason.authExpired,
        ),
      ];
      youtube.result = readyUrl(SourceId.youtube);

      final result = await run();

      expect(result.isOk, isFalse);
      expect(result.needsUserAction, isTrue);
      expect(result.exhausted, isFalse);
      expect(youtube.resolveCalls, 0);
    },
  );

  test('needsPlus не останавливает цепочку, но требует действия', () async {
    yandex.failures = [
      const SourceFailure(
        source: SourceId.yandex,
        reason: SourceFailReason.needsPlus,
      ),
    ];
    youtube.result = readyUrl(SourceId.youtube);

    final result = await run();

    expect(result.playback?.usedSource, SourceId.youtube);
  });

  test(
    'второй успешный вызов берётся из кэша без обращения к источнику',
    () async {
      yandex.result = readyUrl(SourceId.yandex);

      final first = await run();
      final second = await run();

      expect(first.playback?.fromCache, isFalse);
      expect(second.playback?.fromCache, isTrue);
      expect(yandex.resolveCalls, 1);
    },
  );

  test('протухший кэш переписывается, а не отдаётся', () async {
    yandex.result = readyUrl(SourceId.yandex, secondsToLive: 60);

    await run();
    // TTL 60s меньше запаса в 2 минуты — ссылка считается непригодной.
    final second = await run();

    expect(yandex.resolveCalls, 2);
    expect(second.playback?.fromCache, isFalse);
  });

  test('негативный кэш пропускает источник целиком', () async {
    store.failures['$trackId|yandex'] = SourceFailReason.unavailable;
    youtube.result = readyUrl(SourceId.youtube);

    final result = await run();

    expect(result.playback?.usedSource, SourceId.youtube);
    expect(yandex.resolveCalls, 0);
  });

  test('отказ с нулевым TTL в негативный кэш не попадает', () async {
    yandex.failures = [
      const SourceFailure(
        source: SourceId.yandex,
        reason: SourceFailReason.signatureRejected,
      ),
    ];
    youtube.result = readyUrl(SourceId.youtube);

    await run();
    await run();

    expect(yandex.resolveCalls, 2);
  });

  test('все отказали — exhausted и список причин', () async {
    yandex.failures = [
      const SourceFailure(
        source: SourceId.yandex,
        reason: SourceFailReason.unavailable,
      ),
    ];
    youtube.failures = [
      const SourceFailure(
        source: SourceId.youtube,
        reason: SourceFailReason.geoBlocked,
      ),
    ];

    final result = await run();

    expect(result.isOk, isFalse);
    expect(result.exhausted, isTrue);
    expect(result.failures.map((f) => f.source), [
      SourceId.yandex,
      SourceId.youtube,
    ]);
  });

  test('bypassCache сбрасывает хранилище и требует новой подписи', () async {
    yandex.result = readyUrl(SourceId.yandex);
    await run();

    final result = await run(bypassCache: true);

    expect(store.invalidations, ['$trackId|yandex']);
    expect(yandex.resolveCalls, 2);
    expect(result.isOk, isTrue);
  });

  test('источник без варианта этого трека не вызывается', () async {
    youtube.result = readyUrl(SourceId.youtube);

    final result = await resolver.resolve(
      localTrackId: trackId,
      variants: [variant(SourceId.youtube)],
    );

    expect(yandex.resolveCalls, 0);
    expect(result.playback?.usedSource, SourceId.youtube);
  });

  test('совпавшие запросы коалесцируются в одну подпись', () async {
    yandex.result = readyUrl(SourceId.yandex);

    final results = await Future.wait([run(), run(), run()]);

    expect(yandex.resolveCalls, 1);
    expect(results.every((r) => r.isOk), isTrue);
  });
}
