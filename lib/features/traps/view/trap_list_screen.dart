import 'package:chess_traps/data/chess_trap.dart';
import 'package:chess_traps/providers/traps_group_provider.dart';
import 'package:chess_traps/widgets/ad_banner_widget.dart';
import 'package:chess_traps/widgets/explore_trap_card.dart';
import 'package:chess_traps/widgets/hero_featured_trap_card.dart';
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

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: context.colors.surface,
              surfaceTintColor: Colors.transparent,
              centerTitle: true,
              title: Text(
                context.phrase.chessTraps,
                style: context.textTheme.headlineSmall?.copyWith(
                  color: context.colors.onSurface,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              sliver: SliverToBoxAdapter(
                child: FloatingSearchTextField(
                  onChanged: (p0) => setState(() => _searchValue = p0),
                  controller: _searchController,
                  hint: context.phrase.searchByName,
                ),
              ),
            ),

            // Ad Banner elegantly integrated right after search
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: AdBannerWidget(),
              ),
            ),

            if (_searchValue.isEmpty) ...[
              if (featuredTrap != null)
                SliverToBoxAdapter(
                  child: HeroFeaturedTrapCard(trap: featuredTrap),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Text(
                    context.phrase.browseByOpening,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: HorizontalTrapGroups(trapsGroups: trapsGroups),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                  child: Text(
                    context.phrase.allTraps,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              TrapsGridSliver(traps: trapsSearched),
            ] else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    context.phrase.searchResults,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              TrapsGridSliver(traps: trapsSearched),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class HorizontalTrapGroups extends StatelessWidget {
  const HorizontalTrapGroups({super.key, required this.trapsGroups});

  final Map<String, List<int>> trapsGroups;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: trapsGroups.length,
        itemBuilder: (context, index) {
          final entry = trapsGroups.entries.elementAt(index);
          return Container(
            width: 140,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: context.colors.outlineVariant),
              ),
              color: context.colors.surfaceContainerHighest,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  TrapGroupRoute(name: entry.key).push<void>(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        entry.key,
                        textAlign: TextAlign.center,
                        style: context.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: context.colors.onSurface,
                          height: 1.1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: context.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: context.colors.onSurfaceVariant),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: context.colors.onSurfaceVariant,
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}
