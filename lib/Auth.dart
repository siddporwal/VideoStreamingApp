import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth {
  Future<String> signInWithEmailAndPassword(String email, String password);
  Future<String> createUserWithEmailAndPassword(String email, String password);
  Future<String> currentUser();
  Future<void> signOut();
  Future forgotPassword(String email);
}

class Auth implements BaseAuth {
  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    AuthResult result = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.toString().trim(), password: password);
    return result.user.uid;
  }

  Future<String> createUserWithEmailAndPassword(
      String email, String password) async {
    AuthResult result = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: email.toString().trim(), password: password);
    return result.user.uid;
  }

  Future forgotPassword(String email) async {
    try {
      return await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e.message);
      return e.message;
    }
  }

  Future<String> currentUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return user?.uid;
  }

  Future<void> signOut() async {
    return FirebaseAuth.instance.signOut();
  }
}
