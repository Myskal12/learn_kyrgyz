import java.io.FileInputStream
import java.util.Properties
import groovy.json.JsonSlurper
import org.gradle.api.GradleException

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystorePropertiesFile.exists()

if (hasReleaseKeystore) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

val configuredAppId =
    (project.findProperty("APP_ID") as String?) ?: "com.example.learn_kyrgyz"
val googleServicesFile = file("google-services.json")

fun parseGoogleServicesPackageName(file: File): String? {
    if (!file.exists()) return null

    val payload = JsonSlurper().parse(file) as? Map<*, *> ?: return null
    val clients = payload["client"] as? List<*> ?: return null
    for (client in clients) {
        val clientMap = client as? Map<*, *> ?: continue
        val clientInfo = clientMap["client_info"] as? Map<*, *> ?: continue
        val androidInfo = clientInfo["android_client_info"] as? Map<*, *> ?: continue
        val packageName = androidInfo["package_name"]?.toString()?.trim()
        if (!packageName.isNullOrEmpty()) {
            return packageName
        }
    }
    return null
}

fun validateReleaseConfiguration() {
    val releaseAppId = configuredAppId.trim()
    if (releaseAppId.isEmpty() || releaseAppId.startsWith("com.example")) {
        throw GradleException(
            "Release builds require a final APP_ID. Current value: '$releaseAppId'. " +
                "Run Gradle with -PAPP_ID=com.yourcompany.app",
        )
    }

    if (!hasReleaseKeystore) {
        throw GradleException(
            "Release builds require android/key.properties and a real signing keystore. " +
                "Copy android/key.properties.example to android/key.properties and fill real values.",
        )
    }

    val requiredKeys = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
    val missingKeys = requiredKeys.filter { key ->
        keystoreProperties.getProperty(key)?.trim().isNullOrEmpty()
    }
    if (missingKeys.isNotEmpty()) {
        throw GradleException(
            "android/key.properties is missing required values: ${missingKeys.joinToString(", ")}",
        )
    }

    val storeFilePath = keystoreProperties.getProperty("storeFile").trim()
    val releaseStoreFile = file(storeFilePath)
    if (!releaseStoreFile.exists()) {
        throw GradleException(
            "Release keystore file does not exist: ${releaseStoreFile.absolutePath}",
        )
    }

    if (!googleServicesFile.exists()) {
        throw GradleException(
            "android/app/google-services.json is required for release builds.",
        )
    }

    val googlePackageName = parseGoogleServicesPackageName(googleServicesFile)
    if (googlePackageName.isNullOrEmpty()) {
        throw GradleException(
            "Could not read package_name from android/app/google-services.json",
        )
    }

    if (googlePackageName != releaseAppId) {
        throw GradleException(
            "APP_ID ($releaseAppId) does not match google-services.json package_name ($googlePackageName). " +
                "Download a matching Firebase config before building release.",
        )
    }
}

android {
    namespace = "com.example.learn_kyrgyz"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = configuredAppId
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (hasReleaseKeystore) {
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

afterEvaluate {
    tasks.matching { task ->
        task.name == "assembleRelease" ||
            task.name == "bundleRelease" ||
            task.name == "packageRelease"
    }.configureEach {
        doFirst {
            validateReleaseConfiguration()
        }
    }
}

flutter {
    source = "../.."
}
