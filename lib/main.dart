import 'package:flutter/material.dart';
import 'package:pixamart/routing/route_generator.dart';
import 'front_end/pages/spash_screen.dart';

void main() {
  runApp(MaterialApp(
    title: "Pixamart",
    debugShowCheckedModeBanner: false,
    theme: ThemeData(primaryColor: Colors.black),
    home: SplashScreen(),
    onGenerateRoute: RouteGenerator.generateRoute,
  )
  );
}

