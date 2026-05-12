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
          builder: (context, child) {
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: child,
            );
          },
          home: AppShell(settings: _settings),
        );
      },
    );
  }
}

ThemeData _daymarkTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  const primary = Color(0xFFCFBCFF);
  final colorScheme = ColorScheme.fromSeed(
    seedColor: primary,
    brightness: brightness,
    primary: primary,
  );
  final scaffoldBackground = isDark
      ? const Color(0xFF141218)
      : const Color(0xFFF8F6FF);
  final cardColor = isDark ? const Color(0xFF211F24) : Colors.white;

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: scaffoldBackground,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: scaffoldBackground,
      foregroundColor: isDark
          ? const Color(0xFFE6E0E9)
          : const Color(0xFF1D1B20),
      titleTextStyle: TextStyle(
        color: isDark ? primary : const Color(0xFF4F378A),
        fontSize: 28,
        fontWeight: FontWeight.w800,
        height: 1.2,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: cardColor,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(24)),
        side: BorderSide(
          color: isDark ? const Color(0xFF494551) : const Color(0xFFE7E0EF),
        ),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 76,
      backgroundColor: isDark ? const Color(0xE6211F24) : Colors.white,
      indicatorColor: isDark
          ? const Color(0xFF6750A4)
          : const Color(0xFFEADDFF),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w600,
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: const Color(0xFF381E72),
      elevation: 12,
      shape: const CircleBorder(),
      sizeConstraints: const BoxConstraints.tightFor(width: 72, height: 72),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: isDark
          ? const Color(0xFF2B292F)
          : const Color(0xFFF0ECF5),
      selectedColor: primary,
      checkmarkColor: isDark
          ? const Color(0xFF381E72)
          : const Color(0xFF381E72),
      labelStyle: TextStyle(
        color: isDark ? const Color(0xFFE6E0E9) : const Color(0xFF322F35),
        fontWeight: FontWeight.w700,
      ),
      side: BorderSide(
        color: isDark ? const Color(0xFF494551) : const Color(0xFFE7E0EF),
      ),
      shape: const StadiumBorder(),
    ),
  );
}
