import 'package:chess_traps/data/chess_trap.dart';
import 'package:chess_traps/router.dart';
import 'package:chessground/chessground.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

class TrapWithName extends StatelessWidget {
  const TrapWithName({super.key, required this.label, required this.trap});
  final String label;
  final ChessTrap trap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          TrapDetailRoute(index: trap.id).push(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  label,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              StaticChessboard(size: 144, orientation: .white, fen: trap.fen),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  trap.trapName,
                  style: context.textTheme.bodySmall?.copyWith(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
