-keep class com.chessground.** { *; }
-keep class com.github.lichess.** { *; }
-keep class io.flutter.plugins.** { *; }
-keepattributes *Annotation*
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}