import 'package:flutter/material.dart';

import '../daily_filter.dart';
import '../daily_formatters.dart';

class DailyFilterChips extends StatelessWidget {
  const DailyFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onSelected,
  });

  final DailyFilter selectedFilter;
  final ValueChanged<DailyFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        for (final filter in DailyFilter.values)
          FilterChip(
            label: Text(filterLabel(filter)),
            selected: selectedFilter == filter,
            onSelected: (_) => onSelected(filter),
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            labelStyle: TextStyle(
              color: selectedFilter == filter
                  ? colorScheme.onPrimary
                  : colorScheme.onSurface,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
            backgroundColor: colorScheme.surfaceContainerHigh,
            selectedColor: colorScheme.primary,
            side: BorderSide(
              color: selectedFilter == filter
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.06),
            ),
          ),
      ],
    );
  }
}
