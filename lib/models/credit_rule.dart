class CreditRule {
  const CreditRule({
    required this.id,
    required this.activityId,
    this.baseCredit = 0,
    this.creditPerMinute = 0,
    this.creditPerUnit = 0,
    this.maxDailyCredit,
    this.penaltyCredit = 0,
  });

  final String id;
  final String activityId;
  final double baseCredit;
  final double creditPerMinute;
  final double creditPerUnit;
  final double? maxDailyCredit;
  final double penaltyCredit;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'activity_id': activityId,
      'base_credit': baseCredit,
      'credit_per_minute': creditPerMinute,
      'credit_per_unit': creditPerUnit,
      'max_daily_credit': maxDailyCredit,
      'penalty_credit': penaltyCredit,
    };
  }

  factory CreditRule.fromJson(Map<String, Object?> json) {
    return CreditRule(
      id: json['id']! as String,
      activityId: json['activity_id']! as String,
      baseCredit: (json['base_credit']! as num).toDouble(),
      creditPerMinute: (json['credit_per_minute']! as num).toDouble(),
      creditPerUnit: (json['credit_per_unit']! as num).toDouble(),
      maxDailyCredit: (json['max_daily_credit'] as num?)?.toDouble(),
      penaltyCredit: (json['penalty_credit']! as num).toDouble(),
    );
  }
}
