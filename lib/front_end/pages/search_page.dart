// When user searches something he/she lands on this page

import 'dart:async';
import 'dart:convert';
import 'package:PixaMart/backend/functions/animate_to_top.dart';
import 'package:PixaMart/front_end/widget/search_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as Getx;
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:PixaMart/private/get_pexels_api_key.dart';
import 'package:PixaMart/backend/model/wallpaper_model.dart';
import 'package:PixaMart/backend/model/favourites_model.dart';
import 'package:PixaMart/private/api_key.dart';
import 'package:flutter/services.dart';
import 'package:PixaMart/front_end/widget/categories.dart';
import 'package:PixaMart/backend/model/categories_model.dart';
import 'package:PixaMart/front_end/widget/category_tile.dart';

class SearchPage extends StatefulWidget {
  final TextEditingController searchQuery;
  const SearchPage({Key? key, required this.searchQuery}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late List<CategoriesModel> categories;
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
  late List<Getx.RxDouble> opacityManager;

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
    categories = getCategory();
    opacityManager = [
      0.0.obs,
      0.0.obs,
      0.0.obs,
    ];
    manageOpacity();
    super.initState();
  }

  void manageOpacity() async {
    int i = 0;
    await Future.delayed(const Duration(milliseconds: 250));
    Timer.periodic(const Duration(milliseconds: 250), (timer) {
      if (i < opacityManager.length) {
        opacityManager[i].value = 1.0;
        i++;
      }
    });
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
                  title: Padding(
                    padding: EdgeInsets.fromLTRB(
                        MediaQuery.of(context).size.width / 4,
                        MediaQuery.of(context).size.height / 15,
                        0,
                        0),
                    child: Getx.Obx(
                          () => AnimatedOpacity(
                        duration: const Duration(milliseconds: 350),
                        opacity: opacityManager[0].value,
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) =>
                              const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops: [0.1, 0.5],
                                  colors: [
                                    Colors.white,
                                    Colors.blue,
                                  ]).createShader(bounds),
                          child: Text(
                            'PixaMart',
                            style: TextStyle(
                              fontSize:
                              MediaQuery.of(context).size.height / 18.53,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Raunchies',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                body: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 80,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(0.0),
                      child: Getx.Obx(
                            () => AnimatedOpacity(
                          duration: const Duration(milliseconds: 350),
                          opacity: opacityManager[1].value,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SearchBar(),
                              SizedBox(
                                height: MediaQuery.of(context).size.height / 16.68,
                                child: ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                        MediaQuery.of(context).size.width / 98),
                                    itemCount: categories.length,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      return CategoryTile(
                                        title: categories[index].categoriesName,
                                        imgUrl: categories[index].imgUrl,
                                      );
                                    }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 80,
                    ),
                    Getx.Obx(
                          () => AnimatedOpacity(
                        duration: const Duration(milliseconds: 550),
                        opacity: opacityManager[1].value,
                        child: FutureBuilder(
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
                                                    child: CachedNetworkImage(
                                                      imageUrl: '${photo.src.portrait}',
                                                      placeholder: (context, url) => const Icon(Icons.add),
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
                                        /*scrollController.animateTo(
                                            (MediaQuery.of(context).size.height /
                                                4.7) *
                                                -1,
                                            duration:
                                            const Duration(milliseconds: 400),
                                            curve: Curves
                                                .easeOutSine); // easeinexpo, easeoutsine*/
                                        animateToTop(scrollController, MediaQuery.of(context).size.height /
                                            4.7 *
                                            -1);
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
                      ),
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