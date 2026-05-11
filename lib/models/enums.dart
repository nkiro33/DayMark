enum ActivityType { positive, negative, neutral }

enum TrackingType { boolean, duration, quantity, level, milestone, categorical }

enum ActivityScope { recurring, manual, oneTime }

enum ScheduleFrequency { daily, weekly, custom, manual }

enum DailyLogStatus {
  planned,
  completed,
  partiallyCompleted,
  missed,
  skipped,
  notApplicable,
}

enum WeeklyChangeType { normal, muchLower, muchHigher }

enum WeeklyReflectionType { positiveChange, negativeChange }

extension EnumJsonName on Enum {
  String get jsonName {
    return name.replaceAllMapped(
      RegExp('[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    );
  }
}

T enumFromJsonName<T extends Enum>(Iterable<T> values, String name) {
  return values.firstWhere((value) => value.jsonName == name);
}
