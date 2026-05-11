import 'package:flutter/material.dart';

class ProductivityRing extends StatelessWidget {
  const ProductivityRing({
    super.key,
    required this.progress,
    this.size = 64,
    this.strokeWidth = 7,
    this.showPercent = true,
  });

  final double progress;
  final double size;
  final double strokeWidth;
  final bool showPercent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalizedProgress = progress.clamp(0.0, 1.0);

    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: normalizedProgress,
            strokeWidth: strokeWidth,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
          if (showPercent)
            Text(
              '${(normalizedProgress * 100).round()}%',
              style: size < 40
                  ? theme.textTheme.labelSmall
                  : theme.textTheme.labelLarge,
            ),
        ],
      ),
    );
  }
}
