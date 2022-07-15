// This is when a user clicks on an image and lands on the page where he/she can set it as wallpaper.
// Todo Build System to share Images through App (Kingshuk)
// Todo try different sounds with actions (Kingshuk)

import 'dart:async';
import 'dart:typed_data';
import 'package:PixaMart/backend/model/favourites_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:ionicons/ionicons.dart';
import 'package:liquid_progress_indicator_ns/liquid_progress_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';
import 'dart:ui';

class ImageView extends StatefulWidget {
  final String imgShowUrl;
  final String imgDownloadUrl;
  final String alt;
  const ImageView(
      {required this.imgShowUrl,
      required this.imgDownloadUrl,
      required this.alt,
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
  late Box<dynamic> downloadsList;
  late final FirebaseAuth auth;
  late final User? user;
  late Favourites fav;
  late final CollectionReference cloudDownloads;

  @override
  void initState() {
    super.initState();
    dialogue = 'Downloading'.obs;
    opacity = 0.0;
    progressValue = 0.0.obs;
    startPosition = 0.0;
    updatePosition = 0.0.obs;
    auth = FirebaseAuth.instance;
    user = auth.currentUser;
    downloadsList = Hive.box('${user?.uid}-downloads');
    fav = Favourites(widget.imgShowUrl, widget.imgDownloadUrl, widget.alt);
    cloudDownloads =
        FirebaseFirestore.instance.collection('${user?.uid}-downloads/');
  }

  updateProgressValue({required newProgressValue, currentProgressValue}) async {
    while (currentProgressValue != newProgressValue) {
      currentProgressValue += 1;
      progressValue.value = currentProgressValue;
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }

  checkIfDownloaded({required String imgShowUrl}) {
    int alreadyLikedAt = -1;
    for (int i = 0; i < downloadsList.length; i++) {
      if (imgShowUrl == (downloadsList.getAt(i) as Favourites).imgShowUrl) {
        alreadyLikedAt = i;
      }
    } // Todo find a better searching solution (Kingshuk/upayan)
    return alreadyLikedAt;
  }

  saveToGallery() async {
    Map<Permission, PermissionStatus> status = await [
      Permission.storage,
    ].request();
    if (status[Permission.storage]!.isGranted) {
      opacity = 1.0;
      int index = checkIfDownloaded(imgShowUrl: widget.imgShowUrl);
      if (index == -1) {
        downloadsList.add(fav);
        cloudDownloads.doc(widget.imgDownloadUrl.split('/')[4]).set({
          'imgShowUrl': widget.imgShowUrl,
          'imgDownloadUrl': widget.imgDownloadUrl,
          'alt': widget.alt,
        });
      }
      var response = await Dio().get(
        widget.imgDownloadUrl,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );
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
      await Future.delayed(const Duration(milliseconds: 500)).then((value) => Navigator.pop(context));
    } else {
      Permission.storage.request();
    }
  }

  Future<void> setWallpaper(String place) async {
    Map<Permission, PermissionStatus> status = await [
      Permission.storage,
    ].request();
    if (status[Permission.storage]!.isGranted) {
      opacity = 1.0;
      int index = checkIfDownloaded(imgShowUrl: widget.imgShowUrl);
      if (index == -1) {
        downloadsList.add(fav);
        cloudDownloads.doc(widget.imgDownloadUrl.split('/')[4]).set({
          'imgShowUrl': widget.imgShowUrl,
          'imgDownloadUrl': widget.imgDownloadUrl,
          'alt': widget.alt,
        });
      }
      var dir = await getExternalStorageDirectory();
      String filePath = '${dir?.path}/${widget.imgDownloadUrl.split('/')[4]}.jpg';
      await Dio().download(widget.imgDownloadUrl, filePath).then((value) async {
        dialogue = 'Setting as Wallpaper'.obs;
        await updateProgressValue(
            newProgressValue: 40, currentProgressValue: progressValue.value);
        setState(() {});
      });
      int location;
      if (place == 'homescreen') {
        location = WallpaperManager.HOME_SCREEN;
      } else if (place == 'lockscreen') {
        location = WallpaperManager.LOCK_SCREEN;
      } else {
        location = WallpaperManager.BOTH_SCREEN;
      }
      await WallpaperManager.setWallpaperFromFile(filePath, location).then((value) {
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
      await Future.delayed(const Duration(milliseconds: 500)).then((value) => Navigator.pop(context));
    } else {
      Permission.storage.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onVerticalDragStart: (DragStartDetails details) {
          startPosition = details.globalPosition.dy;
        },
        onVerticalDragUpdate: (DragUpdateDetails details) {
          updatePosition.value = details.globalPosition.dy;
          if ((updatePosition.value - startPosition > MediaQuery.of(context).size.height / 20.85) || updatePosition.value - startPosition < (-1 * MediaQuery.of(context).size.height / 20.85)) {
            Navigator.pop(context);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: AnimatedScale(
            duration: const Duration(milliseconds: 500),
            scale: (1 - updatePosition.value / MediaQuery.of(context).size.height / 1.39),
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
                        child: Image.network(
                          widget.imgShowUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          spreadRadius: 0,
                          blurRadius: 50,
                          color: Colors.black.withOpacity(0.1),
                          offset: Offset(10, 10),
                        ),
                      ],
                    ),
                    child: Image.asset('assets/Mobile_Outline.png',
                        height: MediaQuery.of(context).size.height / 0.2,
                        fit: BoxFit.contain),
                  ),
                  Container(
                    margin: MediaQuery.of(context).orientation == Orientation.portrait ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 5.6, MediaQuery.of(context).size.height / 6.55, MediaQuery.of(context).size.width / 5.6, MediaQuery.of(context).size.height / 5.9) : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 5.6, MediaQuery.of(context).size.height / 7.55, MediaQuery.of(context).size.width / 5.6, MediaQuery.of(context).size.height / 6.9),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Hero(
                        tag: widget.imgShowUrl,
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: Image.network(
                            widget.imgShowUrl,
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
                  child: const Icon(Icons
                      .add_to_home_screen),
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
                  child: const Icon(Icons.lock),
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
                  child: const Icon(Ionicons.share_social),
                  backgroundColor: Colors.white,
                  label: 'Share',
                  labelStyle: const TextStyle(
                    fontFamily: 'Nexa',
                    fontWeight: FontWeight.bold,
                  ),
                  onTap: () {
                    setState(() {});
                  }),
              SpeedDialChild(
                  child: const Icon(Icons.download),
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
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        ),
      ),
    );
  }
}
