import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pixamart/front_end/pages/homepage.dart';
import 'package:pixamart/front_end/widget/Drawer.dart';
import 'package:pixamart/front_end/widget/curved_navigation_bar.dart';
import 'package:pixamart/routing/route_generator.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rive/rive.dart';

void main() {
  runApp(
    SplashScreenPage(),
  );
}
class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
        splash: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Pixa', style: TextStyle(
              fontSize: MediaQuery.of(context).size.width / 12,
              color: Colors.white,
              fontFamily: 'Raunchies',
              fontWeight: FontWeight.bold,
            ),),
            Text('Mart', style: TextStyle(
              fontSize: MediaQuery.of(context).size.width / 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              fontFamily: 'Raunchies',
            ),),
          ],
        ),
        duration: 1000,
        backgroundColor: Colors.black,
        splashTransition: SplashTransition.fadeTransition,
        nextScreen: Navigation_bar()
    );
  }
  }
