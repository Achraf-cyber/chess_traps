import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class StreakState {
  const StreakState({this.count = 0});
  final int count;
}

class StreakNotifier extends Notifier<StreakState> {
  static const _streakCountKey = 'streak_count';
  static const _lastOpenedKey = 'last_opened_date';

  @override
  StreakState build() {
    _initStreak();
    return const StreakState();
  }

  Future<void> _initStreak() async {
    final prefs = await SharedPreferences.getInstance();
    int count = prefs.getInt(_streakCountKey) ?? 0;
    final String? lastOpenedStr = prefs.getString(_lastOpenedKey);

    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    if (lastOpenedStr == null) {
      count = 1;
    } else {
      final lastOpened = DateTime.parse(lastOpenedStr);
      final difference = DateTime(now.year, now.month, now.day)
          .difference(DateTime(lastOpened.year, lastOpened.month, lastOpened.day))
          .inDays;

      if (difference == 1) {
        // Logged in exactly yesterday
        count += 1;
      } else if (difference > 1) {
        // Missed a day
        count = 1;
      }
      // If difference == 0, logged in today already, count remains the same
    }

    await prefs.setInt(_streakCountKey, count);
    await prefs.setString(_lastOpenedKey, todayStr);

    state = StreakState(count: count);
  }
}

final streakProvider = NotifierProvider<StreakNotifier, StreakState>(() {
  return StreakNotifier();
});
