import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';

import '../../backend/model/favourites_model.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({Key? key}) : super(key: key);

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  late final FirebaseAuth auth;
  late final User? user;
  late Future<Box<dynamic>> downloadsBox;
  late Box<dynamic> downloadsList;
  late final CollectionReference cloudDownloads;

  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
    user = auth.currentUser;
    downloadsBox = Hive.openBox('${user?.uid}-downloads');
    downloadsList = Hive.box('${user?.uid}-downloads');
    cloudDownloads = FirebaseFirestore.instance.collection('${user?.uid}-downloads/');
    syncDownloads();
  }

  syncDownloads() async {
    await downloadsBox.then((value) async {
      if(value.isEmpty) {
        final snapshot = await cloudDownloads.get();
        for (var element in snapshot.docs) {
          var download = element.data() as Map;
          Favourites fav = Favourites(download['imgShowUrl'], download['imgDownloadUrl'], download['alt']);
          downloadsList.add(fav);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        title: Text(
          'Downloads',
          style: TextStyle(
            fontFamily: 'Nexa',
            fontWeight: FontWeight.bold,
            fontSize: MediaQuery.of(context).size.height / 27.8,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder(
          future: downloadsBox,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData && downloadsList.isNotEmpty) {
                return GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  clipBehavior: Clip.antiAlias,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    ),
                  itemCount: downloadsList.length,
                  itemBuilder: (context, index) {
                    final downloads = downloadsList.getAt(downloadsList.length - index - 1) as Favourites;
                      return Padding(
                        padding: const EdgeInsets.all(1),
                        child: GridTile(
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/imageView/',
                                      arguments: {
                                        'imgShowUrl': downloads.imgShowUrl,
                                        'imgDownloadUrl': downloads.imgDownloadUrl,
                                        'alt': downloads.alt,
                                      });
                                },
                                child: Hero(
                                    tag: downloads.imgShowUrl.toString(),
                                    child: CachedNetworkImage(
                                      imageUrl: downloads.imgShowUrl.toString(),
                                      placeholder: (context, url) => const Icon(Icons.add),
                                      fit: BoxFit.cover,
                                    )),
                              )),
                        ),
                      );
                  },
                );
              } else {
                return Center(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(
                        MediaQuery.of(context).size.height / 8, 0, 0, 0),
                    // padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.height/10, 0, 0, 0),
                    child: Lottie.asset(
                      'assets/lottie/Downloads.json',
                      fit: BoxFit.fill,
                      repeat: true,
                    ),
                  ),
                );
              }
            } else if (downloadsList.isEmpty) {
              return Center(
                child: Container(
                  margin: EdgeInsets.fromLTRB(
                      MediaQuery.of(context).size.height / 8, 0, 0, 0),
                  // padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.height/10, 0, 0, 0),
                  child: Lottie.asset(
                    'assets/lottie/Downloads.json',
                    fit: BoxFit.fill,
                    repeat: true,
                  ),
                ),
              );
            }
            else {
              return Center(
                child: Container(
                  margin: EdgeInsets.fromLTRB(
                      MediaQuery.of(context).size.height / 8, 0, 0, 0),
                  // padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.height/10, 0, 0, 0),
                  child: Lottie.asset(
                    'assets/lottie/Downloads.json',
                    fit: BoxFit.fill,
                    repeat: true,
                  ),
                ),
              );
            }
          }),
    );
  }
}
