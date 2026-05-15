
# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# AdMob
-keep class com.google.android.gms.ads.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }

# Local Notifications
-keep class com.dexterous.** { *; }

# Lichess
-keep class com.chessground.** { *; }
-keep class com.github.lichess.** { *; }
-keep class io.flutter.plugins.** { *; }
-keepattributes *Annotation*
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}