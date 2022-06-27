import 'package:flutter/material.dart';
import 'package:pixamart/front_end/pages/Image_view_page.dart';
import '../front_end/pages/category_page.dart';
import '../front_end/pages/homepage.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch(settings.name) {
      case '/':
        final args = settings.arguments;
        return MaterialPageRoute(builder: (context) => HomePage());
      case '/category':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (context) => Category(categoryName: args['categoryName'],));
      case '/imageView':
        final args = settings.arguments as Map<String, dynamic>;
<<<<<<< Updated upstream
        return MaterialPageRoute(builder: (context) => ImageView(imgUrl: args['imgUrl']));
=======
        return MaterialPageRoute(builder: (context) => ImageView(imgShowUrl: args['imgShowUrl'], imgDownloadUrl: args['imgDownloadUrl'], alt: args['alt'],));
      case '/search':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (context) => Search(searchQuery: args['searchQuery']));
>>>>>>> Stashed changes
      default:
        return MaterialPageRoute(builder: (context) => ErrorPage());
    }
  }
}

class ErrorPage extends StatelessWidget {
  const ErrorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('You have come to the wrong place!'),
      ),
    );
  }
}
