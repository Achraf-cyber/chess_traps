import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chess_traps/presentation/state/traps/traps_provider.dart';
import 'package:chess_traps/presentation/widgets/explore_trap_card.dart';
import 'package:chess_traps/utils.dart';

class RelatedTrapsStrip extends ConsumerWidget {
  const RelatedTrapsStrip({required this.trapId});
  final int trapId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final related = ref.watch(relatedTrapsProvider(trapId));
    if (related.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.colors.outlineVariant.withValues(alpha: 0.3))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.phrase.relatedTraps,
            style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: related.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) => SizedBox(
                width: 130,
                child: ExploreTrapCard(trap: related[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
