import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:QualitronixGP_v5/auth/verification_code.dart';
import 'package:QualitronixGP_v5/auth/auth_service.dart'; // Import your AuthService
import 'constants.dart';
import 'widgets.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  SignUpPageState createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRole = 'User';
  String _selectedGender = 'Male';
  File? _selectedImage; // To store the picked image

  final AuthService _authService = AuthService();

  // Pick image from gallery or camera
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery); // Or ImageSource.camera
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _signUp() async {
    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || phone.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill out all fields')));
      return;
    }
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    try {
      User? user = await _authService.signUp(
        email,
        password,
        name,
        phone,
        _selectedRole,
        _selectedGender,
        _selectedImage, // Pass the selected image
      );
      if (user != null) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => VerifyEmailScreen(email: email)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign-up failed')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlurredBackground(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
              padding: EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: Colors.transparent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Image Picker UI
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppConstants.textColor.withOpacity(0.2),
                        image: _selectedImage != null
                            ? DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: _selectedImage == null
                          ? Icon(Icons.add_a_photo, size: 40, color: AppConstants.primaryColor)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text("Create Account", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppConstants.textColor)),
                  const SizedBox(height: 20),
                  CustomTextField(controller: _nameController, hintText: 'Full Name'),
                  const SizedBox(height: 15),
                  CustomTextField(controller: _phoneController, hintText: 'Phone Number'),
                  const SizedBox(height: 15),
                  CustomTextField(controller: _emailController, hintText: 'Email'),
                  const SizedBox(height: 15),
                  CustomTextField(controller: _passwordController, hintText: 'Password', obscureText: true),
                  const SizedBox(height: 15),
                  CustomTextField(controller: _confirmPasswordController, hintText: 'Confirm Password', obscureText: true),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: _buildInputDecoration(),
                    items: ['User', 'student', 'technician']
                        .map((role) => DropdownMenuItem(value: role, child: Text(role, style: TextStyle(color: AppConstants.textColor))))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedRole = value!),
                    dropdownColor: Colors.black,
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildRadio('Male'),
                      const SizedBox(width: 20),
                      _buildRadio('Female'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _signUp,
                    child: const Text("Sign Up", style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.defaultRadius)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      "Already have an account? Sign In",
                      style: TextStyle(color: AppConstants.primaryColor, fontSize: 16),
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

  InputDecoration _buildInputDecoration({String hintText = ''}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: AppConstants.hintColor),
      filled: true,
      fillColor: AppConstants.textColor.withOpacity(0.2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
    );
  }

  Widget _buildRadio(String gender) {
    return Row(
      children: [
        Radio(
          value: gender,
          groupValue: _selectedGender,
          onChanged: (value) => setState(() => _selectedGender = value.toString()),
          activeColor: AppConstants.primaryColor,
        ),
        Text(gender, style: TextStyle(color: AppConstants.textColor, fontSize: 16)),
      ],
    );
  }
}