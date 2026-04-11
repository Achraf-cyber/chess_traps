import 'package:flutter/material.dart';
import '../utils.dart';

class EvaluationBar extends StatelessWidget {
  const EvaluationBar({
    super.key,
    required this.score,
    required this.isWhiteOrientation,
    this.label,
    this.orientation = Axis.vertical,
  });

  final double score; // -10.0 to 10.0
  final bool isWhiteOrientation;
  final String? label;
  final Axis orientation;

  @override
  Widget build(BuildContext context) {
    final isVertical = orientation == Axis.vertical;

    // Clamp score for visual representation.
    // 0 -> center, 10.0 -> full white, -10.0 -> full black
    final clampedScore = score.clamp(-10.0, 10.0);

    // Calculate percentage fill for white.
    // +10 -> 1.0 (100% white)
    // 0 -> 0.5 (50% white)
    // -10 -> 0.0 (0% white)
    final whitePercentage = (clampedScore + 10.0) / 20.0;

    final whiteColor = Colors.grey.shade100;
    final blackColor = Colors.grey.shade900;

    final topColor = isWhiteOrientation ? blackColor : whiteColor;
    final bottomColor = isWhiteOrientation ? whiteColor : blackColor;

    final fillPercentage =
        isWhiteOrientation ? whitePercentage : 1.0 - whitePercentage;

    final displayLabel = label ?? score.abs().toStringAsFixed(1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalLength = isVertical ? constraints.maxHeight : constraints.maxWidth;
        final barThickness = isVertical ? constraints.maxWidth : constraints.maxHeight;

        return Container(
          decoration: BoxDecoration(
            color: topColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: context.colors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            alignment: isVertical ? Alignment.bottomCenter : Alignment.centerLeft,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                height: isVertical ? totalLength : barThickness,
                width: !isVertical ? totalLength : barThickness,
                alignment: isVertical ? Alignment.bottomCenter : Alignment.centerLeft,
                child: FractionallySizedBox(
                  heightFactor: isVertical ? fillPercentage : 1.0,
                  widthFactor: !isVertical ? fillPercentage : 1.0,
                  child: Container(color: bottomColor),
                ),
              ),
              // Score text
              Positioned.fill(
                child: Center(
                  child: RotatedBox(
                    quarterTurns: isVertical ? 1 : 0,
                    child: Text(
                      displayLabel,
                      style: TextStyle(
                        color: fillPercentage > 0.5
                            ? (bottomColor == whiteColor ? Colors.black : Colors.white)
                            : (topColor == whiteColor ? Colors.black : Colors.white),
                        fontSize: 10,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
