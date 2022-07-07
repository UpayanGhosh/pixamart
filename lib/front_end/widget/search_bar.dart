import 'package:flutter/material.dart';
import 'package:PixaMart/front_end/widget/animated_search_bar.dart';

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
    return Padding(
      padding:  EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 24.5, 0, 0, 0),
      child: AnimatedSearchBar(width: MediaQuery.of(context).size.width / 1.57, textController: searchController, onSuffixTap: (){
      }, searchQuery: searchController,),
    );
  }
}
