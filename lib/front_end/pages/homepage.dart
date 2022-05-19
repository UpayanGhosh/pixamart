// This is the HomePage of the application

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pixamart/backend/model/categories_model.dart';
import 'package:pixamart/backend/model/wallpaper_model.dart';
import 'package:pixamart/front_end/widget/search_bar.dart';
import 'package:pixamart/front_end/widget/app_title.dart';
import 'package:pixamart/private/get_pexels_api_key.dart';
import 'package:pixamart/front_end/widget/categories.dart';
import 'package:pixamart/front_end/widget/category_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CategoriesModel> categories = [];
  late int page;
  late ScrollController scrollController;
  List<dynamic> photoList = [];
  late double currentMaxScrollExtent;

  Future<List<dynamic>> getPexelsCuratedWallpapers() async {
    Response url = await get(
        Uri.parse('https://api.pexels.com/v1/curated?per_page=80'),
        headers: {"Authorization": getPexelsApiKey()});
    if (url.statusCode == 200) {
      Map<String, dynamic> curated = jsonDecode(url.body);
      List<dynamic> photos = curated['photos'].map((dynamic item) => Photos.fromJson(item)).toList();
      photoList.addAll(photos);
      scrollController.addListener(() async {
        if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange) {
          if(currentMaxScrollExtent < scrollController.position.maxScrollExtent) {
            currentMaxScrollExtent = scrollController.position.maxScrollExtent;
            Response url = await get(
                Uri.parse('https://api.pexels.com/v1/curated/?page=$page&per_page=80'),
                headers: {"Authorization": getPexelsApiKey()});
            page++;
            if (url.statusCode == 200) {
              Map<String, dynamic> curated = jsonDecode(url.body);
              List<dynamic> photos = curated['photos'].map((dynamic item) => Photos.fromJson(item)).toList();
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
      throw Exception('Failed to Fetch Curated');
    }
  }

  @override
  void initState() {
    super.initState();
    page = 2;
    categories = getCategory();
    scrollController = ScrollController();
    currentMaxScrollExtent = 0.0;
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
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              FutureBuilder(
                future: getPexelsCuratedWallpapers(),
                builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                  if (snapshot.hasData) {
                    List<dynamic> photos = snapshot.data!;
                    return Container(
                      height: MediaQuery.of(context).size.height / 1.39,
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
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/imageView', arguments: {'imgShowUrl': photo.src.portrait, 'imgDownloadUrl': photo.src.original});
                                  },
                                  child: Hero(
                                      tag: photo.src.portrait,
                                      child: Image.network(
                                        '${photo.src.portrait}',
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: ElevatedButton(
                  onPressed: () {
                    scrollController.animateTo(-170, duration: Duration(milliseconds: 400), curve: Curves.easeOutSine); // easeinexpo, easeoutsine
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: Icon(Icons.rocket_rounded,size: 30,),
                  ),
                  style: ElevatedButton.styleFrom(primary: Colors.black54, shape: CircleBorder()),),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


