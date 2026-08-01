
# Flutter. The engine registers plugins reflectively, so the embedding stays
# kept wholesale. Everything below it does not need to be.
-keep class io.flutter.** { *; }

# Local Notifications — this plugin deserialises scheduled notifications from
# disk by class name, so it genuinely needs its classes kept.
-keep class com.dexterous.** { *; }

# AdMob and Firebase are deliberately NOT kept wholesale: both ship their own
# consumer-proguard-rules.pro inside their AARs, which keep exactly what their
# reflection needs. Blanket -keep rules here only stopped R8 from shrinking
# them, which is what Play's "R8 optimisation" recommendation flags.

# Chessground and dartchess are pure Dart — there was never a com.chessground
# or com.github.lichess package on the Java side for these rules to match.

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