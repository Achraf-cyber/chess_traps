import 'package:chess_traps/data/chess_trap.dart';
import 'package:chess_traps/providers/traps_group_provider.dart';
import 'package:chess_traps/widgets/ad_banner_widget.dart';
import 'package:chess_traps/widgets/trap_grid_card.dart';
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
          childAspectRatio: 0.85,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final trap = traps[index];
          return TrapGridCard(trap: trap);
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

class _TrapOfTheDayCard extends StatelessWidget {
  const _TrapOfTheDayCard();

  @override
  Widget build(BuildContext context) {
    if (chessTraps.isEmpty) return const SizedBox.shrink();

    // Deterministic random based on the day of the year
    final dayOfYear = DateTime.now()
        .difference(DateTime(DateTime.now().year))
        .inDays;
    final index = dayOfYear % chessTraps.length;
    final trap = chessTraps[index];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              '✨ Trap of the Day',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.primary,
              ),
            ),
          ),
          SizedBox(
            height: 140, // Adjust height as necessary
            child: TrapGridCard(trap: trap),
          ),
        ],
      ),
    );
  }
}
