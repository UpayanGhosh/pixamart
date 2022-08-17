// This is when a user clicks on an image and lands on the page where he/she can set it as wallpaper.
// Todo Build System to share Images through App (Kingshuk)

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:PixaMart/backend/functions/on_share.dart';
import 'package:PixaMart/backend/model/favourites_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:ionicons/ionicons.dart';
import 'package:liquid_progress_indicator_ns/liquid_progress_indicator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';
import 'dart:ui';

class ImageView extends StatefulWidget {
  final String imgShowUrl;
  final String imgDownloadUrl;
  final String imgTinyUrl;
  final PendingDynamicLinkData? initialLink;
  const ImageView(
      {required this.imgShowUrl,
      required this.imgDownloadUrl,
      required this.imgTinyUrl,
      required this.initialLink,
      Key? key})
      : super(key: key);

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView>
    with SingleTickerProviderStateMixin {
  late Rx<String> dialogue;
  late double opacity;
  late RxDouble progressValue;
  late double startPosition;
  late RxDouble updatePosition;
  late Box<dynamic>? downloadsList;
  late Box<dynamic>? favouritesList;
  late final FirebaseAuth auth;
  late final User? user;
  late Favourites fav;
  late final CollectionReference cloudDownloads;
  late BaseCacheManager cacheManager;
  late List<RxDouble> opacityManager;
  late GlobalKey cropperKey;
  late Future<Box<dynamic>> downloadsBox;
  late Future<Box<dynamic>> favouritesBox;
  late int isLiked;
  late final DatabaseReference userFavouritesDatabase;
  late final CollectionReference removedFromLiked;

  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
    user = auth.currentUser;
    dialogue = 'Downloading'.obs;
    opacity = 0.0;
    progressValue = 0.0.obs;
    startPosition = 0.0;
    updatePosition = 0.0.obs;
    opacityManager = [
      0.0.obs,
    ];
    widget.initialLink == null ? fav = Favourites(widget.imgShowUrl, widget.imgDownloadUrl, widget.imgTinyUrl) : fav = Favourites('https://images.pexels.com/photos/${widget.initialLink?.link.path.split('/')[2]}/pexels-photo-${widget.initialLink?.link.path.split('/')[2]}.jpeg?auto=compress&cs=tinysrgb&fit=crop&h=1200&w=800', 'https://images.pexels.com/photos/${widget.initialLink?.link.path.split('/')[2]}/pexels-photo-2014422.jpeg', 'https://images.pexels.com/photos/${widget.initialLink?.link.path.split('/')[2]}/pexels-photo-${widget.initialLink?.link.path.split('/')[2]}.jpeg?auto=compress&cs=tinysrgb&dpr=1&fit=crop&h=200&w=280');
      userFavouritesDatabase = FirebaseDatabase.instance.ref('${user?.uid}-favourites/');
      removedFromLiked = FirebaseFirestore.instance.collection('${user?.uid}-favourites/');
      downloadsBox = Hive.openBox('${user?.uid}-downloads');
      favouritesBox = Hive.openBox('${user?.uid}-favourites');
      downloadsList = Hive.box('${user?.uid}-downloads');
      favouritesList = Hive.box('${user?.uid}-favourites');
    if (widget.initialLink == null) {
      isLiked = checkIfLiked(imgShowUrl: widget.imgShowUrl);
    }else {
      isLiked = checkIfLiked(imgShowUrl: 'https://images.pexels.com/photos/${widget.initialLink?.link.path.split('/')[2]}/pexels-photo-${widget.initialLink?.link.path.split('/')[2]}.jpeg?auto=compress&cs=tinysrgb&fit=crop&h=1200&w=800');
    }
      cloudDownloads = FirebaseFirestore.instance.collection('${user?.uid}-downloads/');
      cacheManager = DefaultCacheManager();
      cropperKey = GlobalKey(debugLabel: 'cropperKey');
    manageOpacity();
  }

