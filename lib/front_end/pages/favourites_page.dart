import 'dart:async';
import 'package:PixaMart/backend/model/favourites_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';

import 'package:PixaMart/backend/functions/animate_to_top.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({Key? key}) : super(key: key);

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  late ScrollController scrollController;
  late double currentMaxScrollExtent;
  late final FirebaseAuth auth;
  late final User? user;
  late final DatabaseReference userFavouritesDatabase;
  late final CollectionReference removedFromLiked;
  late List<RxDouble> opacityManager;

  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
    user = auth.currentUser;
    scrollController = ScrollController();
    currentMaxScrollExtent = 0.0;
    userFavouritesDatabase = FirebaseDatabase.instance.ref('${user?.uid}-favourites/');
    removedFromLiked = FirebaseFirestore.instance.collection('${user?.uid}-favourites/');
    opacityManager = [
      0.0.obs,
    ];
    manageOpacity();
  }

  void manageOpacity() async {
    int i = 0;
    await Future.delayed(const Duration(milliseconds: 250));
    Timer.periodic(const Duration(milliseconds: 250), (timer) {
      if (i < opacityManager.length) {
        opacityManager[i].value = 1.0;
        i++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Box<dynamic> favouritesBox = Hive.box('${FirebaseAuth.instance.currentUser?.uid}-favourites');
    if (favouritesBox.length > 4) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Obx(
              () => AnimatedOpacity(
            duration: const Duration(milliseconds: 230),
            opacity: opacityManager[0].value,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  controller: scrollController,
                  clipBehavior: Clip.antiAlias,
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisSpacing: 0,
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.6,
                  ),
                  itemCount: favouritesBox.length,
                  itemBuilder: (context, index) {
                    final favourites = favouritesBox.getAt(favouritesBox.length - index - 1) as Favourites;
                    return GridTile(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/imageView/',
                                        arguments: {
                                          'imgShowUrl': favourites.imgShowUrl,
                                          'imgDownloadUrl': favourites.imgDownloadUrl,
                                          'alt': favourites.alt,
                                        });
                                  },
                                  child: Hero(
                                      tag: favourites.imgShowUrl.toString(),
                                      child: CachedNetworkImage(
                                        imageUrl: favourites.imgShowUrl.toString(),
                                        placeholder: (context, url) => const Icon(Icons.add),
                                        fit: BoxFit.cover,
                                      )),
                                )),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                child: const Icon(
                                  Icons.favorite_rounded,
                                  color: Colors.pink,
                                ),
                                onTap: () {
                                  Favourites lastDeleted = Favourites(
                                      favourites.imgShowUrl,
                                      favourites.imgDownloadUrl,
                                      favourites.alt);
                                  userFavouritesDatabase.child(favouritesBox.getAt(favouritesBox.length - index - 1).imgDownloadUrl.split('/')[4]).remove();
                                  removedFromLiked.doc(favouritesBox.getAt(favouritesBox.length - index - 1).imgDownloadUrl.split('/')[4]).set({
                                    'imgShowUrl': lastDeleted.imgShowUrl,
                                    'imgDownloadUrl': lastDeleted.imgDownloadUrl,
                                    'alt': lastDeleted.alt,
                                  }); // when user removes an image from liked it goes to firestore
                                  favouritesBox.deleteAt(favouritesBox.length - index - 1);
                                  setState(() {});
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: const Text('Removed from Favourites!!', style: TextStyle(
                                      fontFamily: 'Nexa',
                                      fontWeight: FontWeight.bold,
                                    ),),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20)),
                                    action: SnackBarAction(
                                      label: 'Undo',
                                      onPressed: () {
                                        favouritesBox.add(lastDeleted);
                                        userFavouritesDatabase.child(lastDeleted.imgDownloadUrl.split('/')[4]).set({
                                          'imgShowUrl': lastDeleted.imgShowUrl,
                                          'imgDownloadUrl': lastDeleted.imgDownloadUrl,
                                          'alt': lastDeleted.alt,
                                        }); // RD write complete
                                        setState(() {});
                                      },
                                    ),
                                  ));
                                },
                              ),
                            ),
                          ],
                        ));
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: ElevatedButton(
                    onPressed: () {
                      animateToTop(scrollController, MediaQuery.of(context).size.height /
                          4.7 *
                          -1);
                    },
                    style: ElevatedButton.styleFrom(
                        primary: Colors.black54, shape: const CircleBorder()),
                    child: Lottie.asset('assets/lottie/Rocket.json',
                        height: MediaQuery.of(context).size.width /
                            6.53, width: MediaQuery.of(context).size.width /
                            12.5, fit: BoxFit.fill),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.black,
        body: GridView.builder(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          controller: scrollController,
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                            Navigator.pushNamed(context, '/imageView/', arguments: {
                              'imgShowUrl': favourites.imgShowUrl,
                              'imgDownloadUrl': favourites.imgDownloadUrl,
                              'alt': favourites.alt,
                            });
                          },
                          child: Hero(
                              tag: favourites.imgShowUrl.toString(),
                              child: CachedNetworkImage(
                                imageUrl: favourites.imgShowUrl.toString(),
                                placeholder: (context, url) => const Icon(Icons.add),
                                fit: BoxFit.cover,
                              )),
                        )),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: Colors.pink,
                        ),
                        onTap: () {
                          Favourites lastDeleted = Favourites(favourites.imgShowUrl,
                              favourites.imgDownloadUrl, favourites.alt);
                          userFavouritesDatabase.child(favouritesBox.getAt(favouritesBox.length - index - 1).imgDownloadUrl.split('/')[4]).remove();
                          removedFromLiked.doc(favouritesBox.getAt(favouritesBox.length - index - 1).imgDownloadUrl.split('/')[4]).set({
                            'imgShowUrl': favouritesBox.getAt(favouritesBox.length - index - 1).imgShowUrl,
                            'imgDownloadUrl': favouritesBox.getAt(favouritesBox.length - index - 1).imgDownloadUrl,
                            'alt': favouritesBox.getAt(favouritesBox.length - index - 1).alt,
                          }); // when user removes an image from liked it goes to firestore
                          favouritesBox.deleteAt(index);
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: const Text('Removed from Favourites!!', style: TextStyle(
                              fontFamily: 'Nexa',
                              fontWeight: FontWeight.bold,
                            ),),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () {
                                favouritesBox.add(lastDeleted);
                                userFavouritesDatabase.child(lastDeleted.imgDownloadUrl.split('/')[4]).set({
                                  'imgShowUrl': lastDeleted.imgShowUrl,
                                  'imgDownloadUrl': lastDeleted.imgDownloadUrl,
                                  'alt': lastDeleted.alt,
                                }); // RD write complete
                                setState(() {});
                              },
                            ),
                          ));
                        },
                      ),
                    ),
                  ],
                ));
          },
        ),
      );
    }
  }
}