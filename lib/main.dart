import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:PixaMart/front_end/widget/curved_navigation_bar.dart';
import 'package:PixaMart/routing/route_generator.dart';

void main() {
  runApp(
    MaterialApp(
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.black),
      title: 'PixaMart',
      onGenerateRoute: RouteGenerator.generateRoute,
    ),
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
