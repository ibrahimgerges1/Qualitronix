import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:QualitronixGP_v5/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:QualitronixGP_v5/providers/theme_provider.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedGender = 'Male';
  String _selectedRole = 'User';
  String _email = ''; // Initialize with empty string

  @override
  void initState() {
    super.initState();
    // Set email immediately from currentUser if available
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _email = currentUser.email ?? 'No email available';
    }
    _loadUserData(); // Load additional Firestore data
  }

  void _loadUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        _nameController.text = userData['name'] ?? '';
        _phoneController.text = userData['phone'] ?? '';
        _selectedGender = userData['gender'] ?? 'Male';
        _selectedRole = userData['role'] ?? 'User';
        setState(() {}); // Update UI with Firestore data
      }
    }
  }

  void _saveChanges() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'gender': _selectedGender,
          'role': _selectedRole,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
        Navigator.pop(context); // Navigate back to ProfilePage
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update profile: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isLight = themeProvider.appTheme == AppTheme.light;
    bool isOriginal = themeProvider.appTheme == AppTheme.original;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isOriginal || isLight ? Colors.green : Colors.black, // Green for original/light
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isLight ? Colors.black : Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          localizations.translate('edit_profile'),
          style: TextStyle(
            color: isLight ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align text to start
            children: [
              const SizedBox(height: 20.0),
              // Display email as static text at the top
              Text(
                localizations.translate('change_info').replaceFirst('{email}', _email),
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: isLight ? Colors.black : Colors.white,
                ),
              ),
              const SizedBox(height: 20.0),
              _buildInputField(
                label: localizations.translate('name'),
                controller: _nameController,
                isLight: isLight,
              ),
              const SizedBox(height: 20.0),
              _buildInputField(
                label: localizations.translate('phone'),
                controller: _phoneController,
                isLight: isLight,
              ),
              const SizedBox(height: 20.0),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  localizations.translate('gender'),
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: isLight ? Colors.black : Colors.white,
                  ),
                ),
              ),
              Row(
                children: [
                  _buildRadioOption(localizations.translate('male'), 'Male', isLight),
                  _buildRadioOption(localizations.translate('female'), 'Female', isLight),
                ],
              ),
              const SizedBox(height: 20.0),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  localizations.translate('role'),
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: isLight ? Colors.black : Colors.white,
                  ),
                ),
              ),
              _buildRoleDropdown(isLight),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  localizations.translate('save_changes'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required bool isLight,
    bool isReadOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: isLight ? Colors.black : Colors.white,
          ),
        ),
        const SizedBox(height: 5.0),
        TextFormField(
          controller: controller,
          style: TextStyle(color: isLight ? Colors.black : Colors.white),
          readOnly: isReadOnly,
          decoration: InputDecoration(
            filled: true,
            fillColor: isLight ? Colors.transparent : Colors.grey[900],
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: isLight ? Colors.black : Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: isLight ? Colors.black : Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOption(String label, String value, bool isLight) {
    return Row(
      children: [
        Radio(
          value: value,
          groupValue: _selectedGender,
          onChanged: (String? newValue) {
            setState(() {
              _selectedGender = newValue!;
            });
          },
          activeColor: Colors.amber,
        ),
        Text(
          label,
          style: TextStyle(
            color: isLight ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleDropdown(bool isLight) {
    final localizations = AppLocalizations.of(context)!; // Access localizations here

    return DropdownButtonFormField<String>(
      value: _selectedRole,
      items: ['User', 'student', 'technician'].map((role) {
        return DropdownMenuItem(
          value: role, // Keep the value as the original string for consistency
          child: Text(
            localizations.translate(role.toLowerCase()), // Translate the role
            style: TextStyle(color: isLight ? Colors.black : Colors.white),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedRole = newValue!;
        });
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: isLight ? Colors.black : Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: isLight ? Colors.black : Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: isLight ? Colors.black : Colors.white),
        ),
      ),
      dropdownColor: isLight ? Colors.white : Colors.grey[900],
    );
  }
}