package com.ryanheise.audioservice;

import android.content.Intent;
import android.support.v4.media.session.MediaSessionCompat;
import android.util.Log;
import android.view.KeyEvent;

import java.lang.reflect.Field;

/**
 * audio_service превращает KEYCODE_MEDIA_PLAY и KEYCODE_MEDIA_PAUSE в «клик»,
 * а клик в Dart — это переключатель. Из-за этого кнопка «пауза» гарнитуры или
 * машины на паузе запускала музыку. Здесь PLAY всегда играет, PAUSE всегда
 * ставит паузу, остальное идёт в обработчик плагина как было.
 *
 * Класс лежит в пакете плагина: поле {@code instance} у AudioService видно
 * только из него. Сама сессия приватная, её достаём по типу поля (имя после
 * R8 может поменяться). Любой сбой оставляет поведение плагина.
 */
public final class MimikoMediaButtons {
    private static final String TAG = "MimikoMediaButtons";
    private static MediaSessionCompat patched;

    private MimikoMediaButtons() {}

    public static void install() {
        try {
            final AudioService service = AudioService.instance;
            if (service == null) return;
            MediaSessionCompat session = null;
            for (Field field : AudioService.class.getDeclaredFields()) {
                if (field.getType() == MediaSessionCompat.class) {
                    field.setAccessible(true);
                    session = (MediaSessionCompat) field.get(service);
                    break;
                }
            }
            if (session == null || session == patched) return;
            session.setCallback(new Callback(service));
            patched = session;
        } catch (Throwable error) {
            Log.w(TAG, "media buttons patch skipped", error);
        }
    }

    static final class Callback extends AudioService.MediaSessionCallback {
        Callback(AudioService outer) {
            outer.super();
        }

        @Override
        public boolean onMediaButtonEvent(Intent mediaButtonEvent) {
            final KeyEvent event = mediaButtonEvent == null
                    ? null
                    : (KeyEvent) mediaButtonEvent.getParcelableExtra(Intent.EXTRA_KEY_EVENT);
            if (event != null) {
                final int code = event.getKeyCode();
                if (code == KeyEvent.KEYCODE_MEDIA_PLAY || code == KeyEvent.KEYCODE_MEDIA_PAUSE) {
                    if (event.getAction() == KeyEvent.ACTION_DOWN) {
                        if (code == KeyEvent.KEYCODE_MEDIA_PLAY) {
                            onPlay();
                        } else {
                            onPause();
                        }
                    }
                    return true;
                }
            }
            return super.onMediaButtonEvent(mediaButtonEvent);
        }
    }
}
