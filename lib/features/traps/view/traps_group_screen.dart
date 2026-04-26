import 'package:chess_traps/providers/traps_group_provider.dart';
import 'package:chess_traps/data/chess_trap.dart';
import 'package:chess_traps/data/openings.dart';
import 'package:chess_traps/widgets/group_trap_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils.dart';

class TrapsGroupScreen extends ConsumerWidget {
  const TrapsGroupScreen({super.key, required this.groupName});
  final String groupName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elements = ref
        .watch(trapsOfGroupProvider(groupName))
        .where(_isRenderableTrap)
        .toList();
    final ecoLabel = _ecoLabelForGroup(groupName);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              groupName,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            if (ecoLabel.isNotEmpty)
              Text(
                ecoLabel,
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
      body: elements.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No traps available for this opening yet.',
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: elements.length,
              itemBuilder: (context, index) {
                return GroupTrapCard(trap: elements[index]);
              },
            ),
    );
  }

  String _ecoLabelForGroup(String groupName) {
    final entries = ecoOpeningIndexes.byName[groupName] ?? const [];
    final ecoRanges = entries.map((entry) => entry.eco.toString()).toSet();
    return ecoRanges.join(', ');
  }

  bool _isRenderableTrap(ChessTrap trap) {
    final hasName = trap.trapName.trim().isNotEmpty;
    final hasContent = trap.commentedMoves.trim().isNotEmpty;
    final hasMoves = trap.moves.isNotEmpty;
    final hasLikelyFen = _isLikelyFen(trap.fen);
    return hasName && hasContent && hasMoves && hasLikelyFen;
  }

  bool _isLikelyFen(String fen) {
    final parts = fen.trim().split(RegExp(r'\s+'));
    return parts.length >= 2 && parts.first.contains('/');
  }
}
