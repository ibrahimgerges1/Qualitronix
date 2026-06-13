import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:QualitronixGP_v5/auth/constants.dart';
import 'package:QualitronixGP_v5/auth/forget_pass.dart';
import 'package:QualitronixGP_v5/auth/sign_up_page.dart';
import 'package:QualitronixGP_v5/auth/widgets.dart';
import 'package:QualitronixGP_v5/pages/welcom_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  SignInPageState createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isVerified = true;

  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailController.text = prefs.getString('email') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
      _rememberMe = prefs.getBool('rememberMe') ?? false;
    });
    if (_rememberMe &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      _signIn();
    }
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('email', _emailController.text);
      await prefs.setString('password', _passwordController.text);
      await prefs.setBool('rememberMe', true);
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
      await prefs.setBool('rememberMe', false);
    }
  }

  Future<void> _signIn() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await userCredential.user?.reload();
      if (userCredential.user!.emailVerified) {
        await _saveCredentials();
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => WelcomeScreen()));
      } else {
        setState(() => _isVerified = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Email not verified. Please verify your email.')),
        );
      }
    } catch (e) {
      print('Error signing in: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Invalid email or password')),
      );
    }
  }

  Future<void> _reverifyEmail() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.delete();
        await _auth.signOut();
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => SignUpPage()));
      }
    } catch (e) {
      print('Error during reverification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting account. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double paddingValue = screenWidth * 0.05;

    return Scaffold(
      body: BlurredBackground(
        child: Center(
          child: SingleChildScrollView(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: paddingValue),
                  padding: EdgeInsets.all(paddingValue),
                  decoration: BoxDecoration(
                    color: AppConstants.textColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: screenWidth * 0.15, // Reverted to responsive radius
                        backgroundImage: const AssetImage('assets/images/logo.png'),
                        backgroundColor: Colors.transparent,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Hi, Welcome Back! 👋",
                        style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Hello again, you've been missed!",
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: AppConstants.hintColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      CustomTextField(
                        controller: _emailController,
                        hintText: 'email',
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        controller: _passwordController,
                        hintText: 'Password',
                        obscureText: true,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) =>
                                      setState(() => _rememberMe = value!),
                                  activeColor: AppConstants.primaryColor,
                                ),
                                Flexible(
                                  child: Text(
                                    "Remember Me",
                                    style: TextStyle(
                                      color: AppConstants.hintColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                              ),
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(color: AppConstants.primaryColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _signIn,
                        child: const Text("Login", style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          padding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: screenWidth * 0.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.defaultRadius,
                            ),
                          ),
                        ),
                      ),
                      if (!_isVerified) ...[
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _reverifyEmail,
                          child: const Text("Reverify Email",
                              style: TextStyle(fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: screenWidth * 0.15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(AppConstants.defaultRadius),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: Divider(color: AppConstants.hintColor)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text("Or",
                                style: TextStyle(color: AppConstants.hintColor)),
                          ),
                          Expanded(child: Divider(color: AppConstants.hintColor)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpPage()),
                        ),
                        child: Text(
                          "Don't have an account? Sign Up",
                          style: TextStyle(
                            color: AppConstants.primaryColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}