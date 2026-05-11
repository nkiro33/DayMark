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
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final filter in DailyFilter.values)
          FilterChip(
            label: Text(filterLabel(filter)),
            selected: selectedFilter == filter,
            onSelected: (_) => onSelected(filter),
          ),
      ],
    );
  }
}
