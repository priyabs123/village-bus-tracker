import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'background_service.dart';

class LoginScreen extends StatefulWidget {
  final String role;
  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;
  bool isSignUp = false;
  bool obscurePassword = true;
  bool obscureConfirm = true;
  String errorMessage = '';

  final String adminEmail = 'admin@villagebustrack.com';

  Future<void> _handleAuth() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() => errorMessage = 'Enter email & password');
      return;
    }

    if (isSignUp &&
        _passwordController.text != _confirmController.text) {
      setState(() => errorMessage = 'Passwords do not match');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      if (isSignUp) {
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }

      _navigateToRole(_emailController.text.trim());
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.message ?? 'Error';
      });
    }
  }

  void _navigateToRole(String email) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('userRole', widget.role);
    await prefs.setString('userEmail', email);

    if (email == adminEmail) {
      await prefs.setString('userRole', 'admin');
      Navigator.pushReplacementNamed(context, '/admin');
    } else if (widget.role == 'driver') {
      await initializeBackgroundService();
      Navigator.pushReplacementNamed(context, '/driver');
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          // 🔥 BACKGROUND IMAGE
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/bg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 🔥 DARK OVERLAY
          Container(
            color: Colors.black.withOpacity(0.7),
          ),

          // 🔥 CONTENT
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),

              child: Column(
                children: [

                  const SizedBox(height: 40),

                  const Text(
                    "Village Bus Tracker",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 🔥 GLASS CARD
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),

                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(25),
                        ),

                        child: Column(
                          children: [

                            TextField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputStyle("Email", Icons.email),
                            ),

                            const SizedBox(height: 15),

                            TextField(
                              controller: _passwordController,
                              obscureText: obscurePassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputStyle("Password", Icons.lock)
                                  .copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() =>
                                        obscurePassword = !obscurePassword);
                                  },
                                ),
                              ),
                            ),

                            if (isSignUp) ...[
                              const SizedBox(height: 15),
                              TextField(
                                controller: _confirmController,
                                obscureText: obscureConfirm,
                                style:
                                    const TextStyle(color: Colors.white),
                                decoration:
                                    _inputStyle("Confirm Password",
                                        Icons.lock_outline)
                                        .copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      obscureConfirm
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() =>
                                          obscureConfirm = !obscureConfirm);
                                    },
                                  ),
                                ),
                              ),
                            ],

                            if (errorMessage.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                errorMessage,
                                style:
                                    const TextStyle(color: Colors.red),
                              ),
                            ],

                            const SizedBox(height: 20),

                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed:
                                    isLoading ? null : _handleAuth,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(30),
                                  ),
                                ),
                                child: isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : Text(
                                        isSignUp
                                            ? "Create Account"
                                            : "Login",
                                        style: const TextStyle(
                                            fontSize: 18),
                                      ),
                              ),
                            ),

                            TextButton(
                              onPressed: () {
                                setState(() {
                                  isSignUp = !isSignUp;
                                  errorMessage = '';
                                });
                              },
                              child: Text(
                                isSignUp
                                    ? "Already have account? Login"
                                    : "New user? Create account",
                                style: const TextStyle(
                                    color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputStyle(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      prefixIcon: Icon(icon, color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
    );
  }
}

