import 'package:flutter/material.dart';

import '../daily_formatters.dart';
import '../../../shared/widgets/primary_action_button.dart';

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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(titleForDate(selectedDate, today)),
      actions: [
        IconButton(
          onPressed: onOpenCalendar,
          tooltip: 'Open calendar',
          icon: const Icon(Icons.calendar_month_outlined),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: PrimaryActionButton(
            key: const ValueKey('daily-primary-action'),
            onPressed: onPrimaryAction,
            icon: isFutureDate ? Icons.add : Icons.add_task,
            label: isFutureDate ? '+ Add' : '+ Log',
          ),
        ),
      ],
    );
  }
}
