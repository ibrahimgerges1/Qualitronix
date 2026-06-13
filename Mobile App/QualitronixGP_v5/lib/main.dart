import 'package:QualitronixGP_v5/l10n/app_localizations.dart';
import 'package:QualitronixGP_v5/l10n/language_provider.dart';
import 'package:QualitronixGP_v5/pages/splash_page.dart';
import 'package:QualitronixGP_v5/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final themeProvider = ThemeProvider();
  await themeProvider.loadPreferences();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ChangeNotifierProvider(create: (context) => themeProvider),
      ],
      child: const PCBDefectDetectorApp(),
    ),
  );
}

class PCBDefectDetectorApp extends StatefulWidget {
  const PCBDefectDetectorApp({super.key});

  @override
  PCBDefectDetectorAppState createState() => PCBDefectDetectorAppState();
}

class PCBDefectDetectorAppState extends State<PCBDefectDetectorApp> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool rememberMe = prefs.getBool('rememberMe') ?? false;
    String? email = prefs.getString('email');
    String? password = prefs.getString('password');

    if (rememberMe && email != null && password != null) {
      setState(() {
        isLoggedIn = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      // showPerformanceOverlay: true,
      debugShowCheckedModeBanner: false,
      title: 'PCB Defect Detector',
      supportedLocales: const [
        Locale('en', ''),
        Locale('ar', ''),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: Provider.of<LanguageProvider>(context).locale,
      theme: themeProvider.themeData.copyWith(
        scaffoldBackgroundColor: themeProvider.appTheme == AppTheme.original
            ? null
            : themeProvider.themeData.scaffoldBackgroundColor,
      ),
      home: const SplashScreen(),
    );
  }
}