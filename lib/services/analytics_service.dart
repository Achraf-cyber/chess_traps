import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  FirebaseAnalytics? _analyticsInstance;

  FirebaseAnalytics? get _analytics {
    try {
      _analyticsInstance ??= FirebaseAnalytics.instance;
      return _analyticsInstance;
    } catch (e) {
      debugPrint('Firebase Analytics initialization error: $e');
      return null;
    }
  }

  /// Log when a user starts viewing a trap
  Future<void> logTrapViewed({required int id, required String name}) async {
    try {
      await _analytics?.logEvent(
        name: 'trap_viewed',
        parameters: {'trap_id': id, 'trap_name': name},
      );
    } catch (e) {
      debugPrint('Error logging trap_viewed: $e');
    }
  }

  /// Log when a user completes a trap (finishes all moves or watches auto-play)
  Future<void> logTrapMastered({required int id, required String name}) async {
    try {
      await _analytics?.logEvent(
        name: 'trap_mastered',
        parameters: {'trap_id': id, 'trap_name': name},
      );
    } catch (e) {
      debugPrint('Error logging trap_mastered: $e');
    }
  }

  /// Log when a trap is added or removed from favorites
  Future<void> logFavoriteToggled({
    required int id,
    required String name,
    required bool isAdded,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'favorite_toggled',
        parameters: {
          'trap_id': id,
          'trap_name': name,
          'is_added': isAdded ? 1 : 0,
        },
      );
    } catch (e) {
      debugPrint('Error logging favorite_toggled: $e');
    }
  }

  /// Log when engine analysis is toggled
  Future<void> logEngineToggled({required bool enabled}) async {
    try {
      await _analytics?.logEvent(
        name: 'engine_toggled',
        parameters: {'enabled': enabled ? 1 : 0},
      );
    } catch (e) {
      debugPrint('Error logging engine_toggled: $e');
    }
  }

  /// Log ad impressions (optional manual tracking if desired)
  Future<void> logAdImpression({required String adUnitId}) async {
    try {
      await _analytics?.logEvent(
        name: 'ad_impression_custom',
        parameters: {'ad_unit_id': adUnitId},
      );
    } catch (e) {
      debugPrint('Error logging ad_impression_custom: $e');
    }
  }

  /// Set user properties for better segmentation
  Future<void> setUserProperties({required String theme}) async {
    try {
      await _analytics?.setUserProperty(name: 'app_theme', value: theme);
    } catch (e) {
      debugPrint('Error setting user properties: $e');
    }
  }
}
