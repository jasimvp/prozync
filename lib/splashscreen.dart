import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prozync/login.dart';
import 'package:prozync/signup.dart';

class Splashscreen extends StatelessWidget {
  const Splashscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 120,),
            // Text('Prozync',style: GoogleFonts.archivoBlack(color: Colors.blue[900],fontSize: 32,fontWeight: FontWeight.bold,),),
            // SizedBox(height: 50,),
            CircleAvatar(radius: 120,backgroundImage: AssetImage('assets/icon/prozync.png'),),
            SizedBox(height: 30,),
            Text('Hello !',style: GoogleFonts.pacifico(color: Colors.blue[900],fontSize: 28,fontWeight: FontWeight.w600,),),
            SizedBox(height: 50,),
            ElevatedButton(
              onPressed: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
              }, 
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900],foregroundColor: Colors.white,shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(20)),minimumSize: Size(250, 50)),
              child: Text('LOGIN'),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Signupscreen()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white,foregroundColor: Colors.blue[900],shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(20)),minimumSize: Size(250, 50),side: BorderSide(color: Colors.blue.shade900,width: 2)),
              child: Text('SIGN UP'),
            ),
          ],
        ),
      ),
    );
  }
}