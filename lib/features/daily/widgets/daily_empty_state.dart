import 'package:flutter/material.dart';

import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/primary_action_button.dart';
import '../daily_filter.dart';

class DailyEmptyState extends StatelessWidget {
  const DailyEmptyState({
    super.key,
    required this.isFutureDate,
    required this.filter,
    required this.onAction,
  });

  final bool isFutureDate;
  final DailyFilter filter;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: _icon,
      title: _title,
      message: _message,
      action: _showAction
          ? PrimaryActionButton(
              onPressed: onAction,
              icon: Icons.add,
              label: isFutureDate ? '+ Add Activity' : '+ Log Activity',
            )
          : null,
    );
  }

  IconData get _icon {
    return switch (filter) {
      DailyFilter.completed => Icons.check_circle_outline,
      DailyFilter.missed => Icons.favorite_border,
      DailyFilter.toDo => Icons.inbox_outlined,
      DailyFilter.all => Icons.event_available_outlined,
    };
  }

  String get _title {
    return switch (filter) {
      DailyFilter.all =>
        isFutureDate
            ? 'No activities planned for this day.'
            : 'No activities logged for this day.',
      DailyFilter.toDo =>
        isFutureDate
            ? 'Nothing waiting on this day.'
            : 'Nothing left for this day.',
      DailyFilter.completed => 'Nothing completed here yet.',
      DailyFilter.missed => 'Nothing missed here.',
    };
  }

  String get _message {
    return switch (filter) {
      DailyFilter.all =>
        isFutureDate
            ? 'Add something when you are ready.'
            : 'A lighter day is okay.',
      DailyFilter.toDo =>
        isFutureDate
            ? 'This day is open unless you want to plan something.'
            : 'You are clear for now.',
      DailyFilter.completed =>
        isFutureDate
            ? 'Future days can be planned, but not completed yet.'
            : 'Completed activities will show up here.',
      DailyFilter.missed => 'That is a good sign.',
    };
  }

  bool get _showAction {
    return filter == DailyFilter.all || filter == DailyFilter.toDo;
  }
}
