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
    final eval = evaluation ?? 0;
    // A mate score (encoded as ±999 by the caller) should render as a fully
    // filled bar for the mating side, rather than the near-full-but-not-quite
    // value that clamping centipawns to ±10 would otherwise produce.
    final isMate = eval.abs() >= 999;
    final percentage = isMate
        ? (eval > 0 ? 1.0 : 0.0)
        : (((eval / 100).clamp(-10.0, 10.0)) + 10) / 20;

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
              child: RotatedBox(
                quarterTurns: isHorizontal ? 0 : 3,
                child: Text(
                  label!,
                  style: context.textTheme.labelSmall?.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey, // Ensure contrast
                    fontFamily: 'monospace',
                  ),
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
