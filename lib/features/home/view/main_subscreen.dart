import 'dart:math';
import 'package:chess_traps/router.dart';
import 'package:chess_traps/widgets/trap_featured_card.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        // ── Hero Section ────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: _HeroSection(isDark: isDark, totalTraps: allTraps.length),
        ),

        // ── Trap of the Day ─────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                  label: context.phrase.highlight,
                  icon: Icons.local_fire_department_rounded,
                ),
                const SizedBox(height: 14),
                TrapFeaturedCard(
                  trap: trapOfTheDay,
                  title: context.phrase.trapOfTheDay,
                ),
              ],
            ),
          ),
        ),

        // ── Quick Actions ────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                  label: context.phrase.exploreMore,
                  icon: Icons.explore_rounded,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _ActionTile(
                        icon: Icons.shuffle_rounded,
                        label: context.phrase.randomTrap,
                        sublabel: 'Surprise me',
                        color: const Color(0xFF5D5FEF),
                        onTap: () {
                          final randomId = Random().nextInt(allTraps.length);
                          final randomTrap = allTraps[randomId];
                          InterstitialAdManager().onTrapViewed();
                          TrapDetailRoute(
                            index: randomTrap.id,
                          ).push<void>(context);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionTile(
                        icon: Icons.videogame_asset_rounded,
                        label: 'Play Mode',
                        sublabel: 'vs Engine',
                        color: const Color(0xFF00C48C),
                        onTap: () => const PlayRoute().go(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ActionTile(
                        icon: Icons.search_rounded,
                        label: 'By Moves',
                        sublabel: 'Find by position',
                        color: const Color(0xFFFF4B55),
                        onTap: () => const SearchByMovesRoute().go(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionTile(
                        icon: Icons.format_list_bulleted_rounded,
                        label: 'All Traps',
                        sublabel: '${allTraps.length} traps',
                        color: const Color(0xFFFF9F0A),
                        onTap: () => const TrapsRoute().go(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Section
// ─────────────────────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.isDark, required this.totalTraps});
  final bool isDark;
  final int totalTraps;

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFF0F3460);
    final foregroundColor =
        bgColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;

    return Container(
      height: 260,
      width: double.infinity,
      color: bgColor,
      child: Stack(
        children: [
          // Decorative chess pattern background
          Positioned.fill(
            child: CustomPaint(
              painter: _ChessPatternPainter(color: foregroundColor),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 52, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: foregroundColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: foregroundColor.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$totalTraps Opening Traps',
                        style: TextStyle(
                          color: foregroundColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Outplay Your\nOpponent',
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Master the traps that grandmasters use.',
                  style: TextStyle(
                    color: foregroundColor.withValues(alpha: 0.75),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                // Stats row
                Row(
                  children: [
                    _HeroStat(
                      label: 'Traps',
                      value: totalTraps.toString(),
                      color: foregroundColor,
                    ),
                    _HeroDivider(color: foregroundColor),
                    _HeroStat(
                      label: 'Openings',
                      value: '40+',
                      color: foregroundColor,
                    ),
                    _HeroDivider(color: foregroundColor),
                    _HeroStat(
                      label: 'Languages',
                      value: '4',
                      color: foregroundColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.6),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _HeroDivider extends StatelessWidget {
  const _HeroDivider({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: 1,
      height: 32,
      color: color.withValues(alpha: 0.2),
    );
  }
}

// Chess board pattern painter
class _ChessPatternPainter extends CustomPainter {
  _ChessPatternPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    const squareSize = 28.0;
    final cols = (size.width / squareSize).ceil() + 1;
    final rows = (size.height / squareSize).ceil() + 1;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if ((r + c) % 2 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(
              c * squareSize - 14,
              r * squareSize - 14,
              squareSize,
              squareSize,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: context.colors.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action Tile (2x2 grid)
// ─────────────────────────────────────────────────────────────────────────────
class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Calculate foreground color based on background luminance for contrast
    final foregroundColor =
        color.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            splashColor: foregroundColor.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: foregroundColor, size: 28),
                  const Spacer(),
                  Text(
                    label,
                    style: TextStyle(
                      color: foregroundColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: TextStyle(
                      color: foregroundColor.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
