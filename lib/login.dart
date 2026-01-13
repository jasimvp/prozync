import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prozync/forgot.dart';
import 'package:prozync/signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 50,),

          Padding(
            padding: const EdgeInsets.only(left: 50.0),
            child: Text('Welcome !',style: GoogleFonts.manrope(color: Colors.blue[900],fontSize: 32,fontWeight: FontWeight.bold),),
          ),

          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.only(left: 50.0),
            child: Text('sign in to continue',style: GoogleFonts.manrope(color: Colors.blueGrey),),
          ),
          SizedBox(height: 100,),
          Center(
            child: SizedBox(
              width: 350,
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined,color: Colors.blue[900],),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 40,),
          Center(
            child: SizedBox(
              width: 350,
              child: TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline,color: Colors.blue[900],),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 50,),
          Center(
            child: ElevatedButton(
              onPressed: (){},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900],foregroundColor: Colors.white,shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(20)),minimumSize: Size(230, 50)),
              child: Text('LOGIN'),
            ),
          ),
          SizedBox(height: 10,),
          GestureDetector(
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ForgotScreen())),
            child: Center(child: Text('forgot password?',style: GoogleFonts.manrope(color: Colors.blue[900]),))),
          SizedBox(height: 50,),
          Row(
            children: [
              Expanded(child: Divider(thickness: 2,indent: 40,endIndent: 10,)),
              Text('or'),
              Expanded(child: Divider(thickness: 2,indent: 10,endIndent: 40,)),
            ],
          ),
          SizedBox(height: 30,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.facebook,color: Colors.blue[900],size: 40,),
              SizedBox(width: 10,),
              FaIcon(FontAwesomeIcons.google,color: Colors.green, size: 30,),
              SizedBox(width: 10,),
              Icon(Icons.apple,color: Colors.black,size: 40,),
            ],
          ),
          SizedBox(height: 150,),
          Container(
            margin: EdgeInsets.only(left: 50),
            child: Row(
              children: [
                Text("Don't have an account?",style: GoogleFonts.manrope(color: Colors.blueGrey),),
                SizedBox(width: 10,),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Signupscreen()));
                  },
                  child: Text('Sign Up',style: GoogleFonts.manrope(color: Colors.blue[900],fontWeight: FontWeight.bold),)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}