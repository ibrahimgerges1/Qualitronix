import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:QualitronixGP_v5/pages/history/history_details.dart';
import 'package:QualitronixGP_v5/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:QualitronixGP_v5/l10n/app_localizations.dart'; // Add this import

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isOriginal = themeProvider.appTheme == AppTheme.original;
    final isLight = themeProvider.appTheme == AppTheme.light;
    final localizations = AppLocalizations.of(context)!; // Add this to access translations

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          title: Text(
            localizations.translate('history'), // Use translation for "History"
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          backgroundColor: isOriginal ? Colors.transparent : (isLight ? Colors.white : Colors.black),
          elevation: 0,
          flexibleSpace: isOriginal
              ? Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green, Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          )
              : null,
          iconTheme: IconThemeData(
            color: isLight ? Colors.black : Colors.white,
          ),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: isOriginal
            ? const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        )
            : null,
        color: isOriginal ? null : (isLight ? Colors.white : Colors.black),
        child: Column(
          children: [
            Container(height: 2, color: isOriginal ? Colors.black : theme.dividerColor),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getHistoryFromFirestore(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('${localizations.translate('error')}: ${snapshot.error}')); // Localize "Error"
                  }

                  var historyItems = snapshot.data?.docs ?? [];
                  return ListView.builder(
                    itemCount: historyItems.length,
                    itemBuilder: (context, index) {
                      var historyItem = historyItems[index].data() as Map<String, dynamic>;

                      var timestampField = historyItem['timestamp'];

                      String formattedTimestamp;
                      if (timestampField is Timestamp) {
                        formattedTimestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(timestampField.toDate());
                      } else if (timestampField is String) {
                        try {
                          formattedTimestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(timestampField));
                        } catch (e) {
                          formattedTimestamp = localizations.translate('invalid_date_format'); // Localize "Invalid Date Format"
                        }
                      } else {
                        formattedTimestamp = localizations.translate('unknown_time'); // Localize "Unknown Time"
                      }

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isLight ? Colors.black : Colors.white, width: 2),
                            color: isOriginal ? Colors.transparent : (isLight ? Colors.white : Colors.black87),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${localizations.translate('scan_name')}: ${historyItem['class_name']}', // Localize "Scan Name"
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isLight ? Colors.black : Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${localizations.translate('date')}: $formattedTimestamp', // Localize "Date"
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isLight ? Colors.black54 : Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${localizations.translate('defects')}: ${historyItem['defects']?.join(", ") ?? localizations.translate('no_defects_reported')}', // Localize "Defects" and "No defects reported"
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isLight ? Colors.black54 : Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: isLight ? Colors.black54 : Colors.white70,
                              size: 18,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HistoryItemDetailPage(
                                    historyItem: historyItem,
                                    documentId: historyItems[index].id,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Stream<QuerySnapshot> getHistoryFromFirestore() {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('history')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}