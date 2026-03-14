import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/traps_provider.dart';

class TrapsScreen extends ConsumerWidget {
  const TrapsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trapsAsync = ref.watch(trapsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Traps')),
      body: trapsAsync.when(
        data: (traps) {
          if (traps.isEmpty) {
            return const Center(child: Text('No traps found.'));
          }
          return ListView.builder(
            itemCount: traps.length,
            itemBuilder: (context, index) {
              final trap = traps[index];
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
                  onTap: () {
                    context.push('/trap/$index');
                  },
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
