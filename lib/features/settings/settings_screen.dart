import 'package:flutter/material.dart';

import 'widgets/settings_row.dart';
import 'widgets/settings_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: SettingsSection(
          title: 'Keep Daymark comfortable.',
          children: [
            SettingsRow(
              icon: Icons.settings,
              title: 'Simple preferences',
              subtitle: 'App settings will be added in a later step.',
            ),
          ],
        ),
      ),
    );
  }
}
