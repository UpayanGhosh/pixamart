import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:PixaMart/front_end/pages/account_page.dart';
import 'package:PixaMart/front_end/pages/favourites_page.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

class AppBottomNavigationBar extends StatefulWidget {
  final PendingDynamicLinkData? initialLink;
  final Widget firstPage;
  const AppBottomNavigationBar(
      {this.initialLink, required this.firstPage, Key? key})
      : super(key: key);

  @override
  State<AppBottomNavigationBar> createState() => _AppBottomNavigationBarState();
}

class _AppBottomNavigationBarState extends State<AppBottomNavigationBar> {
  late RxDouble iconSize;
  final GlobalKey<CurvedNavigationBarState> _navKey = GlobalKey();
  late List<Widget> pagesAll;
  late RxInt myIndex;
  late PageController pageController;
  late int currentPage;
  late String page;

  @override
  void initState() {
    super.initState();
    pageController = PageController(
      initialPage: 0,
    );
    pagesAll = [widget.firstPage, const FavouritesPage(), const AccountPage()];
    myIndex = 0.obs;
    iconSize = 0.0.obs;
    currentPage = 0;
  }

  @override
  Widget build(BuildContext context) {
    iconSize.value = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.black87,
      resizeToAvoidBottomInset: false,
      body: PageView(
          physics: const BouncingScrollPhysics(),
          controller: pageController,
          clipBehavior: Clip.antiAlias,
          onPageChanged: (page) {
            myIndex.value = page;
            setState(() {
              currentPage = myIndex.value;
            });
          },
          children: [
            //HomePage(initialLink: widget.initialLink),
            widget.firstPage,
            const FavouritesPage(),
            const AccountPage(),
          ]),
      bottomNavigationBar: Obx(
        () => CurvedNavigationBar(
          index: myIndex.value,
          height: MediaQuery.of(context).size.height <= 845
              ? MediaQuery.of(context).size.height / 11.27
              : MediaQuery.of(context).size.height / 11.4,
          backgroundColor: Colors.black,
          color: Colors.black,
          key: _navKey,
          items: [
            Icon(
              widget.firstPage.toString() == 'HomePage'
                  ? Ionicons.home_outline
                  : widget.firstPage.toString() == 'CategoryPage'
                      ? Icons.category_outlined
                      : Icons.search_outlined,
              color: Colors.blue,
              size: iconSize / 44.90,
            ),
            Icon(
              Ionicons.heart_outline,
              color: Colors.blue,
              size: iconSize / 44.90,
            ),
            Icon(
              Icons.account_circle_outlined,
              color: Colors.blue,
              size: iconSize / 44.90,
            ),
          ],
          buttonBackgroundColor: Colors.white,
          onTap: (index) {
            if (myIndex.value != index) {
              myIndex.value = index;
            } else {
              // Todo add code to scroll to top of page
            }
            pageController.animateToPage(myIndex.value,
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut);
          },
        ),
      ),
    );
  }
}
