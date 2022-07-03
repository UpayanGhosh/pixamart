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
import 'AccountPage.dart';
import 'favourites_page.dart';


class CategoryPageNavigation extends StatefulWidget {
  final String categoryName;
  const CategoryPageNavigation({Key? key, required this.categoryName}) : super(key: key);

  @override
  State<CategoryPageNavigation> createState() => _CategoryPageNavigationState();
}

class _CategoryPageNavigationState extends State<CategoryPageNavigation> {
  late GlobalKey<CurvedNavigationBarState> _NavKey;
  late var pagesAll;
  late int myIndex;

  @override
  void initState() {
    super.initState();
    _NavKey = GlobalKey();
    pagesAll = [CategoryPage(categoryName: widget.categoryName), FavouritesPage(), AccountPage()];
    myIndex = 0;
  }
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
          Icon(Icons.category_outlined,color: Colors.blue,),
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

  Future<List<dynamic>> getSearchWallpapers(String query) async {
    Response url = await get(
        Uri.parse("https://api.pexels.com/v1/search?query=$query&per_page=80"),
        headers: {"Authorization": getPexelsApiKey()});
    if (url.statusCode == 200) {
      dynamic body = jsonDecode(url.body);
      List<dynamic> photos = body['photos'].map((dynamic item) => Photos.fromJson(item)).toList();
      photoList.addAll(photos);
      scrollController.addListener(() async {
        if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange) {
          if(currentMaxScrollExtent < scrollController.position.maxScrollExtent) {
            currentMaxScrollExtent = scrollController.position.maxScrollExtent;
            Response url = await get(
                Uri.parse('https://api.pexels.com/v1/search?query=$query/?page=$page&per_page=80'),
                headers: {"Authorization": getPexelsApiKey()});
            page++;
            if (url.statusCode == 200) {
              Map<String, dynamic> newPhotos = jsonDecode(url.body);
              List<dynamic> photos = newPhotos['photos'].map((dynamic item) => Photos.fromJson(item)).toList();
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

  @override
  void initState() {
    favouritesBox = Hive.openBox('favourites');
    getSearchWallpapers(widget.categoryName);
    page = 2;
    currentMaxScrollExtent = 0.0;
    scrollController = ScrollController();
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
                centerTitle: true,
                elevation: 0.0,
                backgroundColor: Colors.transparent,
                title: AppTitle(padLeft: 0.0, padTop: 60.0, padRight: 0.0, padBottom: 15.0,),
              ),
              body: Container(
                child: Column(
                  children: [
                    SearchBar(),
                    SizedBox(
                      height: MediaQuery.of(context).size.height - 230,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          FutureBuilder(
                            future: getSearchWallpapers(widget.categoryName),
                            builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                              if (snapshot.hasData) {
                                List<dynamic> photos = snapshot.data!;
                                return Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: GridView.count(
                                    controller: scrollController,
                                    physics: BouncingScrollPhysics(),
                                    shrinkWrap: true,
                                    childAspectRatio: 0.6,
                                    scrollDirection: Axis.vertical,
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    children: photoList
                                        .map((dynamic photo) => GridTile(
                                      child: Stack(
                                        alignment: Alignment.bottomRight,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(16),
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.pushNamed(context, '/imageView', arguments: {'imgShowUrl': photo.src.portrait, 'imgDownloadUrl': photo.src.original, 'alt': photo.alt});
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
                                              Favourites favourites = Favourites(photo.src.portrait, photo.src.original, photo.alt);
                                              Hive.box('favourites').add(favourites);
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added to Favourites!!'), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), action: SnackBarAction(
                                                label: 'Undo',
                                                onPressed: () {
                                                  Hive.box('favourites').deleteAt(Hive.box('favourites').length - 1);
                                                },
                                              ),));
                                              // Todo Add to favourites code
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Icon(Icons.heart_broken), // Todo change favourites icon
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ).toList(),
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return Center(child: Text('Failed to Load Wallpapers'));
                              }
                              return Center(child: Lottie.asset('assets/lottie/lf30_editor_vomrc8qf.json',
                                height: 300,
                                width: 300,));
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            child: ElevatedButton(
                              onPressed: () {
                                scrollController.animateTo(-150, duration: Duration(milliseconds: 400), curve: Curves.easeOutSine); // easeinexpo, easeoutsine
                              },
                              child: Lottie.asset('assets/lottie/81045-rocket-launch.json',
                                  height: 60,
                                  width: 60,
                                  fit: BoxFit.fill),
                              style: ElevatedButton.styleFrom(primary: Colors.black54, shape: CircleBorder()),),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Text('data'); // Todo add Code for when Hive doensn't initialize
          }
        } else {
          return Scaffold(backgroundColor: Colors.black,);
        }
  }
    );
  }
}
