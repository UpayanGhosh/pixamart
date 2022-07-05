// This is the HomePage of the application

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:PixaMart/backend/model/categories_model.dart';
import 'package:PixaMart/backend/model/wallpaper_model.dart';
import 'package:PixaMart/front_end/widget/search_bar.dart';
import 'package:PixaMart/front_end/widget/app_title.dart';
import 'package:PixaMart/private/api_key.dart';
import 'package:PixaMart/private/get_pexels_api_key.dart';
import 'package:PixaMart/front_end/widget/categories.dart';
import 'package:PixaMart/front_end/widget/category_tile.dart';
import 'package:PixaMart/backend/model/favourites_model.dart';

import 'constants.dart';

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
  late Future<Box<dynamic>> favouritesBox;

  Future<List<dynamic>> getPexelsCuratedWallpapers() async {
    Response url = await get(
        Uri.parse('https://api.pexels.com/v1/curated?per_page=80'),
        headers: {"Authorization": getPexelsApiKey()});
    if (url.statusCode == 200) {
      Map<String, dynamic> curated = jsonDecode(url.body);
      List<dynamic> photos = curated['photos']
          .map((dynamic item) => Photos.fromJson(item))
          .toList();
      photoList.addAll(photos);
      scrollController.addListener(() async {
        if (scrollController.offset >=
                scrollController.position.maxScrollExtent &&
            !scrollController.position.outOfRange) {
          if (currentMaxScrollExtent <
              scrollController.position.maxScrollExtent) {
            currentMaxScrollExtent = scrollController.position.maxScrollExtent;
            Response url = await get(
                Uri.parse(
                    'https://api.pexels.com/v1/curated/?page=$page&per_page=80'),
                headers: {"Authorization": getPexelsApiKey()});
            page++;
            if (url.statusCode == 200) {
              Map<String, dynamic> curated = jsonDecode(url.body);
              List<dynamic> newPhotos = curated['photos']
                  .map((dynamic item) => Photos.fromJson(item))
                  .toList();
              setState(() {
                photoList.addAll(newPhotos);
                photoList.reversed;
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
      //throw Exception('Failed to Fetch Curated');
    }
  }

  addToLiked({required String imgShowUrl, required String imgDownloadUrl, required String alt}) {
    Favourites favourites = Favourites(imgShowUrl, imgDownloadUrl, alt);
    Hive.box('favourites').add(favourites);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added to Favourites!!'), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), action: SnackBarAction(
      label: 'Undo',
      onPressed: () {
        Hive.box('favourites').deleteAt(Hive.box('favourites').length - 1);
      },
    ),));
    // Todo Add to favourites code
  }

  @override
  void initState() {
    super.initState();
    page = 2;
    categories = getCategory();
    scrollController = ScrollController();
    currentMaxScrollExtent = 0.0;
    favouritesBox = Hive.openBox('favourites');
  }

  @override
  void dispose() {
    photoList.clear();
    //Hive.box('favourites').close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: favouritesBox,
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.done) {
          if(snapshot.hasData) {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.black,
              appBar: AppBar(
                elevation: 0.0,
                backgroundColor: Colors.transparent,
                title: AppTitle(
                  padLeft: MediaQuery.of(context).size.width / 26,
                  padTop: MediaQuery.of(context).size.height / 15,
                  padRight: 0,
                  padBottom: 0.0,
                ),
              ),
              body: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height / 80,),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.all(0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SearchBar(),
                        Container(
                          height: MediaQuery.of(context).size.height / 16.05,
                          child: ListView.builder(
                              physics: BouncingScrollPhysics(),
                              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 98),
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
                  SizedBox(height: MediaQuery.of(context).size.height / 80,),
                  FutureBuilder(
                    future: getPexelsCuratedWallpapers(),
                    builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                      if (snapshot.hasData) {
                        List<dynamic> photoList = snapshot.data!;
                        return Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height / 1.45,
                              decoration: BoxDecoration(),
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: GridView.count(
                                physics: BouncingScrollPhysics(),
                                controller: scrollController,
                                shrinkWrap: true,
                                childAspectRatio: 0.61,
                                scrollDirection: Axis.vertical,
                                crossAxisCount: 2,
                                crossAxisSpacing: MediaQuery.of(context).size.width / 39.2,
                                mainAxisSpacing: 0,
                                children: photoList
                                    .map((dynamic photo) => GridTile(
                                    child: Stack(
                                      alignment: Alignment.bottomRight,
                                      children: [
                                        ClipRRect(
                                            borderRadius: BorderRadius.circular(16),
                                            child: GestureDetector(
                                              onDoubleTap: () {
                                                addToLiked(imgShowUrl: photo.src.portrait, imgDownloadUrl: photo.src.original, alt: photo.alt);
                                              },
                                              onTap: () {
                                                Navigator.pushNamed(
                                                    context, '/imageView',
                                                    arguments: {
                                                      'imgShowUrl':
                                                      photo.src.portrait,
                                                      'imgDownloadUrl':
                                                      photo.src.original,
                                                      'alt': photo.alt
                                                    });
                                              },
                                              child: Hero(
                                                  tag: photo.src.portrait,
                                                  child: Image.network(
                                                    '${photo.src.portrait}',
                                                    fit: BoxFit.cover,
                                                  )),
                                            )),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GestureDetector(
                                            child: Icon(Icons.favorite_outline_rounded,color: Colors.pink,),
                                            onTap: () {
                                              addToLiked(imgShowUrl: photo.src.portrait, imgDownloadUrl: photo.src.original, alt: photo.alt);
                                            },
                                          ), //Todo change favourite icon
                                        ),
                                      ],
                                    )
                                )
                                )
                                    .toList(),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: MediaQuery.of(context).size.width / 24.5, vertical: MediaQuery.of(context).size.height / 50.15),
                              child: ElevatedButton(
                                onPressed: () {
                                  scrollController.animateTo((MediaQuery.of(context).size.height / 4.7) * -1,
                                      duration: Duration(milliseconds: 400),
                                      curve: Curves
                                          .easeOutSine); // easeinexpo, easeoutsine
                                },
                                child: Lottie.asset(
                                    'assets/lottie/81045-rocket-launch.json',
                                    height: MediaQuery.of(context).size.height / 13.5,
                                    width: MediaQuery.of(context).size.width / 12.5,
                                    fit: BoxFit.fill),
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.black54, shape: CircleBorder()),
                              ),
                            ),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Failed to Load Wallpapers'));
                      }
                      return Container(
                        margin: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height / 6.5, MediaQuery.of(context).size.width / 5.2, 0),
                        child: Lottie.asset('assets/lottie/lf30_editor_vomrc8qf.json',
                            height: MediaQuery.of(context).size.height / 4, width: MediaQuery.of(context).size.width / 1.96, fit: BoxFit.cover),
                      );
                    },
                  ),
                ],
              ),
            );
          }
          else {
            return Text('data'); //Todo add code for when Hive doesn't initialize
          }
        } else {
          return Scaffold(backgroundColor: Colors.black,);
        }
  }
    );
  }
}
