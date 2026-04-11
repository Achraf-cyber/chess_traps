import 'package:chess_traps/providers/traps_group_provider.dart';
import 'package:chess_traps/widgets/group_trap_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils.dart';

class TrapsGroupScreen extends ConsumerWidget {
  const TrapsGroupScreen({super.key, required this.groupName});
  final String groupName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elements = ref.watch(trapsOfGroupProvider(groupName));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          groupName,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        itemCount: elements.length,
        itemBuilder: (context, index) {
          return GroupTrapCard(trap: elements[index]);
        },
      ),
    );
  }
}
