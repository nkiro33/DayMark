import 'package:flutter/material.dart';

import '../daily_formatters.dart';

class DailyHeader extends StatelessWidget implements PreferredSizeWidget {
  const DailyHeader({
    super.key,
    required this.selectedDate,
    required this.today,
    required this.isFutureDate,
    required this.onOpenCalendar,
    required this.onPrimaryAction,
  });

  final DateTime selectedDate;
  final DateTime today;
  final bool isFutureDate;
  final VoidCallback onOpenCalendar;
  final VoidCallback onPrimaryAction;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      toolbarHeight: 72,
      title: Text(titleForDate(selectedDate, today)),
      actions: [
        IconButton(
          onPressed: onOpenCalendar,
          tooltip: 'Open calendar',
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.44,
            ),
            foregroundColor: colorScheme.onSurfaceVariant,
          ),
          icon: const Icon(Icons.calendar_today_outlined),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Daily reminders are managed in Settings.'),
                ),
              );
            },
            tooltip: 'Reminder settings',
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.44,
              ),
              foregroundColor: colorScheme.onSurfaceVariant,
            ),
            icon: const Icon(Icons.notifications_none_outlined),
          ),
        ),
      ],
    );
  }
}
