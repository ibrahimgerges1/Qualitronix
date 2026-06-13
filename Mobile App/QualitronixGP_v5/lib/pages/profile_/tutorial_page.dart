import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:QualitronixGP_v5/l10n/app_localizations.dart';
import 'package:QualitronixGP_v5/pages/history/history_page.dart';
import 'package:QualitronixGP_v5/pages/profile_/settings_page.dart';
import 'package:QualitronixGP_v5/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class TutorialPage extends StatefulWidget {
  @override
  TutorialPageState createState() => TutorialPageState();
}

class TutorialPageState extends State<TutorialPage> {
  int step = 0;
  double boxTop = 200;
  double boxLeft = 100;

  late List<Map<String, dynamic>> tutorialSteps;

  List<GlobalKey> buttonKeys = [];

  @override
  void initState() {
    super.initState();
    buttonKeys = List.generate(6, (index) => GlobalKey());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      moveBoxToStep(0);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localizations = AppLocalizations.of(context)!;
    tutorialSteps = [
      {
        'label': localizations.translate('scan'),
        'icon': Icons.qr_code_scanner,
        'description': localizations.translate('scan_description'),
        'action': ImageSource.camera
      },
      {
        'label': localizations.translate('gallery'),
        'icon': Icons.photo,
        'description': localizations.translate('gallery_description'),
        'action': ImageSource.gallery
      },
      {
        'label': localizations.translate('history'),
        'icon': Icons.history,
        'description': localizations.translate('history_description'),
        'action': HistoryPage()
      },
      {
        'label': localizations.translate('defect_guidelines'),
        'icon': Icons.menu_book,
        'description': localizations.translate('defect_guidelines_description'),
        'action': null
      },
      {
        'label': localizations.translate('settings'),
        'icon': Icons.settings,
        'description': localizations.translate('settings_description'),
        'action': SettingsScreen()
      },
      {
        'label': localizations.translate('tutorial'),
        'icon': Icons.book,
        'description': localizations.translate('tutorial_description'),
        'action': null
      },
    ];
    print('Tutorial Steps Initialized: $tutorialSteps'); // Debug
  }

  void moveBoxToStep(int index) {
    final keyContext = buttonKeys[index].currentContext;
    if (keyContext != null) {
      final renderBox = keyContext.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);
      setState(() {
        boxTop = position.dy + renderBox.size.height / 2 + 5;
        boxLeft = position.dx + renderBox.size.width / 2 - 80;
        step = index;
      });
    }
  }

  void nextStep() {
    if (step < tutorialSteps.length - 1) {
      moveBoxToStep(step + 1);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isOriginal = themeProvider.appTheme == AppTheme.original;
    final bool isLight = themeProvider.appTheme == AppTheme.light;
    final localizations = AppLocalizations.of(context)!;

    print('Step: $step, Description: ${tutorialSteps[step]['description']}'); // Debug

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: tutorialSteps.asMap().entries.map((entry) {
                  int index = entry.key;
                  var data = entry.value;
                  return ButtonWidget(
                    key: buttonKeys[index],
                    label: data['label'],
                    icon: data['icon'],
                    isHighlighted: step == index,
                    isOriginal: isOriginal,
                    isLight: isLight,
                    onPressed: () {},
                  );
                }).toList(),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              top: boxTop,
              left: boxLeft,
              child: Column(
                children: [
                  CustomPaint(
                    size: const Size(40, 40),
                    painter: ArrowPainter(isLight: isLight),
                  ),
                  Material(
                    color: Colors.transparent,
                    elevation: 10,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 250,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: isOriginal
                            ? const LinearGradient(
                          colors: [Colors.green, Colors.black],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                            : null,
                        color: isOriginal ? null : (isLight ? Colors.white : Colors.black),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tutorialSteps[step]['description'] ?? 'Description not found',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isLight ? Colors.black : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: nextStep,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.zero,
                            ),
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
                                width: 150,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                alignment: Alignment.center,
                                child: Text(
                                  localizations.translate('next'),
                                  style: TextStyle(
                                    color: isLight ? Colors.black : Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ArrowPainter and ButtonWidget remain unchanged
class ArrowPainter extends CustomPainter {
  final bool isLight;

  ArrowPainter({required this.isLight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isLight ? Colors.black : Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width / 2, size.height - 10);
    path.lineTo(size.width / 2 - 5, size.height - 15);
    path.moveTo(size.width / 2, size.height - 10);
    path.lineTo(size.width / 2 + 5, size.height - 15);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ButtonWidget extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isHighlighted;
  final bool isOriginal;
  final bool isLight;
  final VoidCallback onPressed;

  const ButtonWidget({
    super.key,
    required this.label,
    required this.icon,
    required this.isHighlighted,
    required this.isOriginal,
    required this.isLight,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isLight ? Colors.black : Colors.white;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.07,
        child: Container(
          decoration: isHighlighted
              ? BoxDecoration(
            border: Border.all(color: Colors.blue, width: 4),
            borderRadius: BorderRadius.circular(10),
          )
              : null,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
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
                    Icon(icon, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}