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
      expect(data.categories, hasLength(6));
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
      expect(data.dailyCheckIns.single.sleepHours, 7.5);
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
      expect(summary.expectedCredits, greaterThan(0));
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

    test('saves sleep check-ins and removes daily logs', () {
      final checkIn = data.saveDailyCheckIn(date: today, sleepHours: 8);

      data.removeActivityLog(activityId: 'activity-study', date: today);

      expect(checkIn.sleepHours, 8);
      expect(
        data.getLogsForDate(today).map((log) => log.activityId),
        isNot(contains('activity-study')),
      );
    });
  });
}
