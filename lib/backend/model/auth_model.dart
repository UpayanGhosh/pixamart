import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth credential = FirebaseAuth.instance;
  Stream<User?> get user {
    return credential.authStateChanges();
  }

  Future registerWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      UserCredential result = await credential.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      } else if (e.code == 'invalid-email') {
        print('Invalid email provided.');
      }
      return null;
    } catch (e) {
      print(e);
    }
  }

  Future loginWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      await credential.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  Future logout() async {
    await credential.signOut();
  }
}
