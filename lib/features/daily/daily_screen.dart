import 'package:flutter/material.dart';

import '../../data/mock_daymark_data.dart';
import '../../models/models.dart';

enum DailyFilter { all, toDo, completed, missed }

class DailyScreen extends StatefulWidget {
  const DailyScreen({super.key});

  @override
  State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  final MockDaymarkData _data = MockDaymarkData();
  late DateTime _selectedDate = _data.today;
  DailyFilter _selectedFilter = DailyFilter.all;

  @override
  Widget build(BuildContext context) {
    final isFutureDate = _isAfterDate(_selectedDate, _data.today);
    final entries = _filteredEntries(_data.getActivitiesForDate(_selectedDate));
    final summary = _data.getDailySummary(_selectedDate);
    final checkIn = _checkInForDate(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(_titleForDate(_selectedDate, _data.today)),
        actions: [
          IconButton(
            onPressed: null,
            tooltip: 'Open calendar',
            icon: const Icon(Icons.calendar_month_outlined),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              key: const ValueKey('daily-primary-action'),
              onPressed: null,
              icon: Icon(isFutureDate ? Icons.add : Icons.add_task),
              label: Text(isFutureDate ? '+ Add' : '+ Log'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _DailySummaryCard(summary: summary),
          const SizedBox(height: 16),
          _DaySelector(
            today: _data.today,
            selectedDate: _selectedDate,
            summaryForDate: _data.getDailySummary,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),
          const SizedBox(height: 16),
          _SleepCard(sleepHours: checkIn?.sleepHours),
          const SizedBox(height: 16),
          _FilterChips(
            selectedFilter: _selectedFilter,
            onSelected: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            _EmptyDailyState(isFutureDate: isFutureDate)
          else
            for (final entry in entries) ...[
              _ActivityCard(
                entry: entry,
                category: _categoryForActivity(entry.activity),
                isFutureDate: isFutureDate,
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }

  List<DailyActivityEntry> _filteredEntries(List<DailyActivityEntry> entries) {
    return switch (_selectedFilter) {
      DailyFilter.all => entries,
      DailyFilter.toDo =>
        entries
            .where(
              (entry) =>
                  entry.log == null ||
                  entry.log!.status == DailyLogStatus.planned,
            )
            .toList(),
      DailyFilter.completed =>
        entries
            .where((entry) => entry.log?.status == DailyLogStatus.completed)
            .toList(),
      DailyFilter.missed =>
        entries
            .where(
              (entry) =>
                  entry.log?.status == DailyLogStatus.missed ||
                  entry.log?.status == DailyLogStatus.skipped,
            )
            .toList(),
    };
  }

  DailyCheckIn? _checkInForDate(DateTime date) {
    return _data.dailyCheckIns
        .where((checkIn) => _isSameDate(checkIn.date, date))
        .firstOrNull;
  }

  ActivityCategory _categoryForActivity(ActivityTemplate activity) {
    return _data.categories
        .where((category) => category.id == activity.categoryId)
        .first;
  }
}

class _DailySummaryCard extends StatelessWidget {
  const _DailySummaryCard({required this.summary});

  final DailySummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = summary.expectedCredits <= 0
        ? 0.0
        : (summary.earnedCredits / summary.expectedCredits).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 64,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 7,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: theme.textTheme.labelLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_formatCredit(summary.earnedCredits)} / '
                    '${_formatCredit(summary.expectedCredits)} credits',
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
      ),
    );
  }
}

class _DaySelector extends StatelessWidget {
  const _DaySelector({
    required this.today,
    required this.selectedDate,
    required this.summaryForDate,
    required this.onDateSelected,
  });

  final DateTime today;
  final DateTime selectedDate;
  final DailySummary Function(DateTime date) summaryForDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final dates = List.generate(
      7,
      (index) => today.subtract(Duration(days: 3 - index)),
    );

    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final date = dates[index];
          final summary = summaryForDate(date);
          final progress = summary.expectedCredits <= 0
              ? 0.0
              : (summary.earnedCredits / summary.expectedCredits).clamp(
                  0.0,
                  1.0,
                );
          return _DaySelectorItem(
            date: date,
            progress: progress,
            isSelected: _isSameDate(date, selectedDate),
            onTap: () => onDateSelected(date),
          );
        },
      ),
    );
  }
}

class _DaySelectorItem extends StatelessWidget {
  const _DaySelectorItem({
    required this.date,
    required this.progress,
    required this.isSelected,
    required this.onTap,
  });

  final DateTime date;
  final double progress;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        key: ValueKey('day-selector-${_dateKey(date)}'),
        duration: const Duration(milliseconds: 160),
        width: 68,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colorScheme.primary : const Color(0xFFE3E8E2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_weekdayShort(date), style: theme.textTheme.labelMedium),
            Text('${date.day}', style: theme.textTheme.titleMedium),
            SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 4,
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SleepCard extends StatelessWidget {
  const _SleepCard({required this.sleepHours});

  final double? sleepHours;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.bedtime_outlined, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Text(
              sleepHours == null
                  ? 'Sleep: Not added yet'
                  : 'Sleep: ${_formatCredit(sleepHours!)}h',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selectedFilter, required this.onSelected});

