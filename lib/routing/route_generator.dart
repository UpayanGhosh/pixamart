import 'package:PixaMart/front_end/pages/helpSupport.dart';
import 'package:PixaMart/front_end/pages/login_page.dart';
import 'package:PixaMart/front_end/pages/settings_page.dart';
import 'package:PixaMart/front_end/pages/signup_page.dart';
import 'package:PixaMart/front_end/widget/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:PixaMart/front_end/pages/image_view_page.dart';
import 'package:PixaMart/front_end/pages/search_page.dart';
import 'package:PixaMart/front_end/pages/category_page.dart';
import 'package:PixaMart/front_end/pages/splash_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch(settings.name) {
      case '/':
        final args = settings.arguments;
        return MaterialPageRoute(builder: (context) => SplashScreen());
      case '/category':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (context) => CategoryPageNavigation(categoryName: args['categoryName'],));
      case '/imageView':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (context) => ImageView(imgShowUrl: args['imgShowUrl'], imgDownloadUrl: args['imgDownloadUrl'], alt: args['alt'],));
      case '/search':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (context) => SearchPageNavigation(searchQuery: args['searchQuery']));
      case '/navigationBar':
        return MaterialPageRoute(builder: (context) => AppBottomNavigationBar());
      case '/signUp':
        return MaterialPageRoute(builder: (context) => SignupPage());
      case '/login':
        return MaterialPageRoute(builder: (context) => LoginPage());
      case '/helpSupport':
        return MaterialPageRoute(builder: (context) => HelpSupport());
      case '/settings':
        return MaterialPageRoute(builder: (context) => SettingsPage());
      default:
        return MaterialPageRoute(builder: (context) => ErrorPage());
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
