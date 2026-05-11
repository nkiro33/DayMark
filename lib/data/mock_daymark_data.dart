import '../models/models.dart';
import 'presaved_activity_templates.dart';

class DailyActivityEntry {
  const DailyActivityEntry({required this.activity, this.log});

  final ActivityTemplate activity;
  final DailyActivityLog? log;
}

class DailySummary {
  const DailySummary({
    required this.earnedCredits,
    required this.expectedCredits,
    required this.completedCount,
    required this.partialCount,
    required this.remainingCount,
    required this.missedOrSkippedCount,
  });

  final double earnedCredits;
  final double expectedCredits;
  final int completedCount;
  final int partialCount;
  final int remainingCount;
  final int missedOrSkippedCount;
}

class MockDaymarkData {
  MockDaymarkData({DateTime? today})
    : today = _dateOnly(today ?? DateTime.now()) {
    final now = DateTime.now();
    final yesterday = this.today.subtract(const Duration(days: 1));
    final futureDate = this.today.add(const Duration(days: 1));

    userProfile = UserProfile(
      id: userId,
      displayName: 'Daymark User',
      timezone: 'local',
      onboardingCompleted: true,
      createdAt: now,
      updatedAt: now,
    );

    categories = [
      const ActivityCategory(
        id: 'category-good-habit',
        name: 'Good Habit',
        code: 'good_habit',
      ),
      const ActivityCategory(id: 'category-work', name: 'Work', code: 'work'),
      const ActivityCategory(
        id: 'category-study',
        name: 'Study',
        code: 'study',
      ),
      const ActivityCategory(
        id: 'category-course',
        name: 'Course',
        code: 'course',
      ),
      const ActivityCategory(
        id: 'category-project',
        name: 'Project',
        code: 'project',
      ),
      const ActivityCategory(
        id: 'category-bad-habit',
        name: 'Bad Habit',
        code: 'bad_habit',
      ),
      const ActivityCategory(
        id: 'category-health',
        name: 'Health',
        code: 'health',
      ),
      const ActivityCategory(
        id: 'category-personal',
        name: 'Personal',
        code: 'personal',
      ),
      const ActivityCategory(
        id: 'category-to-do',
        name: 'To-do',
        code: 'to_do',
      ),
    ];

    presavedTemplates = appPresavedActivityTemplates;

    activities = [
      ActivityTemplate(
        id: 'activity-make-bed',
        userId: userId,
        categoryId: 'category-good-habit',
        title: 'Make Bed',
        description: 'Start the day with a small win.',
        activityType: ActivityType.positive,
        trackingType: TrackingType.boolean,
        activityScope: ActivityScope.recurring,
        createdAt: now,
        updatedAt: now,
      ),
      ActivityTemplate(
        id: 'activity-study',
        userId: userId,
        categoryId: 'category-study',
        title: 'Study',
        description: 'Track focused study time.',
        activityType: ActivityType.positive,
        trackingType: TrackingType.duration,
        activityScope: ActivityScope.recurring,
        createdAt: now,
        updatedAt: now,
      ),
      ActivityTemplate(
        id: 'activity-work-on-project',
        userId: userId,
        categoryId: 'category-project',
        title: 'Work on Project',
        description: 'Track progress on a personal or professional project.',
        activityType: ActivityType.positive,
        trackingType: TrackingType.duration,
        activityScope: ActivityScope.manual,
        createdAt: now,
        updatedAt: now,
      ),
      ActivityTemplate(
        id: 'activity-reduce-tiktok-reels',
        userId: userId,
        categoryId: 'category-bad-habit',
        title: 'Reduce TikTok/Reels',
        description: 'Track how well you controlled short-form scrolling.',
        activityType: ActivityType.negative,
        trackingType: TrackingType.level,
        activityScope: ActivityScope.recurring,
        createdAt: now,
        updatedAt: now,
      ),
      ActivityTemplate(
        id: 'activity-exercise',
        userId: userId,
        categoryId: 'category-health',
        title: 'Exercise',
        description: 'Track workouts or physical activity.',
        activityType: ActivityType.positive,
        trackingType: TrackingType.duration,
        activityScope: ActivityScope.recurring,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    schedules = [
      const ActivitySchedule(
        id: 'schedule-make-bed',
        activityId: 'activity-make-bed',
        frequency: ScheduleFrequency.daily,
      ),
      const ActivitySchedule(
        id: 'schedule-study',
        activityId: 'activity-study',
        frequency: ScheduleFrequency.weekly,
        daysOfWeek: [1, 2, 3, 4, 5],
        expectedDurationMinutes: 60,
      ),
      const ActivitySchedule(
        id: 'schedule-work-on-project',
        activityId: 'activity-work-on-project',
        frequency: ScheduleFrequency.manual,
      ),
      const ActivitySchedule(
        id: 'schedule-reduce-tiktok-reels',
        activityId: 'activity-reduce-tiktok-reels',
        frequency: ScheduleFrequency.daily,
      ),
      ActivitySchedule(
        id: 'schedule-exercise',
        activityId: 'activity-exercise',
        frequency: ScheduleFrequency.weekly,
        daysOfWeek: _uniqueWeekdays([this.today.weekday, futureDate.weekday]),
        expectedDurationMinutes: 30,
      ),
    ];

    creditRules = [
      CreditRule(
        id: 'credit-make-bed',
        activityId: 'activity-make-bed',
        baseCredit: 2,
      ),
      CreditRule(
        id: 'credit-study',
        activityId: 'activity-study',
        creditPerMinute: 0.1,
        maxDailyCredit: 8,
      ),
      CreditRule(
        id: 'credit-work-on-project',
        activityId: 'activity-work-on-project',
        creditPerMinute: 0.12,
        maxDailyCredit: 10,
      ),
      CreditRule(
        id: 'credit-reduce-tiktok-reels',
        activityId: 'activity-reduce-tiktok-reels',
        baseCredit: 2,
        penaltyCredit: -5,
      ),
      CreditRule(
        id: 'credit-exercise',
        activityId: 'activity-exercise',
        creditPerMinute: 0.1,
        maxDailyCredit: 5,
      ),
    ];

    activityOptions = [];

    dailyLogs = [
      DailyActivityLog(
        id: 'log-yesterday-make-bed',
        userId: userId,
        activityId: 'activity-make-bed',
        date: yesterday,
        status: DailyLogStatus.completed,
        creditsEarned: 2,
        createdAt: now,
        updatedAt: now,
      ),
      DailyActivityLog(
        id: 'log-yesterday-study',
        userId: userId,
        activityId: 'activity-study',
        date: yesterday,
        status: DailyLogStatus.partiallyCompleted,
        durationMinutes: 30,
        creditsEarned: 3,
        createdAt: now,
        updatedAt: now,
      ),
      DailyActivityLog(
        id: 'log-yesterday-reduce-tiktok-reels',
        userId: userId,
        activityId: 'activity-reduce-tiktok-reels',
        date: yesterday,
        status: DailyLogStatus.completed,
        value: 1,
        creditsEarned: 2,
        createdAt: now,
        updatedAt: now,
      ),
      DailyActivityLog(
        id: 'log-today-make-bed',
        userId: userId,
        activityId: 'activity-make-bed',
        date: this.today,
        status: DailyLogStatus.completed,
        creditsEarned: 2,
        createdAt: now,
        updatedAt: now,
      ),
      DailyActivityLog(
        id: 'log-today-study',
        userId: userId,
        activityId: 'activity-study',
        date: this.today,
        status: DailyLogStatus.completed,
        durationMinutes: 60,
        creditsEarned: 6,
        createdAt: now,
        updatedAt: now,
      ),
      DailyActivityLog(
        id: 'log-today-work-on-project',
        userId: userId,
        activityId: 'activity-work-on-project',
        date: this.today,
        status: DailyLogStatus.completed,
        durationMinutes: 45,
        creditsEarned: 5.4,
        createdAt: now,
        updatedAt: now,
      ),
      DailyActivityLog(
        id: 'log-today-reduce-tiktok-reels',
        userId: userId,
        activityId: 'activity-reduce-tiktok-reels',
        date: this.today,
        status: DailyLogStatus.partiallyCompleted,
        value: 2,
        creditsEarned: -2,
        createdAt: now,
        updatedAt: now,
      ),
      DailyActivityLog(
        id: 'log-future-make-bed',
        userId: userId,
        activityId: 'activity-make-bed',
        date: futureDate,
        status: DailyLogStatus.planned,
        creditsEarned: 0,
        createdAt: now,
        updatedAt: now,
      ),
      DailyActivityLog(
        id: 'log-future-exercise',
        userId: userId,
        activityId: 'activity-exercise',
        date: futureDate,
        status: DailyLogStatus.planned,
        creditsEarned: 0,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    dailyCheckIns = [
      DailyCheckIn(
        id: 'check-in-today',
        userId: userId,
        date: this.today,
        sleepMinutes: 450,
        dayNote: 'A steady day.',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  static const userId = 'local-user';

  final DateTime today;
  late final UserProfile userProfile;
  late final List<ActivityCategory> categories;
  late final List<ActivityTemplate> activities;
  late final List<PresavedActivityTemplate> presavedTemplates;
  late final List<ActivitySchedule> schedules;
  late final List<CreditRule> creditRules;
  late final List<ActivityOption> activityOptions;
  late final List<DailyActivityLog> dailyLogs;
  late final List<DailyCheckIn> dailyCheckIns;

  List<DailyActivityLog> getLogsForDate(DateTime date) {
    final target = _dateOnly(date);
    return dailyLogs.where((log) => _isSameDate(log.date, target)).toList();
  }

  DailyActivityLog? getLogForActivityDate({
    required String activityId,
    required DateTime date,
  }) {
    final target = _dateOnly(date);
    return dailyLogs
        .where(
          (log) =>
              log.activityId == activityId && _isSameDate(log.date, target),
        )
        .firstOrNull;
  }

  List<DailyActivityEntry> getActivitiesForDate(DateTime date) {
    final target = _dateOnly(date);
    final logsByActivityId = {
      for (final log in getLogsForDate(target)) log.activityId: log,
    };
    final entries = <DailyActivityEntry>[];
    final addedActivityIds = <String>{};

    for (final activity in activities.where((activity) => activity.isActive)) {
      final log = logsByActivityId[activity.id];
      if (_isScheduledForDate(activity.id, target) || log != null) {
        entries.add(DailyActivityEntry(activity: activity, log: log));
        addedActivityIds.add(activity.id);
      }
    }

    for (final log in logsByActivityId.values) {
      if (addedActivityIds.contains(log.activityId)) {
        continue;
      }
      final activity = _activityById(log.activityId);
      if (activity != null) {
        entries.add(DailyActivityEntry(activity: activity, log: log));
      }
    }

    return entries;
  }

  DailySummary getDailySummary(DateTime date) {
    final entries = getActivitiesForDate(date);
    final logs = entries.map((entry) => entry.log).nonNulls;

    return DailySummary(
      earnedCredits: logs.fold(0, (sum, log) => sum + log.creditsEarned),
      expectedCredits: entries.fold(
        0,
        (sum, entry) => sum + _expectedCreditsForActivity(entry.activity.id),
      ),
      completedCount: logs
          .where((log) => log.status == DailyLogStatus.completed)
          .length,
      partialCount: logs
          .where((log) => log.status == DailyLogStatus.partiallyCompleted)
          .length,
      remainingCount:
          entries.where((entry) => entry.log == null).length +
          logs.where((log) => log.status == DailyLogStatus.planned).length,
      missedOrSkippedCount: logs
          .where(
            (log) =>
                log.status == DailyLogStatus.missed ||
                log.status == DailyLogStatus.skipped,
          )
          .length,
    );
  }

  List<ActivityTemplate> getActivitiesByCategory(ActivityCategory category) {
    return activities
        .where(
          (activity) => activity.categoryId == category.id && activity.isActive,
        )
        .toList();
  }

  ActivityCategory categoryForActivity(ActivityTemplate activity) {
    return categories
        .where((category) => category.id == activity.categoryId)
        .first;
  }

  ActivityCategory categoryForPresavedTemplate(
    PresavedActivityTemplate template,
  ) {
    return categories
        .where((category) => category.id == template.categoryId)
        .first;
  }

  String resolveCategoryId({
    required String categoryId,
    String? customCategoryName,
  }) {
    final normalizedName = customCategoryName?.trim();
    if (normalizedName == null || normalizedName.isEmpty) {
      return categoryId;
    }

    final existing = categories
        .where(
          (category) =>
              category.name.toLowerCase() == normalizedName.toLowerCase(),
        )
        .firstOrNull;
    if (existing != null) {
      return existing.id;
    }

    final code = _categoryCode(normalizedName);
    final category = ActivityCategory(
      id: 'category-custom-$code-${categories.length + 1}',
      name: normalizedName,
      code: code,
    );
    categories.add(category);
    return category.id;
  }

  List<ActivityOption> optionsForActivity(String activityId) {
    final options =
        activityOptions
            .where((option) => option.activityId == activityId)
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return options;
  }

  List<ActivityTemplate> getLoggableActivitiesForDate(DateTime date) {
    final loggedActivityIds = getLogsForDate(
      date,
    ).map((log) => log.activityId).toSet();
    return activities
        .where(
          (activity) =>
              activity.isActive &&
              activity.activityScope != ActivityScope.oneTime &&
              !loggedActivityIds.contains(activity.id),
        )
        .toList();
  }

  DailyActivityLog saveActivityLog({
    required String activityId,
    required DateTime date,
    required DailyLogStatus status,
    double? value,
    int? durationMinutes,
    String? notes,
  }) {
    final target = _dateOnly(date);
    final activity = _activityById(activityId);
    if (activity == null) {
      throw ArgumentError.value(activityId, 'activityId', 'Unknown activity');
    }
    if (_isFutureDate(target)) {
      if (status != DailyLogStatus.planned) {
        throw ArgumentError('Future-dated logs can only be planned.');
      }
      if ((value ?? 0) != 0 || (durationMinutes ?? 0) != 0) {
        throw ArgumentError(
          'Future-dated logs cannot earn activity values yet.',
        );
      }
    }
    if (durationMinutes != null && durationMinutes < 0) {
      throw ArgumentError.value(
        durationMinutes,
        'durationMinutes',
        'Duration cannot be negative',
      );
    }
    if (value != null && value < 0) {
      throw ArgumentError.value(value, 'value', 'Value cannot be negative');
    }

    final now = DateTime.now();
    final existingIndex = dailyLogs.indexWhere(
      (log) => log.activityId == activityId && _isSameDate(log.date, target),
    );
    final existing = existingIndex == -1 ? null : dailyLogs[existingIndex];
    final log = DailyActivityLog(
      id: existing?.id ?? 'log-$activityId-${_dateKey(target)}',
      userId: userId,
      activityId: activityId,
      date: target,
      status: status,
      value: value,
      durationMinutes: durationMinutes,
      notes: notes,
      creditsEarned: _isFutureDate(target)
          ? 0
          : calculateCredits(
              activity: activity,
              status: status,
              value: value,
              durationMinutes: durationMinutes,
            ),
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    if (existingIndex == -1) {
      dailyLogs.add(log);
    } else {
      dailyLogs[existingIndex] = log;
    }

    return log;
  }

  DailyActivityLog planActivity({
    required String activityId,
    required DateTime date,
  }) {
    return saveActivityLog(
      activityId: activityId,
      date: date,
      status: DailyLogStatus.planned,
    );
  }

  void removeActivityLog({required String activityId, required DateTime date}) {
    final target = _dateOnly(date);
    dailyLogs.removeWhere(
      (log) => log.activityId == activityId && _isSameDate(log.date, target),
    );
  }

  DailyActivityLog createOneTimeActivity({
    required String title,
    required DateTime date,
    String? description,
    String categoryId = 'category-personal',
    ActivityType activityType = ActivityType.positive,
    TrackingType trackingType = TrackingType.boolean,
    double baseCredit = 1,
    double creditPerMinute = 0,
    double creditPerUnit = 0,
    double? maxDailyCredit,
    double penaltyCredit = 0,
    List<ActivityOptionInput> categoricalOptions = const [],
  }) {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Title cannot be empty');
    }

    final target = _dateOnly(date);
    final now = DateTime.now();
    final idSuffix = '${_dateKey(target)}-${activities.length + 1}';
    final activity = ActivityTemplate(
      id: 'activity-one-time-$idSuffix',
      userId: userId,
      categoryId: categoryId,
      title: normalizedTitle,
      description: description ?? 'One-time activity for ${_dateKey(target)}.',
      activityType: activityType,
      trackingType: trackingType,
      activityScope: ActivityScope.oneTime,
      createdAt: now,
      updatedAt: now,
    );
    activities.add(activity);
    creditRules.add(
      CreditRule(
        id: 'credit-one-time-$idSuffix',
        activityId: activity.id,
        baseCredit: baseCredit,
        creditPerMinute: _defaultCreditPerMinute(trackingType, creditPerMinute),
        creditPerUnit: _defaultCreditPerUnit(trackingType, creditPerUnit),
        maxDailyCredit: maxDailyCredit,
        penaltyCredit: penaltyCredit,
      ),
    );
    _addCategoricalOptions(
      activity: activity,
      idSuffix: idSuffix,
      options: categoricalOptions,
      now: now,
    );

    return saveActivityLog(
      activityId: activity.id,
      date: target,
      status: _isFutureDate(target) || !_canCompleteImmediately(trackingType)
          ? DailyLogStatus.planned
          : DailyLogStatus.completed,
    );
  }

  ActivityTemplate createRecurringActivity({
    required String title,
    required DateTime startDate,
    String? description,
    String categoryId = 'category-personal',
    ActivityType activityType = ActivityType.positive,
    TrackingType trackingType = TrackingType.boolean,
    ScheduleFrequency frequency = ScheduleFrequency.daily,
    List<int> daysOfWeek = const [],
    int? expectedDurationMinutes,
    double baseCredit = 1,
    double creditPerMinute = 0,
    double creditPerUnit = 0,
    double? maxDailyCredit,
    double penaltyCredit = 0,
    List<ActivityOptionInput> categoricalOptions = const [],
  }) {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Title cannot be empty');
    }

    final target = _dateOnly(startDate);
    final now = DateTime.now();
    final idSuffix = '${_dateKey(target)}-${activities.length + 1}';
    final activity = ActivityTemplate(
      id: 'activity-recurring-$idSuffix',
      userId: userId,
      categoryId: categoryId,
      title: normalizedTitle,
      description: description ?? 'Recurring activity.',
      activityType: activityType,
      trackingType: trackingType,
      activityScope: frequency == ScheduleFrequency.manual
          ? ActivityScope.manual
          : ActivityScope.recurring,
      startDate: target,
      createdAt: now,
      updatedAt: now,
    );

    activities.add(activity);
    schedules.add(
      ActivitySchedule(
        id: 'schedule-recurring-$idSuffix',
        activityId: activity.id,
        frequency: frequency,
        daysOfWeek: daysOfWeek,
        expectedDurationMinutes: expectedDurationMinutes,
      ),
    );
    creditRules.add(
      CreditRule(
        id: 'credit-recurring-$idSuffix',
        activityId: activity.id,
        baseCredit: baseCredit,
        creditPerMinute: _defaultCreditPerMinute(trackingType, creditPerMinute),
        creditPerUnit: _defaultCreditPerUnit(trackingType, creditPerUnit),
        maxDailyCredit: maxDailyCredit,
        penaltyCredit: penaltyCredit,
      ),
    );
    _addCategoricalOptions(
      activity: activity,
      idSuffix: idSuffix,
      options: categoricalOptions,
      now: now,
    );

    if (_isFutureDate(target)) {
      planActivity(activityId: activity.id, date: target);
    }

    return activity;
  }

  ActivityTemplate createActivityFromPresavedTemplate(
    PresavedActivityTemplate template,
  ) {
    final now = DateTime.now();
    final idSuffix = '${template.id}-${activities.length + 1}';
    final activity = ActivityTemplate(
      id: 'activity-from-$idSuffix',
      userId: userId,
      categoryId: template.categoryId,
      title: template.title,
      description: template.description,
      activityType: template.activityType,
      trackingType: template.trackingType,
      activityScope: template.activityScope,
      isActive: true,
      startDate: today,
      createdAt: now,
      updatedAt: now,
    );

    activities.add(activity);
    schedules.add(
      ActivitySchedule(
        id: 'schedule-from-$idSuffix',
        activityId: activity.id,
        frequency: template.frequency,
        daysOfWeek: template.daysOfWeek,
        expectedDurationMinutes: template.expectedDurationMinutes,
      ),
    );
    creditRules.add(
      CreditRule(
        id: 'credit-from-$idSuffix',
        activityId: activity.id,
        baseCredit: template.baseCredit,
        creditPerMinute: _defaultCreditPerMinute(
          template.trackingType,
          template.creditPerMinute,
        ),
        creditPerUnit: _defaultCreditPerUnit(
          template.trackingType,
          template.creditPerUnit,
        ),
        maxDailyCredit: template.maxDailyCredit,
        penaltyCredit: template.penaltyCredit,
      ),
    );

    return activity;
  }

  ActivityTemplate updateReusableActivity({
    required String activityId,
    required String title,
    String? description,
    required String categoryId,
    required ActivityType activityType,
    required TrackingType trackingType,
    required ScheduleFrequency frequency,
    List<int> daysOfWeek = const [],
    int? expectedDurationMinutes,
    required double baseCredit,
    required double creditPerMinute,
    required double creditPerUnit,
    double? maxDailyCredit,
    required double penaltyCredit,
    List<ActivityOptionInput> categoricalOptions = const [],
  }) {
    final existingIndex = activities.indexWhere(
      (activity) => activity.id == activityId,
    );
    if (existingIndex == -1) {
      throw ArgumentError.value(activityId, 'activityId', 'Unknown activity');
    }

    final existing = activities[existingIndex];
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Title cannot be empty');
    }

    final updated = ActivityTemplate(
      id: existing.id,
      userId: existing.userId,
      categoryId: categoryId,
      title: normalizedTitle,
      description: description,
      activityType: activityType,
      trackingType: trackingType,
      activityScope: frequency == ScheduleFrequency.manual
          ? ActivityScope.manual
          : ActivityScope.recurring,
      isActive: existing.isActive,
      startDate: existing.startDate,
      endDate: existing.endDate,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    activities[existingIndex] = updated;

    _upsertSchedule(
      activityId: activityId,
      frequency: frequency,
      daysOfWeek: daysOfWeek,
      expectedDurationMinutes: expectedDurationMinutes,
    );
    _upsertCreditRule(
      activityId: activityId,
      baseCredit: baseCredit,
      creditPerMinute: _defaultCreditPerMinute(trackingType, creditPerMinute),
      creditPerUnit: _defaultCreditPerUnit(trackingType, creditPerUnit),
      maxDailyCredit: maxDailyCredit,
      penaltyCredit: penaltyCredit,
    );
    activityOptions.removeWhere((option) => option.activityId == activityId);
    _addCategoricalOptions(
      activity: updated,
      idSuffix: '$activityId-edit',
      options: categoricalOptions,
      now: DateTime.now(),
    );

    return updated;
  }

  ActivityTemplate setActivityActive({
    required String activityId,
    required bool isActive,
  }) {
    final index = activities.indexWhere(
      (activity) => activity.id == activityId,
    );
    if (index == -1) {
      throw ArgumentError.value(activityId, 'activityId', 'Unknown activity');
    }

    final existing = activities[index];
    final updated = ActivityTemplate(
      id: existing.id,
      userId: existing.userId,
      categoryId: existing.categoryId,
      title: existing.title,
      description: existing.description,
      activityType: existing.activityType,
      trackingType: existing.trackingType,
      activityScope: existing.activityScope,
      isActive: isActive,
      startDate: existing.startDate,
      endDate: existing.endDate,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    activities[index] = updated;
    return updated;
  }

  ActivitySchedule? scheduleForActivity(String activityId) {
    return schedules
        .where((schedule) => schedule.activityId == activityId)
        .firstOrNull;
  }

  CreditRule? creditRuleForActivity(String activityId) {
    return _creditRuleForActivity(activityId);
  }

  List<DailyActivityLog> recentLogsForActivity(String activityId) {
    final logs = dailyLogs.where((log) => log.activityId == activityId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return logs.take(5).toList();
  }

  int? expectedDurationForActivity(String activityId) {
    return schedules
        .where((schedule) => schedule.activityId == activityId)
        .firstOrNull
        ?.expectedDurationMinutes;
  }

  DailyCheckIn saveDailyCheckIn({
    required DateTime date,
    required int? sleepMinutes,
    String? dayNote,
  }) {
    if (sleepMinutes != null && (sleepMinutes < 0 || sleepMinutes > 1440)) {
      throw ArgumentError.value(
        sleepMinutes,
        'sleepMinutes',
        'Sleep minutes must be between 0 and 1440',
      );
    }

    final target = _dateOnly(date);
    final now = DateTime.now();
    final existingIndex = dailyCheckIns.indexWhere(
      (checkIn) => _isSameDate(checkIn.date, target),
    );
    final existing = existingIndex == -1 ? null : dailyCheckIns[existingIndex];
    final checkIn = DailyCheckIn(
      id: existing?.id ?? 'check-in-${_dateKey(target)}',
      userId: userId,
      date: target,
      sleepMinutes: sleepMinutes,
      dayNote: dayNote,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    if (existingIndex == -1) {
      dailyCheckIns.add(checkIn);
    } else {
      dailyCheckIns[existingIndex] = checkIn;
    }

    return checkIn;
  }

  double calculateCredits({
    required ActivityTemplate activity,
    required DailyLogStatus status,
    double? value,
    int? durationMinutes,
  }) {
    if (status == DailyLogStatus.planned ||
        status == DailyLogStatus.skipped ||
        status == DailyLogStatus.notApplicable) {
      return 0;
    }

    final rule = _creditRuleForActivity(activity.id);
    if (rule == null) {
      return 0;
    }

    final credit = switch (activity.trackingType) {
      TrackingType.boolean ||
      TrackingType.milestone => _simpleCompletionCredits(
        activity: activity,
        rule: rule,
        status: status,
      ),
      TrackingType.duration => rule.creditPerMinute * (durationMinutes ?? 0),
      TrackingType.quantity => rule.creditPerUnit * (value ?? 0),
      TrackingType.level => _levelCredits(activity, rule, value),
      TrackingType.categorical => _categoricalCredits(activity.id, value),
    };

    return _capDailyCredit(credit, rule.maxDailyCredit);
  }

  double _categoricalCredits(String activityId, double? value) {
    if (value == null) {
      return 0;
    }

    return optionsForActivity(
          activityId,
        ).where((option) => option.value == value).firstOrNull?.creditValue ??
        0;
  }

  void _addCategoricalOptions({
    required ActivityTemplate activity,
    required String idSuffix,
    required List<ActivityOptionInput> options,
    required DateTime now,
  }) {
    if (activity.trackingType != TrackingType.categorical) {
      return;
    }

    final normalizedOptions = options
        .where((option) => option.label.trim().isNotEmpty)
        .toList();
    final effectiveOptions = normalizedOptions.isEmpty
        ? const [
            ActivityOptionInput(label: 'Too little', value: 1, creditValue: 0),
            ActivityOptionInput(label: 'Normal', value: 2, creditValue: 1),
            ActivityOptionInput(label: 'Too much', value: 3, creditValue: 0),
          ]
        : normalizedOptions;

    for (final indexedOption in effectiveOptions.indexed) {
      final index = indexedOption.$1;
      final option = indexedOption.$2;
      activityOptions.add(
        ActivityOption(
          id: 'option-$idSuffix-${index + 1}',
          activityId: activity.id,
          label: option.label.trim(),
          value: option.value,
          creditValue: option.creditValue,
          sortOrder: index,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
  }

  bool _isScheduledForDate(String activityId, DateTime date) {
    final activity = _activityById(activityId);
    if (activity == null) {
      return false;
    }
    if (activity.startDate != null &&
        date.isBefore(_dateOnly(activity.startDate!))) {
      return false;
    }
    if (activity.endDate != null &&
        date.isAfter(_dateOnly(activity.endDate!))) {
      return false;
    }

    final schedule = schedules
        .where((item) => item.activityId == activityId)
        .firstOrNull;
    if (schedule == null) {
      return false;
    }

    return switch (schedule.frequency) {
      ScheduleFrequency.daily => true,
      ScheduleFrequency.weekly => schedule.daysOfWeek.contains(date.weekday),
      ScheduleFrequency.custom => schedule.daysOfWeek.contains(date.weekday),
      ScheduleFrequency.manual => false,
    };
  }

  ActivityTemplate? _activityById(String id) {
    return activities.where((activity) => activity.id == id).firstOrNull;
  }

  CreditRule? _creditRuleForActivity(String activityId) {
    return creditRules
        .where((item) => item.activityId == activityId)
        .firstOrNull;
  }

  void _upsertSchedule({
    required String activityId,
    required ScheduleFrequency frequency,
    required List<int> daysOfWeek,
    required int? expectedDurationMinutes,
  }) {
    final index = schedules.indexWhere(
      (schedule) => schedule.activityId == activityId,
    );
    final schedule = ActivitySchedule(
      id: index == -1 ? 'schedule-$activityId' : schedules[index].id,
      activityId: activityId,
      frequency: frequency,
      daysOfWeek: daysOfWeek,
      expectedDurationMinutes: expectedDurationMinutes,
    );
    if (index == -1) {
      schedules.add(schedule);
    } else {
      schedules[index] = schedule;
    }
  }

  void _upsertCreditRule({
    required String activityId,
    required double baseCredit,
    required double creditPerMinute,
    required double creditPerUnit,
    required double? maxDailyCredit,
    required double penaltyCredit,
  }) {
    final index = creditRules.indexWhere(
      (rule) => rule.activityId == activityId,
    );
    final rule = CreditRule(
      id: index == -1 ? 'credit-$activityId' : creditRules[index].id,
      activityId: activityId,
      baseCredit: baseCredit,
      creditPerMinute: creditPerMinute,
      creditPerUnit: creditPerUnit,
      maxDailyCredit: maxDailyCredit,
      penaltyCredit: penaltyCredit,
    );
    if (index == -1) {
      creditRules.add(rule);
    } else {
      creditRules[index] = rule;
    }
  }

  double _expectedCreditsForActivity(String activityId) {
    final rule = _creditRuleForActivity(activityId);
    if (rule == null) {
      return 0;
    }
    final categoricalCredits = optionsForActivity(
      activityId,
    ).map((option) => option.creditValue);
    if (categoricalCredits.isNotEmpty) {
      return categoricalCredits.reduce((a, b) => a > b ? a : b);
    }
    if (rule.baseCredit > 0) {
      return rule.baseCredit;
    }
    if (rule.maxDailyCredit != null) {
      return rule.maxDailyCredit!;
    }
    return rule.creditPerMinute * 60 + rule.creditPerUnit;
  }

  bool _isFutureDate(DateTime date) {
    return date.isAfter(today);
  }
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

bool _isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

List<int> _uniqueWeekdays(List<int> weekdays) {
  return weekdays.toSet().toList()..sort();
}

double _levelCredits(
  ActivityTemplate activity,
  CreditRule rule,
  double? value,
) {
  if (activity.activityType != ActivityType.negative) {
    return rule.baseCredit;
  }
  final penaltyCredit = rule.penaltyCredit == 0
      ? -rule.baseCredit.abs()
      : rule.penaltyCredit;

  return switch ((value ?? 1).round()) {
    <= 1 => rule.baseCredit,
    2 => penaltyCredit / 2,
    _ => penaltyCredit,
  };
}

double _simpleCompletionCredits({
  required ActivityTemplate activity,
  required CreditRule rule,
  required DailyLogStatus status,
}) {
  if (activity.activityType == ActivityType.negative) {
    return status == DailyLogStatus.completed
        ? rule.baseCredit
        : rule.penaltyCredit == 0
        ? -rule.baseCredit.abs()
        : rule.penaltyCredit;
  }
  return status == DailyLogStatus.completed ? rule.baseCredit : 0;
}

double _capDailyCredit(double credit, double? maxDailyCredit) {
  if (maxDailyCredit == null || credit <= 0) {
    return credit;
  }
  return credit > maxDailyCredit ? maxDailyCredit : credit;
}

double _defaultCreditPerMinute(TrackingType trackingType, double value) {
  if (trackingType == TrackingType.duration && value == 0) {
    return 0.1;
  }
  return value;
}

double _defaultCreditPerUnit(TrackingType trackingType, double value) {
  if (trackingType == TrackingType.quantity && value == 0) {
    return 1;
  }
  return value;
}

bool _canCompleteImmediately(TrackingType trackingType) {
  return trackingType == TrackingType.boolean ||
      trackingType == TrackingType.milestone;
}

String _dateKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

String _categoryCode(String name) {
  final cleaned = name
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  return cleaned.isEmpty ? 'other' : cleaned;
}
