import 'package:flutter/material.dart';

import '../../../data/mock_daymark_data.dart';
import '../../../models/models.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../daily_formatters.dart';

class DailyActivityCard extends StatelessWidget {
  const DailyActivityCard({
    super.key,
    required this.entry,
    required this.category,
    required this.isFutureDate,
    required this.showScore,
    required this.onLogAction,
    required this.onReview,
  });

  final DailyActivityEntry entry;
  final ActivityCategory category;
  final bool isFutureDate;
  final bool showScore;
  final ValueChanged<DailyActivityEntry> onLogAction;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = isFutureDate
        ? DailyLogStatus.planned
        : entry.log?.status ?? DailyLogStatus.planned;

    return AppCard(
      key: ValueKey('activity-card-${entry.activity.id}'),
      onTap: onReview,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.activity.title,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(category.name, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              StatusBadge(
                label: statusLabel(status),
                color: statusColor(status),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (showScore) ...[
                Icon(
                  Icons.toll_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(creditsLabel(entry.log, isFutureDate)),
              ],
              const Spacer(),
              _ActivityAction(
                entry: entry,
                isFutureDate: isFutureDate,
                onLogAction: onLogAction,
                onReview: onReview,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityAction extends StatelessWidget {
  const _ActivityAction({
    required this.entry,
    required this.isFutureDate,
    required this.onLogAction,
    required this.onReview,
  });

  final DailyActivityEntry entry;
  final bool isFutureDate;
  final ValueChanged<DailyActivityEntry> onLogAction;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    if (isFutureDate) {
      return TextButton(onPressed: onReview, child: const Text('Manage'));
    }
    if (entry.log != null && entry.log!.status != DailyLogStatus.planned) {
      return OutlinedButton(onPressed: onReview, child: const Text('Review'));
    }

    return OutlinedButton(
      key: ValueKey('log-action-${entry.activity.id}'),
      onPressed: () => onLogAction(entry),
      child: Text(_actionLabel(entry.activity)),
    );
  }

  String _actionLabel(ActivityTemplate activity) {
    if (activity.activityType == ActivityType.negative) {
      return switch (activity.trackingType) {
        TrackingType.boolean || TrackingType.milestone => 'Did not happen',
        _ => 'Log',
      };
    }

    return switch (activity.trackingType) {
      TrackingType.boolean => 'Done',
      TrackingType.duration => 'Log time',
      TrackingType.quantity => 'Enter value',
      TrackingType.level => 'Choose level',
      TrackingType.milestone => 'Mark reached',
      TrackingType.categorical => 'Choose',
    };
  }
}
