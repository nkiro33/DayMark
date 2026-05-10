import 'package:flutter/material.dart';

class DailyScreen extends StatelessWidget {
  const DailyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderScaffold(
      title: 'Daily',
      icon: Icons.today,
      message: 'Ready to log your day?',
      detail: 'Daily activity logging will be added in a later step.',
    );
  }
}

class _PlaceholderScaffold extends StatelessWidget {
  const _PlaceholderScaffold({
    required this.title,
    required this.icon,
    required this.message,
    required this.detail,
  });

  final String title;
  final IconData icon;
  final String message;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 32),
                const SizedBox(height: 16),
                Text(message, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(detail, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
