import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:QualitronixGP_v5/providers/theme_provider.dart';

class ThemePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isOriginal = themeProvider.appTheme == AppTheme.original;
    final isLight = themeProvider.appTheme == AppTheme.light;
    final isDark = themeProvider.appTheme == AppTheme.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Theme Settings"),
        backgroundColor: isOriginal ? Colors.green : (isLight ? Colors.white : Colors.black),
        iconTheme: IconThemeData(color: isLight ? Colors.black : Colors.white),
        titleTextStyle: TextStyle(
          color: isLight ? Colors.black : Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Container(
        decoration: isOriginal
            ? const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        )
            : null,
        color: isOriginal ? null : (isLight ? Colors.white : Colors.black),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _themeOption("Light Mode", AppTheme.light, themeProvider, isLight, isDark, isOriginal),
            _themeOption("Dark Mode", AppTheme.dark, themeProvider, isDark, isDark, isOriginal),
            _themeOption("Original Theme", AppTheme.original, themeProvider, isOriginal, isDark, isOriginal),
          ],
        ),
      ),
    );
  }

  Widget _themeOption(
      String title, AppTheme mode, ThemeProvider themeProvider, bool isSelected, bool isDark, bool isOriginal) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? (isOriginal ? Colors.green.shade700 : (isDark ? Colors.grey[800] : Colors.grey[300]))
              : (isOriginal ? Colors.green.shade900 : (isDark ? Colors.grey[900] : Colors.white)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: SwitchListTile(
          title: Text(
            title,
            style: TextStyle(
              color: isOriginal || isDark ? Colors.white : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          value: isSelected,
          onChanged: (value) {
            if (value) themeProvider.setAppTheme(mode);
          },
          activeColor: Colors.greenAccent,
          inactiveTrackColor: isOriginal ? Colors.green.shade800 : (isDark ? Colors.grey[700] : Colors.grey[400]),
          activeTrackColor: isOriginal ? Colors.lightGreenAccent : (isDark ? Colors.grey[500] : Colors.green),
        ),
      ),
    );
  }
}