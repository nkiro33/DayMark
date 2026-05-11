import 'package:flutter/material.dart';

import '../../app/daymark_settings.dart';
import '../../data/mock_daymark_data.dart';
import '../../models/models.dart';
import 'activity_form_result.dart';
import 'daily_filter.dart';
import 'daily_formatters.dart';
import 'daily_log_request.dart';
import 'widgets/add_or_log_activity_sheet.dart';
import 'widgets/activity_form_sheet.dart';
import 'widgets/daily_activity_card.dart';
import 'widgets/daily_empty_state.dart';
import 'widgets/daily_filter_chips.dart';
import 'widgets/daily_header.dart';
import 'widgets/daily_log_details_sheet.dart';
import 'widgets/daily_summary_card.dart';
import 'widgets/duration_minutes_sheet.dart';
import 'widgets/horizontal_day_selector.dart';
import 'widgets/numeric_log_sheet.dart';
import 'widgets/sleep_input_card.dart';

class DailyScreen extends StatefulWidget {
  const DailyScreen({super.key, this.data, this.settings});

  final MockDaymarkData? data;
  final DaymarkSettings? settings;

  @override
  State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  late final MockDaymarkData _data;
  late final DaymarkSettings _settings;
  late DateTime _selectedDate;
  DailyFilter _selectedFilter = DailyFilter.all;

  @override
  void initState() {
    super.initState();
    _data = widget.data ?? MockDaymarkData();
    _settings = widget.settings ?? DaymarkSettings();
    _selectedDate = _data.today;
  }

