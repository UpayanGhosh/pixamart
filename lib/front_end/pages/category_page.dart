// This Page is for when the user clicks on a Category tile and lands on the page where all of the images of the same category is shown

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:pixamart/front_end/widget/search_bar.dart';
import 'package:pixamart/private/get_pexels_api_key.dart';
import 'package:pixamart/backend/model/wallpaper_model.dart';
import 'package:pixamart/front_end/widget/app_title.dart';

import '../../private/api_key.dart';

class Category extends StatefulWidget {
  final String categoryName;
  const Category({Key? key, required this.categoryName}) : super(key: key);

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  late ScrollController scrollController;
  late int page;
  List<dynamic> photoList = [];
  late double currentMaxScrollExtent;

  Future<List<dynamic>> getSearchWallpapers(String query) async {
    Response url = await get(
        Uri.parse("https://api.pexels.com/v1/search?query=$query&per_page=80"),
        headers: {"Authorization": getPexelsApiKey()});
    if (url.statusCode == 200) {
      dynamic body = jsonDecode(url.body);
      List<dynamic> photos = body['photos'].map((dynamic item) => Photos.fromJson(item)).toList();
      photoList.addAll(photos);
      scrollController.addListener(() async {
        if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange) {
          if(currentMaxScrollExtent < scrollController.position.maxScrollExtent) {
            currentMaxScrollExtent = scrollController.position.maxScrollExtent;
            Response url = await get(
                Uri.parse('https://api.pexels.com/v1/search?query=$query/?page=$page&per_page=80'),
                headers: {"Authorization": getPexelsApiKey()});
            page++;
            if (url.statusCode == 200) {
              Map<String, dynamic> newPhotos = jsonDecode(url.body);
              List<dynamic> photos = newPhotos['photos'].map((dynamic item) => Photos.fromJson(item)).toList();
              setState(() {
                photoList.addAll(photos);
              });
            } else {
              throw Exception('Failed to Fetch Curated');
            }
          }
        }
      });
      return photoList;
    } else {
      swapKeys();
      return photoList;
      //throw Exception('Failed to Fetch Photos');
    }
  }

  @override
  void initState() {
    getSearchWallpapers(widget.categoryName);
    page = 2;
    currentMaxScrollExtent = 0.0;
    scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    photoList.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: AppTitle(padLeft: 0.0, padTop: 60.0, padRight: 0.0, padBottom: 15.0,),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            SearchBar(),
            SizedBox(
              height: MediaQuery.of(context).size.height - 185,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  FutureBuilder(
                  future: getSearchWallpapers(widget.categoryName),
                  builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                    if (snapshot.hasData) {
                      List<dynamic> photos = snapshot.data!;
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.count(
                          controller: scrollController,
                          physics: BouncingScrollPhysics(),
                          shrinkWrap: true,
                          childAspectRatio: 0.6,
                          scrollDirection: Axis.vertical,
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          children: photoList
                              .map((dynamic photo) => GridTile(
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Stack(
                                        alignment: Alignment.topRight,
                                        children: [
                                          GestureDetector(
                                          onTap: () {
                                            Navigator.pushNamed(context, '/imageView', arguments: {'imgShowUrl': photo.src.portrait, 'imgDownloadUrl': photo.src.original, 'alt': photo.alt});
                                            },
                                          child: Hero(
                                            tag: photo.src.portrait,
                                            child: Image.network(
                                              '${photo.src.portrait}',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                          GestureDetector(
                                            onTap: () {
                                              print('object'); // Todo Add to favourites code
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Icon(Icons.heart_broken), // Todo change favourites icon
                                            ),
                                          ),
                                        ],
                                      ),
                                  ),
                          ),
                          ).toList(),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Failed to Load Wallpapers'));
                    }
                    return Center(child: Lottie.asset('assets/lottie/lf30_editor_vomrc8qf.json',
                      height: 300,
                      width: 300,));
                  },
                ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        scrollController.animateTo(-150, duration: Duration(milliseconds: 400), curve: Curves.easeOutSine); // easeinexpo, easeoutsine
                      },
                      child: Lottie.asset('assets/lottie/81045-rocket-launch.json',
                          height: 60,
                          width: 60,
                          fit: BoxFit.fill),
                       style: ElevatedButton.styleFrom(primary: Colors.black54, shape: CircleBorder()),),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
