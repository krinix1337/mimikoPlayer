<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/hero-dark.svg">
  <img src="docs/hero-light.svg" width="100%" alt="mimikoPlayer — музыкальный плеер для Android на Material 3">
</picture>

<br>

<a href="https://github.com/krinix1337/mimikoPlayer/releases/latest"><img alt="Версия 1.3.2" src="https://img.shields.io/badge/версия-1.3.2-D8F544?style=for-the-badge&labelColor=1C1B1F"></a>
<img alt="Android 8.0+" src="https://img.shields.io/badge/Android-8.0%2B-3DDC84?style=for-the-badge&logo=android&logoColor=white&labelColor=1C1B1F">
<a href="https://flutter.dev"><img alt="Flutter 3.47" src="https://img.shields.io/badge/Flutter-3.47-02569B?style=for-the-badge&logo=flutter&logoColor=white&labelColor=1C1B1F"></a>
<img alt="191 тест" src="https://img.shields.io/badge/тесты-191-22C7A9?style=for-the-badge&labelColor=1C1B1F">
<img alt="Лицензия MIT" src="https://img.shields.io/badge/лицензия-MIT-A78BFA?style=for-the-badge&labelColor=1C1B1F">

<h3>Яндекс Музыка, SoundCloud и свои файлы — в одном плеере</h3>

<p>
  <a href="#-возможности"><b>Возможности</b></a> ·
  <a href="#-скриншоты"><b>Скриншоты</b></a> ·
  <a href="#-установка"><b>Установка</b></a> ·
  <a href="#-что-нового-в-132"><b>Что нового</b></a> ·
  <a href="#-архитектура"><b>Архитектура</b></a> ·
  <a href="#-сборка"><b>Сборка</b></a>
</p>

</div>

<br>

Один экран «Сейчас играет», одна очередь и одна коллекция — независимо от того, откуда пришёл трек. Если источник не отдаёт песню, плеер сам находит её в другом. Интерфейс собран на токенах **Material 3 Expressive** и показывает только настоящие данные.

> [!NOTE]
> Только Android. Проект не связан с Яндексом и SoundCloud и предназначен для личного использования.

## ✨ Возможности

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/features-dark.svg">
  <img src="docs/features-light.svg" width="100%" alt="Моя волна, плеер, коллекция, караоке, источники и оформление">
</picture>

<table>
  <tr>
    <td width="50%" valign="top">

### 🌊 Моя волна
- Персональные рекомендации Яндекса, докачка без повторов
- Режимы колесом: настроение, язык, характер
- **Волна целиком из SoundCloud** на его рекомендациях
- Дизлайк убирает трек — больше он сам не заиграет

</td>
    <td width="50%" valign="top">

### 🎧 Плеер
- Фоновое воспроизведение, уведомление и экран блокировки
- Очередь переживает перезапуск, повтор и перемешивание тоже
- Эквалайзер: 8 пресетов и своя 10-полосная кривая
- Таймер сна — пауза в конце текущего трека

</td>
  </tr>
  <tr>
    <td valign="top">

### 📚 Коллекция
- Любимое, плейлисты, артисты, недавние, файлы
- Свои плейлисты с синхронизацией в Яндекс
- Офлайн: очередь загрузок, докачка, лимит места
- Автозагрузка лайков по Wi-Fi

</td>
    <td valign="top">

### 🎤 Караоке
- Синхронный текст из LRCLIB, запасной — из Яндекса
- Плавная подсветка строки, перемотка тапом
- Размер текста и приглушение остальных строк

</td>
  </tr>
  <tr>
    <td valign="top">

### 🎨 Оформление
- Светлая, тёмная, Material You, монохром, AMOLED
- 10 акцентов и 10 значков лаунчера
- Адаптивное стекло и размытие обложек
- Русский и английский интерфейс

</td>
    <td valign="top">

### 🛡️ Фильтры и обновления
- Метки 18+, ИИ и «без цензуры»
- Скрытие ИИ-треков по списку Slopless
- Обновления прямо из приложения с проверкой SHA-256

</td>
  </tr>
</table>

## 📱 Скриншоты

<div align="center">
<table>
  <tr>
    <td align="center" width="25%"><img src="docs/screenshots/home.webp" alt="Моя волна"><br><sub><b>Моя волна</b></sub></td>
    <td align="center" width="25%"><img src="docs/screenshots/player.webp" alt="Плеер"><br><sub><b>Сейчас играет</b></sub></td>
    <td align="center" width="25%"><img src="docs/screenshots/collection.webp" alt="Коллекция"><br><sub><b>Коллекция</b></sub></td>
    <td align="center" width="25%"><img src="docs/screenshots/settings.webp" alt="Настройки"><br><sub><b>Настройки</b></sub></td>
  </tr>
</table>
</div>

## 📦 Установка

