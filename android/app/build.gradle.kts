import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = readProperties(file("../local.properties"));

var flutterVersionCode = localProperties["flutter.versionCode"];
if (flutterVersionCode == null) {
    flutterVersionCode = "1"
}

var flutterVersionName = localProperties["flutter.versionName"];
if (flutterVersionName == null) {
    flutterVersionName = "1.0"
}

var googleMapsApiKey = localProperties["googleMaps.apiKey"];
if (googleMapsApiKey == null) {
    googleMapsApiKey = "NO_API_KEY_FOUND"
}

val keystoreProperties = readProperties(file("../key.properties"));

android {
    namespace = "dev.alpagaga.points_verts"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "dev.alpagaga.points_verts"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["mapApiKey"] = googleMapsApiKey as String
    }

    signingConfigs {
        create("release") {
            if (localProperties.containsKey("keyAlias")) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }
    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}

fun readProperties(propertiesFile: File) = Properties().apply {
    if (propertiesFile.exists()) {
        propertiesFile.inputStream().use { fis ->
            load(fis)
        }
    } else {
        Properties()
    }
}