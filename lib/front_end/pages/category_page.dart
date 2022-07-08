// This Page is for when the user clicks on a Category tile and lands on the page where all of the images of the same category is shown

import 'dart:convert';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:PixaMart/front_end/widget/search_bar.dart';
import 'package:PixaMart/private/get_pexels_api_key.dart';
import 'package:PixaMart/backend/model/wallpaper_model.dart';
import 'package:PixaMart/front_end/widget/app_title.dart';
import 'package:PixaMart/private/api_key.dart';
import 'package:PixaMart/backend/model/favourites_model.dart';
import 'package:PixaMart/front_end/pages/account_page.dart';
import 'package:PixaMart/front_end/pages/favourites_page.dart';
import 'package:flutter/services.dart';

class CategoryPageNavigation extends StatefulWidget {
  final String categoryName;
  const CategoryPageNavigation({Key? key, required this.categoryName})
      : super(key: key);

  @override
  State<CategoryPageNavigation> createState() => _CategoryPageNavigationState();
}

class _CategoryPageNavigationState extends State<CategoryPageNavigation> {
  late GlobalKey<CurvedNavigationBarState> _navKey;
  late List<Widget> pagesAll;
  late int myIndex;

  @override
  void initState() {
    super.initState();
    _navKey = GlobalKey();
    pagesAll = [
      CategoryPage(categoryName: widget.categoryName),
      const FavouritesPage(),
      const AccountPage()
    ];
    myIndex = 0;
  }

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
          Icon(
            Icons.category_outlined,
            color: Colors.blue,
          ),
          Icon(
            Icons.favorite_outline,
            color: Colors.blue,
          ),
          Icon(
            Icons.account_circle_outlined,
            color: Colors.blue,
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

class CategoryPage extends StatefulWidget {
  final String categoryName;
  const CategoryPage({Key? key, required this.categoryName}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late ScrollController scrollController;
  late int page;
  List<dynamic> photoList = [];
  late double currentMaxScrollExtent;
  late Future<Box> favouritesBox;
  late Box<dynamic> favouritesList;

  Future<List<dynamic>> getSearchWallpapers(String query) async {
    Response url = await get(
        Uri.parse("https://api.pexels.com/v1/search?query=$query&per_page=80"),
        headers: {"Authorization": getPexelsApiKey()});
    if (url.statusCode == 200) {
      dynamic body = jsonDecode(url.body);
      List<dynamic> photos =
          body['photos'].map((dynamic item) => Photos.fromJson(item)).toList();
      photoList.addAll(photos);
      scrollController.addListener(() async {
        if (scrollController.offset >=
                scrollController.position.maxScrollExtent &&
            !scrollController.position.outOfRange) {
          if (currentMaxScrollExtent <
              scrollController.position.maxScrollExtent) {
            currentMaxScrollExtent = scrollController.position.maxScrollExtent;
            Response url = await get(
                Uri.parse(
                    'https://api.pexels.com/v1/search?query=$query/?page=$page&per_page=80'),
                headers: {"Authorization": getPexelsApiKey()});
            page++;
            if (url.statusCode == 200) {
              Map<String, dynamic> newPhotos = jsonDecode(url.body);
              List<dynamic> photos = newPhotos['photos']
                  .map((dynamic item) => Photos.fromJson(item))
                  .toList();
              setState(() {
                photoList.addAll(photos);
              });
            } else {
              throw Exception('Failed to Fetch Curated');
            }
          }
        }
      });
      return photoList;
    } else {
      swapKeys();
      return photoList;
      //throw Exception('Failed to Fetch Photos');
    }
  }

  checkIfLiked({required String imgShowUrl}) {
    int alreadyLikedAt = -1;
    for (int i = 0; i < favouritesList.length; i++) {
      if (imgShowUrl == (favouritesList.getAt(i) as Favourites).imgShowUrl) {
        alreadyLikedAt = i;
      }
    } // Todo find a better searching solution (Kingshuk/upayan)
    return alreadyLikedAt;
  }

  handleLiked(
      {required String imgShowUrl,
      required String imgDownloadUrl,
      required String alt}) {
    Favourites fav = Favourites(imgShowUrl, imgDownloadUrl, alt);
    int index = checkIfLiked(imgShowUrl: imgShowUrl);
    if (index == -1) {
      Hive.box('favourites').add(fav);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Added to Favourites!!', style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Nexa'
        ),),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            Hive.box('favourites').deleteAt(Hive.box('favourites').length - 1);
            setState(() {});
          },
        ),
      ));
    } else {
      Hive.box('favourites').deleteAt(index);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Removed from Favourites!!', style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Nexa'
        ),),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            Favourites lastDeleted =
                Favourites(fav.imgShowUrl, fav.imgDownloadUrl, fav.alt);
            favouritesList.add(lastDeleted);
            setState(() {});
          },
        ),
      ));
    }
    setState(() {});
    HapticFeedback.lightImpact();
  }

  @override
  void initState() {
    favouritesBox = Hive.openBox('favourites');
    getSearchWallpapers(widget.categoryName);
    page = 2;
    currentMaxScrollExtent = 0.0;
    scrollController = ScrollController();
    favouritesList = Hive.box('favourites');
    super.initState();
  }

  @override
  void dispose() {
    photoList.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: favouritesBox,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.black,
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  centerTitle: true,
                  elevation: 0.0,
                  backgroundColor: Colors.transparent,
                  title: AppTitle(
                      padLeft: MediaQuery.of(context).size.width / 8,
                      padTop: MediaQuery.of(context).size.height / 15,
                      padRight: MediaQuery.of(context).size.width / 10,
                      padBottom: 0),
                ),
                body: Column(
                  children: [
                    const SearchBar(),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 80,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 1.43,
                      child: FutureBuilder(
                        future: getSearchWallpapers(widget.categoryName),
                        builder:
                            (context, AsyncSnapshot<List<dynamic>> snapshot) {
                          if (snapshot.hasData) {
                            List<dynamic> photos = snapshot.data!;
                            return Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width /
                                              24.5),
                                  child: GridView.count(
                                    controller: scrollController,
                                    physics: const BouncingScrollPhysics(),
                                    shrinkWrap: true,
                                    childAspectRatio: 0.61,
                                    scrollDirection: Axis.vertical,
                                    crossAxisCount: 2,
                                    crossAxisSpacing:
                                        MediaQuery.of(context).size.width /
                                            39.2,
                                    mainAxisSpacing: 0,
                                    children: photoList
                                        .map(
                                          (dynamic photo) => GridTile(
                                            child: Stack(
                                              alignment: Alignment.bottomRight,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  child: GestureDetector(
                                                    onDoubleTap: () {
                                                      handleLiked(
                                                          imgShowUrl: photo
                                                              .src.portrait,
                                                          imgDownloadUrl: photo
                                                              .src.original,
                                                          alt: photo.alt);
                                                    },
                                                    onTap: () {
                                                      Navigator.pushNamed(
                                                          context, '/imageView',
                                                          arguments: {
                                                            'imgShowUrl': photo
                                                                .src.portrait,
                                                            'imgDownloadUrl':
                                                                photo.src
                                                                    .original,
                                                            'alt': photo.alt
                                                          });
                                                    },
                                                    child: Hero(
                                                      tag: photo.src.portrait,
                                                      child: Image.network(
                                                        '${photo.src.portrait}',
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    handleLiked(
                                                        imgShowUrl:
                                                            photo.src.portrait,
                                                        imgDownloadUrl:
                                                            photo.src.original,
                                                        alt: photo.alt);
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Builder(
                                                        builder: (context) {
                                                      if (checkIfLiked(
                                                              imgShowUrl: photo
                                                                  .src
                                                                  .portrait) ==
                                                          -1) {
                                                        return const Icon(
                                                          Icons
                                                              .favorite_outline_rounded,
                                                          color: Colors.pink,
                                                        );
                                                      } else {
                                                        return const Icon(
                                                          Icons
                                                              .favorite_outlined,
                                                          color: Colors.pink,
                                                        );
                                                      }
                                                    }),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width /
                                              24.5,
                                      vertical:
                                          MediaQuery.of(context).size.height /
                                              50.15),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      scrollController.animateTo(
                                          (MediaQuery.of(context).size.height /
                                                  4.7) *
                                              -1,
                                          duration:
                                              const Duration(milliseconds: 400),
                                          curve: Curves
                                              .easeOutSine); // easeinexpo, easeoutsine
                                    },
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.black54,
                                        shape: const CircleBorder()),
                                    child: Lottie.asset(
                                        'assets/lottie/Rocket.json',
                                        height:
                                            MediaQuery.of(context).size.height /
                                                13.5,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                12.5,
                                        fit: BoxFit.fill),
                                  ),
                                ),
                              ],
                            );
                          } else if (snapshot.hasError) {
                            return const Center(
                                child: Text('Failed to Load Wallpapers'));
                          }
                          return Center(
                              child: Lottie.asset(
                            'assets/lottie/Loading.json',
                            height: MediaQuery.of(context).size.height / 4,
                            width: MediaQuery.of(context).size.width / 1.96,
                          ));
                        },
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const Text(
                  'data'); // Todo add Code for when Hive doensn't initialize(Kingshuk)
            }
          } else {
            return const Scaffold(
              backgroundColor: Colors.black,
            );
          }
        });
  }
}
