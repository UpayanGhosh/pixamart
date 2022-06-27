// This is when a user clicks on an image and lands on the page where he/she can set it as wallpaper.

import 'dart:typed_data';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class ImageView extends StatefulWidget {
<<<<<<< Updated upstream
  final String imgUrl;
  ImageView({required this.imgUrl});
=======
  final String imgShowUrl;
  final String imgDownloadUrl;
  final String alt;
  const ImageView({required this.imgShowUrl, required this.imgDownloadUrl, required this.alt, Key? key}) : super(key: key);
>>>>>>> Stashed changes

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> with SingleTickerProviderStateMixin{
  late Dio dioBrando;

  saveToGallery() async {
    Navigator.pop(context);
    var response = await dioBrando.get(widget.imgDownloadUrl, options: Options(responseType: ResponseType.bytes,),);
    final result = await ImageGallerySaver.saveImage(Uint8List.fromList(response.data));
    //print('hi');
  }

  Future<void>setWallpaper(String place) async {
    Map<Permission, PermissionStatus> status = await [
      Permission.storage,
    ].request();
    if(status[Permission.storage]!.isGranted) {
      Navigator.pop(context);
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
      //print('Wallpaper set');
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
            tag: widget.imgUrl,
            child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Image.network(widget.imgUrl,fit: BoxFit.cover,)),
          ),
<<<<<<< Updated upstream
          SafeArea(child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: (){
                  setWallpaper('homescreen');
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Homescreen Wallpaper Set Successfully')));
                },
                child: Container(
                  height: 65,
                  width: 200,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(colors: [
                        Colors.blueAccent,
                        Colors.transparent,
                      ])
                  ),
                  child: Center(child: Text("Set as Homescreen",style: TextStyle(fontWeight: FontWeight.bold, fontSize:17, color: Colors.white),textAlign: TextAlign.center,)),
                ),
              ),
              GestureDetector(
                onTap: (){
                  setWallpaper('lockscreen');
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lockscreen Wallpaper Set Successfully')));
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 40),
                  height: 65,
                  width: 200,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(colors: [
                        Colors.transparent,
                        Colors.blueAccent,
                      ])
                  ),
                  child: Center(child: Text("Set as Lockscreen",style: TextStyle(fontWeight: FontWeight.bold, fontSize:17, color: Colors.white),textAlign: TextAlign.center,)),
                ),
              ),
            ],
          ),
=======
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
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Homescreen Wallpaper Will Set Shortly'), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),));
              }
          ),
          SpeedDialChild(
            child: Icon(Icons.lock),
              backgroundColor: Colors.white,
            label: 'Lockscreen',
            onTap: () {
              setWallpaper('lockscreen');
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lockscreen Wallpaper Will Set Shortly'), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))));
            }
          ),
          SpeedDialChild(
            child: Icon(Icons.now_wallpaper),
              backgroundColor: Colors.white,
            label: 'Both',
            onTap: () {
              setWallpaper('bothscreen');
              /*setWallpaper('lockscreen');*/
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Wallpaper Will Set Shortly'), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))));
            }
          ),
          SpeedDialChild(
            child: Icon(Icons.download),
              backgroundColor: Colors.white,
            label: 'Save',
            onTap: () {
              saveToGallery();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Wallpaper saved to gallery Successfully'), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))));
            }
>>>>>>> Stashed changes
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
<<<<<<< Updated upstream

  _save() async {
    //await _askPermission();
    var response = await Dio().get(widget.imgUrl,
        options: Options(responseType: ResponseType.bytes));
    final result =
    await ImageGallerySaver.saveImage(Uint8List.fromList(response.data));
  }

  Future<void>setWallpaper(String place) async{
    Navigator.pop(context);
    if(place == 'homescreen') {
    int location = WallpaperManager.HOME_SCREEN;
    var file =  await DefaultCacheManager().getSingleFile(widget.imgUrl);  //image file
    await WallpaperManager.setWallpaperFromFile(file.path, location);
    //provide image path
    }// Wrap with try catch for error management.
    else if(place == 'lockscreen') {
      int location = WallpaperManager.LOCK_SCREEN;
      var file =  await DefaultCacheManager().getSingleFile(widget.imgUrl);  //image file
      await WallpaperManager.setWallpaperFromFile(file.path, location);
    }
    _save();
  }
=======
>>>>>>> Stashed changes
}
