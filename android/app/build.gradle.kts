plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    ndkVersion = "28.1.13356709"
    namespace = "com.yiclass.app"  
    compileSdk = flutter.compileSdkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {

        applicationId = "com.yiclass.app"  // 必须与namespace保持一致
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // 使用解码的 keystore 文件路径
            storeFile = file("android/app/upload-keystore.jks")
            storePassword = System.getenv("KEYSTORE_PASSWORD") ?: "your_default_password"
            keyAlias = System.getenv("KEY_ALIAS") ?: "your_default_alias"
            keyPassword = System.getenv("KEY_PASSWORD") ?: "your_default_key_password"
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
