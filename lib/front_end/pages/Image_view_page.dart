// This is when a user clicks on an image and lands on the page where he/she can set it as wallpaper.

import 'dart:typed_data';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class ImageView extends StatefulWidget {
  final String imgUrl;
  ImageView({required this.imgUrl});

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
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
          ),
        ],
      ),
    );
  }

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
}
