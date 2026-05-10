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
      expect(data.categories, hasLength(5));
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
  });
}
