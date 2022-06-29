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
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height / 40,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: () {
                  setWallpaper('homescreen');
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Homescreen Wallpaper will be set Shortly!')));
                }, child: Padding(
                  padding: const EdgeInsets.fromLTRB(0,14,0,0),
                  child: Text('Set as Homescreen', style: TextStyle(color: Colors.black87, fontFamily: 'Raunchies', fontSize: 20),),
                ), style: ElevatedButton.styleFrom(primary: Colors.white, shape: StadiumBorder()),),
                ElevatedButton(onPressed: () {
                  setWallpaper('lockscreen');
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lockscreen Wallpaper will be set Shortly')));
                }, child: Padding(
                  padding: const EdgeInsets.fromLTRB(0,14,0,0),
                  child: Text('Set as Lockscreen', style: TextStyle(fontFamily: 'Raunchies', fontSize: 20)),
                ),
              ),
            ],
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
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
