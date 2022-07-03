import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:PixaMart/front_end/pages/AccountPage.dart';
import 'package:PixaMart/front_end/pages/favourites_page.dart';
import 'package:PixaMart/front_end/pages/homepage.dart';
class Navigation_bar extends StatefulWidget {
  const Navigation_bar({Key? key}) : super(key: key);

  @override
  State<Navigation_bar> createState() => _Navigation_barState();
}

class _Navigation_barState extends State<Navigation_bar> {
  GlobalKey<CurvedNavigationBarState> _NavKey = GlobalKey();
  var pagesAll = [HomePage(),FavouritesPage(),AccountPage()];
  int myIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: pagesAll[myIndex],
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
              myIndex = index;
            });
        },
      ),
    );
  }
}
