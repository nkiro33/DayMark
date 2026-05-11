import 'package:flutter/material.dart';

import '../../../data/mock_daymark_data.dart';
import '../../../shared/widgets/productivity_ring.dart';
import '../daily_formatters.dart';

class HorizontalDaySelector extends StatelessWidget {
  const HorizontalDaySelector({
    super.key,
    required this.today,
    required this.selectedDate,
    required this.summaryForDate,
    required this.onDateSelected,
  });

  final DateTime today;
  final DateTime selectedDate;
  final DailySummary Function(DateTime date) summaryForDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final dates = List.generate(
      7,
      (index) => today.subtract(Duration(days: 3 - index)),
    );

    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final date = dates[index];
          final summary = summaryForDate(date);
          final progress = summary.expectedCredits <= 0
              ? 0.0
              : summary.earnedCredits / summary.expectedCredits;
          return _DaySelectorItem(
            date: date,
            progress: progress,
            isSelected: isSameDate(date, selectedDate),
            onTap: () => onDateSelected(date),
          );
        },
      ),
    );
  }
}

class _DaySelectorItem extends StatelessWidget {
  const _DaySelectorItem({
    required this.date,
    required this.progress,
    required this.isSelected,
    required this.onTap,
  });

  final DateTime date;
  final double progress;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        key: ValueKey('day-selector-${dateKey(date)}'),
        duration: const Duration(milliseconds: 160),
        width: 68,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colorScheme.primary : const Color(0xFFE3E8E2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(weekdayShort(date), style: theme.textTheme.labelMedium),
            Text('${date.day}', style: theme.textTheme.titleMedium),
            ProductivityRing(
              progress: progress,
              size: 22,
              strokeWidth: 4,
              showPercent: false,
            ),
          ],
        ),
      ),
    );
  }
}
