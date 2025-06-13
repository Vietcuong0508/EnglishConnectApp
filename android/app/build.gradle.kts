import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Method 1: Using Properties with proper error handling
val dotenv = Properties()
val dotenvFile = File(rootProject.projectDir.parent, ".env") // Go up one level from android folder
if (dotenvFile.exists()) {
    try {
        dotenvFile.inputStream().use { inputStream ->
            dotenv.load(inputStream)
        }
        println("Loaded .env file successfully")
    } catch (e: Exception) {
        println("Error loading .env file: ${e.message}")
    }
} else {
    println(".env file not found at: ${dotenvFile.absolutePath}")
}

// Method 2: Alternative - Manual parsing (uncomment if Properties method fails)
/*
fun loadEnvFile(file: File): Map<String, String> {
    val envMap = mutableMapOf<String, String>()
    if (file.exists()) {
        file.readLines().forEach { line ->
            val trimmedLine = line.trim()
            if (trimmedLine.isNotEmpty() && !trimmedLine.startsWith("#")) {
                val parts = trimmedLine.split("=", limit = 2)
                if (parts.size == 2) {
                    envMap[parts[0].trim()] = parts[1].trim()
                }
            }
        }
    }
    return envMap
}

val envVars = loadEnvFile(rootProject.file(".env"))
*/

android {
    namespace = "com.tvc.english_connect"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = dotenv.getProperty("APP_ID") ?: "com.example.default"
        
        // Debug prints to check if values are loaded
        println("APP_ID: ${dotenv.getProperty("APP_ID")}")
        println("APP_NAME: ${dotenv.getProperty("APP_NAME")}")
        println("VER_CODE: ${dotenv.getProperty("VER_CODE")}")
        println("VER_NAME: ${dotenv.getProperty("VER_NAME")}")
        
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 21
        targetSdk = 34
        versionCode = dotenv.getProperty("VER_CODE")?.toIntOrNull() ?: 1
        versionName = dotenv.getProperty("VER_NAME") ?: "1.0.0"
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}