  @override
  Widget build(BuildContext context) {
    final isFutureDate = isAfterDate(_selectedDate, _data.today);
    final entries = _filteredEntries(_data.getActivitiesForDate(_selectedDate));
    final summary = _data.getDailySummary(_selectedDate);
    final checkIn = _checkInForDate(_selectedDate);

    return Scaffold(
      appBar: DailyHeader(
        selectedDate: _selectedDate,
        today: _data.today,
        isFutureDate: isFutureDate,
        onOpenCalendar: _openCalendar,
        onPrimaryAction: _showPrimaryActionSheet,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          DailySummaryCard(
            summary: summary,
            showDailyScore: _settings.showDailyScore,
          ),
          const SizedBox(height: 16),
          HorizontalDaySelector(
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
          SleepInputCard(
            sleepMinutes: checkIn?.sleepMinutes,
            onTap: _showSleepSheet,
          ),
          const SizedBox(height: 16),
          DailyFilterChips(
            selectedFilter: _selectedFilter,
            onSelected: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            DailyEmptyState(
              isFutureDate: isFutureDate,
              filter: _selectedFilter,
              onAction: _showPrimaryActionSheet,
            )
          else
            for (final entry in entries) ...[
              DailyActivityCard(
                entry: entry,
                category: _data.categoryForActivity(entry.activity),
                isFutureDate: isFutureDate,
                showScore: _settings.showDailyScore,
                onLogAction: _logActivityEntry,
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
                  entry.activity.activityType != ActivityType.negative &&
                      entry.log == null ||
                  (entry.activity.activityType != ActivityType.negative &&
                      entry.log!.status == DailyLogStatus.planned),
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
        .where((checkIn) => isSameDate(checkIn.date, date))
        .firstOrNull;
  }

  DailyActivityLog _saveLog(
    ActivityTemplate activity,
    DailyLogRequest request,
  ) {
    late final DailyActivityLog savedLog;
    final existingLog = _data.getLogForActivityDate(
      activityId: activity.id,
      date: _selectedDate,
    );
    setState(() {
      savedLog = _data.saveActivityLog(
        activityId: activity.id,
        date: _selectedDate,
        status: request.status,
        value: request.value,
        durationMinutes: request.durationMinutes,
        notes: request.notes ?? existingLog?.notes,
      );
    });
    _showMessage('${activity.title} updated.');
    return savedLog;
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
    final isFutureDate = isAfterDate(_selectedDate, _data.today);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return AddOrLogActivitySheet(
          isFutureDate: isFutureDate,
          onExistingActivity: () {
            Navigator.of(context).pop();
            _showExistingActivitySheet();
          },
          onOneTimeActivity: () {
            Navigator.of(context).pop();
            _showActivityTitleSheet(
              title: 'One-time activity',
              submitLabel: 'Save',
              isRecurring: false,
              onSave: _saveOneTimeActivity,
            );
          },
          onRecurringActivity: () {
            Navigator.of(context).pop();
            _showActivityTitleSheet(
              title: 'Recurring activity',
              submitLabel: 'Save',
              isRecurring: true,
              onSave: _saveRecurringActivity,
            );
          },
        );
      },
    );
  }

  void _showExistingActivitySheet() {
    final isFutureDate = isAfterDate(_selectedDate, _data.today);
    final activities = _data.getLoggableActivitiesForDate(_selectedDate);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        if (activities.isEmpty) {
          return const InfoSheet(
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
                  leading: Icon(iconForTrackingType(activity.trackingType)),
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

  void _logActivityEntry(DailyActivityEntry entry) {
    _logActivityFromTemplate(entry.activity);
  }

  void _logActivityFromTemplate(ActivityTemplate activity) {
    switch (activity.trackingType) {
      case TrackingType.boolean:
      case TrackingType.milestone:
        _saveLog(
          activity,
          const DailyLogRequest(status: DailyLogStatus.completed),
        );
      case TrackingType.quantity:
        _showQuantitySheet(activity);
      case TrackingType.duration:
        _showDurationSheetForActivity(activity);
      case TrackingType.level:
        _showLevelSheetForActivity(activity);
      case TrackingType.categorical:
        _showCategoricalSheetForActivity(activity);
    }
  }

  void _showActivityTitleSheet({
    required String title,
    required String submitLabel,
    required bool isRecurring,
    required ValueChanged<ActivityFormResult> onSave,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return ActivityFormSheet(
          title: title,
          submitLabel: submitLabel,
          categories: _data.categories,
          isRecurring: isRecurring,
          onSave: onSave,
        );
      },
    );
  }

  void _saveOneTimeActivity(ActivityFormResult result) {
    setState(() {
      _data.createOneTimeActivity(
        title: result.title,
        date: _selectedDate,
        description: result.description,
        categoryId: _categoryIdForResult(result),
        activityType: result.activityType,
        trackingType: result.trackingType,
        baseCredit: result.baseCredit,
        creditPerMinute: result.creditPerMinute,
        creditPerUnit: result.creditPerUnit,
        maxDailyCredit: result.maxDailyCredit,
        penaltyCredit: result.penaltyCredit,
        categoricalOptions: result.categoricalOptions,
      );
    });
    Navigator.of(context).pop();
    _showMessage('${result.title} added.');
  }

  void _saveRecurringActivity(ActivityFormResult result) {
    final isFutureDate = isAfterDate(_selectedDate, _data.today);
    setState(() {
      final activity = _data.createRecurringActivity(
        title: result.title,
        startDate: _selectedDate,
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
      if (!isFutureDate && _canCompleteImmediately(activity.trackingType)) {
        _data.saveActivityLog(
          activityId: activity.id,
          date: _selectedDate,
          status: DailyLogStatus.completed,
        );
      }
    });
    Navigator.of(context).pop();
    _showMessage(
      isFutureDate ? '${result.title} planned.' : '${result.title} added.',
    );
  }

  String _categoryIdForResult(ActivityFormResult result) {
    return _data.resolveCategoryId(
      categoryId: result.categoryId,
      customCategoryName: result.customCategoryName,
    );
  }

  void _showSleepSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final checkIn = _checkInForDate(_selectedDate);
        return DurationMinutesSheet(
          title: 'Daily check-in',
          initialMinutes: checkIn?.sleepMinutes,
          saveLabel: 'Save Check-In',
          keyPrefix: 'sleep',
          maxMinutes: 1440,
          noteLabel: 'Day note',
          initialNote: checkIn?.dayNote,
          onSave: (result) {
            Navigator.of(context).pop();
            setState(() {
              _data.saveDailyCheckIn(
                date: _selectedDate,
                sleepMinutes: result.totalMinutes,
                dayNote: result.note,
              );
            });
          },
        );
      },
    );
  }

  void _showActivityDetails(DailyActivityEntry entry) {
    final isFutureDate = isAfterDate(_selectedDate, _data.today);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return DailyLogDetailsSheet(
          entry: entry,
          category: _data.categoryForActivity(entry.activity),
          options: _data.optionsForActivity(entry.activity.id),
          expectedDurationMinutes: _data.expectedDurationForActivity(
            entry.activity.id,
          ),
          isFutureDate: isFutureDate,
          onSaveLog: (request) => _saveLog(entry.activity, request),
          onClearLog: () => _removeLog(entry.activity),
          onPlanActivity: () => _planActivity(entry.activity),
        );
      },
    );
  }

  void _planActivity(ActivityTemplate activity) {
    setState(() {
      _data.planActivity(activityId: activity.id, date: _selectedDate);
    });
    _showMessage('${activity.title} planned.');
  }

  void _removeLog(ActivityTemplate activity) {
    setState(() {
      _data.removeActivityLog(activityId: activity.id, date: _selectedDate);
    });
    _showMessage('${activity.title} removed from this day.');
  }

  void _showDurationSheetForActivity(ActivityTemplate activity) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return DurationMinutesSheet(
          title: 'How long did you spend?',
          initialMinutes: null,
          saveLabel: 'Save Time',
          keyPrefix: 'duration',
          onSave: (result) {
            Navigator.of(context).pop();
            _saveLog(
              activity,
              DailyLogRequest(
                status: _statusForDuration(activity, result.totalMinutes),
                durationMinutes: result.totalMinutes,
              ),
            );
          },
        );
      },
    );
  }

  void _showQuantitySheet(ActivityTemplate activity) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return NumericLogSheet(
          title: 'What number do you want to log?',
          label: 'Amount',
          submitLabel: 'Save',
          onSave: (value) {
            Navigator.of(context).pop();
            _saveLog(
              activity,
              DailyLogRequest(status: DailyLogStatus.completed, value: value),
            );
          },
        );
      },
    );
  }

  void _showLevelSheetForActivity(ActivityTemplate activity) {
    _showLogChoiceSheet(
      title: 'How was your control today?',
      choices: const [
        LogChoice(
          label: 'Good control',
          request: DailyLogRequest(status: DailyLogStatus.completed, value: 1),
        ),
        LogChoice(
          label: 'Some scrolling',
          request: DailyLogRequest(
            status: DailyLogStatus.partiallyCompleted,
            value: 2,
          ),
        ),
        LogChoice(
          label: 'Bad day',
          request: DailyLogRequest(status: DailyLogStatus.missed, value: 3),
        ),
      ],
      onSelected: (choice) => _saveLog(activity, choice.request!),
    );
  }

  void _showCategoricalSheetForActivity(ActivityTemplate activity) {
    final options = _data.optionsForActivity(activity.id);
    if (options.isEmpty) {
      _showMessage('Add options for this activity first.');
      return;
    }

    _showLogChoiceSheet(
      title: 'What fits this activity today?',
      choices: [
        for (final option in options)
          LogChoice(
            label: option.label,
            request: DailyLogRequest(
              status: _statusForCategoricalOption(option),
              value: option.value,
            ),
          ),
      ],
      onSelected: (choice) => _saveLog(activity, choice.request!),
    );
  }

  void _showLogChoiceSheet({
    required String title,
    required List<LogChoice> choices,
    required ValueChanged<LogChoice> onSelected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return LogChoiceSheet(
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  bool _canCompleteImmediately(TrackingType trackingType) {
    return trackingType == TrackingType.boolean ||
        trackingType == TrackingType.milestone;
  }

  DailyLogStatus _statusForDuration(ActivityTemplate activity, int minutes) {
    final expectedMinutes = _data.expectedDurationForActivity(activity.id);
    if (expectedMinutes == null || expectedMinutes <= 0) {
      return DailyLogStatus.completed;
    }
    return minutes >= expectedMinutes
        ? DailyLogStatus.completed
        : DailyLogStatus.partiallyCompleted;
  }

  DailyLogStatus _statusForCategoricalOption(ActivityOption option) {
    return option.creditValue < 0
        ? DailyLogStatus.missed
        : DailyLogStatus.completed;
  }
}
