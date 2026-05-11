import '../../models/models.dart';

class DailyLogRequest {
  const DailyLogRequest({
    required this.status,
    this.value,
    this.durationMinutes,
    this.notes,
  });

  final DailyLogStatus status;
  final double? value;
  final int? durationMinutes;
  final String? notes;
}
