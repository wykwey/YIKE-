plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.yiclass"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.1.13356709"  // 手动指定 NDK 版本为 27.0.12077973

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

signingConfigs {
    create("release") {
        storeFile = file("upload-keystore.jks")
        storePassword = System.getenv("KEYSTORE_PASSWORD")
        keyAlias = System.getenv("KEY_ALIAS")
        keyPassword = System.getenv("KEY_PASSWORD")
    }
}

buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
        isMinifyEnabled = false
        isShrinkResources = false
    }
}

	debug {
		signingConfig = signingConfigs.getByName("debug")
		isMinifyEnabled = false
		isShrinkResources = false
	}
}


flutter {
    source = "../.."
}
