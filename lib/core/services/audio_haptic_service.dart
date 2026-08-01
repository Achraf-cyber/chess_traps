import 'dart:math';

import 'package:dartchess/dartchess.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sound_effect/sound_effect.dart';

/// Which family of sounds a screen speaks in.
///
/// This is a deliberate product split, not a technical one: **Play** is loud
/// and funny (voice clips, chomping, a whinnying horse) because it is where
/// people mess around, while the **trap trainer** stays on clean, short,
/// neutral tones so it remains bearable over a long study session.
enum SoundProfile {
  /// Play screen — meme clips.
  meme,

  /// Trap detail screen — plain chess UI tones.
  simple,
}

/// Everything about a move that a sound might key off.
///
/// These are independent observations, not a ranking — several are true at
/// once for something like `Qxd8+`. Each profile applies its *own* priority to
/// them, which is the whole point of keeping them separate: Play cares most
/// that a queen just died, the trainer cares most that you are in check.
typedef MoveFacts = ({
  bool check,
  bool queenCapture,
  bool enPassant,
  bool castle,
  bool promotion,
  bool capture,
  bool knight,
});

/// Board feedback: low-latency bundled sound effects (via the [SoundEffect]
/// plugin) plus haptics. Sounds are loaded once at startup and played by id;
/// if loading ever fails (or on an unsupported platform) the service degrades
/// gracefully to haptics-only instead of throwing.
class AudioHapticService {
  factory AudioHapticService() => _instance;
  AudioHapticService._internal();

  static final AudioHapticService _instance = AudioHapticService._internal();

  // Neutral tones. Shared by both profiles: there is no meme clip for a quiet
  // move or for castling, and forcing one on every single ply would be
  // exhausting.
  static const _moveId = 'move';
  static const _castleId = 'castle';
  // Synthesised stand-ins for the clips pulled over copyright. They are tonal
  // rather than funny, but a takedown on the listing costs more than a gag
  // does. [_alertId] is still distinct from the trainer's [_checkId] — a
  // repeated siren figure rather than a single chime — so the two profiles
  // keep their own voice.
  static const _queenId = 'queen_down';
  static const _defeatId = 'defeat';
  static const _alertId = 'alert';

  // Simple profile.
  static const _captureId = 'capture';
  static const _checkId = 'check';
  static const _errorId = 'error';
  static const _successId = 'success';
  static const _promoteId = 'promote';

  // Meme profile.
  static const _eatIds = <String>['eat1', 'eat2', 'eat3'];
  static const _horseId = 'horse';
  static const _teleportId = 'teleport';
  static const _transformId = 'transform';
  static const _praiseId = 'praise';
  static const _awwId = 'aww';

  /// Playing length of [_awwId] after trimming, used to space the two-part
  /// checkmate reaction. Keep in step with `assets/audio/faah.mp3`.
  static const _awwLength = Duration(milliseconds: 1220);

  static const _assets = <String, String>{
    _moveId: 'assets/sounds/move.wav',
    _castleId: 'assets/sounds/castle.wav',
    _promoteId: 'assets/sounds/promote.wav',
    _captureId: 'assets/sounds/capture.wav',
    _checkId: 'assets/sounds/check.wav',
    _errorId: 'assets/sounds/error.wav',
    _successId: 'assets/sounds/success.wav',
    _queenId: 'assets/sounds/queen_down.wav',
    _defeatId: 'assets/sounds/defeat.wav',
    _alertId: 'assets/sounds/alert.wav',
    'eat1': 'assets/audio/eat1.mp3',
    'eat2': 'assets/audio/eat2.mp3',
    'eat3': 'assets/audio/eat3.mp3',
    _horseId: 'assets/audio/horse.mp3',
    _teleportId: 'assets/audio/teleport.mp3',
    _transformId: 'assets/audio/transform.mp3',
    _praiseId: 'assets/audio/du_bist_gut_genug.mp3',
    _awwId: 'assets/audio/faah.mp3',
  };

  final SoundEffect _soundEffect = SoundEffect();
  final Random _random = Random();

  /// Last chomp played, so the random pick never repeats back-to-back — a
  /// repeat is what makes randomised sets sound broken rather than varied.
  String? _lastEat;

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

