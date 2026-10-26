plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Вторая, тестовая установка: тот же код, но отдельный applicationId и имя.
// Включается только сборкой с ORG_GRADLE_PROJECT_md3test=true; обычный APK
// остаётся пакетом net.nekto.phoneyandex.
val md3Test = project.findProperty("md3test")?.toString()?.toBoolean() ?: false

android {
    namespace = "net.nekto.phoneyandex"
    compileSdk = 37
    // Android 17 распространяется минорными платформами: в SDK это каталог
    // android-37.0, и без minor AGP ищет несуществующий android-37.
    compileSdkMinor = 0
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "net.nekto.phoneyandex"
        minSdk = flutter.minSdkVersion
        targetSdk = 37
        manifestPlaceholders["appLabel"] = if (md3Test) {
            "mimikoPlayer MD3"
        } else {
            "mimikoPlayer"
        }
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        debug {
            if (md3Test) applicationIdSuffix = ".md3test"
        }
        release {
            if (md3Test) applicationIdSuffix = ".md3test"
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
