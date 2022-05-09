import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pixamart/private.dart';
import 'package:pixamart/front_end/model/wallpaper_model.dart';
import 'package:pixamart/front_end/widget/brand_name.dart';
import 'package:pixamart/front_end/views/Image_view.dart';

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
        title: brand_name(),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            SizedBox(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
