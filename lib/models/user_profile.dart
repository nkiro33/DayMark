class UserProfile {
  const UserProfile({
    required this.id,
    this.displayName,
    required this.timezone,
    this.onboardingCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String? displayName;
  final String timezone;
  final bool onboardingCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'timezone': timezone,
      'onboarding_completed': onboardingCompleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, Object?> json) {
    return UserProfile(
      id: json['id']! as String,
      displayName: json['display_name'] as String?,
      timezone: json['timezone']! as String,
      onboardingCompleted: json['onboarding_completed']! as bool,
      createdAt: DateTime.parse(json['created_at']! as String),
      updatedAt: DateTime.parse(json['updated_at']! as String),
    );
  }
}
