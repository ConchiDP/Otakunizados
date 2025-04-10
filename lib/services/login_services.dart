import 'package:firebase_auth/firebase_auth.dart';

class LoginServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> loginWithEmailPassword(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      throw e.toString();
    }
  }
}
