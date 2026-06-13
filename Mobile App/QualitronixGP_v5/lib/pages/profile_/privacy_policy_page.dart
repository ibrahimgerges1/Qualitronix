import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:QualitronixGP_v5/providers/theme_provider.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isLight = themeProvider.appTheme == AppTheme.light;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Privacy Policy",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isLight ? Colors.black : Colors.white, // Adjust text color based on theme
          ),
        ),
        backgroundColor: theme.primaryColor, // Use primaryColor from ThemeData
        elevation: 0,
        iconTheme: IconThemeData(color: isLight ? Colors.black : Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: themeProvider.appTheme == AppTheme.original
              ? const LinearGradient(
            colors: [Colors.green, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: themeProvider.appTheme == AppTheme.original
              ? null
              : (isLight ? Colors.white : Colors.black),
        ),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Introduction", isLight),
              _buildText(
                  "Welcome to PCB Defect Detector. Your privacy is important to us. This Privacy Policy explains how we collect, use, and protect your information when you use our mobile application.",
                  isLight),

              _buildSectionTitle("Information We Collect", isLight),
              _buildBulletPoint(
                  "Personal Information: Name, email, phone number, and profile details.", isLight),
              _buildBulletPoint("Authentication Data: Securely stored authentication credentials.",
                  isLight),
              _buildBulletPoint("User History: Scan results linked to your user ID.", isLight),
              _buildBulletPoint("Device Information: Collected for app optimization.", isLight),

              _buildSectionTitle("How We Use Your Information", isLight),
              _buildBulletPoint("To provide and improve our services.", isLight),
              _buildBulletPoint("To authenticate users and maintain security.", isLight),
              _buildBulletPoint("To store scan history for tracking and access.", isLight),
              _buildBulletPoint("To personalize your app experience.", isLight),

              _buildSectionTitle("Data Protection", isLight),
              _buildText(
                  "We implement security measures, including encryption and authentication protocols, to protect your personal data.",
                  isLight),

              _buildSectionTitle("Sharing of Information", isLight),
              _buildText("We do not sell or share your personal data except when required by law.",
                  isLight),

              _buildSectionTitle("User Rights", isLight),
              _buildBulletPoint("You can update or delete your profile information.", isLight),
              _buildBulletPoint("You may request account deletion by contacting support.", isLight),

              _buildSectionTitle("Updates to Privacy Policy", isLight),
              _buildText(
                  "We may update this policy periodically. Users will be notified of significant changes.",
                  isLight),

              _buildSectionTitle("Contact Us", isLight),
              _buildText("For any privacy-related inquiries, contact us at [your support email].",
                  isLight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isLight) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isLight ? Colors.black : Colors.white, // Adjust based on theme
        ),
      ),
    );
  }

  Widget _buildText(String text, bool isLight) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: isLight ? Colors.black : Colors.white, // Adjust based on theme
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text, bool isLight) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "• ",
            style: TextStyle(
              fontSize: 16,
              color: isLight ? Colors.black : Colors.white, // Adjust based on theme
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: isLight ? Colors.black : Colors.white, // Adjust based on theme
              ),
            ),
          ),
        ],
      ),
    );
  }
}