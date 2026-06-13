import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Initialize Cloudinary
  static final cloudinary = CloudinaryPublic(
    'drkydbtrt',
    'user_profile_images',
  );

  Future<User?> signUp(
      String email,
      String password,
      String name,
      String phone,
      String role,
      String gender,
      File? imageFile, // Add image file parameter
      ) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(name);
        await user.sendEmailVerification();

        // Upload image to Cloudinary and get URL
        String? imageUrl;
        if (imageFile != null) {
          CloudinaryResponse response = await cloudinary.uploadFile(
            CloudinaryFile.fromFile(
              imageFile.path,
              resourceType: CloudinaryResourceType.Image,
            ),
          );
          imageUrl = response.secureUrl;
        }

        // Save user info with image URL
        await saveUserInfo(user.uid, name, phone, role, gender, imageUrl);
      }
      return user;
    } catch (e) {
      print('Sign-Up Error: $e');
      return null;
    }
  }

  Future<bool> isEmailVerified() async {
    try {
      User? user = _auth.currentUser;
      await user?.reload();
      return user?.emailVerified ?? false;
    } catch (e) {
      print('Error checking email verification: $e');
      return false;
    }
  }

  Future<void> saveUserInfo(
      String userId,
      String name,
      String phone,
      String role,
      String gender,
      String? imageUrl,
      ) async {
    try {
      CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
      await usersCollection.doc(userId).set({
        'name': name,
        'phone': phone,
        'role': role,
        'gender': gender,
        'image_url': imageUrl, // Store Cloudinary URL
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error saving user info: $e");
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print('Sign-In Error: $e');
      return null;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}