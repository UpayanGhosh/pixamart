import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pixamart/data/data.dart';
import 'package:pixamart/front_end/model/categories_model.dart';
import 'package:pixamart/front_end/model/wallpaper_model.dart';
import 'package:pixamart/front_end/views/Image_view.dart';
import 'package:pixamart/front_end/views/categorie.dart';
import 'package:pixamart/front_end/views/search.dart';
import 'package:pixamart/front_end/widget/widget.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<CategoriesModel> categories = [];
  TextEditingController searchController = TextEditingController();
  Future<List<dynamic>> getTrendingWallpapers() async {
    Response url = await get(
        Uri.parse("https://api.pexels.com/v1/curated?per_page=80"),
        headers: {"Authorization": apiKey});
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
    getTrendingWallpapers();
    categories = getCategory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: brand_name(),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          SingleChildScrollView(
            child: Container(
              child: Column(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 24),
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: "search wallpaper",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Search(
                                          searchQuery: searchController.text,
                                        )));
                          },
                          child: Container(child: Icon(Icons.search)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Container(
                    height: 80,
                    child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        itemCount: categories.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          //wallpapers[index].src.portrait;
                          return CategoriesTile(
                            title: categories[index].categoriesName,
                            imgUrl: categories[index].imgUrl,
                          );
                        }),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height - 263,
            child: FutureBuilder(
              future: getTrendingWallpapers(),
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
                                                    imgUrl: photos.src.portrait,
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
    );
  }
}

class CategoriesTile extends StatelessWidget {
  final String imgUrl, title;
  CategoriesTile({required this.title, required this.imgUrl});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    Category(categoryName: title.toLowerCase())));
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        child: Stack(
          children: <Widget>[
            ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imgUrl,
                  height: 50,
                  width: 100,
                  fit: BoxFit.cover,
                )),
            Container(
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(8),
              ),
              height: 50,
              width: 100,
              alignment: Alignment.center,
              child: Text(
                title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
