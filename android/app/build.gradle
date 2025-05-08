plugins {
    id 'com.android.application'
    id 'kotlin-android'
    // Flutter 插件必须放在后面
    id 'dev.flutter.flutter-gradle-plugin'
}

android {
    namespace "com.example.yiclass"
    compileSdkVersion flutter.compileSdkVersion
    ndkVersion "28.1.13356709"

    defaultConfig {
        // 设置最低 SDK 版本为 21
        minSdkVersion 21
        targetSdkVersion 33  // 推荐使用最新的 SDK 版本
        versionCode flutter.versionCode.toInteger()
        versionName flutter.versionName
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_11
        targetCompatibility JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    signingConfigs {
        release {
            storeFile file("upload-keystore.jks")
            storePassword System.getenv("KEYSTORE_PASSWORD")
            keyAlias System.getenv("KEY_ALIAS")
            keyPassword System.getenv("KEY_PASSWORD")
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled false
            shrinkResources false
        }
        debug {
            signingConfig signingConfigs.debug
            minifyEnabled false
            shrinkResources false
        }
    }
}

flutter {
    source '../..'
}

