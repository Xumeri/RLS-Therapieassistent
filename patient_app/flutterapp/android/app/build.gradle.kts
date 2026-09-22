plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")

    // Flutter-Gradle-Plugin (erforderlich für Flutter-Android-Projekte)
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.flutterapp"

    // Erforderlich für aktuelle Android-Features und
    // flutter_local_notifications (Android 13+)
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17

        // Notwendig für zeitgesteuerte Benachrichtigungen
        // mit Rückwärtskompatibilität (Desugaring)
        isCoreLibraryDesugaringEnabled = true
    }
/*
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }
    */
    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }

    defaultConfig {
        applicationId = "com.example.flutterapp"
        minSdk = flutter.minSdkVersion

        // Ziel-SDK für Android 14/15 Verhalten
        targetSdk = 35

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Debug-Signing für Uni-/Emulator-Builds ausreichend
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Erforderlich für Java-API-Desugaring (flutter_local_notifications ≥ v10)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")

    // Stabilitätsfix für bekannte Crashes auf Android 12L+
    implementation("androidx.window:window:1.2.0")
}
