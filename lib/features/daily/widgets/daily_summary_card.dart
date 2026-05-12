import 'package:flutter/material.dart';

import '../../../data/mock_daymark_data.dart';
import '../daily_formatters.dart';

class DailySummaryCard extends StatelessWidget {
  const DailySummaryCard({
    super.key,
    required this.summary,
    required this.showDailyScore,
  });

  final DailySummary summary;
  final bool showDailyScore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDailyScore)
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 6,
            children: [
              Text(
                formatCredit(summary.earnedCredits),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  '/ ${formatCredit(summary.expectedCredits)} credits',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          )
        else
          Text(
            'Daily score hidden',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        const SizedBox(height: 3),
        Text(
          '${summary.completedCount} done · '
          '${summary.partialCount} partial · '
          '${summary.remainingCount} left',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
