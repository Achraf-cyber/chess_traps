import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sound_effect/sound_effect.dart';

/// Move/capture/check feedback: low-latency bundled sound effects (via the
/// [SoundEffect] plugin) plus haptics. Sounds are loaded once at startup and
/// played by id; if loading ever fails (or on an unsupported platform) the
/// service degrades gracefully to haptics-only instead of throwing.
class AudioHapticService {
  factory AudioHapticService() => _instance;
  AudioHapticService._internal();

  static final AudioHapticService _instance = AudioHapticService._internal();

  static const _moveId = 'move';
  static const _captureId = 'capture';
  static const _checkId = 'check';
  static const _errorId = 'error';
  // Voice clips, played only at rare, meaningful moments (win / loss / trap
  // completion) so they stay a delightful surprise rather than a nuisance.
  static const _praiseId = 'praise';
  static const _awwId = 'aww';

  static const _assets = <String, String>{
    _moveId: 'assets/sounds/move.wav',
    _captureId: 'assets/sounds/capture.wav',
    _checkId: 'assets/audio/i_am_in_danger.mp3',
    _errorId: 'assets/sounds/error.wav',
    _praiseId: 'assets/audio/du_bist_gut_genug.mp3',
    _awwId: 'assets/audio/faah.mp3',
  };

  final SoundEffect _soundEffect = SoundEffect();

  /// True once [initialize] has loaded the effects. Playback is a no-op (sound
  /// side) until then, so an early call never crashes.
  bool _ready = false;

  /// User toggles, mirrored here from ChessSettings so this service (which
  /// has no Riverpod ref) can honour them. Default on; loaded at startup.
  static bool soundEnabled = true;
  static bool hapticsEnabled = true;

  /// Loads all sound effects. Safe to call more than once. Failures are
  /// swallowed so audio problems never block app start — the app just runs
  /// without move sounds.
  Future<void> initialize() async {
    if (_ready) return;
    try {
      await _soundEffect.initialize();
      for (final entry in _assets.entries) {
        await _soundEffect.load(entry.key, entry.value);
      }
      _ready = true;
    } catch (e) {
      if (kDebugMode) debugPrint('AudioHapticService init failed: $e');
    }
  }

  Future<void> _play(String id) async {
    if (!soundEnabled || !_ready) return;
    try {
      await _soundEffect.play(id);
    } catch (e) {
      if (kDebugMode) debugPrint('AudioHapticService play($id) failed: $e');
    }
  }

  Future<void> playMove() async {
    if (hapticsEnabled) await HapticFeedback.lightImpact();
    await _play(_moveId);
  }

  Future<void> playCapture() async {
    if (hapticsEnabled) await HapticFeedback.mediumImpact();
    await _play(_captureId);
  }

  Future<void> playCheck() async {
    if (hapticsEnabled) await HapticFeedback.heavyImpact();
    await _play(_checkId);
  }

  Future<void> playError() async {
    if (hapticsEnabled) await HapticFeedback.vibrate();
    await _play(_errorId);
  }

  /// Encouraging voice clip for a win or a completed trap. Rare by design.
  Future<void> playPraise() async {
    if (hapticsEnabled) await HapticFeedback.heavyImpact();
    await _play(_praiseId);
  }

  /// Light-hearted "aww" voice clip for a loss. Rare by design.
  Future<void> playAww() async {
    if (hapticsEnabled) await HapticFeedback.mediumImpact();
    await _play(_awwId);
  }

  /// Releases native sound resources. Call on app teardown if needed.
  Future<void> dispose() async {
    if (!_ready) return;
    try {
      await _soundEffect.release();
    } catch (_) {}
    _ready = false;
  }
}
