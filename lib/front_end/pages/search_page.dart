// When user searches something he/she lands on this page

import 'dart:convert';
import 'package:PixaMart/front_end/widget/search_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:PixaMart/private/get_pexels_api_key.dart';
import 'package:PixaMart/backend/model/wallpaper_model.dart';
import 'package:PixaMart/front_end/widget/app_title.dart';
import 'package:PixaMart/backend/model/favourites_model.dart';
import 'package:PixaMart/private/api_key.dart';
import 'package:flutter/services.dart';

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
  late Box<dynamic> favouritesList;
  late FirebaseAuth auth;
  late final DatabaseReference userFavouritesDatabase;
  late final CollectionReference removedFromLiked;
  late final User? user;

  @override
  void initState() {
    auth = FirebaseAuth.instance;
    user = auth.currentUser;
    favouritesBox = Hive.openBox('${auth.currentUser?.uid}-favourites');
    favouritesList = Hive.box('${auth.currentUser?.uid}-favourites');
    getSearchWallpapers(widget.searchQuery.text);
    page = 2;
    scrollController = ScrollController();
    currentMaxScrollExtent = 0.0;
    userFavouritesDatabase = FirebaseDatabase.instance.ref('${user?.uid}-favourites/');
    removedFromLiked = FirebaseFirestore.instance.collection('${user?.uid}-favourites/');
    super.initState();
  }

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
                    'https://api.pexels.com/v1/search?query/?page=$page&per_page=80'),
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
      HapticFeedback.lightImpact(); // may remove later
      Hive.box('${auth.currentUser?.uid}-favourites').add(fav);
      userFavouritesDatabase.child(imgDownloadUrl.split('/')[4]).set({
        'imgShowUrl': imgShowUrl,
        'imgDownloadUrl': imgDownloadUrl,
        'alt': alt,
      }); // RD write complete
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(
          'Added to Favourites!!',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nexa'),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            Hive.box('${auth.currentUser?.uid}-favourites').deleteAt(Hive.box('${auth.currentUser?.uid}-favourites').length - 1);
            userFavouritesDatabase.child(imgDownloadUrl.split('/')[4]).remove();
            removedFromLiked.doc(imgDownloadUrl.split('/')[4]).set({
              'imgShowUrl': imgShowUrl,
              'imgDownloadUrl': imgDownloadUrl,
              'alt': alt,
            }); // when user removes an image from liked it goes to firestore
            setState(() {});
          },
        ),
      ));
    } else {
      Hive.box('${auth.currentUser?.uid}-favourites').deleteAt(index);
      userFavouritesDatabase.child(imgDownloadUrl.split('/')[4]).remove(); // RD deletion code
      removedFromLiked.doc(imgDownloadUrl.split('/')[4]).set({
        'imgShowUrl': imgShowUrl,
        'imgDownloadUrl': imgDownloadUrl,
        'alt': alt,
      }); // when user removes an image from liked it goes to firestore
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(
          'Removed from Favourites!!',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nexa'),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            Favourites lastDeleted =
                Favourites(fav.imgShowUrl, fav.imgDownloadUrl, fav.alt);
            favouritesList.add(lastDeleted);
            userFavouritesDatabase.child(imgDownloadUrl.split('/')[4]).set({
              'imgShowUrl': imgShowUrl,
              'imgDownloadUrl': imgDownloadUrl,
              'alt': alt,
            });
            setState(() {});
          },
        ),
      ));
    }
    setState(() {});
    HapticFeedback.lightImpact();
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
                  backgroundColor: Colors.transparent,
                  title: AppTitle(
                      padLeft: MediaQuery.of(context).size.width / 8,
                      padTop: MediaQuery.of(context).size.height / 15,
                      padRight: MediaQuery.of(context).size.width / 10,
                      padBottom: 0),
                ),
                body: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 80,
                    ),
                    const SearchBar(),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 80,
                    ),
                    FutureBuilder(
                      future: getSearchWallpapers(widget.searchQuery.text),
                      builder:
                          (context, AsyncSnapshot<List<dynamic>> snapshot) {
                        if (snapshot.hasData) {
                          List<dynamic> photos = snapshot.data!;
                          return Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                height: MediaQuery.of(context).size.height /
                                    (MediaQuery.of(context).orientation ==
                                            Orientation.portrait
                                        ? 1.45
                                        : 1.68),
                                color: Colors.black,
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width /
                                            24.5),
                                child: GridView.count(
                                  controller: scrollController,
                                  physics: const BouncingScrollPhysics(),
                                  shrinkWrap: true,
                                  clipBehavior: Clip.antiAlias,
                                  childAspectRatio: 0.61,
                                  scrollDirection: Axis.vertical,
                                  crossAxisCount: 2,
                                  crossAxisSpacing:
                                      MediaQuery.of(context).size.width / 39.2,
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
                                                        imgShowUrl:
                                                            photo.src.portrait,
                                                        imgDownloadUrl:
                                                            photo.src.original,
                                                        alt: photo.alt);
                                                  },
                                                  onTap: () {
                                                    Navigator.pushNamed(
                                                        context, '/imageView/',
                                                        arguments: {
                                                          'imgShowUrl': photo
                                                              .src.portrait,
                                                          'imgDownloadUrl':
                                                              photo
                                                                  .src.original,
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
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: GestureDetector(
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
                                                        Icons.favorite_outlined,
                                                        color: Colors.pink,
                                                      );
                                                    }
                                                  }),
                                                  onTap: () {
                                                    handleLiked(
                                                        imgShowUrl:
                                                            photo.src.portrait,
                                                        imgDownloadUrl:
                                                            photo.src.original,
                                                        alt: photo.alt);
                                                  },
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
                                          MediaQuery.of(context).size.width /
                                              6.53,
                                      width: MediaQuery.of(context).size.width /
                                          12.5,
                                      fit: BoxFit.fill),
                                ),
                              ),
                            ],
                          );
                        } else if (snapshot.hasError) {
                          return Container(
                              margin: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height / 8.34, 0, 0),
                              child: Lottie.asset(
                                  'assets/lottie/Server_Error.json'));
                        }
                        return Container(
                          margin: EdgeInsets.fromLTRB(
                              0,
                              MediaQuery.of(context).size.height / 6.5,
                              MediaQuery.of(context).size.width / 5.2,
                              0),
                          child: Lottie.asset('assets/lottie/Loading.json',
                              height: MediaQuery.of(context).size.height / 4,
                              width: MediaQuery.of(context).size.width / 1.96,
                              fit: BoxFit.cover),
                        );
                      },
                    ),
                  ],
                ),
              );
            } else {
              return const Scaffold(
                backgroundColor: Colors.black,
              );
            }
          } else {
            return const Scaffold(
              backgroundColor: Colors.black,
            );
          }
        });
  }
}
