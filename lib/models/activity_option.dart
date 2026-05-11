class ActivityOption {
  const ActivityOption({
    required this.id,
    required this.activityId,
    required this.label,
    required this.value,
    required this.creditValue,
    required this.sortOrder,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String activityId;
  final String label;
  final double value;
  final double creditValue;
  final int sortOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'activity_id': activityId,
      'label': label,
      'value': value,
      'credit_value': creditValue,
      'sort_order': sortOrder,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory ActivityOption.fromJson(Map<String, Object?> json) {
    return ActivityOption(
      id: json['id']! as String,
      activityId: json['activity_id']! as String,
      label: json['label']! as String,
      value: (json['value']! as num).toDouble(),
      creditValue: (json['credit_value']! as num).toDouble(),
      sortOrder: json['sort_order']! as int,
      createdAt: _parseOptionalDate(json['created_at']),
      updatedAt: _parseOptionalDate(json['updated_at']),
    );
  }
}

class ActivityOptionInput {
  const ActivityOptionInput({
    required this.label,
    required this.value,
    required this.creditValue,
  });

  final String label;
  final double value;
  final double creditValue;
}

DateTime? _parseOptionalDate(Object? value) {
  return value == null ? null : DateTime.parse(value as String);
}
