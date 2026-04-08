import 'dart:ui';
import 'package:chess_traps/generated/assets.dart';
import 'package:chess_traps/router.dart';
import 'package:chess_traps/widgets/trap_featured_card.dart';
import 'package:chess_traps/widgets/quick_action_card.dart';
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

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Stack(
            children: [
              Image.asset(
                AppAssets.imagesHomeImagePng,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.colors.surface.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: context.colors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            context.phrase.elevateYourGame,
                            style: context.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: context.colors.primary,
                            ),
                          ),
                          Text(
                            context.phrase.discoverWinningSequencesByMasters,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.phrase.highlight,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                TrapFeaturedCard(
                  trap: trapOfTheDay,
                  title: context.phrase.trapOfTheDay,
                ),
                const SizedBox(height: 24),
                Text(
                  context.phrase.exploreMore,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                QuickActionCard(
                  title: context.phrase.randomTrap,
                  subtitle: context.phrase.testYourPatternRecog,
                  icon: Icons.shuffle_rounded,
                  color: context.colors.secondaryContainer.withValues(
                    alpha: 0.5,
                  ),
                  onTap: () =>
                      TrapDetailRoute(index: randomTrap.id).push<void>(context),
                ),
                const SizedBox(height: 12),
                QuickActionCard(
                  title: context.phrase.strategyGuide,
                  subtitle: context.phrase.comingSoonDeepDives,
                  icon: Icons.auto_stories_rounded,
                  color: context.colors.tertiaryContainer.withValues(
                    alpha: 0.4,
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
