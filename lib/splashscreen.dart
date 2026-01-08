import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Splashscreen extends StatelessWidget {
  const Splashscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   centerTitle: true,
      //   backgroundColor: Colors.white,
      //   title: Text('Prozync',style: GoogleFonts.archivoBlack(color: Colors.blue[900],fontSize: 32,fontWeight: FontWeight.bold,),),
      // ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 120,),
            Text('Prozync',style: GoogleFonts.archivoBlack(color: Colors.blue[900],fontSize: 32,fontWeight: FontWeight.bold,),),
            // SizedBox(height: 50,),
            CircleAvatar(radius: 120,backgroundImage: AssetImage('assets/icon/prozync.png'),),
            SizedBox(height: 30,),
            Text('Hello !',style: GoogleFonts.pacifico(color: Colors.blue[900],fontSize: 28,fontWeight: FontWeight.w600,),),
            SizedBox(height: 50,),
            ElevatedButton(
              onPressed: (){}, 
              child: Text('LOGIN'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900],foregroundColor: Colors.white,shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(20)),minimumSize: Size(250, 50)),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: (){}, 
              child: Text('SIGN UP'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white,foregroundColor: Colors.blue[900],shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(20)),minimumSize: Size(250, 50),side: BorderSide(color: Colors.blue.shade900,width: 2)),
            ),
          ],
        ),
      ),
    );
  }
}