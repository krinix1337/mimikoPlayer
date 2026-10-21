# Живые проверки

Помеченные здесь пункты нельзя считать сделанными, пока нет реального ответа
сервера или устройства. Раздел «подтверждено» — фактические ответы, раздел
«осталось» — то, что ещё не проверялось.

## Подтверждено 2026-10-21 (зонд `tool/probe/yandex_probe.dart`, аккаунт с Плюс)

### Авторизация — OAuth device flow работает

- `POST https://oauth.yandex.ru/device/code`, форма `client_id`, `device_id`,
  `device_name` → `device_code`, `user_code`, `verification_url`
  (= `https://ya.ru/device`), `interval`, `expires_in` = 300.
- `POST https://oauth.yandex.ru/token`, форма `grant_type=device_code`, `code`,
  `client_id`, `client_secret` → пока не подтверждено, `error=authorization_pending`;
  после подтверждения — `access_token` (55 симв.), `expires_in` = 31 536 000 (год),
  `refresh_token` **есть**.
- Реквизиты клиента (`client_id` 23cabbbd…, `client_secret` 53bc7523…) публичные:
  они вшиты в открытые реализации device flow для Я.Музыки и не являются
  секретом. Лежат в `lib/core/env.dart` с возможностью перебить через
  `--dart-define`.
- Запросы к API: `Authorization: OAuth <token>` + `Accept-Language: ru`,
  ответ всегда завёрнут в `result`.

### Эндпоинты (всё это отдали реальные вызовы)

| Что | Как отвечает |
|---|---|
| `GET /account/status` | `result.account{uid,login}`, `result.plus{hasPlus}` |
| `GET /search?text=&type=track&page=&page-size=` | `result.tracks{order,perPage,results,total}` — страница в **`results`**, ключа `items` нет (в доноре reads `items`, поэтому его поиск всегда пустой). `total`=64119 на «queen» |
| `GET /tracks?track-ids=<csv>` | только числовые id; `id-albumId` → `400 validate`. То же и для `GET /tracks/<id>/download-info`: составной id даёт `400 illegal-argument` (на этом приложение и спотыкалось, пока в маппинге лежал составной ключ) |
| `GET /users/<uid>/likes/tracks` | `result.library.tracks[]{id,albumId,timestamp}` — 1027 записей |
| `GET /users/<uid>/playlists/list` | `result[]` — плейлисты **без** треков: `kind,title,trackCount,cover.uri,modified,uid,visibility,metaType…` |
| `GET /users/<uid>/playlists?kinds=<kind>,…` | `result[]` с `tracks[]` (проверено: kind 1006 → 54 трека). Без `kinds` → `400 validate: kinds not set` |
| `GET /rotor/station/user:onyourwave/tracks?queue=1` | `result.sequence[].track` — 5 треков, объект трека полный |
| `GET /rotor/stations/list` | `result[]` из 702 станций, id — объект `{type, tag}` → в URL как `genre:pop`, `user:onyourwave` |
| `GET /rotor/station/<id>/settings` | `result{language, mood, energy, diversity}` — mood/energy числа 0..4 (2 = середина), diversity строка |

### Поток: классический `download-info` жив, HMAC не нужен

1. `GET /tracks/<trackId>/download-info` → `result[]` `{codec:"mp3", bitrateInKbps:192, downloadInfoUrl}`.
2. `GET <downloadInfoUrl>` с `Authorization: OAuth` → XML с полями `host`, `path`, `ts`, `region`, `s`.
3. `sign = md5hex("<соль>" + path.substring(1) + s)`, соль `XGRvlVRHweBcSULG`.
4. `https://{host}/get-mp3/{sign}/{ts}{path}` → `206 Partial Content`,
   `bytes 0-2047/3088927`, первые байты `ff fb b0` (кадр MPEG). **Заголовок
   авторизации этому URL не нужен** — проверено без него, те же байты. Значит
   just_audio играет его напрямую, и скачивание на этапе «офлайн» не требует
   токена.
5. Подставленный неверный `ts` → `401`: адрес привязан к `ts`, то есть ссылка
   протухает по времени.

Донор (`mimikoMusic`) в этом месте ошибался дважды: соль была другой, и вместо
MD5 считался обрезанный SHA-256 — поэтому его ссылки не играли.

### Что в Яндексе недоступно

- **`isrc` нет ни в поиске, ни в `/tracks`** (ключа нет в объекте трека).
  Значит сведение треков между каталогами на этапе резервных источников
  строится на нормализованных имени, артисте и длительности; ISRC-путь в
  `track_identity.dart` останется, но с Яндекса он не заполнится.
- `GET /v2.0/track/<id>/get-file-info` → `404 not-found`.
- `GET /get-file-info` существует (отвечает `music-resource-provider`): с
  `quality=mp3-128` → `400 illegal-argument`, с `quality=lossless` →
  `403 track-download-info-error / not-allowed`. Ни одна из проверенных солей
  (`7tvSmFbyf5hJnIHhCimDDD`, `kzqU4XhfCaY6B6JTHODeq5`, `XGRSTTXRwyKgnhHQBEZkg`)
  не дала валидного ответа; вариант `XGRvlVRHweBcSULG` + MD5 через
  `download-info` работает, поэтому HMAC-схему не исследуем.
- `/albums/<id>/tracks` → `404`, `/tracks/<id>-<albumId>` (композит) → `400`.

## Осталось подтвердить

1. Реальный TTL ссылки `get-mp3`: сейчас в `defaultStreamTtl` консервативные
   20 минут. Замеряется повторным запросом той же ссылки через N минут.
2. `POST /rotor/station/<id>/settings` — запись настроек волны (кнопка
   «Применить» в приложении). Форму тела угадали по ответу GET, живого
   подтверждения принятия ещё не было.
3. `POST /rotor/station/<id>/feedback` — приложение отправляет его с телефона
   (после `trackStarted`), но принят ли сервером — не видно: отказ теперь
   пишется в лог (`rotor feedback … не принят`), а не глотается. Проверить на
   следующем прогоне с разблокированным телефоном.
4. Лайки из приложения (`POST/DELETE /users/<uid>/likes/tracks?track-id=`) —
   то же самое: запись в чужой аккаунт только по явному действию пользователя.
5. Поведение тех же эндпоинтов через VPN с раздельным туннелированием (пункт
   плана «тест») и на Android 17: `cmd audio set-enable-hardening` на API 36 не
   действует, то есть ограничения while-in-use пока не проверялись совсем.
6. Восстановление по media-кнопке после смерти процесса: на MIUI система не
   подняла приложение ни по `KEYCODE_MEDIA_PLAY`, ни явным `MEDIA_BUTTON`
   (снимок очереди в БД при этом есть). Нужно проверить свайпом из Recents и на
   другом ROM.
7. `audio_service` 0.18.19 — legacy `androidx.media` (не Media3
   `MediaSessionService`), манифест плагина пустой, `startForeground` вызывается
   без type-флага; тип `mediaPlayback` приходит из нашего манифеста (проверено:
   `dumpsys activity services` → `types=0x00000002`).
8. `drift_flutter` тянет `sqlite3_flutter_libs 0.6.0+eol` и
   `sqlcipher_flutter_libs 0.7.0+eol` (оба помечены EOL). На устройстве БД
   создаётся и пишет (`app_flutter/phoneyandex.sqlite` + `-wal`), в тестах
   нативный SQLite тоже поднимается.
