import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chess_traps/core/services/remote_config_service.dart';

part 'daily_limit_provider.g.dart';

class DailyLimitState {
  const DailyLimitState({
    required this.viewsToday,
    required this.isUnlocked,
  });

  final int viewsToday;
  final bool isUnlocked;


  DailyLimitState copyWith({
    int? viewsToday,
    bool? isUnlocked,
  }) {
    return DailyLimitState(
      viewsToday: viewsToday ?? this.viewsToday,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}

@Riverpod(keepAlive: true)
class DailyLimitNotifier extends _$DailyLimitNotifier {
  static const String _dateKey = 'daily_limit_date';
  static const String _viewsKey = 'daily_limit_views';
  static const String _unlockedKey = 'daily_limit_unlocked';

  /// Remote-tunable free-view threshold (generous default protects retention).
  int get maxFreeViews => RemoteConfigService().dailyFreeTrapViews;

  final Completer<void> _readyCompleter = Completer<void>();

  /// Completes once today's persisted counts have loaded, so callers can gate
  /// on an accurate [viewsToday] rather than the initial placeholder state.
  Future<void> get ready => _readyCompleter.future;

  @override
  DailyLimitState build() {
    _init();
    return const DailyLimitState(viewsToday: 0, isUnlocked: false);
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getTodayDateString();
    final savedDate = prefs.getString(_dateKey);

    if (savedDate == today) {
      final views = prefs.getInt(_viewsKey) ?? 0;
      final unlocked = prefs.getBool(_unlockedKey) ?? false;
      try {
        state = DailyLimitState(viewsToday: views, isUnlocked: unlocked);
      } catch (_) {}
    } else {
      // New day, reset
      await prefs.setString(_dateKey, today);
      await prefs.setInt(_viewsKey, 0);
      await prefs.setBool(_unlockedKey, false);
      try {
        state = const DailyLimitState(viewsToday: 0, isUnlocked: false);
      } catch (_) {}
    }
    if (!_readyCompleter.isCompleted) _readyCompleter.complete();
  }

  String _getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  bool canViewTrap() {
    if (state.isUnlocked) return true;
    return state.viewsToday < maxFreeViews;
  }

  Future<void> incrementViewCount() async {
    if (state.isUnlocked) return;

    final newViews = state.viewsToday + 1;
    state = state.copyWith(viewsToday: newViews);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_viewsKey, newViews);
  }

  Future<void> unlockForToday() async {
    state = state.copyWith(isUnlocked: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_unlockedKey, true);
  }
}
