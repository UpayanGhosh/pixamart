import 'package:PixaMart/front_end/pages/homepage.dart';
import 'package:PixaMart/front_end/pages/welcome_page.dart';
import 'package:PixaMart/front_end/widget/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:PixaMart/backend/model/auth_model.dart';
import 'package:hive/hive.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final AuthService _auth;

  @override
  void initState() {
    super.initState();
    _auth = AuthService();

  }

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
                stream: _auth.auth.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Hive.openBox('${_auth.auth.currentUser?.uid}-favourites');
                    Hive.openBox('${_auth.auth.currentUser?.uid}-downloads');
                    return FutureBuilder(
                      future: Hive.openBox('${_auth.auth.currentUser?.uid}-favourites'),
                      builder: (context, snapshot) {
                        if(snapshot.connectionState == ConnectionState.done) {
                          if(snapshot.hasData) {
                            return AppBottomNavigationBar(initialLink: null, firstPage: HomePage(initialLink: null),);
                          } else {
                            return const Scaffold(
                              backgroundColor: Colors.black87,
                            );
                          }
                        } else {
                          return const Scaffold(
                            backgroundColor: Colors.black87,
                          );
                        }
                      },
                    );
                  } else {
                    return WelcomePage(initialLink: null);
                  }
                },
              ),
    );
              }
  }
