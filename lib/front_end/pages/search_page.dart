// When user searches something he/she lands on this page

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pixamart/front_end/widget/animated_search_bar.dart';
import 'package:pixamart/private.dart';
import 'package:pixamart/backend/model/wallpaper_model.dart';
import 'package:pixamart/front_end/widget/app_title.dart';

class Search extends StatefulWidget {
  final TextEditingController searchQuery;
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
  }
  @override
  void initState() {
    getSearchWallpapers(widget.searchQuery.text);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    childAspectRatio: 0.6,
                    scrollDirection: Axis.vertical,
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: photos.map((dynamic photos) => GridTile(child: ClipRRect(borderRadius: BorderRadius.circular(16),child: GestureDetector(
                      onTap: (){
                        Navigator.pushNamed(context, '/imageView', arguments: {'imgUrl': photos.src.original});
                      },
                      child: Hero(
                          tag:photos.src.original, child: Image.network('${photos.src.portrait}',fit: BoxFit.cover,)),
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

        ],
      ),
    );
  }
}
