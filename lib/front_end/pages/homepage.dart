// This is the HomePage of the application

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:pixamart/backend/model/categories_model.dart';
import 'package:pixamart/backend/model/wallpaper_model.dart';
import 'package:pixamart/front_end/widget/Drawer.dart';
import 'package:pixamart/front_end/widget/search_bar.dart';
import 'package:pixamart/front_end/widget/app_title.dart';
import 'package:pixamart/private.dart';
import 'package:pixamart/front_end/widget/categories.dart';
<<<<<<< Updated upstream

import '../widget/category_tile.dart';
=======
import 'package:pixamart/front_end/widget/category_tile.dart';
import 'package:rive/rive.dart';
>>>>>>> Stashed changes

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CategoriesModel> categories = [];

  Future<List<dynamic>> getTrendingWallpapers() async {
    Response url = await get(
        Uri.parse("https://api.pexels.com/v1/curated?per_page=80"),
        headers: {"Authorization": getPexelsApiKey()});
    if (url.statusCode == 200) {
      dynamic body = jsonDecode(url.body);
      List<dynamic> photos =
          body['photos'].map((dynamic item) => Photos.fromJson(item)).toList();
      return photos;
    } else {
      throw Exception('Failed to Fetch Photos');
    }
  }

  @override
  void initState() {
    super.initState();
    getTrendingWallpapers();
    categories = getCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: AppTitle(),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          SingleChildScrollView(
<<<<<<< Updated upstream
            child: Container(
              child: Column(
                children: <Widget>[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        SearchBar(),
                        Container(
                          height: 80,
                          child: ListView.builder(
                              physics: BouncingScrollPhysics(),
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              itemCount: categories.length,
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return CategoryTile(
                                  title: categories[index].categoriesName,
                                  imgUrl: categories[index].imgUrl,
                                );
                              }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height - MediaQuery.of(context).size.height / 3.9,
            child: FutureBuilder(
              future: getTrendingWallpapers(),
              builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                if (snapshot.hasData) {
                  List<dynamic> photos = snapshot.data!;
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.count(
=======
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SearchBar(),
                Container(
                  height: 50,
                  child: ListView.builder(
>>>>>>> Stashed changes
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      childAspectRatio: 0.6,
                      scrollDirection: Axis.vertical,
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: photos
                          .map((dynamic photos) => GridTile(
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, '/imageView', arguments: {'imgUrl': photos.src.portrait});
                                      //Navigator.push(context, MaterialPageRoute(builder: (context) => ImageView(imgUrl: photos.src.portrait)));
                                    },
                                    child: Hero(
                                        tag: photos.src.portrait,
                                        child: Image.network(
                                          '${photos.src.portrait}',
                                          fit: BoxFit.cover,
                                        )),
                                  ))))
                          .toList(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Failed to Load Wallpapers'));
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
<<<<<<< Updated upstream
=======
          FutureBuilder(
            future: getPexelsCuratedWallpapers(),
            builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.hasData) {
                List<dynamic> photos = snapshot.data!;
                return Stack(
                  alignment: Alignment.bottomRight,
                  children: [Container(
                    height: MediaQuery.of(context).size.height / 1.40,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.count(
                      physics: BouncingScrollPhysics(),
                      controller: scrollController,
                      shrinkWrap: true,
                      childAspectRatio: 0.6,
                      scrollDirection: Axis.vertical,
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: photoList.map((dynamic photo) => GridTile(
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
                                      child: Icon(Icons.heart_broken), // Todo change favourite icon
                                    ),
                                  ),
                                ],
                              ),
                          ),
                      ),
                      ).toList(),
                    ),
                  ),Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        scrollController.animateTo(-170, duration: Duration(milliseconds: 400), curve: Curves.easeOutSine); // easeinexpo, easeoutsine
                      },
                      child: Lottie.asset('assets/lottie/81045-rocket-launch.json',
                          height: 60,
                          width: 60,
                          fit: BoxFit.fill),
                      style: ElevatedButton.styleFrom(primary: Colors.black, shape: CircleBorder()),),
                  ),]
                );
              } else if (snapshot.hasError) {
                return Column(
                  children: [
                    Center(child: Lottie.asset('assets/lottie/8lf30_editor_6akqllok.json'),),
                  ],
                );
                //Todo change lottie asset and show server down msg
              }
              return Center(child: Lottie.asset('assets/lottie/lf30_editor_vomrc8qf.json',),);
              // Todo change lottie asset
            },
          ),
>>>>>>> Stashed changes
        ],
      ),
    );
  }
}


