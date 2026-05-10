import 'enums.dart';

class WeeklyReflection {
  const WeeklyReflection({
    required this.id,
    required this.userId,
    required this.weeklySummaryId,
    required this.reflectionType,
    this.reasons = const [],
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String weeklySummaryId;
  final WeeklyReflectionType reflectionType;
  final List<String> reasons;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'weekly_summary_id': weeklySummaryId,
      'reflection_type': reflectionType.jsonName,
      'reasons': reasons,
      'note': note,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory WeeklyReflection.fromJson(Map<String, Object?> json) {
    return WeeklyReflection(
      id: json['id']! as String,
      userId: json['user_id']! as String,
      weeklySummaryId: json['weekly_summary_id']! as String,
      reflectionType: enumFromJsonName(
        WeeklyReflectionType.values,
        json['reflection_type']! as String,
      ),
      reasons: List<String>.from(json['reasons']! as List),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at']! as String),
      updatedAt: DateTime.parse(json['updated_at']! as String),
    );
  }
}
