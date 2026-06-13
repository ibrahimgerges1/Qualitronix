import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:QualitronixGP_v5/l10n/app_localizations.dart';
import 'package:QualitronixGP_v5/pages/api_service.dart';
import 'package:QualitronixGP_v5/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final ImageSource source;

  const HomeScreen({super.key, required this.source});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  File? _selectedImage;
  List<dynamic>? _predictions;
  String? _annotatedImageUrl;
  String? _heatmapImageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pickImage();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: widget.source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _predictions = null;
        _annotatedImageUrl = null;
        _heatmapImageUrl = null;
      });
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Call the API to process the image
      final response = await ApiService.predictSingleImage(_selectedImage!);

      // Validate the response
      if (response['batch_results'] == null || response['batch_results'].isEmpty) {
        throw Exception("No batch results returned from API");
      }
      final batchResult = response['batch_results'][0];

      // Base URL for constructing absolute URLs
      const String baseUrl = "http://51.20.245.170";

      setState(() {
        // Extract predictions
        _predictions = batchResult['predictions'] ?? [];

        // Construct absolute URLs for annotated image and heatmap
        _annotatedImageUrl = batchResult.containsKey('annotated_image_url') &&
            batchResult['annotated_image_url'] != null
            ? (batchResult['annotated_image_url'].startsWith('/')
            ? baseUrl + batchResult['annotated_image_url']
            : batchResult['annotated_image_url'])
            : null;
        _heatmapImageUrl = batchResult.containsKey('heatmap_url') && batchResult['heatmap_url'] != null
            ? (batchResult['heatmap_url'].startsWith('/')
            ? baseUrl + batchResult['heatmap_url']
            : batchResult['heatmap_url'])
            : null;
      });

      if (_predictions != null && _predictions!.isNotEmpty) {
        await _uploadToFirestore();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${AppLocalizations.of(context)!.translate('error_processing_image')}: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadToFirestore() async {
    String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    String className = _predictions![0]['class_name'] ?? 'Unknown';
    double confidence = _predictions![0]['confidence'] ?? 0.0;
    List defects = _predictions!.map((prediction) => prediction['class_name']).toList();

    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('history')
          .add({
        'class_name': className,
        'confidence': confidence,
        'image_url': _annotatedImageUrl,
        'heatmap_url': _heatmapImageUrl,
        'timestamp': timestamp,
        'defects': defects,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.translate('data_uploaded_successfully'))),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${AppLocalizations.of(context)!.translate('failed_to_upload_data')}: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isOriginal = themeProvider.appTheme == AppTheme.original;
    bool isLight = themeProvider.appTheme == AppTheme.light;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          localizations.translate('pcb_defect_detector'),
          style: TextStyle(color: isLight ? Colors.black : Colors.white),
        ),
        backgroundColor: isOriginal || isLight ? Colors.green : Colors.black,
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedImage != null || _annotatedImageUrl != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_selectedImage != null)
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenImagePage(image: _selectedImage),
                              ),
                            );
                          },
                          child: Image.file(
                            _selectedImage!,
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    const SizedBox(width: 10),
                    if (_annotatedImageUrl != null)
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenImagePage(imageUrl: _annotatedImageUrl),
                              ),
                            );
                          },
                          child: Image.network(
                            _annotatedImageUrl!,
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: 10),
              if (_heatmapImageUrl != null)
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImagePage(imageUrl: _heatmapImageUrl),
                        ),
                      );
                    },
                    child: Image.network(
                      _heatmapImageUrl!,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _processImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(localizations.translate('process_image')),
                ),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          localizations.translate('processing_image'),
                          style: TextStyle(
                            color: isLight ? Colors.black : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (!_isLoading && _predictions != null && _predictions!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.translate('defects_detected'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isLight ? Colors.black : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _predictions!.length,
                      itemBuilder: (context, index) {
                        final prediction = _predictions![index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${prediction['class_name']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isLight ? Colors.black : Colors.white,
                                ),
                              ),
                              Text(
                                '${(prediction['confidence'] * 100).toStringAsFixed(2)}%',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isLight ? Colors.black : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class FullScreenImagePage extends StatelessWidget {
  final File? image;
  final String? imageUrl;

  const FullScreenImagePage({super.key, this.image, this.imageUrl})
      : assert(image != null || imageUrl != null, 'Either image or imageUrl must be provided');

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isOriginal = themeProvider.appTheme == AppTheme.original;
    bool isLight = themeProvider.appTheme == AppTheme.light;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          localizations.translate('full_screen_image'),
          style: TextStyle(color: isLight ? Colors.black : Colors.white),
        ),
        backgroundColor: isOriginal || isLight ? Colors.green : Colors.black,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(20.0),
          minScale: 0.5,
          maxScale: 4.0,
          child: Center(
            child: image != null
                ? Image.file(image!)
                : Image.network(imageUrl!),
          ),
        ),
      ),
    );
  }
}