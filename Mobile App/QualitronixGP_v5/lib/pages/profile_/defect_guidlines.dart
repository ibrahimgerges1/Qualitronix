import 'package:flutter/material.dart';
import 'package:QualitronixGP_v5/l10n/app_localizations.dart'; // Add this import
import 'package:QualitronixGP_v5/models/defects.dart';
import 'package:provider/provider.dart';
import 'package:QualitronixGP_v5/providers/theme_provider.dart';
import 'defect_details_page.dart';

class DefectGuidelinesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isLight = themeProvider.appTheme == AppTheme.light;
    final isOriginal = themeProvider.appTheme == AppTheme.original;
    final localizations = AppLocalizations.of(context)!; // Add this to access translations

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.translate('defect_guidelines'), // Use localized string
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isOriginal ? const Color(0xFFE3A81F) : theme.textTheme.titleLarge?.color,
          ),
        ),
        backgroundColor: isOriginal ? Colors.green : theme.primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: isOriginal ? Colors.white : theme.iconTheme.color),
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
            : BoxDecoration(
          color: isLight ? Colors.white : Colors.black,
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: defects.length,
          itemBuilder: (context, index) {
            final defect = defects[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DefectDetailsPage(defect: defect),
                  ),
                );
              },
              child: Card(
                color: isOriginal
                    ? Colors.white.withOpacity(0.1)
                    : (isLight ? Colors.white : Colors.grey[900]),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    Image.asset(defect.image, height: 150, width: double.infinity, fit: BoxFit.cover),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        defect.name, // You can localize this too if needed (see below)
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isLight ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}