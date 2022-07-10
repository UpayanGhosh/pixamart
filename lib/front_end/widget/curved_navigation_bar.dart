import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:PixaMart/front_end/pages/account_page.dart';
import 'package:PixaMart/front_end/pages/favourites_page.dart';
import 'package:PixaMart/front_end/pages/homepage.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';


class AppBottomNavigationBar extends StatefulWidget {
  const AppBottomNavigationBar({Key? key}) : super(key: key);

  @override
  State<AppBottomNavigationBar> createState() => _AppBottomNavigationBarState();
}

class _AppBottomNavigationBarState extends State<AppBottomNavigationBar> {
  late RxDouble iconSize;
  final GlobalKey<CurvedNavigationBarState> _navKey = GlobalKey();
  late List<Widget> pagesAll;
  late int myIndex;

  @override
  void initState() {
    super.initState();
    pagesAll = [
    const HomePage(),
    const FavouritesPage(),
    const AccountPage()
    ];
    myIndex = 0;
    iconSize = 0.0.obs;
  }
  @override
  Widget build(BuildContext context) {
    iconSize.value = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.black87,
      resizeToAvoidBottomInset: false,
      body: pagesAll[myIndex],
      bottomNavigationBar: CurvedNavigationBar(
        height: MediaQuery.of(context).size.height / 11.27,
        backgroundColor: Colors.black,
        color: Colors.black,
        key: _navKey,
        items: [
          Obx(
            () => Icon(
              Ionicons.home_outline,
              color: Colors.blue,
              size: iconSize / 37.90,
            ),
          ),
          Obx(
            () => Icon(
              Ionicons.heart_outline,
              color: Colors.blue,
              size: iconSize / 37.90,
            ),
          ),
          Obx(
          () => Icon(
              Icons.account_circle_outlined,
              color: Colors.blue,
              size: iconSize / 37.90,
            ),
          ),
        ],
        buttonBackgroundColor: Colors.white,
        onTap: (index) {
          setState(() {
            myIndex = index;
          });
        },
      ),
    );
  }
}
