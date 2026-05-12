import 'package:daymark/data/mock_daymark_data.dart';
import 'package:daymark/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MockDaymarkData', () {
    final today = DateTime(2026, 5, 10);
    late MockDaymarkData data;

    setUp(() {
      data = MockDaymarkData(today: today);
    });

    test('includes focused sample data for the MVP model set', () {
      expect(data.categories, hasLength(9));
      expect(data.presavedTemplates.length, greaterThanOrEqualTo(15));
      expect(
        data.activities.map((activity) => activity.title),
        containsAll([
          'Make Bed',
          'Study',
          'Work on Project',
          'Reduce TikTok/Reels',
          'Exercise',
        ]),
      );
      expect(data.schedules, hasLength(data.activities.length));
      expect(data.creditRules, hasLength(data.activities.length));
      expect(data.dailyCheckIns.single.sleepMinutes, 450);
      expect(data.userProfile.dailyCreditGoal, 45);
      expect(
        data.activities.every((activity) => activity.sortOrder > 0),
        isTrue,
      );
      expect(data.presavedTemplates.first.title, 'Work');
    });

    test('creates user activities from presaved template defaults', () {
      final template = data.presavedTemplates.singleWhere(
        (template) => template.title == 'Drink Water',
      );

      final activity = data.createActivityFromPresavedTemplate(template);
      final schedule = data.scheduleForActivity(activity.id);
      final creditRule = data.creditRuleForActivity(activity.id);

      expect(activity.title, 'Drink Water');
      expect(activity.isActive, isTrue);
      expect(activity.categoryId, 'category-health');
      expect(activity.sortOrder, template.sortOrder);
      expect(schedule?.frequency, ScheduleFrequency.daily);
      expect(creditRule?.creditPerUnit, 0.5);
      expect(creditRule?.maxDailyCredit, 4);
    });

    test('returns logs for today, yesterday, and a future date', () {
      final yesterday = today.subtract(const Duration(days: 1));
      final futureDate = today.add(const Duration(days: 1));

      expect(data.getLogsForDate(yesterday), isNotEmpty);
      expect(data.getLogsForDate(today), isNotEmpty);
      expect(data.getLogsForDate(futureDate), isNotEmpty);
    });

    test('keeps future logs planned and credit-free', () {
      final futureDate = today.add(const Duration(days: 1));
      final futureLogs = data.getLogsForDate(futureDate);

      expect(futureLogs, isNotEmpty);
      expect(
        futureLogs.every((log) => log.status == DailyLogStatus.planned),
        isTrue,
      );
      expect(futureLogs.every((log) => log.creditsEarned == 0), isTrue);
    });

    test('includes manual activities only when logged for the date', () {
      final todayActivities = data.getActivitiesForDate(today);
      final futureActivities = data.getActivitiesForDate(
        today.add(const Duration(days: 1)),
      );

      expect(
        todayActivities.map((entry) => entry.activity.title),
        contains('Work on Project'),
      );
      expect(
        futureActivities.map((entry) => entry.activity.title),
        isNot(contains('Work on Project')),
      );
    });

    test('builds a simple daily summary', () {
      final summary = data.getDailySummary(today);

      expect(summary.earnedCredits, greaterThan(0));
      expect(summary.expectedCredits, data.userProfile.dailyCreditGoal);
      expect(summary.completedCount, 3);
      expect(summary.partialCount, 1);
      expect(summary.missedOrSkippedCount, 0);
    });

    test('logs a duration activity and updates the daily summary', () {
      final before = data.getDailySummary(today);

      final log = data.saveActivityLog(
        activityId: 'activity-exercise',
        date: today,
        status: DailyLogStatus.partiallyCompleted,
        durationMinutes: 30,
      );
      final after = data.getDailySummary(today);

      expect(log.creditsEarned, 3);
      expect(log.status, DailyLogStatus.partiallyCompleted);
      expect(log.sortOrder, 130);
      expect(after.earnedCredits, before.earnedCredits + 3);
      expect(after.partialCount, before.partialCount + 1);
    });

    test('replaces an existing activity log for the same date', () {
      data.saveActivityLog(
        activityId: 'activity-exercise',
        date: today,
        status: DailyLogStatus.partiallyCompleted,
        durationMinutes: 30,
      );
      data.saveActivityLog(
        activityId: 'activity-exercise',
        date: today,
        status: DailyLogStatus.completed,
        durationMinutes: 60,
      );

      final exerciseLogs = data
          .getLogsForDate(today)
          .where((log) => log.activityId == 'activity-exercise');

      expect(exerciseLogs, hasLength(1));
      expect(exerciseLogs.single.status, DailyLogStatus.completed);
      expect(exerciseLogs.single.creditsEarned, 5);
    });

    test('does not allow completing future activity logs', () {
      final futureDate = today.add(const Duration(days: 1));

      expect(
        () => data.saveActivityLog(
          activityId: 'activity-exercise',
          date: futureDate,
          status: DailyLogStatus.completed,
          durationMinutes: 30,
        ),
        throwsArgumentError,
      );

      final futureLogs = data.getLogsForDate(futureDate);
      expect(
        futureLogs.every((log) => log.status == DailyLogStatus.planned),
        isTrue,
      );
      expect(futureLogs.every((log) => log.creditsEarned == 0), isTrue);
    });

    test('creates one-time activities for today and future dates', () {
      final futureDate = today.add(const Duration(days: 1));

      final todayLog = data.createOneTimeActivity(
        title: 'Clean desk',
        date: today,
      );
      final futureLog = data.createOneTimeActivity(
        title: 'Doctor appointment',
        date: futureDate,
      );

      expect(todayLog.status, DailyLogStatus.completed);
      expect(todayLog.creditsEarned, 1);
      expect(futureLog.status, DailyLogStatus.planned);
      expect(futureLog.creditsEarned, 0);
      expect(
        data
            .getActivitiesForDate(futureDate)
            .map((entry) => entry.activity.title),
        contains('Doctor appointment'),
      );
    });

    test('creates recurring activities starting on the selected date', () {
      final futureDate = today.add(const Duration(days: 1));

      final todayActivity = data.createRecurringActivity(
        title: 'Read',
        startDate: today,
      );
      final futureActivity = data.createRecurringActivity(
        title: 'Water plants',
        startDate: futureDate,
      );

      expect(todayActivity.activityScope, ActivityScope.recurring);
      expect(futureActivity.activityScope, ActivityScope.recurring);
      expect(
        data.getActivitiesForDate(today).map((entry) => entry.activity.title),
        contains('Read'),
      );
      expect(
        data.getActivitiesForDate(today).map((entry) => entry.activity.title),
        isNot(contains('Water plants')),
      );
      expect(
        data
            .getActivitiesForDate(futureDate)
            .map((entry) => entry.activity.title),
        contains('Water plants'),
      );
      expect(
        data
            .getLogForActivityDate(
              activityId: futureActivity.id,
              date: futureDate,
            )
            ?.status,
        DailyLogStatus.planned,
      );
    });

    test('writes custom activity form details into models', () {
      final activity = data.createRecurringActivity(
        title: 'Practice guitar',
        startDate: today,
        description: 'Keep a small music practice rhythm.',
        categoryId: 'category-personal',
        activityType: ActivityType.positive,
        trackingType: TrackingType.duration,
        frequency: ScheduleFrequency.weekly,
        daysOfWeek: const [1, 3, 5],
        expectedDurationMinutes: 20,
        creditPerMinute: 0.2,
        maxDailyCredit: 6,
      );

      final schedule = data.schedules.singleWhere(
        (item) => item.activityId == activity.id,
      );
      final creditRule = data.creditRules.singleWhere(
        (item) => item.activityId == activity.id,
      );

      expect(activity.description, 'Keep a small music practice rhythm.');
      expect(activity.trackingType, TrackingType.duration);
      expect(schedule.frequency, ScheduleFrequency.weekly);
      expect(schedule.daysOfWeek, [1, 3, 5]);
      expect(schedule.expectedDurationMinutes, 20);
      expect(creditRule.creditPerMinute, 0.2);
      expect(creditRule.maxDailyCredit, 6);
    });

    test('stores categorical options and logs the selected option value', () {
      final activity = data.createRecurringActivity(
        title: 'Screen time balance',
        startDate: today,
        trackingType: TrackingType.categorical,
        categoricalOptions: const [
          ActivityOptionInput(label: 'Too little', value: 1, creditValue: 0),
          ActivityOptionInput(label: 'Normal', value: 2, creditValue: 2),
          ActivityOptionInput(label: 'Too much', value: 3, creditValue: -2),
        ],
      );

      final log = data.saveActivityLog(
        activityId: activity.id,
        date: today,
        status: DailyLogStatus.completed,
        value: 2,
      );

      expect(
        data.optionsForActivity(activity.id).map((option) => option.label),
        ['Too little', 'Normal', 'Too much'],
      );
      expect(log.value, 2);
      expect(log.creditsEarned, 2);
    });

    test(
      'treats not doing a bad habit as positive and doing it as negative',
      () {
        final activity = data.createRecurringActivity(
          title: 'Avoid late scrolling',
          startDate: today,
          categoryId: 'category-bad-habit',
          activityType: ActivityType.negative,
          trackingType: TrackingType.boolean,
          baseCredit: 1,
        );

        final avoidedLog = data.saveActivityLog(
          activityId: activity.id,
          date: today,
          status: DailyLogStatus.completed,
        );
        final happenedLog = data.saveActivityLog(
          activityId: activity.id,
          date: today,
          status: DailyLogStatus.missed,
        );

        expect(avoidedLog.creditsEarned, greaterThan(0));
        expect(happenedLog.creditsEarned, lessThan(0));
      },
    );

    test('saves sleep check-ins and removes daily logs', () {
      final checkIn = data.saveDailyCheckIn(
        date: today,
        sleepMinutes: 480,
        dayNote: 'Slept well.',
      );

      data.removeActivityLog(activityId: 'activity-study', date: today);

      expect(checkIn.sleepMinutes, 480);
      expect(checkIn.dayNote, 'Slept well.');
      expect(
        data.getLogsForDate(today).map((log) => log.activityId),
        isNot(contains('activity-study')),
      );
    });

    test('pauses and reactivates reusable activities', () {
      data.setActivityActive(activityId: 'activity-study', isActive: false);

      expect(
        data.activities
            .singleWhere((activity) => activity.id == 'activity-study')
            .isActive,
        isFalse,
      );

      data.setActivityActive(activityId: 'activity-study', isActive: true);

      expect(
        data.activities
            .singleWhere((activity) => activity.id == 'activity-study')
            .isActive,
        isTrue,
      );
    });

    test('updates reusable activity configuration', () {
      final updated = data.updateReusableActivity(
        activityId: 'activity-study',
        title: 'Deep Study',
        description: 'Focused course work.',
        categoryId: 'category-study',
        activityType: ActivityType.positive,
        trackingType: TrackingType.duration,
        frequency: ScheduleFrequency.weekly,
        daysOfWeek: const [2, 4],
        expectedDurationMinutes: 45,
        baseCredit: 0,
        creditPerMinute: 0.2,
        creditPerUnit: 0,
        maxDailyCredit: 9,
        penaltyCredit: 0,
      );

      final schedule = data.scheduleForActivity('activity-study');
      final creditRule = data.creditRuleForActivity('activity-study');

      expect(updated.title, 'Deep Study');
      expect(updated.description, 'Focused course work.');
      expect(schedule?.daysOfWeek, [2, 4]);
      expect(schedule?.expectedDurationMinutes, 45);
      expect(creditRule?.creditPerMinute, 0.2);
      expect(creditRule?.maxDailyCredit, 9);
    });

    test('creates custom categories from Other activity form input', () {
      final categoryId = data.resolveCategoryId(
        categoryId: '__other_category__',
        customCategoryName: 'Music',
      );

      final activity = data.createRecurringActivity(
        title: 'Practice piano',
        startDate: today,
        categoryId: categoryId,
      );

      expect(data.categoryForActivity(activity).name, 'Music');
      expect(data.categoryForActivity(activity).code, 'music');
    });
  });
}
