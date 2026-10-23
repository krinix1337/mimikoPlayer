package net.nekto.phoneyandex

import android.content.ComponentName
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.Build
import android.os.Environment
import android.os.StatFs
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.plugin.common.MethodChannel

/**
 * AudioServiceActivity — требование плагина audio_service, поэтому свой класс
 * наследуется от него, а не от FlutterActivity.
 *
 * Здесь две вещи, которые нельзя сделать из Dart:
 *  1) запрос высокой частоты кадров окну (без него HyperOS держит приложение
 *     на 60 Гц, даже когда панель настроек телефона стоит на 120);
 *  2) переключение значка в лаунчере через activity-alias.
 */
class MimikoActivity : AudioServiceActivity() {
    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        applyFrameRate(preferredHz)
        // FlutterView появляется не в onCreate, а когда движок прицепился к
        // окну — просим частоту ещё раз после первой раскладки.
        window.decorView.post { applyFrameRate(preferredHz) }
    }

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "setFrameRate" -> {
                    preferredHz = (call.arguments as? Number)?.toFloat() ?: 0f
                    applyFrameRate(preferredHz)
                    result.success(actualRefreshRate())
                }

                "actualRefreshRate" -> result.success(actualRefreshRate())

                "getMediaInfo" -> {
                    val path = call.arguments as? String
                    if (path.isNullOrBlank()) {
                        result.error("bad_argument", "path пустой", null)
                    } else {
                        result.success(mediaInfo(path))
                    }
                }

                "setLauncherIcon" -> {
                    val component = call.arguments as? String
                    if (component.isNullOrBlank()) {
                        result.error("bad_argument", "component пустой", null)
                    } else {
                        runCatching { setLauncherIcon(component) }
                            .onSuccess { result.success(true) }
                            .onFailure { result.error("icon_failed", it.message, null) }
                    }
                }

                "freeBytes" -> result.success(freeBytes())

                "networkStatus" -> result.success(networkStatus())

                else -> result.notImplemented()
            }
        }
    }

    private var preferredHz = 120f

    @Suppress("DEPRECATION")
    private fun displayOrNull(): android.view.Display? =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) display
        else windowManager.defaultDisplay

    /**
     * `preferredFrameRate` в публичном API нет, есть два рабочих рычага:
     * `preferredDisplayModeId` (API 31) выбирает режим всему дисплею, а
     * `View.setRequestedFrameRate` (тоже API 31) подтверждает намерение
     * на стороне контента. Плюс boost-on-touch: без него HyperOS снижает
     * частоту, пока палец не коснулся экрана.
     */
    private fun applyFrameRate(hz: Float) {
        val params = window.attributes
        val modes = displayOrNull()?.supportedModes ?: return

        if (hz <= 0f) {
            params.preferredDisplayModeId = 0
            window.attributes = params
            return
        }

        modes
            .filter { it.refreshRate >= hz - 1f }
            .minByOrNull { it.refreshRate }
            ?.let { params.preferredDisplayModeId = it.modeId }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            params.setFrameRateBoostOnTouchEnabled(true)
        }
        window.attributes = params

        val content = findViewById<android.view.View>(android.R.id.content)
        if (content != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            applyRateToTree(content)
        }
    }

    /** FlutterView лежит не в самом content, а в его дочернем контейнере. */
    private fun applyRateToTree(view: android.view.View) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            view.requestedFrameRate = preferredHz
        }
        if (view is android.view.ViewGroup) {
            for (i in 0 until view.childCount) applyRateToTree(view.getChildAt(i))
        }
    }

    /**
     * Метаданные из тега файла: название, исполнитель, альбом, длительность и
     * обложка. Без этого локальная фонотека — список имён файлов.
     */
    private fun mediaInfo(path: String): Map<String, Any?> {
        val retriever = android.media.MediaMetadataRetriever()
        return try {
            retriever.setDataSource(path)
            val art = retriever.embeddedPicture
            mapOf(
                "title" to retriever.extractMetadata(
                    android.media.MediaMetadataRetriever.METADATA_KEY_TITLE,
                ),
                "artist" to retriever.extractMetadata(
                    android.media.MediaMetadataRetriever.METADATA_KEY_ARTIST,
                ),
                "album" to retriever.extractMetadata(
                    android.media.MediaMetadataRetriever.METADATA_KEY_ALBUM,
                ),
                "durationMs" to (retriever.extractMetadata(
                    android.media.MediaMetadataRetriever.METADATA_KEY_DURATION,
                )?.toLongOrNull() ?: 0L),
                "art" to art,
            )
        } catch (e: Exception) {
            mapOf("error" to (e.message ?: "retriever failed"))
        } finally {
            runCatching { retriever.release() }
        }
    }

    private fun actualRefreshRate(): Float =
        runCatching { displayOrNull()?.refreshRate ?: 0f }.getOrDefault(0f)

    /** Свободное место на разделе данных: нужно для лимита загрузок. */
    private fun freeBytes(): Long =
        runCatching {
            StatFs(Environment.getDataDirectory().absolutePath).availableBytes
        }.getOrDefault(0L)

    /**
     * Проверяем физическую Wi-Fi-сеть отдельно от активного VPN: иначе
     * автозагрузка навсегда ждёт «Wi-Fi», которого не видно за туннелем.
     */
    private fun networkStatus(): Map<String, Boolean> {
        val manager = getSystemService(ConnectivityManager::class.java)
        val active = manager.activeNetwork
        val activeCaps = active?.let { manager.getNetworkCapabilities(it) }
        val all = manager.allNetworks.mapNotNull {
            manager.getNetworkCapabilities(it)
        }
        val wifi = all.any {
            it.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) &&
                it.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED)
        }
        val unmetered =
            activeCaps?.hasCapability(NetworkCapabilities.NET_CAPABILITY_NOT_METERED) == true ||
                all.any {
                    it.hasCapability(NetworkCapabilities.NET_CAPABILITY_NOT_METERED) &&
                        it.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED)
                }
        val connected =
            activeCaps?.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) == true
        return mapOf(
            "connected" to connected,
            "wifi" to wifi,
            "unmetered" to unmetered,
            "vpn" to (activeCaps?.hasTransport(NetworkCapabilities.TRANSPORT_VPN) == true),
        )
    }

    /**
     * В лаунчере всегда ровно один включённый алиас: основной activity
     * стартового фильтра не имеет, иначе отключить «дефолтный» значок
     * было бы нельзя.
     */
    private fun setLauncherIcon(component: String) {
        for (alias in ALIASES) {
            val enable = alias == component
            val state = if (enable) {
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED
            } else {
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED
            }
            packageManager.setComponentEnabledSetting(
                ComponentName(packageName, "$packageName.$alias"),
                state,
                PackageManager.DONT_KILL_APP,
            )
        }
    }

    companion object {
        private const val CHANNEL = "net.nekto.mimiko/platform"
        private val ALIASES = listOf(
            "MimikoLauncherDefault",
            "MimikoLauncherAcid",
            "MimikoLauncherMono",
            "MimikoLauncherNight",
            "MimikoLauncherSunset",
            "MimikoLauncherMint",
            "MimikoLauncherViolet",
            "MimikoLauncherIce",
            "MimikoLauncherAmber",
            "MimikoLauncherForest",
        )
    }
}
