// When user searches something he/she lands on this page

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pixamart/front_end/widget/animated_search_bar.dart';
import 'package:pixamart/private/get_pexels_api_key.dart';
import 'package:pixamart/backend/model/wallpaper_model.dart';
import 'package:pixamart/front_end/widget/app_title.dart';

class Search extends StatefulWidget {
  final TextEditingController searchQuery;
  const Search({Key? key, required this.searchQuery}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  late int page;
  late ScrollController scrollController;
  List<dynamic> photoList = [];
  late double currentMaxScrollExtent;
  TextEditingController searchController = TextEditingController();
  Future<List<dynamic>>getSearchWallpapers(String query) async{
    Response url = await get(Uri.parse("https://api.pexels.com/v1/search?query=$query&per_page=80"),
        headers: {
          "Authorization": getPexelsApiKey()});
    if(url.statusCode == 200){
      dynamic body = jsonDecode(url.body);
      List<dynamic> photos = body['photos'].map((dynamic item)=>Photos.fromJson(item)).toList();
      photoList.addAll(photos);
      scrollController.addListener(() async {
        if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange) {
          if(currentMaxScrollExtent < scrollController.position.maxScrollExtent) {
            currentMaxScrollExtent = scrollController.position.maxScrollExtent;
            Response url = await get(
                Uri.parse('https://api.pexels.com/v1/search?query/?page=$page&per_page=80'),
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
    }
    else{
      throw Exception('Failed to Fetch Photos');
    }
  }
  @override
  void initState() {
    getSearchWallpapers(widget.searchQuery.text);
    page = 2;
    scrollController = ScrollController();
    currentMaxScrollExtent = 0.0;
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
        backgroundColor: Colors.transparent,
        title: AppTitle(padLeft: 0.0, padTop: 60.0, padRight: 0.0, padBottom: 15.0,),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 0, 22),
            child: AnimatedSearchBar(width: MediaQuery.of(context).size.width / 1.525, searchQuery: searchController, textController: searchController, onSuffixTap:(){print("hello");}),
          ),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
                FutureBuilder(
                future: getSearchWallpapers(widget.searchQuery.text),
                builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                  if(snapshot.hasData) {
                    List<dynamic> photos = snapshot.data!;
                    return Container(
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
                        children: photoList.map((dynamic photo) => GridTile(child: ClipRRect(borderRadius: BorderRadius.circular(16),child: GestureDetector(
                          onTap: (){
                            Navigator.pushNamed(context, '/imageView', arguments: {'imgShowUrl': photo.src.portrait, 'imgDownloadUrl': photo.src.original});
                          },
                          child: Hero(
                              tag:photo.src.portrait,
                              child: Image.network('${photo.src.portrait}',fit: BoxFit.cover,)),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: ElevatedButton(
                  onPressed: () {
                    scrollController.animateTo(-170, duration: Duration(milliseconds: 400), curve: Curves.easeOutSine); // easeinexpo, easeoutsine
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: Icon(Icons.rocket),
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
