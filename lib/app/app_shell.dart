import 'package:flutter/material.dart';

import '../data/mock_daymark_data.dart';
import '../features/activities/activities_screen.dart';
import '../features/daily/daily_screen.dart';
import '../features/settings/settings_screen.dart';
import 'daymark_settings.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.settings});

  final DaymarkSettings settings;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  final MockDaymarkData _data = MockDaymarkData();

  static const _destinations = <NavigationDestination>[
    NavigationDestination(
      icon: Icon(Icons.today_outlined),
      selectedIcon: Icon(Icons.today),
      label: 'Daily',
    ),
    NavigationDestination(
      icon: Icon(Icons.list_alt_outlined),
      selectedIcon: Icon(Icons.list_alt),
      label: 'Activities',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      DailyScreen(data: _data, settings: widget.settings),
      ActivitiesScreen(data: _data),
      SettingsScreen(settings: widget.settings),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: screens),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        destinations: _destinations,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}
