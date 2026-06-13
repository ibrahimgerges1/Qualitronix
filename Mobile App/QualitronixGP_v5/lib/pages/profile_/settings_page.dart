import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:QualitronixGP_v5/auth/sign_in_page.dart';
import 'package:QualitronixGP_v5/pages/profile_/language_selection_screen.dart';
import 'package:QualitronixGP_v5/pages/profile_/peofile_page.dart';
import 'package:QualitronixGP_v5/pages/profile_/privacy_policy_page.dart';
import 'package:QualitronixGP_v5/pages/profile_/terms_of_service_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:QualitronixGP_v5/pages/profile_/theme_page.dart';
import 'package:QualitronixGP_v5/l10n/app_localizations.dart';
import 'package:QualitronixGP_v5/providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  Stream<DocumentSnapshot> _getUserStream() {
    if (currentUser != null) {
      return FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).snapshots();
    }
    return const Stream.empty();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isOriginal = themeProvider.appTheme == AppTheme.original;
    final isDark = themeProvider.appTheme == AppTheme.dark;
    final isLight = themeProvider.appTheme == AppTheme.light;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isOriginal ? Colors.green : (isDark ? Colors.black : Colors.white),
        elevation: 0,
        iconTheme: IconThemeData(color: isLight ? Colors.black : Colors.white),
        title: Text(
          localizations.translate('settings'),
          style: TextStyle(
            color: isLight ? Colors.black : const Color(0xFFE3A81F), // Gold for original/dark
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
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
          color: isOriginal ? null : (isDark ? Colors.black : Colors.white),
        ),
        child: Column(
          children: [
            Container(height: 2, color: isOriginal ? Colors.black : theme.dividerColor),
            Expanded(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          currentUser == null
                              ? const CircleAvatar(
                            radius: 30,
                            child: Icon(Icons.person, size: 30),
                          )
                              : StreamBuilder<DocumentSnapshot>(
                            stream: _getUserStream(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const CircleAvatar(
                                  radius: 30,
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (!snapshot.hasData || !snapshot.data!.exists) {
                                return const CircleAvatar(
                                  radius: 30,
                                  backgroundImage: AssetImage('assets/images/1.jpg'),
                                );
                              }

                              final userData = snapshot.data!.data() as Map<String, dynamic>;
                              final String? imageUrl = userData['image_url']; // Fetch image_url instead of profileImageUrl

                              return CircleAvatar(
                                radius: 30,
                                backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                                    ? NetworkImage(imageUrl)
                                    : const AssetImage('assets/images/1.jpg') as ImageProvider,
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          currentUser == null
                              ? const Text("User not logged in")
                              : StreamBuilder<DocumentSnapshot>(
                            stream: _getUserStream(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Loading...", style: TextStyle(fontSize: 18)),
                                    Text("Loading...", style: TextStyle(fontSize: 14)),
                                  ],
                                );
                              }
                              if (!snapshot.hasData || !snapshot.data!.exists) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "N/A",
                                      style: TextStyle(
                                        color: isLight ? Colors.black : Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      currentUser!.email ?? 'N/A',
                                      style: TextStyle(
                                        color: isLight ? Colors.black54 : Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                );
                              }

                              final userData = snapshot.data!.data() as Map<String, dynamic>;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userData['name'] ?? 'N/A',
                                    style: TextStyle(
                                      color: isLight ? Colors.black : Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    currentUser!.email ?? 'N/A',
                                    style: TextStyle(
                                      color: isLight ? Colors.black54 : Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView(
                          children: [
                            _settingsTile(LucideIcons.user, localizations.translate('profile'), context),
                            _settingsTile(LucideIcons.globe, localizations.translate('language'), context),
                            _settingsTile(LucideIcons.shield, localizations.translate('privacy'), context),
                            _settingsTile(LucideIcons.moon, localizations.translate('theme'), context),
                            _settingsTile(LucideIcons.book, localizations.translate('terms_of_service'), context),
                            _settingsTile(LucideIcons.logOut, localizations.translate('logout'), context, isLogout: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsTile(IconData icon, String title, BuildContext context, {bool isLogout = false}) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isLight = themeProvider.appTheme == AppTheme.light;

    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.red : (isLight ? theme.primaryColor : const Color(0xFFE3A81F)),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red : (isLight ? Colors.black : Colors.white),
          fontSize: 16,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isLight ? Colors.black54 : Colors.white70,
      ),
      onTap: () async {
        if (isLogout) {
          await _signOut(context);
        } else {
          if (title == AppLocalizations.of(context)!.translate('profile')) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
          } else if (title == AppLocalizations.of(context)!.translate('language')) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => LanguageSelectionScreen()));
          } else if (title == AppLocalizations.of(context)!.translate('theme')) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ThemePage()));
          } else if (title == AppLocalizations.of(context)!.translate('privacy')) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacyPolicyPage()));
          } else if (title == AppLocalizations.of(context)!.translate('terms_of_service')) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => TermsOfServicePage()));
          }
        }
      },
    );
  }

  Future<void> _signOut(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await FirebaseAuth.instance.signOut();
    await prefs.remove('rememberMe');
    await prefs.remove('email');
    await prefs.remove('password');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SignInPage()),
          (route) => false,
    );
  }
}