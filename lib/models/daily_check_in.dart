class DailyCheckIn {
  const DailyCheckIn({
    required this.id,
    required this.userId,
    required this.date,
    this.sleepHours,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final DateTime date;
  final double? sleepHours;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String(),
      'sleep_hours': sleepHours,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory DailyCheckIn.fromJson(Map<String, Object?> json) {
    return DailyCheckIn(
      id: json['id']! as String,
      userId: json['user_id']! as String,
      date: DateTime.parse(json['date']! as String),
      sleepHours: (json['sleep_hours'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at']! as String),
      updatedAt: DateTime.parse(json['updated_at']! as String),
    );
  }
}
