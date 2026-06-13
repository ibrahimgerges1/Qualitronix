import 'package:flutter/material.dart';
import 'package:QualitronixGP_v5/l10n/language_provider.dart';
import 'package:QualitronixGP_v5/l10n/app_localizations.dart';
import 'package:QualitronixGP_v5/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  LanguageSelectionScreenState createState() => LanguageSelectionScreenState();
}

class LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  late String selectedLanguage;

  @override
  void initState() {
    super.initState();
    selectedLanguage = Provider.of<LanguageProvider>(context, listen: false).locale.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isOriginal = themeProvider.appTheme == AppTheme.original;
    final isLight = themeProvider.appTheme == AppTheme.light;
    // Removed unused isDark (Line 27)

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isOriginal ? Colors.green : (isLight ? Colors.white : Colors.black),
        elevation: 0,
        iconTheme: IconThemeData(color: isLight ? Colors.black : Colors.white),
        title: Text(
          localizations.translate('language'),
          style: TextStyle(
            color: isOriginal ? const Color(0xFFE3A81F) : (isLight ? Colors.black : Colors.white),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: isLight ? Colors.black : Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isOriginal
              ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green, Colors.black],
          )
              : null,
          color: isOriginal ? null : (isLight ? Colors.white : Colors.black),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.translate('application_language'),
                style: TextStyle(
                  color: isLight ? Colors.black : Colors.amber,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Divider(color: isLight ? Colors.black26 : Colors.white54),
              const SizedBox(height: 10),
              buildLanguageOption(context, "en", localizations.translate('english')),
              buildLanguageOption(context, "ar", localizations.translate('arabic')),
              const Spacer(),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    localizations.translate('save_changes'),
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLanguageOption(BuildContext context, String languageCode, String language) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isLight = themeProvider.appTheme == AppTheme.light;
    // Removed unused isOriginal and isDark (Lines 103 and 105)

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.amber),
        borderRadius: BorderRadius.circular(30),
      ),
      child: ListTile(
        title: Text(
          language,
          style: TextStyle(
            color: isLight ? Colors.black : Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Radio<String>(
          value: languageCode,
          groupValue: selectedLanguage,
          activeColor: Colors.amber,
          onChanged: (String? value) {
            if (value != null) {
              setState(() {
                selectedLanguage = value;
              });
              Provider.of<LanguageProvider>(context, listen: false).changeLanguage(value);
            }
          },
        ),
      ),
    );
  }
}