import 'package:PixaMart/backend/model/favourites_model.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';


class FavouritesPage extends StatefulWidget {
  const FavouritesPage({Key? key}) : super(key: key);

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  late ScrollController scrollController;
  late double currentMaxScrollExtent;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    currentMaxScrollExtent = 0.0;

  }
  @override
  Widget build(BuildContext context) {
    Box<dynamic> favouritesBox = Hive.box('favourites');
    if(favouritesBox.length > 4) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          alignment: Alignment.bottomRight,
          children: [
            GridView.builder(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              controller: scrollController,
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisSpacing: 0,
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                childAspectRatio: 0.6,
              ),
              itemCount: favouritesBox.length,
              itemBuilder: (context, index) {
                final favourites = favouritesBox.getAt(index) as Favourites;
                return GridTile(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                    context, '/imageView',
                                    arguments: {
                                      'imgShowUrl':
                                      favourites.imgShowUrl,
                                      'imgDownloadUrl':
                                      favourites.imgDownloadUrl,
                                      'alt': favourites.alt,
                                    });
                              },
                              child: Hero(
                                  tag: favourites.imgShowUrl.toString(),
                                  child: Image.network(
                                    '${favourites.imgShowUrl.toString()}',
                                    fit: BoxFit.cover,
                                  )),
                            )),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            child: Icon(Icons.heart_broken),
                            onTap: () {
                              Favourites lastDeleted = Favourites(favourites.imgShowUrl, favourites.imgDownloadUrl, favourites.alt);
                              favouritesBox.deleteAt(index);
                              setState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Removed from Favourites!!'), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () {
                                  favouritesBox.add(lastDeleted);
                                  setState(() {});
                                },
                              ),));
                              // Todo add to favourites code
                            },
                          ), //Todo change favourite icon
                        ),
                      ],
                    )
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 16),
              child: ElevatedButton(
                onPressed: () {
                  scrollController.animateTo(-170,
                      duration: Duration(milliseconds: 400),
                      curve: Curves
                          .easeOutSine); // easeinexpo, easeoutsine
                },
                child: Lottie.asset(
                    'assets/lottie/81045-rocket-launch.json',
                    height: 60,
                    width: 60,
                    fit: BoxFit.fill),
                style: ElevatedButton.styleFrom(
                    primary: Colors.black54, shape: CircleBorder()),
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.black,
        body: GridView.builder(
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          controller: scrollController,
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: 0,
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            childAspectRatio: 0.6,
          ),
          itemCount: favouritesBox.length,
          itemBuilder: (context, index) {
            final favourites = favouritesBox.getAt(index) as Favourites;
            return GridTile(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                                context, '/imageView',
                                arguments: {
                                  'imgShowUrl':
                                  favourites.imgShowUrl,
                                  'imgDownloadUrl':
                                  favourites.imgDownloadUrl,
                                  'alt': favourites.alt,
                                });
                          },
                          child: Hero(
                              tag: favourites.imgShowUrl.toString(),
                              child: Image.network(
                                '${favourites.imgShowUrl.toString()}',
                                fit: BoxFit.cover,
                              )),
                        )),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        child: Icon(Icons.heart_broken),
                        onTap: () {
                          Favourites lastDeleted = Favourites(favourites.imgShowUrl, favourites.imgDownloadUrl, favourites.alt);
                          favouritesBox.deleteAt(index);
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Removed from Favourites!!'), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              favouritesBox.add(lastDeleted);
                              setState(() {});
                            },
                          ),));
                          // Todo add to favourites code
                        },
                      ), //Todo change favourite icon
                    ),
                  ],
                )
            );
          },
        ),
      );
    }
  }
}
