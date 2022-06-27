// When user searches something he/she lands on this page

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
<<<<<<< Updated upstream
import 'package:pixamart/private.dart';
=======
import 'package:lottie/lottie.dart';
import 'package:pixamart/front_end/widget/animated_search_bar.dart';
import 'package:pixamart/private/get_pexels_api_key.dart';
>>>>>>> Stashed changes
import 'package:pixamart/backend/model/wallpaper_model.dart';
import '../widget/app_title.dart';
import 'Image_view_page.dart';

class Search extends StatefulWidget {
  final String searchQuery;
  const Search({Key? key, required this.searchQuery}) : super(key: key);


  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchController = TextEditingController();
  Future<List<dynamic>>getSearchWallpapers(String query) async{
    Response url = await get(Uri.parse("https://api.pexels.com/v1/search?query=$query&per_page=80"),
        headers: {
          "Authorization": getPexelsApiKey()});
    if(url.statusCode == 200){
      dynamic body = jsonDecode(url.body);
      List<dynamic> photos = body['photos'].map((dynamic item)=>Photos.fromJson(item)).toList();
      return photos;
    }
    else{
      throw Exception('Failed to Fetch Photos');
    }
    //print(jsonData);
  }
  @override
  void initState() {
    getSearchWallpapers(widget.searchQuery);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: AppTitle(),
      ),
<<<<<<< Updated upstream
      body: Container(
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
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>Search(
                        searchQuery:searchController.text,
                      )
                      ));
                    },
                    child: Container(
                        child: Icon(Icons.search)),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height - 167,
              child: FutureBuilder(
                future: getSearchWallpapers(widget.searchQuery),
                builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                  if(snapshot.hasData) {
                    List<dynamic> photos = snapshot.data!;
                    return Container(
                      padding: EdgeInsets.all(16),
                      child: GridView.count(
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        childAspectRatio: 0.6,
                        scrollDirection: Axis.vertical,
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        children: photos.map((dynamic photos) => GridTile(child: ClipRRect(borderRadius: BorderRadius.circular(16),child: GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>ImageView(imgUrl:photos.src.portrait,)));
                          },
                          child: Hero(
                              tag:photos.src.portrait,child: Image.network('${photos.src.portrait}',fit: BoxFit.cover,)),
                        )))).toList(),
                      ),
                    );
                  }
                  else if(snapshot.hasError){
                    return Center(child: Text('Failed to Load Wallpapers'));
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),
=======
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 0, 22),
            child: AnimatedSearchBar(width: MediaQuery.of(context).size.width / 1.525, searchQuery: searchController, textController: searchController, onSuffixTap:(){print("hello");}),
          ),
          FutureBuilder(
          future: getSearchWallpapers(widget.searchQuery.text),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if(snapshot.hasData) {
              List<dynamic> photos = snapshot.data!;
              return Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                  height: MediaQuery.of(context).size.height / 1.44,
                  color: Colors.black,
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
                    children: photoList.map((dynamic photo) => GridTile(child: ClipRRect(borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        alignment: Alignment.topRight,
                      children: [
                        GestureDetector(
                        onTap: (){
                          Navigator.pushNamed(context, '/imageView', arguments: {'imgShowUrl': photo.src.portrait, 'imgDownloadUrl': photo.src.original, 'alt': photo.alt});
                        },
                        child: Hero(
                          tag:photo.src.portrait,
                          child: Image.network('${photo.src.portrait}', fit: BoxFit.cover,),
                          ),
                      ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                              child: Icon(Icons.heart_broken),
                            onTap: () {
                                print('object'); // Todo add to favourites code
                            },
                          ), //Todo change favourite icon
                        ),
                      ],
                    ),
                    ),
                    ),
                    ).toList(),
                  ),
                ),
                  Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: ElevatedButton(
                    onPressed: () {
                      scrollController.animateTo(-170, duration: Duration(milliseconds: 400), curve: Curves.easeOutSine); // easeinexpo, easeoutsine
                    },
                    child: Lottie.asset('assets/lottie/81045-rocket-launch.json',
                        height: 60,
                        width: 60,
                        fit: BoxFit.fill),
                    style: ElevatedButton.styleFrom(primary: Colors.black54, shape: CircleBorder()),),
                ),
                ],
              );
            }
            else if(snapshot.hasError){
              return Center(child: Text('Failed to Load Wallpapers'));
              //Todo Lottie asset for server down and msg
            }
            return Center(child: Lottie.asset('assets/lottie/lf30_editor_vomrc8qf.json',
            height: 200,
            width: 200,));
          // Todo change lottie asset
          },
              ),
>>>>>>> Stashed changes

          ],
        ),
      ),
    );
  }
}
