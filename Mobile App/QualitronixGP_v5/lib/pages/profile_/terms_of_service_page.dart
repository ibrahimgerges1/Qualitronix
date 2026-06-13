import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:QualitronixGP_v5/providers/theme_provider.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isOriginal = themeProvider.appTheme == AppTheme.original;
    final isLight = themeProvider.appTheme == AppTheme.light;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Terms of Service",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isLight ? Colors.black : Colors.white, // White for original/dark, black for light
          ),
        ),
        backgroundColor: theme.primaryColor, // Use primaryColor (green) from ThemeData
        elevation: 0,
        iconTheme: IconThemeData(color: isLight ? Colors.black : Colors.white), // Match text color
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("1. Acceptance of Terms"),
              _buildText("By using the PCB Defect Detector app, you agree to these Terms of Service."),

              _buildSectionTitle("2. User Accounts"),
              _buildBulletPoint("Users must provide accurate information when registering."),
              _buildBulletPoint("You are responsible for maintaining the confidentiality of your login credentials."),

              _buildSectionTitle("3. Use of Services"),
              _buildBulletPoint("The app allows users to scan, detect, and store PCB defect data."),
              _buildBulletPoint("Misuse of the application, including unauthorized access, is prohibited."),

              _buildSectionTitle("4. Intellectual Property"),
              _buildBulletPoint("All app content, including designs and data, is protected by intellectual property laws."),
              _buildBulletPoint("Users may not reproduce, modify, or distribute any content without permission."),

              _buildSectionTitle("5. Limitation of Liability"),
              _buildText("We are not responsible for damages resulting from incorrect defect detections or misinterpretation of results."),

              _buildSectionTitle("6. Termination"),
              _buildText("We reserve the right to suspend or terminate accounts that violate these terms."),

              _buildSectionTitle("7. Changes to Terms"),
              _buildText("These terms may be updated. Continued use of the app constitutes acceptance of the new terms."),

              _buildSectionTitle("8. Contact Information"),
              _buildText("For any questions about these Terms, contact us at [gadibrahim029@gmail.com]."),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
