import 'package:flutter/material.dart';

import '../../../data/mock_daymark_data.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/productivity_ring.dart';
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
    final progress = summary.expectedCredits <= 0 || !showDailyScore
        ? 0.0
        : summary.earnedCredits / summary.expectedCredits;

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          if (showDailyScore) ...[
            ProductivityRing(progress: progress),
            const SizedBox(width: 18),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  showDailyScore
                      ? '${formatCredit(summary.earnedCredits)} / '
                            '${formatCredit(summary.expectedCredits)} credits'
                      : 'Daily score hidden',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  '${summary.completedCount} done · '
                  '${summary.partialCount} partial · '
                  '${summary.remainingCount} left · '
                  '${summary.missedOrSkippedCount} missed',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
