import 'package:flutter/material.dart';

import 'package:chess_traps/utils.dart';

class MoveChip extends StatelessWidget {
  const MoveChip({
    required this.san,
    required this.highlighted,
    required this.onTap,
  });

  final String san;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: BoxDecoration(
          color: highlighted ? context.colors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          san,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: highlighted
                ? context.colors.onPrimaryContainer
                : context.colors.onSurface,
          ),
        ),
      ),
    );
  }
}
