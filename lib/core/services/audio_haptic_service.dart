import 'package:flutter/services.dart';

/// Move/capture/check feedback via haptics plus the platform's built-in
/// system click sound. The app ships no bundled audio assets, so this uses
/// [SystemSound] (a real, distinct click on both iOS and Android) rather than
/// silently doing nothing — [SystemSoundType] only exposes `click` and
/// `alert`, so capture/check are distinguished by haptic weight instead.
class AudioHapticService {
  factory AudioHapticService() => _instance;
  AudioHapticService._internal();

  static final AudioHapticService _instance = AudioHapticService._internal();

  Future<void> playMove() async {
    await HapticFeedback.lightImpact();
    await SystemSound.play(SystemSoundType.click);
  }

  Future<void> playCapture() async {
    await HapticFeedback.mediumImpact();
    await SystemSound.play(SystemSoundType.click);
  }

  Future<void> playCheck() async {
    await HapticFeedback.heavyImpact();
    await SystemSound.play(SystemSoundType.alert);
  }

  Future<void> playError() async {
    await HapticFeedback.vibrate();
  }
}
