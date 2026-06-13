import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:QualitronixGP_v5/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:QualitronixGP_v5/pages/history/history_page.dart';
import 'package:QualitronixGP_v5/pages/pro_page.dart';
import 'package:QualitronixGP_v5/pages/profile_/defect_guidlines.dart';
import 'package:QualitronixGP_v5/pages/profile_/settings_page.dart';
import 'package:QualitronixGP_v5/pages/profile_/tutorial_page.dart';
import 'package:QualitronixGP_v5/l10n/app_localizations.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key}); // Added const

  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 350).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Stream<DocumentSnapshot> _getUserStream() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      return FirebaseFirestore.instance.collection('users').doc(currentUser.uid).snapshots();
    }
    return const Stream.empty();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text("Please log in to continue."),
        ),
      );
    }

    bool isOriginal = themeProvider.appTheme == AppTheme.original;
    bool isLight = themeProvider.appTheme == AppTheme.light;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isOriginal
              ? const LinearGradient(
            colors: [Colors.green, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
          )
              : null,
          color: isOriginal ? null : (isLight ? Colors.white : Colors.black),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: StreamBuilder<DocumentSnapshot>(
                stream: _getUserStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: screenHeight * 0.06,
                              backgroundColor: Colors.transparent,
                              backgroundImage: const AssetImage('assets/images/logo.png'),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.translate('hello'),
                                  style: TextStyle(
                                    fontSize: screenHeight * 0.02,
                                    fontWeight: FontWeight.bold,
                                    color: isLight ? Colors.black : Colors.white,
                                  ),
                                ),
                                Text(
                                  'No Name',
                                  style: TextStyle(
                                    fontSize: screenHeight * 0.018,
                                    color: isLight ? Colors.black54 : Colors.white70,
                                  ),
                                ),
                                Text(
                                  currentUser.email ?? 'No Email',
                                  style: TextStyle(
                                    fontSize: screenHeight * 0.018,
                                    color: isLight ? Colors.black54 : Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 350,
                          height: 10,
                          child: Stack(
                            children: [
                              Container(
                                height: 2,
                                width: 350,
                                color: isLight ? Colors.black : Colors.white,
                              ),
                              AnimatedBuilder(
                                animation: _animation,
                                builder: (context, child) {
                                  return Positioned(
                                    left: _animation.value,
                                    top: -2,
                                    child: ShaderMask(
                                      shaderCallback: (Rect bounds) {
                                        return const LinearGradient(
                                          colors: [Color(0xFFFFD700), Colors.white],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ).createShader(bounds);
                                      },
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildButtons(context, screenWidth, screenHeight),
                      ],
                    );
                  }

                  final userData = snapshot.data!.data() as Map<String, dynamic>;
                  String name = userData['name'] ?? 'No Name';
                  String email = currentUser.email ?? 'No Email';

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: screenHeight * 0.06,
                            backgroundColor: Colors.transparent,
                            backgroundImage: const AssetImage('assets/images/logo.png'),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.translate('hello'),
                                style: TextStyle(
                                  fontSize: screenHeight * 0.02,
                                  fontWeight: FontWeight.bold,
                                  color: isLight ? Colors.black : Colors.white,
                                ),
                              ),
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: screenHeight * 0.018,
                                  color: isLight ? Colors.black54 : Colors.white70,
                                ),
                              ),
                              Text(
                                email,
                                style: TextStyle(
                                  fontSize: screenHeight * 0.018,
                                  color: isLight ? Colors.black54 : Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 350,
                        height: 10,
                        child: Stack(
                          children: [
                            Container(
                              height: 2,
                              width: 350,
                              color: isLight ? Colors.black : Colors.white,
                            ),
                            AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) {
                                return Positioned(
                                  left: _animation.value,
                                  top: -2,
                                  child: ShaderMask(
                                    shaderCallback: (Rect bounds) {
                                      return const LinearGradient(
                                        colors: [Color(0xFFFFD700), Colors.white],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ).createShader(bounds);
                                    },
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildButtons(context, screenWidth, screenHeight),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context, double screenWidth, double screenHeight) {
    return Column(
      children: [
        _buildButton(
          label: 'scan',
          icon: Icons.camera_alt,
          context: context,
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(source: ImageSource.camera)),
          ),
        ),
        _buildButton(
          label: 'gallery',
          icon: Icons.photo,
          context: context,
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(source: ImageSource.gallery)),
          ),
        ),
        _buildButton(
          label: 'history',
          icon: Icons.history,
          context: context,
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HistoryPage()),
          ),
        ),
        _buildButton(
          label: 'defect_guidelines',
          icon: Icons.menu_book,
          context: context,
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DefectGuidelinesPage()),
          ),
        ),
        _buildButton(
          label: 'settings',
          icon: Icons.settings,
          context: context,
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingsScreen()),
          ),
        ),
        _buildButton(
          label: 'tutorial',
          icon: Icons.book,
          context: context,
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TutorialPage()),
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required BuildContext context,
    required double screenWidth,
    required double screenHeight,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: screenWidth * 0.8,
        height: screenHeight * 0.07,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.zero,
          ),
          onPressed: onPressed,
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFF9A620)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        colors: [Colors.green, Colors.black],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    child: Icon(
                      icon,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.translate(label),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}