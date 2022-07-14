// This is the HomePage of the application
//todo fix old images appear with new images issue (kingshuk)
//todo find info about limitedbox widget (kingshuk)

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as Getx;
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:PixaMart/backend/model/categories_model.dart';
import 'package:PixaMart/backend/model/wallpaper_model.dart';
import 'package:PixaMart/front_end/widget/search_bar.dart';
import 'package:PixaMart/front_end/widget/app_title.dart';
import 'package:PixaMart/private/api_key.dart';
import 'package:PixaMart/private/get_pexels_api_key.dart';
import 'package:PixaMart/front_end/widget/categories.dart';
import 'package:PixaMart/front_end/widget/category_tile.dart';
import 'package:PixaMart/backend/model/favourites_model.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CategoriesModel> categories = [];
  late int page;
  late ScrollController scrollController;
  List<dynamic> photoList = [];
  late double currentMaxScrollExtent;
  late Future<Box<dynamic>> favouritesBox;
  late Box<dynamic> favouritesList;
  late final DatabaseReference database;
  late final favouritesRef;
  late final User? user;
  late final FirebaseAuth auth;

  Future<List<dynamic>> getPexelsCuratedWallpapers() async {
    Response url = await get(
        Uri.parse('https://api.pexels.com/v1/curated?per_page=80'),
        headers: {"Authorization": getPexelsApiKey()});
    if (url.statusCode == 200) {
      Map<String, dynamic> curated = jsonDecode(url.body);
      List<dynamic> photos = curated['photos']
          .map((dynamic item) => Photos.fromJson(item))
          .toList();
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
                    'https://api.pexels.com/v1/curated/?page=$page&per_page=80'),
                headers: {"Authorization": getPexelsApiKey()});
            page++;
            if (url.statusCode == 200) {
              Map<String, dynamic> curated = jsonDecode(url.body);
              List<dynamic> newPhotos = curated['photos']
                  .map((dynamic item) => Photos.fromJson(item))
                  .toList();
              setState(() {
                photoList.addAll(newPhotos);
                photoList.reversed;
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
      //throw Exception('Failed to Fetch Curated');
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
      required String alt}) async {
    Favourites fav = Favourites(imgShowUrl, imgDownloadUrl, alt);
    int index = checkIfLiked(imgShowUrl: imgShowUrl);
    if (index == -1) {
      Hive.box('${user?.uid}-favourites').add(fav);
      try{
        favouritesRef.push().update(
            {
              'imgShowUrl': imgShowUrl,
              'imgDownloadUrl': imgDownloadUrl,
              'alt': alt,
            }
        );
        await favouritesRef.onValue.listen((DatabaseEvent event) {
          final data = event.snapshot.value;
        });
      } catch (e) {
        print(e);
      }
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
            Hive.box('${user?.uid}-favourites').deleteAt(Hive.box('${user?.uid}-favourites').length - 1);
            setState(() {});
          },
        ),
      ));
    } else {
      Hive.box('${user?.uid}-favourites').deleteAt(index);
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
    super.initState();
    page = 2;
    categories = getCategory();
    scrollController = ScrollController();
    currentMaxScrollExtent = 0.0;
    auth = FirebaseAuth.instance;
    user = auth.currentUser;
    favouritesBox = Hive.openBox('${user?.uid}-favourites');
    favouritesList = Hive.box('${user?.uid}-favourites');
    database = FirebaseDatabase.instance.ref('users/${user?.uid}/');
    favouritesRef = database.child('${user?.uid}-favourites/');
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
                  elevation: 0.0,
                  backgroundColor: Colors.transparent,
                  title: AppTitle(
                    padLeft: MediaQuery.of(context).size.width / 8,
                    padTop: MediaQuery.of(context).size.height / 15,
                    padRight: MediaQuery.of(context).size.width / 10,
                    padBottom: 0.0,
                  ),
                ),
                body: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 80,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(0.0),
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
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 80,
                    ),
                    FutureBuilder(
                      future: getPexelsCuratedWallpapers(),
                      builder:
                          (context, AsyncSnapshot<List<dynamic>> snapshot) {
                        if (snapshot.hasData) {
                          List<dynamic> photoList = snapshot.data!;
                          return Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              SingleChildScrollView(
                                child: Container(
                                  height: MediaQuery.of(context).size.height /
                                      (MediaQuery.of(context).orientation ==
                                              Orientation.portrait
                                          ? 1.45
                                          : 1.68),
                                  decoration: const BoxDecoration(),
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width /
                                              24.5),
                                  child: GridView.count(
                                    physics: const BouncingScrollPhysics(),
                                    controller: scrollController,
                                    shrinkWrap: true,
                                    childAspectRatio: 0.61,
                                    scrollDirection: Axis.vertical,
                                    crossAxisCount: 2,
                                    clipBehavior: Clip.antiAlias,
                                    crossAxisSpacing:
                                        MediaQuery.of(context).size.width /
                                            39.2,
                                    children: photoList
                                        .map((dynamic photo) => GridTile(
                                                child: Stack(
                                              alignment: Alignment.bottomRight,
                                              children: [
                                                ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    child: GestureDetector(
                                                      onDoubleTap: () {
                                                        handleLiked(
                                                            imgShowUrl: photo
                                                                .src.portrait,
                                                            imgDownloadUrl:
                                                                photo.src
                                                                    .original,
                                                            alt: photo.alt);
                                                      },
                                                      onTap: () {
                                                        Navigator.pushNamed(
                                                            context,
                                                            '/imageView',
                                                            arguments: {
                                                              'imgShowUrl':
                                                                  photo.src
                                                                      .portrait,
                                                              'imgDownloadUrl':
                                                                  photo.src
                                                                      .original,
                                                              'alt': photo.alt
                                                            });
                                                      },
                                                      child: Hero(
                                                          tag: photo
                                                              .src.portrait,
                                                          child: Image.network(
                                                            '${photo.src.portrait}',
                                                            fit: BoxFit.cover,
                                                          )),
                                                    )),
                                                Padding(
                                                  padding: EdgeInsets.all(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height /
                                                          104.25),
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
                                                          Icons
                                                              .favorite_outlined,
                                                          color: Colors.pink,
                                                        );
                                                      }
                                                    }),
                                                    onTap: () {
                                                      handleLiked(
                                                          imgShowUrl: photo
                                                              .src.portrait,
                                                          imgDownloadUrl: photo
                                                              .src.original,
                                                          alt: photo.alt);
                                                    },
                                                  ),
                                                ),
                                              ],
                                            )))
                                        .toList(),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width /
                                            24.5,
                                    vertical:
                                        MediaQuery.of(context).size.height /
                                            52.125),
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
                          return const Center(
                              child: Text('Failed to Load Wallpapers'));
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
              return const Text(
                  'data'); //Todo add code for when Hive doesn't initialize
            }
          } else {
            return const Scaffold(
              backgroundColor: Colors.black,
            );
          }
        });
  }
}
