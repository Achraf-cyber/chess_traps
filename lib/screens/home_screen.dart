import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/traps_provider.dart';
import 'dart:math';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trapsAsync = ref.watch(trapsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: trapsAsync.when(
        data: (traps) {
          if (traps.isEmpty) {
            return const Center(child: Text('No traps available.'));
          }
          final randomTrapIndex = Random().nextInt(traps.length);
          final randomTrap = traps[randomTrapIndex];

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text('Trap of the Day', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  onTap: () => context.push('/trap/$randomTrapIndex'),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Icon(Icons.psychology, size: 64, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 16),
                        Text(randomTrap.trapName, style: Theme.of(context).textTheme.titleLarge),
                        Text(randomTrap.opening),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text('Explore', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.go('/traps'),
                icon: const Icon(Icons.explore),
                label: const Text('View All Traps'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading traps: $err')),
      ),
    );
  }
}
