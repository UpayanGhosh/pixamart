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
      body: GestureDetector(
        onTap: (){
          setWallpaper();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Wallpaper Set Successfully')));
        },
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Hero(
              tag: widget.imgUrl,
              child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Image.network(widget.imgUrl,fit: BoxFit.cover,)),
            ),
            SafeArea(child: Opacity(
              opacity: 0.7,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    //alignment: Alignment.bottomCenter,
                    margin: EdgeInsets.symmetric(horizontal:16,vertical: 0.1),
                    height: 50,
                    width: 200,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(colors: [
                          Colors.white,
                          Colors.blue,
                        ])
                    ),
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 50,
                          width: 140,
                          child: Center(child: Text("Set Wallpaper",style: TextStyle(fontWeight: FontWeight.bold,fontSize:16,color: Colors.black),textAlign: TextAlign.center,)),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: Container(
                        margin: EdgeInsets.symmetric(vertical: 50),
                        child: Text("Cancel",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),)),
                  ),
                ],
              ),
            ),
            )
            /*Container(
              height: 50,
              width: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.white,
                  Colors.blue,
                ])
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    child: Column(
                      children: <Widget>[
                        Text("Set Wallpaper"),
                        Text("Image will be saved in gallery automatically"),
                      ],
                    ),
                  ),
                  Text("Cancel",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),)
                ],
              ),
            )*/
          ],
        ),
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

  Future<void>setWallpaper() async{
    Navigator.pop(context);
    int location = WallpaperManager.HOME_SCREEN;
    var file =  await DefaultCacheManager().getSingleFile(widget.imgUrl);  //image file
    await WallpaperManager.setWallpaperFromFile(file.path, location);
    //provide image path
    _save();
    // Wrap with try catch for error management.
  }

}
