import 'package:flutter/material.dart';

import '../../data/mock_daymark_data.dart';
import '../../data/presaved_activity_templates.dart';
import '../../models/models.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/primary_action_button.dart';
import '../daily/activity_form_result.dart';
import '../daily/daily_formatters.dart';
import '../daily/widgets/activity_form_sheet.dart';
import 'widgets/activity_card.dart';
import 'widgets/activity_filter_chips.dart';
import 'widgets/activity_search_bar.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key, this.data});

  final MockDaymarkData? data;

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  static const _groups = [
    'All',
    'Good Habits',
    'Bad Habits',
    'Health',
    'Work',
    'Study',
    'Projects',
    'To-do',
    'Personal',
    'Inactive',
  ];

  late final MockDaymarkData _data;
  final _searchController = TextEditingController();
  String _selectedGroup = 'All';
  String _query = '';

  @override
  void initState() {
    super.initState();
    _data = widget.data ?? MockDaymarkData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activities = _filteredActivities();
    final templates = _filteredPresavedTemplates();
    final isEmpty = activities.isEmpty && templates.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activities'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: PrimaryActionButton(
              key: const ValueKey('activities-new-activity'),
              icon: Icons.add,
              label: 'New Activity',
              onPressed: () => _showActivityForm(),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          ActivityFilterChips(
            filters: _groups,
            selectedFilter: _selectedGroup,
            onSelected: (group) {
              setState(() => _selectedGroup = group);
            },
          ),
          const SizedBox(height: 12),
          ActivitySearchBar(
            controller: _searchController,
            onChanged: (value) {
              setState(() => _query = value.trim());
            },
          ),
          const SizedBox(height: 16),
          if (isEmpty)
            EmptyState(
              icon: Icons.list_alt_outlined,
              title: _query.isEmpty
                  ? 'No activities here yet.'
                  : 'No matching activities.',
              message: _query.isEmpty
                  ? 'Add something when you are ready.'
                  : 'Try another group or search term.',
              action: PrimaryActionButton(
                icon: Icons.add,
                label: 'New Activity',
                onPressed: () => _showActivityForm(),
              ),
            )
          else ...[
            for (final activity in activities) ...[
              ActivityCard(
                activity: activity,
                category: _data.categoryForActivity(activity),
                schedule: _data.scheduleForActivity(activity.id),
                creditRule: _data.creditRuleForActivity(activity.id),
                onTap: () => _showActivityDetails(activity),
              ),
              const SizedBox(height: 12),
            ],
            for (final template in templates) ...[
              PresavedTemplateCard(
                template: template,
                category: _data.categoryForPresavedTemplate(template),
                onTap: () => _showTemplatePreview(template),
                onUseTemplate: () => _showTemplateForm(template),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }

  List<ActivityTemplate> _filteredActivities() {
    return _activitiesForGroup(_selectedGroup).where(_matchesSearch).toList()
      ..sort((a, b) => a.title.compareTo(b.title));
  }

  List<PresavedActivityTemplate> _filteredPresavedTemplates() {
    return _templatesForGroup(
        _selectedGroup,
      ).where(_matchesTemplateSearch).toList()
      ..sort((a, b) => a.title.compareTo(b.title));
  }

  Iterable<ActivityTemplate> _activitiesForGroup(String group) {
    if (group == 'Inactive') {
      return _data.activities.where((activity) => !activity.isActive);
    }

    if (group == 'All') {
      return _data.activities;
    }

    return _data.activities.where((activity) {
      final category = _data.categoryForActivity(activity).name;
      return _normalizedGroup(category) == _normalizedGroup(group);
    });
  }

  Iterable<PresavedActivityTemplate> _templatesForGroup(String group) {
    if (group == 'All' || group == 'Inactive') {
      return _data.presavedTemplates;
    }

    return _data.presavedTemplates.where((template) {
      final category = _data.categoryForPresavedTemplate(template).name;
      return _normalizedGroup(category) == _normalizedGroup(group);
    });
  }

  bool _matchesSearch(ActivityTemplate activity) {
    if (_query.isEmpty) {
      return true;
    }
    final category = _data.categoryForActivity(activity).name.toLowerCase();
    final query = _query.toLowerCase();
    return activity.title.toLowerCase().contains(query) ||
        category.contains(query);
  }

  bool _matchesTemplateSearch(PresavedActivityTemplate template) {
    if (_query.isEmpty) {
      return true;
    }
    final category = _data
        .categoryForPresavedTemplate(template)
        .name
        .toLowerCase();
    final query = _query.toLowerCase();
    return template.title.toLowerCase().contains(query) ||
        category.contains(query) ||
        template.tags.any((tag) => tag.toLowerCase().contains(query));
  }

  void _showActivityDetails(ActivityTemplate activity) {
    final schedule = _data.scheduleForActivity(activity.id);
    final creditRule = _data.creditRuleForActivity(activity.id);
    final category = _data.categoryForActivity(activity);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            children: [
              Text(
                activity.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (activity.description != null) ...[
                const SizedBox(height: 6),
                Text(activity.description!),
              ],
              const SizedBox(height: 16),
              _DetailRow(label: 'Category', value: category.name),
              _DetailRow(
                label: 'Schedule',
                value: scheduleLabel(schedule, activity.activityScope),
              ),
              _DetailRow(
                label: 'Tracking',
                value: trackingLabel(activity.trackingType),
              ),
              _DetailRow(
                label: 'Scoring',
                value: creditSummary(activity, creditRule),
              ),
              _DetailRow(
                label: 'Status',
                value: activity.isActive ? 'Active' : 'Inactive',
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showLogActivitySheet(activity);
                },
                icon: const Icon(Icons.add_task_outlined),
                label: const Text('Log Activity'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showActivityForm(activity: activity);
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Activity'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _toggleActive(activity);
                },
                icon: Icon(
                  activity.isActive
                      ? Icons.pause_circle_outline
                      : Icons.play_circle_outline,
                ),
                label: Text(
                  activity.isActive ? 'Pause Activity' : 'Activate Activity',
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showRecentLogs(activity);
                },
                icon: const Icon(Icons.history),
                label: const Text('View Recent Logs'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTemplatePreview(PresavedActivityTemplate template) {
    final category = _data.categoryForPresavedTemplate(template);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(iconForTemplate(template.iconName), size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      template.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(template.description),
              const SizedBox(height: 16),
              _DetailRow(label: 'Category', value: category.name),
              _DetailRow(
                label: 'Schedule',
                value: templateScheduleLabel(template),
              ),
              _DetailRow(
                label: 'Tracking',
                value: trackingLabel(template.trackingType),
              ),
              _DetailRow(
                label: 'Scoring',
                value: templateCreditSummary(template),
              ),
              const _DetailRow(label: 'Status', value: 'Inactive'),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showTemplateForm(template);
                },
                icon: const Icon(Icons.add),
                label: const Text('Use Template'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showActivityForm({ActivityTemplate? activity}) {
    final schedule = activity == null
        ? null
        : _data.scheduleForActivity(activity.id);
    final creditRule = activity == null
        ? null
        : _data.creditRuleForActivity(activity.id);
    final options = activity == null
        ? const <ActivityOptionInput>[]
        : [
            for (final option in _data.optionsForActivity(activity.id))
              ActivityOptionInput(
                label: option.label,
                value: option.value,
                creditValue: option.creditValue,
              ),
          ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return ActivityFormSheet(
          title: activity == null ? 'New activity' : 'Edit activity',
          submitLabel: activity == null ? 'Save Activity' : 'Save Changes',
          categories: _data.categories,
          isRecurring: true,
          initialTitle: activity?.title,
          initialDescription: activity?.description,
          initialCategoryId: activity?.categoryId,
          initialActivityType: activity?.activityType,
          initialTrackingType: activity?.trackingType,
          initialFrequency: schedule?.frequency,
          initialDaysOfWeek: schedule?.daysOfWeek,
          initialExpectedDurationMinutes: schedule?.expectedDurationMinutes,
          initialBaseCredit: creditRule?.baseCredit,
          initialCreditPerMinute: creditRule?.creditPerMinute,
          initialCreditPerUnit: creditRule?.creditPerUnit,
          initialMaxDailyCredit: creditRule?.maxDailyCredit,
          initialPenaltyCredit: creditRule?.penaltyCredit,
          initialCategoricalOptions: options,
          onSave: (result) {
            if (activity == null) {
              _saveNewActivity(result);
            } else {
              _saveActivityEdits(activity, result);
            }
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _showTemplateForm(PresavedActivityTemplate template) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return ActivityFormSheet(
          title: 'Use template',
          submitLabel: 'Save Activity',
          categories: _data.categories,
          isRecurring: true,
          initialTitle: template.title,
          initialDescription: template.description,
          initialCategoryId: template.categoryId,
          initialActivityType: template.activityType,
          initialTrackingType: template.trackingType,
          initialFrequency: template.frequency,
          initialDaysOfWeek: template.daysOfWeek,
          initialExpectedDurationMinutes: template.expectedDurationMinutes,
          initialBaseCredit: template.baseCredit,
          initialCreditPerMinute: template.creditPerMinute,
          initialCreditPerUnit: template.creditPerUnit,
          initialMaxDailyCredit: template.maxDailyCredit,
          initialPenaltyCredit: template.penaltyCredit,
          onSave: (result) {
            _saveTemplateActivity(result);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _saveNewActivity(ActivityFormResult result) {
    setState(() {
      _data.createRecurringActivity(
        title: result.title,
        startDate: _data.today,
        description: result.description,
        categoryId: _categoryIdForResult(result),
        activityType: result.activityType,
        trackingType: result.trackingType,
        frequency: result.frequency,
        daysOfWeek: result.daysOfWeek,
        expectedDurationMinutes: result.expectedDurationMinutes,
        baseCredit: result.baseCredit,
        creditPerMinute: result.creditPerMinute,
        creditPerUnit: result.creditPerUnit,
        maxDailyCredit: result.maxDailyCredit,
        penaltyCredit: result.penaltyCredit,
        categoricalOptions: result.categoricalOptions,
      );
    });
    _showMessage('${result.title} added.');
  }

  void _saveTemplateActivity(ActivityFormResult result) {
    setState(() {
      _data.createRecurringActivity(
        title: result.title,
        startDate: _data.today,
        description: result.description,
        categoryId: _categoryIdForResult(result),
        activityType: result.activityType,
        trackingType: result.trackingType,
        frequency: result.frequency,
        daysOfWeek: result.daysOfWeek,
        expectedDurationMinutes: result.expectedDurationMinutes,
        baseCredit: result.baseCredit,
        creditPerMinute: result.creditPerMinute,
        creditPerUnit: result.creditPerUnit,
        maxDailyCredit: result.maxDailyCredit,
        penaltyCredit: result.penaltyCredit,
        categoricalOptions: result.categoricalOptions,
      );
    });
    _showMessage('${result.title} added.');
  }

  void _saveActivityEdits(
    ActivityTemplate activity,
    ActivityFormResult result,
  ) {
    setState(() {
      _data.updateReusableActivity(
        activityId: activity.id,
        title: result.title,
        description: result.description,
        categoryId: _categoryIdForResult(result),
        activityType: result.activityType,
        trackingType: result.trackingType,
        frequency: result.frequency,
        daysOfWeek: result.daysOfWeek,
        expectedDurationMinutes: result.expectedDurationMinutes,
        baseCredit: result.baseCredit,
        creditPerMinute: result.creditPerMinute,
        creditPerUnit: result.creditPerUnit,
        maxDailyCredit: result.maxDailyCredit,
        penaltyCredit: result.penaltyCredit,
        categoricalOptions: result.categoricalOptions,
      );
    });
    _showMessage('${result.title} updated.');
  }

  String _categoryIdForResult(ActivityFormResult result) {
    return _data.resolveCategoryId(
      categoryId: result.categoryId,
      customCategoryName: result.customCategoryName,
    );
  }

  void _toggleActive(ActivityTemplate activity) {
    setState(() {
      _data.setActivityActive(
        activityId: activity.id,
        isActive: !activity.isActive,
      );
    });
    _showMessage(
      activity.isActive
          ? '${activity.title} paused.'
          : '${activity.title} active again.',
    );
  }

  void _showLogActivitySheet(ActivityTemplate activity) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return _ActivityLogSheet(
          activity: activity,
          today: _data.today,
          expectedDurationMinutes: _data.expectedDurationForActivity(
            activity.id,
          ),
          options: _data.optionsForActivity(activity.id),
          onSave: (submission) {
            Navigator.of(context).pop();
            setState(() {
              _data.saveActivityLog(
                activityId: activity.id,
                date: submission.date,
                status: submission.status,
                value: submission.value,
                durationMinutes: submission.durationMinutes,
              );
            });
            _showMessage(
              isAfterDate(submission.date, _data.today)
                  ? '${activity.title} planned.'
                  : '${activity.title} logged.',
            );
          },
        );
      },
    );
  }

  void _showRecentLogs(ActivityTemplate activity) {
    final logs = _data.recentLogsForActivity(activity.id);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            children: [
              Text(
                'Recent logs',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (logs.isEmpty)
                const Text('No logs yet. Add something when you are ready.')
              else
                for (final log in logs)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event_available_outlined),
                    title: Text(
                      '${weekdayLong(log.date)}, ${dateKey(log.date)}',
                    ),
                    subtitle: Text(statusLabel(log.status)),
                    trailing: Text(
                      '${formatCredit(log.creditsEarned)} credits',
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(label, style: theme.textTheme.labelLarge),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _ActivityLogSheet extends StatefulWidget {
  const _ActivityLogSheet({
    required this.activity,
    required this.today,
    required this.expectedDurationMinutes,
    required this.options,
    required this.onSave,
  });

  final ActivityTemplate activity;
  final DateTime today;
  final int? expectedDurationMinutes;
  final List<ActivityOption> options;
  final ValueChanged<_ActivityLogSubmission> onSave;

  @override
  State<_ActivityLogSheet> createState() => _ActivityLogSheetState();
}

class _ActivityLogSheetState extends State<_ActivityLogSheet> {
  final _durationController = TextEditingController(text: '30');
  final _quantityController = TextEditingController(text: '1');
  DateTime _selectedDate = DateTime.now();
  double _levelValue = 1;
  double? _categoricalValue;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.today;
    _categoricalValue = widget.options.firstOrNull?.value;
  }

  @override
  void dispose() {
    _durationController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFuture = isAfterDate(_selectedDate, widget.today);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 8,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Log ${widget.activity.title}',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(
                isSameDate(_selectedDate, widget.today)
                    ? 'Today'
                    : dateKey(_selectedDate),
              ),
              subtitle: Text(isFuture ? 'Plan Activity' : 'Save Log'),
              trailing: TextButton(
                onPressed: _pickDate,
                child: const Text('Change Date'),
              ),
            ),
            if (isFuture)
              const Text(
                'Future activities can be planned, but they should not earn credits yet.',
              )
            else
              _ActivityValueFields(
                activity: widget.activity,
                options: widget.options,
                durationController: _durationController,
                quantityController: _quantityController,
                levelValue: _levelValue,
                categoricalValue: _categoricalValue,
                onLevelChanged: (value) => setState(() => _levelValue = value),
                onCategoricalChanged: (value) {
                  setState(() => _categoricalValue = value);
                },
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    child: Text(isFuture ? 'Plan Activity' : 'Save Log'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: widget.today.subtract(const Duration(days: 365)),
      lastDate: widget.today.add(const Duration(days: 365)),
    );
    if (picked == null) {
      return;
    }
    setState(() => _selectedDate = picked);
  }

  void _save() {
    if (isAfterDate(_selectedDate, widget.today)) {
      widget.onSave(
        _ActivityLogSubmission(
          date: _selectedDate,
          status: DailyLogStatus.planned,
        ),
      );
      return;
    }

    final durationMinutes = int.tryParse(_durationController.text.trim()) ?? 0;
    final quantity = double.tryParse(_quantityController.text.trim()) ?? 0;
    final status = _statusForCurrentValue(durationMinutes);

    widget.onSave(
      _ActivityLogSubmission(
        date: _selectedDate,
        status: status,
        durationMinutes: widget.activity.trackingType == TrackingType.duration
            ? durationMinutes
            : null,
        value: switch (widget.activity.trackingType) {
          TrackingType.quantity => quantity,
          TrackingType.level => _levelValue,
          TrackingType.categorical => _categoricalValue,
          _ => null,
        },
      ),
    );
  }

  DailyLogStatus _statusForCurrentValue(int durationMinutes) {
    return switch (widget.activity.trackingType) {
      TrackingType.duration =>
        widget.expectedDurationMinutes != null &&
                durationMinutes < widget.expectedDurationMinutes!
            ? DailyLogStatus.partiallyCompleted
            : DailyLogStatus.completed,
      TrackingType.level =>
        _levelValue.round() == 1
            ? DailyLogStatus.completed
            : _levelValue.round() == 2
            ? DailyLogStatus.partiallyCompleted
            : DailyLogStatus.missed,
      TrackingType.categorical =>
        _selectedCategoricalCreditIsNegative()
            ? DailyLogStatus.missed
            : DailyLogStatus.completed,
      _ => DailyLogStatus.completed,
    };
  }

  bool _selectedCategoricalCreditIsNegative() {
    final selectedOption = widget.options
        .where((option) => option.value == _categoricalValue)
        .firstOrNull;
    return selectedOption != null && selectedOption.creditValue.isNegative;
  }
}

class _ActivityValueFields extends StatelessWidget {
  const _ActivityValueFields({
    required this.activity,
    required this.options,
    required this.durationController,
    required this.quantityController,
    required this.levelValue,
    required this.categoricalValue,
    required this.onLevelChanged,
    required this.onCategoricalChanged,
  });

  final ActivityTemplate activity;
  final List<ActivityOption> options;
  final TextEditingController durationController;
  final TextEditingController quantityController;
  final double levelValue;
  final double? categoricalValue;
  final ValueChanged<double> onLevelChanged;
  final ValueChanged<double?> onCategoricalChanged;

  @override
  Widget build(BuildContext context) {
    return switch (activity.trackingType) {
      TrackingType.duration => TextField(
        controller: durationController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Duration minutes',
          border: OutlineInputBorder(),
        ),
      ),
      TrackingType.quantity => TextField(
        controller: quantityController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Amount',
          border: OutlineInputBorder(),
        ),
      ),
      TrackingType.level => SegmentedButton<double>(
        segments: const [
          ButtonSegment(value: 1, label: Text('Good control')),
          ButtonSegment(value: 2, label: Text('Some')),
          ButtonSegment(value: 3, label: Text('High')),
        ],
        selected: {levelValue},
        onSelectionChanged: (selection) => onLevelChanged(selection.single),
      ),
      TrackingType.categorical when options.isNotEmpty =>
        DropdownButtonFormField<double>(
          initialValue: categoricalValue,
          decoration: const InputDecoration(
            labelText: 'Option',
            border: OutlineInputBorder(),
          ),
          items: [
            for (final option in options)
              DropdownMenuItem(value: option.value, child: Text(option.label)),
          ],
          onChanged: onCategoricalChanged,
        ),
      TrackingType.categorical => const Text(
        'Add options before logging this activity.',
      ),
      TrackingType.boolean || TrackingType.milestone => const Text(
        'This will be marked as completed for the selected date.',
      ),
    };
  }
}

class _ActivityLogSubmission {
  const _ActivityLogSubmission({
    required this.date,
    required this.status,
    this.value,
    this.durationMinutes,
  });

  final DateTime date;
  final DailyLogStatus status;
  final double? value;
  final int? durationMinutes;
}

String _normalizedGroup(String value) {
  return value
      .toLowerCase()
      .replaceAll('-', '')
      .replaceAll(' ', '')
      .replaceAll('habits', 'habit')
      .replaceAll('projects', 'project');
}
