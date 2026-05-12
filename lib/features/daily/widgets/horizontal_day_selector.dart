import 'package:flutter/material.dart';

import '../../../data/mock_daymark_data.dart';
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
      height: 68,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
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
    final normalizedProgress = progress.clamp(0.0, 1.0);
    final dayLabel = weekdayShort(date).substring(0, 1).toUpperCase();

    return SizedBox(
      key: ValueKey('day-selector-${dateKey(date)}'),
      width: 50,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Column(
          children: [
            Text(
              dayLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            SizedBox.square(
              dimension: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (isSelected)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.38),
                            blurRadius: 18,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const SizedBox.expand(),
                    ),
                  CircularProgressIndicator(
                    value: 1,
                    strokeWidth: isSelected ? 2.5 : 2,
                    color: isSelected
                        ? colorScheme.primary.withValues(alpha: 0.34)
                        : colorScheme.outlineVariant.withValues(alpha: 0.42),
                  ),
                  if (normalizedProgress > 0)
                    CircularProgressIndicator(
                      value: normalizedProgress,
                      strokeWidth: 2.6,
                      strokeCap: StrokeCap.round,
                      color: colorScheme.primary,
                    ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: isSelected ? 36 : 34,
                    height: isSelected ? 36 : 34,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primaryContainer
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${date.day}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: isSelected
                            ? colorScheme.onPrimaryContainer
                            : normalizedProgress == 0
                            ? colorScheme.onSurface.withValues(alpha: 0.56)
                            : colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
