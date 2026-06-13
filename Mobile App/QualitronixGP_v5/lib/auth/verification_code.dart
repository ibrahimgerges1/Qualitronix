import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:QualitronixGP_v5/auth/constants.dart';
import 'package:QualitronixGP_v5/auth/sign_in_page.dart';
import 'package:QualitronixGP_v5/auth/widgets.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  const VerifyEmailScreen({required this.email, super.key}); // Added const and super.key

  @override
  VerifyEmailScreenState createState() => VerifyEmailScreenState();
}

class VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isVerified = false;
  bool _isSending = false;

  Future<void> _sendVerificationEmail() async {
    try {
      setState(() => _isSending = true);
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification email sent. Please check your inbox.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email is already verified.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send verification email.')),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _checkVerification() async {
    try {
      await _auth.currentUser?.reload();
      bool isVerified = _auth.currentUser?.emailVerified ?? false;
      if (isVerified) {
        setState(() => _isVerified = true);
        Navigator.push(context, MaterialPageRoute(builder: (context) =>  SignInPage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email not verified. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong. Please try again later.')),
      );
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
                color: AppConstants.textColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/logo.png'),
                    backgroundColor: Colors.transparent,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Verify Your Email",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "A verification link has been sent to:",
                    style: TextStyle(fontSize: 16, color: AppConstants.hintColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.email,
                    style: TextStyle(fontSize: 16, color: AppConstants.textColor),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Edit Email",
                      style: TextStyle(color: AppConstants.primaryColor, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_isSending)
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(AppConstants.primaryColor),
                    )
                  else if (_isVerified) // Using _isVerified here
                    Text(
                      "Email Verified! Redirecting...",
                      style: TextStyle(color: AppConstants.primaryColor, fontSize: 16),
                    )
                  else
                    TextButton(
                      onPressed: _sendVerificationEmail,
                      child: Text(
                        "Didn’t get a code? Resend",
                        style: TextStyle(color: AppConstants.primaryColor),
                      ),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    onPressed: _isVerified ? null : _checkVerification, // Disable button if verified
                    child: Text(
                      'Verify',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SignInPage())),
                    child: Text(
                      "Back to Sign In",
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
}