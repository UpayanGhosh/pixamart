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

  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
    user = auth.currentUser;
    downloadsBox = Hive.openBox('${user?.uid}-downloads');
    downloadsList = Hive.box('${user?.uid}-downloads');
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
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    ),
                  itemCount: downloadsList.length,
                  itemBuilder: (context, index) {
                    final downloads = downloadsList.getAt(downloadsList.length - index - 1) as Favourites;
                      return Padding(
                        padding: EdgeInsets.all(1),
                        child: GridTile(
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/imageView',
                                      arguments: {
                                        'imgShowUrl': downloads.imgShowUrl,
                                        'imgDownloadUrl': downloads.imgDownloadUrl,
                                        'alt': downloads.alt,
                                      });
                                },
                                child: Hero(
                                    tag: downloads.imgShowUrl.toString(),
                                    child: Image.network(
                                      downloads.imgShowUrl.toString(),
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
