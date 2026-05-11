class DailyCheckIn {
  const DailyCheckIn({
    required this.id,
    required this.userId,
    required this.date,
    this.sleepMinutes,
    this.dayNote,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final DateTime date;
  final int? sleepMinutes;
  final String? dayNote;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String(),
      'sleep_minutes': sleepMinutes,
      'day_note': dayNote,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory DailyCheckIn.fromJson(Map<String, Object?> json) {
    return DailyCheckIn(
      id: json['id']! as String,
      userId: json['user_id']! as String,
      date: DateTime.parse(json['date']! as String),
      sleepMinutes: _parseSleepMinutes(json),
      dayNote: json['day_note'] as String?,
      createdAt: DateTime.parse(json['created_at']! as String),
      updatedAt: DateTime.parse(json['updated_at']! as String),
    );
  }
}

int? _parseSleepMinutes(Map<String, Object?> json) {
  final minutes = json['sleep_minutes'];
  if (minutes != null) {
    return minutes as int;
  }

  final legacyHours = json['sleep_hours'] as num?;
  return legacyHours == null ? null : (legacyHours * 60).round();
}
