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
            onPressed: _openCalendar,
            tooltip: 'Open calendar',
            icon: const Icon(Icons.calendar_month_outlined),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              key: const ValueKey('daily-primary-action'),
              onPressed: _showPrimaryActionSheet,
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
          _SleepCard(sleepHours: checkIn?.sleepHours, onTap: _showSleepSheet),
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
            _EmptyDailyState(
              isFutureDate: isFutureDate,
              onAction: _showPrimaryActionSheet,
            )
          else
            for (final entry in entries) ...[
              _ActivityCard(
                entry: entry,
                category: _categoryForActivity(entry.activity),
                isFutureDate: isFutureDate,
                onLog: (request) => _saveLog(entry.activity, request),
                onReview: () => _showActivityDetails(entry),
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
    return _data.categoryForActivity(activity);
  }

  void _saveLog(ActivityTemplate activity, _LogRequest request) {
    setState(() {
      _data.saveActivityLog(
        activityId: activity.id,
        date: _selectedDate,
        status: request.status,
        value: request.value,
        durationMinutes: request.durationMinutes,
      );
    });
    _showMessage('${activity.title} updated.');
  }

  Future<void> _openCalendar() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: _data.today.subtract(const Duration(days: 365)),
      lastDate: _data.today.add(const Duration(days: 365)),
    );
    if (pickedDate == null) {
      return;
    }
    setState(() {
      _selectedDate = pickedDate;
    });
  }

  void _showPrimaryActionSheet() {
    final isFutureDate = _isAfterDate(_selectedDate, _data.today);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return _ActionSheet(
          title: isFutureDate ? 'Add to this day' : 'Log activity',
          actions: [
            _SheetAction(
              icon: Icons.playlist_add,
              label: isFutureDate
                  ? 'Add existing activity'
                  : 'Log existing activity',
              onTap: () {
                Navigator.of(context).pop();
                _showExistingActivitySheet();
              },
            ),
            _SheetAction(
              icon: Icons.add_circle_outline,
              label: 'Create one-time activity',
              onTap: () {
                Navigator.of(context).pop();
                _showOneTimeActivitySheet();
              },
            ),
          ],
        );
      },
    );
  }

  void _showExistingActivitySheet() {
    final isFutureDate = _isAfterDate(_selectedDate, _data.today);
    final activities = _data.getLoggableActivitiesForDate(_selectedDate);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        if (activities.isEmpty) {
          return _InfoSheet(
            title: 'Nothing to add right now',
            message: 'Activities for this day are already shown.',
          );
        }

        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            children: [
              Text(
                isFutureDate ? 'Plan an activity' : 'Choose an activity',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              for (final activity in activities)
                ListTile(
                  leading: Icon(_iconForTrackingType(activity.trackingType)),
                  title: Text(activity.title),
                  subtitle: Text(_data.categoryForActivity(activity).name),
                  onTap: () {
                    Navigator.of(context).pop();
                    if (isFutureDate) {
                      setState(() {
                        _data.planActivity(
                          activityId: activity.id,
                          date: _selectedDate,
                        );
                      });
                      _showMessage('${activity.title} planned.');
                    } else {
                      _logActivityFromTemplate(activity);
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _logActivityFromTemplate(ActivityTemplate activity) {
    switch (activity.trackingType) {
      case TrackingType.boolean:
      case TrackingType.milestone:
        _saveLog(activity, const _LogRequest(status: DailyLogStatus.completed));
      case TrackingType.quantity:
        _showQuantitySheet(activity);
      case TrackingType.duration:
        _showDurationSheetForActivity(activity);
      case TrackingType.level:
        _showLevelSheetForActivity(activity);
    }
  }

  void _showOneTimeActivitySheet() {
    final controller = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
            top: 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'One-time activity',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              TextField(
                key: const ValueKey('one-time-title-field'),
                controller: controller,
                autofocus: true,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Activity title',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _saveOneTimeActivity(controller),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const ValueKey('save-one-time-activity'),
                  onPressed: () => _saveOneTimeActivity(controller),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveOneTimeActivity(TextEditingController controller) {
    final title = controller.text.trim();
    if (title.isEmpty) {
      _showMessage('Add a title first.');
      return;
    }
    setState(() {
      _data.createOneTimeActivity(title: title, date: _selectedDate);
    });
    Navigator.of(context).pop();
    _showMessage('$title added.');
  }

  void _showSleepSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return _LogChoiceSheet(
          title: 'Sleep for this day',
          choices: const [
            _LogChoice(label: '6 hours', sleepHours: 6),
            _LogChoice(label: '7.5 hours', sleepHours: 7.5),
            _LogChoice(label: '8 hours', sleepHours: 8),
            _LogChoice(label: 'Clear sleep', sleepHours: null),
          ],
          onSelected: (choice) {
            Navigator.of(context).pop();
            setState(() {
              _data.saveDailyCheckIn(
                date: _selectedDate,
                sleepHours: choice.sleepHours,
              );
            });
          },
        );
      },
    );
  }

  void _showActivityDetails(DailyActivityEntry entry) {
    final isFutureDate = _isAfterDate(_selectedDate, _data.today);
    final log = entry.log;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return _ActionSheet(
          title: entry.activity.title,
          subtitle: _activityDetailSubtitle(entry, isFutureDate),
          actions: [
            if (isFutureDate) ...[
              if (log == null)
                _SheetAction(
                  icon: Icons.add_task,
                  label: 'Plan activity',
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _data.planActivity(
                        activityId: entry.activity.id,
                        date: _selectedDate,
                      );
                    });
                    _showMessage('${entry.activity.title} planned.');
                  },
                )
              else
                _SheetAction(
                  icon: Icons.remove_circle_outline,
                  label: 'Remove from this day',
                  onTap: () {
                    Navigator.of(context).pop();
                    _removeLog(entry.activity);
                  },
                ),
            ] else ...[
              _SheetAction(
                icon: Icons.edit_outlined,
                label: log == null ? 'Log activity' : 'Edit log',
                onTap: () {
                  Navigator.of(context).pop();
                  _logActivityFromTemplate(entry.activity);
                },
              ),
              _SheetAction(
                icon: Icons.event_busy_outlined,
                label: 'Mark skipped',
                onTap: () {
                  Navigator.of(context).pop();
                  _saveLog(
                    entry.activity,
                    const _LogRequest(status: DailyLogStatus.skipped),
                  );
                },
              ),
              _SheetAction(
                icon: Icons.undo_outlined,
                label: 'Clear log',
                onTap: () {
                  Navigator.of(context).pop();
                  _removeLog(entry.activity);
                },
              ),
            ],
          ],
        );
      },
    );
  }

  void _removeLog(ActivityTemplate activity) {
    setState(() {
      _data.removeActivityLog(activityId: activity.id, date: _selectedDate);
    });
    _showMessage('${activity.title} removed from this day.');
  }

  void _showDurationSheetForActivity(ActivityTemplate activity) {
    _showLogChoiceSheet(
      title: 'How long did you spend?',
      choices: const [
        _LogChoice(
          label: '30 min',
          request: _LogRequest(
            status: DailyLogStatus.partiallyCompleted,
            durationMinutes: 30,
          ),
        ),
        _LogChoice(
          label: '1 hour',
          request: _LogRequest(
            status: DailyLogStatus.completed,
            durationMinutes: 60,
          ),
        ),
        _LogChoice(
          label: '2 hours',
          request: _LogRequest(
            status: DailyLogStatus.completed,
            durationMinutes: 120,
          ),
        ),
      ],
      onSelected: (choice) => _saveLog(activity, choice.request!),
    );
  }

  void _showQuantitySheet(ActivityTemplate activity) {
    _showLogChoiceSheet(
      title: 'How many did you complete?',
      choices: const [
        _LogChoice(
          label: '1',
          request: _LogRequest(status: DailyLogStatus.completed, value: 1),
        ),
        _LogChoice(
          label: '3',
          request: _LogRequest(status: DailyLogStatus.completed, value: 3),
        ),
        _LogChoice(
          label: '5',
          request: _LogRequest(status: DailyLogStatus.completed, value: 5),
        ),
      ],
      onSelected: (choice) => _saveLog(activity, choice.request!),
    );
  }

  void _showLevelSheetForActivity(ActivityTemplate activity) {
    _showLogChoiceSheet(
      title: 'How was your control today?',
      choices: const [
        _LogChoice(
          label: 'Good control',
          request: _LogRequest(status: DailyLogStatus.completed, value: 1),
        ),
        _LogChoice(
          label: 'Some scrolling',
          request: _LogRequest(
            status: DailyLogStatus.partiallyCompleted,
            value: 2,
          ),
        ),
        _LogChoice(
          label: 'Bad day',
          request: _LogRequest(status: DailyLogStatus.missed, value: 3),
        ),
      ],
      onSelected: (choice) => _saveLog(activity, choice.request!),
    );
  }

  void _showLogChoiceSheet({
    required String title,
    required List<_LogChoice> choices,
    required ValueChanged<_LogChoice> onSelected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return _LogChoiceSheet(
          title: title,
          choices: choices,
          onSelected: (choice) {
            Navigator.of(context).pop();
            onSelected(choice);
          },
        );
      },
    );
  }

  String _activityDetailSubtitle(DailyActivityEntry entry, bool isFutureDate) {
    final category = _data.categoryForActivity(entry.activity).name;
    final status = isFutureDate
        ? DailyLogStatus.planned
        : entry.log?.status ?? DailyLogStatus.planned;
    return '$category · ${_statusLabel(status)} · ${_creditsLabel(entry.log, isFutureDate)}';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _LogRequest {
  const _LogRequest({required this.status, this.value, this.durationMinutes});

  final DailyLogStatus status;
  final double? value;
  final int? durationMinutes;
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
  const _SleepCard({required this.sleepHours, required this.onTap});

  final double? sleepHours;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.bedtime_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  sleepHours == null
                      ? 'Sleep: Not added yet'
                      : 'Sleep: ${_formatCredit(sleepHours!)}h',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionSheet extends StatelessWidget {
  const _ActionSheet({
    required this.title,
    required this.actions,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<_SheetAction> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: theme.textTheme.bodyMedium),
          ],
          const SizedBox(height: 12),
          for (final action in actions)
            ListTile(
              leading: Icon(action.icon),
              title: Text(action.label),
              onTap: action.onTap,
            ),
        ],
      ),
    );
  }
}

