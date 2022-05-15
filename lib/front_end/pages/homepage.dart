// This is the HomePage of the application

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pixamart/backend/model/categories_model.dart';
import 'package:pixamart/backend/model/wallpaper_model.dart';
import 'package:pixamart/front_end/widget/search_bar.dart';
import 'package:pixamart/front_end/widget/app_title.dart';
import 'package:pixamart/private.dart';
import 'package:pixamart/front_end/widget/categories.dart';
import 'package:rive/rive.dart';

import '../widget/category_tile.dart';

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
        title: AppTitle(padLeft: 0.0, padTop: MediaQuery.of(context).size.height / 16, padRight: 0.0, padBottom: 0.0,),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.all(0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SearchBar(),
                Container(
                  height: 50,
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
          FutureBuilder(
            future: getTrendingWallpapers(),
            builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.hasData) {
                List<dynamic> photos = snapshot.data!;
                return Container(
                  height: MediaQuery.of(context).size.height / 1.39,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
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
                                    Navigator.pushNamed(context, '/imageView', arguments: {'imgUrl': photos.src.original });
                                  },
                                  child: Hero(
                                      tag: photos.src.original,
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
              return Center(child: Text('Hello'));
            },
          ),
        ],
      ),
    );
  }
}


