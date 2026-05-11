import 'package:flutter/material.dart';

import '../../app/daymark_settings.dart';
import 'widgets/settings_row.dart';
import 'widgets/settings_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.settings});

  final DaymarkSettings settings;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              SettingsSection(
                title: 'Appearance',
                children: [
                  SettingsRow(
                    icon: Icons.contrast_outlined,
                    title: 'Theme',
                    subtitle: themePreferenceLabel(settings.themePreference),
                    trailing: const Icon(Icons.expand_more),
                    onTap: () => _showThemeSheet(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SettingsSection(
                title: 'Calendar',
                children: [
                  SettingsRow(
                    icon: Icons.calendar_month_outlined,
                    title: 'Week starts on',
                    subtitle: weekStartPreferenceLabel(
                      settings.weekStartPreference,
                    ),
                    trailing: const Icon(Icons.expand_more),
                    onTap: () => _showWeekStartSheet(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SettingsSection(
                title: 'Reminders',
                children: [
                  SwitchListTile(
                    key: const ValueKey('daily-reminder-switch'),
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.notifications_none_outlined),
                    title: const Text('Daily reminder'),
                    subtitle: Text(
                      settings.dailyReminderEnabled
                          ? 'At ${settings.dailyReminderTime.format(context)}'
                          : 'Off',
                    ),
                    value: settings.dailyReminderEnabled,
                    onChanged: settings.setDailyReminderEnabled,
                  ),
                  SettingsRow(
                    icon: Icons.schedule_outlined,
                    title: 'Reminder time',
                    subtitle: settings.dailyReminderTime.format(context),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: settings.dailyReminderEnabled
                        ? () => _pickReminderTime(context)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SettingsSection(
                title: 'Reflections',
                children: [
                  SwitchListTile(
                    key: const ValueKey('unusual-weeks-switch'),
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.rate_review_outlined),
                    title: const Text('Ask about unusual weeks'),
                    subtitle: const Text(
                      'A short prompt when a week looks different.',
                    ),
                    value: settings.askAboutUnusualWeeks,
                    onChanged: settings.setAskAboutUnusualWeeks,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SettingsSection(
                title: 'Scoring',
                children: [
                  SwitchListTile(
                    key: const ValueKey('daily-score-switch'),
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.toll_outlined),
                    title: const Text('Show daily score'),
                    subtitle: const Text(
                      'Hide scores if they feel distracting.',
                    ),
                    value: settings.showDailyScore,
                    onChanged: settings.setShowDailyScore,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showThemeSheet(BuildContext context) {
    _showChoiceSheet<DaymarkThemePreference>(
      context: context,
      title: 'Theme',
      selectedValue: settings.themePreference,
      values: DaymarkThemePreference.values,
      labelForValue: themePreferenceLabel,
      onSelected: settings.setThemePreference,
    );
  }

  void _showWeekStartSheet(BuildContext context) {
    _showChoiceSheet<WeekStartPreference>(
      context: context,
      title: 'Week starts on',
      selectedValue: settings.weekStartPreference,
      values: WeekStartPreference.values,
      labelForValue: weekStartPreferenceLabel,
      onSelected: settings.setWeekStartPreference,
    );
  }

  void _showChoiceSheet<T>({
    required BuildContext context,
    required String title,
    required T selectedValue,
    required List<T> values,
    required String Function(T value) labelForValue,
    required ValueChanged<T> onSelected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              for (final value in values)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(labelForValue(value)),
                  trailing: value == selectedValue
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    Navigator.of(context).pop();
                    onSelected(value);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickReminderTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: settings.dailyReminderTime,
    );
    if (picked == null) {
      return;
    }
    settings.setDailyReminderTime(picked);
  }
}
