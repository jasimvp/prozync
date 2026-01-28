import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prozync/login.dart';
import 'package:prozync/core/services/auth_service.dart';

class Signupscreen extends StatefulWidget {
  const Signupscreen({super.key});

  @override
  State<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends State<Signupscreen> {
  bool _isPasswordVisible = true;
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  void _handleSignup() async {
    if (_emailController.text.isEmpty || _usernameController.text.isEmpty || _passwordController.text.isEmpty || _fullNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final result = await _authService.signup({
      'email': _emailController.text.trim(),
      'username': _usernameController.text.trim(),
      'full_name': _fullNameController.text.trim(),
      'password': _passwordController.text.trim(),
    });

    if (mounted) setState(() => _isLoading = false);

    if (result['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup successful! Please login.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Signup failed. Please try again.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.06),
            Padding(
              padding: EdgeInsets.only(left: screenWidth * 0.1),
              child: Text(
                'Hi !',
                style: GoogleFonts.manrope(
                  color: Colors.blue[900],
                  fontSize: screenWidth * 0.08,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Padding(
              padding: EdgeInsets.only(left: screenWidth * 0.1),
              child: Text(
                'create a new account',
                style: GoogleFonts.manrope(
                  color: Colors.blueGrey,
                  fontSize: screenWidth * 0.04,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.12),
            Center(
              child: SizedBox(
                width: screenWidth * 0.8,
                child: TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: Colors.blue[900],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Center(
              child: SizedBox(
                width: screenWidth * 0.8,
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: Colors.blue[900],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Center(
              child: SizedBox(
                width: screenWidth * 0.8,
                child: TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'username',
                    prefixIcon: Icon(
                      Icons.verified_user_outlined,
                      color: Colors.blue[900],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Center(
              child: SizedBox(
                width: screenWidth * 0.8,
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: _isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.blue[900],
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    prefixIcon: Icon(Icons.lock_outline, color: Colors.blue[900]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.06),
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSignup,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: Size(screenWidth * 0.5, screenHeight * 0.06),
                  backgroundColor: Colors.blue[900],
                ),
                child: _isLoading 
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      'SIGN UP',
                      style: TextStyle(fontSize: screenWidth * 0.04),
                    ),
              ),
            ),
          SizedBox(height: screenHeight * 0.06),
          Row(
            children: [
              Expanded(
                child: Divider(
                  thickness: 2,
                  indent: screenWidth * 0.1,
                  endIndent: screenWidth * 0.02,
                ),
              ),
              Text('or'),
              Expanded(
                child: Divider(
                  thickness: 2,
                  indent: screenWidth * 0.02,
                  endIndent: screenWidth * 0.1,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.06),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.facebook,
                color: Colors.blue[900],
                size: screenWidth * 0.1,
              ),
              SizedBox(width: screenWidth * 0.03),
              FaIcon(
                FontAwesomeIcons.google,
                color: Colors.green,
                size: screenWidth * 0.08,
              ),
              SizedBox(width: screenWidth * 0.03),
              Icon(Icons.apple, color: Colors.black, size: screenWidth * 0.1),
            ],
          ),
          SizedBox(height: screenHeight * 0.08),
          Container(
            margin: EdgeInsets.only(left: screenWidth * 0.1),
            child: Row(
              children: [
                Text(
                  "Already have an account?",
                  style: GoogleFonts.manrope(
                    color: Colors.blueGrey,
                    fontSize: screenWidth * 0.04,
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text(
                    'Sign In',
                    style: GoogleFonts.manrope(
                      color: Colors.blue[900],
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}
