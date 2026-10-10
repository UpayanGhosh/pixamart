import 'package:PixaMart/front_end/widget/source_picker.dart';
import 'package:PixaMart/backend/sources/wallpaper.dart';
import 'package:PixaMart/backend/sources/wallpaper_repository.dart';
// This is the HomePage of the application
//todo find info about limitedbox widget (kingshuk)

import 'dart:async';
import 'package:PixaMart/backend/functions/on_share.dart';
import 'package:PixaMart/front_end/widget/search_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:PixaMart/backend/model/shared_link.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as Getx;
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:PixaMart/backend/model/categories_model.dart';
import 'package:PixaMart/front_end/widget/app_title.dart';
import 'package:PixaMart/front_end/widget/categories.dart';
import 'package:PixaMart/front_end/widget/category_tile.dart';
import 'package:PixaMart/backend/model/favourites_model.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:PixaMart/backend/functions/animate_to_top.dart';

class HomePage extends StatefulWidget {
  final SharedLink? initialLink;
  const HomePage({required this.initialLink, Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<CategoriesModel> categories;
  late int page;
  late List<dynamic> photoList;
  late double currentMaxScrollExtent;
  late Future<Box<dynamic>> favouritesBox;
  late Box<dynamic> favouritesList;
  late final FirebaseAuth auth;
  late final User? user;
  late final DatabaseReference userFavouritesDatabase;
  late final CollectionReference removedFromLiked;
  late List<Getx.RxDouble> opacityManager;
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    page = 1;
    categories = getCategory();
    currentMaxScrollExtent = 0.0;
    auth = FirebaseAuth.instance;
    user = auth.currentUser;
    favouritesBox = Hive.openBox('${user?.uid}-favourites');
    favouritesList = Hive.box('${user?.uid}-favourites');
    userFavouritesDatabase =
        FirebaseDatabase.instance.ref('${user?.uid}-favourites/');
    removedFromLiked =
        FirebaseFirestore.instance.collection('${user?.uid}-favourites/');
    photoList = [];
    opacityManager = [
      0.0.obs,
      0.0.obs,
      0.0.obs,
    ];
    manageOpacity();
    scrollController = ScrollController();
    scrollController.addListener(loadMoreOnScroll);
    wallpapersFuture = loadWallpapers();
    syncFavourites();
  }

  getInitialLink() async {
    if (widget.initialLink != null) {
      final String link = widget.initialLink.toString();
      await FirebaseFirestore.instance
          .collection('app-details')
          .doc('link')
          .set({'link': link}).then((value) {
        Navigator.pushNamed(context, '/imageView', arguments: {
          'imgShowUrl':
              'https://images.pexels.com/photos/$link/snake-rainbow-boa-reptile-scale.jpg?auto=compress&cs=tinysrgb&fit=crop&h=1200&w=800',
          'imgDownloadUrl':
              'https://images.pexels.com/photos/$link/snake-rainbow-boa-reptile-scale.jpg',
          'imgTinyUrl':
              'https://images.pexels.com/photos/$link/pexels-photo-$link.jpeg?auto=compress&cs=tinysrgb&dpr=1&fit=crop&h=200&w=280'
        });
      });
    }
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

  syncFavourites() async {
    if (favouritesList.isEmpty) {
      final snapshot = await userFavouritesDatabase.get();
      final cloudFavourites = snapshot.children;
      for (int i = 0; i < cloudFavourites.length; i++) {
        var favourite = cloudFavourites.elementAt(i).value as Map;
        final urls = urlsFromCloudRecord(favourite);
          Favourites fav = Favourites(urls[0], urls[1], urls[2]);
        Hive.box('${user?.uid}-favourites').add(fav); // Hive write complete
      }
    }
    setState(() {});
  }

  late Future<List<dynamic>> wallpapersFuture;
  bool loadingMore = false;

  Future<List<dynamic>> loadWallpapers() async {
    page = 1;
    final firstPage = await WallpaperRepository.curated(page);
    photoList
      ..clear()
      ..addAll(firstPage);
    return photoList;
  }

  void loadMoreOnScroll() async {
    if (loadingMore || !scrollController.hasClients) return;
    final position = scrollController.position;
    if (position.pixels < position.maxScrollExtent * 0.7) return;
    loadingMore = true;
    try {
      final more = await WallpaperRepository.curated(page + 1);
      if (more.isNotEmpty && mounted) {
        page++;
        setState(() => photoList.addAll(more));
      }
    } catch (_) {
    } finally {
      loadingMore = false;
    }
  }

  void changeSource(WallpaperSourceId id) {
    WallpaperRepository.select(id);
    if (scrollController.hasClients) scrollController.jumpTo(0);
    setState(() => wallpapersFuture = loadWallpapers());
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //getInitialLink();
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
                  title: Getx.Obx(
                    () => AnimatedOpacity(
                      duration: const Duration(milliseconds: 550),
                      opacity: opacityManager[0].value,
                      child: AppTitle(
                        padLeft: MediaQuery.of(context).size.width / 8,
                        padTop: MediaQuery.of(context).size.height / 15,
                        padRight: MediaQuery.of(context).size.width / 10,
                        padBottom: 0.0,
                      ),
                    ),
                  ),
                ),
                body: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 80,
                    ),
                    Getx.Obx(
                      () => AnimatedOpacity(
                        duration: const Duration(milliseconds: 550),
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
                                height:
                                    MediaQuery.of(context).size.height / 16.68,
                                child: ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            MediaQuery.of(context).size.width /
                                                98),
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
                    SourcePicker(onChanged: changeSource),
                    SizedBox(height: MediaQuery.of(context).size.height / 80),
                    Getx.Obx(
                      () => AnimatedOpacity(
                        duration: const Duration(milliseconds: 1000),
                        opacity: opacityManager[2].value,
                        child: FutureBuilder(
                          future: wallpapersFuture,
                          builder:
                              (context, AsyncSnapshot<List<dynamic>> snapshot) {
                            if (snapshot.hasData) {
                              List<dynamic> photoList = snapshot.data!;
                              return Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  SingleChildScrollView(
                                    child: Container(
                                      height: MediaQuery.of(context)
                                              .size
                                              .height /
                                          (MediaQuery.of(context).orientation ==
                                                  Orientation.portrait
                                              ? 1.45
                                              : 1.68),
                                      decoration: const BoxDecoration(),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context)
                                                  .size
                                                  .width /
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
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  children: [
                                                    ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                        child: GestureDetector(
                                                          onLongPressStart:
                                                              (longPress) {
                                                            onShare(
                                                                photo.tinyUrl,
                                                                photo.downloadUrl);
                                                          },
                                                          onDoubleTap: () {
                                                            handleLiked(
                                                                imgShowUrl: photo.showUrl,
                                                                imgDownloadUrl:
                                                                    photo.downloadUrl,
                                                                imgTinyUrl:
                                                                    photo.tinyUrl);
                                                          },
                                                          onTap: () {
                                                            Navigator.pushNamed(
                                                                context,
                                                                '/imageView/${photo.id}',
                                                                arguments: {
                                                                  'imgShowUrl':
                                                                      photo.showUrl,
                                                                  'imgDownloadUrl':
                                                                      photo.downloadUrl,
                                                                  'imgTinyUrl':
                                                                      photo.tinyUrl
                                                                });
                                                          },
                                                          child: Hero(
                                                              tag: photo.showUrl,
                                                              child:
                                                                  CachedNetworkImage(
                                                                imageUrl:
                                                                    '${photo.showUrl}',
                                                                placeholder: (context,
                                                                        url) =>
                                                                    const Icon(
                                                                        Icons
                                                                            .add),
                                                                fit: BoxFit
                                                                    .cover,
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
                                                                  imgShowUrl: photo.showUrl) ==
                                                              -1) {
                                                            return const Icon(
                                                              Icons
                                                                  .favorite_outline_rounded,
                                                              color:
                                                                  Colors.pink,
                                                            );
                                                          } else {
                                                            return const Icon(
                                                              Icons
                                                                  .favorite_outlined,
                                                              color:
                                                                  Colors.pink,
                                                            );
                                                          }
                                                        }),
                                                        onTap: () {
                                                          handleLiked(
                                                              imgShowUrl: photo.showUrl,
                                                              imgDownloadUrl:
                                                                  photo.downloadUrl,
                                                              imgTinyUrl: photo.tinyUrl);
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
                                        animateToTop(
                                            scrollController,
                                            MediaQuery.of(context).size.height /
                                                4.7 *
                                                -1);
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black54,
                                          shape: const CircleBorder()),
                                      child: Lottie.asset(
                                          'assets/lottie/Rocket.json',
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              6.53,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
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
                                  height:
                                      MediaQuery.of(context).size.height / 4,
                                  width:
                                      MediaQuery.of(context).size.width / 1.96,
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
