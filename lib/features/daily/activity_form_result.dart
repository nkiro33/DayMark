import '../../models/models.dart';

class ActivityFormResult {
  const ActivityFormResult({
    required this.title,
    this.description,
    required this.categoryId,
    this.customCategoryName,
    required this.activityType,
    required this.trackingType,
    required this.baseCredit,
    required this.creditPerMinute,
    required this.creditPerUnit,
    this.maxDailyCredit,
    required this.penaltyCredit,
    required this.frequency,
    required this.daysOfWeek,
    this.categoricalOptions = const [],
    this.expectedDurationMinutes,
  });

  final String title;
  final String? description;
  final String categoryId;
  final String? customCategoryName;
  final ActivityType activityType;
  final TrackingType trackingType;
  final double baseCredit;
  final double creditPerMinute;
  final double creditPerUnit;
  final double? maxDailyCredit;
  final double penaltyCredit;
  final ScheduleFrequency frequency;
  final List<int> daysOfWeek;
  final List<ActivityOptionInput> categoricalOptions;
  final int? expectedDurationMinutes;
}
