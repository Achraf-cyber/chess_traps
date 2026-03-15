import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../router.dart';
import '../../../utils.dart';
import '../../traps/data/chess_trap.dart';
import '../../traps/provider/traps_provider.dart';

class MainSubscreen extends ConsumerWidget {
  const MainSubscreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ChessTrap>> trapsAsync = ref.watch(trapsProvider);

    return trapsAsync.when(
      data: (traps) {
        if (traps.isEmpty) {
          return Center(child: Text(context.phrase.noTrapsFound));
        }
        
        final int randomTrapIndex = Random().nextInt(traps.length);
        final ChessTrap randomTrap = traps[randomTrapIndex];

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              context.phrase.trapOfTheDay,
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () => TrapDetailRoute(index: randomTrapIndex).push<void>(context),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.psychology,
                        size: 64,
                        color: context.colors.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        randomTrap.trapName,
                        style: context.textTheme.titleLarge,
                      ),
                      Text(randomTrap.opening),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              context.phrase.explore,
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // In this modular structure, the HomeScreen handles the index.
                // But context.go('/traps') might or might not work depending on how router is setup.
                // architecture.md says use Routing System for inter-feature communication.
                const TrapsRoute().push<void>(context); 
              },
              icon: const Icon(Icons.explore),
              label: Text(context.phrase.viewAllTraps),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Text('${context.phrase.errorLoadingTraps}: $err'),
      ),
    );
  }
}
