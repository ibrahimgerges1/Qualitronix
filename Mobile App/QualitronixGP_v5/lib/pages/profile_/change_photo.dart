import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:QualitronixGP_v5/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:QualitronixGP_v5/providers/theme_provider.dart';

class ChangePhotoScreen extends StatefulWidget {
  @override
  ChangePhotoScreenState createState() => ChangePhotoScreenState();
}

class ChangePhotoScreenState extends State<ChangePhotoScreen> {
  File? _selectedImage;
  bool _isLoading = false;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Initialize Cloudinary
  final cloudinary = CloudinaryPublic(
    'drkydbtrt', // Replace with your Cloud Name
    'user_profile_images', // Replace with your upload preset
  );

  // Pick image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Upload image to Cloudinary and update Firestore
  Future<void> _savePhoto() async {
    if (_selectedImage == null || currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload to Cloudinary
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          _selectedImage!.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      String imageUrl = response.secureUrl;

      // Update Firestore
      await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).update({
        'image_url': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.translate('photo_updated_successfully'))),
      );
      Navigator.pop(context); // Return to ProfilePage
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
          localizations.translate('change_photo'),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.withOpacity(0.3),
                  image: _selectedImage != null
                      ? DecorationImage(
                    image: FileImage(_selectedImage!),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: _selectedImage == null
                    ? Icon(Icons.add_a_photo, size: 50, color: isLight ? Colors.black : Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 40),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _savePhoto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE3A81F),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  localizations.translate('save_photo'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}