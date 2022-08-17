import 'package:PixaMart/front_end/pages/check_if_logged_in.dart';
import 'package:PixaMart/front_end/pages/helpSupport.dart';
import 'package:PixaMart/front_end/pages/login_page.dart';
import 'package:PixaMart/front_end/pages/signup_page.dart';
import 'package:PixaMart/front_end/pages/welcome_page.dart';
import 'package:PixaMart/front_end/widget/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:PixaMart/front_end/pages/image_view_page.dart';
import 'package:PixaMart/front_end/pages/search_page.dart';
import 'package:PixaMart/front_end/pages/category_page.dart';
import 'package:PixaMart/front_end/pages/splash_screen.dart';

class RouteGenerator {
  PendingDynamicLinkData? initialLink;
  Route<dynamic> generateRoute(RouteSettings settings) {
    if(settings.name == '/') {
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(builder: (context) => const SplashScreen());
    }
    if(settings.name == '/category') {
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
          builder: (context) => AppBottomNavigationBar(
            firstPage: CategoryPage(categoryName: args['categoryName'],)
          ));
    }
    if(settings.name?.split('/')[1] == 'imageView') {
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
          builder: (context) => ImageView(
            imgShowUrl: args['imgShowUrl'],
            imgDownloadUrl: args['imgDownloadUrl'],
            imgTinyUrl: args['imgTinyUrl'], initialLink: null,
          ));
    }
    if(settings.name == '/search') {
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
          builder: (context) =>
              AppBottomNavigationBar(firstPage: SearchPage(searchQuery: args['searchQuery'])));
    }
    if(settings.name == '/navigationBar') {
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
          builder: (context) => AppBottomNavigationBar(initialLink: args['initialLink'], firstPage: args['firstPage'],));
    }
    if(settings.name == '/signUp') {
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(builder: (context) => SignupPage(initialLink: args['initialLink']));
    }
    if(settings.name == '/login') {
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(builder: (context) => LoginPage(initialLink: args['initialLink']));
    }
    if(settings.name == '/helpSupport') {
      return MaterialPageRoute(builder: (context) => const HelpSupport());
    }
    if(RegExp(r'\/\w+').hasMatch(settings.name!)) {
      /*if(FirebaseAuth.instance.currentUser?.uid != null) {
        return MaterialPageRoute(builder: (context) => ImageView(imgShowUrl: 'shared', imgDownloadUrl: 'shared', imgTinyUrl: 'shared', initialLink: initialLink,));
      } else {
        return MaterialPageRoute(builder: (context) => WelcomePage(initialLink: initialLink));
      }*/
      return MaterialPageRoute(builder: (context) => CheckIfShared(initialLink: initialLink));
    }
    else {
      print(settings.name);
      return MaterialPageRoute(builder: (context) => const ErrorPage());
    }
  }
}

class ErrorPage extends StatelessWidget {
  const ErrorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('You have come to the wrong place!'),
      ),
    );
  }
}
