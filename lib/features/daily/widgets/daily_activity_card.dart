import 'package:flutter/material.dart';

import '../../../data/mock_daymark_data.dart';
import '../../../models/models.dart';
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
    final colorScheme = theme.colorScheme;
    final status = isFutureDate
        ? DailyLogStatus.planned
        : entry.log?.status ?? DailyLogStatus.planned;
    final accentColor = _accentColor(entry.activity, category, status);
    final isLogged = entry.log != null && status != DailyLogStatus.planned;

    return Material(
      key: ValueKey('activity-card-${entry.activity.id}'),
      color: accentColor.withValues(alpha: _cardAlpha(status)),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onReview,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: colorScheme.onSurface.withValues(alpha: 0.10),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: isLogged ? 0.12 : 0.04),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _ActivityIcon(
                icon: _activityIcon(entry.activity, category),
                color: accentColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.activity.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                        decoration: status == DailyLogStatus.completed
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: colorScheme.outline.withValues(
                          alpha: 0.70,
                        ),
                        decorationThickness: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subtitle(status),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: _subtitleColor(
                          colorScheme: colorScheme,
                          accentColor: accentColor,
                          status: status,
                          isLogged: isLogged,
                        ),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _ActivityAction(
                entry: entry,
                status: status,
                isFutureDate: isFutureDate,
                onLogAction: onLogAction,
                onReview: onReview,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle(DailyLogStatus status) {
    if (isFutureDate) {
      return '${statusLabel(status)} · ${creditsLabel(entry.log, isFutureDate)}';
    }
    if (entry.log != null && showScore) {
      return '${statusLabel(status)} · ${creditsLabel(entry.log, false)}';
    }
    if (entry.log != null) {
      return statusLabel(status);
    }
    return '${category.name} · ${_actionLabel(entry.activity)}';
  }
}

class _ActivityAction extends StatelessWidget {
  const _ActivityAction({
    required this.entry,
    required this.status,
    required this.isFutureDate,
    required this.onLogAction,
    required this.onReview,
  });

  final DailyActivityEntry entry;
  final DailyLogStatus status;
  final bool isFutureDate;
  final ValueChanged<DailyActivityEntry> onLogAction;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLogged = entry.log != null && status != DailyLogStatus.planned;

    if (isFutureDate) {
      return _RoundIconButton(
        tooltip: 'Manage',
        icon: Icons.edit_calendar_outlined,
        onPressed: onReview,
        key: ValueKey('log-action-${entry.activity.id}'),
      );
    }
    if (isLogged) {
      return _RoundIconButton(
        tooltip: 'Review',
        icon: status == DailyLogStatus.completed
            ? Icons.check_circle
            : Icons.edit_square,
        onPressed: onReview,
        foregroundColor: status == DailyLogStatus.completed
            ? colorScheme.onSurfaceVariant
            : colorScheme.primary,
        key: ValueKey('log-action-${entry.activity.id}'),
      );
    }

    return _RoundIconButton(
      key: ValueKey('log-action-${entry.activity.id}'),
      onPressed: () => onLogAction(entry),
      tooltip: _actionLabel(entry.activity),
      icon: _actionIcon(entry.activity),
    );
  }
}

class _ActivityIcon extends StatelessWidget {
  const _ActivityIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.08),
        shape: BoxShape.circle,
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.foregroundColor,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        fixedSize: const Size.square(48),
        backgroundColor: colorScheme.surfaceContainerHighest,
        foregroundColor: foregroundColor ?? colorScheme.onSurfaceVariant,
      ),
      icon: Icon(icon, size: 30),
    );
  }
}

Color _accentColor(
  ActivityTemplate activity,
  ActivityCategory category,
  DailyLogStatus status,
) {
  if (status == DailyLogStatus.completed) {
    return const Color(0xFF4ADE80);
  }
  if (status == DailyLogStatus.partiallyCompleted) {
    return const Color(0xFFFBBF24);
  }
  if (status == DailyLogStatus.missed || status == DailyLogStatus.skipped) {
    return const Color(0xFFFCA5A5);
  }
  if (activity.activityType == ActivityType.negative) {
    return const Color(0xFFE7C365);
  }

  return switch (category.code) {
    'study' => const Color(0xFF60A5FA),
    'project' || 'work' => const Color(0xFF38BDF8),
    'health' => const Color(0xFF34D399),
    'personal' => const Color(0xFFCFBCFF),
    _ => const Color(0xFFCFBCFF),
  };
}

double _cardAlpha(DailyLogStatus status) {
  return switch (status) {
    DailyLogStatus.planned => 0.16,
    DailyLogStatus.completed => 0.18,
    DailyLogStatus.partiallyCompleted => 0.18,
    DailyLogStatus.missed || DailyLogStatus.skipped => 0.14,
    DailyLogStatus.notApplicable => 0.12,
  };
}

Color _subtitleColor({
  required ColorScheme colorScheme,
  required Color accentColor,
  required DailyLogStatus status,
  required bool isLogged,
}) {
  if (isLogged || status == DailyLogStatus.partiallyCompleted) {
    return accentColor;
  }
  return colorScheme.onSurface.withValues(alpha: 0.64);
}

IconData _activityIcon(ActivityTemplate activity, ActivityCategory category) {
  if (activity.activityType == ActivityType.negative) {
    return Icons.do_not_disturb_on_outlined;
  }
  return switch (category.code) {
    'good_habit' => Icons.auto_awesome_outlined,
    'study' => Icons.menu_book_outlined,
    'project' => Icons.laptop_mac_outlined,
    'work' => Icons.work_outline,
    'health' => Icons.favorite_border,
    'personal' => Icons.person_outline,
    'to_do' => Icons.checklist_outlined,
    _ => iconForTrackingType(activity.trackingType),
  };
}

IconData _actionIcon(ActivityTemplate activity) {
  if (activity.activityType == ActivityType.negative) {
    return switch (activity.trackingType) {
      TrackingType.boolean || TrackingType.milestone => Icons.check_circle,
      _ => Icons.remove_circle_outline,
    };
  }

  return switch (activity.trackingType) {
    TrackingType.boolean => Icons.check_circle,
    TrackingType.duration => Icons.play_circle,
    TrackingType.quantity => Icons.pin_outlined,
    TrackingType.level => Icons.tune,
    TrackingType.milestone => Icons.flag_outlined,
    TrackingType.categorical => Icons.category_outlined,
  };
}

String _actionLabel(ActivityTemplate activity) {
  if (activity.activityType == ActivityType.negative) {
    return switch (activity.trackingType) {
      TrackingType.boolean || TrackingType.milestone => 'Did not happen',
      _ => 'Choose level',
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
