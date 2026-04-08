import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'user_favorites_provider.g.dart';

@riverpod
class UserFavoritesNotifier extends _$UserFavoritesNotifier {
  static const _key = 'favorite_traps';

  @override
  Set<int> build() {
    _load();
    return {};
  }

  Future<void> _load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> strings = prefs.getStringList(_key) ?? [];
    state = strings.map((e) => int.parse(e)).toSet();
  }

  bool isFavorite(int index) {
    return state.contains(index);
  }

  Future<void> toggleFavorite(int index) async {
    final newSet = Set<int>.from(state);
    if (newSet.contains(index)) {
      newSet.remove(index);
    } else {
      newSet.add(index);
    }

    state = newSet;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, newSet.map((e) => e.toString()).toList());
  }

  Future<void> clear() async {
    state = {};
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
