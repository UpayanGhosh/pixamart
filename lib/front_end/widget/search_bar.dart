import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:pixamart/front_end/pages/search_page.dart';
import 'package:pixamart/front_end/widget/anime.dart';

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
    return Anime(width: MediaQuery.of(context).size.width/1.525, textController: searchController, onSuffixTap: (){

    }, searchQuery: searchController,);
  }
}
