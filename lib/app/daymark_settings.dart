import 'package:flutter/material.dart';

enum DaymarkThemePreference { system, light, dark }

enum WeekStartPreference { saturday, sunday, monday }

class DaymarkSettings extends ChangeNotifier {
  DaymarkThemePreference _themePreference = DaymarkThemePreference.system;
  WeekStartPreference _weekStartPreference = WeekStartPreference.monday;
  bool _dailyReminderEnabled = false;
  TimeOfDay _dailyReminderTime = const TimeOfDay(hour: 21, minute: 0);
  bool _askAboutUnusualWeeks = true;
  bool _showDailyScore = true;

  DaymarkThemePreference get themePreference => _themePreference;
  WeekStartPreference get weekStartPreference => _weekStartPreference;
  bool get dailyReminderEnabled => _dailyReminderEnabled;
  TimeOfDay get dailyReminderTime => _dailyReminderTime;
  bool get askAboutUnusualWeeks => _askAboutUnusualWeeks;
  bool get showDailyScore => _showDailyScore;

  ThemeMode get themeMode {
    return switch (_themePreference) {
      DaymarkThemePreference.system => ThemeMode.system,
      DaymarkThemePreference.light => ThemeMode.light,
      DaymarkThemePreference.dark => ThemeMode.dark,
    };
  }

  void setThemePreference(DaymarkThemePreference value) {
    if (_themePreference == value) {
      return;
    }
    _themePreference = value;
    notifyListeners();
  }

  void setWeekStartPreference(WeekStartPreference value) {
    if (_weekStartPreference == value) {
      return;
    }
    _weekStartPreference = value;
    notifyListeners();
  }

  void setDailyReminderEnabled(bool value) {
    if (_dailyReminderEnabled == value) {
      return;
    }
    _dailyReminderEnabled = value;
    notifyListeners();
  }

  void setDailyReminderTime(TimeOfDay value) {
    if (_dailyReminderTime == value) {
      return;
    }
    _dailyReminderTime = value;
    notifyListeners();
  }

  void setAskAboutUnusualWeeks(bool value) {
    if (_askAboutUnusualWeeks == value) {
      return;
    }
    _askAboutUnusualWeeks = value;
    notifyListeners();
  }

  void setShowDailyScore(bool value) {
    if (_showDailyScore == value) {
      return;
    }
    _showDailyScore = value;
    notifyListeners();
  }
}

String themePreferenceLabel(DaymarkThemePreference preference) {
  return switch (preference) {
    DaymarkThemePreference.system => 'System default',
    DaymarkThemePreference.light => 'Light',
    DaymarkThemePreference.dark => 'Dark',
  };
}

String weekStartPreferenceLabel(WeekStartPreference preference) {
  return switch (preference) {
    WeekStartPreference.saturday => 'Saturday',
    WeekStartPreference.sunday => 'Sunday',
    WeekStartPreference.monday => 'Monday',
  };
}
