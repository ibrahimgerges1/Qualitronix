import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:QualitronixGP_v5/pages/profile_/change_pass.dart';
import 'package:QualitronixGP_v5/pages/profile_/edit_profile.dart';
import 'package:QualitronixGP_v5/pages/profile_/change_photo.dart'; // Import the new screen
import 'package:QualitronixGP_v5/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:QualitronixGP_v5/providers/theme_provider.dart';

class ProfilePage extends StatefulWidget {
  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  late Future<DocumentSnapshot> _userDataFuture;
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _userDataFuture = _fetchUserData();
  }

  Future<DocumentSnapshot> _fetchUserData() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .get(GetOptions(source: Source.serverAndCache));
  }

  void _refreshData() {
    setState(() {
      _userDataFuture = _fetchUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isLight = themeProvider.appTheme == AppTheme.light;
    final isOriginal = themeProvider.appTheme == AppTheme.original;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isOriginal || isLight ? Colors.green : Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isLight ? Colors.black : Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          localizations.translate('profile'),
          style: TextStyle(
            color: isLight ? const Color(0xFFE3A81F) : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
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
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: currentUser == null
            ? const Center(child: Text("User not logged in"))
            : RefreshIndicator(
          key: _refreshKey,
          onRefresh: () async {
            _refreshData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: FutureBuilder<DocumentSnapshot>(
              future: _userDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text("User data not found"));
                }

                final userData = snapshot.data!.data() as Map<String, dynamic>;
                final String? imageUrl = userData['image_url'];

                return Column(
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 50,
                      backgroundImage: imageUrl != null
                          ? NetworkImage(imageUrl)
                          : const AssetImage('assets/images/logo.png') as ImageProvider,
                    ),
                    const SizedBox(height: 40),
                    _customButton(localizations.translate('change_photo'), () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChangePhotoScreen()),
                      ).then((_) => _refreshData()); // Refresh on return
                    }),
                    const SizedBox(height: 60),
                    InfoItem(
                        label: localizations.translate('name'),
                        value: userData['name'] ?? 'N/A'),
                    InfoItem(
                        label: localizations.translate('email'),
                        value: currentUser!.email ?? 'N/A'),
                    InfoItem(
                        label: localizations.translate('phone'),
                        value: userData['phone'] ?? 'N/A'),
                    InfoItem(
                        label: localizations.translate('role'),
                        value: userData['role'] ?? 'N/A'),
                    InfoItem(
                        label: localizations.translate('gender'),
                        value: userData['gender'] ?? 'N/A'),
                    const SizedBox(height: 60),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _customButton(localizations.translate('change_password'), () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
                          );
                        }),
                        _customButton(localizations.translate('edit_profile'), () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EditProfileScreen()),
                          ).then((_) => _refreshData());
                        }),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _customButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE3A81F),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}

class InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const InfoItem({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isLight = themeProvider.appTheme == AppTheme.light;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              color: Color(0xFFE3A81F),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isLight ? Colors.black : Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}