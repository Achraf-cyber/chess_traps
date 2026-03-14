import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'favorites_provider.g.dart';

@riverpod
class FavoritesNotifier extends _$FavoritesNotifier {
  static const _key = 'favorite_traps';

  @override
  List<int> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final strings = prefs.getStringList(_key) ?? [];
    state = strings.map((e) => int.parse(e)).toList();
  }

  Future<void> toggleFavorite(int index) async {
    final newList = List<int>.from(state);
    if (newList.contains(index)) {
      newList.remove(index);
    } else {
      newList.add(index);
    }
    
    state = newList;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, newList.map((e) => e.toString()).toList());
  }
}
