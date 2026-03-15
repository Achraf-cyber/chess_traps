import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../router.dart';
import '../../../utils.dart';
import '../data/chess_trap.dart';
import '../provider/traps_provider.dart';

class TrapsScreen extends ConsumerWidget {
  const TrapsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ChessTrap>> trapsAsync = ref.watch(trapsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.phrase.traps)),
      body: trapsAsync.when(
        data: (traps) {
          if (traps.isEmpty) {
            return Center(child: Text(context.phrase.noTrapsFound));
          }
          return ListView.builder(
            itemCount: traps.length,
            itemBuilder: (context, index) {
              final ChessTrap trap = traps[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: const Icon(Icons.psychology),
                  ),
                  title: Text(
                    trap.trapName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(trap.opening),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => TrapDetailRoute(index: index).push<void>(context),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
