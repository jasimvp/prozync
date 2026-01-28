import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prozync/login.dart';
import 'package:prozync/signup.dart';
import 'package:prozync/core/services/auth_service.dart';
import 'package:prozync/features/main_navigation/main_navigation_screen.dart';
import 'package:prozync/core/services/profile_service.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn && mounted) {
      // Prefetch profile and verify token
      final success = await ProfileService().fetchMyProfile();
      
      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      } else {
        // If profile fetch fails (e.g. invalid token), go to login
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    } else if (mounted) {
      // Not logged in, go to home splash view (existing buttons will lead to login/signup)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      CircleAvatar(
                        radius: constraints.maxWidth * 0.25,
                        backgroundColor: Colors.transparent, // Ensure clean background
                        backgroundImage: const AssetImage('assets/icon/prozync.png'),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.04),
                      
                      // Welcome Text
                      Text(
                        'Hello !',
                        style: GoogleFonts.pacifico(
                          color: Colors.blue[900],
                          fontSize: constraints.maxWidth * 0.09, // slightly larger for emphasis
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.08),

                      // Login Button
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400), // Max width for wider screens
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[900],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 5,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text(
                            'LOGIN',
                            style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.03),

                      // Sign Up Button
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const Signupscreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blue[900],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            side: BorderSide(color: Colors.blue.shade900, width: 2),
                            elevation: 0,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text(
                            'SIGN UP',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
