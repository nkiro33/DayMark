import 'package:flutter/material.dart';

class SleepInputCard extends StatelessWidget {
  const SleepInputCard({
    super.key,
    required this.sleepMinutes,
    required this.onTap,
  });

  final int? sleepMinutes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final label = sleepMinutes == null
        ? 'Sleep: Not added'
        : 'Sleep: ${_formatSleepDuration(sleepMinutes!)}';

    return Material(
      color: colorScheme.onSurface.withValues(alpha: 0.05),
      shape: StadiumBorder(
        side: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.10)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bedtime, size: 18, color: colorScheme.tertiary),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatSleepDuration(int minutes) {
  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;
  if (remainingMinutes == 0) {
    return '${hours}h';
  }
  if (hours == 0) {
    return '${remainingMinutes}m';
  }
  return '${hours}h ${remainingMinutes}m';
}
