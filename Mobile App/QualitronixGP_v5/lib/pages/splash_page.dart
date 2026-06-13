import 'package:flutter/material.dart';
import 'package:QualitronixGP_v5/auth/sign_in_page.dart';
import 'package:QualitronixGP_v5/pages/welcom_page.dart';

import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _animationController.forward();
        }
      });

    _animationController.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final appState = context.findAncestorStateOfType<PCBDefectDetectorAppState>();
        final isLoggedIn = appState?.isLoggedIn ?? false;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => isLoggedIn ? const WelcomeScreen() : const SignInPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF9A620), Color(0xFF009966)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 100),
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        colors: [Color(0xFFFCA326), Color(0xFFFFFFFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    child: const Text(
                      'Detecting Precision, Weaving Perfection.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 5),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double lineWidth = 350.0;
                      double lineHeight = 4.0;
                      double circleSize = 15.0;
                      double animationStart = (constraints.maxWidth - lineWidth) / 8;

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            height: lineHeight,
                            width: lineWidth,
                            color: Colors.white,
                          ),
                          AnimatedBuilder(
                            animation: _animation,
                            builder: (context, child) {
                              double circleLeft = animationStart + (_animation.value * (lineWidth - circleSize));
                              return Positioned(
                                left: circleLeft,
                                top: -(circleSize / 2) + (lineHeight / 2),
                                child: Container(
                                  width: circleSize,
                                  height: circleSize,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.yellow, Colors.white],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.topCenter,
                child: Image.asset('assets/images/logo.png', height: 200, width: 200),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.2,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Image.asset(
                    'assets/images/qualitrounx.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}