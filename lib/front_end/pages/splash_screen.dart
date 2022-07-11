import 'package:PixaMart/front_end/pages/welcome_page.dart';
import 'package:PixaMart/front_end/widget/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:PixaMart/backend/model/auth_model.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({Key? key}) : super(key: key);
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
        splash: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Pixa',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height / 20.85,
                color: Colors.white,
                fontFamily: 'Raunchies',
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Mart',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height / 20.85,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                fontFamily: 'Raunchies',
              ),
            ),
          ],
        ),
        duration: 1000,
        backgroundColor: Colors.black,
        splashTransition: SplashTransition.fadeTransition,
        nextScreen: StreamBuilder(
          stream: _auth.credential.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // print(snapshot.data);
              return AppBottomNavigationBar();
            } else {
              return WelcomePage();
            }
          },
        ));
  }
}
