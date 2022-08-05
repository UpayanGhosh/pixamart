import 'package:PixaMart/front_end/pages/category_page.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:PixaMart/front_end/pages/account_page.dart';
import 'package:PixaMart/front_end/pages/favourites_page.dart';
import 'package:PixaMart/front_end/pages/homepage.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

class AppBottomNavigationBar extends StatefulWidget {
  final PendingDynamicLinkData? initialLink;
  final Widget firstPage;
  final String? categoryName;
  const AppBottomNavigationBar({this.initialLink, required this.firstPage, this.categoryName, Key? key})
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
  late String categoryName;

  @override
  void initState() {
    super.initState();
    pageController = PageController(
      initialPage: 0,
    );
    pagesAll = [
      widget.firstPage,
      const FavouritesPage(),
      AccountPage()
    ];
    myIndex = 0.obs;
    iconSize = 0.0.obs;
    currentPage = 0;
    categoryName = widget.categoryName ?? '';
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
            AccountPage(),
          ]),
      bottomNavigationBar: Obx(
        () => CurvedNavigationBar(
          index: myIndex.value,
          height: MediaQuery.of(context).size.height <= 845
              ? MediaQuery.of(context).size.height / 11.27
              : 74,
          backgroundColor: Colors.black,
          color: Colors.black,
          key: _navKey,
          items: [
            Icon(
                widget.firstPage == HomePage(initialLink: widget.initialLink) ? Ionicons.home_outline : widget.firstPage == CategoryPage(categoryName: categoryName,) ? Icons.category_outlined : Icons.search_outlined,
                color: Colors.blue,
                size: iconSize / 37.90,
              ),
            Icon(
                Ionicons.heart_outline,
                color: Colors.blue,
                size: iconSize / 37.90,
              ),
            Icon(
                Icons.account_circle_outlined,
                color: Colors.blue,
                size: iconSize / 37.90,
              ),
          ],
          buttonBackgroundColor: Colors.white,
          onTap: (index) {
            myIndex.value = index;
            pageController.animateToPage(myIndex.value,
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut);
          },
        ),
      ),
    );
  }
}
