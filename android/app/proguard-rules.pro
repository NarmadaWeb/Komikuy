# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.provider.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Google Mobile Ads / Play Services
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.**

# Native / JNI
-keepclasseswithmembernames class * {
    native <methods>;
}