class _SheetAction {
  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _InfoSheet extends StatelessWidget {
  const _InfoSheet({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
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
    required this.onLog,
    required this.onReview,
  });

  final DailyActivityEntry entry;
  final ActivityCategory category;
  final bool isFutureDate;
  final ValueChanged<_LogRequest> onLog;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = isFutureDate
        ? DailyLogStatus.planned
        : entry.log?.status ?? DailyLogStatus.planned;

    return Card(
      key: ValueKey('activity-card-${entry.activity.id}'),
      child: InkWell(
        onTap: onReview,
        borderRadius: BorderRadius.circular(16),
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
                  _ActivityAction(
                    entry: entry,
                    isFutureDate: isFutureDate,
                    onLog: onLog,
                    onReview: onReview,
                  ),
                ],
              ),
            ],
          ),
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
  const _ActivityAction({
    required this.entry,
    required this.isFutureDate,
    required this.onLog,
    required this.onReview,
  });

  final DailyActivityEntry entry;
  final bool isFutureDate;
  final ValueChanged<_LogRequest> onLog;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    if (isFutureDate) {
      return TextButton(onPressed: onReview, child: const Text('Manage'));
    }
    if (entry.log != null && entry.log!.status != DailyLogStatus.planned) {
      return OutlinedButton(onPressed: onReview, child: const Text('Review'));
    }

    final label = switch (entry.activity.trackingType) {
      TrackingType.boolean => 'Done',
      TrackingType.duration => 'Log time',
      TrackingType.quantity => 'Enter value',
      TrackingType.level => 'Choose level',
      TrackingType.milestone => 'Mark reached',
    };

    return OutlinedButton(
      key: ValueKey('log-action-${entry.activity.id}'),
      onPressed: () => _handleLogAction(context),
      child: Text(label),
    );
  }

  void _handleLogAction(BuildContext context) {
    switch (entry.activity.trackingType) {
      case TrackingType.boolean:
      case TrackingType.milestone:
        onLog(const _LogRequest(status: DailyLogStatus.completed));
      case TrackingType.duration:
        _showDurationSheet(context);
      case TrackingType.quantity:
        onLog(const _LogRequest(status: DailyLogStatus.completed, value: 1));
      case TrackingType.level:
        _showLevelSheet(context);
    }
  }

  void _showDurationSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return _LogChoiceSheet(
          title: 'How long did you spend?',
          choices: [
            _LogChoice(
              label: '30 min',
              request: const _LogRequest(
                status: DailyLogStatus.partiallyCompleted,
                durationMinutes: 30,
              ),
            ),
            _LogChoice(
              label: '1 hour',
              request: const _LogRequest(
                status: DailyLogStatus.completed,
                durationMinutes: 60,
              ),
            ),
            _LogChoice(
              label: '2 hours',
              request: const _LogRequest(
                status: DailyLogStatus.completed,
                durationMinutes: 120,
              ),
            ),
          ],
          onSelected: (choice) {
            Navigator.of(context).pop();
            onLog(choice.request!);
          },
        );
      },
    );
  }

  void _showLevelSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return _LogChoiceSheet(
          title: 'How was your control today?',
          choices: [
            _LogChoice(
              label: 'Good control',
              request: const _LogRequest(
                status: DailyLogStatus.completed,
                value: 1,
              ),
            ),
            _LogChoice(
              label: 'Some scrolling',
              request: const _LogRequest(
                status: DailyLogStatus.partiallyCompleted,
                value: 2,
              ),
            ),
            _LogChoice(
              label: 'Bad day',
              request: const _LogRequest(
                status: DailyLogStatus.missed,
                value: 3,
              ),
            ),
          ],
          onSelected: (choice) {
            Navigator.of(context).pop();
            onLog(choice.request!);
          },
        );
      },
    );
  }
}

class _LogChoiceSheet extends StatelessWidget {
  const _LogChoiceSheet({
    required this.title,
    required this.choices,
    required this.onSelected,
  });

  final String title;
  final List<_LogChoice> choices;
  final ValueChanged<_LogChoice> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          for (final choice in choices) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: () => onSelected(choice),
                child: Text(choice.label),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _LogChoice {
  const _LogChoice({required this.label, this.request, this.sleepHours});

  final String label;
  final _LogRequest? request;
  final double? sleepHours;
}

class _EmptyDailyState extends StatelessWidget {
  const _EmptyDailyState({required this.isFutureDate, required this.onAction});

  final bool isFutureDate;
  final VoidCallback onAction;

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
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: Text(isFutureDate ? '+ Add Activity' : '+ Log Activity'),
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

IconData _iconForTrackingType(TrackingType trackingType) {
  return switch (trackingType) {
    TrackingType.boolean => Icons.check_circle_outline,
    TrackingType.duration => Icons.timer_outlined,
    TrackingType.quantity => Icons.pin_outlined,
    TrackingType.level => Icons.tune,
    TrackingType.milestone => Icons.flag_outlined,
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
