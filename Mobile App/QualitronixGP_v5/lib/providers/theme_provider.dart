import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme { original, light, dark }

class ThemeProvider extends ChangeNotifier {
  AppTheme _appTheme = AppTheme.original;

  AppTheme get appTheme => _appTheme;

  ThemeData get themeData {
    switch (_appTheme) {
      case AppTheme.original:
        return ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.transparent, // Managed by gradient
          primaryColor: Colors.green,
          colorScheme: const ColorScheme.dark(
            primary: Colors.green,
            secondary: Colors.black,
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white70),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
            ),
          ),
        );
      case AppTheme.light:
        return ThemeData.light().copyWith(
          primaryColor: Colors.green,
          colorScheme: const ColorScheme.light(
            primary: Colors.green,
            secondary: Colors.black,
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.black),
            bodyMedium: TextStyle(color: Colors.black54),
          ),
        );
      case AppTheme.dark:
        return ThemeData.dark().copyWith(
          primaryColor: Colors.green,
          colorScheme: const ColorScheme.dark(
            primary: Colors.green,
            secondary: Colors.white,
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white70),
          ),
        );
    }
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String? theme = prefs.getString('appTheme');
    _appTheme = switch (theme) {
      'light' => AppTheme.light,
      'dark' => AppTheme.dark,
      _ => AppTheme.original, // Default for new users or invalid value
    };
    notifyListeners();
  }

  Future<void> setAppTheme(AppTheme theme) async {
    _appTheme = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'appTheme', theme == AppTheme.light ? 'light' : theme == AppTheme.dark ? 'dark' : 'original');
    notifyListeners();
  }
}