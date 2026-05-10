import 'enums.dart';

class DailyActivityLog {
  const DailyActivityLog({
    required this.id,
    required this.userId,
    required this.activityId,
    required this.date,
    required this.status,
    this.value,
    this.durationMinutes,
    this.notes,
    this.creditsEarned = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String activityId;
  final DateTime date;
  final DailyLogStatus status;
  final double? value;
  final int? durationMinutes;
  final String? notes;
  final double creditsEarned;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'activity_id': activityId,
      'date': date.toIso8601String(),
      'status': status.jsonName,
      'value': value,
      'duration_minutes': durationMinutes,
      'notes': notes,
      'credits_earned': creditsEarned,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory DailyActivityLog.fromJson(Map<String, Object?> json) {
    return DailyActivityLog(
      id: json['id']! as String,
      userId: json['user_id']! as String,
      activityId: json['activity_id']! as String,
      date: DateTime.parse(json['date']! as String),
      status: enumFromJsonName(
        DailyLogStatus.values,
        json['status']! as String,
      ),
      value: (json['value'] as num?)?.toDouble(),
      durationMinutes: json['duration_minutes'] as int?,
      notes: json['notes'] as String?,
      creditsEarned: (json['credits_earned']! as num).toDouble(),
      createdAt: DateTime.parse(json['created_at']! as String),
      updatedAt: DateTime.parse(json['updated_at']! as String),
    );
  }
}
