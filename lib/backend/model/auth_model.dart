import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future registerWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      await auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }

  Future loginWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      final User? user = auth.currentUser;
      await auth.signInWithEmailAndPassword(
          email: email, password: password);
      return user;
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }

  Future loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }

  Future checkIfUserExists({required String email}) {
    return auth.fetchSignInMethodsForEmail(email);
  }

  Future logout() async {
    await auth.signOut();
  }
}