1. Скачайте `mimikoPlayer-1.3.2.apk` со страницы **[Releases](https://github.com/krinix1337/mimikoPlayer/releases/latest)**.
2. Откройте файл и разрешите установку из этого источника.
3. Войдите в Яндекс в разделе **Настройки → Аккаунт и сервисы**. SoundCloud и локальные файлы работают без входа.

> [!TIP]
> Дальше обновляться можно из самого приложения: **Настройки → Обновления**. Нужен fine-grained токен GitHub с доступом *Contents: Read-only*; он хранится только на телефоне.

> [!IMPORTANT]
> На Xiaomi с HyperOS отключите для приложения оптимизацию батареи и разрешите автозапуск — иначе система может останавливать фоновое воспроизведение и загрузки.

## 🆕 Что нового в 1.3.2

| | |
|---|---|
| 🐞 **Плеер** | Повтор и перемешивание сохраняются после перезапуска · пауза во время загрузки трека больше не игнорируется · без лишних записей в истории |
| 👎 **Дизлайк** | Кнопка слева от управления, трек сразу убирается из очереди и больше не играет сам |
| 🌊 **Волна** | Нет повторов песен · конец очереди докачивается, а не начинается заново · режим SoundCloud — карточка в колесе |
| ⚡ **Скорость** | При переходах и в колесе режимов пропущенных кадров в 10–20 раз меньше: размытие обложек считается один раз |
| ✏️ **Интерфейс** | Плеер не выскакивает при каждом треке (настраивается) · склонения «1 трек / 2 трека» · ровные колонки и подписи |

<details>
<summary><b>Полный список изменений</b></summary>

<br>

**Плеер**
- Удаление трека выше текущего больше не сдвигает очередь; дубли удаляются точечно.
- Play после конца очереди начинает трек сначала, а не зависает.
- Переключение трека во время загрузки не пропускает выбранный.
- Без щелчка громкости на паузе.
- Защита от зависаний потока срабатывает повторно.

**Волна**
- Ротор Яндекса получает последний трек очереди и отдаёт продолжение.
- Одна песня в разных релизах склеивается и не повторяется.
- Режим SoundCloud: старт от исполнителей вашей волны, дальше — «похожие» SoundCloud; перезаливы отсеиваются.
- Треки только с зашифрованным потоком отсеиваются сразу.

**Загрузки и система**
- Оборванная загрузка не сохраняется как готовая — докачается по Range.
- Чтение тегов локальных файлов вынесено из UI-потока.

**Интерфейс**
- Название плейлиста в шапке плеера; «слушателей» у артиста; значок «Нелюбимого».
- Выравнивание длительностей, подписей карточек, меню трека и таймера сна.
- Локализованные единицы размера, длинные заголовки настроек не обрезаются.

</details>

## 🧩 Архитектура

Каждый источник — модуль за общим интерфейсом. Если источник не может отдать трек, резолвер идёт к следующему по приоритету, а экраны не знают, откуда пришла музыка.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/architecture-dark.svg">
  <img src="docs/architecture-light.svg" width="100%" alt="Яндекс Музыка, SoundCloud и свои файлы → MusicSource → StreamResolver → PlaybackController → just_audio и экраны">
</picture>

<details>
<summary><b>Структура проекта</b></summary>

```
lib/
├── core/
│   ├── sources/     MusicSource, DTO, типизированные отказы, StreamResolver
│   ├── identity/    нормализация и сведение трека из разных каталогов
│   ├── db/          drift, DAO, аддитивные миграции
│   ├── prefs/       настройки одним снимком
│   └── platform/    мост в Android: частота кадров, значки, теги
├── features/        волна, поиск, коллекция, плеер, каталог, караоке, настройки
├── sources/         yandex, soundcloud, local, lyrics
├── l10n/            строки RU / EN
└── theme/           токены M3: цвет, типографика, формы, движение
```

</details>

| Слой | Технологии |
|---|---|
| UI | Flutter 3.47 · Material 3 Expressive · Riverpod 3 · go_router |
| Звук | just_audio (media3 / ExoPlayer) · audio_service |
| Данные | drift + SQLite |
| Сеть | dio · Yandex Music API · SoundCloud · LRCLIB |
| Фон | WorkManager |

## 🛠️ Сборка

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter analyze && flutter test
flutter build apk --release
```

`compileSdk = targetSdk = 37`, `minSdk = 24`. Готовый файл — `build/app/outputs/flutter-apk/app-release.apk`.

<details>
<summary><b>Замер плавности на устройстве</b></summary>

<br>

Сборка со счётчиком кадров пишет в logcat, сколько кадров не уложилось в бюджет и чем — сборкой или отрисовкой:

```bash
flutter build apk --profile --dart-define=FRAME_STATS=true
adb logcat -s flutter | grep frames
```

</details>

> [!WARNING]
> Не передавайте `--dart-define=GITHUB_TOKEN=...` в сборки, которые раздаёте другим: токен окажется внутри APK.

## ⚖️ Лицензия и данные

MIT — см. [LICENSE](LICENSE).

- «Яндекс Музыка» и SoundCloud — товарные знаки своих правообладателей; проект с ними не связан.
- Тексты песен приходят из публичных источников по запросу пользователя.
- Список ИИ-исполнителей — [Slopless](https://github.com/alexeyfv/slopless) (GPL-3.0), загружается по сети и не входит в APK.
- Незацензуренные версии — открытая база [FckCensorData](https://github.com/Hazzz895/FckCensorData), загружается по сети.

<div align="center">
<br>
<sub>mimikoPlayer · сделано <a href="https://github.com/krinix1337">krinix1337</a> на Flutter</sub>
</div>
