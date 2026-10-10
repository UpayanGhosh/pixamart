import 'package:PixaMart/backend/sources/wallpaper.dart';
import 'package:PixaMart/backend/sources/wallpaper_repository.dart';
// This Page is for when the user clicks on a Category tile and lands on the page where all of the images of the same category is shown

import 'dart:async';
import 'package:PixaMart/backend/functions/on_share.dart';
import 'package:PixaMart/front_end/widget/categories.dart';
import 'package:PixaMart/front_end/widget/search_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart' as Getx;
import 'package:PixaMart/backend/model/favourites_model.dart';
import 'package:flutter/services.dart';
import 'package:PixaMart/backend/model/categories_model.dart';
import 'package:PixaMart/front_end/widget/category_tile.dart';
import 'package:PixaMart/backend/functions/animate_to_top.dart';

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
  late FirebaseAuth auth;
  late final User? user;
  late final DatabaseReference userFavouritesDatabase;
  late final CollectionReference removedFromLiked;
  List<CategoriesModel> categories = [];
  late List<Getx.RxDouble> opacityManager;

  @override
  void initState() {
    auth = FirebaseAuth.instance;
    user = auth.currentUser;
    favouritesBox = Hive.openBox('${auth.currentUser?.uid}-favourites');
    favouritesList = Hive.box('${auth.currentUser?.uid}-favourites');
    userFavouritesDatabase =
        FirebaseDatabase.instance.ref('${user?.uid}-favourites/');
    removedFromLiked =
        FirebaseFirestore.instance.collection('${user?.uid}-favourites/');
    page = 2;
    currentMaxScrollExtent = 0.0;
    scrollController = ScrollController();
    scrollController.addListener(() => loadMoreOnScroll(widget.categoryName));
    wallpapersFuture = loadWallpapers(widget.categoryName);
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

  late Future<List<dynamic>> wallpapersFuture;
  bool loadingMore = false;

  Future<List<dynamic>> loadWallpapers(String query) async {
    final firstPage = await WallpaperRepository.search(query, 1);
    page = 2;
    photoList
      ..clear()
      ..addAll(firstPage);
    return photoList;
  }

  void loadMoreOnScroll(String query) async {
    if (loadingMore || !scrollController.hasClients) return;
    final position = scrollController.position;
    if (position.pixels < position.maxScrollExtent * 0.7) return;
    loadingMore = true;
    try {
      final more = await WallpaperRepository.search(query, page);
      if (more.isNotEmpty && mounted) {
        page++;
        setState(() => photoList.addAll(more));
      }
    } catch (_) {
    } finally {
      loadingMore = false;
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
        required String imgTinyUrl}) async {
    Favourites fav = Favourites(imgShowUrl, imgDownloadUrl, imgTinyUrl);
    int index = checkIfLiked(imgShowUrl: imgShowUrl);
    if (index == -1) {
      HapticFeedback.lightImpact(); // may remove later
      Hive.box('${user?.uid}-favourites').add(fav); // Hive write complete
      userFavouritesDatabase.child(cloudKeyFor(imgDownloadUrl)).set({
        ...cloudRecordFor(imgDownloadUrl),
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
            Hive.box('${user?.uid}-favourites')
                .deleteAt(Hive.box('${user?.uid}-favourites').length - 1);
            userFavouritesDatabase.child(cloudKeyFor(imgDownloadUrl)).remove();
            removedFromLiked.doc(cloudKeyFor(imgDownloadUrl)).set({
              ...cloudRecordFor(imgDownloadUrl),
            }); // when user removes an image from liked it goes to firestore
            setState(() {});
          },
        ),
      ));
    } else {
      Hive.box('${user?.uid}-favourites').deleteAt(index);
      userFavouritesDatabase
          .child(cloudKeyFor(imgDownloadUrl))
          .remove(); // RD deletion code
      removedFromLiked.doc(cloudKeyFor(imgDownloadUrl)).set({
        ...cloudRecordFor(imgDownloadUrl),
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
            Favourites(fav.imgShowUrl, fav.imgDownloadUrl, fav.imgTinyUrl);
            favouritesList.add(lastDeleted);
            userFavouritesDatabase.child(cloudKeyFor(imgDownloadUrl)).set({
              ...cloudRecordFor(imgDownloadUrl),
            });
            setState(() {});
          },
        ),
      ));
    }
    setState(() {});
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
                    title: Padding(
                      padding: EdgeInsets.fromLTRB(
                          MediaQuery.of(context).size.width / 8,
                          MediaQuery.of(context).size.height / 15,
                          MediaQuery.of(context).size.width / 10,
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
                    )),
                body: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 80,
                    ),
                    Getx.Obx(
                          () => AnimatedOpacity(
                        duration: const Duration(milliseconds: 350),
                        opacity: opacityManager[1].value,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(0.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Search_Bar(),
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
                        duration: const Duration(milliseconds: 350),
                        opacity: opacityManager[2].value,
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height /
                              (MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                                  ? 1.45
                                  : 1.68),
                          child: FutureBuilder(
                            future: wallpapersFuture,
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
                                        clipBehavior: Clip.antiAlias,
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
                                                    onLongPressStart: (longPress) {
                                                      HapticFeedback.lightImpact();
                                                      onShare(
                                                          photo.showUrl,
                                                          photo.downloadUrl);
                                                    },
                                                    onDoubleTap: () {
                                                      handleLiked(
                                                          imgShowUrl: photo.showUrl,
                                                          imgDownloadUrl: photo.downloadUrl,
                                                          imgTinyUrl: photo.tinyUrl);
                                                    },
                                                    onTap: () {
                                                      Navigator.pushNamed(
                                                          context,
                                                          '/imageView/',
                                                          arguments: {
                                                            'imgShowUrl': photo.showUrl,
                                                            'imgDownloadUrl':
                                                            photo.downloadUrl,
                                                            'imgTinyUrl': photo.tinyUrl
                                                          });
                                                    },
                                                    child: Hero(
                                                      tag: photo.showUrl,
                                                      child: CachedNetworkImage(
                                                        imageUrl: '${photo.showUrl}',
                                                        placeholder: (context, url) => const Icon(Icons.add),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    handleLiked(
                                                        imgShowUrl:
                                                        photo.showUrl,
                                                        imgDownloadUrl:
                                                        photo.downloadUrl,
                                                        imgTinyUrl: photo.tinyUrl);
                                                  },
                                                  child: Padding(
                                                    padding:
                                                    const EdgeInsets.all(
                                                        8.0),
                                                    child: Builder(
                                                        builder: (context) {
                                                          if (checkIfLiked(
                                                              imgShowUrl: photo.showUrl) ==
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
                                          animateToTop(scrollController, MediaQuery.of(context).size.height /
                                              4.7 *
                                              -1);
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black54,
                                            shape: const CircleBorder()),
                                        child: Lottie.asset(
                                            'assets/lottie/Rocket.json',
                                            height:
                                            MediaQuery.of(context).size.width /
                                                6.53,
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