  /// Reads off everything notable about [move], played from [before] and
  /// producing [after].
  static MoveFacts describe(Position before, Move move, Position after) {
    if (move is! NormalMove) {
      return (
        check: after.isCheck,
        queenCapture: false,
        enPassant: false,
        castle: false,
        promotion: false,
        capture: false,
        knight: false,
      );
    }

    final mover = before.board.pieceAt(move.from);
    final victim = before.board.pieceAt(move.to);
    final enPassant = mover?.role == Role.pawn && before.epSquare == move.to;

    // dartchess accepts both castling encodings (king two squares, or the
    // king-takes-own-rook form), so look for either.
    final castle =
        mover?.role == Role.king &&
        ((victim != null &&
                victim.role == Role.rook &&
                victim.color == before.turn) ||
            (move.from.file - move.to.file).abs() > 1);

    return (
      check: after.isCheck,
      queenCapture: !castle && victim?.role == Role.queen,
      enPassant: enPassant,
      castle: castle,
      promotion: move.promotion != null,
      capture: !castle && (victim != null || enPassant),
      knight: mover?.role == Role.knight,
    );
  }

  /// Classifies [move] and plays the matching sound for [profile].
  Future<void> playMoveSound(
    SoundProfile profile,
    Position before,
    Move move,
    Position after,
  ) async {
    final facts = describe(before, move, after);
    await _haptic(_hapticFor(facts));
    await _play(_soundFor(profile, facts));
  }

  /// A plain move tick, for the few places with no position to inspect (the
  /// opening position, or a line we failed to parse).
  Future<void> playQuietMove(SoundProfile profile) async {
    await _haptic(HapticFeedback.lightImpact);
    await _play(_moveId);
  }

  /// Something went right: a trap completed, a game won, a trap marked learned.
  Future<void> playSuccess(SoundProfile profile) async {
    await _haptic(HapticFeedback.heavyImpact);
    await _play(profile == SoundProfile.meme ? _praiseId : _successId);
  }

  /// A single-shot "no": a wrong move in trap practice.
  Future<void> playFailure(SoundProfile profile) async {
    await _haptic(HapticFeedback.vibrate);
    await _play(profile == SoundProfile.meme ? _awwId : _errorId);
  }

  /// The game is lost.
  ///
  /// Losing to mate gets a two-beat reaction — the disappointed "aww" lands
  /// first, then the defeat sting once it has finished. Resigning skips
  /// straight to the sting: you saw it coming.
  Future<void> playLoss(
    SoundProfile profile, {
    required bool byCheckmate,
  }) async {
    await _haptic(HapticFeedback.vibrate);
    if (profile == SoundProfile.simple) {
      await _play(_errorId);
      return;
    }
    if (byCheckmate) {
      await _play(_awwId);
      await Future<void>.delayed(_awwLength);
    }
    await _play(_defeatId);
  }

  /// Play's priority: a dead queen first (rare and dramatic), then check, then
  /// the piece-specific gags. The trainer's priority: check first, always —
  /// it's the one thing a student must not miss — and no gags at all.
  String _soundFor(SoundProfile profile, MoveFacts f) {
    switch (profile) {
      case SoundProfile.meme:
        if (f.queenCapture) return _queenId;
        if (f.check) return _alertId;
        if (f.enPassant) return _teleportId;
        if (f.promotion) return _transformId;
        if (f.castle) return _castleId;
        if (f.capture) return _nextEat();
        if (f.knight) return _horseId;
        return _moveId;
      case SoundProfile.simple:
        if (f.check) return _checkId;
        if (f.capture) return _captureId;
        if (f.promotion) return _promoteId;
        if (f.castle) return _castleId;
        return _moveId;
    }
  }

  Future<void> Function() _hapticFor(MoveFacts f) {
    if (f.check || f.queenCapture) return HapticFeedback.heavyImpact;
    if (f.capture || f.castle || f.promotion) {
      return HapticFeedback.mediumImpact;
    }
    return HapticFeedback.lightImpact;
  }

  /// A chomp that isn't the one we just played.
  String _nextEat() {
    String pick;
    do {
      pick = _eatIds[_random.nextInt(_eatIds.length)];
    } while (pick == _lastEat);
    return _lastEat = pick;
  }

  Future<void> _haptic(Future<void> Function() effect) async {
    if (!hapticsEnabled) return;
    await effect();
  }

  Future<void> _play(String id) async {
    if (!soundEnabled || !_ready) return;
    try {
      await _soundEffect.play(id);
    } catch (e) {
      if (kDebugMode) debugPrint('AudioHapticService play($id) failed: $e');
    }
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
