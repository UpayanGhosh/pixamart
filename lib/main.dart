// Todo try and add a notification system (kingshuk)
// Todo try adding a showcase system for new users (kingshuk)

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
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
  final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
  print(initialLink.toString());
  runApp(PixaMartApp(initialLink: initialLink));
}

class PixaMartApp extends StatelessWidget {
  final PendingDynamicLinkData? initialLink;
  const PixaMartApp({required this.initialLink, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: SplashScreen(initialLink: initialLink),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.black),
      title: 'PixaMart',
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
