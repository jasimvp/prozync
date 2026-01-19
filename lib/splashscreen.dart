import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prozync/login.dart';
import 'package:prozync/signup.dart';

class Splashscreen extends StatelessWidget {
  const Splashscreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.15),
            CircleAvatar(
              radius: screenWidth * 0.25,
              backgroundImage: const AssetImage('assets/icon/prozync.png'),
            ),
            SizedBox(height: screenHeight * 0.04),
            Text(
              'Hello !',
              style: GoogleFonts.pacifico(
                color: Colors.blue[900],
                fontSize: screenWidth * 0.07,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: screenHeight * 0.06),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: Size(screenWidth * 0.6, screenHeight * 0.06),
              ),
              child: Text(
                'LOGIN',
                style: TextStyle(fontSize: screenWidth * 0.04),
              ),
            ),
            SizedBox(height: screenHeight * 0.04),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Signupscreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: Size(screenWidth * 0.6, screenHeight * 0.06),
                side: BorderSide(color: Colors.blue.shade900, width: 2),
              ),
              child: Text(
                'SIGN UP',
                style: TextStyle(fontSize: screenWidth * 0.04),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
