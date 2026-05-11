import 'package:flutter/material.dart';

import '../daily_log_request.dart';

class AddOrLogActivitySheet extends StatelessWidget {
  const AddOrLogActivitySheet({
    super.key,
    required this.isFutureDate,
    required this.onExistingActivity,
    required this.onOneTimeActivity,
    required this.onRecurringActivity,
  });

  final bool isFutureDate;
  final VoidCallback onExistingActivity;
  final VoidCallback onOneTimeActivity;
  final VoidCallback onRecurringActivity;

  @override
  Widget build(BuildContext context) {
    return ActionSheet(
      title: isFutureDate ? 'Add to this day' : 'Log activity',
      actions: [
        SheetAction(
          icon: Icons.playlist_add,
          label: isFutureDate
              ? 'Add existing activity'
              : 'Log existing activity',
          onTap: onExistingActivity,
        ),
        SheetAction(
          icon: Icons.add_circle_outline,
          label: 'Create one-time activity',
          onTap: onOneTimeActivity,
        ),
        SheetAction(
          icon: Icons.repeat,
          label: 'Create recurring activity',
          onTap: onRecurringActivity,
        ),
      ],
    );
  }
}

class ActionSheet extends StatelessWidget {
  const ActionSheet({
    super.key,
    required this.title,
    required this.actions,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<SheetAction> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: theme.textTheme.bodyMedium),
          ],
          const SizedBox(height: 12),
          for (final action in actions)
            ListTile(
              leading: Icon(action.icon),
              title: Text(action.label),
              onTap: action.onTap,
            ),
        ],
      ),
    );
  }
}

class SheetAction {
  const SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class InfoSheet extends StatelessWidget {
  const InfoSheet({super.key, required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LogChoiceSheet extends StatelessWidget {
  const LogChoiceSheet({
    super.key,
    required this.title,
    required this.choices,
    required this.onSelected,
  });

  final String title;
  final List<LogChoice> choices;
  final ValueChanged<LogChoice> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          for (final choice in choices) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: () => onSelected(choice),
                child: Text(choice.label),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class LogChoice {
  const LogChoice({required this.label, this.request});

  final String label;
  final DailyLogRequest? request;
}
