# Flutter ProGuard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# WebRTC & LiveKit Keep Rules
-keep class org.webrtc.** { *; }
-keep class io.livekit.** { *; }
-dontwarn org.webrtc.**
-dontwarn io.livekit.**

# Anti-Piracy DRM Channel Protection
-keep class com.pindofuture.pindo_future_mobile.MainActivity { *; }
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Android Architecture Components
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod
