import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Product and health events. Every call is fire-and-forget: analytics must
/// never be able to break the thing it is measuring.
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  /// Firebase rejects longer string parameter values.
  static const _maxValueLength = 100;

  Future<void> _log(String name, [Map<String, Object>? parameters]) async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e) {
      debugPrint('Error logging $name: $e');
    }
  }

  static String _short(String value) => value.length <= _maxValueLength
      ? value
      : value.substring(0, _maxValueLength);

  // ── Engine health ───────────────────────────────────────────────────

  /// The engine came up. Set against [logEngineStartFailed] this gives the
  /// failure rate, and [elapsed] shows how close devices get to the 5s limit.
  void logEngineStarted({required int attempt, required Duration elapsed}) {
    _log('engine_started', {
      'attempt': attempt,
      'duration_ms': elapsed.inMilliseconds,
    });
  }

  /// One attempt to start the engine failed. [willRetry] is false on the last
  /// attempt, which is the failure the user actually feels. The full error goes
  /// to Crashlytics, which unlike Analytics keeps it whole.
  void logEngineStartFailed({
    required int attempt,
    required bool willRetry,
    required Object error,
  }) {
    _log('engine_start_failed', {
      'attempt': attempt,
      'will_retry': willRetry ? 1 : 0,
      'error_type': error.runtimeType.toString(),
      'error': _short(error.toString()),
    });
    _recordEngineError(error, 'Stockfish start failed, attempt $attempt');
  }

  /// A running engine died. [diagnostics] is multistockfish's own report of
  /// where it was.
  void logEngineCrashed({required String state, required String diagnostics}) {
    _log('engine_crashed', {'state': state, 'diagnostics': _short(diagnostics)});
    _recordEngineError(diagnostics, 'Stockfish died ($state)');
  }

  /// No engine could be started, so the game carried on with the built-in
  /// move picker instead of Stockfish.
  void logEngineFallbackUsed() => _log('engine_fallback_used');

  void _recordEngineError(Object error, String reason) {
    try {
      FirebaseCrashlytics.instance.recordError(
        error,
        StackTrace.current,
        reason: reason,
      );
    } catch (e) {
      debugPrint('Error recording engine failure: $e');
    }
  }

  // ── Learning ────────────────────────────────────────────────────────

  void logTrapViewed({required int id, required String name}) {
    _log('trap_viewed', {'trap_id': id, 'trap_name': _short(name)});
  }

  /// [mode] is `practice` or `avoid`.
  void logTrapPracticeStarted({required int id, required String mode}) {
    _log('trap_practice_started', {'trap_id': id, 'mode': mode});
  }

  /// Finished a trap in [mode]. [wrongAttempts] shows which traps are too hard.
  void logTrapPracticeCompleted({
    required int id,
    required String mode,
    required int wrongAttempts,
  }) {
    _log('trap_practice_completed', {
      'trap_id': id,
      'mode': mode,
      'wrong_attempts': wrongAttempts,
    });
  }

  void logTrapLearned({required int id, required bool learned}) {
    _log('trap_learned', {'trap_id': id, 'learned': learned ? 1 : 0});
  }

  void logFavoriteToggled({required int id, required bool isAdded}) {
    _log('favorite_toggled', {'trap_id': id, 'is_added': isAdded ? 1 : 0});
  }

  void logTrapShared({required int id}) => _log('trap_shared', {'trap_id': id});

  /// [source] is `trap` or `game`.
  void logHintUsed({required String source}) {
    _log('hint_used', {'source': source});
  }

  // ── Games ───────────────────────────────────────────────────────────

  /// [mode] is `engine` or `friend`.
  void logGameStarted({required String mode, required int elo}) {
    _log('game_started', {'mode': mode, 'elo': elo});
  }

  /// [result] is `win`, `loss` or `draw`; in friend games, the winning color.
  void logGameFinished({
    required String mode,
    required String result,
    required int elo,
    required int plies,
    required bool resigned,
  }) {
    _log('game_finished', {
      'mode': mode,
      'result': result,
      'elo': elo,
      'plies': plies,
      'resigned': resigned ? 1 : 0,
    });
  }

  // ── Monetisation ────────────────────────────────────────────────────

  /// [placement] is `daily_limit` or `search_limit`.
  void logRewardedAdEarned({required String placement}) {
    _log('rewarded_ad_earned', {'placement': placement});
  }

  /// The ad offer was accepted but none was available to show.
  void logRewardedAdUnavailable({required String placement}) {
    _log('rewarded_ad_unavailable', {'placement': placement});
  }
}
