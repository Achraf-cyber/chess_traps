import 'dart:math';

import 'package:dartchess/dartchess.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sound_effect/sound_effect.dart';

/// Which family of sounds a screen speaks in.
///
/// This is a deliberate product split, not a technical one: **Play** is a comic
/// stage show (a clown horn, a crowd that laughs at you, a kazoo band) because
/// it is where people mess around, while the **trap trainer** stays on clean,
/// short, neutral tones so it remains bearable over a long study session. The
/// trainer's only jokes are one-offs too rare to wear out: [playTrapSprung] and
/// [playTrapLearned].
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
  bool rook,
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
  // Tonal rather than funny: the trainer's queen capture and draw.
  static const _queenId = 'queen_down';
  static const _drawId = 'draw';

  // Simple profile.
  static const _captureId = 'capture';
  static const _checkId = 'check';
  static const _errorId = 'error';
  static const _successId = 'success';
  static const _promoteId = 'promote';

  // Meme profile.
  static const _eatIds = <String>['eat1', 'eat2', 'eat3'];
  static const _horseId = 'horse';
  static const _rookId = 'the_rook';
  static const _teleportId = 'teleport';
  static const _transformId = 'transform';
  static const _praiseId = 'praise';
  static const _awwId = 'aww';
  static const _honkId = 'honk';
  static const _gaspId = 'gasp';
  static const _crowdLaughId = 'crowd_laugh';
  static const _kazooId = 'kazoo';
  static const _applauseId = 'applause';
  static const _sadHornId = 'sad_horn';
  static const _slideDownId = 'slide_down';
  static const _whoopeeId = 'whoopee';
  static const _cricketsId = 'crickets';
  static const _recordScratchId = 'record_scratch';
  static const _squeakId = 'squeak';

  // The trainer's rare jokes, and the streak.
  static const _evilLaughId = 'evil_laugh';
  static const _rimshotId = 'rimshot';
  static const _roosterId = 'rooster';

  // Playing lengths, used to space the two-part reactions. Keep in step with
  // the files in `assets/audio/`. Applause enters just before the kazoo ends.
  static const _awwLength = Duration(milliseconds: 1220);
  static const _kazooLength = Duration(milliseconds: 2600);
  static const _slideDownLength = Duration(milliseconds: 1420);

  static const _assets = <String, String>{
    _moveId: 'assets/sounds/move.wav',
    _castleId: 'assets/sounds/castle.wav',
    _promoteId: 'assets/sounds/promote.wav',
    _captureId: 'assets/sounds/capture.wav',
    _checkId: 'assets/sounds/check.wav',
    _errorId: 'assets/sounds/error.wav',
    _successId: 'assets/sounds/success.wav',
    _queenId: 'assets/sounds/queen_down.wav',
    _drawId: 'assets/sounds/draw.wav',
    'eat1': 'assets/audio/eat1.mp3',
    'eat2': 'assets/audio/eat2.mp3',
    'eat3': 'assets/audio/eat3.mp3',
    _horseId: 'assets/audio/horse.mp3',
    _rookId: 'assets/audio/the-rook.mp3',
    _teleportId: 'assets/audio/teleport.mp3',
    _transformId: 'assets/audio/transform.mp3',
    _praiseId: 'assets/audio/du_bist_gut_genug.mp3',
    _awwId: 'assets/audio/faah.mp3',
    _honkId: 'assets/audio/honk.mp3',
    _gaspId: 'assets/audio/gasp.mp3',
    _crowdLaughId: 'assets/audio/crowd_laugh.mp3',
    _kazooId: 'assets/audio/kazoo.mp3',
    _applauseId: 'assets/audio/applause.mp3',
    _sadHornId: 'assets/audio/sad_horn.mp3',
    _slideDownId: 'assets/audio/slide_down.mp3',
    _whoopeeId: 'assets/audio/whoopee.mp3',
    _cricketsId: 'assets/audio/crickets.mp3',
    _recordScratchId: 'assets/audio/record_scratch.mp3',
    _squeakId: 'assets/audio/squeak.mp3',
    _evilLaughId: 'assets/audio/evil_laugh.mp3',
    _rimshotId: 'assets/audio/rimshot.mp3',
    _roosterId: 'assets/audio/rooster.mp3',
  };

  /// Per-clip playback gain, so one master volume setting is usable.
  ///
  /// The bundled clips come from different sources and were mastered at wildly
  /// different levels: about 15 dB apart, from -6.2 LUFS (du_bist_gut_genug)
  /// down to -21.7 LUFS (eat2). Whatever volume the user picked, some sounds
  /// shouted and others were barely there.
  ///
  /// Loudness is measured in LUFS, which weights frequencies the way the ear
  /// does. An earlier pass used plain RMS, which under-rates voice and
  /// mid-range clips, so the meme clips still came out several dB too loud.
  /// Most clips are shorter than the 400 ms a LUFS reading needs, so each is
  /// measured with silence stripped and the clip looped:
  ///
  ///   ffmpeg -stream_loop 40 -i CLIP -af "silenceremove=start_periods=1:
  ///     start_threshold=-45dB:stop_periods=-1:stop_threshold=-45dB:
  ///     stop_silence=0,atrim=duration=6,ebur128" -f null -
  ///
  /// Each value is 10^((-18 - measured LUFS) / 20), targeting -18 LUFS. The
  /// plugin clamps at 1.0, so only attenuation is possible here: eat2, the one
  /// clip below target, was raised in the file instead (+3.9 dB, limited at
  /// -1 dBFS). Clips within 0.2 dB of target are absent and play at 1.0.
  /// Re-measure and update this table whenever a clip is replaced. The comic
  /// clips added later were levelled in the file to -18 LUFS, so they need no
  /// entry. Rimshot and squeak are too short to reach it and sit 2-4 dB under.
  static const _gains = <String, double>{
    // Simple tones.
    _moveId: 0.88, // -16.9 LUFS
    _castleId: 0.92, // -17.3
    _checkId: 0.51, // -12.1
    _errorId: 0.54, // -12.6
    _successId: 0.77, // -15.7
    _promoteId: 0.65, // -14.2
    _queenId: 0.92, // -17.3
    // Meme clips.
    'eat3': 0.66, // -14.4
    _horseId: 0.28, // -6.9
    _rookId: 0.64, // -14.1
    _teleportId: 0.37, // -9.4
    _transformId: 0.59, // -13.4
    _praiseId: 0.26, // -6.2, by far the loudest clip in the bundle
    _awwId: 0.60, // -13.5
  };

  final SoundEffect _soundEffect = SoundEffect();
  final Random _random = Random();

  /// Last chomp played, so the random pick never repeats back-to-back — a
  /// repeat is what makes randomised sets sound broken rather than varied.
  String? _lastEat;

  /// True once [initialize] has loaded the effects. Playback is a no-op (sound
  /// side) until then, so an early call never crashes.
  bool _ready = false;

  /// The load in progress, so that a caller during it waits rather than
  /// loading everything a second time.
  Future<void>? _initializing;

  /// User toggles, mirrored here from ChessSettings so this service (which
  /// has no Riverpod ref) can honour them. Default on; loaded at startup.
  static bool soundEnabled = true;
  static bool hapticsEnabled = true;

  /// Loads all sound effects. Safe to call more than once. Failures are
  /// swallowed so audio problems never block app start — the app just runs
  /// without move sounds.
  Future<void> initialize() {
    if (_ready) return Future.value();
    return _initializing ??= _load().whenComplete(() => _initializing = null);
  }

  Future<void> _load() async {
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
        rook: false,
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
      rook: mover?.role == Role.rook,
    );
  }

  /// Classifies [move] and plays the matching sound for [profile].
  ///
  /// [byOpponent] decides who the joke is on: the crowd gasps when you take a
  /// queen and laughs when you lose yours. Checkmate is left silent in Play,
  /// where the end-of-game sound follows and would clash.
  Future<void> playMoveSound(
    SoundProfile profile,
    Position before,
    Move move,
    Position after, {
    bool byOpponent = false,
  }) async {
    final facts = describe(before, move, after);
    await _haptic(_hapticFor(facts));
    if (profile == SoundProfile.meme && after.isCheckmate) return;
    await _play(_soundFor(profile, facts, byOpponent: byOpponent));
  }

  /// A plain move tick, for the few places with no position to inspect (the
  /// opening position, or a line we failed to parse).
  Future<void> playQuietMove(SoundProfile profile) async {
    await _haptic(HapticFeedback.lightImpact);
    await _play(_moveId);
  }

  /// Something went right: a trap completed, a game won, a trap marked learned.
  ///
  /// A win on the Play screen gets either the kazoo band and its applause or
  /// the voice clip, so that it doesn't go stale.
  Future<void> playSuccess(SoundProfile profile) async {
    await _haptic(HapticFeedback.heavyImpact);
    if (profile == SoundProfile.simple) {
      await _play(_successId);
    } else if (_random.nextInt(4) == 0) {
      await _play(_praiseId);
    } else {
      await _play(_kazooId);
      await Future<void>.delayed(_kazooLength);
      await _play(_applauseId);
    }
  }

  /// The final move of a trap in practice. It's the moment the app is about.
  Future<void> playTrapSprung() async {
    await _haptic(HapticFeedback.heavyImpact);
    await _play(_evilLaughId);
  }

  /// A trap marked as learned. Ba-dum-tss.
  Future<void> playTrapLearned() async {
    await _haptic(HapticFeedback.mediumImpact);
    await _play(_rimshotId);
  }

  /// The streak grew today: a rooster, because it's a new day.
  Future<void> playStreak() async {
    await initialize();
    await _play(_roosterId);
  }

  /// A move taken back. The needle comes off the record.
  Future<void> playUndo() async {
    await _haptic(HapticFeedback.lightImpact);
    await _play(_recordScratchId);
  }

  /// A hint was asked for in a game.
  Future<void> playHint() async {
    await _haptic(HapticFeedback.lightImpact);
    await _play(_squeakId);
  }

  /// A single-shot "no": a wrong move in trap practice.
  Future<void> playFailure(SoundProfile profile) async {
    await _haptic(HapticFeedback.vibrate);
    await _play(profile == SoundProfile.meme ? _awwId : _errorId);
  }

  /// The game ended in a draw.
  ///
  /// A sound of its own: a draw is neither a win nor a loss, and borrowing
  /// either would tell the player something untrue about the result. Play gets
  /// a rimshot to an audience that doesn't laugh.
  Future<void> playDraw(SoundProfile profile) async {
    await _haptic(HapticFeedback.mediumImpact);
    await _play(profile == SoundProfile.meme ? _cricketsId : _drawId);
  }

  /// The game is lost.
  ///
  /// Losing to mate gets a two-beat reaction: the disappointed "aww" lands
  /// first, then the sad horn once it has finished. Resigning is a slide
  /// whistle down to a whoopee cushion: you saw it coming.
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
      await _play(_sadHornId);
    } else {
      await _play(_slideDownId);
      await Future<void>.delayed(_slideDownLength);
      await _play(_whoopeeId);
    }
  }

  /// Play's priority: a dead queen first (rare and dramatic), then check, then
  /// the piece-specific gags. The trainer's priority: check first, always —
  /// it's the one thing a student must not miss — and no gags at all.
  String _soundFor(
    SoundProfile profile,
    MoveFacts f, {
    bool byOpponent = false,
  }) {
    switch (profile) {
      case SoundProfile.meme:
        if (f.queenCapture) return byOpponent ? _crowdLaughId : _gaspId;
        if (f.check) return byOpponent ? _awwId : _honkId;
        if (f.enPassant) return _teleportId;
        if (f.promotion) return _transformId;
        if (f.castle) return _castleId;
        if (f.capture) return _nextEat();
        if (f.knight) return _horseId;
        if (f.rook) return _rookId;
        return _moveId;
      case SoundProfile.simple:
        if (f.check) return _checkId;
        if (f.queenCapture) return _queenId;
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
      await _soundEffect.play(id, volume: _gains[id] ?? 1.0);
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
