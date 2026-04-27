import 'dart:math' as math;

import 'package:chess_traps/data/chess_trap.dart';
import 'package:chess_traps/providers/traps_group_provider.dart';
import 'package:chess_traps/providers/traps_provider.dart';
import 'package:chess_traps/widgets/ad_banner_widget.dart';
import 'package:chess_traps/widgets/explore_trap_card.dart';
import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chess_traps/generated/chess/base_chess_traps.dart';

import '../../../router.dart';
import '../../../utils.dart';

class TrapListScreen extends ConsumerStatefulWidget {
  const TrapListScreen({super.key});

  @override
  ConsumerState<TrapListScreen> createState() => _TrapListScreenState();
}

class _TrapListScreenState extends ConsumerState<TrapListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchValue = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trapsGroups = ref.watch(trapsGroupSourceProvider);
    final trapsSearched = ref.watch(trapsSearchByNameProvider(_searchValue));

    return Scaffold(
      bottomNavigationBar: const AdBannerWidget(),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  context.phrase.chessTraps,
                  textAlign: TextAlign.center,
                  style: context.textTheme.headlineSmall?.copyWith(
                    color: context.colors.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverToBoxAdapter(
                child: FloatingSearchTextField(
                  onChanged: (p0) => setState(() => _searchValue = p0),
                  controller: _searchController,
                  hint: context.phrase.searchByName,
                ),
              ),
            ),
            if (_searchValue.isEmpty) ...[
              const SliverToBoxAdapter(child: _TrapOfTheDayCard()),
              TrapGroupGridSliver(trapsGroups: trapsGroups),
            ] else
              TrapsGridSliver(traps: trapsSearched),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class TrapGroupGridSliver extends ConsumerWidget {
  const TrapGroupGridSliver({super.key, required this.trapsGroups});

  final Map<String, List<int>> trapsGroups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final entry = trapsGroups.entries.elementAt(index);
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: context.colors.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                TrapGroupRoute(name: entry.key).push<void>(context);
              },
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: context.colors.primaryContainer.withValues(
                                alpha: 0.4,
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Icon(
                            Icons.collections_bookmark_rounded,
                            color: context.colors.primary,
                            size: 36,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          entry.key,
                          textAlign: TextAlign.center,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: context.colors.onSurface,
                            height: 1.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${entry.value.length} Traps",
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colors.onSecondaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }, childCount: trapsGroups.length),
      ),
    );
  }
}

class TrapsGridSliver extends StatelessWidget {
  const TrapsGridSliver({super.key, required this.traps});

  final List<ChessTrap> traps;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.72,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final trap = traps[index];
          return ExploreTrapCard(trap: trap);
        }, childCount: traps.length),
      ),
    );
  }
}

class FloatingSearchTextField extends StatelessWidget {
  const FloatingSearchTextField({
    super.key,
    required this.onChanged,
    required this.controller,
    required this.hint,
  });

  final void Function(String) onChanged;
  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: context.colors.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                  icon: const Icon(Icons.close_rounded),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
        ),
      ),
    );
  }
}

class _TrapOfTheDayCard extends ConsumerWidget {
  const _TrapOfTheDayCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (chessTraps.isEmpty) return const SizedBox.shrink();

    final trap = ref.watch(trapOfTheDayProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 18,
                color: context.colors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'TRAP OF THE DAY',
                style: context.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 360;
              final cardHeight = isCompact ? 320.0 : 180.0;
              final boardSize = isCompact
                  ? math.min(constraints.maxWidth - 48, 220).toDouble()
                  : math.min((constraints.maxWidth * 0.38), 150).toDouble();

              return Container(
                height: cardHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.colors.primaryContainer.withValues(alpha: 0.5),
                      context.colors.surface,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: context.colors.primary.withValues(alpha: 0.1),
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: isCompact
                    ? Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: _TrapOfDayTextContent(trap: trap),
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: IgnorePointer(
                              child: StaticChessboard(
                                size: boardSize,
                                orientation: Side.white,
                                fen: trap.fen,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: _TrapOfDayTextContent(trap: trap),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: IgnorePointer(
                                  child: StaticChessboard(
                                    size: boardSize,
                                    orientation: Side.white,
                                    fen: trap.fen,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TrapOfDayTextContent extends StatelessWidget {
  const _TrapOfDayTextContent({required this.trap});

  final ChessTrap trap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          trap.getLocalizedName(context),
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          trap.opening,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        FilledButton.tonal(
          onPressed: () => TrapDetailRoute(index: trap.id).push<void>(context),
          style: FilledButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          child: const Text("Master Now"),
        ),
      ],
    );
  }
}
