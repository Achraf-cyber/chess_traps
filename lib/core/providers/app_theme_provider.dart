import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_theme_provider.g.dart';

@riverpod
class AppThemeNotifier extends _$AppThemeNotifier {
  static const _themeModeKey = 'theme_mode';

  @override
  ThemeMode build() {
    _loadThemeMode();
    return ThemeMode.system;
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeValue = prefs.getString(_themeModeKey);
    if (!ref.mounted) return;
    state = modeValue != null
        ? ThemeMode.values.byName(modeValue)
        : ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    final value = mode.name;
    await prefs.setString(_themeModeKey, value);
  }
}
