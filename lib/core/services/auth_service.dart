import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return {'success': true, 'user': result.user};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> signup(Map<String, dynamic> data) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: data['email'],
        password: data['password'],
      );

      // Create user profile in Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'uid': result.user!.uid,
        'email': data['email'],
        'username': data['username'] ?? data['email'].split('@')[0],
        'full_name': data['full_name'] ?? '',
        'created_at': FieldValue.serverTimestamp(),
      });

      return {'success': true, 'user': result.user};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> resetPassword(Map<String, dynamic> data) async {
    // Firebase handles this via sendPasswordResetEmail which already sent the link
    // This might be for a manual reset if you have your own flow
    return true;
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> verifySignupOtp(String email, String otp) async {
    // Mock for now as Firebase doesn't have email OTP by default
    await Future.delayed(const Duration(seconds: 1));
    return {'success': true};
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  User? get currentUser => _auth.currentUser;
}
