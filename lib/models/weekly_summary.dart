import 'enums.dart';

class WeeklySummary {
  const WeeklySummary({
    required this.id,
    required this.userId,
    required this.weekStartDate,
    required this.weekEndDate,
    this.totalCredits = 0,
    this.positiveCredits = 0,
    this.negativeCredits = 0,
    this.completedCount = 0,
    this.missedCount = 0,
    this.partialCount = 0,
    this.averageSleepMinutes,
    this.scoreChangeFromPreviousWeek = 0,
    this.changeType = WeeklyChangeType.normal,
    this.reflectionRequested = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final DateTime weekStartDate;
  final DateTime weekEndDate;
  final double totalCredits;
  final double positiveCredits;
  final double negativeCredits;
  final int completedCount;
  final int missedCount;
  final int partialCount;
  final double? averageSleepMinutes;
  final double scoreChangeFromPreviousWeek;
  final WeeklyChangeType changeType;
  final bool reflectionRequested;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'week_start_date': weekStartDate.toIso8601String(),
      'week_end_date': weekEndDate.toIso8601String(),
      'total_credits': totalCredits,
      'positive_credits': positiveCredits,
      'negative_credits': negativeCredits,
      'completed_count': completedCount,
      'missed_count': missedCount,
      'partial_count': partialCount,
      'average_sleep_minutes': averageSleepMinutes,
      'score_change_from_previous_week': scoreChangeFromPreviousWeek,
      'change_type': changeType.jsonName,
      'reflection_requested': reflectionRequested,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory WeeklySummary.fromJson(Map<String, Object?> json) {
    return WeeklySummary(
      id: json['id']! as String,
      userId: json['user_id']! as String,
      weekStartDate: DateTime.parse(json['week_start_date']! as String),
      weekEndDate: DateTime.parse(json['week_end_date']! as String),
      totalCredits: (json['total_credits']! as num).toDouble(),
      positiveCredits: (json['positive_credits']! as num).toDouble(),
      negativeCredits: (json['negative_credits']! as num).toDouble(),
      completedCount: json['completed_count']! as int,
      missedCount: json['missed_count']! as int,
      partialCount: json['partial_count']! as int,
      averageSleepMinutes: _parseAverageSleepMinutes(json),
      scoreChangeFromPreviousWeek:
          (json['score_change_from_previous_week']! as num).toDouble(),
      changeType: enumFromJsonName(
        WeeklyChangeType.values,
        json['change_type']! as String,
      ),
      reflectionRequested: json['reflection_requested']! as bool,
      createdAt: DateTime.parse(json['created_at']! as String),
      updatedAt: DateTime.parse(json['updated_at']! as String),
    );
  }
}

double? _parseAverageSleepMinutes(Map<String, Object?> json) {
  final minutes = json['average_sleep_minutes'] as num?;
  if (minutes != null) {
    return minutes.toDouble();
  }

  final legacyHours = json['average_sleep_hours'] as num?;
  return legacyHours == null ? null : legacyHours.toDouble() * 60;
}
