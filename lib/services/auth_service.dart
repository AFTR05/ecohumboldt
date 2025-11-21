import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // REGISTRO
 Future<User?> registerUser(
    String email,
    String password,
    String fullName,
    String idNumber,
  ) async {
  try {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = cred.user;
    if (user == null) return null;

    await _db.collection("users").doc(user.uid).set({
      "email": email,
      "fullName": fullName,
      "idNumber": idNumber,
      "points": 0,
      "avatarUrl": "",
      "createdAt": DateTime.now().toIso8601String(),
    });

    return user;
  } catch (e) {
    print("ERROR en registerUser(): $e");
    rethrow;
  }
}


  // LOGIN
  Future<User?> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } catch (e) {
      print("ERROR en signIn(): $e");
      return null;
    }
  }

  // LOGOUT
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // USUARIO ACTUAL (instantáneo)
  User? get currentUser => _auth.currentUser;

  // 🔥 STREAM DE AUTH (para StreamProvider)
  Stream<User?> get userChanges => _auth.authStateChanges();
}
