import 'package:flutter/material.dart';

import '../../../shared/widgets/app_card.dart';

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

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(Icons.bedtime_outlined, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              sleepMinutes == null
                  ? 'Sleep: Not added yet'
                  : 'Sleep: ${_formatSleepDuration(sleepMinutes!)}',
              style: theme.textTheme.titleMedium,
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
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
