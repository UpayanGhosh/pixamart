// This is when a user clicks on an image and lands on the page where he/she can set it as wallpaper.

import 'dart:typed_data';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class ImageView extends StatefulWidget {
  final String imgShowUrl;
  final String imgDownloadUrl;
  final String alt;
  const ImageView({required this.imgShowUrl, required this.imgDownloadUrl, required this.alt, Key? key}) : super(key: key);

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height / 12,),
            Text(widget.alt, style: TextStyle(color: Colors.white, fontSize: 27, fontFamily: 'Raunchies'), textAlign: TextAlign.center,),
            SizedBox(height: MediaQuery.of(context).size.height / 40,),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                child: Hero(
                  tag: widget.imgShowUrl,
                  child: Container(
                      height: MediaQuery.of(context).size.height - 100,
                      width: MediaQuery.of(context).size.width - 50,
                      child: Image.network(widget.imgShowUrl,fit: BoxFit.cover,),
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
                  style: ElevatedButton.styleFrom(primary: Colors.blue, shape: StadiumBorder()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _save() async {
    //await _askPermission();
    var response = await Dio().get(widget.imgDownloadUrl,
        options: Options(responseType: ResponseType.bytes));
    final result = await ImageGallerySaver.saveImage(Uint8List.fromList(response.data));
  }

  Future<void>setWallpaper(String place) async{
    Navigator.pop(context);
    if(place == 'homescreen') {
    int location = WallpaperManager.HOME_SCREEN;
    var file =  await DefaultCacheManager().getSingleFile(widget.imgDownloadUrl);  //image file
    await WallpaperManager.setWallpaperFromFile(file.path, location);
    }
    else if(place == 'lockscreen') {
      int location = WallpaperManager.LOCK_SCREEN;
      var file =  await DefaultCacheManager().getSingleFile(widget.imgDownloadUrl);  //image file
      await WallpaperManager.setWallpaperFromFile(file.path, location);
    }
    _save();
  }
}
