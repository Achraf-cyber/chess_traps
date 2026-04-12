import 'dart:math';
import 'dart:ui';
import 'package:chess_traps/generated/assets.dart';
import 'package:chess_traps/router.dart';
import 'package:chess_traps/widgets/trap_featured_card.dart';
import 'package:chess_traps/widgets/quick_action_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chess_traps/services/interstitial_ad_manager.dart';
import 'package:chess_traps/utils.dart';
import 'package:chess_traps/providers/traps_provider.dart';

class MainSubscreen extends ConsumerWidget {
  const MainSubscreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trapOfTheDay = ref.watch(trapOfTheDayProvider);
    final allTraps = ref.watch(trapsProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Stack(
            children: [
              Image.asset(
                AppAssets.imagesHomeImagePng,
                width: double.infinity,
                height: 280,
                fit: BoxFit.cover,
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        context.colors.surface.withValues(alpha: 0.9),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: context.colors.surface.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: context.colors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.offline_pin_rounded,
                                      size: 14,
                                      color: Colors.green.shade800,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Elevate Your Game",
                            style: context.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: context.colors.primary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            "Discover winning sequences used by masters.",
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colors.onSurfaceVariant,
                              letterSpacing: 0.1,
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
                  onTap: () {
                    final randomId = Random().nextInt(allTraps.length);
                    final randomTrap = allTraps[randomId];
                    InterstitialAdManager().onTrapViewed();
                    TrapDetailRoute(index: randomTrap.id).push<void>(context);
                  },
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