  final DailyFilter selectedFilter;
  final ValueChanged<DailyFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final filter in DailyFilter.values)
          FilterChip(
            label: Text(_filterLabel(filter)),
            selected: selectedFilter == filter,
            onSelected: (_) => onSelected(filter),
          ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.entry,
    required this.category,
    required this.isFutureDate,
  });

  final DailyActivityEntry entry;
  final ActivityCategory category;
  final bool isFutureDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = isFutureDate
        ? DailyLogStatus.planned
        : entry.log?.status ?? DailyLogStatus.planned;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                      Text(
                        '${category.name} · ${_trackingLabel(entry.activity.trackingType)}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                _StatusPill(status: status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.toll_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(_creditsLabel(entry.log, isFutureDate)),
                const Spacer(),
                _ActivityAction(entry: entry, isFutureDate: isFutureDate),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final DailyLogStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _statusColor(status);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          _statusLabel(status),
          style: theme.textTheme.labelMedium?.copyWith(color: color),
        ),
      ),
    );
  }
}

class _ActivityAction extends StatelessWidget {
  const _ActivityAction({required this.entry, required this.isFutureDate});

  final DailyActivityEntry entry;
  final bool isFutureDate;

  @override
  Widget build(BuildContext context) {
    if (isFutureDate) {
      return const Text('Planned');
    }

    final label = switch (entry.activity.trackingType) {
      TrackingType.boolean => 'Done',
      TrackingType.duration => 'Log time',
      TrackingType.quantity => 'Enter value',
      TrackingType.level => 'Choose level',
      TrackingType.milestone => 'Mark reached',
    };

    return OutlinedButton(
      onPressed: null,
      child: Text(entry.log == null ? label : 'Review'),
    );
  }
}

class _EmptyDailyState extends StatelessWidget {
  const _EmptyDailyState({required this.isFutureDate});

  final bool isFutureDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.event_available_outlined,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              isFutureDate
                  ? 'No activities planned for this day.'
                  : 'No activities logged for this day.',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              isFutureDate
                  ? 'Add something when you are ready.'
                  : 'A lighter day is okay.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

String _titleForDate(DateTime date, DateTime today) {
  if (_isSameDate(date, today)) {
    return 'Today';
  }
  return '${_weekdayLong(date)}, ${date.day} ${_monthShort(date)}';
}

String _filterLabel(DailyFilter filter) {
  return switch (filter) {
    DailyFilter.all => 'All',
    DailyFilter.toDo => 'To do',
    DailyFilter.completed => 'Completed',
    DailyFilter.missed => 'Missed',
  };
}

String _statusLabel(DailyLogStatus status) {
  return switch (status) {
    DailyLogStatus.planned => 'Planned',
    DailyLogStatus.completed => 'Completed',
    DailyLogStatus.partiallyCompleted => 'Partial',
    DailyLogStatus.missed => 'Missed',
    DailyLogStatus.skipped => 'Skipped',
    DailyLogStatus.notApplicable => 'Not needed',
  };
}

Color _statusColor(DailyLogStatus status) {
  return switch (status) {
    DailyLogStatus.completed => const Color(0xFF2E7D5B),
    DailyLogStatus.partiallyCompleted => const Color(0xFF9A6A00),
    DailyLogStatus.missed || DailyLogStatus.skipped => const Color(0xFFB05A58),
    DailyLogStatus.planned ||
    DailyLogStatus.notApplicable => const Color(0xFF5D6F82),
  };
}

String _trackingLabel(TrackingType trackingType) {
  return switch (trackingType) {
    TrackingType.boolean => 'Yes / No',
    TrackingType.duration => 'Duration',
    TrackingType.quantity => 'Quantity',
    TrackingType.level => 'Level',
    TrackingType.milestone => 'Milestone',
  };
}

String _creditsLabel(DailyActivityLog? log, bool isFutureDate) {
  if (isFutureDate) {
    return '0 credits planned';
  }
  if (log == null) {
    return 'Not logged yet';
  }
  return '${_formatCredit(log.creditsEarned)} credits';
}

String _formatCredit(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(1);
}

String _weekdayShort(DateTime date) {
  return const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday -
      1];
}

String _weekdayLong(DateTime date) {
  return const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ][date.weekday - 1];
}

String _monthShort(DateTime date) {
  return const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][date.month - 1];
}

bool _isAfterDate(DateTime a, DateTime b) {
  return DateTime(
    a.year,
    a.month,
    a.day,
  ).isAfter(DateTime(b.year, b.month, b.day));
}

bool _isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _dateKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
