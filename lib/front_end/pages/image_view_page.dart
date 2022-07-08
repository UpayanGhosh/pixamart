// This is when a user clicks on an image and lands on the page where he/she can set it as wallpaper.

import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:liquid_progress_indicator_ns/liquid_progress_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';

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

  @override
  void initState() {
    super.initState();
    dialogue = 'Downloading'.obs;
    opacity = 0.0;
    progressValue = 0.0.obs;
  }

  updateProgressValue({required newProgressValue, currentProgressValue}) async {
    while(currentProgressValue != newProgressValue) {
      //print(progressValue.value + newProgressValue);
      currentProgressValue += 0.1;
      progressValue.value = currentProgressValue;
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }

  saveToGallery() async {
    opacity = 1.0;
    var response = await Dio().get(
      widget.imgDownloadUrl,
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );
    final result =
        await ImageGallerySaver.saveImage(Uint8List.fromList(response.data));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Wallpaper saved to gallery Successfully'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))));
    updateProgressValue(newProgressValue: 1.0, currentProgressValue: progressValue.value);
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 500));
    opacity = 1.0;
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 500));
    Navigator.pop(context);
  }

  Future<void> setWallpaper(String place) async {
    Map<Permission, PermissionStatus> status = await [
      Permission.storage,
    ].request();
    if (status[Permission.storage]!.isGranted) {
      opacity = 1.0;
      var dir = await getExternalStorageDirectory();
      String filePath = '${dir?.path}/${widget.alt}.jpg';
      await Dio().download(widget.imgDownloadUrl, filePath).then((value) {
        dialogue = 'Setting as Wallpaper'.obs;
        updateProgressValue(newProgressValue: 0.4, currentProgressValue: progressValue.value);
        setState(() {});
      });
      //print('Download Complete');
      int location;
      if (place == 'homescreen') {
        location = WallpaperManager.HOME_SCREEN;
      } else if (place == 'lockscreen') {
        location = WallpaperManager.LOCK_SCREEN;
      } else {
        //Todo change both screen code
        location = WallpaperManager.BOTH_SCREEN;
      }
      //Todo Spawn a seperate Isolate to set the wallpaper from the downloaded file.
      await WallpaperManager.setWallpaperFromFile(filePath, location);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            '${location == 1 ? "HomeScreen" : location == 2 ? "LockScreen" : ""} Wallpaper is set'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ));
      updateProgressValue(newProgressValue: 1.0, currentProgressValue: progressValue);
      setState(() {});
      await Future.delayed(Duration(milliseconds: 500));
      opacity = 0.0;
      setState(() {});
      await Future.delayed(Duration(milliseconds: 500));
      //Todo Pop an Alert Dialogue saying Wait until Wallpaper is set
      Navigator.pop(context);
    } else {
      Permission.storage.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Hero(
            tag: widget.imgShowUrl,
            child: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Image.network(
                  widget.imgShowUrl,
                  fit: BoxFit.cover,
                )),
          ),
          AnimatedOpacity(
            opacity: opacity,
            duration: const Duration(milliseconds: 400),
            child: AlertDialog(
              backgroundColor: Colors.transparent,
              title: Obx(() => Text('$dialogue',style: const TextStyle(color: Colors.white),textAlign: TextAlign.center,)),
              content: SizedBox(
                height: MediaQuery.of(context).size.height / 26,
                width: MediaQuery.of(context).size.width / 2,
                child: LiquidLinearProgressIndicator(
                  borderColor: Colors.transparent,
                  value: progressValue.value,
                  borderRadius: 30,
                  borderWidth: 0,
                  direction: Axis.horizontal,
                  center: Obx(() => Text('${(progressValue.value).toStringAsFixed(1)}%', style: const TextStyle(color: Colors.white),)),
                ),
              ),
            ),
          ),
        ],
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
              child: const Icon(Icons.add_to_home_screen),
              backgroundColor: Colors.white,
              label: 'Homescreen',
              onTap: () {
                setWallpaper('homescreen');
                setState(() {});
              }),
          SpeedDialChild(
              child: const Icon(Icons.lock),
              backgroundColor: Colors.white,
              label: 'Lockscreen',
              onTap: () {
                setWallpaper('lockscreen');
                setState(() {});
              }),
          SpeedDialChild(
              child: const Icon(Icons.now_wallpaper),
              backgroundColor: Colors.white,
              label: 'Both',
              onTap: () {
                setWallpaper('bothscreen');
                setState(() {});
              }),
          SpeedDialChild(
              child: const Icon(Icons.download),
              backgroundColor: Colors.white,
              label: 'Save',
              onTap: () {
                saveToGallery();
                setState(() {});
              }),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
