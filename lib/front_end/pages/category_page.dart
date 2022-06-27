// This Page is for when the user clicks on a Catergory tile and lands on the page where all of the images of the same catergory is shown

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
<<<<<<< Updated upstream
import 'package:pixamart/private.dart';
=======
import 'package:lottie/lottie.dart';
import 'package:pixamart/front_end/widget/search_bar.dart';
import 'package:pixamart/private/get_pexels_api_key.dart';
>>>>>>> Stashed changes
import 'package:pixamart/backend/model/wallpaper_model.dart';
import 'package:pixamart/front_end/widget/app_title.dart';
import 'package:pixamart/front_end/pages/Image_view_page.dart';

class Category extends StatefulWidget {
  final String categoryName;
  const Category({Key? key, required this.categoryName}) : super(key: key);

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  Future<List<dynamic>> getSearchWallpapers(String query) async {
    Response url = await get(
        Uri.parse("https://api.pexels.com/v1/search?query=$query&per_page=80"),
        headers: {"Authorization": getPexelsApiKey()});
    if (url.statusCode == 200) {
      dynamic body = jsonDecode(url.body);
      List<dynamic> photos =
          body['photos'].map((dynamic item) => Photos.fromJson(item)).toList();
      //List<Photos> photos = body.toList();
      return photos;
    } else {
      throw Exception('Failed to Fetch Photos');
    }
    //print(jsonData);
  }

  @override
  void initState() {
    getSearchWallpapers(widget.categoryName);
    super.initState();
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
        title: AppTitle(),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            SizedBox(
<<<<<<< Updated upstream
              height: MediaQuery.of(context).size.height - 119,
              child: FutureBuilder(
                future: getSearchWallpapers(widget.categoryName),
                builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                  if (snapshot.hasData) {
                    List<dynamic> photos = snapshot.data!;
                    return Container(
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
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => ImageView(
                                                      imgUrl:
                                                          photos.src.portrait,
                                                    )));
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
=======
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
                  ),],
>>>>>>> Stashed changes
              ),
            ),
          ],
        ),
      ),
    );
  }
}
