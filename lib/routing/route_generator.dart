import 'package:PixaMart/front_end/pages/helpSupport.dart';
import 'package:PixaMart/front_end/pages/login_page.dart';
import 'package:PixaMart/front_end/pages/signup_page.dart';
import 'package:PixaMart/front_end/widget/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:PixaMart/front_end/pages/image_view_page.dart';
import 'package:PixaMart/front_end/pages/search_page.dart';
import 'package:PixaMart/front_end/pages/category_page.dart';
import 'package:PixaMart/front_end/pages/splash_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    if(settings.name == '/') {
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(builder: (context) => SplashScreen(initialLink: args['initialLink'],));
    }
    if(settings.name == '/category') {
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
          builder: (context) => AppBottomNavigationBar(
            firstPage: CategoryPage(categoryName: args['categoryName'],),
            categoryName: args['categoryName'],
          ));
    }
    if(settings.name?.split('/')[1] == 'imageView') {
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
          builder: (context) => ImageView(
            imgShowUrl: args['imgShowUrl'],
            imgDownloadUrl: args['imgDownloadUrl'],
            alt: args['alt'],
          ));
    }
    if(settings.name == '/search') {
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
          builder: (context) =>
              SearchPage(searchQuery: args['searchQuery']));
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
    else {
      return MaterialPageRoute(builder: (context) => const ErrorPage());
    }
    /*switch (settings.name) {
      case '/':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (context) => SplashScreen(initialLink: args['initialLink'],));
      case '/category':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
            builder: (context) => CategoryPageNavigation(
                  categoryName: args['categoryName'],
                ));
      case settings.name.split('/')[1] == 'imageView':
        print('args = ${settings.arguments}');
        print('name = ${settings.name}');
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
            builder: (context) => ImageView(
                  imgShowUrl: args['imgShowUrl'],
                  imgDownloadUrl: args['imgDownloadUrl'],
                  alt: args['alt'],
                ));
      case '/search':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
            builder: (context) =>
                SearchPageNavigation(searchQuery: args['searchQuery']));
      case '/navigationBar':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
            builder: (context) => AppBottomNavigationBar(initialLink: args['initialLink'],));
      case '/signUp':
        return MaterialPageRoute(builder: (context) => SignupPage());
      case '/login':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (context) => LoginPage(initialLink: args['initialLink']));
      case '/helpSupport':
        return MaterialPageRoute(builder: (context) => HelpSupport());
      default:
        return MaterialPageRoute(builder: (context) => ErrorPage());
    }*/
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
