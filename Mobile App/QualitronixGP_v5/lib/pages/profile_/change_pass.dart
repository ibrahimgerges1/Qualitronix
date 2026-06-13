import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:QualitronixGP_v5/providers/theme_provider.dart';
import 'package:QualitronixGP_v5/l10n/app_localizations.dart'; // Add this import

class ChangePasswordScreen extends StatefulWidget {
  @override
  ChangePasswordScreenState createState() => ChangePasswordScreenState();
}

class ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _changePassword() async {
    final localizations = AppLocalizations.of(context)!; // Add this

    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.translate('password_mismatch'))));
      return;
    }

    setState(() => _isLoading = true);

    User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.translate('user_not_logged_in'))));
      setState(() => _isLoading = false);
      return;
    }

    String email = user.email!;

    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: _currentPasswordController.text,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(_newPasswordController.text);

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.translate('password_updated'))));

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String errorMessage = "${localizations.translate('error')}${e.message}";
      if (e.code == 'wrong-password') {
        errorMessage = localizations.translate('wrong_password');
      } else if (e.code == 'weak-password') {
        errorMessage = localizations.translate('weak_password');
      } else if (e.code == 'requires-recent-login') {
        errorMessage = localizations.translate('requires_recent_login');
      }

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${localizations.translate('unexpected_error')}${e.toString()}")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizations = AppLocalizations.of(context)!; // Add this
    bool isLight = themeProvider.appTheme == AppTheme.light;
    bool isOriginal = themeProvider.appTheme == AppTheme.original;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isOriginal || isLight ? Colors.green : Colors.black,
        elevation: 0,
        title: Text(
          localizations.translate('change_password'), // Updated
          style: TextStyle(
            color: isLight ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isLight ? Colors.black : Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: themeProvider.appTheme == AppTheme.original
              ? const LinearGradient(
            colors: [Colors.green, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: themeProvider.appTheme == AppTheme.original
              ? null
              : (isLight ? Colors.white : Colors.black),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20.0),
              _buildInputField(localizations.translate('current_password'), _currentPasswordController, isLight,
                  obscureText: true),
              const SizedBox(height: 20.0),
              _buildInputField(localizations.translate('new_password'), _newPasswordController, isLight,
                  obscureText: true),
              const SizedBox(height: 20.0),
              _buildInputField(localizations.translate('confirm_password'), _confirmPasswordController, isLight,
                  obscureText: true),
              const SizedBox(height: 50.0),
              ElevatedButton(
                onPressed: _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                  localizations.translate('save_changes'), // Updated
                  style: TextStyle(
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

  Widget _buildInputField(String label, TextEditingController controller, bool isLight,
      {bool obscureText = false}) {
    final localizations = AppLocalizations.of(context)!; // Add this

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: isLight ? Colors.black : Colors.white),
        ),
        const SizedBox(height: 5.0),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: TextStyle(color: isLight ? Colors.black : Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: isLight ? Colors.transparent : Colors.grey[900],
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: isLight ? Colors.black : Colors.white),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return localizations.translate('field_required'); // Updated
            }
            return null;
          },
        ),
      ],
    );
  }
}