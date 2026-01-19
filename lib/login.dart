import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prozync/forgot.dart';
import 'package:prozync/signup.dart';
import 'package:prozync/features/main_navigation/main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      // appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: screenHeight * 0.06),

          Padding(
            padding: EdgeInsets.only(left: screenWidth * 0.1),
            child: Text(
              'Welcome !',
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
              'sign in to continue',
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
          SizedBox(height: screenHeight * 0.05),
          Center(
            child: SizedBox(
              width: screenWidth * 0.8,
              child: TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
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
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: Size(screenWidth * 0.5, screenHeight * 0.06),
              ),
              child: Text(
                'LOGIN',
                style: TextStyle(fontSize: screenWidth * 0.04),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          GestureDetector(
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ForgotScreen()),
            ),
            child: Center(
              child: Text(
                'forgot password?',
                style: GoogleFonts.manrope(
                  color: Colors.blue[900],
                  fontSize: screenWidth * 0.04,
                ),
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
          SizedBox(height: screenHeight * 0.04),
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
          SizedBox(height: screenHeight * 0.18),
          Container(
            margin: EdgeInsets.only(left: screenWidth * 0.1),
            child: Row(
              children: [
                Text(
                  "Don't have an account?",
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
                      MaterialPageRoute(builder: (context) => Signupscreen()),
                    );
                  },
                  child: Text(
                    'Sign Up',
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
    );
  }
}
