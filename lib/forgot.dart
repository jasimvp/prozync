import 'package:flutter/material.dart';
import 'package:prozync/login.dart';

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key});

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 100,),
          Padding(
            padding: const EdgeInsets.only(left: 50.0),
            child: Text('Forgot Password?',style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Colors.blue[900]),),
          ),
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.only(left: 50.0),
            child: Text('Enter your email to reset your password',style: TextStyle(fontSize: 16,color: Colors.blueGrey),),
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
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 40,),
          Center(
            child: SizedBox(
              width: 350,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  // Add your onPressed code here!
                },
                child: Text('Reset Password',style: TextStyle(fontSize: 18),),
              ),
            ),
          ),
          SizedBox(height: 50,),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Remember your password? ',style: TextStyle(color: Colors.blueGrey),),
                SizedBox(width: 10,),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
                  },
                  child: Text('Login',style: TextStyle(color: Colors.blue[900],fontWeight: FontWeight.bold),),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}