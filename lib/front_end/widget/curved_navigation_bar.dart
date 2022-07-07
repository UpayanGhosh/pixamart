import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:PixaMart/front_end/pages/account_page.dart';
import 'package:PixaMart/front_end/pages/favourites_page.dart';
import 'package:PixaMart/front_end/pages/homepage.dart';
class AppBottomNavigationBar extends StatefulWidget {
  const AppBottomNavigationBar({Key? key}) : super(key: key);

  @override
  State<AppBottomNavigationBar> createState() => _AppBottomNavigationBarState();
}

class _AppBottomNavigationBarState extends State<AppBottomNavigationBar> {
  final GlobalKey<CurvedNavigationBarState> _navKey = GlobalKey();
  var pagesAll = [const HomePage(),const FavouritesPage(),const AccountPage()];
  int myIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: pagesAll[myIndex],
      bottomNavigationBar: CurvedNavigationBar(
        height: MediaQuery.of(context).size.height / 16.05,
        backgroundColor: Colors.black,
        color: Colors.black,
        key: _navKey,
        items: const [
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