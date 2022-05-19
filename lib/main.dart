import 'package:flutter/material.dart';
import 'package:pixamart/routing/route_generator.dart';
import 'package:pixamart/front_end/pages/spash_screen.dart';

void main() {
  runApp(
    SplashScreenPage(),
  );
}

class SplashScreenPage extends StatelessWidget {
  const SplashScreenPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Pixamart",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.black),
      home: SplashScreen(),
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}

