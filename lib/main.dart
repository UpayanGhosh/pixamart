import 'package:flutter/material.dart';
import 'package:pixamart/front_end/pages/homepage.dart';
import 'package:pixamart/routing/route_generator.dart';

void main() {
  runApp(MaterialApp(
    title: "Pixamart",
    debugShowCheckedModeBanner: false,
    theme: ThemeData(primaryColor: Colors.black),
    home: HomePage(),
    onGenerateRoute: RouteGenerator.generateRoute,
  )
  );
}