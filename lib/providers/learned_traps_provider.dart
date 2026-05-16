import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'learned_traps_provider.g.dart';

@riverpod
class LearnedTraps extends _$LearnedTraps {
  static const _key = 'learned_traps';

  @override
  Set<int> build() {
    _load();
    return {};
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key);
    if (list != null) {
      state = list.map(int.parse).toSet();
    }
  }

  Future<void> toggleLearned(int id) async {
    final newState = Set<int>.from(state);
    if (newState.contains(id)) {
      newState.remove(id);
    } else {
      newState.add(id);
    }
    state = newState;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, state.map((e) => e.toString()).toList());
  }
}
