import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioHapticService {
  factory AudioHapticService() => _instance;
  AudioHapticService._internal();

  static final AudioHapticService _instance = AudioHapticService._internal();

  final AudioPlayer _player = AudioPlayer();
  
  // Audio file paths (we should add these to assets)
  static const String moveSound = 'sounds/move.mp3';
  static const String captureSound = 'sounds/capture.mp3';
  static const String checkSound = 'sounds/check.mp3';
  static const String gameOverSound = 'sounds/game_over.mp3';

  Future<void> playMove() async {
    await HapticFeedback.lightImpact();
    // In a real app, we'd play the sound here if it exists in assets
    // await _player.play(AssetSource(moveSound));
  }

  Future<void> playCapture() async {
    await HapticFeedback.mediumImpact();
    // await _player.play(AssetSource(captureSound));
  }

  Future<void> playCheck() async {
    await HapticFeedback.heavyImpact();
    // await _player.play(AssetSource(checkSound));
  }

  Future<void> playError() async {
    await HapticFeedback.vibrate();
  }

  void dispose() {
    _player.dispose();
  }
}
