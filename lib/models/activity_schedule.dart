import 'enums.dart';

class ActivitySchedule {
  const ActivitySchedule({
    required this.id,
    required this.activityId,
    required this.frequency,
    this.daysOfWeek = const [],
    this.timeStart,
    this.timeEnd,
    this.expectedDurationMinutes,
  });

  final String id;
  final String activityId;
  final ScheduleFrequency frequency;
  final List<int> daysOfWeek;
  final String? timeStart;
  final String? timeEnd;
  final int? expectedDurationMinutes;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'activity_id': activityId,
      'frequency': frequency.jsonName,
      'days_of_week': daysOfWeek,
      'time_start': timeStart,
      'time_end': timeEnd,
      'expected_duration_minutes': expectedDurationMinutes,
    };
  }

  factory ActivitySchedule.fromJson(Map<String, Object?> json) {
    return ActivitySchedule(
      id: json['id']! as String,
      activityId: json['activity_id']! as String,
      frequency: enumFromJsonName(
        ScheduleFrequency.values,
        json['frequency']! as String,
      ),
      daysOfWeek: List<int>.from(json['days_of_week']! as List),
      timeStart: json['time_start'] as String?,
      timeEnd: json['time_end'] as String?,
      expectedDurationMinutes: json['expected_duration_minutes'] as int?,
    );
  }
}
