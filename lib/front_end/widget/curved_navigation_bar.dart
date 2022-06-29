import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:pixamart/front_end/pages/AccountPage.dart';
import 'package:pixamart/front_end/pages/Favourites.dart';
import 'package:pixamart/front_end/pages/homepage.dart';
class Navigation_bar extends StatefulWidget {
  const Navigation_bar({Key? key}) : super(key: key);

  @override
  State<Navigation_bar> createState() => _Navigation_barState();
}

class _Navigation_barState extends State<Navigation_bar> {
  GlobalKey<CurvedNavigationBarState> _NavKey = GlobalKey();
  var PagesAll = [HomePage(),FavouritesPage(),AccountPage()];
  var myindex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.black,
        color: Colors.black,
        key: _NavKey,
          items: [
            Icon(Icons.home_outlined,color: Colors.blue,),
            Icon(Icons.favorite_outline,color: Colors.blue,),
            Icon(Icons.account_circle_outlined,color: Colors.blue,),
          ],
        buttonBackgroundColor: Colors.white,
        onTap: (index){
            setState((){
              myindex = index;
            });
        },
      ),
      body: PagesAll[myindex],
    );
  }
}
