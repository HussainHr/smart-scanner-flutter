# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Google ML Kit
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.mlkit.**
-dontwarn com.google.android.gms.**

# Mobile Scanner / CameraX
-keep class androidx.camera.** { *; }
-dontwarn androidx.camera.**

# Media Store Plus
-keep class com.snnafi.media_store_plus.** { *; }

# Path Provider
-keep class io.flutter.plugins.pathprovider.** { *; }

# Share Plus
-keep class dev.fluttercommunity.plus.share.** { *; }

# Gson / reflection used by plugins
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
