import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeNotifier extends Notifier<String> {
  static const _key = 'theme_mode';

  @override
  String build() {
    _load();
    return 'system';
  }

  Future<void> _load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_key) ?? 'system';
  }

  Future<void> setThemeMode(String mode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode);
    state = mode;
  }
}

final themeModeNotifierProvider = NotifierProvider<ThemeModeNotifier, String>(ThemeModeNotifier.new);

class LanguageNotifier extends Notifier<String> {
  static const _key = 'app_language';

  @override
  String build() {
    _load();
    return 'en';
  }

  Future<void> _load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_key) ?? 'en';
  }

  Future<void> setLanguage(String code) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code);
    state = code;
  }
}

final languageNotifierProvider = NotifierProvider<LanguageNotifier, String>(LanguageNotifier.new);
