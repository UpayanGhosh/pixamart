// Todo try and add a notification system
// Todo try adding a showcase system for new users

import 'package:flutter/material.dart';
import 'package:PixaMart/routing/route_generator.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:PixaMart/front_end/pages/splash_screen.dart';
import 'package:PixaMart/backend/model/favourites_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDirectory.path);
  Hive.registerAdapter(FavouritesAdapter());
  //await Hive.openBox('currentUser');
  //Hive.box('currentUser').putAt(0, FirebaseAuth.instance.currentUser?.uid);
  //FirebaseAuth.instance.currentUser == null ? await Hive.openBox('favourites') : await Hive.openBox('${FirebaseAuth.instance.currentUser?.uid}-favourites');
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