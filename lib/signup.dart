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
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 50,),
          Padding(
            padding: const EdgeInsets.only(left: 50.0),
            child: Text('Hi !',style: GoogleFonts.manrope(color: Colors.blue[900],fontSize: 34,fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.only(left: 50.0),
            child: Text('create a new account',style: GoogleFonts.manrope(color: Colors.blueGrey),),
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
                decoration: InputDecoration(
                  labelText: 'username',
                  prefixIcon: Icon(Icons.verified_user_outlined,color: Colors.blue[900],),
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
                obscureText: _isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      color: Colors.blue[900],
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
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
              style: ElevatedButton.styleFrom(foregroundColor: Colors.white,shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(20)),minimumSize: Size(230, 50),backgroundColor: Colors.blue[900]),
              child: Text('SIGN UP'),
            ),
          ),
          SizedBox(height: 50,),
          Row(
            children: [
              Expanded(child: Divider(thickness: 2,indent: 40,endIndent: 10,)),
              Text('or'),
              Expanded(child: Divider(thickness: 2,indent: 10,endIndent: 40,)),
            ],
          ),
          SizedBox(height: 50,),
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
          SizedBox(height: 70,),
          Container(
            margin: EdgeInsets.only(left: 50),
            child: Row(
              children: [
                Text("Already have an account?",style: GoogleFonts.manrope(color: Colors.blueGrey),),
                SizedBox(width: 10,),
                GestureDetector(
                  
                  onTap: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
                  },
                  child: Text('Sign In',style: GoogleFonts.manrope(color: Colors.blue[900],fontWeight: FontWeight.bold),),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}