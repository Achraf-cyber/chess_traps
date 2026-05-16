import 'package:flutter/material.dart';
import 'package:chess_traps/utils.dart';

class EvaluationBar extends StatelessWidget {
  const EvaluationBar({
    super.key,
    required this.evaluation,
    this.isReversed = false,
    this.orientation = Axis.vertical,
    this.label,
  });

  /// Evaluation value in centipawns. Positive for white, negative for black.
  final double? evaluation;
  final bool isReversed;
  final Axis orientation;
  final String? label;

  @override
  Widget build(BuildContext context) {
    // Clamp evaluation between -10 and 10 for visual representation
    // 1000 centipawns = 10 points
    final eval = evaluation ?? 0;
    final displayEval = (eval / 100).clamp(-10.0, 10.0);
    
    // Convert -10..10 range to 0..1 percentage (white's advantage)
    final percentage = (displayEval + 10) / 20;
    
    final whiteFactor = percentage;
    final blackFactor = 1 - percentage;

    final isHorizontal = orientation == Axis.horizontal;

    final children = isReversed 
        ? [
            _buildSegment(context, Colors.white, whiteFactor),
            _buildSegment(context, Colors.black87, blackFactor),
          ]
        : [
            _buildSegment(context, Colors.black87, blackFactor),
            _buildSegment(context, Colors.white, whiteFactor),
          ];

    return Container(
      width: isHorizontal ? double.infinity : 12,
      height: isHorizontal ? double.infinity : double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isHorizontal ? 999 : 2),
        border: Border.all(color: context.colors.outlineVariant, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          isHorizontal 
              ? Row(children: children) 
              : Column(children: children),
          if (label != null)
            Center(
              child: Text(
                label!,
                style: context.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.grey, // Ensure contrast
                  fontFamily: 'monospace',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSegment(BuildContext context, Color color, double factor) {
    return Expanded(
      flex: (factor * 1000).toInt().clamp(1, 1000),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        color: color,
      ),
    );
  }
}
