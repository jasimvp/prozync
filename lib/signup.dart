import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prozync/login.dart';

class Signupscreen extends StatefulWidget {
  const Signupscreen({super.key});

  @override
  State<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends State<Signupscreen> {
  bool _isPasswordVisible = true;
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Column(
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
          SizedBox(height: screenHeight * 0.05),
          Center(
            child: SizedBox(
              width: screenWidth * 0.8,
              child: TextFormField(
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
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: Size(screenWidth * 0.5, screenHeight * 0.06),
                backgroundColor: Colors.blue[900],
              ),
              child: Text(
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
    );
  }
}
