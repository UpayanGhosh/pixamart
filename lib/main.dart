//Todo try and add a notification system

import 'package:flutter/material.dart';
import 'package:PixaMart/routing/route_generator.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:PixaMart/front_end/pages/splash_screen.dart';
import 'package:PixaMart/backend/model/favourites_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDirectory.path);
  Hive.registerAdapter(FavouritesAdapter());
  await Hive.openBox('favourites');
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(
    PixaMartApp()
  );
}

class PixaMartApp extends StatelessWidget {
  const PixaMartApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.black),
      title: 'PixaMart',
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}