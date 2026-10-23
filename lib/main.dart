import 'package:flutter/material.dart';
import 'package:money_dashboard/design/theme_constants.dart';
import 'package:money_dashboard/home/home_container.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ThemeMode>(
    valueListenable: appThemeMode,
    builder: (_, mode, __) => MaterialApp(
      title: 'Finance Dashboard',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: mode,
      home: const HomeContainer(),
    ),
  );
}
