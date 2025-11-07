import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signIn(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Error en login: $e');
      return null;
    }
  }

  Future<User?> registerUser(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Error en registro: $e');
      rethrow;
    }
  }

  Future<void> signOut() async => await _auth.signOut();

  Stream<User?> get user => _auth.authStateChanges();
}
