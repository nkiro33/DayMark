import 'package:flutter/material.dart';

import '../../models/models.dart';
import 'daily_filter.dart';

String titleForDate(DateTime date, DateTime today) {
  if (isSameDate(date, today)) {
    return 'Today';
  }
  return '${weekdayLong(date)}, ${date.day} ${monthShort(date)}';
}

String filterLabel(DailyFilter filter) {
  return switch (filter) {
    DailyFilter.all => 'All',
    DailyFilter.toDo => 'To do',
    DailyFilter.completed => 'Completed',
    DailyFilter.missed => 'Missed',
  };
}

String statusLabel(DailyLogStatus status) {
  return switch (status) {
    DailyLogStatus.planned => 'Planned',
    DailyLogStatus.completed => 'Completed',
    DailyLogStatus.partiallyCompleted => 'Partial',
    DailyLogStatus.missed => 'Missed',
    DailyLogStatus.skipped => 'Skipped',
    DailyLogStatus.notApplicable => 'Not needed',
  };
}

Color statusColor(DailyLogStatus status) {
  return switch (status) {
    DailyLogStatus.completed => const Color(0xFF2E7D5B),
    DailyLogStatus.partiallyCompleted => const Color(0xFF9A6A00),
    DailyLogStatus.missed || DailyLogStatus.skipped => const Color(0xFFB05A58),
    DailyLogStatus.planned ||
    DailyLogStatus.notApplicable => const Color(0xFF5D6F82),
  };
}

String trackingLabel(TrackingType trackingType) {
  return switch (trackingType) {
    TrackingType.boolean => 'Yes / No',
    TrackingType.duration => 'Duration',
    TrackingType.quantity => 'Quantity',
    TrackingType.level => 'Level',
    TrackingType.milestone => 'Milestone',
    TrackingType.categorical => 'Options',
  };
}

IconData iconForTrackingType(TrackingType trackingType) {
  return switch (trackingType) {
    TrackingType.boolean => Icons.check_circle_outline,
    TrackingType.duration => Icons.timer_outlined,
    TrackingType.quantity => Icons.pin_outlined,
    TrackingType.level => Icons.tune,
    TrackingType.milestone => Icons.flag_outlined,
    TrackingType.categorical => Icons.category_outlined,
  };
}

String creditsLabel(DailyActivityLog? log, bool isFutureDate) {
  if (isFutureDate) {
    return '0 credits planned';
  }
  if (log == null) {
    return 'Not logged yet';
  }
  return '${formatCredit(log.creditsEarned)} credits';
}

String formatCredit(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(1);
}

String weekdayShort(DateTime date) {
  return const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday -
      1];
}

String weekdayLong(DateTime date) {
  return const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ][date.weekday - 1];
}

String monthShort(DateTime date) {
  return const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][date.month - 1];
}

bool isAfterDate(DateTime a, DateTime b) {
  return DateTime(
    a.year,
    a.month,
    a.day,
  ).isAfter(DateTime(b.year, b.month, b.day));
}

bool isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String dateKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
