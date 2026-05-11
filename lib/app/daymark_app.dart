import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'daymark_settings.dart';

class DaymarkApp extends StatefulWidget {
  const DaymarkApp({super.key});

  @override
  State<DaymarkApp> createState() => _DaymarkAppState();
}

class _DaymarkAppState extends State<DaymarkApp> {
  final DaymarkSettings _settings = DaymarkSettings();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _settings,
      builder: (context, _) {
        return MaterialApp(
          title: 'Daymark',
          debugShowCheckedModeBanner: false,
          themeMode: _settings.themeMode,
          theme: _daymarkTheme(Brightness.light),
          darkTheme: _daymarkTheme(Brightness.dark),
          home: AppShell(settings: _settings),
        );
      },
    );
  }
}

ThemeData _daymarkTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF4F8F7B),
    brightness: brightness,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: isDark
        ? const Color(0xFF121714)
        : const Color(0xFFF8FAF7),
    appBarTheme: const AppBarTheme(centerTitle: false),
    cardTheme: CardThemeData(
      elevation: 0,
      color: isDark ? const Color(0xFF1A211D) : Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        side: BorderSide(
          color: isDark ? const Color(0xFF334038) : const Color(0xFFE3E8E2),
        ),
      ),
    ),
  );
}
