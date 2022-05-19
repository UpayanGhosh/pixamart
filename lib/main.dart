import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:pixamart/front_end/pages/homepage.dart';
import 'package:pixamart/routing/route_generator.dart';
import 'package:page_transition/page_transition.dart';

void main() {
  runApp(MaterialApp(
    title: "Pixamart",
    debugShowCheckedModeBanner: false,
    theme: ThemeData(primaryColor: Colors.black),
    home: const SplashScreen(),
    onGenerateRoute: RouteGenerator.generateRoute,
  )
  );
}
class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
        splash: Column(
          children: [
            Image.asset('assets/test_2-removebg-preview.png'),
          ],
        ),
        splashIconSize: 550,
        backgroundColor: Colors.black,
        splashTransition: SplashTransition.slideTransition,
        pageTransitionType: PageTransitionType.leftToRight,
        nextScreen: HomePage());
  }
}
