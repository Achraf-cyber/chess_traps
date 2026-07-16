
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

# Flutter's deferred-components support references the Play Core split-install
# API even though this app has no dynamic feature modules and doesn't depend
# on com.google.android.play:core. These classes are genuinely absent, so R8
# just needs to stop warning about them (this is Flutter's own generated
# missing_rules.txt for this exact situation).
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task