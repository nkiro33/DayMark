import 'enums.dart';

class ActivityTemplate {
  const ActivityTemplate({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.title,
    this.description,
    required this.activityType,
    required this.trackingType,
    required this.activityScope,
    this.isActive = true,
    this.startDate,
    this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String categoryId;
  final String title;
  final String? description;
  final ActivityType activityType;
  final TrackingType trackingType;
  final ActivityScope activityScope;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'activity_type': activityType.jsonName,
      'tracking_type': trackingType.jsonName,
      'activity_scope': activityScope.jsonName,
      'is_active': isActive,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ActivityTemplate.fromJson(Map<String, Object?> json) {
    return ActivityTemplate(
      id: json['id']! as String,
      userId: json['user_id']! as String,
      categoryId: json['category_id']! as String,
      title: json['title']! as String,
      description: json['description'] as String?,
      activityType: enumFromJsonName(
        ActivityType.values,
        json['activity_type']! as String,
      ),
      trackingType: enumFromJsonName(
        TrackingType.values,
        json['tracking_type']! as String,
      ),
      activityScope: enumFromJsonName(
        ActivityScope.values,
        json['activity_scope']! as String,
      ),
      isActive: json['is_active']! as bool,
      startDate: _parseOptionalDate(json['start_date']),
      endDate: _parseOptionalDate(json['end_date']),
      createdAt: DateTime.parse(json['created_at']! as String),
      updatedAt: DateTime.parse(json['updated_at']! as String),
    );
  }
}

DateTime? _parseOptionalDate(Object? value) {
  return value == null ? null : DateTime.parse(value as String);
}
