import 'package:flutter/material.dart';

import 'app_shell.dart';

class DaymarkApp extends StatelessWidget {
  const DaymarkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daymark',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F8F7B),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAF7),
        appBarTheme: const AppBarTheme(centerTitle: false),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(color: Color(0xFFE3E8E2)),
          ),
        ),
      ),
      home: const AppShell(),
    );
  }
}