  void manageOpacity() async {
    int i = 0;
    await Future.delayed(const Duration(milliseconds: 150));
    Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (i < opacityManager.length) {
        opacityManager[i].value = 1.0;
        i++;
      }
    });
  }

  updateProgressValue({required newProgressValue, currentProgressValue}) async {
    while (currentProgressValue != newProgressValue) {
      currentProgressValue += 1;
      progressValue.value = currentProgressValue;
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }

  checkIfDownloaded({required String imgShowUrl}) {
    int alreadyDownloadedAt = -1;
    for (int i = 0; i < downloadsList!.length; i++) {
      if (imgShowUrl == (downloadsList!.getAt(i) as Favourites).imgShowUrl) {
        alreadyDownloadedAt = i;
      }
    } // Todo find a better searching solution (Kingshuk/upayan)
    return alreadyDownloadedAt;
  }

  handleLiked({required String imgShowUrl, required String imgDownloadUrl, required String imgTinyUrl}) async {
    Favourites fav = Favourites(imgShowUrl, imgDownloadUrl, imgTinyUrl);
    int index = checkIfLiked(imgShowUrl: imgShowUrl);
    if (index == -1) {
      HapticFeedback.lightImpact(); // may remove later
      Hive.box('${user?.uid}-favourites').add(fav); // Hive write complete
      if(widget.initialLink == null) {
        userFavouritesDatabase.child(imgDownloadUrl.split('/')[4]).set({
          'img': imgDownloadUrl.split('/')[4],
        }); // RD write complete
        isLiked = 0;
      } else {
        userFavouritesDatabase.child(imgDownloadUrl.split('/')[4]).set({
          'img': widget.initialLink?.link.path.split('/')[2],
        }); // RD write complete
      }
      isLiked = 0;
    } else {
      Hive.box('${user?.uid}-favourites').deleteAt(index);
      isLiked = -1;
      if(widget.initialLink == null) {
        userFavouritesDatabase
            .child(imgDownloadUrl.split('/')[4])
            .remove(); // RD deletion code
        removedFromLiked.doc(imgDownloadUrl.split('/')[4]).set({
          'img': imgDownloadUrl.split('/')[4],
        }); // when user removes an image from liked it goes to firestore
      } else {
        userFavouritesDatabase
            .child(widget.initialLink!.link.path.split('/')[2])
            .remove(); // RD deletion code
        removedFromLiked.doc(widget.initialLink?.link.path.split('/')[2]).set({
          'img': imgDownloadUrl.split('/')[4],
        }); // when user removes an image from liked it goes to firestore
      }
    }
  }

  checkIfLiked({required String imgShowUrl}) {
    int alreadyLikedAt = -1;
    for (int i = 0; i < favouritesList!.length; i++) {
      if (imgShowUrl == (favouritesList!.getAt(i) as Favourites).imgShowUrl) {
        alreadyLikedAt = i;
      }
    } // Todo find a better searching solution (Kingshuk/upayan)
    return alreadyLikedAt;
  }

  saveToGallery() async {
    opacity = 1.0;
    int index;
    if (widget.initialLink == null) {
      index = checkIfDownloaded(imgShowUrl: widget.imgShowUrl);
    } else {
      index = checkIfDownloaded(
          imgShowUrl: 'https://images.pexels.com/photos/${widget.initialLink
              ?.link.path.split('/')[2]}/pexels-photo-${widget.initialLink?.link
              .path.split(
              '/')[2]}.jpeg?auto=compress&cs=tinysrgb&fit=crop&h=1200&w=800');
    }
    if (index == -1) {
        downloadsList?.add(fav);
        if(widget.initialLink == null) {
          cloudDownloads.doc(widget.imgDownloadUrl.split('/')[4]).set({
            'img': widget.imgDownloadUrl.split('/')[4],
          });
        } else {
          cloudDownloads.doc(widget.initialLink?.link.path.split('/')[2]).set({
            'img': widget.initialLink?.link.path.split('/')[2],
          });
        }
      }
      var response;
      if(widget.initialLink == null) {
        response = await Dio().get(
          widget.imgDownloadUrl,
          options: Options(
            responseType: ResponseType.bytes,
          ),
        );
      }
      else {
        response = await Dio().get(
          'https://images.pexels.com/photos/${widget.initialLink?.link.path.split('/')[2]}/pexels-photo-${widget.initialLink?.link.path.split('/')[2]}.jpeg',
          options: Options(
            responseType: ResponseType.bytes,
          ),
        );
      }
    final result =
      await ImageGallerySaver.saveImage(Uint8List.fromList(response.data));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text(
            'Wallpaper saved to gallery Successfully',
            style: TextStyle(
              fontFamily: 'Nexa',
              fontWeight: FontWeight.bold,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))));
      await updateProgressValue(
          newProgressValue: 100, currentProgressValue: progressValue.value);
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 500));
      opacity = 1.0;
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 500))
          .then((value) => Navigator.pop(context));
  }

  Future<void> setWallpaper(String place) async {
    opacity = 1.0;
    int index;
    if(widget.initialLink == null) {
      index = checkIfDownloaded(imgShowUrl: widget.imgShowUrl);
    } else {
      index = checkIfDownloaded(imgShowUrl: 'https://images.pexels.com/photos/${widget.initialLink?.link.path.split('/')[2]}/pexels-photo-${widget.initialLink?.link.path.split('/')[2]}.jpeg?auto=compress&cs=tinysrgb&fit=crop&h=1200&w=800');
    }
    if (index == -1) {
      downloadsList?.add(fav);
      if(widget.initialLink == null) {
        cloudDownloads.doc(widget.imgDownloadUrl.split('/')[4]).set({
          'img': widget.imgDownloadUrl.split('/')[4],
        });
      } else {
        cloudDownloads.doc(widget.initialLink?.link.path.split('/')[2]).set({
          'img': widget.initialLink?.link.path.split('/')[2],
        });
      }
    }
    var dir = await getExternalStorageDirectory();
    int midProgressValue = Random().nextInt(15) + 55;
    String filePath;
    if(widget.initialLink == null) {
      filePath = '${dir?.path}/${widget.imgDownloadUrl.split('/')[4]}.jpg';
    } else {
      filePath = '${dir?.path}/${widget.initialLink?.link.path.split('/')[2]}.jpg';
    }
    if(widget.initialLink == null) {
      await Dio().download(widget.imgDownloadUrl, filePath).then((value) async {
        dialogue = 'Setting as Wallpaper'.obs;
        await updateProgressValue(
            newProgressValue: midProgressValue,
            currentProgressValue: progressValue.value);
        setState(() {});
      });
    } else {
      await Dio().download('https://images.pexels.com/photos/${widget.initialLink?.link.path.split('/')[2]}/pexels-photo-${widget.initialLink?.link.path.split('/')[2]}.jpeg', filePath).then((value) async {
        dialogue = 'Setting as Wallpaper'.obs;
        await updateProgressValue(
            newProgressValue: midProgressValue,
            currentProgressValue: progressValue.value);
        setState(() {});
      });
    }
    int location;
    if (place == 'homescreen') {
      location = WallpaperManager.HOME_SCREEN;
    } else if (place == 'lockscreen') {
      location = WallpaperManager.LOCK_SCREEN;
    } else {
      location = WallpaperManager.BOTH_SCREEN;
    }
    await WallpaperManager.setWallpaperFromFile(filePath, location)
        .then((value) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          '${location == 1 ? "HomeScreen" : location == 2 ? "LockScreen" : ""} Wallpaper is set',
          style: const TextStyle(
            fontFamily: 'Nexa',
            fontWeight: FontWeight.bold,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ));
    });
    await updateProgressValue(
        newProgressValue: 100, currentProgressValue: progressValue.value);
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 500));
    opacity = 0.0;
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 500))
        .then((value) => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: favouritesBox,
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          return FutureBuilder(
              future: downloadsBox,
              builder: (context, snapshot) {
                if(snapshot.hasData) {
                  return Obx(
                        () => GestureDetector(
                      onVerticalDragStart: (DragStartDetails details) {
                        startPosition = details.globalPosition.dy;
                      },
                      onVerticalDragUpdate: (DragUpdateDetails details) {
                        updatePosition.value = details.globalPosition.dy;
                        if ((updatePosition.value - startPosition >
                            MediaQuery.of(context).size.height / 20.85) ||
                            updatePosition.value - startPosition <
                                (-1 * MediaQuery.of(context).size.height / 20.85)) {
                          Navigator.pop(context);
                        }
                      },
                      child: Scaffold(
                        backgroundColor: Colors.transparent,
                        body: AnimatedScale(
                          duration: const Duration(milliseconds: 500),
                          scale: (1 -
                              updatePosition.value /
                                  MediaQuery.of(context).size.height /
                                  1.39),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              clipBehavior: Clip.antiAlias,
                              children: [
                                SizedBox(
                                  height: MediaQuery.of(context).size.height,
                                  width: MediaQuery.of(context).size.width,
                                  child: ImageFiltered(
                                    imageFilter: ImageFilter.blur(
                                      sigmaX: 15,
                                      sigmaY: 15,
                                    ),
                                    child: Opacity(
                                      opacity: 0.8,
                                      child: CachedNetworkImage(
                                        imageUrl: widget.initialLink == null ? widget.imgShowUrl : 'https://images.pexels.com/photos/${widget.initialLink?.link.path.split('/')[2]}/pexels-photo-${widget.initialLink?.link.path.split('/')[2]}.jpeg?auto=compress&cs=tinysrgb&fit=crop&h=1200&w=800',
                                        placeholder: (context, url) => const Icon(Icons.add),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                Obx(
                                      () => AnimatedOpacity(
                                    duration: const Duration(milliseconds: 250),
                                    opacity: opacityManager[0].value,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            spreadRadius: 0,
                                            blurRadius: 50,
                                            color: Colors.black.withOpacity(0.1),
                                            offset: const Offset(10, 10), // Todo Experiment
                                          ),
                                        ],
                                      ),
                                      child: Image.asset('assets/Mobile_Outline.png',
                                          height: MediaQuery.of(context).size.height / 0.2,
                                          fit: BoxFit.contain),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: MediaQuery.of(context).orientation ==
                                      Orientation.portrait
                                      ? EdgeInsets.fromLTRB(
                                      MediaQuery.of(context).size.width / 5.6,
                                      MediaQuery.of(context).size.height / 6.55,
                                      MediaQuery.of(context).size.width / 5.6,
                                      MediaQuery.of(context).size.height / 5.9)
                                      : EdgeInsets.fromLTRB(
                                      MediaQuery.of(context).size.width / 5.6,
                                      MediaQuery.of(context).size.height / 7.55,
                                      MediaQuery.of(context).size.width / 5.6,
                                      MediaQuery.of(context).size.height / 6.9),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Hero(
                                      tag: widget.initialLink == null ? widget.imgShowUrl : 'https://images.pexels.com/photos/${widget.initialLink?.link.path.split('/')[2]}/pexels-photo-${widget.initialLink?.link.path.split('/')[2]}.jpeg?auto=compress&cs=tinysrgb&fit=crop&h=1200&w=800',
                                      child: SizedBox(
                                        height: MediaQuery.of(context).size.height,
                                        width: MediaQuery.of(context).size.width,
                                        child: Image.network(
                                          widget.initialLink == null ? widget.imgShowUrl : 'https://images.pexels.com/photos/${widget.initialLink?.link.path.split('/')[2]}/pexels-photo-${widget.initialLink?.link.path.split('/')[2]}.jpeg?auto=compress&cs=tinysrgb&fit=crop&h=1200&w=800',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                AnimatedOpacity(
                                  opacity: opacity,
                                  duration: const Duration(milliseconds: 400),
                                  child: AlertDialog(
                                    backgroundColor: Colors.transparent,
                                    title: Obx(() => Text(
                                      '$dialogue',
                                      style: const TextStyle(
                                          fontFamily: 'Nexa',
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                      textAlign: TextAlign.center,
                                    )),
                                    content: SizedBox(
                                      height: MediaQuery.of(context).size.height / 26,
                                      width: MediaQuery.of(context).size.width / 2,
                                      child: Obx(
                                            () => LiquidLinearProgressIndicator(
                                          borderColor: Colors.transparent,
                                          value: progressValue.value / 100,
                                          borderRadius: 30,
                                          borderWidth: 0,
                                          direction: Axis.horizontal,
                                          center: Text(
                                            '${(progressValue.value).toStringAsFixed(1)}%',
                                            style: const TextStyle(
                                                fontFamily: 'Nexa',
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Transform.translate(offset: Offset(0, -(MediaQuery.of(context).size.height / 6.5)), child: Transform.scale(scale: MediaQuery.of(context).size.width / 520, child: Image.asset('assets/apps.png'))),
                              ],
                            ),
                          ),
                        ),
                        floatingActionButton: SpeedDial(
                            animatedIcon: AnimatedIcons.menu_close,
                            backgroundColor: Colors.white24,
                            overlayColor: Colors.transparent,
                            overlayOpacity: 0.5,
                            spacing: 17,
                            spaceBetweenChildren: 12,
                            children: [
                              SpeedDialChild(
                                  child: isLiked == -1 ? const Icon(Icons.favorite_outline_rounded, color: Colors.pink,) : const Icon(Icons.favorite_outlined, color: Colors.pink,),
                                  backgroundColor: Colors.white,
                                  label: 'Add to Favourites',
                                  labelStyle: const TextStyle(
                                    fontFamily: 'Nexa',
                                    fontWeight: FontWeight.bold,
                                  ),
                                  onTap: () {
                                    if(widget.initialLink == null) {
                                      handleLiked(imgShowUrl: widget.imgShowUrl, imgDownloadUrl: widget.imgDownloadUrl, imgTinyUrl: widget.imgTinyUrl);
                                    } else {
                                      handleLiked(imgShowUrl: 'https://images.pexels.com/photos/${widget.initialLink?.link.path.split('/')[2]}/pexels-photo-${widget.initialLink?.link.path.split('/')[2]}.jpeg?auto=compress&cs=tinysrgb&fit=crop&h=1200&w=800', imgDownloadUrl: 'https://images.pexels.com/photos/${widget.initialLink?.link.path.split('/')[2]}/pexels-photo-${widget.initialLink?.link.path.split('/')[2]}.jpeg', imgTinyUrl: 'https://images.pexels.com/photos/${widget.initialLink?.link.path.split('/')[2]}/pexels-photo-${widget.initialLink?.link.path.split('/')[2]}.jpeg?auto=compress&cs=tinysrgb&dpr=1&fit=crop&h=200&w=280');
                                    }
                                    setState(() {}  );
                                  }),
                              SpeedDialChild(
                                  child: const Icon(Icons.add_to_home_screen, color: Colors.greenAccent,),
                                  backgroundColor: Colors.white,
                                  label: 'Homescreen',
                                  labelStyle: const TextStyle(
                                    fontFamily: 'Nexa',
                                    fontWeight: FontWeight.bold,
                                  ),
                                  onTap: () {
                                    setWallpaper('homescreen');
                                    setState(() {});
                                  }),
                              SpeedDialChild(
                                  child: const Icon(Icons.lock, color: Colors.blueAccent,),
                                  backgroundColor: Colors.white,
                                  label: 'Lockscreen',
                                  labelStyle: const TextStyle(
                                    fontFamily: 'Nexa',
                                    fontWeight: FontWeight.bold,
                                  ),
                                  onTap: () {
                                    setWallpaper('lockscreen');
                                    setState(() {});
                                  }),
                              SpeedDialChild(
                                  child: const Icon(Ionicons.share_social, color: Colors.orange,),
                                  backgroundColor: Colors.white,
                                  label: 'Share',
                                  labelStyle: const TextStyle(
                                    fontFamily: 'Nexa',
                                    fontWeight: FontWeight.bold,
                                  ),
                                  onTap: () async {
                                    onShare(widget.initialLink == null ? widget.imgTinyUrl : 'https://images.pexels.com/photos/${widget.initialLink?.link.path.split('/')[2]}/pexels-photo-${widget.initialLink?.link.path.split('/')[2]}.jpeg?auto=compress&cs=tinysrgb&dpr=1&fit=crop&h=200&w=280', widget.initialLink == null ? widget.imgDownloadUrl : 'https://images.pexels.com/photos/${widget.initialLink?.link.path.split('/')[2]}/pexels-photo-${widget.initialLink?.link.path.split('/')[2]}.jpeg');
                                    setState(() {});
                                  }),
                              SpeedDialChild(
                                  child: const Icon(Icons.download, color: Colors.blueGrey),
                                  backgroundColor: Colors.white,
                                  label: 'Save',
                                  labelStyle: const TextStyle(
                                    fontFamily: 'Nexa',
                                    fontWeight: FontWeight.bold,
                                  ),
                                  onTap: () {
                                    saveToGallery();
                                    setState(() {});
                                  }),
                            ],
                          ),
                        floatingActionButtonLocation:
                        FloatingActionButtonLocation.centerFloat,
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              }
          );
        } else {
          return Container();
        }
      }
    );
  }
}
