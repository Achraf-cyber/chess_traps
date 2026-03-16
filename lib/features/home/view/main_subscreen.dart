import 'package:chess_traps/generated/assets.dart';
import 'package:chess_traps/widgets/trap_with_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils.dart';
import '../../../providers/traps_provider.dart';

class MainSubscreen extends ConsumerWidget {
  const MainSubscreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trapOfTheDay = ref.watch(trapOfTheDayProvider);
    final randomTrap = ref.watch(randomTrapProvider);

    return SafeArea(
      child: Column(
        // padding: const EdgeInsets.all(16.0),
        children: [
          Image.asset(AppAssets.imagesHomeImagePng),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TrapWithName(
                label: context.phrase.trapOfTheDay,
                trap: trapOfTheDay,
              ),
              TrapWithName(label: context.phrase.randomTrap, trap: randomTrap),
            ],
          ),
        ],
      ),
    );
  }
}
