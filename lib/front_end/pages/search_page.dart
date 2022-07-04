// When user searches something he/she lands on this page

import 'dart:convert';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:PixaMart/front_end/widget/animated_search_bar.dart';
import 'package:PixaMart/private/get_pexels_api_key.dart';
import 'package:PixaMart/backend/model/wallpaper_model.dart';
import 'package:PixaMart/front_end/widget/app_title.dart';
import 'package:PixaMart/backend/model/favourites_model.dart';
import 'package:PixaMart/private/api_key.dart';
import 'AccountPage.dart';
import 'favourites_page.dart';

class SearchPageNavigation extends StatefulWidget {
  final TextEditingController searchQuery;
  const SearchPageNavigation({Key? key, required this.searchQuery}) : super(key: key);

  @override
  State<SearchPageNavigation> createState() => _SearchPageNavigationState();
}

class _SearchPageNavigationState extends State<SearchPageNavigation> {
  late var pagesAll;
  late int myIndex;
  late GlobalKey<CurvedNavigationBarState> _NavKey;

  @override
  void initState() {
    super.initState();
    _NavKey = GlobalKey();
    pagesAll = [SearchPage(searchQuery: widget.searchQuery,),FavouritesPage(),AccountPage()];
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
        buttonBackgroundColor: Colors.white,
        key: _NavKey,
        items: [
          Icon(Icons.search_outlined,color: Colors.blue,),
          Icon(Icons.favorite_outline,color: Colors.blue,),
          Icon(Icons.account_circle_outlined,color: Colors.blue,),
        ],
        onTap: (index) {
          setState((){
            myIndex = index;
          });
        },
      ),
    );
  }
}



class SearchPage extends StatefulWidget {
  final TextEditingController searchQuery;
  const SearchPage({Key? key, required this.searchQuery}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late int page;
  late ScrollController scrollController;
  List<dynamic> photoList = [];
  late double currentMaxScrollExtent;
  late Future<Box<dynamic>> favouritesBox;
  TextEditingController searchController = TextEditingController();

  Future<List<dynamic>>getSearchWallpapers(String query) async{
    Response url = await get(Uri.parse("https://api.pexels.com/v1/search?query=$query&per_page=80"),
        headers: {
          "Authorization": getPexelsApiKey()});
    if(url.statusCode == 200){
      dynamic body = jsonDecode(url.body);
      List<dynamic> photos = body['photos'].map((dynamic item)=>Photos.fromJson(item)).toList();
      photoList.addAll(photos);
      scrollController.addListener(() async {
        if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange) {
          if(currentMaxScrollExtent < scrollController.position.maxScrollExtent) {
            currentMaxScrollExtent = scrollController.position.maxScrollExtent;
            Response url = await get(
                Uri.parse('https://api.pexels.com/v1/search?query/?page=$page&per_page=80'),
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
    }
    else{
      swapKeys();
      return photoList;
      //throw Exception('Failed to Fetch Photos');
    }
  }

  addToLiked({required String imgShowUrl, required String imgDownloadUrl, required String alt}) {
    Favourites favourites = Favourites(imgShowUrl, imgDownloadUrl, alt);
    Hive.box('favourites').add(favourites);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added to Favourites!!'), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), action: SnackBarAction(
      label: 'Undo',
      onPressed: () {
        Hive.box('favourites').deleteAt(Hive.box('favourites').length - 1);
      },
    ),));
    // Todo Add to favourites code
  }

  @override
  void initState() {
    getSearchWallpapers(widget.searchQuery.text);
    page = 2;
    scrollController = ScrollController();
    currentMaxScrollExtent = 0.0;
    favouritesBox = Hive.openBox('favourites');
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
        if(snapshot.connectionState == ConnectionState.done) {
          if(snapshot.hasData) {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                title: AppTitle(padLeft: 0, padTop: 50, padRight: MediaQuery.of(context).size.width - 342, padBottom: 0),
              ),
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 0, 22),
                    child: AnimatedSearchBar(width: MediaQuery.of(context).size.width / 1.525, searchQuery: searchController, textController: searchController, onSuffixTap:(){}),
                  ),
                  FutureBuilder(
                    future: getSearchWallpapers(widget.searchQuery.text),
                    builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                      if(snapshot.hasData) {
                        List<dynamic> photos = snapshot.data!;
                        return Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height - 262,
                              color: Colors.black,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: GridView.count(
                                controller: scrollController,
                                physics: BouncingScrollPhysics(),
                                shrinkWrap: true,
                                childAspectRatio: 0.6,
                                scrollDirection: Axis.vertical,
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 0,
                                children: photoList.map((dynamic photo) => GridTile(child: Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    ClipRRect(borderRadius: BorderRadius.circular(16),
                                      child: GestureDetector(
                                        onDoubleTap: () {
                                          addToLiked(imgShowUrl: photo.src.portrait, imgDownloadUrl: photo.src.original, alt: photo.alt);
                                        },
                                        onTap: (){
                                          Navigator.pushNamed(context, '/imageView', arguments: {'imgShowUrl': photo.src.portrait, 'imgDownloadUrl': photo.src.original, 'alt': photo.alt});
                                        },
                                        child: Hero(
                                          tag:photo.src.portrait,
                                          child: Image.network('${photo.src.portrait}', fit: BoxFit.cover,),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: GestureDetector(
                                        child: Icon(Icons.favorite_outline_rounded,color: Colors.red),
                                        onTap: () {
                                          addToLiked(imgShowUrl: photo.src.portrait, imgDownloadUrl: photo.src.original, alt: photo.alt);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                ),
                                ).toList(),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              child: ElevatedButton(
                                onPressed: () {
                                  scrollController.animateTo(-170, duration: Duration(milliseconds: 400), curve: Curves.easeOutSine); // easeinexpo, easeoutsine
                                },
                                child: Lottie.asset('assets/lottie/81045-rocket-launch.json',
                                    height: 60,
                                    width: 60,
                                    fit: BoxFit.fill),
                                style: ElevatedButton.styleFrom(primary: Colors.black54, shape: CircleBorder()),),
                            ),
                          ],
                        );
                      }
                      else if(snapshot.hasError){
                        return Center(child: Text('Failed to Load Wallpapers'));
                        //Todo Lottie asset for server down and msg
                      }
                      return Container(
                          margin: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height - 653, 0, 0),
                          child: Lottie.asset('assets/lottie/lf30_editor_vomrc8qf.json',
                        height: 200,
                        width: 200,));
                      // Todo change lottie asset
                    },
                  ),
                ],
              ),
            );
          } else {
            return Text('data');
          }
        }
        else {
          return Scaffold(backgroundColor: Colors.black,);
        }
  }
    );
  }
}
