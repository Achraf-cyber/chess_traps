import 'package:chess_traps/data/chess_trap.dart';
import 'package:chess_traps/providers/traps_group_provider.dart';
import 'package:chess_traps/widgets/trap_grid_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../router.dart';
import '../../../utils.dart';

class TrapsScreen extends ConsumerStatefulWidget {
  const TrapsScreen({super.key});

  @override
  ConsumerState<TrapsScreen> createState() => _TrapsScreenState();
}

class _TrapsScreenState extends ConsumerState<TrapsScreen> {
  final controller = TextEditingController();
  var searchValue = '';
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void updateChessResultList(String value) {
    setState(() {
      searchValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final trapsGroups = ref.watch(trapsGroupSourceProvider);
    final trapsSearched = ref.watch(trapsSearchByNameProvider(searchValue));
    return SafeArea(
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
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: SearchBar(
                controller: controller,
                elevation: WidgetStateProperty.all(0),
                backgroundColor: WidgetStateProperty.all(
                  context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
                ),
                hintText: context.phrase.wildGambit,
                leading: const Icon(Icons.search_rounded),
                onChanged: updateChessResultList,
              ),
            ),
          ),
          if (searchValue.isEmpty)
            ChessGroupGridSliver(trapsGroups: trapsGroups)
          else
            ChessTrapsGridSliver(traps: trapsSearched),
        ],
      ),
    );
  }
}

class ChessGroupGridSliver extends StatelessWidget {
  const ChessGroupGridSliver({super.key, required this.trapsGroups});

  final Map<String, List<int>> trapsGroups;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.82,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final entry = trapsGroups.entries.elementAt(index);
          return Container(
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: context.colors.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => TrapGroupRoute(name: entry.key).push<void>(context),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: context.colors.primaryContainer.withValues(alpha: 0.4),
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
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
              ),
            );
        }, childCount: trapsGroups.length),
      ),
    );
  }
}

class ChessTrapsGridSliver extends StatelessWidget {
  const ChessTrapsGridSliver({super.key, required this.traps});

  final List<ChessTrap> traps;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => TrapGridCard(trap: traps[index]),
          childCount: traps.length,
        ),
      ),
    );
  }
}
