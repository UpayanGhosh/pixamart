import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'package:pixamart/data/data.dart';
import '../model/wallpaper_model.dart';
import '../widget/widget.dart';
import 'Image_view.dart';
class Search extends StatefulWidget {
  final String searchQuery;
  Search({required this.searchQuery});


  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchController = TextEditingController();
  Future<List<dynamic>>getSearchWallpapers(String query) async{
    Response url = await get(Uri.parse("https://api.pexels.com/v1/search?query=$query&per_page=80"),
        headers: {
          "Authorization": apiKey});
    if(url.statusCode == 200){
      dynamic body = jsonDecode(url.body);
      List<dynamic> photos = body['photos'].map((dynamic item)=>Photos.fromJson(item)).toList();
      //List<Photos> photos = body.toList();
      print(photos);
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
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: brand_name(),
      ),
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
                        physics: ClampingScrollPhysics(),
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

              ),),

          ],
        ),
      ),
    );
  }
}
