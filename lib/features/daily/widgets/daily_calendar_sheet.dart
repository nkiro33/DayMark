import 'package:flutter/material.dart';

import '../../../data/mock_daymark_data.dart';
import '../daily_formatters.dart';

class DailyCalendarSheet extends StatefulWidget {
  const DailyCalendarSheet({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.summaryForDate,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final DailySummary Function(DateTime date) summaryForDate;

  @override
  State<DailyCalendarSheet> createState() => _DailyCalendarSheetState();
}

class _DailyCalendarSheetState extends State<DailyCalendarSheet> {
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    _visibleMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final monthStart = DateTime(_visibleMonth.year, _visibleMonth.month);
    final daysInMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month + 1,
      0,
    ).day;
    final leadingBlanks = monthStart.weekday - 1;
    final cellCount = leadingBlanks + daysInMonth;
    final rowCount = (cellCount / 7).ceil();

    return SafeArea(
      child: Container(
        color: colorScheme.surface,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: _canMoveMonth(-1) ? () => _moveMonth(-1) : null,
                  icon: const Icon(Icons.chevron_left),
                  tooltip: 'Previous month',
                ),
                Expanded(
                  child: Text(
                    '${monthShort(monthStart)} ${monthStart.year}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _canMoveMonth(1) ? () => _moveMonth(1) : null,
                  icon: const Icon(Icons.chevron_right),
                  tooltip: 'Next month',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final label in const ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
                  Expanded(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            for (var row = 0; row < rowCount; row++) ...[
              Row(
                children: [
                  for (var column = 0; column < 7; column++)
                    Expanded(
                      child: _CalendarCell(
                        date: _dateForCell(
                          row: row,
                          column: column,
                          leadingBlanks: leadingBlanks,
                          daysInMonth: daysInMonth,
                        ),
                        selectedDate: widget.initialDate,
                        firstDate: widget.firstDate,
                        lastDate: widget.lastDate,
                        summaryForDate: widget.summaryForDate,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }

  DateTime? _dateForCell({
    required int row,
    required int column,
    required int leadingBlanks,
    required int daysInMonth,
  }) {
    final day = row * 7 + column - leadingBlanks + 1;
    if (day < 1 || day > daysInMonth) {
      return null;
    }
    return DateTime(_visibleMonth.year, _visibleMonth.month, day);
  }

  bool _canMoveMonth(int delta) {
    final next = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    final firstMonth = DateTime(widget.firstDate.year, widget.firstDate.month);
    final lastMonth = DateTime(widget.lastDate.year, widget.lastDate.month);
    return !next.isBefore(firstMonth) && !next.isAfter(lastMonth);
  }

  void _moveMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }
}

class _CalendarCell extends StatelessWidget {
  const _CalendarCell({
    required this.date,
    required this.selectedDate,
    required this.firstDate,
    required this.lastDate,
    required this.summaryForDate,
  });

  final DateTime? date;
  final DateTime selectedDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final DailySummary Function(DateTime date) summaryForDate;

  @override
  Widget build(BuildContext context) {
    if (date == null) {
      return const SizedBox(height: 48);
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final disabled =
        date!.isBefore(_dateOnly(firstDate)) ||
        date!.isAfter(_dateOnly(lastDate));
    final selected = isSameDate(date!, selectedDate);
    final summary = summaryForDate(date!);
    final progress = summary.expectedCredits <= 0
        ? 0.0
        : (summary.earnedCredits / summary.expectedCredits)
              .clamp(0.0, 1.0)
              .toDouble();

    return SizedBox(
      height: 48,
      child: InkWell(
        onTap: disabled ? null : () => Navigator.of(context).pop(date),
        borderRadius: BorderRadius.circular(999),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.square(
              dimension: 42,
              child: CircularProgressIndicator(
                value: 1,
                strokeWidth: selected ? 2.6 : 2,
                color: selected
                    ? colorScheme.primary.withValues(alpha: 0.30)
                    : colorScheme.outlineVariant.withValues(alpha: 0.38),
              ),
            ),
            if (progress > 0)
              SizedBox.square(
                dimension: 42,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 2.8,
                  strokeCap: StrokeCap.round,
                  color: colorScheme.primary,
                ),
              ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: selected ? 34 : 32,
              height: selected ? 34 : 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? colorScheme.primaryContainer : null,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${date!.day}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: disabled
                      ? colorScheme.onSurface.withValues(alpha: 0.28)
                      : selected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
