import '../models/models.dart';

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

    categories = const [
      ActivityCategory(
        id: 'category-good-habit',
        name: 'Good Habit',
        code: 'good_habit',
      ),
      ActivityCategory(id: 'category-study', name: 'Study', code: 'study'),
      ActivityCategory(
        id: 'category-project',
        name: 'Project',
        code: 'project',
      ),
      ActivityCategory(
        id: 'category-bad-habit',
        name: 'Bad Habit',
        code: 'bad_habit',
      ),
      ActivityCategory(id: 'category-health', name: 'Health', code: 'health'),
    ];

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

    creditRules = const [
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
        sleepHours: 7.5,
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
  late final List<ActivitySchedule> schedules;
  late final List<CreditRule> creditRules;
  late final List<DailyActivityLog> dailyLogs;
  late final List<DailyCheckIn> dailyCheckIns;

  List<DailyActivityLog> getLogsForDate(DateTime date) {
    final target = _dateOnly(date);
    return dailyLogs.where((log) => _isSameDate(log.date, target)).toList();
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

  bool _isScheduledForDate(String activityId, DateTime date) {
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

  double _expectedCreditsForActivity(String activityId) {
    final rule = creditRules
        .where((item) => item.activityId == activityId)
        .firstOrNull;
    if (rule == null) {
      return 0;
    }
    if (rule.baseCredit > 0) {
      return rule.baseCredit;
    }
    if (rule.maxDailyCredit != null) {
      return rule.maxDailyCredit!;
    }
    return rule.creditPerMinute * 60 + rule.creditPerUnit;
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
