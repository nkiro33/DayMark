import 'package:flutter/material.dart';

import '../../../data/presaved_activity_templates.dart';
import '../../../models/models.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../daily/daily_formatters.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.activity,
    required this.category,
    required this.schedule,
    required this.creditRule,
    required this.onTap,
  });

  final ActivityTemplate activity;
  final ActivityCategory category;
  final ActivitySchedule? schedule;
  final CreditRule? creditRule;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedColor = theme.colorScheme.onSurface.withValues(alpha: 0.62);

    return Opacity(
      opacity: activity.isActive ? 1 : 0.62,
      child: AppCard(
        key: ValueKey('activity-management-card-${activity.id}'),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  iconForTrackingType(activity.trackingType),
                  color: activity.isActive
                      ? theme.colorScheme.primary
                      : mutedColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(activity.title, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        '${category.name} · ${trackingLabel(activity.trackingType)} · ${scheduleLabel(schedule, activity.activityScope)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: mutedColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(
                  label: activity.isActive ? 'Active' : 'Inactive',
                  color: activity.isActive
                      ? const Color(0xFF2E7D5B)
                      : const Color(0xFF5D6F82),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  icon: Icons.calendar_today_outlined,
                  label: scheduleLabel(schedule, activity.activityScope),
                ),
                _InfoChip(
                  icon: Icons.toll_outlined,
                  label: creditSummary(activity, creditRule),
                ),
                if (activity.activityScope == ActivityScope.manual)
                  const _InfoChip(
                    icon: Icons.touch_app_outlined,
                    label: 'Manual',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PresavedTemplateCard extends StatelessWidget {
  const PresavedTemplateCard({
    super.key,
    required this.template,
    required this.category,
    required this.onTap,
    required this.onUseTemplate,
  });

  final PresavedActivityTemplate template;
  final ActivityCategory category;
  final VoidCallback onTap;
  final VoidCallback onUseTemplate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedColor = theme.colorScheme.onSurface.withValues(alpha: 0.62);

    return Opacity(
      opacity: 0.72,
      child: AppCard(
        key: ValueKey('presaved-template-card-${template.id}'),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(iconForTemplate(template.iconName), color: mutedColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(template.title, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        '${category.name} · ${trackingLabel(template.trackingType)} · ${templateScheduleLabel(template)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: mutedColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const StatusBadge(label: 'Inactive', color: Color(0xFF5D6F82)),
              ],
            ),
            const SizedBox(height: 8),
            Text(template.description, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(
                        icon: Icons.calendar_today_outlined,
                        label: templateScheduleLabel(template),
                      ),
                      _InfoChip(
                        icon: Icons.toll_outlined,
                        label: templateCreditSummary(template),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: onUseTemplate,
                  icon: const Icon(Icons.add),
                  label: const Text('Use Template'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.58,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Flexible(child: Text(label, style: theme.textTheme.labelMedium)),
          ],
        ),
      ),
    );
  }
}

String scheduleLabel(ActivitySchedule? schedule, ActivityScope scope) {
  if (scope == ActivityScope.oneTime) {
    return 'Once';
  }
  if (scope == ActivityScope.manual ||
      schedule?.frequency == ScheduleFrequency.manual) {
    return 'Manual';
  }
  if (schedule == null) {
    return 'Manual';
  }

  return switch (schedule.frequency) {
    ScheduleFrequency.daily => 'Daily',
    ScheduleFrequency.weekly || ScheduleFrequency.custom =>
      schedule.daysOfWeek.isEmpty
          ? 'Selected days'
          : schedule.daysOfWeek.map(_weekdayLabel).join(', '),
    ScheduleFrequency.manual => 'Manual',
  };
}

String templateScheduleLabel(PresavedActivityTemplate template) {
  return switch (template.frequency) {
    ScheduleFrequency.daily => 'Daily',
    ScheduleFrequency.weekly || ScheduleFrequency.custom =>
      template.daysOfWeek.isEmpty
          ? 'Selected days'
          : template.daysOfWeek.map(_weekdayLabel).join(', '),
    ScheduleFrequency.manual => 'Manual',
  };
}

String creditSummary(ActivityTemplate activity, CreditRule? rule) {
  if (rule == null) {
    return 'No scoring yet';
  }

  final cap = rule.maxDailyCredit == null
      ? ''
      : ' · Max ${formatCredit(rule.maxDailyCredit!)}/day';

  return switch (activity.trackingType) {
    TrackingType.duration when rule.creditPerMinute > 0 =>
      '+${formatCredit(rule.creditPerMinute * 15)} / 15 min$cap',
    TrackingType.quantity when rule.creditPerUnit > 0 =>
      '+${formatCredit(rule.creditPerUnit)} / item$cap',
    TrackingType.level when rule.penaltyCredit < 0 =>
      'Penalty up to ${formatCredit(rule.penaltyCredit)}',
    TrackingType.categorical => 'Custom option credits',
    _ when rule.baseCredit != 0 => '${_signed(rule.baseCredit)} credits$cap',
    _ => 'Credits optional',
  };
}

String templateCreditSummary(PresavedActivityTemplate template) {
  final rule = CreditRule(
    id: '${template.id}-preview-credit',
    activityId: template.id,
    baseCredit: template.baseCredit,
    creditPerMinute: template.creditPerMinute,
    creditPerUnit: template.creditPerUnit,
    maxDailyCredit: template.maxDailyCredit,
    penaltyCredit: template.penaltyCredit,
  );
  final activity = ActivityTemplate(
    id: '${template.id}-preview-activity',
    userId: 'preview',
    categoryId: template.categoryId,
    title: template.title,
    description: template.description,
    activityType: template.activityType,
    trackingType: template.trackingType,
    activityScope: template.activityScope,
    createdAt: DateTime(2000),
    updatedAt: DateTime(2000),
  );
  return creditSummary(activity, rule);
}

IconData iconForTemplate(String iconName) {
  return switch (iconName) {
    'work' => Icons.work_outline,
    'laptop' => Icons.laptop_mac_outlined,
    'school' => Icons.school_outlined,
    'menu_book' => Icons.menu_book_outlined,
    'checklist' => Icons.checklist,
    'bed' => Icons.bed_outlined,
    'water_drop' => Icons.water_drop_outlined,
    'fitness_center' => Icons.fitness_center,
    'bedtime' => Icons.bedtime_outlined,
    'phone_android' => Icons.phone_android_outlined,
    'fastfood' => Icons.fastfood_outlined,
    'construction' => Icons.construction_outlined,
    'flag' => Icons.flag_outlined,
    'cleaning_services' => Icons.cleaning_services_outlined,
    'send' => Icons.send_outlined,
    'event' => Icons.event_outlined,
    _ => Icons.list_alt_outlined,
  };
}

String _signed(double value) {
  final formatted = formatCredit(value);
  return value > 0 ? '+$formatted' : formatted;
}

String _weekdayLabel(int weekday) {
  return const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekday - 1];
}
