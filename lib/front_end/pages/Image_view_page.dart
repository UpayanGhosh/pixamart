// This is when a user clicks on an image and lands on the page where he/she can set it as wallpaper.

import 'dart:typed_data';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixamart/front_end/pages/homepage.dart';

class ImageView extends StatefulWidget {
  final String imgShowUrl;
  final String imgDownloadUrl;
  final String alt;
  const ImageView({required this.imgShowUrl, required this.imgDownloadUrl, required this.alt, Key? key}) : super(key: key);

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> with SingleTickerProviderStateMixin{
  late Dio dioBrando;

  saveToGallery() async {
    Navigator.pop(context);
    var response = await dioBrando.get(widget.imgDownloadUrl, options: Options(responseType: ResponseType.bytes,),);
    final result = await ImageGallerySaver.saveImage(Uint8List.fromList(response.data));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Wallpaper saved to gallery Successfully'), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))));
    //print('hi');
  }

  Future<void>setWallpaper(String place) async {
    Map<Permission, PermissionStatus> status = await [
      Permission.storage,
    ].request();
    if(status[Permission.storage]!.isGranted) {
      var dir = await getExternalStorageDirectory();
      //print(dir);
      String filePath = '${dir?.path}/${widget.alt}.jpg';
      await Dio().download(widget.imgDownloadUrl, filePath);
      //print('Download Complete');
      int location;
      if(place == 'homescreen') {
        location = WallpaperManager.HOME_SCREEN;
      }
      else if(place == 'lockscreen'){
        location = WallpaperManager.LOCK_SCREEN;
      }
      else {
        location = WallpaperManager.BOTH_SCREEN;
      }
      //Todo Spawn a seperate Isolate to set the wallpaper from the downloaded file.
      await WallpaperManager.setWallpaperFromFile(filePath, location);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${location == 1 ? "HomeScreen" : location == 2 ? "LockScreen" : ""} Wallpaper is set'), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),));
      //Todo Pop an Alert Dialogue saying Wait until Wallpaper is set
      Navigator.pop(context);
    } else {
      Permission.storage.request();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Hero(
            tag: widget.imgShowUrl,
            child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Image.network(widget.imgShowUrl,fit: BoxFit.cover,)),
          ),
          AlertDialog(
            title: Text('Wait'),
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
              child: Icon(Icons.add_to_home_screen),
              backgroundColor: Colors.white,
              label: 'Homescreen',
              onTap: () {
                setWallpaper('homescreen');
              }
          ),
          SpeedDialChild(
              child: Icon(Icons.lock),
              backgroundColor: Colors.white,
              label: 'Lockscreen',
              onTap: () {
                setWallpaper('lockscreen');
              }
          ),
          SpeedDialChild(
              child: Icon(Icons.now_wallpaper),
              backgroundColor: Colors.white,
              label: 'Both',
              onTap: () {
                setWallpaper('bothscreen');
              }
          ),
          SpeedDialChild(
              child: Icon(Icons.download),
              backgroundColor: Colors.white,
              label: 'Save',
              onTap: () {
                saveToGallery();
              }
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
