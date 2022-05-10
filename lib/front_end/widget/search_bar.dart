import 'package:flutter/material.dart';
import 'package:pixamart/front_end/pages/search_page.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 2,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.fromLTRB(14, 0,0,30),
      padding: EdgeInsets.symmetric(horizontal: 20),
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
    );
  }
}
