import 'package:flutter/material.dart';
import 'package:QualitronixGP_v5/l10n/app_localizations.dart'; // Add this import
import 'package:QualitronixGP_v5/models/defects.dart';
import 'package:provider/provider.dart';
import 'package:QualitronixGP_v5/providers/theme_provider.dart';

class DefectDetailsPage extends StatelessWidget {
  final Defect defect;

  const DefectDetailsPage({super.key, required this.defect});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!; // Add this to access translations
    final isOriginal = themeProvider.appTheme == AppTheme.original;
    final isLight = themeProvider.appTheme == AppTheme.light;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.translate('defect_details_title'), // Use translated title
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isLight ? Colors.black : Colors.white,
          ),
        ),
        backgroundColor: theme.primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: isLight ? Colors.black : Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isOriginal
              ? const LinearGradient(
            colors: [Colors.green, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: isOriginal ? null : (isLight ? Colors.white : Colors.black),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(defect.image, height: 200, width: double.infinity, fit: BoxFit.cover),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.translate(defect.name), // Translate defect name
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isLight ? Colors.black : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizations.translate('description_label'), // Translate "Description:"
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isLight ? Colors.black : Colors.white,
                      ),
                    ),
                    Text(
                      localizations.translate(defect.description), // Translate description
                      style: TextStyle(
                        color: isLight ? Colors.black : Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      localizations.translate('challenges_label'), // Translate "Challenges:"
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isLight ? Colors.black : Colors.white,
                      ),
                    ),
                    for (var challenge in defect.challenges)
                      Text(
                        "- ${localizations.translate(challenge)}", // Translate each challenge
                        style: TextStyle(
                          color: isLight ? Colors.black : Colors.white70,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}