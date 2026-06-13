import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:QualitronixGP_v5/l10n/app_localizations.dart';
import 'package:QualitronixGP_v5/providers/theme_provider.dart';

class HistoryItemDetailPage extends StatelessWidget {
  final Map<String, dynamic> historyItem;
  final String documentId;

  HistoryItemDetailPage({required this.historyItem, required this.documentId});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isOriginal = themeProvider.appTheme == AppTheme.original;
    final isLight = themeProvider.appTheme == AppTheme.light;
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: isLight ? Colors.black : Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        localizations.translate('history_item_detail'),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isLight ? Colors.black : Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _infoText('${localizations.translate('class')}: ${historyItem['class_name']}', isLight),
                  _infoText('${localizations.translate('confidence')}: ${historyItem['confidence']}', isLight),
                  const SizedBox(height: 20),
                  Center(
                    child: historyItem['image_url'] != null
                        ? GestureDetector(
                      onTap: () => _showFullScreenImage(context, historyItem['image_url']),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                        child: PhotoView(
                          imageProvider: NetworkImage(historyItem['image_url']),
                          minScale: PhotoViewComputedScale.contained,
                          maxScale: PhotoViewComputedScale.covered * 2,
                          backgroundDecoration: const BoxDecoration(color: Colors.transparent),
                        ),
                      ),
                    )
                        : Text(
                      localizations.translate('no_image_available'),
                      style: TextStyle(
                        color: isLight ? Colors.black54 : Colors.white70,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    localizations.translate('heatmap'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isLight ? Colors.black : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: historyItem['heatmap_url'] != null
                        ? GestureDetector(
                      onTap: () => _showFullScreenImage(context, historyItem['heatmap_url']),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                        child: PhotoView(
                          imageProvider: NetworkImage(historyItem['heatmap_url']),
                          minScale: PhotoViewComputedScale.contained,
                          maxScale: PhotoViewComputedScale.covered * 2,
                          backgroundDecoration: const BoxDecoration(color: Colors.transparent),
                        ),
                      ),
                    )
                        : Text(
                      localizations.translate('no_heatmap_available'),
                      style: TextStyle(
                        color: isLight ? Colors.black54 : Colors.white70,
                      ),
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

  Widget _infoText(String text, bool isLight, {bool bold = false}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        color: isLight ? Colors.black : Colors.white,
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            PhotoView(
              imageProvider: NetworkImage(imageUrl),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 3,
              backgroundDecoration: const BoxDecoration(color: Colors.black87),
            ),
            Positioned(
              top: 40,
              left: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}