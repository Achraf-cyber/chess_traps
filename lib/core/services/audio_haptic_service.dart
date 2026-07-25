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

  /// User toggles, mirrored here from ChessSettings so this service (which
  /// has no Riverpod ref) can honour them. Default on; loaded at startup.
  static bool soundEnabled = true;
  static bool hapticsEnabled = true;

  Future<void> playMove() async {
    if (hapticsEnabled) await HapticFeedback.lightImpact();
    if (soundEnabled) await SystemSound.play(SystemSoundType.click);
  }

  Future<void> playCapture() async {
    if (hapticsEnabled) await HapticFeedback.mediumImpact();
    if (soundEnabled) await SystemSound.play(SystemSoundType.click);
  }

  Future<void> playCheck() async {
    if (hapticsEnabled) await HapticFeedback.heavyImpact();
    if (soundEnabled) await SystemSound.play(SystemSoundType.alert);
  }

  Future<void> playError() async {
    if (hapticsEnabled) await HapticFeedback.vibrate();
  }
}
