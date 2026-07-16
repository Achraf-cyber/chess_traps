import 'package:chess_traps/core/constants/app_sizes.dart';
import 'package:chess_traps/data/traps/chess_trap.dart';
import 'package:chess_traps/presentation/state/traps/traps_group_provider.dart';
import 'package:chess_traps/presentation/widgets/explore_trap_card.dart';
import 'package:chess_traps/presentation/widgets/hero_featured_trap_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final featuredTrap = ref.watch(randomFeaturedTrapProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            // ── App bar ───────────────────────────────────────────────
            SliverAppBar(
              floating: true,
              backgroundColor: scheme.surface,
              surfaceTintColor: Colors.transparent,
              title: Text(
                context.phrase.chessTraps,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.travel_explore),
                  tooltip: context.phrase.searchByName, // or 'Search by moves'
                  onPressed: () {
                    const SearchByMovesRoute().push<void>(context);
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),

            // ── Search bar ────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverToBoxAdapter(
                child: _SearchField(
                  controller: _searchController,
                  hint: context.phrase.searchByName,
                  onChanged: (v) => setState(() => _searchValue = v),
                ),
              ),
            ),

            // ── Ad banner ─────────────────────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
              ),
            ),

            if (_searchValue.isEmpty) ...[
              // ── Hero featured card ──────────────────────────────────
              if (featuredTrap != null)
                SliverToBoxAdapter(
                  child: HeroFeaturedTrapCard(trap: featuredTrap),
                ),

              // ── Browse by opening ───────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
                  child: Text(
                    context.phrase.browseByOpening,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _OpeningGroupsRow(trapsGroups: trapsGroups),
              ),

              // ── All traps header ────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    context.phrase.allTraps,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ] else ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    context.phrase.searchResults,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],

            // ── Trap grid ─────────────────────────────────────────────
            _TrapsGrid(traps: trapsSearched),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Opening groups horizontal scroll
// ─────────────────────────────────────────────────────────────────────────────

class _OpeningGroupsRow extends StatelessWidget {
  const _OpeningGroupsRow({required this.trapsGroups});
  final Map<String, List<int>> trapsGroups;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final entries = trapsGroups.entries.toList();

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: entries.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final entry = entries[index];
          return InkWell(
            onTap: () => TrapGroupRoute(name: entry.key).push<void>(context),
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                border: Border.all(color: scheme.outline.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${entry.value.length}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Trap grid
// ─────────────────────────────────────────────────────────────────────────────

class _TrapsGrid extends StatelessWidget {
  const _TrapsGrid({required this.traps});
  final List<ChessTrap> traps;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => ExploreTrapCard(trap: traps[index]),
          childCount: traps.length,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search field
// ─────────────────────────────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(
          Icons.search_rounded,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
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
      ),
    );
  }
}

// Keep the old public name available for backward compatibility with imports
// that might reference it (e.g., from search_by_moves screen).
typedef FloatingSearchTextField = _SearchField;
