class ActivityCategory {
  const ActivityCategory({
    required this.id,
    required this.name,
    required this.code,
  });

  final String id;
  final String name;
  final String code;

  Map<String, Object?> toJson() {
    return {'id': id, 'name': name, 'code': code};
  }

  factory ActivityCategory.fromJson(Map<String, Object?> json) {
    return ActivityCategory(
      id: json['id']! as String,
      name: json['name']! as String,
      code: json['code']! as String,
    );
  }
}
